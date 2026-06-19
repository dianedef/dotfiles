local git = require("neogit.lib.git")

local M = {}

local state_by_tab = {}

local function notify(message, level)
  vim.schedule(function()
    vim.notify("difftastic: " .. message, level or vim.log.levels.INFO)
  end)
end

local function run_git(git_root, args)
  local cmd = { "git", "-C", git_root }
  vim.list_extend(cmd, args)
  return vim.system(cmd, { text = true }):wait()
end

local function split_lines(text)
  if not text or text == "" then
    return {}
  end

  local lines = vim.split(text, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

local function make_empty_file()
  local path = vim.fn.tempname()
  vim.fn.writefile({}, path)
  return path
end

local function make_temp_from_lines(lines)
  local path = vim.fn.tempname()
  vim.fn.writefile(lines, path, "b")
  return path
end

local function make_temp_from_git(git_root, spec)
  local result = run_git(git_root, { "show", spec })
  if result.code ~= 0 then
    return make_empty_file()
  end
  return make_temp_from_lines(split_lines(result.stdout))
end

local function make_temp_from_worktree(path)
  if vim.fn.filereadable(path) ~= 1 then
    return make_empty_file()
  end
  return make_temp_from_lines(vim.fn.readfile(path, "b"))
end

local function build_git_spec(rev, path)
  return ("%s:%s"):format(rev, path)
end

local function entry_display(entry)
  return string.format("%-10s %s", entry.kind, entry.path)
end

local function parse_name_status(lines)
  local entries = {}

  for _, line in ipairs(lines) do
    if line ~= "" then
      local status, rest = line:match("^(%S+)%s+(.+)$")
      if status and rest then
        local path = rest:match("^[^\t]+$") or select(2, rest:match("^([^\t]+)\t(.+)$"))
        table.insert(entries, {
          status = status,
          path = path or rest,
        })
      end
    end
  end

  return entries
end

local function collect_staged_entries(git_root)
  local result = run_git(git_root, { "diff", "--cached", "--name-status", "--no-renames", "--relative" })
  if result.code ~= 0 then
    return nil, result.stderr
  end

  local entries = {}
  for _, item in ipairs(parse_name_status(split_lines(result.stdout))) do
    table.insert(entries, {
      kind = "staged",
      path = item.path,
      left = { type = "git", spec = build_git_spec("HEAD", item.path), label = "HEAD" },
      right = { type = "git", spec = ":" .. item.path, label = "INDEX" },
    })
  end

  return entries
end

local function collect_unstaged_entries(git_root)
  local result = run_git(git_root, { "diff", "--name-status", "--no-renames", "--relative" })
  if result.code ~= 0 then
    return nil, result.stderr
  end

  local entries = {}
  for _, item in ipairs(parse_name_status(split_lines(result.stdout))) do
    table.insert(entries, {
      kind = "unstaged",
      path = item.path,
      left = { type = "git", spec = ":" .. item.path, label = "INDEX" },
      right = { type = "worktree", path = git_root .. "/" .. item.path, label = "WORKTREE" },
    })
  end

  return entries
end

local function collect_worktree_entries(git_root)
  local result = run_git(git_root, { "status", "--porcelain=v1", "--untracked-files=all" })
  if result.code ~= 0 then
    return nil, result.stderr
  end

  local entries = {}
  for _, line in ipairs(split_lines(result.stdout)) do
    if line:match("^%?%? ") then
      local path = line:sub(4)
      table.insert(entries, {
        kind = "untracked",
        path = path,
        left = { type = "empty", label = "/dev/null" },
        right = { type = "worktree", path = git_root .. "/" .. path, label = "WORKTREE" },
      })
    else
      local x = line:sub(1, 1)
      local y = line:sub(2, 2)
      local path = line:sub(4)

      if x ~= " " and x ~= "?" then
        table.insert(entries, {
          kind = "staged",
          path = path,
          left = { type = "git", spec = build_git_spec("HEAD", path), label = "HEAD" },
          right = { type = "git", spec = ":" .. path, label = "INDEX" },
        })
      end

      if y ~= " " and y ~= "?" then
        table.insert(entries, {
          kind = "unstaged",
          path = path,
          left = { type = "git", spec = ":" .. path, label = "INDEX" },
          right = { type = "worktree", path = git_root .. "/" .. path, label = "WORKTREE" },
        })
      end
    end
  end

  return entries
end

local function resolve_single_ref(git_root, ref)
  local result = run_git(git_root, { "rev-parse", ref })
  if result.code ~= 0 then
    return nil, result.stderr
  end
  return vim.trim(result.stdout)
end

local function resolve_range(git_root, range)
  local triple_a, triple_b = range:match("^(.-)%.%.%.(.-)$")
  if triple_a then
    local target = triple_b ~= "" and triple_b or "HEAD"
    local merge_base = run_git(git_root, { "merge-base", triple_a, target })
    if merge_base.code ~= 0 then
      return nil, nil, merge_base.stderr
    end
    local right = resolve_single_ref(git_root, target)
    if not right then
      return nil, nil, "unable to resolve target revision"
    end
    return vim.trim(merge_base.stdout), right
  end

  local left, right = range:match("^(.-)%.%.(.-)$")
  if not left or not right then
    return nil, nil, "invalid range"
  end

  local left_rev = resolve_single_ref(git_root, left)
  local right_rev = resolve_single_ref(git_root, right)
  if not left_rev or not right_rev then
    return nil, nil, "unable to resolve revisions"
  end

  return left_rev, right_rev
end

local function collect_revision_entries(git_root, left_rev, right_rev, kind)
  local result = run_git(git_root, { "diff", "--name-status", "--no-renames", "--relative", left_rev, right_rev })
  if result.code ~= 0 then
    return nil, result.stderr
  end

  local entries = {}
  for _, item in ipairs(parse_name_status(split_lines(result.stdout))) do
    table.insert(entries, {
      kind = kind or "range",
      path = item.path,
      left = { type = "git", spec = build_git_spec(left_rev, item.path), label = left_rev:sub(1, 8) },
      right = { type = "git", spec = build_git_spec(right_rev, item.path), label = right_rev:sub(1, 8) },
    })
  end

  return entries
end

local function materialize_side(git_root, side)
  if side.type == "git" then
    return make_temp_from_git(git_root, side.spec), side.label
  elseif side.type == "worktree" then
    return make_temp_from_worktree(side.path), side.label
  end

  return make_empty_file(), side.label
end

local function render_list(state)
  local lines = {
    ("Difftastic %s"):format(state.title),
    "j/k: navigate  <Enter>: refresh  q: close",
    "",
  }

  for _, entry in ipairs(state.entries) do
    table.insert(lines, entry_display(entry))
  end

  vim.bo[state.list_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.list_buf, 0, -1, false, lines)
  vim.bo[state.list_buf].modifiable = false
end

local function current_index(state)
  local line = vim.api.nvim_win_get_cursor(state.list_win)[1]
  local idx = line - state.offset
  if idx < 1 then
    idx = 1
  elseif idx > #state.entries then
    idx = #state.entries
  end
  return idx
end

local function ensure_terminal_window(state)
  if vim.api.nvim_win_is_valid(state.term_win) then
    return
  end

  vim.api.nvim_set_current_win(state.list_win)
  vim.cmd("wincmd l")
  state.term_win = vim.api.nvim_get_current_win()
end

local function preview_entry(state, idx)
  local entry = state.entries[idx]
  if not entry then
    return
  end

  state.current = idx
  ensure_terminal_window(state)

  local left_path, left_label = materialize_side(state.git_root, entry.left)
  local right_path, right_label = materialize_side(state.git_root, entry.right)

  vim.api.nvim_set_current_win(state.term_win)
  vim.cmd("enew")
  local term_buf = vim.api.nvim_get_current_buf()
  state.term_buf = term_buf
  vim.bo[term_buf].bufhidden = "wipe"

  local title = string.format("%s (%s -> %s)", entry.path, left_label or "LEFT", right_label or "RIGHT")
  vim.api.nvim_buf_set_name(term_buf, "difftastic://" .. entry.path)
  vim.fn.termopen({
    "difft",
    "--color=always",
    "--display=side-by-side-show-both",
    "--context=3",
    left_path,
    right_path,
  }, {
    on_exit = function()
      pcall(vim.fn.delete, left_path)
      pcall(vim.fn.delete, right_path)
    end,
  })
  vim.cmd("setlocal nonumber norelativenumber signcolumn=no")
  vim.api.nvim_buf_set_lines(term_buf, 0, 0, false, { title, "" })

  vim.api.nvim_set_current_win(state.list_win)
end

local function refresh_preview(state)
  if #state.entries == 0 then
    return
  end
  preview_entry(state, current_index(state))
end

local function close_tab(tabpage, on_close)
  if on_close then
    pcall(on_close)
  end
  if vim.api.nvim_tabpage_is_valid(tabpage) then
    vim.api.nvim_set_current_tabpage(tabpage)
    vim.cmd("tabclose")
  end
end

local function open_tab(state)
  vim.cmd("tabnew")
  state.tabpage = vim.api.nvim_get_current_tabpage()
  state.list_win = vim.api.nvim_get_current_win()
  state.list_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(state.list_win, state.list_buf)
  vim.bo[state.list_buf].buftype = "nofile"
  vim.bo[state.list_buf].bufhidden = "wipe"
  vim.bo[state.list_buf].swapfile = false
  vim.bo[state.list_buf].filetype = "DifftasticExplorer"
  vim.bo[state.list_buf].modifiable = false
  vim.wo[state.list_win].number = false
  vim.wo[state.list_win].relativenumber = false
  vim.wo[state.list_win].cursorline = true
  vim.cmd("vertical resize 42")
  vim.cmd("vsplit")
  state.term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(state.list_win)

  state.offset = 3
  render_list(state)

  local opts = { buffer = state.list_buf, silent = true, nowait = true }
  vim.keymap.set("n", "q", function()
    close_tab(state.tabpage, state.on_close)
  end, opts)
  vim.keymap.set("n", "<CR>", function()
    refresh_preview(state)
  end, opts)
  vim.keymap.set("n", "r", function()
    refresh_preview(state)
  end, opts)

  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    buffer = state.list_buf,
    callback = function()
      refresh_preview(state)
    end,
  })

  vim.api.nvim_create_autocmd({ "TabClosed" }, {
    once = true,
    callback = function()
      state_by_tab[state.tabpage] = nil
      if state.on_close then
        pcall(state.on_close)
      end
    end,
  })

  state_by_tab[state.tabpage] = state
  if #state.entries > 0 then
    vim.api.nvim_win_set_cursor(state.list_win, { state.offset, 0 })
    refresh_preview(state)
  else
    notify("no files to diff")
  end
