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
