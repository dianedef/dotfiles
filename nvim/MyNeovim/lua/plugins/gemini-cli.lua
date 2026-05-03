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
      "<leader>agt",
      function()
        require("gemini_cli.api").toggle_terminal()
      end,
      desc = "Gemini Toggle",
    },
    {
      "<leader>aga",
      function()
        require("gemini_cli.api").add_current_file()
      end,
      desc = "Gemini Add File",
    },
    {
      "<leader>agd",
      function()
        require("gemini_cli.api").send_diagnostics_with_prompt()
      end,
      desc = "Gemini Fix Diagnostic",
    },
    {
      "<leader>ag/",
      function()
        require("gemini_cli.api").open_command_picker()
      end,
      desc = "Gemini Slash Commands",
    },
  },
}
