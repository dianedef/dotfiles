return {
  "leath-dub/snipe.nvim",
  enabled = false,
  opts = {
    ui = {
      position = "center",
    },
    hints = {
      dictionary = "asdfjkl;ghqwertyuiopzxcvbnm",
    },
  },
  keys = {
    { "<leader>bs", function() require("snipe").open_buffer_menu() end, desc = "Snipe buffer" },
  },
}
