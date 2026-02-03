return {
  "stevearc/aerial.nvim",
  enabled = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
  opts = {
    backends = { "treesitter", "lsp", "markdown", "man" },
    layout = {
      max_width = { 40, 0.2 },
      min_width = 20,
    },
    filter_kind = false,
  },
  keys = {
    { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
    { "<leader>cS", "<cmd>AerialNavToggle<cr>", desc = "Aerial Nav" },
  },
}
