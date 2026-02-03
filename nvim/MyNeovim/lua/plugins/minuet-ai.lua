return {
  "milanglacier/minuet-ai.nvim",
  enabled = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    provider = "openai",
    throttle = 1000,
    debounce = 400,
  },
}
