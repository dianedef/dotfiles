return {
  "rgroli/other.nvim",
  enabled = false,
  cmd = { "Other", "OtherTabNew", "OtherSplit", "OtherVSplit" },
  opts = {
    mappings = {
      -- Built-in mappings for common patterns
      "livewire",
      "angular",
      "laravel",
      "rails",
      "golang",
    },
  },
  keys = {
    { "<leader>oo", "<cmd>Other<cr>", desc = "Other file" },
    { "<leader>ov", "<cmd>OtherVSplit<cr>", desc = "Other file (vsplit)" },
    { "<leader>os", "<cmd>OtherSplit<cr>", desc = "Other file (split)" },
  },
}
