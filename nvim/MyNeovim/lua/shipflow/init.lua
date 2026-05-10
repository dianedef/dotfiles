-- ShipFlow Plugin for NeoVim
-- This plugin allows navigation between Markdown headers using customizable shortcuts.

local M = {}

-- Function to search for headers of a specific level
local function search_header(level)
  local header_pattern = "^" .. string.rep("#", level) .. " "
  local search_cmd = "/" .. header_pattern
  vim.cmd(search_cmd)
end

local function set_explorer_width(width)
  require("config.explorer-panel").set_width(width, { notify = false })
end

-- Mappings for navigating between headers
M.setup = function()
  vim.keymap.set("n", "<leader>h1", function()
    M.search_header(1)
  end, { desc = "Markdown H1", noremap = true, silent = true })
  vim.keymap.set("n", "<leader>h2", function()
    M.search_header(2)
  end, { desc = "Markdown H2", noremap = true, silent = true })
  vim.keymap.set("n", "<leader>h3", function()
    M.search_header(3)
  end, { desc = "Markdown H3", noremap = true, silent = true })

  vim.api.nvim_create_user_command("ShipFlowExplorerWidth20", function()
    set_explorer_width(20)
  end, { desc = "Set explorer panel width to 20", force = true })

  vim.api.nvim_create_user_command("ShipFlowExplorerWidth35", function()
    set_explorer_width(35)
  end, { desc = "Set explorer panel width to 35", force = true })

  vim.api.nvim_create_user_command("ShipFlowExplorerWidthFull", function()
    set_explorer_width("full")
  end, { desc = "Set explorer panel width to full screen", force = true })

  vim.keymap.set("n", "<leader>e2", "<cmd>ShipFlowExplorerWidth20<cr>", { desc = "Explorer width 20" })
  vim.keymap.set("n", "<leader>e3", "<cmd>ShipFlowExplorerWidth35<cr>", { desc = "Explorer width 35" })
  vim.keymap.set("n", "<leader>eF", "<cmd>ShipFlowExplorerWidthFull<cr>", { desc = "Explorer full width" })
end

-- Function to navigate to a header
function M.search_header(level)
  search_header(level)
end

return M
