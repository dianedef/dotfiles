local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action
local userprofile = os.getenv 'USERPROFILE' or ''

local function basename(path)
	if not path or path == '' then
		return nil
	end
	return wezterm.basename(path)
end

local function pane_cwd(pane)
	local cwd = pane.current_working_dir
	if not cwd then
		return nil
	end
	return cwd.file_path or tostring(cwd)
end

-- Keep the former tmux information architecture: the active directory and
-- command name title each tab, while workspaces replace tmux sessions.
wezterm.on('format-tab-title', function(tab)
	local title = tab.tab_title
	if not title or title == '' then
		title = tab.active_pane.title
		local directory = basename(pane_cwd(tab.active_pane))
		if directory then
			title = directory .. ' · ' .. title
		end
	end
	return {
		{ Text = string.format(' %d  %s ', tab.tab_index + 1, title) },
	}
end)

wezterm.on('update-right-status', function(window, pane)
	local workspace = window:active_workspace()
	local directory = basename(pane_cwd(pane)) or 'home'
	window:set_right_status(string.format(' %s · %s · %s ', workspace, directory, wezterm.strftime '%d/%m %H:%M'))
end)

config.adjust_window_size_when_changing_font_size = false
config.color_scheme = 'Catppuccin Mocha'
config.font_size = 16.0
config.font = wezterm.font 'JetBrains Mono'
config.window_background_opacity = 1.0
config.window_decorations = 'RESIZE'
config.automatically_reload_config = true
config.harfbuzz_features = { 'calt=0' }
config.max_fps = 120
config.animation_fps = 120
config.front_end = 'WebGpu'
config.prefer_egl = true
config.enable_kitty_graphics = true
config.window_close_confirmation = 'NeverPrompt'
config.audible_bell = 'Disabled'
config.window_padding = { left = 2, right = 2, top = 15, bottom = 0 }
config.scrollback_lines = 2000000
config.term = 'xterm-256color'
config.enable_scroll_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.status_update_interval = 1000
config.leader = { key = 'w', mods = 'CTRL', timeout_milliseconds = 1000 }

-- PowerShell is a Windows default only. Linux and macOS keep their configured
-- login shell, so one WezTerm configuration remains portable.
if wezterm.target_triple:find 'windows' then
	config.default_prog = {
		'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe',
		'-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-NoExit', '-File',
		userprofile .. '\\.config\\shipglows\\profile.ps1',
	}
end

config.keys = {
	-- Direct shortcuts kept from the first native Windows configuration.
	{ key = '|', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{ key = '_', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
	{ key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
	{ key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
	{ key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
	{ key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },

	-- tmux compatibility: Ctrl+W, then the original tmux bindings.
	{ key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{ key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
	{ key = '"', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
	{ key = '%', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{ key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
	{ key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
	{ key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
	{ key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
	{ key = 'h', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
	{ key = 'j', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
	{ key = 'k', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
	{ key = 'l', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
	{ key = 'c', mods = 'LEADER', action = act.SpawnCommandInNewTab { cwd = wezterm.home_dir } },
	{ key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } },
	{
		key = 's', mods = 'LEADER',
		action = act.PromptInputLine {
			description = 'New or switch WezTerm workspace:',
			action = wezterm.action_callback(function(window, pane, line)
				if line and line ~= '' then
					window:perform_action(act.SwitchToWorkspace { name = line }, pane)
				end
			end),
		},
	},
	{
		key = ',', mods = 'LEADER',
		action = act.PromptInputLine {
			description = 'Name this tab:',
			action = wezterm.action_callback(function(window, _, line)
				if line and line ~= '' then
					window:active_tab():set_title(line)
				end
			end),
		},
	},
	-- Open a fresh Codex next to the current work; never destroy the active pane.
	{ key = 'r', mods = 'LEADER|SHIFT', action = act.SpawnCommandInNewPane { args = { 'co' }, direction = 'Right' } },
	{ key = 'w', mods = 'LEADER|CTRL', action = act.SendKey { key = 'w', mods = 'CTRL' } },
	{ key = 'q', mods = 'CTRL', action = act.ToggleFullScreen },
	{ key = '\\', mods = 'CTRL', action = act.ClearScrollback 'ScrollbackAndViewport' },
	{ key = 'LeftArrow', mods = 'OPT', action = act.SendString '\x1bb' },
	{ key = 'RightArrow', mods = 'OPT', action = act.SendString '\x1bf' },
}

config.mouse_bindings = {
	{ event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE', action = act.PasteFrom 'PrimarySelection' },
	{ event = { Up = { streak = 1, button = 'Left' } }, mods = 'NONE', action = act.CompleteSelection 'ClipboardAndPrimarySelection' },
	{ event = { Up = { streak = 1, button = 'Left' } }, mods = 'SUPER', action = act.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection' },
	{ event = { Down = { streak = 1, button = 'Left' } }, mods = 'SUPER', action = act.Nop },
}

config.send_composed_key_when_left_alt_is_pressed = true
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_ease_out = 'Constant'
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_rate = 0
config.colors = {
	foreground = '#E6E9F0', background = '#1E1E2E', cursor_bg = '#89B4FA', cursor_fg = '#11111B', cursor_border = '#F2CDCD', selection_fg = '#11111B', selection_bg = '#A6E3A1',
	ansi = { '#45475A', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#BAC2DE' },
	brights = { '#585B70', '#F38BA8', '#A6E3A1', '#F9E2AF', '#89B4FA', '#F5C2E7', '#94E2D5', '#FFFFFF' },
	-- tmux-inspired tab/status contrast.
	tab_bar = {
		background = '#000000',
		active_tab = { bg_color = '#F9E2AF', fg_color = '#11111B', intensity = 'Bold' },
		inactive_tab = { bg_color = '#3B3B50', fg_color = '#CDD6F4' },
		inactive_tab_hover = { bg_color = '#F5C2E7', fg_color = '#11111B' },
	},
}

return config
