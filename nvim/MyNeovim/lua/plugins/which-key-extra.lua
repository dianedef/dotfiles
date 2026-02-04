return {
  "folke/which-key.nvim",
  enabled = true,
  optional = true,
  opts = {
    icons = {
      rules = false, -- Disable icon auto-detection rules (fixes extra letters in descriptions)
    },
    spec = {
      { "<leader>o", group = "opencode", icon = "🔥" },
      -- Notification keymaps with explicit icons (no category letters)
      { "<leader>nn", icon = "󰵅" },
      { "<leader>nc", icon = "󱥰" },
      { "<leader>nC", icon = "󱥰" },
    },
  },
}
