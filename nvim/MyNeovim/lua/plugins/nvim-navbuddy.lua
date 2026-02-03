return {
  "SmiteshP/nvim-navbuddy",
  enabled = false,
  dependencies = {
    "SmiteshP/nvim-navic",
    "MunifTanjim/nui.nvim",
  },
  opts = { lsp = { auto_attach = true } },
  keys = {
    { "<leader>cn", function() require("nvim-navbuddy").open() end, desc = "Navbuddy" },
  },
}
