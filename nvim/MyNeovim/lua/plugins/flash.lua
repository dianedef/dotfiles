return {
  "folke/flash.nvim",
  enabled = true,
  event = "VeryLazy",
  opts = {
    modes = {
      -- Termux/custom keyboard paste can replay normal-mode text through Neo-tree.
      -- Keep explicit Flash jumps, but leave char motions native to avoid nil state crashes.
      char = {
        enabled = false,
      },
    },
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
