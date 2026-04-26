return {
  "saghen/blink.cmp",
  enabled = true,
  lazy = false,
  version = "*",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = { preset = "default" },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    completion = {
      menu = {
        auto_show = false,
      },
      list = {
        selection = {
          preselect = false,
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets" },
    },
  },
  opts_extend = { "sources.default" },
}
