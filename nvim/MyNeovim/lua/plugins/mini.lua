-- mini.nvim collection (enable individual modules as needed)
return {
  "nvim-mini/mini.nvim",
  enabled = false,
  version = "*",
  config = function()
    -- Uncomment modules you want to use:
    -- require("mini.ai").setup()         -- Better text objects
    -- require("mini.align").setup()      -- Align text
    -- require("mini.animate").setup()    -- Animations
    -- require("mini.bracketed").setup()  -- Bracket navigation
    -- require("mini.bufremove").setup()  -- Better buffer removal
    -- require("mini.comment").setup()    -- Comments
    -- require("mini.cursorword").setup() -- Highlight word under cursor
    -- require("mini.diff").setup()       -- Git diff
    -- require("mini.extra").setup()      -- Extra pickers
    -- require("mini.hipatterns").setup() -- Highlight patterns
    -- require("mini.indentscope").setup()-- Indent scope
    -- require("mini.jump").setup()       -- Jump with f/t
    -- require("mini.jump2d").setup()     -- 2D jump
    -- require("mini.map").setup()        -- Window with buffer minimap
    -- require("mini.move").setup()       -- Move lines/selections
    -- require("mini.operators").setup()  -- Text operators
    -- require("mini.pairs").setup()      -- Auto pairs
    -- require("mini.pick").setup()       -- Pick (like telescope)
    -- require("mini.splitjoin").setup()  -- Split/join arguments
    -- require("mini.starter").setup()    -- Start screen
    -- require("mini.statusline").setup() -- Status line
    -- require("mini.surround").setup()   -- Surround
    -- require("mini.tabline").setup()    -- Tab line
    -- require("mini.trailspace").setup() -- Trailing whitespace
  end,
}
