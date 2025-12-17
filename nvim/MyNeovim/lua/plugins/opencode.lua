-- OpenCode.nvim - AI coding assistant (Codespaces/Linux)
return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Default command (uses system opencode)
    }

    vim.o.autoread = true

    -- Keymaps (using <leader>o prefix to avoid conflicts)
    vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>ox", function() require("opencode").select() end, { desc = "Execute opencode action" })
    vim.keymap.set({ "n", "x" }, "<leader>op", function() require("opencode").prompt("@this") end, { desc = "Add to opencode" })
    vim.keymap.set({ "n", "t" }, "<leader>ot", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
  end,
}