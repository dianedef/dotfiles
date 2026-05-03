return {
  "coder/claudecode.nvim",
  enabled = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    terminal_cmd = "claude --permission-mode bypassPermissions",
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
    { "<leader>acc", "<cmd>ClaudeCode<cr>", desc = "Claude Code (IDE)" },
    { "<leader>acs", "<cmd>ClaudeCodeSend<cr>", mode = { "n", "v" }, desc = "Claude Code Send" },
  },
}
