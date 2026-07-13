local M = {}
local config = require("shipglowz.mail.config")
local clipboard = require("shipglowz.clipboard")

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
  local line = vim.api.nvim_get_current_line()
  local key = line:match("^%[([^%]]+)%]")
  return key and (root() .. "/inbox/" .. key .. ".md") or nil
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

local function render_list(preferred_key)
  local list = files("inbox")
  local lines = { "MAIL INTELLIGENCE", "", "Pending proposals: " .. #list, "", "j/k move   r resume 1-5 phrases   a ask AI   h handoff   y accept   e edit   x reject   d trash Gmail   i ignore", "" }
  for _, path in ipairs(list) do
    local key = item_key(path)
    local title = "(sans sujet)"
    local first = vim.fn.readfile(path, "", 8)
    for _, line in ipairs(first) do
      if line:match("^# ") then title = line:sub(3); break end
    end
    table.insert(lines, string.format("[%s] %s", key, title))
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "Mail Intelligence")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "mail-intake"
  vim.bo[buf].modifiable = false
  vim.cmd("only")
  vim.api.nvim_win_set_buf(0, buf)
  local list_win = vim.api.nvim_get_current_win()
  vim.cmd("resize 12")
  local source_win
  local source_buf

  local function show_source(path, markdown)
    if not source_win or not vim.api.nvim_win_is_valid(source_win) then
      vim.api.nvim_set_current_win(list_win)
      vim.cmd("botright split")
      source_win = vim.api.nvim_get_current_win()
      source_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(source_buf, source_buffer_name(path, source_buf))
      vim.bo[source_buf].bufhidden = "wipe"
      vim.bo[source_buf].filetype = "markdown"
    end
    vim.api.nvim_buf_set_name(source_buf, source_buffer_name(path, source_buf))
    vim.bo[source_buf].modifiable = true
    vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, vim.split(markdown, "\n", { plain = true }))
    vim.bo[source_buf].modifiable = false
    vim.api.nvim_win_set_buf(source_win, source_buf)
    vim.api.nvim_set_current_win(list_win)
  end

  local function current_path()
    return queue_item_path()
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
  local function ask_ai(question)
    local path = current_path()
    if not path then return end
    open_source(path, function(markdown)
      show_source(path, markdown)
      local ok, api = pcall(require, "avante.api")
      if not ok or type(api.ask) ~= "function" then
        vim.notify("Avante est indisponible", vim.log.levels.WARN)
        return
      end
      api.ask({ question = question })
    end)
  end
  local function summarize()
    ask_ai("Resume cet email en 1 a 5 phrases maximum. Donne uniquement le resume factuel, sans proposer de projet, d'angle ou d'action. N'invente rien et ne copie pas le texte source.")
  end
  local function update(status)
    local path = current_path()
    if not path then return end
    local following_key = next_key(path)
    cli({ "--private-root", root(), "update", item_key(path), status }, function()
      vim.cmd("MailIntake" .. (following_key and (" " .. following_key) or ""))
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
          vim.cmd("MailIntake" .. (following_key and (" " .. following_key) or ""))
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
  local opts = { buffer = buf, silent = true, noremap = true }
  vim.keymap.set("n", "<CR>", open_item, vim.tbl_extend("force", opts, { desc = "Open email" }))
  vim.keymap.set("n", "a", function()
    ask_ai("Analyse cet email comme une source #source. Propose le projet, l'angle, le owner skill, les risques et l'action suivante. Ne copie pas le texte. Je decide ensuite.")
  end, vim.tbl_extend("force", opts, { desc = "Ask AI about email" }))
  vim.keymap.set("n", "r", summarize, vim.tbl_extend("force", opts, { desc = "Summarize email in 1-5 sentences" }))
  vim.keymap.set("n", "h", handoff, vim.tbl_extend("force", opts, { desc = "Copy governed handoff" }))
  vim.keymap.set("n", "y", function() update("accepted") end, opts)
  vim.keymap.set("n", "e", edit_item, vim.tbl_extend("force", opts, { desc = "Edit review record" }))
  vim.keymap.set("n", "E", function() update("edited") end, opts)
  vim.keymap.set("n", "x", function() update("rejected") end, opts)
  vim.keymap.set("n", "d", delete_source, vim.tbl_extend("force", opts, { desc = "Move email to Gmail Trash" }))
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
  vim.api.nvim_create_user_command("MailIntake", function(opts)
    render_list(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", desc = "Open Mail Intelligence review", force = true })
  vim.api.nvim_create_user_command("MailIntakeScan", function(opts)
    local args = { "scan" }
    if opts.bang then table.insert(args, "--dry-run") end
    cli(args, function(output) vim.notify(output:gsub("%s+$", ""), vim.log.levels.INFO) end)
  end, { bang = true, desc = "Scan local mail into the private review queue", force = true })
  vim.keymap.set("n", "<leader>mm", "<cmd>MailIntake<cr>", { desc = "Mail Intelligence review" })
  vim.keymap.set("n", "<leader>ms", "<cmd>MailIntakeScan<cr>", { desc = "Scan mail for review" })
end

return M
