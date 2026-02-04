return {
  "folke/snacks.nvim",
  enabled = true,
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = false }, -- using nvim-notify
    quickfile = { enabled = true },
    scroll = { enabled = false }, -- using neoscroll
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
}
