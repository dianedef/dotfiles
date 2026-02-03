return {
  "Rolv-Apneseth/tfm.nvim",
  enabled = false,
  lazy = false,
  opts = {
    file_manager = "yazi",
    replace_netrw = false,
    enable_cmds = true,
    ui = {
      border = "rounded",
      height = 0.9,
      width = 0.9,
    },
  },
  keys = {
    { "<leader>e", "<cmd>Tfm<cr>", desc = "TFM" },
    { "<leader>E", "<cmd>TfmSplit<cr>", desc = "TFM (split)" },
  },
}
