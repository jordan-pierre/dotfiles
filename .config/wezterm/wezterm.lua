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

-- Tab bar colors: active tab stands out in both light and dark mode
local function tab_bar_colors_for_scheme(scheme_name)
	local scheme = (scheme_name == "cyberdream-light")
		and dofile(colors_dir .. "/cyberdream-light.lua")
		or dofile(colors_dir .. "/cyberdream.lua")
	-- Use selection_bg for active tab so it's clearly distinct from inactive tabs
	local active_bg = scheme.selection_bg or scheme.background
	return {
		background = scheme.background,
		active_tab = { bg_color = active_bg, fg_color = scheme.foreground },
		inactive_tab = { bg_color = scheme.background, fg_color = scheme.foreground },
		inactive_tab_hover = { bg_color = active_bg, fg_color = scheme.foreground },
		new_tab = { bg_color = scheme.background, fg_color = scheme.foreground },
	}
end
config.colors = { tab_bar = tab_bar_colors_for_scheme("cyberdream") }

-- Sync color scheme to macOS system appearance (light/dark)
local dark_scheme = "cyberdream"
local light_scheme = "cyberdream-light"
local function scheme_for_appearance(appearance)
	if appearance and appearance:find("Dark") then
		return dark_scheme
	end
	return light_scheme
end

-- Sync Claude Code theme to match appearance
local claude_theme_path = wezterm.home_dir .. '/.claude/themes/cyberdream-auto.json'
local claude_theme_dark = '{"name":"Cyberdream Auto","base":"dark","overrides":{"claude":"#bd5eff","text":"#ffffff","inverseText":"#1a1625","inactive":"#3c4048","subtle":"#3c4048","suggestion":"#3c4048","permission":"#5ea1ff","remember":"#f1ff5e","promptBorder":"#5ea1ff","planMode":"#5ea1ff","autoAccept":"#5eff6c","bashBorder":"#f1ff5e","ide":"#5ef1ff","fastMode":"#bd5eff","success":"#5eff6c","error":"#ff6e5e","warning":"#f1ff5e","merged":"#bd5eff","diffAdded":"#1a3020","diffRemoved":"#3a1a1a","diffAddedDimmed":"#151e15","diffRemovedDimmed":"#271515","diffAddedWord":"#2a5030","diffRemovedWord":"#5a2020","userMessageBackground":"#221930","userMessageBackgroundHover":"#2a2040","messageActionsBackground":"#2a2040","bashMessageBackgroundColor":"#1e1c12","memoryBackgroundColor":"#1e1c12","selectionBg":"#3c4048","briefLabelYou":"#5ea1ff","briefLabelClaude":"#bd5eff","rate_limit_fill":"#bd5eff","rate_limit_empty":"#3c4048"}}\n'
local claude_theme_light = '{"name":"Cyberdream Auto","base":"light","overrides":{"claude":"#a018ff","text":"#16181a","inverseText":"#ffffff","inactive":"#7b8496","subtle":"#7b8496","suggestion":"#7b8496","permission":"#0057d1","remember":"#997b00","promptBorder":"#0057d1","planMode":"#0057d1","autoAccept":"#008b0c","bashBorder":"#997b00","ide":"#008c99","fastMode":"#a018ff","success":"#008b0c","error":"#d11500","warning":"#997b00","merged":"#a018ff","diffAdded":"#d4f0da","diffRemoved":"#f0d4d4","diffAddedDimmed":"#e8f5eb","diffRemovedDimmed":"#f5e8e8","diffAddedWord":"#a8ddb5","diffRemovedWord":"#dba8a8","userMessageBackground":"#f0eaf8","userMessageBackgroundHover":"#e8e0f5","messageActionsBackground":"#e8e0f5","bashMessageBackgroundColor":"#f5f3e8","memoryBackgroundColor":"#f5f3e8","selectionBg":"#acacac","briefLabelYou":"#0057d1","briefLabelClaude":"#a018ff","rate_limit_fill":"#a018ff","rate_limit_empty":"#acacac"}}\n'
local function sync_claude_theme(appearance)
	local content = (appearance and appearance:find('Dark')) and claude_theme_dark or claude_theme_light
	local f = io.open(claude_theme_path, 'r')
	if f then
		local current = f:read('*a')
		f:close()
		if current == content then return end
	end
	local out = io.open(claude_theme_path, 'w')
	if out then
		out:write(content)
		out:close()
	end
