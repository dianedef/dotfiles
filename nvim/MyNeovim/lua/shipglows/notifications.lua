local M = {}

local function render(value)
  if type(value) == "table" then
    return table.concat(vim.tbl_map(tostring, value), "\n")
  end
  return tostring(value or "")
end

local function noice_messages()
  local ok, manager = pcall(require, "noice.message.manager")
  if not ok then return {} end

  local messages = manager.get({}, { history = true }) or {}
  local result = {}
  for _, message in ipairs(messages) do
    local text = message:content()
    if text and text ~= "" then result[#result + 1] = text end
  end
  return result
end

local function notify_messages()
  local ok, notify = pcall(require, "notify")
  if not ok or type(notify.history) ~= "function" then return {} end

  local result = {}
  for _, entry in ipairs(notify.history() or {}) do
    local title = render(entry.title)
    local message = render(entry.message)
    if message ~= "" then
      result[#result + 1] = title ~= "" and (title .. ": " .. message) or message
    end
  end
  return result
end

function M.latest()
  local notifications = notify_messages()
  if #notifications > 0 then return notifications[#notifications] end

  local messages = noice_messages()
  return messages[#messages]
end

function M.report()
  local sections = {}
  local notifications = notify_messages()
  local messages = noice_messages()

  if #notifications > 0 then
    sections[#sections + 1] = "# Notifications\n\n" .. table.concat(notifications, "\n\n")
  end
  if #messages > 0 then
    sections[#sections + 1] = "# Messages Neovim\n\n" .. table.concat(messages, "\n\n")
  end

  return table.concat(sections, "\n\n"), #notifications + #messages
end

return M
