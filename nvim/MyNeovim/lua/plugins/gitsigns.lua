return {
  "lewis6991/gitsigns.nvim",
  keys = {
    { "<leader>ghp", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview Git hunk inline" },
    { "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage Git hunk" },
    { "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Git hunk" },
    { "<leader>ghb", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
    { "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff current file" },
    { "<leader>ght", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle Git word diff" },
  },
  opts = {
    signcolumn = true,
    numhl = true,
    linehl = true,
    word_diff = true,
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "^" },
      changedelete = { text = "!" },
      untracked = { text = "?" },
    },
  },
}
