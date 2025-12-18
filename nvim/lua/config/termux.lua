-- Termux: Désactiver plugins lourds
return {
  -- Désactiver Copilot sur Termux
  { "zbirenbaum/copilot.lua", enabled = false },
  { "zbirenbaum/copilot-cmp", enabled = false },
  
  -- LSP léger uniquement
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Garder seulement les LSP légers
        lua_ls = {},
        bashls = {},
        -- Désactiver les autres
      },
    },
  },
}
