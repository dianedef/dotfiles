return {
  "shortcuts/no-neck-pain.nvim",
  enabled = false,
  version = "*",
  cmd = { "NoNeckPain" },
  opts = {
    width = 120,
    buffers = {
      scratchPad = { enabled = false },
      bo = { filetype = "no-neck-pain" },
    },
  },
  keys = {
    { "<leader>np", "<cmd>NoNeckPain<cr>", desc = "No Neck Pain" },
  },
}
