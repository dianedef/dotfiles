local config = require("shipflow.mail.config")

local M = {}

local state = {
  current_markdown = nil,
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Competitor Mail" })
end

local function command_base(extra)
  local opts = config.get()
  local cmd = {
    opts.cli,
    "--maildir-root",
    opts.maildir_root,
  }

  for _, arg in ipairs(extra) do
    table.insert(cmd, arg)
  end

  return cmd
end

local function run(args, callback)
  local cmd = command_base(args)

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local stderr = vim.trim(result.stderr or "")
        local stdout = vim.trim(result.stdout or "")
        notify(stderr ~= "" and stderr or stdout ~= "" and stdout or "mail-intel a échoué", vim.log.levels.ERROR)
        return
      end

      callback(result.stdout or "")
    end)
  end)
end

local function decode_json(text)
  local ok, decoded = pcall(vim.json.decode, text)
  if not ok then
    notify("Réponse JSON invalide de mail-intel", vim.log.levels.ERROR)
    return nil
  end
  return decoded
end

local function account_or_default(account)
  account = account and account ~= "" and account or config.get().default_account
  if not account or account == "" then
    notify("Aucun compte configuré. Définis MAIL_INTEL_ACCOUNT ou passe un compte à la commande.", vim.log.levels.WARN)
    return nil
  end
  return account
end

local function open_markdown(markdown, title)
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(markdown, "\n", { plain = true })

  vim.api.nvim_buf_set_name(buf, title or "Competitor Mail")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = "markdown"

  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
  state.current_markdown = markdown
end

local function select_message(messages)
  if not messages or #messages == 0 then
    notify("Aucun email trouvé")
    return
  end

  vim.ui.select(messages, {
    prompt = "Email concurrent",
    format_item = function(item)
      local date = item.date or "date inconnue"
      local sender = item.authors or item.from or "expéditeur inconnu"
      local subject = item.subject or "sans sujet"
      return ("%s | %s | %s"):format(date, sender, subject)
    end,
  }, function(choice)
    if not choice then
      return
    end
    M.open(choice.id)
  end)
end

function M.accounts()
  run({ "--format", "json", "accounts" }, function(stdout)
    local accounts = decode_json(stdout)
    if accounts then
      vim.ui.select(accounts, { prompt = "Compte mail" }, function(choice)
        if choice then
          notify("Compte: " .. choice)
        end
      end)
    end
  end)
end

function M.inbox(account)
  account = account_or_default(account)
  if not account then
    return
  end

  local opts = config.get()
  run({
    "--format",
    "json",
    "list",
    account,
    opts.default_folder,
    "--limit",
    tostring(opts.limit),
  }, function(stdout)
    select_message(decode_json(stdout))
  end)
end

function M.folder(folder, account)
  account = account_or_default(account)
  if not account then
    return
  end

  folder = folder and folder ~= "" and folder or config.get().default_folder

  run({
    "--format",
    "json",
    "list",
    account,
    folder,
    "--limit",
    tostring(config.get().limit),
  }, function(stdout)
    select_message(decode_json(stdout))
  end)
end

function M.search(query, account)
  account = account_or_default(account)
  if not account then
    return
  end

  query = query and query ~= "" and query or vim.fn.input("Recherche emails: ")
  if query == "" then
    return
  end

  run({
    "--format",
    "json",
    "search",
    account,
    query,
    "--limit",
    tostring(config.get().limit),
  }, function(stdout)
    select_message(decode_json(stdout))
  end)
end

function M.open(message_id)
  if not message_id or message_id == "" then
    message_id = vim.fn.input("Message id: ")
  end
  if message_id == "" then
    return
  end

  run({ "export", message_id, "--markdown" }, function(stdout)
    open_markdown(stdout, "Competitor Mail " .. message_id)
  end)
end

function M.copy_markdown()
  local markdown = state.current_markdown
  if not markdown then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    markdown = table.concat(lines, "\n")
  end

  vim.fn.setreg("+", markdown)
  vim.fn.setreg('"', markdown)
  notify("Email copié en Markdown")
end

local function current_markdown()
  if state.current_markdown then
    return state.current_markdown
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, "\n")
end

