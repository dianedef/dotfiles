local user_root_dir = vim.fs.normalize((vim.uv.os_homedir() or vim.env.HOME or vim.fn.expand("~")))
local launch_dir = vim.fn.getcwd()

local function resolve_root_dir()
  return user_root_dir
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  event = "VimEnter",
  init = function()
    local function open_root_tree()
      local root_dir = resolve_root_dir()
      local neo_tree_ok, neo_tree_cmd = pcall(require, "neo-tree.command")
      if neo_tree_ok and neo_tree_cmd and neo_tree_cmd.execute then
        neo_tree_cmd.execute({
          source = "filesystem",
          toggle = true,
          dir = root_dir,
          position = "left",
        })
      else
        vim.cmd("Neotree")
      end
    end

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.schedule(open_root_tree)
      end,
    })
  end,
  keys = {
    {
      "<leader>e",
      function()
        local neo_tree_ok, neo_tree_cmd = pcall(require, "neo-tree.command")
        if neo_tree_ok and neo_tree_cmd and neo_tree_cmd.execute then
          neo_tree_cmd.execute({ toggle = true, source = "filesystem", dir = launch_dir })
          return
        end
        vim.cmd("Neotree")
      end,
      desc = "NeoTree (cwd)",
    },
    {
      "<leader>E",
      function()
        local neo_tree_ok, neo_tree_cmd = pcall(require, "neo-tree.command")
        if neo_tree_ok and neo_tree_cmd and neo_tree_cmd.execute then
          neo_tree_cmd.execute({
            toggle = true,
            source = "filesystem",
            dir = resolve_root_dir(),
          })
          return
        end
        vim.cmd("Neotree")
      end,
      desc = "NeoTree (root)",
    },
    {
      "<leader>ge",
      function()
        require("neo-tree.command").execute({ source = "git_status", toggle = true })
      end,
      desc = "NeoTree Git",
    },
  },
  opts = function()
    local dir_git_cache = {}

    local function normalize_status(status)
      if type(status) == "table" then
        return status[1]
      end
      return status
    end

    local function mark_parent_dirs(git_root, git_status)
      local cache = {}

      for changed_path, raw_status in pairs(git_status or {}) do
        if type(changed_path) == "string" then
          local status = normalize_status(raw_status)
          if status and status ~= "!" then
            local marker = status == "?" and "?" or "*"
            local current = changed_path

            while true do
              local parent = vim.fs.dirname(current)
              if not parent or parent == current or #parent < #git_root then
                break
              end

              local existing = cache[parent]
              if existing ~= "?" then
                cache[parent] = marker
              end
              current = parent
            end
          end
        end
      end

      dir_git_cache[git_root] = cache
    end

    local function contained_git_status(_, node)
      if node.type ~= "directory" then
        return {}
      end

      local git = require("neo-tree.git")
      local path = node.path or node:get_id()
      local git_root = git.find_existing_worktree(path)
      if not git_root then
        return {}
      end

      local marker = dir_git_cache[git_root] and dir_git_cache[git_root][path] or nil
      if not marker then
        return {}
      end

      return {
        text = marker .. " ",
        highlight = marker == "?" and "NeoTreeGitUntracked" or "NeoTreeGitModified",
      }
    end

    return {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status" },
      event_handlers = {
        {
          event = "git_status_changed",
          handler = function(args)
            mark_parent_dirs(args.git_root, args.git_status)
          end,
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
        window = {
          mappings = {
            ["l"] = "open",
          },
        },
        components = {
          contained_git_status = contained_git_status,
        },
        renderers = {
          directory = {
            { "indent" },
            { "icon" },
            {
              "container",
              content = {
                { "contained_git_status", zindex = 15 },
                { "name", zindex = 10 },
                { "clipboard", zindex = 10 },
                { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
                { "git_status", zindex = 10, align = "right", hide_when_expanded = true },
              },
            },
          },
        },
      },
      window = {
        position = "left",
        width = 36,
        mappings = {
          ["<space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            added = "A",
            modified = "M",
            deleted = "D",
            renamed = "R",
            untracked = "?",
            ignored = "!",
            unstaged = "U",
            staged = "S",
            conflict = "C",
          },
        },
      },
    }
  end,
}
