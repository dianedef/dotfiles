-- Markdown preview/rendering (alternative to render-markdown.nvim)
-- Disable one or the other to avoid conflicts
return {
  "OXY2DEV/markview.nvim",
  enabled = false, -- disable to avoid conflict with render-markdown.nvim
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
}
