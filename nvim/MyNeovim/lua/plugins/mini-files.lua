return {
  "echasnovski/mini.files",
  enabled = false,
  version = "*",
  opts = {
    mappings = {
      close = "q",
      go_in = "l",
      go_in_plus = "<CR>",
      go_out = "h",
      go_out_plus = "H",
      reset = "<BS>",
      reveal_cwd = "@",
      show_help = "g?",
      synchronize = "=",
      trim_left = "<",
      trim_right = ">",
    },
    windows = {
      preview = true,
      width_preview = 40,
    },
  },
  keys = {
    { "<leader>fm", function() require("mini.files").open() end, desc = "Mini Files" },
    { "<leader>fM", function() require("mini.files").open(vim.api.nvim_buf_get_name(0)) end, desc = "Mini Files (current)" },
  },
}
