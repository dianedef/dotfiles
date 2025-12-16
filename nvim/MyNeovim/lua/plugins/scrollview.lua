return {
  {
    "dstein64/nvim-scrollview",
    event = "VeryLazy",
    opts = {
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "noice",
        "prompt",
        "TelescopePrompt",
        "lazy",
        "mason",
        "neo-tree",
        "NvimTree",
        "trouble",
      },
      current_only = true,
      base = "right",
      column = 1,
      signs_on_startup = { "all" },
      diagnostics_severities = { vim.diagnostic.severity.ERROR },
      -- Personnalisation des caractères
      scrollview_character = "┃",
      scrollview_line_limit = 1000,
      -- Intégration avec d'autres plugins
      diagnostics_error_symbol = "┃",
      diagnostics_warn_symbol = "┃",
      diagnostics_hint_symbol = "┃",
      diagnostics_info_symbol = "┃",
      search_symbol = "•",
      -- Configuration de Gitsigns (si disponible)
      gitsigns_enabled = true,
      -- Couleurs et style
      winblend = 0,
      winblend_gui = 0,
    },
    config = function(_, opts)
      require("scrollview").setup(opts)
    end,
  },
}
