return {
  "Robitx/gp.nvim",
  enabled = false,
  opts = {
    openai_api_key = { "cat", vim.fn.expand("~/.openai_api_key") },
  },
  keys = {
    { "<leader>gpc", "<cmd>GpChatNew<cr>", desc = "GP Chat New" },
    { "<leader>gpt", "<cmd>GpChatToggle<cr>", desc = "GP Chat Toggle" },
    { "<leader>gpr", "<cmd>GpRewrite<cr>", mode = { "n", "v" }, desc = "GP Rewrite" },
    { "<leader>gpa", "<cmd>GpAppend<cr>", mode = { "n", "v" }, desc = "GP Append" },
  },
}
