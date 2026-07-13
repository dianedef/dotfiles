return {
  "Zeioth/markmap.nvim",
  enabled = false,
  build = "yarn global add markmap-cli",
  cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
  ft = "markdown",
  opts = {},
  keys = {
    { "<leader>mK", "<cmd>MarkmapOpen<cr>", desc = "Markmap Open" },
    { "<leader>mw", "<cmd>MarkmapWatch<cr>", desc = "Markmap Watch" },
  },
}
