return {
  "augmentcode/augment.vim",
  enabled = true,
  dependencies = {
    -- Requires Node 22.0.0+ to be installed on the system
  },
  build = function()
    -- Run npm install in the plugin directory
    vim.fn.system("cd " .. vim.fn.stdpath("data") .. "/lazy/augment.vim && npm install")
  end,
  init = function()
    -- augment.vim is a Vimscript plugin — configure via vim.g.augment_*
    -- See https://github.com/augmentcode/augment.vim for available options
    -- vim.g.augment_workspace_folders = { "~/projects/myproject" }
    -- vim.g.augment_disable_completions = false
    -- vim.g.augment_disable_tab_mapping = false
  end,
  keys = {
    {
      "<leader>auc",
      "<cmd>AugmentChat<cr>",
      desc = "Augment Chat",
      mode = { "n", "v" },
    },
    {
      "<leader>aus",
      "<cmd>AugmentSync<cr>",
      desc = "Augment Sync Project",
      mode = "n",
    },
    {
      "<leader>aut",
      "<cmd>AugmentToggle<cr>",
      desc = "Augment Toggle Completions",
      mode = "n",
    },
  },
}
