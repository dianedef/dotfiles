-- ShipFlow Plugin for NeoVim
-- This plugin allows navigation between Markdown headers using customizable shortcuts.

local M = {}

local function search_headings(levels, backward)
  local sorted_levels = {}
  for _, level in ipairs(levels) do
    sorted_levels[level] = true
  end

  local pattern_parts = {}
  for level in pairs(sorted_levels) do
    table.insert(pattern_parts, "^" .. string.rep("#", level) .. "\\s")
  end
  table.sort(pattern_parts)
  local pattern = table.concat(pattern_parts, "\\|")

  local flags = "W"
  if backward then
    flags = "bW"
  end

  local count = vim.v.count > 0 and vim.v.count or 1
  local found = 0
  for _ = 1, count do
    found = vim.fn.search(pattern, flags)
    if found == 0 then
      break
    end
  end

  if found == 0 then
    local label = table.concat(levels, ",")
    local direction = backward and "précédent" or "suivant"
    local plural = (count > 1) and "s" or ""
    vim.notify("Aucun titre H" .. label .. " " .. direction .. " (x" .. count .. ")" .. plural)
  end
end

function M.search_headings(levels, backward)
  search_headings(levels, backward)
end

local function set_explorer_width(width)
  require("config.explorer-panel").set_width(width, { notify = false })
end

-- Mappings for navigating between headers
M.setup = function()
  local heading_modes = { "x" }
  local function setup_heading_keymaps(buf)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc, noremap = true, silent = true, buffer = buf })
    end

    map("x", "n", function()
      search_headings({ 2, 3 })
    end, "Next heading H2/H3")

    map("x", "p", function()
      search_headings({ 2, 3 }, true)
    end, "Previous heading H2/H3")

    map(heading_modes, "]h", function()
      search_headings({ 2, 3 })
    end, "Next heading H2/H3")

    map(heading_modes, "[h", function()
      search_headings({ 2, 3 }, true)
    end, "Previous heading H2/H3")
  end

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(ev)
      setup_heading_keymaps(ev.buf)
    end,
  })

  vim.api.nvim_create_user_command("ShipFlowExplorerWidth20", function()
    set_explorer_width(20)
  end, { desc = "Set width 20", force = true })

  vim.api.nvim_create_user_command("ShipFlowExplorerWidth35", function()
    set_explorer_width(35)
  end, { desc = "Set width 35", force = true })

  vim.api.nvim_create_user_command("ShipFlowExplorerWidthFull", function()
    set_explorer_width("full")
  end, { desc = "Set width full", force = true })

  vim.keymap.set("n", "<leader>e2", "<cmd>ShipFlowExplorerWidth20<cr>", { desc = "width 20" })
  vim.keymap.set("n", "<leader>e3", "<cmd>ShipFlowExplorerWidth35<cr>", { desc = "width 35" })
  vim.keymap.set("n", "<leader>eF", "<cmd>ShipFlowExplorerWidthFull<cr>", { desc = "width full" })

  require("shipflow.mail").setup()
end

return M
