local wezterm = require('wezterm')

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Colors
-- config.color_scheme = 'Tokyo Night'
config.colors = require("cyberdream")

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

-- Cursor: start like Neovim Insert (beam). zsh will flip to block in vicmd.
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 800

-- Key bindings: separate scrolling from cursor movement
config.keys = {
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
}

return config
