return {
  "jaibhavaya/todo-nvim",
  enabled = false,
  cmd = { "TodoOpen", "TodoAdd", "TodoToggle" },
  opts = {},
  keys = {
    { "<leader>To", "<cmd>TodoOpen<cr>", desc = "Todo Open" },
    { "<leader>Ta", "<cmd>TodoAdd<cr>", desc = "Todo Add" },
    { "<leader>Tt", "<cmd>TodoToggle<cr>", desc = "Todo Toggle" },
  },
}
