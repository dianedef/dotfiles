return {
  "coder/claudecode.nvim",
  enabled = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "ClaudeCode" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = { "n", "v" }, desc = "ClaudeCode Send" },
  },
}
