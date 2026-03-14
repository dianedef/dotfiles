-- AI Coding Agents (Claude Code)
return {
  -- Which-key labels
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai-agents" },
      },
    },
  },

  -- Claude Code plain terminal (uses snacks.terminal from LazyVim)
  -- Note: <leader>ac is handled by claudecode.nvim (IDE integration)
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ah",
        function()
          Snacks.terminal.open("claude", {
            win = {
              position = "bottom",
              height = 0.5,
            },
          })
        end,
        desc = "Claude CLI ─",
      },
      {
        "<leader>av",
        function()
          Snacks.terminal.open("claude", {
            win = {
              position = "right",
              width = 0.5,
            },
          })
        end,
        desc = "Claude CLI │",
      },
      {
        "<leader>aH",
        function()
          local dir = vim.fn.expand("%:p:h")
          Snacks.terminal.open("claude " .. vim.fn.shellescape(dir), {
            win = {
              position = "bottom",
              height = 0.5,
            },
          })
        end,
        desc = "Claude CLI here ─",
      },
      {
        "<leader>aV",
        function()
          local dir = vim.fn.expand("%:p:h")
          Snacks.terminal.open("claude " .. vim.fn.shellescape(dir), {
            win = {
              position = "right",
              width = 0.5,
            },
          })
        end,
        desc = "Claude CLI here │",
      },
    },
  },
}
