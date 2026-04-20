local uv = vim.uv or vim.loop

local function get_dart_bin()
  if vim.fn.executable("dart") == 1 then
    return "dart"
  end

  local bundled = vim.fn.expand("~/.local/opt/flutter/bin/dart")
  if uv.fs_stat(bundled) then
    return bundled
  end
end

local dart_bin = get_dart_bin()

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dartls = dart_bin and {
          cmd = { dart_bin, "language-server", "--protocol=lsp" },
        } or {
          enabled = false,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "dart") then
        table.insert(opts.ensure_installed, "dart")
      end
    end,
  },
}
