local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {
        bigfile = { enabled = true },
        explorer = { enabled = true },
        notifier = { enabled = true },
        picker = { enabled = true },
        quickfile = { enabled = true },
      },
    },
    {
      "preservim/vim-pencil",
      ft = { "markdown", "text", "tex" },
      init = function()
        vim.g["pencil#wrapModeDefault"] = "soft"
      end,
      keys = {
        { "<leader>pe", "<cmd>PencilToggle<cr>", desc = "Pencil Toggle" },
      },
    },
    {
      "kylechui/nvim-surround",
      version = "*",
      event = "VeryLazy",
      opts = {
        aliases = {
          ["("] = ")",
          ["{"] = "}",
          ["["] = "]",
          ["<"] = ">",
          ["S"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
        keymaps = {
          insert = false,
          insert_line = false,
          normal = "S",
          normal_cur = "SS",
          normal_line = false,
          normal_cur_line = false,
          visual = "S",
          visual_line = false,
          delete = "dS",
          change = "cS",
          change_line = false,
        },
      },
    },
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      keys = {
        { "<leader>ghp", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview Git hunk inline" },
        { "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage Git hunk" },
        { "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Git hunk" },
        { "<leader>ghb", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
        { "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff current file" },
        { "<leader>ght", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle Git word diff" },
      },
      opts = {
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "^" },
          changedelete = { text = "!" },
          untracked = { text = "?" },
        },
      },
    },
    {
      "tadmccorkle/markdown.nvim",
      ft = "markdown",
      opts = {
        mappings = {
          inline_surround_toggle = "gs",
          inline_surround_toggle_line = "gss",
          inline_surround_delete = "ds",
          inline_surround_change = "cs",
          link_add = "gl",
          link_follow = "gx",
          go_curr_heading = "]c",
          go_parent_heading = "]p",
          go_next_heading = "]]",
          go_prev_heading = "[[",
        },
        toc = {
          omit_heading = "toc omit heading",
          omit_section = "toc omit section",
        },
      },
    },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  checker = {
    enabled = false,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
