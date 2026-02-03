return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  enabled = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  keys = {
    { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
    { "<leader>hm", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
    { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
    { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
    { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
    { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
    { "<leader>5", function() require("harpoon"):list():select(5) end, desc = "Harpoon 5" },
  },
}
