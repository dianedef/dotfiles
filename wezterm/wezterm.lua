local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Couleurs de base
local c = {
	fg = "#FFFFFF",
	bg = "#000000",
	colour0 = "#000000",
	colour1 = "#D90404",
	colour2 = "#29CC00",
	colour3 = "#E5E600",
	colour4 = "#0066FF",
	colour5 = "#CC00FF",
	colour6 = "#1793D1",
	colour7 = "#D0D0D0",
	colour8 = "#808080",
	colour9 = "#FE0100",
	colour10 = "#33FF00",
	colour11 = "#FEFF00",
	colour12 = "#1A76FF",
	colour13 = "#FF00FF",
	colour14 = "#00FFFF",
	colour15 = "#FFFFFF",
}

return {
	adjust_window_size_when_changing_font_size = false,
	color_scheme = 'Catppuccin Mocha',
	enable_tab_bar = false,
	font_size = 16.0,
	font = wezterm.font('JetBrains Mono'),
	-- Windows default: ShipGlows' native DevServer and shortcuts use PowerShell.
	default_prog = {
		'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe',
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

	-- Scrollback: 0 = let tmux own all scrollback
	-- Fixes: "other panes content bleeding in" when scrolling
	scrollback_lines = 0,

	-- TERM: xterm-256color is safe over SSH, avoids terminfo issues
	term = "xterm-256color",

	-- Enable mouse reporting passthrough to tmux
	enable_scroll_bar = false,

	keys = {
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
		foreground = c.fg,
		background = c.bg,
		cursor_bg = c.fg,
		cursor_fg = c.bg,
		cursor_border = c.colour13,
		selection_fg = c.fg,
		selection_bg = c.colour13,
		scrollbar_thumb = c.colour8,
		split = c.colour7,

		ansi = {
			c.colour0, c.colour1, c.colour2, c.colour3,
			c.colour4, c.colour5, c.colour6, c.colour7,
		},

		brights = {
			c.colour8, c.colour9, c.colour10, c.colour11,
			c.colour12, c.colour13, c.colour14, c.colour15,
		},

		compose_cursor = c.colour3,

		copy_mode_active_highlight_bg = { Color = c.bg },
		copy_mode_active_highlight_fg = { AnsiColor = "Black" },
		copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
		copy_mode_inactive_highlight_fg = { AnsiColor = "White" },
		quick_select_label_bg = { Color = "peru" },
		quick_select_label_fg = { Color = "#ffffff" },
		quick_select_match_bg = { AnsiColor = "Navy" },
		quick_select_match_fg = { Color = "#ffffff" },
	},
}
