local explorer_panel = require("config.explorer-panel")

return {
  "folke/snacks.nvim",
  enabled = true,
  priority = 1000,
  lazy = false,
  init = function()
    -- LazyVim references the global `Snacks` while resolving other plugin opts.
    if not _G.Snacks then
      _G.Snacks = require("snacks")
    end
  end,
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = false }, -- using nvim-notify
    picker = {
      sources = {
        git_diff = {
          layout = {
            fullscreen = true,
            layout = {
              box = "vertical",
              border = true,
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", height = 0.2, border = "none" },
              { win = "preview", title = "{preview}", border = "top" },
            },
          },
        },
        explorer = {
          git_status = true,
          git_status_open = true,
          git_untracked = true,
          diagnostics = true,
          follow_file = true,
          layout = explorer_panel.snacks_layout(),
          win = {
            list = {
              keys = {
                ["<c-f>"] = "picker_files",
                ["<c-g>"] = "picker_grep",
              },
            },
          },
          format = function(item, picker)
            local fmt = require("snacks.picker.format")
            local git = require("snacks.picker.source.git")
            local ret = {}

            if item.label then
              ret[#ret + 1] = { item.label, "SnacksPickerLabel" }
              ret[#ret + 1] = { " ", virtual = true }
            end

            if item.parent then
              vim.list_extend(ret, fmt.tree(item, picker))
            end

            if item.status then
              local status = git.git_status(item.status)
              local hl = "SnacksPickerGitStatus"
              if status.unmerged then
                hl = "SnacksPickerGitStatusUnmerged"
              elseif status.staged then
                hl = "SnacksPickerGitStatusStaged"
              else
                hl = "SnacksPickerGitStatus" .. status.status:sub(1, 1):upper() .. status.status:sub(2)
              end

              local icon = status.status:sub(1, 1):upper()
              icon = status.status == "untracked" and "?" or status.status == "ignored" and "!" or icon
              if picker.opts.icons.git.enabled then
                icon = picker.opts.icons.git[status.unmerged and "unmerged" or status.status] or icon
                if status.staged then
                  icon = picker.opts.icons.git.staged
                end
              end

              ret[#ret + 1] = { icon .. " ", hl }
            end

            if item.severity then
              vim.list_extend(ret, fmt.severity(item, picker))
            end

            vim.list_extend(ret, fmt.filename(item, picker))

            if item.comment then
              ret[#ret + 1] = { item.comment, "SnacksPickerComment" }
              ret[#ret + 1] = { " " }
            end

            return ret
          end,
        },
      },
    },
    quickfile = { enabled = true },
    scroll = { enabled = false }, -- using neoscroll
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusModified", { fg = "#ff9e3b", bold = true })
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusAdded", { fg = "#98bb6c", bold = true })
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusDeleted", { fg = "#e46876", bold = true })
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { fg = "#7fb4ca", bold = true })
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusIgnored", { fg = "#727169" })
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusStaged", { fg = "#7aa89f", bold = true })
    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUnmerged", { fg = "#e46876", bold = true })
  end,
}
