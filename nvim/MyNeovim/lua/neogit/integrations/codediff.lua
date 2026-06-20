local M = {}

local function git_root()
  return vim.fs.root(0, { ".git" }) or vim.fs.root(vim.uv.cwd(), { ".git" })
end

local function notify_error(message)
  vim.schedule(function()
    vim.notify("codediff: " .. message, vim.log.levels.ERROR)
  end)
end

local function run_git(root, args)
  local result = vim.system(vim.list_extend({ "git", "-C", root }, args), { text = true }):wait()
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or result.stdout or "")
  end

  return result.stdout or ""
end

local function split_paths(stdout)
  local paths = {}
  for _, line in ipairs(vim.split(stdout or "", "\n", { plain = true, trimempty = true })) do
    local path = vim.trim(line)
    if path ~= "" then
      paths[#paths + 1] = path
    end
  end
  return paths
end

local function unique(paths)
  local seen = {}
  local result = {}

  for _, path in ipairs(paths or {}) do
    if path and path ~= "" and not seen[path] then
      seen[path] = true
      result[#result + 1] = path
    end
  end

  return result
end

local function list_worktree_paths(root)
  local changed, err = run_git(root, { "diff", "--name-only", "--diff-filter=ACMR", "HEAD", "--" })
  if not changed then
    return nil, err
  end

  local untracked, untracked_err = run_git(root, { "ls-files", "--others", "--exclude-standard" })
  if not untracked then
    return nil, untracked_err
  end

  return unique(vim.list_extend(split_paths(changed), split_paths(untracked)))
end

local function list_staged_paths(root)
  local stdout, err = run_git(root, { "diff", "--cached", "--name-only", "--diff-filter=ACMR", "--" })
  if not stdout then
    return nil, err
  end

  return split_paths(stdout)
end

local function list_unstaged_paths(root)
  local changed, err = run_git(root, { "diff", "--name-only", "--diff-filter=ACMR", "--" })
  if not changed then
    return nil, err
  end

  local untracked, untracked_err = run_git(root, { "ls-files", "--others", "--exclude-standard" })
  if not untracked then
    return nil, untracked_err
  end

  return unique(vim.list_extend(split_paths(changed), split_paths(untracked)))
end

local function read_file(path)
  local handle = io.open(path, "rb")
  if not handle then
    return nil
  end

  local content = handle:read("*a")
  handle:close()
  return content
end

local function write_file(path, content)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local handle = assert(io.open(path, "wb"))
  handle:write(content or "")
  handle:close()
end

local function temp_dir()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  return dir
end

local function cleanup_dirs(dirs)
  for _, dir in ipairs(dirs or {}) do
    pcall(vim.fn.delete, dir, "rf")
  end
end

local function source_content(root, source, path)
  if source.kind == "worktree" then
    return read_file(vim.fs.joinpath(root, path))
  end

  if source.kind == "index" then
    return run_git(root, { "show", ":" .. path })
  end

  if source.kind == "rev" then
    return run_git(root, { "show", source.ref .. ":" .. path })
  end

  return source.kind == "empty" and "" or nil
end

local function build_snapshot(root, source, paths)
  local dir = temp_dir()
  for _, path in ipairs(paths or {}) do
    local content = source_content(root, source, path)
    if content ~= nil then
      write_file(vim.fs.joinpath(dir, path), content)
    end
  end
  return dir
end

local function parse_range(item_name)
  if type(item_name) ~= "string" then
    return nil
  end

  local range = vim.trim(item_name)
  if range == "" then
    return nil
  end

  local left, right = range:match("^(.-)%.%.(.-)$")
  if left then
    left = vim.trim(left)
    right = vim.trim(right)
    if left == "" or right == "" then
      return nil
    end
    return { kind = "double", left = left, right = right }
  end

  local base, target = range:match("^(.-)%.%.%.(.-)$")
  if base then
    base = vim.trim(base)
    target = vim.trim(target)
    if base == "" then
      return nil
    end
    return { kind = "triple", base = base, target = target ~= "" and target or "HEAD" }
  end

  return nil
end

local function resolve_range(root, item_name)
  local parsed = parse_range(item_name)
  if not parsed then
    return nil, nil
  end

  if parsed.kind == "double" then
    return parsed.left, parsed.right
  end

  local merge_base, err = run_git(root, { "merge-base", parsed.base, parsed.target })
  if not merge_base then
    return nil, err
  end

  return vim.trim(merge_base), parsed.target
end

local function open_terminal(root, left_dir, right_dir)
  vim.cmd("botright split")
  vim.cmd("resize " .. math.max(12, math.floor(vim.o.lines * 0.4)))

  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "difftastic"

  local dirs = { left_dir, right_dir }
  vim.b[buf].diffflowz_temp_dirs = dirs

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      cleanup_dirs(dirs)
    end,
  })

  vim.fn.termopen({ "difft", "--display=inline", "--color=always", left_dir, right_dir }, { cwd = root })
  vim.cmd("startinsert")
