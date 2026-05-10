local M = {}

M.width = 37

local function normalize_width(width)
  if width == "full" then
    return math.max(1, vim.o.columns)
  end

  local value = tonumber(width or M.width) or M.width
  return math.max(1, math.floor(value))
end

function M.snacks_layout(width)
  local panel_width = normalize_width(width)

  return {
    preset = "sidebar",
    preview = false,
    layout = {
      width = panel_width,
      min_width = panel_width,
    },
  }
end

function M.resize(winid, width)
  if winid and vim.api.nvim_win_is_valid(winid) then
    pcall(vim.api.nvim_win_set_width, winid, normalize_width(width))
  end
end

local function resize_neotree_windows(width)
  local resized = false

  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(winid)
    if vim.bo[buf].filetype == "neo-tree" then
      M.resize(winid, width)
      resized = true
    end
  end

  return resized
end

local function resize_snacks_explorers(width)
  local ok, picker = pcall(require, "snacks.picker.core.picker")
  if not ok or type(picker.get) ~= "function" then
    return false
  end

  local resized = false
  for _, active_picker in ipairs(picker.get({ source = "explorer", tab = true })) do
    if active_picker and type(active_picker.set_layout) == "function" then
      pcall(function()
        active_picker:set_layout(M.snacks_layout(width))
      end)
      resized = true
    end
  end

  return resized
end

function M.set_width(width, opts)
  opts = opts or {}
  M.width = normalize_width(width)

  local resized = resize_neotree_windows(M.width)
  resized = resize_snacks_explorers(M.width) or resized

  if opts.notify ~= false then
    local suffix = resized and "" or " (applique au prochain explorateur ouvert)"
    vim.notify(("Largeur explorateur: %d%s"):format(M.width, suffix), vim.log.levels.INFO)
  end

  return M.width
end

function M.set_full_width(opts)
  return M.set_width("full", opts)
end

return M
