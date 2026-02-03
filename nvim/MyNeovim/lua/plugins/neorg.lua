return {
  "nvim-neorg/neorg",
  enabled = false,
  lazy = false,
  version = "*",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/notes",
              work = "~/work/notes",
            },
            default_workspace = "notes",
          },
        },
      },
    })
  end,
}
