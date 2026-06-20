local M = {}

local function notify(message, level)
  vim.notify("DiffFlowz: " .. message, level or vim.log.levels.INFO)
end

local function git_root()
  return vim.fs.root(0, { ".git" }) or vim.fs.root(vim.uv.cwd(), { ".git" })
end

local function has_changes(root, staged)
  local args
  if staged then
    args = { "git", "-C", root, "diff", "--cached", "--quiet" }
  else
    args = { "git", "-C", root, "status", "--porcelain" }
  end

  local result = vim.system(args, { text = true }):wait()
  if staged then
    if result.code == 0 then
      return false
    end
    if result.code == 1 then
      return true
    end
    return nil, result.stderr
  end

  if result.code ~= 0 then
    return nil, result.stderr
  end

  return result.stdout ~= ""
end

local function open(staged)
  if vim.fn.executable("git") ~= 1 then
    notify("git is not installed", vim.log.levels.ERROR)
    return
  end

  if vim.fn.executable("difft") ~= 1 then
    notify("difft is not installed", vim.log.levels.ERROR)
    return
  end

  local root = git_root()
  if not root then
    notify("no Git repository found", vim.log.levels.WARN)
    return
  end

  local changed, err = has_changes(root, staged)
  if changed == nil then
    notify("unable to inspect Git changes" .. (err and err ~= "" and ": " .. err or ""), vim.log.levels.ERROR)
    return
  end

  if not changed then
    notify(staged and "no staged changes to review" or "no changes to review", vim.log.levels.INFO)
    return
  end

  require("neogit.integrations.codediff").open(staged and "staged" or "worktree")
end

function M.open()
  open(false)
end

function M.open_staged()
  open(true)
end

function M.close()
  if vim.bo.buftype == "terminal" then
    vim.cmd("close")
    return
  end

  if vim.api.nvim_buf_get_name(0) ~= "" then
    vim.cmd("bdelete")
  end
end

function M.setup()
  vim.api.nvim_create_user_command("DiffFlowz", M.open, { desc = "Open inline Git review" })
  vim.api.nvim_create_user_command("DiffFlowzStaged", M.open_staged, { desc = "Open staged inline Git review" })
  vim.api.nvim_create_user_command("DiffFlowzClose", M.close, { desc = "Close DiffFlowz review" })
end

return M
