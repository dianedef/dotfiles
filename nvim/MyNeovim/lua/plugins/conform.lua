local uv = vim.uv or vim.loop

local function get_dart_bin()
  if vim.fn.executable("dart") == 1 then
    return "dart"
  end

  local bundled = vim.fn.expand("~/.local/opt/flutter/bin/dart")
  if uv.fs_stat(bundled) then
    return bundled
  end

  return "dart"
end

return {
  "stevearc/conform.nvim",
  enabled = true,
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters = {
      dart_format = {
        command = get_dart_bin,
      },
    },
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      python = { "ruff_format", "black", stop_after_first = true },
      dart = { "dart_format" },
      sh = { "shfmt" },
    },
  },
  keys = {
    { "<leader>cf", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
  },
}
