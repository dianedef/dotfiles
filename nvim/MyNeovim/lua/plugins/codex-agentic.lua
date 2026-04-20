return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>aC", group = "Codex" },
      },
    },
  },

  {
    "carlos-algms/agentic.nvim",
    enabled = true,
    opts = {
      provider = "codex-acp",
      acp_providers = {
        ["codex-acp"] = {
          name = "Codex ACP",
          command = "/home/claude/.npm-global/bin/codex-acp",
          env = {},
        },
      },
      windows = {
        position = "bottom",
        width = "100%",
        height = "42%",
        stack_width_ratio = 0.5,
        input = { height = 8 },
        code = { max_height = 18 },
        files = { max_height = 12 },
        diagnostics = { max_height = 10 },
        todos = { display = true, max_height = 10 },
      },
      diff_preview = {
        enabled = true,
        layout = "split",
        center_on_navigate_hunks = true,
      },
      settings = {
        move_cursor_to_chat_on_submit = true,
      },
    },
    keys = {
      {
        "<leader>aC",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Codex Toggle",
      },
      {
        "<leader>aF",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Codex Add File/Selection",
      },
      {
        "<leader>aN",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "Codex New Session",
      },
      {
        "<leader>aR",
        function()
          require("agentic").restore_session()
        end,
        mode = { "n", "v", "i" },
        desc = "Codex Restore Session",
      },
      {
        "<leader>aL",
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        mode = { "n" },
        desc = "Codex Add Line Diagnostics",
      },
      {
        "<leader>aB",
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        mode = { "n" },
        desc = "Codex Add Buffer Diagnostics",
      },
    },
  },
}
