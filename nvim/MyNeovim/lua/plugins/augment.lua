return {
  "augmentcode/augment.vim",
  enabled = true,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Requires Node 22.0.0+ to be installed on the system
  },
  build = function()
    -- Run npm install in the plugin directory
    vim.fn.system("cd " .. vim.fn.stdpath("data") .. "/lazy/augment.vim && npm install")
  end,
  opts = {
    -- Configuration options will go here
    -- See https://github.com/augmentcode/augment.vim for full options
  },
  config = function(_, opts)
    -- Setup augment with options
    require("augment").setup(opts)
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
