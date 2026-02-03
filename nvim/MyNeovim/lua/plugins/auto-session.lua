return {
  "rmagatti/auto-session",
  enabled = false,
  lazy = false,
  opts = {
    auto_restore = false,
    auto_save = true,
    suppressed_dirs = { "~/", "~/Downloads", "/" },
  },
  keys = {
    { "<leader>qs", "<cmd>SessionSave<cr>", desc = "Save session" },
    { "<leader>qr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
    { "<leader>qd", "<cmd>SessionDelete<cr>", desc = "Delete session" },
    { "<leader>qf", "<cmd>SessionSearch<cr>", desc = "Search sessions" },
  },
}
