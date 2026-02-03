return {
  "ray-x/navigator.lua",
  enabled = false,
  dependencies = {
    { "ray-x/guihua.lua", build = "cd lua/fzy && make" },
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    lsp = {
      enable = true,
      format_on_save = false,
    },
    icons = {
      code_action_icon = "💡",
    },
  },
}
