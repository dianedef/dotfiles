-- AI Coding Agents pour Termux
return {
  -- Terminal pour agents IA
  {
    "akinsho/toggleterm.nvim",
    optional = true,
    keys = {
      {
        "<leader>ai",
        function()
          local term = require("toggleterm.terminal").Terminal:new({
            cmd = "aider",
            direction = "float",
            close_on_exit = false,
            float_opts = {
              border = "curved",
              width = math.floor(vim.o.columns * 0.9),
              height = math.floor(vim.o.lines * 0.9),
            },
          })
          term:toggle()
        end,
        desc = "Open Aider",
      },
      {
        "<leader>ax",
        function()
          local term = require("toggleterm.terminal").Terminal:new({
            cmd = "cd ~/codex-termux && python codex.py",
            direction = "float",
            close_on_exit = false,
            float_opts = {
              border = "curved",
              width = math.floor(vim.o.columns * 0.9),
              height = math.floor(vim.o.lines * 0.9),
            },
          })
          term:toggle()
        end,
        desc = "Open Codex-Termux",
      },
      {
        "<leader>as",
        function()
          local term = require("toggleterm.terminal").Terminal:new({
            cmd = "sheikh",
            direction = "float",
            close_on_exit = false,
            float_opts = {
              border = "curved",
              width = math.floor(vim.o.columns * 0.9),
              height = math.floor(vim.o.lines * 0.9),
            },
          })
          term:toggle()
        end,
        desc = "Open Sheikh CLI",
      },
      {
        "<leader>ao",
        function()
          local term = require("toggleterm.terminal").Terminal:new({
            cmd = "proot-distro login alpine -- /root/opencode_termux_alpine_aarch64/opencode-termux-wrapper.sh",
            direction = "float",
            close_on_exit = false,
            float_opts = {
              border = "curved",
              width = math.floor(vim.o.columns * 0.9),
              height = math.floor(vim.o.lines * 0.9),
            },
          })
          term:toggle()
        end,
        desc = "Open OpenCode (Alpine)",
      },
    },
  },

  -- Which-key labels
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai-agents", icon = "🤖" },
        { "<leader>o", group = "opencode", icon = "🔥" },
      },
    },
  },

  -- Copilot désactivé sur Termux (trop lourd)
  {
    "zbirenbaum/copilot.lua",
    enabled = function()
      return vim.env.TERMUX_VERSION == nil
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    enabled = function()
      return vim.env.TERMUX_VERSION == nil
    end,
  },
}
