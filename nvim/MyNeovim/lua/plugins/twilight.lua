return {
  "folke/twilight.nvim",
  enabled = false,
  cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
  opts = {
    dimming = { alpha = 0.25 },
    context = 10,
    treesitter = true,
  },
  keys = {
    { "<leader>tw", "<cmd>Twilight<cr>", desc = "Toggle Twilight" },
  },
}
