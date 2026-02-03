-- Alternative tabline plugins (disabled - bufferline.lua is active)
return {
  { "nanozuki/tabby.nvim", enabled = false, lazy = true },
  { "willothy/nvim-cokeline", enabled = false, lazy = true, dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "romgrk/barbar.nvim", enabled = false, lazy = true, dependencies = { "nvim-tree/nvim-web-devicons" } },
}