local function sf_content_prompt()
  return table.concat({
    "$sf-content",
    "",
    "Analyse cet email comme source d'inspiration éditoriale.",
    "",
    "But:",
    "- trouver le bon business ou site concerné",
    "- trouver le bon endroit dans l'arbre de contenu",
    "- proposer où intégrer l'information: page pilier, article, section, FAQ, offre, preuve, objection",
    "- extraire les idées utiles sans copier mot pour mot",
    "- signaler les informations manquantes à ajouter sur mes sites",
    "",
    "Réponse attendue:",
    "1. Site ou business recommandé",
    "2. Page/article/section cible",
    "3. Idées à reprendre",
    "4. Formulations à adapter",
    "5. Informations manquantes",
    "6. Actions concrètes",
    "",
    "Email:",
    "",
    current_markdown(),
  }, "\n")
end

function M.copy_sf_content()
  local prompt = sf_content_prompt()
  vim.fn.setreg("+", prompt)
  vim.fn.setreg('"', prompt)
  notify("Prompt $sf-content copié")
end

function M.send_sf_content_to_avante()
  local prompt = sf_content_prompt()
  vim.fn.setreg("+", prompt)
  vim.fn.setreg('"', prompt)

  local ok, avante_api = pcall(require, "avante.api")
  if not ok or type(avante_api.ask) ~= "function" then
    notify("Avante indisponible. Prompt $sf-content copié.", vim.log.levels.WARN)
    return
  end

  avante_api.ask({
    question = prompt,
    new_chat = true,
    without_selection = true,
  })
  notify("Email envoyé à Avante avec $sf-content")
end

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("CompetitorMailAccounts", function()
    M.accounts()
  end, { desc = "List competitor mail accounts" })

  vim.api.nvim_create_user_command("CompetitorMailInbox", function(command)
    M.inbox(command.args)
  end, { desc = "Open competitor mail inbox", nargs = "?" })

  vim.api.nvim_create_user_command("CompetitorMailFolder", function(command)
    M.folder(command.args)
  end, { desc = "Open competitor mail folder", nargs = "?" })

  vim.api.nvim_create_user_command("CompetitorMailSearch", function(command)
    M.search(command.args)
  end, { desc = "Search competitor mail", nargs = "*" })

  vim.api.nvim_create_user_command("CompetitorMailOpen", function(command)
    M.open(command.args)
  end, { desc = "Open competitor mail by message id", nargs = "?" })

  vim.api.nvim_create_user_command("CompetitorMailCopyMarkdown", function()
    M.copy_markdown()
  end, { desc = "Copy current competitor mail as Markdown" })

  vim.api.nvim_create_user_command("CompetitorMailCopySfContent", function()
    M.copy_sf_content()
  end, { desc = "Copy current mail as sf-content prompt" })

  vim.api.nvim_create_user_command("CompetitorMailAvanteSfContent", function()
    M.send_sf_content_to_avante()
  end, { desc = "Send current mail to Avante with sf-content" })

  vim.keymap.set("n", "<leader>mi", function()
    M.inbox()
  end, { desc = "Mail Intel Inbox" })

  vim.keymap.set("n", "<leader>mf", function()
    M.folder()
  end, { desc = "Mail Intel Folder" })

  vim.keymap.set("n", "<leader>ms", function()
    M.search()
  end, { desc = "Mail Intel Search" })

  vim.keymap.set("n", "<leader>ma", function()
    M.accounts()
  end, { desc = "Mail Intel Accounts" })

  vim.keymap.set("n", "<leader>mO", function()
    M.open()
  end, { desc = "Mail Intel Open by ID" })

  vim.keymap.set("n", "<leader>my", function()
    M.copy_markdown()
  end, { desc = "Mail Intel Copy Markdown" })

  vim.keymap.set("n", "<leader>mb", function()
    M.copy_sf_content()
  end, { desc = "Mail Intel Copy sf-content" })

  vim.keymap.set("n", "<leader>mA", function()
    M.send_sf_content_to_avante()
  end, { desc = "Mail Intel Avante sf-content" })
end

return M
