return {
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      -- Configuration par défaut
      max_time = 1000,
      max_count = 2,
      disable_mouse = true,
      hint = true,
      notification = true,
      allow_different_key = false,
      enabled = false,
      -- Touches restreintes (éviter l'utilisation excessive)
      restriction_mode = "block",
      restricted_keys = {
        ["h"] = { "n", "x" },
        ["j"] = { "n", "x" },
        ["k"] = { "n", "x" },
        ["l"] = { "n", "x" },
        ["-"] = { "n", "x" },
        ["+"] = { "n", "x" },
        ["gj"] = { "n", "x" },
        ["gk"] = { "n", "x" },
        ["<CR>"] = { "n", "x" },
        ["<C-M>"] = { "n", "x" },
        ["<C-N>"] = { "n", "x" },
        ["<C-P>"] = { "n", "x" },
      },
      -- Désactiver pour certains types de fichiers
      disabled_filetypes = {
        "qf",
        "netrw",
        "NvimTree",
        "lazy",
        "mason",
        "oil",
        "neo-tree",
        "trouble",
        "TelescopePrompt",
      },
      -- Désactiver pour certains types de buffer
      disabled_buftypes = { "terminal", "prompt", "nofile" },
    },
    keys = {
      -- Touche pour activer/désactiver rapidement hardtime
      {
        "<leader>uh",
        "<cmd>Hardtime toggle<cr>",
        desc = "Toggle Hardtime",
      },
    },
  },
}
