return {
  "NeogitOrg/neogit",
  enabled = true,
  init = function()
    package.preload["neogit.popups.diff.actions"] = function()
      return require("config.neogit_diff_actions")
    end
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
  opts = {
    integrations = {
      telescope = true,
    },
  },
  config = function(_, opts)
    local neogit = require("neogit")
    neogit.setup(opts)

    local config = require("neogit.config")
    local original_get_diff_viewer = config.get_diff_viewer

    config.get_diff_viewer = function()
      if vim.fn.executable("difft") == 1 then
        return "difftastic"
      end
      return original_get_diff_viewer()
    end
  end,
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
    { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
    { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Neogit push" },
    { "<leader>gl", "<cmd>Neogit pull<cr>", desc = "Neogit pull" },
  },
}
