return {
  "bassamsdata/namu.nvim",
  enabled = false,
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    namu_symbols = { enable = true },
    ui_select = { enable = true },
  },
  keys = {
    { "<leader>ss", "<cmd>Namu symbols<cr>", desc = "Namu symbols" },
  },
}
