local wezterm = require('wezterm')

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Color scheme
--config.color_scheme = 'Tokyo Night'
config.colors = require("cyberdream")

-- Font configuration
config.font = wezterm.font("JetBrains Mono")
config.font_size = 15  -- Base font size
config.window_frame = {
  font = wezterm.font('JetBrains Mono'),
}

-- Window scaling
config.initial_cols = 90
config.initial_rows = 30
config.window_padding = {
  left = 15, 
  right = 15,
  top = 15,
  bottom = 15,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.95

-- Better unicode support
--config.term = 'wezterm'
--config.enable_kitty_graphics = true

-- Smart tab handling
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Key bindings
config.keys = {
  -- Add your custom key bindings here
}

return config
