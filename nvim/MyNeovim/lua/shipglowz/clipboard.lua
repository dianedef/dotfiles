local M = {}

function M.copy(text)
  text = tostring(text or "")
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)

  local b64 = vim.base64.encode(text)
  io.stdout:write(string.format("\027]52;c;%s\027\\", b64))
  io.stdout:flush()

  local file = io.open("/tmp/nvim_notif.txt", "w")
  if file then
    file:write(text)
    file:close()
  end
end

return M
