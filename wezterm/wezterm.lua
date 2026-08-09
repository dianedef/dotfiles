local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local userprofile = os.getenv 'USERPROFILE' or ''

-- Couleurs de base
return {
	adjust_window_size_when_changing_font_size = false,
	color_scheme = 'Catppuccin Mocha',
	enable_tab_bar = false,
	font_size = 16.0,
	font = wezterm.font('JetBrains Mono'),
	-- Windows default: ShipGlows' native DevServer and shortcuts use PowerShell.
	default_prog = {
		'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe',
		'-NoLogo',
		'-NoProfile',
		'-ExecutionPolicy',
		'Bypass',
		'-NoExit',
		'-File',
		userprofile .. '\\.config\\shipglows\\profile.ps1',
	},

	window_background_opacity = 1.0,
	window_decorations = 'RESIZE',
	automatically_reload_config = true,
	harfbuzz_features = { "calt=0" },
	max_fps = 120,
	animation_fps = 120,
	front_end = "WebGpu",
	prefer_egl = true,
	enable_kitty_graphics = true,
	window_close_confirmation = "NeverPrompt",
	audible_bell = "Disabled",
	window_padding = {
		left = 2,
		right = 2,
		top = 15,
		bottom = 0,
	},

	-- Native Windows sessions use WezTerm panes instead of tmux.
	scrollback_lines = 10000,

	-- TERM: xterm-256color is safe over SSH, avoids terminfo issues
	term = "xterm-256color",

	-- Enable mouse reporting passthrough to tmux
	enable_scroll_bar = false,

	keys = {
		{
			key = '|',
			mods = 'CTRL|SHIFT',
			action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
		},
		{
			key = '_',
			mods = 'CTRL|SHIFT',
			action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
		},
		{ key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
		{ key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
		{ key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
		{ key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
		{
			key = 'q',
			mods = 'CTRL',
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = '\'',
			mods = 'CTRL',
			action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
		},
		{
			key = "LeftArrow",
			mods = "OPT",
			action = wezterm.action({ SendString = "\x1bb" }),
		},
		{
			key = "RightArrow",
			mods = "OPT",
			action = wezterm.action({ SendString = "\x1bf" }),
		},
	},
	mouse_bindings = {
		-- Coller avec le clic droit
		{
			event = { Down = { streak = 1, button = "Right" } },
			mods = "NONE",
			action = wezterm.action.PasteFrom("PrimarySelection"),
		},

		-- Sélectionner le texte sans ouvrir les liens
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "NONE",
			action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection"),
		},

		-- SUPER+Clic pour ouvrir les liens
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "SUPER",
			action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
		},

		-- Désactivation du Down de SUPER+Clic
		{
			event = { Down = { streak = 1, button = "Left" } },
			mods = "SUPER",
			action = wezterm.action.Nop,
		},
	},
	send_composed_key_when_left_alt_is_pressed = true,
	default_cursor_style = "SteadyBlock",
	cursor_blink_ease_out = "Constant",
	cursor_blink_ease_in = "Constant",
	cursor_blink_rate = 0,
	colors = {
		-- High contrast palette for readable PowerShell + gum menus on Windows/Shadow.
		foreground = "#E6E9F0",
		background = "#1E1E2E",
		cursor_bg = "#89B4FA",
		cursor_fg = "#11111B",
		cursor_border = "#F2CDCD",
		selection_fg = "#11111B",
		selection_bg = "#A6E3A1",
		ansi = {
			"#45475A",
			"#F38BA8",
			"#A6E3A1",
			"#F9E2AF",
			"#89B4FA",
			"#F5C2E7",
			"#94E2D5",
			"#BAC2DE",
		},
		brights = {
			"#585B70",
			"#F38BA8",
			"#A6E3A1",
			"#F9E2AF",
			"#89B4FA",
			"#F5C2E7",
			"#94E2D5",
			"#FFFFFF",
		},
	},
}
