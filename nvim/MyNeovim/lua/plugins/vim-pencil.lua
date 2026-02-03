return {
  "preservim/vim-pencil",
  enabled = false,
  ft = { "markdown", "text", "tex" },
  init = function()
    vim.g["pencil#wrapModeDefault"] = "soft"
  end,
  keys = {
    { "<leader>pe", "<cmd>PencilToggle<cr>", desc = "Pencil Toggle" },
  },
}
