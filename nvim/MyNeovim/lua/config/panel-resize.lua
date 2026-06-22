local M = {}

-- Store user-set sizes for terminal windows (keyed by buffer id)
-- Persists across window toggles and VimResized events
local terminal_size_overrides = {} -- buf_id -> { orientation, size }

-- Register a user-chosen size for a terminal buffer
local function set_terminal_override(buf, orientation, size)
  terminal_size_overrides[buf] = { orientation = orientation, size = size }
end

-- Get the user-chosen size for a terminal buffer (nil if none)
function M.get_terminal_size_override(buf)
  return terminal_size_overrides[buf]
end

-- Apply stored override to the window currently displaying a buffer
local function apply_terminal_override(buf, winid)
  local override = terminal_size_overrides[buf]
  if not override then
    return false
  end
  if override.orientation == "horizontal" then
    pcall(vim.api.nvim_win_set_height, winid, override.size)
  else
    pcall(vim.api.nvim_win_set_width, winid, override.size)
  end
  return true
end

-- Reapply stored size when a terminal window reappears (toggle / Tmux refocus)
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("panel_resize_terminal_persist", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= "snacks_terminal" then
      return
    end
    local winid = vim.fn.bufwinid(ev.buf)
    if winid ~= -1 then
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(winid) then
          apply_terminal_override(ev.buf, winid)
        end
      end)
    end
  end,
})

-- Cleanup when a terminal buffer is deleted
vim.api.nvim_create_autocmd("BufDelete", {
  group = vim.api.nvim_create_augroup("panel_resize_terminal_cleanup", { clear = true }),
  callback = function(ev)
    terminal_size_overrides[ev.buf] = nil
  end,
})

M.presets = {
  explorer = { 20, 35, 50 },
  vertical = { 30, 45, 60 },
  horizontal = { 15, 20, 30 },
  avante = {
    [1] = { vertical = 30, horizontal = 15 },
    [2] = { vertical = 45, horizontal = 20 },
    [3] = { vertical = 60, horizontal = 30 },
  },
}

local AVANTE_FILETYPES = {
  Avante = true,
  AvanteInput = true,
}

local function notify(message, opts)
  opts = opts or {}
  if opts.notify ~= false then
    vim.notify(message, vim.log.levels.INFO)
  end
end

local function normalize_preset(preset)
  if preset == "full" or preset == "Full" or preset == "FULL" then
    return "full"
  end

  local value = tonumber(preset)
  if not value then
    return nil
  end

  value = math.floor(value)
  if value < 1 or value > 3 then
    return nil
  end

  return value
end

local function clamp(value, min_value, max_value)
  return math.max(min_value, math.min(max_value, value))
end

local function is_floating_window(winid)
  local cfg = vim.api.nvim_win_get_config(winid)
  return cfg and cfg.relative and cfg.relative ~= ""
end

local function current_window_orientation(winid)
  local function find_parent_layout(node, target, parent_type)
    local node_type = node[1]
    local payload = node[2]

    if node_type == "leaf" then
      if payload == target then
        return parent_type
      end
      return nil
    end

    if type(payload) ~= "table" then
      return nil
    end

    for _, child in ipairs(payload) do
      local found = find_parent_layout(child, target, node_type)
      if found then
        return found
      end
    end
  end

  if not is_floating_window(winid) then
    local layout_type = find_parent_layout(vim.fn.winlayout(), winid, nil)
    if layout_type == "col" then
      return "horizontal"
    end
    if layout_type == "row" then
      return "vertical"
    end
  end

  local width = vim.api.nvim_win_get_width(winid)
  local height = vim.api.nvim_win_get_height(winid)
  local screen_width = math.max(1, vim.o.columns)
  local screen_height = math.max(1, vim.o.lines - vim.o.cmdheight - 2)

  if height <= math.floor(screen_height * 0.55) and width >= math.floor(screen_width * 0.55) then
    return "horizontal"
  end

  return "vertical"
end

local function resize_current_window_dimension(winid, orientation, size)
  if is_floating_window(winid) then
    local cfg = vim.api.nvim_win_get_config(winid)
    if orientation == "horizontal" then
      cfg.height = size
    else
      cfg.width = size
    end
    return pcall(vim.api.nvim_win_set_config, winid, cfg)
  end

  if orientation == "horizontal" then
    return pcall(vim.api.nvim_win_set_height, winid, size)
  end

  return pcall(vim.api.nvim_win_set_width, winid, size)
end

local function current_snacks_explorer_picker()
  local ok, picker = pcall(require, "snacks.picker.core.picker")
  if not ok or type(picker.get) ~= "function" then
    return nil
  end

  local current = vim.api.nvim_get_current_win()
  for _, active_picker in ipairs(picker.get({ source = "explorer", tab = true })) do
    local layout = active_picker and active_picker.layout
    local wins = layout and layout.wins or {}
    for _, win in pairs(wins) do
      if win and win.win == current then
        return active_picker
      end
    end

    local root = layout and layout.root
    if root and root.win == current then
      return active_picker
    end
  end
