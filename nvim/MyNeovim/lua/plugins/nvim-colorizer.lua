-- Alternative to nvim-highlight-colors (disabled to avoid conflict)
return {
  "norcalli/nvim-colorizer.lua",
  enabled = false,
  event = "VeryLazy",
  config = function()
    require("colorizer").setup()
  end,
}
