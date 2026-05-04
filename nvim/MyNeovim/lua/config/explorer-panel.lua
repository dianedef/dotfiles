local M = {}

M.width = 37

function M.snacks_layout()
  return {
    preset = "sidebar",
    preview = false,
    layout = {
      width = M.width,
      min_width = M.width,
    },
  }
end

function M.resize(winid)
  if winid and vim.api.nvim_win_is_valid(winid) then
    pcall(vim.api.nvim_win_set_width, winid, M.width)
  end
end

return M
