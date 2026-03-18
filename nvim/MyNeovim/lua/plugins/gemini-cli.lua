return {
  "marcinjahn/gemini-cli.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
  },
  opts = {},
  config = function(_, opts)
    require("gemini_cli").setup(opts)
  end,
  keys = {
    {
      "<leader>ag",
      function()
        require("gemini_cli").toggle()
      end,
      desc = "Gemini Toggle",
    },
    {
      "<leader>aa",
      function()
        require("gemini_cli").add_current_file()
      end,
      desc = "Gemini Add File",
    },
    {
      "<leader>ad",
      function()
        require("gemini_cli").fix_diagnostic()
      end,
      desc = "Gemini Fix Diagnostic",
    },
    {
      "<leader>a/",
      function()
        require("gemini_cli").slash_command_picker()
      end,
      desc = "Gemini Slash Commands",
    },
  },
}