end

local function inactive_hsb_for_appearance(appearance)
	if appearance and appearance:find("Dark") then
		return { brightness = 0.75, saturation = 0.95 }
	end
	return { brightness = 1.08, saturation = 0.92 }
end

wezterm.on("window-config-reloaded", function(window, _pane)
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance)
	local overrides = window:get_config_overrides() or {}
	local target_hsb = inactive_hsb_for_appearance(appearance)
	local needs_update = overrides.color_scheme ~= scheme
		or not overrides.inactive_pane_hsb
		or overrides.inactive_pane_hsb.brightness ~= target_hsb.brightness
	if needs_update then
		overrides.color_scheme = scheme
		overrides.colors = { tab_bar = tab_bar_colors_for_scheme(scheme) }
		overrides.inactive_pane_hsb = target_hsb
		window:set_config_overrides(overrides)
	end
	sync_claude_theme(appearance)
end)

-- Initial sync on startup
if wezterm.gui then
	sync_claude_theme(wezterm.gui.get_appearance())
end

-- Toggle light/dark manually (Cmd+Shift+T); next system theme change will sync again
wezterm.on("toggle-color-scheme", function(window, _pane)
	local overrides = window:get_config_overrides() or {}
	local current = overrides.color_scheme or config.color_scheme
	local next_scheme = (current == light_scheme) and dark_scheme or light_scheme
	overrides.color_scheme = next_scheme
	overrides.colors = { tab_bar = tab_bar_colors_for_scheme(next_scheme) }
	window:set_config_overrides(overrides)
end)

-- Tab titles: identify the repo/project, not deep paths.
-- Repos live in ~/Projects, so anywhere under it we show the project folder
-- (the segment right under Projects) even from subdirectories; the literal
-- "Projects" name only shows when sitting in ~/Projects itself. Elsewhere
-- (e.g. ~/dotfiles) fall back to the cwd basename.
local function tab_label(pane)
	local proc = (pane.foreground_process_name or ""):match("([^/\\]+)$") or ""

	local path
	local uri = pane.current_working_dir
	if uri then
		path = type(uri) == "userdata" and uri.file_path or tostring(uri):gsub("^file://[^/]*", "")
	end

	local cwd = ""
	if path and path ~= "" then
		path = path:gsub("/$", "")
		local projects = wezterm.home_dir .. "/Projects"
		if path == projects then
			cwd = "Projects"
		elseif path:sub(1, #projects + 1) == projects .. "/" then
			-- Under ~/Projects/<name>/... → the project name, regardless of depth
			local rest = path:sub(#projects + 2)
			cwd = rest:match("^([^/]+)") or rest
		else
			cwd = path:match("([^/]+)$") or path
		end
	end

	local label = cwd ~= "" and cwd or proc
	-- Append the running program unless it's just an idle shell
	if cwd ~= "" and proc ~= "" and proc ~= "zsh" then
		label = cwd .. " (" .. proc .. ")"
	end
	return label
end

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, _max_width)
	return string.format(" [%d] %s ", tab.tab_index + 1, tab_label(tab.active_pane))
end)

