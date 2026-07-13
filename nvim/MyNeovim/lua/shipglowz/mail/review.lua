local M = {}
local config = require("shipglowz.mail.config")
local clipboard = require("shipglowz.clipboard")
local ai = require("shipglowz.mail.ai")

local review_tabpage
local active_path
local review_list_win
local review_source_win

local function resize_review_layout()
  if not review_tabpage or not vim.api.nvim_tabpage_is_valid(review_tabpage) then return end
  if not review_list_win or not vim.api.nvim_win_is_valid(review_list_win) then return end
  if not review_source_win or not vim.api.nvim_win_is_valid(review_source_win) then return end
  if vim.api.nvim_win_get_tabpage(review_list_win) ~= review_tabpage then return end

  local available_height = math.max(1, vim.o.lines - vim.o.cmdheight - 2)
  local list_height = math.floor(available_height * 0.24)
  list_height = math.max(8, math.min(16, list_height))
  pcall(vim.api.nvim_win_set_height, review_list_win, list_height)
end

local function root()
  return vim.fn.expand(config.get().private_root)
end

local function cli(args, callback)
  local command = { config.get().intake_cli }
  vim.list_extend(command, args)
  vim.system(command, config.system_opts(), function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify((result.stderr or "mail-intake failed"):gsub("%s+$", ""), vim.log.levels.ERROR)
        return
      end
      callback(result.stdout or "")
    end)
  end)
end

local function files(folder)
  local result = vim.fn.globpath(root() .. "/" .. folder, "*.md", false, true)
  table.sort(result)
  return result
end

local function item_key(path)
  return vim.fn.fnamemodify(path, ":t:r")
end

local function source_buffer_name(path, buf)
  local base = "Mail source " .. item_key(path)
  local existing = vim.fn.bufnr(base)
  if existing == -1 or existing == buf then return base end
  return base .. " " .. tostring(buf)
end

local function unquote(value)
  value = vim.trim(value or "")
  if (value:sub(1, 1) == '"' and value:sub(-1) == '"') or (value:sub(1, 1) == "'" and value:sub(-1) == "'") then
    return value:sub(2, -2)
  end
  return value
end

local function queue_metadata(path)
  local metadata = {}
  local lines = vim.fn.readfile(path)
  if lines[1] ~= "---" then return metadata end
  for index = 2, #lines do
    local line = lines[index]
    if line == "---" then break end
    local key, value = line:match("^([%w_-]+):%s*(.*)$")
    if key then metadata[key] = unquote(value) end
  end
  return metadata
end

local function source_id(path)
  return queue_metadata(path).source_id
end

local function queue_item_path()
  local paths = vim.b.mail_intake_paths
  local item_index = vim.fn.line(".") - 6
  return paths and paths[item_index] or nil
end

local function open_source(path, callback)
  local id = source_id(path)
  if not id then
    vim.notify("Queue item has no source_id", vim.log.levels.ERROR)
    return
  end
  local command = {
    config.get().cli,
    "--maildir-root",
    config.get().maildir_root,
    "export",
    id,
    "--markdown",
  }
  vim.system(command, config.system_opts(), function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify((result.stderr or "mail-intel failed"):gsub("%s+$", ""), vim.log.levels.ERROR)
        return
      end
      callback(result.stdout or "")
    end)
  end)
end

