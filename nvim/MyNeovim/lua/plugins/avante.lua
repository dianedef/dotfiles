return {
  "yetone/avante.nvim",
  enabled = true,
  event = "VeryLazy",
  build = "make",
  -- build = "make BUILD_FROM_SOURCE=true luajit",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "Avante" }, latex = { enabled = false } },
      ft = { "Avante" },
    },
  },
  opts = {
    provider = "copilot",
    selector = {
      provider = "snacks",
      provider_opts = {},
    },
    input = {
      provider = "snacks",
      provider_opts = {
        title = "Avante Input",
      },
    },
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-5-sonnet-latest",
        proxy = "http://127.0.0.1:8888",
      },
    },
    behaviour = {
      auto_set_keymaps = false,
    },
    hints = { enabled = false },
    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = ";x",
        prev = ",x",
      },
      jump = {
        next = ";x",
        prev = ",x",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },
    windows = {
      width = 40, -- default % based on available width
    sidebar_header = {
        enabled = true,
      },
    },
  },
  cmd = {
    "AvanteAsk",
    "AvanteBuild",
    "AvanteChat",
    "AvanteClear",
    "AvanteEdit",
    "AvanteFocus",
    "AvanteHistory",
    "AvanteModels",
    "AvanteRefresh",
    "AvanteShowRepoMap",
    "AvanteStop",
    "AvanteSwitchProvider",
    "AvanteToggle",
  },
  keys = {
    { "<leader>axq", "<cmd>AvanteAsk<CR>", desc = "Avante Ask" },
    {
      "<leader>axc",
      function() require("avante.api").ask({ ask = false }) end,
      desc = "Avante Chat",
      mode = { "n", "v" },
    },
    { "<leader>axe", "<cmd>AvanteEdit<CR>", desc = "Avante Edit", mode = { "n", "v" } },
    { "<leader>axf", "<cmd>AvanteFocus<CR>", desc = "Avante Focus" },
    { "<leader>axh", "<cmd>AvanteHistory<CR>", desc = "Avante History" },
    { "<leader>axm", "<cmd>AvanteModels<CR>", desc = "Avante Select Model" },
    { "<leader>axn", "<cmd>AvanteChatNew<CR>", desc = "Avante New Chat" },
    { "<leader>axp", "<cmd>AvanteSwitchProvider<CR>", desc = "Avante Switch Provider" },
    { "<leader>axu", "<cmd>AvanteRefresh<CR>", desc = "Avante Refresh" },
    { "<leader>axs", "<cmd>AvanteStop<CR>", desc = "Avante Stop" },
    {
      "<leader>axt",
      function() require("avante").toggle_sidebar({ ask = false }) end,
      desc = "Toggle Avante",
      mode = { "n", "v", "i" },
    },
    {
      "<leader>axv",
      function()
        local avante = require("avante")
        local Config = require("avante.config")

        Config.override({ windows = { position = "right" } })
        avante.toggle_sidebar({ ask = false })
      end,
      desc = "Toggle Avante (vertical)",
      mode = { "n", "v", "i" },
    },
    {
      "<leader>axb",
      function()
        local avante = require("avante")
        local sidebar = avante.get()
        local Config = require("avante.config")

        Config.override({ windows = { position = "bottom" } })
        if sidebar and sidebar:is_open() then
          sidebar:close()
        end
        avante.open_sidebar({ ask = false })
      end,
      desc = "Toggle Avante (horizontal)",
      mode = { "n", "v", "i" },
    },
  },
  config = function(_, opts)
    local function patch_avante_horizontal_input_layout()
      local ok, sidebar = pcall(require, "avante.sidebar")
      if not ok or type(sidebar) ~= "table" then return end
      if sidebar.__avante_input_layout_patched then return end

      local base_create_input_container = sidebar.create_input_container
      sidebar.create_input_container = function(self)
        if self:get_layout() ~= "horizontal" then
          return base_create_input_container(self)
        end

        local original_get_layout = self.get_layout
        self.get_layout = function()
          return "vertical"
        end

        local ok, err = pcall(base_create_input_container, self)

        self.get_layout = original_get_layout
        if not ok then
          vim.notify("Avante input layout patch failed: " .. tostring(err), vim.log.levels.WARN)
        end
      end

      sidebar.__avante_input_layout_patched = true
    end

    local function clear_legacy_avante_keymaps()
      local mappings = {
        "<leader>aa",
        "<leader>an",
        "<leader>az",
        "<leader>ae",
        "<leader>ar",
        "<leader>af",
        "<leader>aS",
        "<leader>at",
        "<leader>ad",
        "<leader>aC",
        "<leader>aR",
        "<leader>a?",
        "<leader>ah",
        "<leader>aM",
        "<leader>am",
        "<leader>aB",
      }

      for _, lhs in ipairs(mappings) do
        pcall(vim.keymap.del, "n", lhs)
        pcall(vim.keymap.del, "v", lhs)
        pcall(vim.keymap.del, "i", lhs)
      end
    end

    clear_legacy_avante_keymaps()
    patch_avante_horizontal_input_layout()
    require("avante").setup(opts)
    vim.api.nvim_set_hl(0, "AvanteTitle", { fg = "#ABB2BF", bg = "#353B45" })
    vim.api.nvim_set_hl(0, "AvanteReversedTitle", { fg = "#353B45" })
    vim.api.nvim_set_hl(0, "AvanteSubtitle", { fg = "#ABB2BF", bg = "#353B45" })
    vim.api.nvim_set_hl(0, "AvanteReversedSubtitle", { fg = "#353B45" })
  end,
}
