local wezterm = require('wezterm')

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Colors: load from colors/*.lua next to this config (single source of truth)
local colors_dir = wezterm.config_dir .. "/colors"
config.color_schemes = {
	["cyberdream"] = dofile(colors_dir .. "/cyberdream.lua"),
	["cyberdream-light"] = dofile(colors_dir .. "/cyberdream-light.lua"),
}
config.color_scheme = "cyberdream"

-- Sync color scheme to macOS system appearance (light/dark)
local dark_scheme = "cyberdream"
local light_scheme = "cyberdream-light"
local function scheme_for_appearance(appearance)
	if appearance and appearance:find("Dark") then
		return dark_scheme
	end
	return light_scheme
end
wezterm.on("window-config-reloaded", function(window, _pane)
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

-- Toggle light/dark manually (Cmd+Shift+T); next system theme change will sync again
wezterm.on("toggle-color-scheme", function(window, _pane)
	local overrides = window:get_config_overrides() or {}
	local current = overrides.color_scheme or config.color_scheme
	overrides.color_scheme = (current == light_scheme) and dark_scheme or light_scheme
	window:set_config_overrides(overrides)
end)

-- Font
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15
config.window_frame = { font = wezterm.font('JetBrainsMono Nerd Font') }

-- Window
config.initial_cols = 90
config.initial_rows = 30
config.window_padding = { left = 15, right = 15, top = 15, bottom = 15 }
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.95
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Launch nushell as interactive shell (zsh remains the login/POSIX shell)
config.default_prog = { "/opt/homebrew/bin/nu" }

-- Ensure Nushell uses ~/.config (so it loads ~/.config/nushell; on macOS nu otherwise uses ~/Library/Application Support/nushell)
-- and Yazi/tools get usable PATH + WezTerm detection
local path = os.getenv("PATH") or "/usr/bin:/bin:/usr/sbin:/sbin"
local env = {
	TERM_PROGRAM = "WezTerm",
	PATH = "/opt/homebrew/bin:" .. path,
}
local home = os.getenv("HOME")
if home and home ~= "" then
	env.XDG_CONFIG_HOME = home .. "/.config"
end
config.set_environment_variables = env

-- Cursor: start like Neovim Insert (beam). Nushell vi mode flips to block in normal.
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 800

-- Key bindings: separate scrolling from cursor movement, add pane/tab management
config.keys = {
  -- ==================
  -- Scrolling
  -- ==================
  -- Scroll up/down with Cmd+Arrow keys
  { key = "UpArrow", mods = "CMD", action = wezterm.action.ScrollByLine(-1) },
  { key = "DownArrow", mods = "CMD", action = wezterm.action.ScrollByLine(1) },
  { key = "LeftArrow", mods = "CMD", action = wezterm.action.ScrollByPage(-1) },
  { key = "RightArrow", mods = "CMD", action = wezterm.action.ScrollByPage(1) },
  { key = "PageUp", mods = "CMD", action = wezterm.action.ScrollByPage(-1) },
  { key = "PageDown", mods = "CMD", action = wezterm.action.ScrollByPage(1) },
  
  -- Scroll up/down with Cmd+Shift+Arrow keys (half page)
  { key = "UpArrow", mods = "CMD|SHIFT", action = wezterm.action.ScrollByLine(-10) },
  { key = "DownArrow", mods = "CMD|SHIFT", action = wezterm.action.ScrollByLine(10) },
  { key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.ScrollByLine(-15) },
  { key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.ScrollByLine(15) },
  
  -- Disable default scroll behavior for arrow keys (let shell handle them)
  { key = "UpArrow", mods = "NONE", action = wezterm.action.SendString("\x1b[A") },
  { key = "DownArrow", mods = "NONE", action = wezterm.action.SendString("\x1b[B") },
  { key = "RightArrow", mods = "NONE", action = wezterm.action.SendString("\x1b[C") },
  { key = "LeftArrow", mods = "NONE", action = wezterm.action.SendString("\x1b[D") },

  -- ==================
  -- Tab Management
  -- ==================
  -- Create new tab
  { key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  -- Close current tab
  { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
  -- Navigate tabs
  { key = "[", mods = "CMD", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "]", mods = "CMD", action = wezterm.action.ActivateTabRelative(1) },
  { key = "1", mods = "CMD", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CMD", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CMD", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CMD", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CMD", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "CMD", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "CMD", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "CMD", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "CMD", action = wezterm.action.ActivateTab(8) },

  -- ==================
  -- Pane Management
  -- ==================
  -- Split panes
  { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "D", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  -- Close current pane
  { key = "x", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  -- Navigate panes with vim-style hjkl
  { key = "h", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Right") },
  -- Resize panes
  { key = "H", mods = "CMD|CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "CMD|CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "CMD|CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "CMD|CTRL|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
  -- Toggle pane zoom
  { key = "z", mods = "CMD", action = wezterm.action.TogglePaneZoomState },

  -- ==================
  -- Other
  -- ==================
  -- Toggle light/dark color scheme
  { key = "t", mods = "CMD|SHIFT", action = wezterm.action.EmitEvent("toggle-color-scheme") },
  -- Command palette
  { key = "p", mods = "CMD|SHIFT", action = wezterm.action.ActivateCommandPalette },
  -- Copy/Paste (ensure they work)
  { key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
  { key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
  -- Clear scrollback
  { key = "k", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },
  -- Search mode
  { key = "f", mods = "CMD", action = wezterm.action.Search({ CaseSensitiveString = "" }) },
  -- Reload configuration
  { key = "r", mods = "CMD|SHIFT", action = wezterm.action.ReloadConfiguration },
}

return config