local function render_list(preferred_key, message_only)
  local list = files("inbox")
  if message_only and preferred_key then
    for _, path in ipairs(list) do
      if item_key(path) == preferred_key then active_path = path; break end
    end
  end
  local lines = { "MAIL INTELLIGENCE", "", "Emails a traiter : " .. #list, "", "j/k move   r resume 1-5 phrases   a ask AI   h handoff   o navigateur   y accepter   e edit   x rejeter   d trash Gmail   i ignore", "" }
  for _, path in ipairs(list) do
    local title = "(sans sujet)"
    local sender = "expéditeur inconnu"
    for _, line in ipairs(vim.fn.readfile(path)) do
      if title == "(sans sujet)" and line:match("^# ") then title = line:sub(3) end
      local label = line:match("^%- Sender:%s*`([^`]*)`")
      if label and label ~= "" then sender = label end
    end
    table.insert(lines, string.format("%s | %s", sender, title))
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "Mail Intelligence")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "mail-intake"
  vim.bo[buf].modifiable = false
  vim.b[buf].mail_intake_paths = list

  local bind_body_actions
  -- Mail review must not inherit a reduced float or an application split.
  -- A dedicated tab gives it the same full-workspace behavior as Neogit.
  if not review_tabpage or not vim.api.nvim_tabpage_is_valid(review_tabpage) then
    vim.cmd("tab sb " .. buf)
    review_tabpage = vim.api.nvim_get_current_tabpage()
  else
    vim.api.nvim_set_current_tabpage(review_tabpage)
  end

  -- Rebuilds after an action reuse the review tab but reset its two-pane layout.
  vim.cmd("silent only")
  vim.api.nvim_win_set_buf(0, buf)
  local list_win = vim.api.nvim_get_current_win()
  local source_win
  local source_buf
  review_list_win = list_win
  review_source_win = nil

  local function show_source(path, markdown)
    active_path = path
    if not source_win or not vim.api.nvim_win_is_valid(source_win) then
      vim.api.nvim_set_current_win(list_win)
      source_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(source_buf, source_buffer_name(path, source_buf))
      vim.bo[source_buf].bufhidden = "wipe"
      vim.bo[source_buf].filetype = "markdown"
      source_win = vim.api.nvim_open_win(source_buf, true, { split = "below", win = list_win })
      review_source_win = source_win
      vim.wo[list_win].winfixheight = true
      resize_review_layout()
    end
    vim.api.nvim_buf_set_name(source_buf, source_buffer_name(path, source_buf))
    vim.bo[source_buf].modifiable = true
    local display_lines = vim.split(markdown, "\n", { plain = true })
    if message_only then
      local header = "MAIL EMAIL | a IA  r resume  h handoff  o navigateur  y accepter  x rejeter  d corbeille  i ignorer  Tab suivant  S-Tab precedent"
      table.insert(display_lines, 1, "")
      table.insert(display_lines, 1, header)
    end
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, display_lines)
    vim.bo[source_buf].modifiable = false
    vim.api.nvim_win_set_buf(source_win, source_buf)
    if message_only then
      vim.api.nvim_set_current_win(source_win)
      vim.cmd("silent only")
      bind_body_actions(source_buf)
    else
      vim.api.nvim_set_current_win(list_win)
    end
  end

  local function current_path()
    return message_only and active_path or queue_item_path()
  end
  local function next_key(path)
    local current = item_key(path)
    for index, candidate in ipairs(list) do
      if item_key(candidate) == current then
        local next_item = list[index + 1] or list[index - 1]
        return next_item and item_key(next_item) or nil
      end
    end
    return nil
  end
  local function open_item()
    local path = current_path()
    if not path then return end
    open_source(path, function(markdown)
      show_source(path, markdown)
    end)
  end
  local function move_item(delta)
    if #list == 0 then return end
    local current_index = vim.fn.line(".") - 6
    local next_index = math.max(1, math.min(#list, current_index + delta))
    vim.api.nvim_win_set_cursor(list_win, { next_index + 6, 0 })
    open_item()
  end
  local function ask_ai(question)
    local path = current_path()
    if not path then return end
    open_source(path, function(markdown)
      show_source(path, markdown)
      ai.ask(question, markdown)
    end)
  end
  local function locate_source(path, callback)
    vim.system({ config.get().cli, "--maildir-root", config.get().maildir_root, "locate", source_id(path) }, config.system_opts(), function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify((result.stderr or "source locale introuvable"):gsub("%s+$", ""), vim.log.levels.ERROR)
          return
        end
        callback(vim.trim(result.stdout or ""))
      end)
    end)
  end
  local function classify_ai()
    local path = current_path()
    if not path then return end
    open_source(path, function(markdown)
      show_source(path, markdown)
      locate_source(path, function(source_path)
        ai.classify("Classe cet email pour la revue humaine et produis le JSON demande.", markdown, path, function(value, err)
          vim.schedule(function()
            if not value then
              vim.notify(err or "Classification impossible", vim.log.levels.ERROR)
              return
            end
            vim.notify("Proposition IA enregistree dans la fiche privee", vim.log.levels.INFO)
            render_list(item_key(path), message_only)
          end)
        end, source_path)
      end)
    end)
  end
  local function summarize()
    ask_ai("Resume cet email en 1 a 5 phrases maximum. Donne uniquement le resume factuel, sans proposer de projet, d'angle ou d'action. N'invente rien et ne copie pas le texte source.")
  end
  local function reopen_following(following_key)
    if not following_key then
      vim.cmd("MailIntake")
      return
    end
    vim.cmd((message_only and "MailIntakeMessage" or "MailIntake") .. " " .. following_key)
  end
  local function update(status)
    local path = current_path()
    if not path then return end
    local following_key = next_key(path)
    cli({ "--private-root", root(), "update", item_key(path), status }, function()
      reopen_following(following_key)
    end)
  end
  local function delete_source()
    local path = current_path()
    if not path then return end
    local id = source_id(path)
    if not id then
      vim.notify("Queue item has no source_id", vim.log.levels.ERROR)
      return
    end
    local following_key = next_key(path)
    vim.system({
      config.get().delete_cli,
      "--account", config.get().default_account,
      "--folder", config.get().default_folder,
      "--source-id", id,
    }, config.system_opts(), function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify((result.stderr or "mail-delete failed"):gsub("%s+$", ""), vim.log.levels.ERROR)
          return
        end
        cli({ "--private-root", root(), "update", item_key(path), "deleted" }, function()
          vim.notify("Email envoyé dans la corbeille Gmail", vim.log.levels.INFO)
          reopen_following(following_key)
        end)
      end)
    end)
  end
  local function open_browser_link()
    local path = current_path()
    if not path then return end
    vim.system({ config.get().cli, "--maildir-root", config.get().maildir_root, "--format", "json", "urls", source_id(path) }, config.system_opts(), function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify((result.stderr or "liens introuvables"):gsub("%s+$", ""), vim.log.levels.ERROR)
          return
        end
        local ok, urls = pcall(vim.json.decode, result.stdout or "[]")
        if not ok or type(urls) ~= "table" or #urls == 0 then
          vim.notify("Aucun lien web trouve dans cet email", vim.log.levels.WARN)
          return
        end
        local choices = {}
        for _, item in ipairs(urls) do table.insert(choices, item.label or "Lien web") end
        vim.ui.select(choices, { prompt = "Ouvrir le lien dans le navigateur:" }, function(_, index)
          local item = index and urls[index]
          if item then vim.ui.open(item.url) end
        end)
      end)
    end)
  end
  local function edit_item()
    local path = current_path()
    if not path then return end
    vim.cmd("botright split " .. vim.fn.fnameescape(path))
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].modifiable = true
    vim.bo[buf].bufhidden = "wipe"
  end
  local function handoff()
    local path = current_path()
    if not path then return end
    local metadata = queue_metadata(path)
    local function field(primary, ...)
      if metadata[primary] and metadata[primary] ~= "" then return metadata[primary] end
      for _, alias in ipairs({ ... }) do
        if metadata[alias] and metadata[alias] ~= "" then return metadata[alias] end
      end
      return "unknown"
    end
    local id = field("source_id")
    local handoff_text = table.concat({
      "#source",
      "project=" .. field("project"),
      "angle=" .. field("angle"),
      "owner_skill=" .. field("owner_skill", "owner-skill"),
      "suggested_action=" .. field("suggested_action", "suggested-action", "action"),
      "confidence=" .. field("confidence"),
      "risks=" .. field("risks", "risk"),
      "status=" .. field("status"),
      "owner=unknown",
      "output=review",
      "source_id=" .. id,
      "",
      "Utiliser ces metadonnees de revue comme contexte structure; relire la source locale associee si necessaire.",
      "Ne pas copier le texte source. Ne rien publier ni envoyer sans validation explicite.",
    }, "\n")
    clipboard.copy(handoff_text)
    vim.notify("Handoff #source copie dans le presse-papiers", vim.log.levels.INFO)
  end
  bind_body_actions = function(body_buf)
    local body_opts = { buffer = body_buf, silent = true, noremap = true }
    vim.keymap.set("n", "a", function()
      classify_ai()
    end, vim.tbl_extend("force", body_opts, { desc = "Ask AI about email" }))
    vim.keymap.set("n", "r", summarize, vim.tbl_extend("force", body_opts, { desc = "Summarize email in 1-5 sentences" }))
    vim.keymap.set("n", "h", handoff, vim.tbl_extend("force", body_opts, { desc = "Copy governed handoff" }))
    vim.keymap.set("n", "y", function() update("accepted") end, body_opts)
    vim.keymap.set("n", "e", edit_item, vim.tbl_extend("force", body_opts, { desc = "Edit review record" }))
    vim.keymap.set("n", "x", function() update("rejected") end, body_opts)
    vim.keymap.set("n", "d", delete_source, vim.tbl_extend("force", body_opts, { desc = "Move email to Gmail Trash" }))
    vim.keymap.set("n", "o", open_browser_link, vim.tbl_extend("force", body_opts, { desc = "Open email link in browser" }))
    vim.keymap.set("n", "i", function() update("ignored") end, body_opts)
    vim.keymap.set("n", "<Tab>", function()
      local path = current_path()
      local following_key = path and next_key(path) or nil
      if following_key then vim.cmd("MailIntakeMessage " .. following_key) end
    end, vim.tbl_extend("force", body_opts, { desc = "Next email" }))
    vim.keymap.set("n", "<S-Tab>", function()
      local path = current_path()
      local current = path and item_key(path) or nil
      for index, candidate in ipairs(list) do
        if item_key(candidate) == current and list[index - 1] then
          vim.cmd("MailIntakeMessage " .. item_key(list[index - 1]))
          return
        end
      end
    end, vim.tbl_extend("force", body_opts, { desc = "Previous email" }))
  end
  local opts = { buffer = buf, silent = true, noremap = true }
  vim.keymap.set("n", "<CR>", open_item, vim.tbl_extend("force", opts, { desc = "Open email" }))
  vim.keymap.set("n", "<Tab>", function() move_item(1) end, vim.tbl_extend("force", opts, { desc = "Next email and open" }))
  vim.keymap.set("n", "<S-Tab>", function() move_item(-1) end, vim.tbl_extend("force", opts, { desc = "Previous email and open" }))
  vim.keymap.set("n", "a", function()
    classify_ai()
  end, vim.tbl_extend("force", opts, { desc = "Ask AI about email" }))
  vim.keymap.set("n", "r", summarize, vim.tbl_extend("force", opts, { desc = "Summarize email in 1-5 sentences" }))
  vim.keymap.set("n", "h", handoff, vim.tbl_extend("force", opts, { desc = "Copy governed handoff" }))
  vim.keymap.set("n", "y", function() update("accepted") end, opts)
  vim.keymap.set("n", "e", edit_item, vim.tbl_extend("force", opts, { desc = "Edit review record" }))
  vim.keymap.set("n", "E", function() update("edited") end, opts)
  vim.keymap.set("n", "x", function() update("rejected") end, opts)
  vim.keymap.set("n", "d", delete_source, vim.tbl_extend("force", opts, { desc = "Move email to Gmail Trash" }))
  vim.keymap.set("n", "o", open_browser_link, vim.tbl_extend("force", opts, { desc = "Open email link in browser" }))
  vim.keymap.set("n", "i", function() update("ignored") end, opts)

  if #list > 0 then
    local target_line = 7
    if preferred_key then
      for line, path in ipairs(list) do
        if item_key(path) == preferred_key then
          target_line = line + 6
          break
        end
      end
    end
    vim.api.nvim_win_set_cursor(list_win, { target_line, 0 })
    vim.schedule(open_item)
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("shipglowz_mail_review_resize", { clear = true }),
    callback = vim.schedule_wrap(resize_review_layout),
  })
  vim.api.nvim_create_user_command("MailIntake", function(opts)
    render_list(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", desc = "Open Mail Intelligence review", force = true })
  vim.api.nvim_create_user_command("MailIntakeMessage", function(opts)
    local key = opts.args ~= "" and opts.args or (active_path and item_key(active_path) or nil)
    render_list(key, true)
  end, { nargs = "?", desc = "Open current email full-screen", force = true })
  vim.api.nvim_create_user_command("MailIntakeScan", function(opts)
    local args = { "scan" }
    if opts.bang then table.insert(args, "--dry-run") end
    cli(args, function(output) vim.notify(output:gsub("%s+$", ""), vim.log.levels.INFO) end)
  end, { bang = true, desc = "Scan local mail into the private review queue", force = true })
  vim.keymap.set("n", "<leader>mi", "<cmd>MailIntake<cr>", { desc = "Mail Intelligence review" })
  vim.keymap.set("n", "<leader>mm", "<cmd>MailIntakeMessage<cr>", { desc = "Open email full-screen" })
  vim.keymap.set("n", "<leader>ms", "<cmd>MailIntakeScan<cr>", { desc = "Scan mail for review" })
end

return M
