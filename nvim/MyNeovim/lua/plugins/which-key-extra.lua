return {
  "folke/which-key.nvim",
  enabled = true,
  optional = true,
  opts = {
    icons = {
      rules = false, -- Disable icon auto-detection rules (fixes extra letters in descriptions)
    },
    spec = {
      { "<leader>a", group = "AI", icon = "🤖" },
      { "<leader>ak", group = "Codex" },
      { "<leader>ax", group = "Avante" },
    },
  },
}
