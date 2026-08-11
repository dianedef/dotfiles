return {
  "coffebar/neovim-project",
  enabled = false,
  lazy = false,
  priority = 100,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "Shatur/neovim-session-manager",
  },
  init = function()
    vim.opt.sessionoptions:append("globals")
  end,
  opts = {
    -- Adjust these globs before enabling if your projects live elsewhere.
    projects = {
      "~/projects/*",
      "~/work/*",
      "~/ShipGlows/*",
      "~/.config/*",
    },
    picker = {
      type = "telescope",
    },
  },
}
