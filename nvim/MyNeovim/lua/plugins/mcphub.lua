return {
  "ravitemer/mcphub.nvim",
  enabled = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  build = "pnpm add -g mcp-hub@latest",
  config = function()
    require("mcphub").setup()
  end,
}
