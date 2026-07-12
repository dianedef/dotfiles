local M = {}

local function register_which_key()
  local ok, which_key = pcall(require, "which-key")
  if not ok then return end

  which_key.add({
    { "<leader>m", group = "Mail Intelligence / Markdown", icon = "󰇮" },
    { "<leader>mi", desc = "ouvrir la revue" },
    { "<leader>ms", desc = "scanner la source" },
    { "<leader>mI", desc = "ouvrir la boite" },
    { "<leader>mS", desc = "rechercher" },
    { "<leader>mf", desc = "choisir un dossier" },
    { "<leader>ma", desc = "lister les comptes" },
    { "<leader>mO", desc = "ouvrir par identifiant" },
    { "<leader>my", desc = "copier en Markdown" },
    { "<leader>mb", desc = "copier le handoff sf-content" },
    { "<leader>mA", desc = "envoyer a Avante" },
  })
end

function M.setup(opts)
  require("shipglowz.mail.config").setup(opts)
  require("shipglowz.mail.reader").setup()
  require("shipglowz.mail.review").setup()
  register_which_key()
end

return M
