-- ShipFlow Plugin for NeoVim
-- This plugin allows navigation between Markdown headers using customizable shortcuts.

local M = {}

-- Function to search for headers of a specific level
local function search_header(level)
    local header_pattern = '^' .. string.rep('#', level) .. ' '
    local search_cmd = "/" .. header_pattern
    vim.cmd(search_cmd)
end

-- Mappings for navigating between headers
M.setup = function()
    vim.api.nvim_set_keymap('n', '<leader>h1', ":lua require'shipflow'.search_header(1)<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>h2', ":lua require'shipflow'.search_header(2)<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>h3', ":lua require'shipflow'.search_header(3)<CR>", { noremap = true, silent = true })
end

-- Function to navigate to a header
function M.search_header(level)
    search_header(level)
end

return M
