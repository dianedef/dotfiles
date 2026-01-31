return {
  "AckslD/nvim-neoclip.lua",
  event = "VeryLazy",
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {
    history = 1000,
    enable_persistent_history = false,
    default_register = '"',
    enable_macro_history = false,
    on_paste = {
      set_reg = false,
    },
    keys = {
      --- It's possible to map to more than one key
      telescope = {
        i = {
          select = nil,
          paste = "<CR>",
          delete = nil, -- delete an entry
        },
        n = {
          select = nil,
          paste = "<CR>",
          paste_behind = "P",
          delete = "d",
        },
      },
    },
  },
}