end

local function normalize_ref(ref)
  if type(ref) ~= "string" then
    return ref
  end

  local stash_ref = ref:match("(stash@{%d+})")
  if stash_ref then
    return stash_ref
  end

  return vim.trim(ref)
end

local function extract_commit(item_name)
  if type(item_name) ~= "string" then
    return nil
  end

  local from_start = item_name:match("^([0-9a-fA-F]+)")
  if from_start then
    return from_start
  end

  return item_name:match("([0-9a-fA-F][0-9a-fA-F]+)")
end

local function build_state(git_root, title, entries, opts)
  return {
    git_root = git_root,
    title = title,
    entries = entries or {},
    on_close = opts and opts.on_close and opts.on_close.fn or nil,
  }
end

function M.open(section_name, item_name, opts)
  if vim.fn.executable("difft") ~= 1 then
    notify("difft is not installed", vim.log.levels.ERROR)
    return
  end

  local git_root = git.repo.worktree_root
  if type(git_root) ~= "string" or git_root == "" then
    notify("git root is unavailable", vim.log.levels.ERROR)
    return
  end

  local entries, err, title

  if section_name == "staged" then
    entries, err = collect_staged_entries(git_root)
    title = "staged"
  elseif section_name == "unstaged" then
    entries, err = collect_unstaged_entries(git_root)
    title = "unstaged"
  elseif section_name == "worktree" or (section_name == nil and item_name == nil) then
    entries, err = collect_worktree_entries(git_root)
    title = "worktree"
  elseif section_name == "range" and item_name then
    local left_rev, right_rev, range_err = resolve_range(git_root, item_name)
    if not left_rev then
      notify(range_err or "invalid range", vim.log.levels.ERROR)
      return
    end
    entries, err = collect_revision_entries(git_root, left_rev, right_rev, "range")
    title = item_name
  elseif (section_name == "commit" or section_name == "stashes") and item_name then
    local ref = normalize_ref(item_name)
    local right_rev, resolve_err = resolve_single_ref(git_root, ref)
    if not right_rev then
      notify(resolve_err or "unable to resolve revision", vim.log.levels.ERROR)
      return
    end
    entries, err = collect_revision_entries(git_root, right_rev .. "^", right_rev, section_name)
    title = ref
  elseif (section_name == "recent" or section_name == "log") and item_name then
    local rev1
    local rev2

    if type(item_name) == "table" then
      rev1 = normalize_ref(item_name[1])
      rev2 = normalize_ref(item_name[#item_name])
    else
      rev2 = extract_commit(item_name)
      rev1 = rev2 and (rev2 .. "^") or nil
    end

    if not rev1 or not rev2 then
      notify("could not resolve selected commit range", vim.log.levels.ERROR)
      return
    end

    entries, err = collect_revision_entries(git_root, rev1, rev2, section_name)
    title = ("%s..%s"):format(rev1, rev2)
  else
    notify("unsupported Neogit section for difftastic viewer: " .. tostring(section_name), vim.log.levels.WARN)
    return
  end

  if not entries then
    notify(err or "failed to build difftastic view", vim.log.levels.ERROR)
    return
  end

  if type(item_name) == "string" and item_name ~= "" then
    table.sort(entries, function(a, b)
      if a.path == item_name then
        return true
      elseif b.path == item_name then
        return false
      end
      return a.path < b.path
    end)
  end

  open_tab(build_state(git_root, title or "diff", entries, opts))
end

return M