end

local function open_sources(root, left_source, right_source, paths)
  local filtered = unique(paths or {})
  if #filtered == 0 then
    notify_error("no files to compare")
    return
  end

  if vim.fn.executable("difft") ~= 1 then
    notify_error("difft is not installed")
    return
  end

  local left_dir = build_snapshot(root, left_source, filtered)
  local right_dir = build_snapshot(root, right_source, filtered)
  open_terminal(root, left_dir, right_dir)
end

local function open_worktree(root, item_name)
  local paths = item_name and { item_name } or list_worktree_paths(root)
  if not paths then
    return nil, "unable to inspect working tree"
  end

  open_sources(root, { kind = "rev", ref = "HEAD" }, { kind = "worktree" }, paths)
end

local function open_staged(root, item_name)
  local paths = item_name and { item_name } or list_staged_paths(root)
  if not paths then
    return nil, "unable to inspect staged changes"
  end

  open_sources(root, { kind = "rev", ref = "HEAD" }, { kind = "index" }, paths)
end

local function open_unstaged(root, item_name)
  local paths = item_name and { item_name } or list_unstaged_paths(root)
  if not paths then
    return nil, "unable to inspect unstaged changes"
  end

  open_sources(root, { kind = "index" }, { kind = "worktree" }, paths)
end

local function open_range(root, item_name)
  local left, right, err = nil, nil, nil
  local parsed = parse_range(item_name)
  if not parsed then
    return nil, "invalid range"
  end

  if parsed.kind == "double" then
    left, right = parsed.left, parsed.right
  else
    left, err = resolve_range(root, item_name)
    if not left then
      return nil, err or "unable to resolve merge-base"
    end
    right = parsed.target
  end

  local paths, paths_err = run_git(root, { "diff", "--name-only", "--diff-filter=ACMR", left, right, "--" })
  if not paths then
    return nil, paths_err
  end

  open_sources(root, { kind = "rev", ref = left }, { kind = "rev", ref = right }, split_paths(paths))
end

local function open_commit(root, item_name)
  if type(item_name) ~= "string" or vim.trim(item_name) == "" then
    return nil, "invalid revision"
  end

  local paths, err = run_git(root, { "diff", "--name-only", "--diff-filter=ACMR", item_name .. "^", item_name, "--" })
  if not paths then
    return nil, err
  end

  open_sources(root, { kind = "rev", ref = item_name .. "^" }, { kind = "rev", ref = item_name }, split_paths(paths))
end

function M.open(section_name, item_name, _opts)
  local root = git_root()
  if not root then
    notify_error("no Git repository found")
    return
  end

  if section_name == "staged" then
    local ok, err = open_staged(root, item_name)
    if not ok and err then
      notify_error(err)
    end
    return
  end

  if section_name == "unstaged" then
    local ok, err = open_unstaged(root, item_name)
    if not ok and err then
      notify_error(err)
    end
    return
  end

  if section_name == "range" then
    local ok, err = open_range(root, item_name)
    if not ok and err then
      notify_error(err)
    end
    return
  end

  if section_name == "commit" or section_name == "stashes" or section_name == "log" or section_name == "recent" then
    local ok, err = open_commit(root, item_name)
    if not ok and err then
      notify_error(err)
    end
    return
  end

  local ok, err = open_worktree(root, item_name)
  if not ok and err then
    notify_error(err)
  end
end

return M
