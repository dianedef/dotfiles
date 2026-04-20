return {
  "tttol/md-outline.nvim",
  enabled = true,
  ft = "markdown",
  opts = {
    auto_open = false,
  },
  keys = {
    { "<leader>mo", "<cmd>MdoOpen<cr>", ft = "markdown", desc = "Markdown Outline Open" },
    { "<leader>mc", "<cmd>MdoClose<cr>", ft = "markdown", desc = "Markdown Outline Close" },
  },
}
