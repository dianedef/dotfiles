return {
  "coder/claudecode.nvim",
  enabled = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    terminal = {
      split_side = "bottom",
      split_width_percentage = 0.35,
      snacks_win_opts = {
        position = "bottom",
        height = 0.35,
      },
    },
  },
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "ClaudeCode" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = { "n", "v" }, desc = "ClaudeCode Send" },
  },
}
