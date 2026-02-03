return {
  "esmuellert/codediff.nvim",
  enabled = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "CodeDiff", "CodeDiffClose" },
  opts = {},
  keys = {
    { "<leader>cd", "<cmd>CodeDiff<cr>", mode = { "n", "v" }, desc = "CodeDiff" },
  },
}
