return {
  "mrjones2014/smart-splits.nvim",
  enabled = false,
  lazy = false,
  opts = {
    ignored_filetypes = { "nofile", "quickfix", "prompt" },
    ignored_buftypes = { "NvimTree" },
    default_amount = 3,
    at_edge = "wrap",
    cursor_follows_swapped_bufs = true,
  },
  keys = {
    -- Resizing splits
    { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize left" },
    { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize down" },
    { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize up" },
    { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
    -- Moving between splits
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
    -- Swapping buffers
    { "<leader>bh", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
    { "<leader>bj", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
    { "<leader>bk", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
    { "<leader>bl", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" },
  },
}
