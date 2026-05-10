local function resolve_codex_acp_command()
  local local_bin = vim.fn.expand("~/.npm-global/bin/codex-acp")
  if vim.fn.executable(local_bin) == 1 then
    return local_bin
  end

  local path_bin = vim.fn.exepath("codex-acp")
  if path_bin ~= "" then
    return path_bin
  end

  return "codex-acp"
end

local function codex_acp_env()
  local env = {
    NODE_NO_WARNINGS = "1",
    HOME = os.getenv("HOME"),
  }

  local codex_home = os.getenv("CODEX_HOME")
  if codex_home and codex_home ~= "" then
    env.CODEX_HOME = codex_home
  end

  return env
end

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
    provider = "codex",
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
    acp_providers = {
      codex = {
        command = resolve_codex_acp_command(),
        args = {},
        env = codex_acp_env(),
        auth_method = "chatgpt",
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
      submit = {
        normal = "<CR>",
        insert = "<CR>",
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
    "AvanteToggleToolMessages",
    "ShipFlowAvantePanel1",
    "ShipFlowAvantePanel2",
    "ShipFlowAvantePanel3",
    "ShipFlowAvantePanel20",
    "ShipFlowAvantePanel30",
    "ShipFlowAvantePanelFull",
  },
  keys = {
    { "<leader>aa", false },
    { "<leader>ac", false },
    { "<leader>ae", false },
    { "<leader>af", false },
    { "<leader>ah", false },
    { "<leader>am", false },
    { "<leader>an", false },
    { "<leader>ap", false },
    { "<leader>ar", false },
    { "<leader>as", false },
    { "<leader>at", false },
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
    { "<leader>ax1", "<cmd>ShipFlowAvantePanel1<CR>", desc = "Avante panel 1" },
    { "<leader>ax2", "<cmd>ShipFlowAvantePanel2<CR>", desc = "Avante panel 2" },
    { "<leader>ax3", "<cmd>ShipFlowAvantePanel3<CR>", desc = "Avante panel 3" },
    { "<leader>axF", "<cmd>ShipFlowAvantePanelFull<CR>", desc = "Avante panel full" },
    { "<leader>axp", "<cmd>AvanteSwitchProvider<CR>", desc = "Avante Switch Provider" },
    { "<leader>axT", "<cmd>AvanteToggleToolMessages<CR>", desc = "Avante Toggle Tool Messages" },
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
    local avante_panel_presets = {
      [1] = { vertical = 30, horizontal = 15 },
      [2] = { vertical = 45, horizontal = 20 },
      [3] = { vertical = 60, horizontal = 30 },
    }

    local function set_avante_panel_size(size)
      local avante = require("avante")
      local Config = require("avante.config")
      local sidebar = avante.get()
      local layout = vim.tbl_contains({ "top", "bottom" }, Config.windows.position) and "horizontal" or "vertical"
      if sidebar and type(sidebar.get_layout) == "function" then
        layout = sidebar:get_layout()
      end

      local width = size == "full" and 100 or tonumber(size)
      local height = width
      if type(size) == "table" then
        width = tonumber(size.vertical)
        height = tonumber(size.horizontal)
      end

      if not width or not height then return end
      width = math.max(1, math.min(100, math.floor(width)))
      height = math.max(1, math.min(100, math.floor(height)))
      Config.override({ windows = { width = width, height = height } })

      local percent = layout == "horizontal" and height or width

      local resized = false
      if sidebar and type(sidebar.is_open) == "function" and sidebar:is_open() then
        if size == "full" then
          if not sidebar.is_in_full_view and type(sidebar.toggle_code_window) == "function" then
            sidebar:toggle_code_window()
          end
        else
          if sidebar.is_in_full_view and type(sidebar.toggle_code_window) == "function" then
            sidebar:toggle_code_window()
          end
          if type(sidebar.adjust_result_container_layout) == "function" then
            sidebar:adjust_result_container_layout()
          end
          if type(sidebar.render_input) == "function" then
            pcall(function() sidebar:render_input() end)
          end
          if type(sidebar.render_selected_code) == "function" then
            pcall(function() sidebar:render_selected_code() end)
          end
        end
        resized = true
      end

      local axis = layout == "horizontal" and "hauteur" or "largeur"
      local label = size == "full" and "full" or (percent .. "%")
      local suffix = resized and "" or " (applique au prochain panneau Avante ouvert)"
      vim.notify(("Avante %s: %s%s"):format(axis, label, suffix), vim.log.levels.INFO)
    end

    local function patch_avante_invalid_buffer_root()
      local ok, root = pcall(require, "avante.utils.root")
      if not ok or type(root) ~= "table" or type(root.get) ~= "function" then return end
      if root.__myneovim_invalid_buffer_root_patch then return end

      local base_get = root.get

      local function fallback_project_root(bufnr)
        local cached = type(bufnr) == "number" and root.cache and root.cache[bufnr] or nil
        if type(cached) == "string" and cached ~= "" then return cached end

        local cwd = vim.uv.cwd()
        if cwd and cwd ~= "" then return cwd end
        return vim.fn.getcwd()
      end

      root.get = function(root_opts)
        local bufnr = root_opts and root_opts.buf
        if type(bufnr) == "number" and bufnr ~= 0 and not vim.api.nvim_buf_is_valid(bufnr) then
          return fallback_project_root(bufnr)
        end

        local ok_get, project_root = pcall(base_get, root_opts)
        if ok_get and type(project_root) == "string" and project_root ~= "" then
          return project_root
        end

        return fallback_project_root(bufnr)
      end

      root.__myneovim_invalid_buffer_root_patch = true
    end

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

    local function patch_avante_hide_tool_messages()
      local ok_render, render = pcall(require, "avante.history.render")
      local ok_helpers, helpers = pcall(require, "avante.history.helpers")
      if not ok_render or not ok_helpers then return end
      if render.__myneovim_hide_tool_messages_patch then return end

      vim.g.avante_hide_tool_messages = vim.g.avante_hide_tool_messages ~= false

      local base_message_to_lines = render.message_to_lines
      local base_message_to_text = render.message_to_text

      render.message_to_lines = function(message, messages, expanded)
        if vim.g.avante_hide_tool_messages ~= false and helpers.is_tool_use_message(message) then
          return {}
        end
        return base_message_to_lines(message, messages, expanded)
      end

      render.message_to_text = function(message, messages)
        if vim.g.avante_hide_tool_messages ~= false and helpers.is_tool_use_message(message) then
          return ""
        end
        return base_message_to_text(message, messages)
      end

      render.__myneovim_hide_tool_messages_patch = true
    end

    local function patch_avante_openai_nil_tool_result_content()
      local ok, openai = pcall(require, "avante.providers.openai")
      if not ok or type(openai) ~= "table" or type(openai.parse_messages) ~= "function" then return end
      if openai.__myneovim_nil_tool_result_content_patch then return end

      local base_parse_messages = openai.parse_messages

      openai.parse_messages = function(self, parse_opts)
        if type(parse_opts) == "table" and type(parse_opts.messages) == "table" then
          for _, msg in ipairs(parse_opts.messages) do
            if type(msg.content) == "table" then
              for _, item in ipairs(msg.content) do
                if type(item) == "table" and item.type == "tool_result" and item.content == nil then
                  item.content = ""
                end
              end
            elseif msg.content == nil then
              msg.content = ""
            end
          end
        end

        return base_parse_messages(self, parse_opts)
      end

      openai.__myneovim_nil_tool_result_content_patch = true
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
    patch_avante_invalid_buffer_root()
    patch_avante_horizontal_input_layout()
    patch_avante_hide_tool_messages()
    patch_avante_openai_nil_tool_result_content()
    require("avante").setup(opts)
    vim.api.nvim_create_user_command("ShipFlowAvantePanel1", function()
      set_avante_panel_size(avante_panel_presets[1])
    end, { desc = "Set Avante panel preset 1", force = true })
    vim.api.nvim_create_user_command("ShipFlowAvantePanel2", function()
      set_avante_panel_size(avante_panel_presets[2])
    end, { desc = "Set Avante panel preset 2", force = true })
    vim.api.nvim_create_user_command("ShipFlowAvantePanel3", function()
      set_avante_panel_size(avante_panel_presets[3])
    end, { desc = "Set Avante panel preset 3", force = true })
    vim.api.nvim_create_user_command("ShipFlowAvantePanel20", function()
      set_avante_panel_size(avante_panel_presets[1])
    end, { desc = "Set Avante panel width/height to 20%", force = true })
    vim.api.nvim_create_user_command("ShipFlowAvantePanel30", function()
      set_avante_panel_size(avante_panel_presets[2])
    end, { desc = "Set Avante panel width/height to 30%", force = true })
    vim.api.nvim_create_user_command("ShipFlowAvantePanelFull", function()
      set_avante_panel_size("full")
    end, { desc = "Set Avante panel width/height to full", force = true })
    vim.api.nvim_create_user_command("AvanteToggleToolMessages", function()
      local currently_hidden = vim.g.avante_hide_tool_messages ~= false
      vim.g.avante_hide_tool_messages = not currently_hidden
      vim.notify(
        "Avante tool messages " .. (vim.g.avante_hide_tool_messages and "hidden" or "visible"),
        vim.log.levels.INFO
      )
    end, {})
    vim.api.nvim_set_hl(0, "AvanteTitle", { fg = "#ABB2BF", bg = "#353B45" })
    vim.api.nvim_set_hl(0, "AvanteReversedTitle", { fg = "#353B45" })
    vim.api.nvim_set_hl(0, "AvanteSubtitle", { fg = "#ABB2BF", bg = "#353B45" })
    vim.api.nvim_set_hl(0, "AvanteReversedSubtitle", { fg = "#353B45" })
  end,
}
