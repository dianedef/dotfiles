return {
  "obsidian-nvim/obsidian.nvim",
  enabled = false,
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      { name = "notes", path = "~/notes" },
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
  },
}
