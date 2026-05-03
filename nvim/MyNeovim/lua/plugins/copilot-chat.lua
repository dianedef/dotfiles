local function ask_with_context(prompt)
  local chat = require("CopilotChat")
  local select = require("CopilotChat.select")
  local selection = vim.fn.mode():match("[vV\22]") and select.visual or select.buffer

  chat.ask(prompt, { selection = selection })
end

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  event = "VeryLazy",
  build = "make tiktoken",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    "nvim-lua/plenary.nvim",
  },
  opts = {
    model = "claude-sonnet-4",
    auto_insert_mode = true,
    question_header = "You ",
    answer_header = "Copilot ",
    window = {
      layout = "vertical",
      width = 0.42,
    },
  },
  config = function(_, opts)
    require("CopilotChat").setup(opts)
  end,
  keys = {
    {
      "<leader>apt",
      function()
        require("CopilotChat").toggle()
      end,
      mode = { "n", "v" },
      desc = "CopilotChat Toggle",
    },
    {
      "<leader>ape",
      function()
        ask_with_context("Explain this code and its role in the current project.")
      end,
      mode = { "n", "v" },
      desc = "CopilotChat Explain",
    },
    {
      "<leader>apr",
      function()
        ask_with_context("Review this code. Focus on bugs, regressions, and maintainability.")
      end,
      mode = { "n", "v" },
      desc = "CopilotChat Review",
    },
    {
      "<leader>apf",
      function()
        ask_with_context("Help me fix this code. Explain the issue briefly and propose the smallest safe patch.")
      end,
      mode = { "n", "v" },
      desc = "CopilotChat Fix",
    },
  },
}
