local M = {}

local function search_headings(levels, backward)
  local wanted = {}
  for _, level in ipairs(levels) do
    wanted[level] = true
  end

  local pattern_parts = {}
  for level in pairs(wanted) do
    table.insert(pattern_parts, "^" .. string.rep("#", level) .. "\\s")
  end
  table.sort(pattern_parts)

  local flags = backward and "bW" or "W"
  local count = vim.v.count > 0 and vim.v.count or 1
  local found = 0

  for _ = 1, count do
    found = vim.fn.search(table.concat(pattern_parts, "\\|"), flags)
    if found == 0 then
      break
    end
  end

  if found == 0 then
    local direction = backward and "précédent" or "suivant"
    vim.notify("Aucun titre Markdown " .. direction)
  end
end

function M.search_headings(levels, backward)
  search_headings(levels, backward)
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(ev)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc, noremap = true, silent = true, buffer = ev.buf })
      end

      map("x", "n", function()
        search_headings({ 2, 3 })
      end, "Next heading H2/H3")

      map("x", "p", function()
        search_headings({ 2, 3 }, true)
      end, "Previous heading H2/H3")

      map("x", "]h", function()
        search_headings({ 2, 3 })
      end, "Next heading H2/H3")

      map("x", "[h", function()
        search_headings({ 2, 3 }, true)
      end, "Previous heading H2/H3")
    end,
  })
end

return M
