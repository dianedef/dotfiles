return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { enabled = true },
        -- Use the user-installed `ruff` binary instead of Mason on this host.
        ruff = { enabled = true, mason = false },
        ruff_lsp = { enabled = false },
      },
    },
  },
}
