local config = require("shipglowz.mail.config")
local clipboard = require("shipglowz.clipboard")

local M = {}

local state = {
  current_markdown = nil,
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Competitor Mail" })
end

local function command_base(extra)
  local opts = config.get()
  local command = {
    opts.cli,
    "--maildir-root",
    opts.maildir_root,
  }

  vim.list_extend(command, extra)
  return command
end

local function run(args, callback)
  vim.system(command_base(args), config.system_opts(), function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local stderr = vim.trim(result.stderr or "")
        local stdout = vim.trim(result.stdout or "")
        notify(stderr ~= "" and stderr or stdout ~= "" and stdout or "mail-intel a echoue", vim.log.levels.ERROR)
        return
      end

      callback(result.stdout or "")
    end)
  end)
end

local function decode_json(value)
  local ok, decoded = pcall(vim.json.decode, value)
  if not ok then
    notify("Reponse JSON invalide de mail-intel", vim.log.levels.ERROR)
    return nil
  end
  return decoded
end

local function account_or_default(account)
  account = account and account ~= "" and account or config.get().default_account
  if not account or account == "" then
    notify("Aucun compte configure. Definis MAIL_INTEL_ACCOUNT ou passe un compte a la commande.", vim.log.levels.WARN)
    return nil
  end
  return account
end

local function open_markdown(markdown, title)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, title or "Competitor Mail")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(markdown, "\n", { plain = true }))
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = "markdown"
  vim.b[buf].competitor_mail_markdown = markdown

  vim.cmd("vsplit")
  vim.api.nvim_win_set_buf(0, buf)
  state.current_markdown = markdown
end

local function select_message(messages)
  if not messages or #messages == 0 then
    notify("Aucun email trouve")
    return
  end

  vim.ui.select(messages, {
    prompt = "Email concurrent",
    format_item = function(item)
      local date = item.date or "date inconnue"
      local sender = item.authors or item.from or "expediteur inconnu"
      local subject = item.subject or "sans sujet"
      return ("%s | %s | %s"):format(date, sender, subject)
    end,
  }, function(choice)
    if choice then
      M.open(choice.id)
    end
  end)
end

local function current_markdown()
  local buffer_markdown = vim.b.competitor_mail_markdown
  if buffer_markdown then
    return buffer_markdown
  end
  if state.current_markdown then
    return state.current_markdown
  end
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

local function sf_content_prompt()
  return table.concat({
    "$sf-content",
    "",
    "Analyse cet email comme source d'inspiration editoriale.",
    "",
    "But:",
    "- trouver le bon business ou site concerne",
    "- trouver le bon endroit dans l'arbre de contenu",
    "- proposer ou integrer l'information: page pilier, article, section, FAQ, offre, preuve, objection",
    "- extraire les idees utiles sans copier mot pour mot",
    "- signaler les informations manquantes a ajouter sur mes sites",
    "",
    "Reponse attendue:",
    "1. Site ou business recommande",
    "2. Page/article/section cible",
    "3. Idees a reprendre",
    "4. Formulations a adapter",
    "5. Informations manquantes",
    "6. Actions concretes",
    "",
    "Email:",
    "",
    current_markdown(),
  }, "\n")
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
  message_id = message_id and message_id ~= "" and message_id or vim.fn.input("Message id: ")
  if message_id == "" then
    return
  end

  run({ "export", message_id, "--markdown" }, function(stdout)
    open_markdown(stdout, "Competitor Mail " .. message_id)
  end)
end

function M.copy_markdown()
  local markdown = current_markdown()
  clipboard.copy(markdown)
  notify("Email copie en Markdown")
end

function M.copy_sf_content()
  local prompt = sf_content_prompt()
  clipboard.copy(prompt)
  notify("Prompt $sf-content copie")
end

function M.send_sf_content_to_avante()
  local prompt = sf_content_prompt()
  clipboard.copy(prompt)

  local ok, avante_api = pcall(require, "avante.api")
  if not ok or type(avante_api.ask) ~= "function" then
    notify("Avante indisponible. Prompt $sf-content copie.", vim.log.levels.WARN)
    return
  end

  avante_api.ask({
    question = prompt,
    new_chat = true,
    without_selection = true,
  })
  notify("Email envoye a Avante avec $sf-content")
end

local function command(name, callback, opts)
  vim.api.nvim_create_user_command(name, callback, vim.tbl_extend("force", { force = true }, opts or {}))
end

function M.setup()
  command("CompetitorMailAccounts", M.accounts, { desc = "List competitor mail accounts" })
  command("CompetitorMailInbox", function(args)
    M.inbox(args.args)
  end, { desc = "Open competitor mail inbox", nargs = "?" })
  command("CompetitorMailFolder", function(args)
    M.folder(args.args)
  end, { desc = "Open competitor mail folder", nargs = "?" })
  command("CompetitorMailSearch", function(args)
    M.search(args.args)
  end, { desc = "Search competitor mail", nargs = "*" })
  command("CompetitorMailOpen", function(args)
    M.open(args.args)
  end, { desc = "Open competitor mail by message id", nargs = "?" })
  command("CompetitorMailCopyMarkdown", M.copy_markdown, { desc = "Copy current competitor mail as Markdown" })
  command("CompetitorMailCopySfContent", M.copy_sf_content, { desc = "Copy current mail as sf-content prompt" })
  command("CompetitorMailSfContent", M.send_sf_content_to_avante, { desc = "Send current mail to Avante with sf-content" })
  command("CompetitorMailAvanteSfContent", M.send_sf_content_to_avante, { desc = "Compatibility alias for CompetitorMailSfContent" })

  vim.keymap.set("n", "<leader>mI", M.inbox, { desc = "Mail Intel reader inbox" })
  vim.keymap.set("n", "<leader>mS", M.search, { desc = "Mail Intel reader search" })
  vim.keymap.set("n", "<leader>mf", M.folder, { desc = "Mail Intel reader folder" })
  vim.keymap.set("n", "<leader>ma", M.accounts, { desc = "Mail Intel reader accounts" })
  vim.keymap.set("n", "<leader>mO", M.open, { desc = "Mail Intel reader open by ID" })
  vim.keymap.set("n", "<leader>my", M.copy_markdown, { desc = "Mail Intel reader copy Markdown" })
  vim.keymap.set("n", "<leader>mb", M.copy_sf_content, { desc = "Mail Intel reader copy sf-content" })
  vim.keymap.set("n", "<leader>mA", M.send_sf_content_to_avante, { desc = "Mail Intel reader Avante sf-content" })
end

return M