end

local function is_current_explorer()
  local ft = vim.bo.filetype
  return ft == "neo-tree" or current_snacks_explorer_picker() ~= nil
end

local function is_current_avante()
  if AVANTE_FILETYPES[vim.bo.filetype] then
    return true
  end

  local ok, avante = pcall(require, "avante")
  if not ok or type(avante.get) ~= "function" then
    return false
  end

  local sidebar = avante.get()
  if not sidebar or type(sidebar.is_open) ~= "function" or not sidebar:is_open() then
    return false
  end

  local current = vim.api.nvim_get_current_win()
  for _, container in pairs(sidebar.containers or {}) do
    if container and container.winid == current then
      return true
    end
  end

  return false
end

function M.explorer_preset(preset, opts)
  local normalized = normalize_preset(preset)
  if not normalized then
    vim.notify("Preset panneau invalide: " .. tostring(preset), vim.log.levels.WARN)
    return false
  end

  local width = normalized == "full" and "full" or M.presets.explorer[normalized]
  require("config.explorer-panel").set_width(width, opts)
  return true
end

function M.avante_size(size, opts)
  opts = opts or {}

  local ok_avante, avante = pcall(require, "avante")
  local ok_config, Config = pcall(require, "avante.config")
  if not ok_avante or not ok_config then
    return false
  end

  local sidebar = avante.get()
  local position = Config.windows and Config.windows.position or "right"
  local layout = vim.tbl_contains({ "top", "bottom" }, position) and "horizontal" or "vertical"
  if sidebar and type(sidebar.get_layout) == "function" then
    layout = sidebar:get_layout()
  end

  local width = size == "full" and 100 or tonumber(size)
  local height = width
  if type(size) == "table" then
    width = tonumber(size.vertical)
    height = tonumber(size.horizontal)
  end

  if not width or not height then
    return false
  end

  width = clamp(math.floor(width), 1, 100)
  height = clamp(math.floor(height), 1, 100)
  Config.override({ windows = { width = width, height = height } })

  if sidebar and type(sidebar.is_open) == "function" and sidebar:is_open() then
    if size == "full" then
      if not sidebar.is_in_full_view and type(sidebar.toggle_code_window) == "function" then
        sidebar:toggle_code_window()
      end
    else
      if sidebar.is_in_full_view and type(sidebar.toggle_code_window) == "function" then
        sidebar:toggle_code_window()
      end
      if type(sidebar.adjust_result_container_layout) == "function" then
        sidebar:adjust_result_container_layout()
      end
      if type(sidebar.render_input) == "function" then
        pcall(function()
          sidebar:render_input()
        end)
      end
      if type(sidebar.render_selected_code) == "function" then
        pcall(function()
          sidebar:render_selected_code()
        end)
      end
    end
  end

  return true
end

function M.avante_preset(preset, opts)
  local normalized = normalize_preset(preset)
  if not normalized then
    vim.notify("Preset Avante invalide: " .. tostring(preset), vim.log.levels.WARN)
    return false
  end

  local size = normalized == "full" and "full" or M.presets.avante[normalized]
  return M.avante_size(size, opts)
end

function M.current_window_preset(preset, opts)
  opts = opts or {}

  local normalized = normalize_preset(preset)
  if not normalized then
    vim.notify("Preset panneau invalide: " .. tostring(preset), vim.log.levels.WARN)
    return false
  end

  local winid = vim.api.nvim_get_current_win()
  local orientation = current_window_orientation(winid)

  if orientation == "horizontal" then
    local max_height = math.max(1, vim.o.lines - vim.o.cmdheight - 2)
    local height = normalized == "full" and max_height or M.presets.horizontal[normalized]
    height = clamp(height, 1, max_height)
    resize_current_window_dimension(winid, orientation, height)
    -- Persist for terminal windows so VimResized / toggles don't override
    local buf = vim.api.nvim_win_get_buf(winid)
    if vim.bo[buf].filetype == "snacks_terminal" then
      set_terminal_override(buf, orientation, height)
    end
    return true
  end

  local max_width = math.max(1, vim.o.columns)
  local width = normalized == "full" and max_width or M.presets.vertical[normalized]
  width = clamp(width, 1, max_width)
  resize_current_window_dimension(winid, orientation, width)
  -- Persist for terminal windows so VimResized / toggles don't override
  local buf = vim.api.nvim_win_get_buf(winid)
  if vim.bo[buf].filetype == "snacks_terminal" then
    set_terminal_override(buf, orientation, width)
  end
  return true
end

function M.preset(preset, opts)
  opts = opts or {}

  if opts.target == "explorer" or (not opts.target and is_current_explorer()) then
    return M.explorer_preset(preset, opts)
  end

  if opts.target == "avante" or (not opts.target and is_current_avante()) then
    return M.avante_preset(preset, opts)
  end

  return M.current_window_preset(preset, opts)
end

function M.full(opts)
  return M.preset("full", opts)
end

return M
