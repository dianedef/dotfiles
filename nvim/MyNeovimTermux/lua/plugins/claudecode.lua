return {
  "coder/claudecode.nvim",
  enabled = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    terminal = {
      split_side = "right",
      split_width_percentage = 0.5,
      snacks_win_opts = {
        position = "bottom",
        height = 0.5,
      },
    },
  },
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code (IDE)" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = { "n", "v" }, desc = "Claude Code Send (IDE)" },
  },
}
