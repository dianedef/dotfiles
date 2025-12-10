return {
  "williamboman/mason.nvim",
  dependencies = {
    { "williamboman/mason-lspconfig.nvim" },
    { "WhoIsSethDaniel/mason-tool-installer.nvim", opts = {} },
  },
  config = function()
    require("mason").setup({
      ui = { border = "rounded" },
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "cssls",
        "emmet_ls",
        "bashls",
        "dockerls",
        "eslint", -- instead of `tsserver` or `eslint_d` in `null_ls` for better linting and react-specific linting rules
        "html",
        "lemminx",
        "pyright",
        "jsonls",
        "yamlls",
      },
      automatic_installation = true,
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "eslint-lsp",
        "prettier",
        "bash-language-server",
        "css-lsp",
        "dockerfile-language-server",
        "emmet-ls",
        "html-lsp",
        "json-lsp",
        "lemminx",
        "lua-language-server",
        -- python
        "pyright",
        "ruff",
      },
      auto_update = true,
    })
  end,
}
