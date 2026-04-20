return {
  "rmagatti/auto-session",
  enabled = true,
  lazy = false,
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    auto_restore = false,
    auto_restore_last_session = false,
    auto_save = true,
    suppressed_dirs = { "~/", "~/Downloads", "/" },
    close_filetypes_on_save = { "checkhealth", "lazy", "mason" },
    legacy_cmds = false,
    session_lens = {
      picker = "telescope",
      load_on_setup = true,
      previewer = "summary",
    },
  },
  keys = {
    { "<leader>qs", "<cmd>AutoSession search<cr>", desc = "Search Sessions" },
    { "<leader>qS", "<cmd>AutoSession save<cr>", desc = "Save Session" },
    { "<leader>qr", "<cmd>AutoSession restore<cr>", desc = "Restore Session" },
    { "<leader>qd", "<cmd>AutoSession delete<cr>", desc = "Delete Session" },
    { "<leader>qa", "<cmd>AutoSession toggle<cr>", desc = "Toggle Session Autosave" },
  },
}
