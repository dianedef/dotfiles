local M = {}

function M.copy(text)
  text = tostring(text or "")
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)

  if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
    local b64 = vim.base64.encode(text)
    io.stdout:write(string.format("\027]52;c;%s\027\\", b64))
    io.stdout:flush()
  end

  local cache_dir = vim.fn.stdpath("cache")
  vim.fn.mkdir(cache_dir, "p")
  local fallback_path = vim.fs.joinpath(cache_dir, "shipglows-notifications.txt")
  vim.fn.writefile(vim.split(text, "\n", { plain = true }), fallback_path)

  return { fallback_path = fallback_path }
end

return M
