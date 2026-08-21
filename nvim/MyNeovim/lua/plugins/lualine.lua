return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  lazy = false,
  config = function()
    -- colorscheme kanagawa-wave
    -- stylua: ignore
    local colors = {
      bg       = '#1F1F28',
      fg       = '#C8C093',
      yellow   = '#DCA561',
      cyan     = '#6A9589',
      darkblue = '#658594',
      green    = '#7AA89F',
      orange   = '#FFA066',
      violet   = '#9CABCA',
      magenta  = '#957FB8',
      blue     = '#A3D4D5',
      red      = '#E46876',
    }

    local function section_color(fg, bg, gui)
      local color = { fg = fg, bg = bg }
      if gui then color.gui = gui end
      return color
    end

    local function active_theme()
      return {
        a = section_color(colors.bg, colors.violet, "bold"),
        b = section_color(colors.fg, colors.bg),
        c = section_color(colors.fg, colors.bg),
        x = section_color(colors.fg, colors.bg),
        y = section_color(colors.fg, colors.bg),
        z = section_color(colors.bg, colors.violet, "bold"),
      }
    end

    local function inactive_theme()
      return {
        a = section_color(colors.fg, colors.bg),
        b = section_color(colors.fg, colors.bg),
        c = section_color(colors.fg, colors.bg),
        x = section_color(colors.fg, colors.bg),
        y = section_color(colors.fg, colors.bg),
        z = section_color(colors.fg, colors.bg),
      }
    end

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,
    }

    local config = {
      options = {
        -- Disable sections and component separators
        component_separators = "",
        section_separators = "",
        disabled_filetypes = {
          "AgenticChat",
          "AgenticInput",
          "AgenticCode",
          "AgenticFiles",
          "AgenticDiagnostics",
          "AgenticTodos",
        },
        theme = {
          normal = active_theme(),
          insert = active_theme(),
          visual = active_theme(),
          replace = active_theme(),
          command = active_theme(),
          inactive = inactive_theme(),
        },
        refresh = {
          statusline = 500,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        -- remove defaults
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- filled later
        lualine_a = { { "mode", color = { fg = colors.bg, bg = colors.violet, gui = "bold" } } },
        lualine_c = {},
        lualine_x = {},
      },
      inactive_sections = {
        -- remove defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
      },
    }

    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    --  ╭──────────────────────────────────────────────────────────╮
    --  │ left section                                             │
    --  ╰──────────────────────────────────────────────────────────╯

    -- Macro recording indicator
    ins_left({
      function()
        local reg = vim.fn.reg_recording()
        if reg == "" then return "" end
        return "recording @" .. reg
      end,
      cond = function() return vim.fn.reg_recording() ~= "" end,
      icon = "\u{f111}",
      color = { fg = colors.red, gui = "bold" },
    })

    -- Search count
    ins_left({
      function()
        if vim.v.hlsearch == 0 then return "" end
        local ok, c = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 100 })
        if not ok or not c or (c.total or 0) == 0 then return "" end
        return string.format("%d/%d", c.current or 0, c.total)
      end,
      cond = function()
        if vim.v.hlsearch == 0 then return false end
        local ok, c = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 100 })
        return ok and c and (c.total or 0) > 0
      end,
      icon = "\u{f002}",
      color = { fg = colors.yellow },
    })

    ins_left({
      "b:gitsigns_head",
      icon = "",
      color = { fg = colors.violet },
    })

    ins_left({
      function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      end,
      icon = "\u{f07b}",
      color = { fg = colors.cyan },
    })

    local git_repo_cache = { cwd = "", modified = 0, untracked = 0, ahead = 0, behind = 0, in_repo = false, ts = 0 }

    local function refresh_git_repo_stats()
      local cwd = vim.fn.getcwd()
      local lines = vim.fn.systemlist({ "git", "-C", cwd, "status", "--porcelain=v1", "--branch" })
      if vim.v.shell_error ~= 0 then
        git_repo_cache = { cwd = cwd, modified = 0, untracked = 0, ahead = 0, behind = 0, in_repo = false, ts = vim.uv.now() }
        return
      end
      local modified, untracked, ahead, behind = 0, 0, 0, 0
      for _, line in ipairs(lines) do
        if line:sub(1, 2) == "##" then
          local a = line:match("ahead (%d+)")
          local b = line:match("behind (%d+)")
          if a then ahead = tonumber(a) end
          if b then behind = tonumber(b) end
        elseif line:sub(1, 2) == "??" then
          untracked = untracked + 1
        elseif line ~= "" then
          modified = modified + 1
        end
      end
      git_repo_cache = { cwd = cwd, modified = modified, untracked = untracked, ahead = ahead, behind = behind, in_repo = true, ts = vim.uv.now() }
    end

    local function git_repo_stats()
      local cwd = vim.fn.getcwd()
      local now = vim.uv.now()
      if git_repo_cache.cwd ~= cwd or (now - git_repo_cache.ts) > 60000 then
        refresh_git_repo_stats()
      end
      return git_repo_cache
    end

    ins_left({
      function()
        local s = git_repo_stats()
        if not s.in_repo then return "" end
        local parts = {}
        if s.modified > 0 then table.insert(parts, "\u{f459}" .. s.modified) end
        if s.untracked > 0 then table.insert(parts, "\u{f128}" .. s.untracked) end
        if s.ahead > 0 then table.insert(parts, "\u{f55c}" .. s.ahead) end
        if s.behind > 0 then table.insert(parts, "\u{f544}" .. s.behind) end
        return table.concat(parts, " ")
      end,
      color = { fg = colors.yellow },
      cond = function() return git_repo_stats().in_repo end,
    })

    local function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end
    ins_left({
      "diff",
      source = diff_source,
      colored = true,
      symbols = { added = " ", modified = "󰝤 ", removed = " " },
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
      },
      cond = conditions.hide_in_width,
    })

    ins_left({
      "diagnostics",
      sources = { "nvim_diagnostic" },
      symbols = { error = " ", warn = " ", info = " " },
      diagnostics_color = {
        color_error = { fg = colors.red },
        color_warn = { fg = colors.yellow },
        color_info = { fg = colors.cyan },
      },
    })

    -- Word count (markdown only)
    ins_left({
      function()
        local wc = vim.fn.wordcount()
        local n = wc.visual_words or wc.words or 0
        return n .. " mots"
      end,
      cond = function()
        return vim.bo.filetype == "markdown" or vim.bo.filetype == "text"
      end,
      icon = "\u{f02d}",
      color = { fg = colors.green },
    })

    --  ╭──────────────────────────────────────────────────────────╮
    --  │ mid section                                              │
    --  ╰──────────────────────────────────────────────────────────╯
    -- ins_left({
    --   function()
    --     return "%="
    --   end,
    -- })

    --  ╭──────────────────────────────────────────────────────────╮
    --  │ right section                                            │
    --  ╰──────────────────────────────────────────────────────────╯
    -- ins_right({
    --   function()
    --     return "󰓹 " .. require("grapple").key()
    --   end,
    --   cond = require("grapple").exists,
    --   color = { fg = colors.violet },
    -- })

    local custom_filetype = require("lualine.components.filetype"):extend()
    local highlight = require("lualine.highlight")
    local default_status_colors = { saved = colors.violet, modified = colors.darkblue }
    function custom_filetype:init(options)
      custom_filetype.super.init(self, options)
      self.status_colors = {
        saved = highlight.create_component_highlight_group(
          { fg = default_status_colors.saved },
          "filename_status_saved",
          self.options
        ),
        modified = highlight.create_component_highlight_group(
          { fg = default_status_colors.modified },
          "filename_status_modified",
          self.options
        ),
      }
    end
    function custom_filetype:update_status()
      local data = custom_filetype.super.update_status(self)
      data = highlight.component_format_highlight(
        vim.bo.modified and self.status_colors.modified or self.status_colors.saved
      ) .. data
      return data
    end

    -- LSP attached
    ins_right({
      function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return "" end
        local names = {}
        for _, c in ipairs(clients) do
          table.insert(names, c.name)
        end
        return table.concat(names, ",")
      end,
      icon = "\u{f085}",
      color = { fg = colors.cyan },
      cond = function()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end,
    })

    -- Lazy updates pending
    ins_right({
      function()
        local ok, lazy = pcall(require, "lazy.status")
        if not ok then return "" end
        return lazy.has_updates() and lazy.updates() or ""
      end,
      cond = function()
        local ok, lazy = pcall(require, "lazy.status")
        return ok and lazy.has_updates()
      end,
      color = { fg = colors.orange },
    })

    -- Session loaded indicator (persistence.nvim)
    local session_loaded = false
    vim.api.nvim_create_autocmd("User", {
      pattern = { "PersistenceLoadPost", "PersistenceSavePost" },
      callback = function() session_loaded = true end,
    })
    ins_right({
      function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      end,
      icon = "\u{f0c7}",
      color = { fg = colors.magenta },
      cond = function() return session_loaded end,
    })

    ins_right({ custom_filetype })
    ins_right({ "location", color = { fg = colors.violet } })
    ins_right({ "progress", color = { fg = colors.violet } })
    require("lualine").setup(config)
  end,
}
