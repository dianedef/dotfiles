return {
  "mrjones2014/legendary.nvim",
  enabled = false,
  priority = 10000,
  lazy = false,
  dependencies = { "kkharji/sqlite.lua" },
  opts = {
    extensions = {
      lazy_nvim = true,
      which_key = { auto_register = true },
    },
  },
  keys = {
    { "<leader>P", "<cmd>Legendary<cr>", desc = "Command palette (Legendary)" },
  },
}
