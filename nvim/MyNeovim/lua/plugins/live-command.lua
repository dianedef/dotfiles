return {
  "smjonas/live-command.nvim",
  enabled = false,
  config = function()
    require("live-command").setup({
      commands = {
        Norm = { cmd = "norm" },
        G = { cmd = "g" },
        S = { cmd = "s" },
      },
    })
  end,
}