-- Font (Bold matches Cursor/VS Code terminal.integrated.fontWeight "bold")
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" })
config.font_size = 15
config.window_frame = { font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" }) }

-- Window
config.initial_cols = 90
config.initial_rows = 30
config.window_padding = { left = 15, right = 15, top = 15, bottom = 15 }
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.92
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
-- Allow wider tab titles before truncation (default is 16)
config.tab_max_width = 32

-- Subtle dim/brighten on unfocused panes; refined in window-config-reloaded
config.inactive_pane_hsb = { brightness = 0.75, saturation = 0.95 }

-- Let Neovim receive Cmd+B, Cmd+P, etc. (kitty keyboard protocol + unbind defaults)
config.enable_kitty_keyboard = true

-- Interactive shell: CHOOSE ONE:
-- =========================
-- A: Launch nushell as interactive shell (zsh remains the login/POSIX shell)
-- config.default_prog = { "/opt/homebrew/bin/nu" }
-- =========================
-- B: Launch zsh as interactive shell
config.default_prog = { "/bin/zsh" }
-- =========================


-- Ensure Nushell uses ~/.config (so it loads ~/.config/nushell; on macOS nu otherwise uses ~/Library/Application Support/nushell)
-- and Yazi/tools get usable PATH + WezTerm detection
local path = os.getenv("PATH") or "/usr/bin:/bin:/usr/sbin:/sbin"
local path_prefix = ""
if wezterm.target_triple:find("darwin") then
	path_prefix = "/opt/homebrew/bin:/usr/local/bin:"
end
local env = {
	TERM_PROGRAM = "WezTerm",
	PATH = path_prefix .. path,
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
local function is_nvim_pane(pane)
  -- 1. Most reliable: nvim sets IS_NVIM=true via OSC SetUserVar on VimEnter
  if pane:get_user_vars().IS_NVIM == "true" then
    return true
  end
  -- 2. Foreground process name (basename only). Works when WEZTERM_PANE env
  --    propagates and nvim is the actual foreground binary.
  local name = pane:get_foreground_process_name() or ""
  local basename = name:match("([^/\\]+)$") or name
  if basename == "nvim" or basename == "vim" then
    return true
  end
  -- 3. Title heuristic. LazyVim sets the window/pane title to include "Nvim".
  --    This is the catch-all for wrappers, aliases, or process-name detection failures.
  local title = pane:get_title() or ""
  return title:match("[Nn]vim") ~= nil
end

---Forward a key to Neovim when focused; otherwise disable WezTerm default (e.g. tab switch).
local function send_to_nvim(key, mods)
  return wezterm.action_callback(function(win, pane)
    if is_nvim_pane(pane) then
      win:perform_action(wezterm.action.SendKey({ key = key, mods = mods }), pane)
    else
      win:perform_action(wezterm.action.DisableDefaultAssignment, pane)
    end
  end)
end

---Classify panes in the active tab relative to the nvim pane.
---Returns { nvim = info, bottom = info|nil, right = info|nil } using
---panes_with_info() top/left coordinates so we don't need pane IDs in state.
local function classify_panes(tab)
  local panes_info = tab:panes_with_info()
  local nvim_info
  for _, info in ipairs(panes_info) do
    if is_nvim_pane(info.pane) then
      nvim_info = info
      break
    end
  end
  if not nvim_info then return nil end
  local result = { nvim = nvim_info }
  for _, info in ipairs(panes_info) do
    if info.pane:pane_id() ~= nvim_info.pane:pane_id() then
      if info.left > nvim_info.left then
        result.right = info
      elseif info.top > nvim_info.top then
        result.bottom = info
      end
    end
  end
  return result
end

-- wezterm.GLOBAL only accepts string keys, so we stringify the pane id.
local function pane_key(pane_id) return tostring(pane_id) end

local function is_minimized(pane_id)
  wezterm.GLOBAL.ide_min = wezterm.GLOBAL.ide_min or {}
  return wezterm.GLOBAL.ide_min[pane_key(pane_id)] == true
end

local function set_minimized(pane_id, state)
  wezterm.GLOBAL.ide_min = wezterm.GLOBAL.ide_min or {}
  wezterm.GLOBAL.ide_min[pane_key(pane_id)] = state and true or nil
end

-- Remember a pane's pre-minimize size so we can restore it exactly.
local function save_size(pane_id, size)
  wezterm.GLOBAL.ide_sizes = wezterm.GLOBAL.ide_sizes or {}
  wezterm.GLOBAL.ide_sizes[pane_key(pane_id)] = size
end

local function get_saved_size(pane_id)
  wezterm.GLOBAL.ide_sizes = wezterm.GLOBAL.ide_sizes or {}
  return wezterm.GLOBAL.ide_sizes[pane_key(pane_id)]
end

---Toggle an IDE companion pane (bottom shell or right Claude).
---Behavior:
--- - missing -> spawn next to nvim
--- - present, unfocused -> activate (works from any pane)
--- - present, focused, not minimized -> shrink + return focus to nvim
--- - present, minimized -> grow + focus
---grow_dir is the direction nvim expands to minimize the target;
---restore_dir is the direction the target expands to restore.
local function toggle_ide_pane(role, grow_dir, restore_dir)
  return wezterm.action_callback(function(win, current_pane)
    local panes_info = current_pane:tab():panes_with_info()

    local nvim_info
    for _, info in ipairs(panes_info) do
      if is_nvim_pane(info.pane) then
        nvim_info = info
        break
      end
    end
    if not nvim_info then return end

    local target
    for _, info in ipairs(panes_info) do
      if info.pane:pane_id() ~= nvim_info.pane:pane_id() then
        if role == "right" and info.left > nvim_info.left then
          target = info
        elseif role == "bottom" and info.left == nvim_info.left and info.top > nvim_info.top then
          target = info
        end
      end
    end

    if not target then
      local size = (role == "bottom") and { Cells = 15 } or { Percent = 30 }
      local dir = (role == "bottom") and "Bottom" or "Right"
      local split_args = { direction = dir, size = size }
      if role == "right" then
        split_args.command = { args = { "claude" } }
      end
      nvim_info.pane:split(split_args)
      return
    end

    local target_pane = target.pane
    local target_id = target_pane:pane_id()
    local focused = (current_pane:pane_id() == target_id)
    local minimized = is_minimized(target_id)
    local size_key = (role == "bottom") and "viewport_rows" or "cols"

    if focused and not minimized then
      -- Save current size so restore can return to exactly this dimension.
      save_size(target_id, target_pane:get_dimensions()[size_key])
      win:perform_action(
        wezterm.action.AdjustPaneSize({ grow_dir, 999 }),
        nvim_info.pane
      )
      set_minimized(target_id, true)
      nvim_info.pane:activate()
      return
    end

    target_pane:activate()
    if minimized then
      local saved = get_saved_size(target_id) or 15
      local delta = saved - target_pane:get_dimensions()[size_key]
      if delta > 0 then
        win:perform_action(
          wezterm.action.AdjustPaneSize({ restore_dir, delta }),
          target_pane
        )
      end
      set_minimized(target_id, false)
    end
  end)
end

config.keys = {}
-- Forward chords to Neovim (SUPER = Cmd in kitty protocol → <D-…> in Neovim)
for _, spec in ipairs({
  { key = "p", mods = "CMD", send = { key = "p", mods = "SUPER" } },
}) do
  table.insert(config.keys, {
    key = spec.key,
    mods = spec.mods,
    action = send_to_nvim(spec.send.key, spec.send.mods),
  })
end
-- Cmd+W: always close the active WezTerm pane, regardless of focused program
table.insert(config.keys, {
  key = "w",
  mods = "CMD",
  action = wezterm.action.CloseCurrentPane({ confirm = true }),
})
-- IDE companion panes: true toggle + cross-pane jump
table.insert(config.keys, {
  key = "`",
  mods = "CTRL",
  action = toggle_ide_pane("bottom", "Down", "Up"),
})
table.insert(config.keys, {
  key = "b",
  mods = "CMD|SHIFT",
  action = toggle_ide_pane("right", "Right", "Left"),
})
for _, key in ipairs({
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
  -- Navigate tabs
  { key = "[", mods = "CMD", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "]", mods = "CMD", action = wezterm.action.ActivateTabRelative(1) },
  -- Cmd+1..9 switches WezTerm tabs (was forwarded to nvim previously)
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
  -- Navigate panes with arrow keys (Ctrl+Cmd+Arrow)
  { key = "LeftArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "DownArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "UpArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "CMD|CTRL", action = wezterm.action.ActivatePaneDirection("Right") },
  -- Resize focused pane: Cmd+Alt+Arrow (3 cells per press)
  { key = "LeftArrow",  mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Left", 3 }) },
  { key = "DownArrow",  mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },
  { key = "UpArrow",    mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
  { key = "RightArrow", mods = "CMD|ALT", action = wezterm.action.AdjustPaneSize({ "Right", 3 }) },
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
}) do
  table.insert(config.keys, key)
end

-- Machine-local overrides (~/.config/wezterm/local.lua), generated by scripts/setup.sh when WezTerm is primary
do
	local ok, local_cfg = pcall(dofile, wezterm.config_dir .. "/local.lua")
	if ok and type(local_cfg) == "table" then
		for k, v in pairs(local_cfg) do
			config[k] = v
		end
	end
end

return config
