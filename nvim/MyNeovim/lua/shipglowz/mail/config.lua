local M = {
  maildir_root = vim.env.MAIL_INTEL_ROOT or "~/Mail/competitors",
  account = vim.env.MAIL_INTEL_ACCOUNT or "business-a",
  folder = vim.env.MAIL_INTEL_FOLDER or "_to_transcribe",
  limit = tonumber(vim.env.MAIL_INTEL_LIMIT or "30") or 30,
  private_root = vim.env.SHIPGLOWZ_MAIL_INTAKE_ROOT or "~/.shipglowz/private/data/mail-intake",
}

return M
