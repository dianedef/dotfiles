-- OpenCode.nvim - AI coding assistant (Termux: uses Alpine proot)
return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Termux: OpenCode runs in Alpine proot
      command = "proot-distro login alpine -- /bin/sh -c 'cd /root/opencode_termux_alpine_aarch64 && ./opencode-termux-wrapper.sh'",
    }

    vim.o.autoread = true

    -- Keymaps (adapted for Termux - avoid <C-a>/<C-x> conflicts)
    vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>ox", function() require("opencode").select() end, { desc = "Execute opencode action" })
    vim.keymap.set({ "n", "x" }, "<leader>op", function() require("opencode").prompt("@this") end, { desc = "Add to opencode" })
    vim.keymap.set({ "n", "t" }, "<leader>ot", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
  end,
}