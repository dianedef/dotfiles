return {
  "NeogitOrg/neogit",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
  opts = {
    integrations = {
      telescope = true,
      diffview = true,
    },
  },
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
    { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Neogit push" },
    { "<leader>gl", "<cmd>Neogit pull<cr>", desc = "Neogit pull" },
  },
}
