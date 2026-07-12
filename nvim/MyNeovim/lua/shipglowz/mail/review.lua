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
  return vim.fn.globpath(root() .. "/" .. folder, "*.md", false, true)
end

local function item_key(path)
  return vim.fn.fnamemodify(path, ":t:r")
end

local function source_buffer_name(path, buf)
  local base = "Mail source " .. item_key(path)
  if vim.fn.bufnr(base) == -1 then return base end
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

local function render_list()
  local list = files("inbox")
  local lines = { "MAIL INTELLIGENCE", "", "Pending proposals: " .. #list, "", "j/k move   <CR> open   a ask AI   h handoff   y accept   e edit   x reject   i ignore", "" }
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
  vim.cmd("botright new")
  vim.api.nvim_win_set_buf(0, buf)
  local function current_path()
    return queue_item_path()
  end
  local function open_item()
    local path = current_path()
    if not path then return end
    open_source(path, function(markdown)
      vim.cmd("botright split")
      local source_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(source_buf, source_buffer_name(path, source_buf))
      vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, vim.split(markdown, "\n", { plain = true }))
      vim.bo[source_buf].filetype = "markdown"
      vim.bo[source_buf].modifiable = false
      vim.api.nvim_win_set_buf(0, source_buf)
    end)
  end
  local function ask_ai()
    local path = current_path()
    if not path then return end
    open_source(path, function(markdown)
      vim.cmd("botright split")
      local source_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(source_buf, source_buffer_name(path, source_buf))
      vim.api.nvim_buf_set_lines(source_buf, 0, -1, false, vim.split(markdown, "\n", { plain = true }))
      vim.bo[source_buf].filetype = "markdown"
      vim.bo[source_buf].modifiable = false
      vim.api.nvim_win_set_buf(0, source_buf)
      local ok, api = pcall(require, "avante.api")
      if not ok or type(api.ask) ~= "function" then
        vim.notify("Avante est indisponible", vim.log.levels.WARN)
        return
      end
      api.ask({ question = "Analyse cet email comme une source #source. Propose le projet, l'angle, le owner skill, les risques et l'action suivante. Ne copie pas le texte. Je decide ensuite." })
    end)
  end
  local function update(status)
    local path = current_path()
    if not path then return end
    cli({ "--private-root", root(), "update", item_key(path), status }, function()
      vim.cmd("MailIntake")
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
  vim.keymap.set("n", "a", ask_ai, vim.tbl_extend("force", opts, { desc = "Ask AI about email" }))
  vim.keymap.set("n", "h", handoff, vim.tbl_extend("force", opts, { desc = "Copy governed handoff" }))
  vim.keymap.set("n", "y", function() update("accepted") end, opts)
  vim.keymap.set("n", "e", edit_item, vim.tbl_extend("force", opts, { desc = "Edit review record" }))
  vim.keymap.set("n", "E", function() update("edited") end, opts)
  vim.keymap.set("n", "x", function() update("rejected") end, opts)
  vim.keymap.set("n", "i", function() update("ignored") end, opts)
end

function M.setup()
  vim.api.nvim_create_user_command("MailIntake", render_list, { desc = "Open Mail Intelligence review", force = true })
  vim.api.nvim_create_user_command("MailIntakeScan", function(opts)
    local args = { "scan" }
    if opts.bang then table.insert(args, "--dry-run") end
    cli(args, function(output) vim.notify(output:gsub("%s+$", ""), vim.log.levels.INFO) end)
  end, { bang = true, desc = "Scan local mail into the private review queue", force = true })
  vim.keymap.set("n", "<leader>mi", "<cmd>MailIntake<cr>", { desc = "Mail Intelligence review" })
  vim.keymap.set("n", "<leader>ms", "<cmd>MailIntakeScan<cr>", { desc = "Scan mail for review" })
end

return M
