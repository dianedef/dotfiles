local M = {}

local private_data_root = vim.env.SHIPGLOWZ_PRIVATE_DATA_DIR
  or vim.fn.expand("~/.shipglowz/private/data")

local function repo_root()
  local source = debug.getinfo(1, "S").source:gsub("^@", "")
  return vim.fn.fnamemodify(source, ":p:h:h:h:h")
end

M.options = {
  maildir_root = vim.env.MAIL_INTEL_ROOT or (private_data_root .. "/mail-source/competitors"),
  default_account = vim.env.MAIL_INTEL_ACCOUNT or "business-a",
  default_folder = vim.env.MAIL_INTEL_FOLDER or "_to_transcribe",
  limit = tonumber(vim.env.MAIL_INTEL_LIMIT or "30") or 30,
  private_root = vim.env.SHIPGLOWZ_MAIL_INTAKE_ROOT or vim.fn.expand("~/.shipglowz/private/data/mail-intake"),
  notmuch_config = vim.env.NOTMUCH_CONFIG or vim.fn.expand("~/.config/notmuch/mail-intel-config"),
  cli = repo_root() .. "/scripts/mail-intel",
  intake_cli = repo_root() .. "/scripts/mail-intake",
  delete_cli = repo_root() .. "/scripts/mail-delete",
  ai_provider = vim.env.MAIL_INTEL_AI_PROVIDER or "avante",
  ai_model_provider = vim.env.MAIL_INTEL_AI_MODEL_PROVIDER,
  project_index_root = vim.env.SHIPGLOWZ_PROJECT_INDEX_ROOT
    or (private_data_root .. "/projects"),
}

local function publish_direct_fields()
  M.maildir_root = M.options.maildir_root
  M.account = M.options.default_account
  M.folder = M.options.default_folder
  M.limit = M.options.limit
  M.private_root = M.options.private_root
  M.notmuch_config = M.options.notmuch_config
  M.cli = M.options.cli
  M.intake_cli = M.options.intake_cli
  M.delete_cli = M.options.delete_cli
  M.ai_provider = M.options.ai_provider
  M.ai_model_provider = M.options.ai_model_provider
  M.project_index_root = M.options.project_index_root
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
  publish_direct_fields()
  return M.options
end

function M.get()
  return M.options
end

function M.system_opts()
  return {
    text = true,
    env = {
      NOTMUCH_CONFIG = M.options.notmuch_config,
      MAIL_INTEL_ROOT = M.options.maildir_root,
      MAIL_INTEL_ACCOUNT = M.options.default_account,
      MAIL_INTEL_FOLDER = M.options.default_folder,
    },
  }
end

publish_direct_fields()

return M
