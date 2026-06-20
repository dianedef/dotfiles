return {
  "NeogitOrg/neogit",
  enabled = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
  opts = {
    diff_viewer = "codediff",
    integrations = {
      telescope = true,
      codediff = true,
    },
  },
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
    { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Neogit push" },
    { "<leader>gl", "<cmd>Neogit pull<cr>", desc = "Neogit pull" },
  },
}
