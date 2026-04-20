return {
  "augment-vim/augment.vim",
  enabled = false, -- Disabled by default, enable when ready to use
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
    -- See https://github.com/augment-vim/augment.vim for full options
  },
  config = function(_, opts)
    -- Setup augment with options
    require("augment").setup(opts)
  end,
  keys = {
    -- Chat interface
    {
      "<leader>au",
      "<cmd>AugmentChat<cr>",
      desc = "Augment: Open Chat",
      mode = { "n", "v" },
    },
    -- Sync project context
    {
      "<leader>aU",
      "<cmd>AugmentSync<cr>",
      desc = "Augment: Sync Project Context",
      mode = "n",
    },
    -- Toggle completions
    {
      "<leader>at",
      "<cmd>AugmentToggle<cr>",
      desc = "Augment: Toggle Completions",
      mode = "n",
    },
  },
}
