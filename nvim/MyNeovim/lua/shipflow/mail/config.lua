local M = {}

local function repo_root()
  local info = debug.getinfo(1, "S").source:gsub("^@", "")
  return vim.fn.fnamemodify(info, ":p:h:h:h:h")
end

M.options = {
  maildir_root = vim.env.MAIL_INTEL_ROOT or vim.fn.expand("~/Mail/competitors"),
  default_account = vim.env.MAIL_INTEL_ACCOUNT or "business-a",
  default_folder = vim.env.MAIL_INTEL_FOLDER or "_to_transcribe",
  limit = tonumber(vim.env.MAIL_INTEL_LIMIT) or 30,
  cli = repo_root() .. "/scripts/mail-intel",
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
  return M.options
end

function M.get()
  return M.options
end

return M
