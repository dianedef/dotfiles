return {
  "aaronhallaert/advanced-git-search.nvim",
  enabled = false,
  cmd = { "AdvancedGitSearch" },
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "tpope/vim-fugitive",
    "tpope/vim-rhubarb",
  },
  config = function()
    require("telescope").load_extension("advanced_git_search")
  end,
  keys = {
    { "<leader>gS", "<cmd>AdvancedGitSearch<cr>", desc = "Advanced Git Search" },
  },
}
