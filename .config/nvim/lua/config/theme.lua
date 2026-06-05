---Cyberdream + Zed-matched palettes. All highlight overrides live in zed_overrides().
local M = {}

-- Zed "Cyberdream dark" (WezTerm dark base, purple chrome)
M.zed_dark = {
  bg          = "#1a1625",
  panel       = "#1f1a30",
  chrome      = "#1a1625",  -- same as bg in dark: no visible chrome
  active_line = "#231d38",
  border      = "#252038",
  fg          = "#ffffff",
  muted       = "#7b8496",
  accent      = "#5ea1ff",  -- blue
  -- semantic palette (matches WezTerm ansi + Zed VC overrides)
  green       = "#5eff6c",
  orange      = "#ffbd5e",
  red         = "#ff6e5e",
  cyan        = "#5ef1ff",
  purple      = "#bd5eff",
  pink        = "#ff5ea0",
}

-- Zed "Cyberdream light" (Quiet Light-style chrome, #c4b7d7 toolbar)
M.zed_light = {
  bg          = "#f5f5f5",
  panel       = "#f2f2f2",
  chrome      = "#c4b7d7",  -- Zed toolbar/tab-bar colour
  active_line = "#ebe8ef",
  border      = "#d4cdd9",
  fg          = "#333333",
  muted       = "#6c6c6c",
  accent      = "#9769dc",  -- purple
  -- semantic palette
  green       = "#008b0c",
  orange      = "#d17c00",
  red         = "#d11500",
  cyan        = "#008c99",
  purple      = "#a018ff",
  pink        = "#f40064",
}

M.bg_dark  = M.zed_dark.bg
M.bg_light = M.zed_light.bg

function M.system_is_dark()
  local os = (vim.uv or vim.loop).os_uname()
  if not os or os.sysname ~= "Darwin" then
    return true
  end
  local out = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null"):gsub("%s+", "")
  return out == "Dark"
end

function M.palette()
  return vim.o.background == "light" and M.zed_light or M.zed_dark
end

function M.cyberdream_colors()
  if vim.o.background == "light" then
    return {
      light = {
        bg           = M.zed_light.bg,
        bg_alt       = M.zed_light.panel,
        bg_highlight = M.zed_light.active_line,
        fg           = M.zed_light.fg,
        grey         = M.zed_light.muted,
        blue         = "#0057d1",
        green        = M.zed_light.green,
        cyan         = M.zed_light.cyan,
        red          = M.zed_light.red,
        yellow       = M.zed_light.orange,  -- cyberdream yellow → Zed keyword orange
        magenta      = M.zed_light.purple,
        pink         = M.zed_light.pink,
        orange       = M.zed_light.orange,
        purple       = M.zed_light.accent,
      },
    }
  end
  return {
    default = {
      bg           = M.zed_dark.bg,
      bg_alt       = M.zed_dark.panel,
      bg_highlight = M.zed_dark.active_line,
      fg           = M.zed_dark.fg,
      grey         = M.zed_dark.muted,
      blue         = M.zed_dark.accent,
      green        = M.zed_dark.green,
      cyan         = M.zed_dark.cyan,
      red          = M.zed_dark.red,
      yellow       = M.zed_dark.orange,  -- cyberdream yellow → Zed keyword orange
      magenta      = "#ff5ef1",
      pink         = M.zed_dark.pink,
      orange       = M.zed_dark.orange,
      purple       = M.zed_dark.purple,
    },
  }
end

function M.zed_overrides()
  local z   = M.palette()
  local hl  = {}

  -- Transparent background: let WezTerm's window opacity show through neo-tree
  -- AND the editor uniformly. Floats/popups stay slightly opaque for readability.
  -- Accent color on the focused-window separator (drawn by tint.nvim companion).
  local focus_accent = z.purple

  -- ── Core editor ──────────────────────────────────────────────────────────
  hl.Normal          = { fg = z.fg,    bg = "NONE" }
  hl.NormalNC        = { fg = z.fg,    bg = "NONE" }
  hl.NormalFloat     = { fg = z.fg,    bg = z.panel }
  hl.FloatBorder     = { fg = z.border, bg = z.panel }
  hl.CursorLine      = { bg = z.active_line }
  hl.CursorLineNr    = { fg = z.accent, bold = true }
  hl.LineNr          = { fg = z.muted }
  hl.WinSeparator    = { fg = focus_accent, bg = "NONE" }
  hl.SignColumn      = { bg = "NONE" }
  hl.Folded          = { fg = z.muted, bg = "NONE" }
  hl.EndOfBuffer     = { fg = "NONE",  bg = "NONE" }
  hl.ColorColumn     = { bg = z.active_line }
  hl.Visual          = { bg = z.active_line }
  hl.Search          = { fg = z.bg,    bg = z.orange, bold = true }
  hl.IncSearch       = { fg = z.bg,    bg = z.accent, bold = true }

  -- ── Statusline / tabs ────────────────────────────────────────────────────
  hl.StatusLine      = { fg = z.fg,   bg = "NONE" }
  hl.StatusLineNC    = { fg = z.muted, bg = "NONE" }
  hl.TabLine         = { fg = z.fg,   bg = "NONE" }
  hl.TabLineFill     = { bg = "NONE" }
  hl.TabLineSel      = { fg = z.fg,   bg = "NONE", bold = true }
  hl.WinBar          = { fg = z.fg,   bg = "NONE" }
  hl.WinBarNC        = { fg = z.muted, bg = "NONE" }

  -- ── Lualine (light mode uses Zed chrome; dark uses cyberdream.nvim's own theme) ──
  if vim.o.background == "light" then
    hl.LualineA = { fg = z.fg,    bg = z.chrome, bold = true }
    hl.LualineB = { fg = z.fg,    bg = z.panel }
    hl.LualineC = { fg = z.fg,    bg = "NONE" }
    hl.LualineX = { fg = z.muted, bg = "NONE" }
    hl.LualineY = { fg = z.fg,    bg = z.panel }
    hl.LualineZ = { fg = z.fg,    bg = z.chrome }
  end

  -- ── NeoTree (transparent to match the editor) ────────────────────────────
  hl.NeoTreeNormal        = { fg = z.fg,    bg = "NONE" }
  hl.NeoTreeNormalNC      = { fg = z.fg,    bg = "NONE" }
  hl.NeoTreeEndOfBuffer   = { fg = "NONE",  bg = "NONE" }
  hl.NeoTreeWinSeparator  = { fg = focus_accent, bg = "NONE" }
  hl.NeoTreeTitleBar      = { fg = z.fg,    bg = z.chrome, bold = true }
  hl.NeoTreeCursorLine    = { bg = z.active_line }

  -- ── ToggleTerm / terminal buffers ────────────────────────────────────────
  hl.ToggleTermNormal   = { fg = z.fg, bg = "NONE" }
  hl.ToggleTermNormalNC = { fg = z.fg, bg = "NONE" }
  hl.Term               = { fg = z.fg, bg = "NONE" }
  hl.TermNC             = { fg = z.fg, bg = "NONE" }

  -- ── Git signs (matches Zed theme_overrides) ──────────────────────────────
  hl.GitSignsAdd          = { fg = z.green }
  hl.GitSignsChange       = { fg = z.orange }
  hl.GitSignsDelete       = { fg = z.red }
  hl.GitSignsAddNr        = { fg = z.green }
  hl.GitSignsChangeNr     = { fg = z.orange }
  hl.GitSignsDeleteNr     = { fg = z.red }
  hl.GitSignsAddLn        = { bg = z.active_line }
  hl.GitSignsChangeLn     = { bg = z.active_line }
  hl.DiffAdd              = { bg = z.active_line }
  hl.DiffChange           = { bg = z.active_line }
  hl.DiffDelete           = { fg = z.red }
  hl.DiffText             = { bg = z.border }

  -- ── Diagnostics (matches Zed error/warning/info/hint palette) ────────────
  hl.DiagnosticError            = { fg = z.red }
  hl.DiagnosticWarn             = { fg = z.orange }
  hl.DiagnosticInfo             = { fg = z.accent }
  hl.DiagnosticHint             = { fg = z.muted }
  hl.DiagnosticSignError        = { fg = z.red,    bg = z.bg }
  hl.DiagnosticSignWarn         = { fg = z.orange, bg = z.bg }
  hl.DiagnosticSignInfo         = { fg = z.accent, bg = z.bg }
  hl.DiagnosticSignHint         = { fg = z.muted,  bg = z.bg }
  hl.DiagnosticUnderlineError   = { undercurl = true, sp = z.red }
  hl.DiagnosticUnderlineWarn    = { undercurl = true, sp = z.orange }
  hl.DiagnosticUnderlineInfo    = { undercurl = true, sp = z.accent }
  hl.DiagnosticUnderlineHint    = { undercurl = true, sp = z.muted }
  hl.DiagnosticVirtualTextError = { fg = z.red,    italic = true }
  hl.DiagnosticVirtualTextWarn  = { fg = z.orange, italic = true }
  hl.DiagnosticVirtualTextInfo  = { fg = z.accent, italic = true }
  hl.DiagnosticVirtualTextHint  = { fg = z.muted,  italic = true }

  -- ── LSP inlay hints (ty type hints) ──────────────────────────────────────
  hl.LspInlayHint = { fg = z.muted, italic = true }

  -- ── Treesitter syntax — match Zed Cyberdream exactly ─────────────────────
  -- cyberdream.nvim maps @keyword → yellow (#f1ff5e / #997b00);
  -- Zed uses orange (#ffbd5e / #d17c00).  Pin them here so they match.
  local kw = { fg = z.orange }
  hl["@keyword"]                    = kw
  hl["@keyword.function"]           = kw
  hl["@keyword.operator"]           = { fg = z.purple }  -- 'not','and','or' → operator color
  hl["@keyword.return"]             = kw
  hl["@keyword.import"]             = kw
  hl["@keyword.modifier"]           = kw
  hl["@keyword.repeat"]             = kw
  hl["@keyword.exception"]          = kw
  hl["@keyword.conditional"]        = kw
  hl["@keyword.conditional.ternary"]= kw
  hl["@conditional"]                = kw  -- legacy capture name
  hl["@repeat"]                     = kw
  hl["@exception"]                  = kw
  hl["@include"]                    = kw

  -- Functions & methods → accent blue
  local fn = { fg = z.accent }
  hl["@function"]           = fn
  hl["@function.builtin"]   = fn
  hl["@function.call"]      = fn
  hl["@function.macro"]     = fn
  hl["@method"]             = fn
  hl["@method.call"]        = fn

  -- Types → purple italic  (matches Zed "type": #bd5eff / #a018ff italic)
  local ty = { fg = z.purple, italic = true }
  hl["@type"]               = ty
  hl["@type.builtin"]       = ty
  hl["@type.definition"]    = ty
  hl["@storageclass"]       = { fg = z.purple }

  -- Operators & special variables → purple
  hl["@operator"]           = { fg = z.purple }
  hl["@variable.special"]   = { fg = z.purple }

  -- Constructors / tags / attributes → cyan
  local cy = { fg = z.cyan }
  hl["@constructor"]        = cy
  hl["@tag"]                = cy
  hl["@tag.delimiter"]      = cy
  hl["@tag.attribute"]      = cy
  hl["@attribute"]          = cy

  -- Strings → green
  local str = { fg = z.green }
  hl["@string"]             = str
  hl["@string.regex"]       = str
  hl["@string.escape"]      = { fg = z.fg }  -- Zed: string.escape → plain text color
  hl["@string.special"]     = str

  -- Numbers & booleans
  hl["@number"]             = { fg = z.orange }
  hl["@float"]              = { fg = z.orange }
  hl["@boolean"]            = { fg = z.accent }

  -- Constants & variables → plain text
  hl["@constant"]           = { fg = z.fg }
  hl["@constant.builtin"]   = { fg = z.accent }
  hl["@variable"]           = { fg = z.fg }
  hl["@variable.builtin"]   = { fg = z.purple }  -- self, cls, etc.

  -- Punctuation (Zed: bracket/delimiter → text; special/list → pink)
  hl["@punctuation.bracket"]   = { fg = z.fg }
  hl["@punctuation.delimiter"] = { fg = z.fg }
  hl["@punctuation.special"]   = { fg = z.pink }

  -- Comments
  hl["@comment"]             = { fg = z.muted }
  hl["@comment.documentation"] = { fg = z.muted }
  hl["@comment.todo"]        = { fg = z.accent,  italic = true, bold = true }
  hl["@comment.note"]        = { fg = z.cyan,    italic = true, bold = true }
  hl["@comment.warning"]     = { fg = z.orange,  italic = true, bold = true }
  hl["@comment.error"]       = { fg = z.red,     italic = true, bold = true }

  -- LSP semantic tokens (ty emits these for Python)
  hl["@lsp.type.class"]          = ty
  hl["@lsp.type.interface"]      = ty
  hl["@lsp.type.enum"]           = ty
  hl["@lsp.type.enumMember"]     = { fg = z.cyan }
  hl["@lsp.type.function"]       = fn
  hl["@lsp.type.method"]         = fn
  hl["@lsp.type.parameter"]      = { fg = z.fg }
  hl["@lsp.type.variable"]       = { fg = z.fg }
  hl["@lsp.type.property"]       = { fg = z.fg }
  hl["@lsp.type.keyword"]        = kw
  hl["@lsp.type.operator"]       = { fg = z.purple }
  hl["@lsp.type.decorator"]      = { fg = z.cyan }
  hl["@lsp.type.selfParameter"]  = { fg = z.purple }
  hl["@lsp.mod.deprecated"]      = { strikethrough = true }

  return hl
end

function M.apply_palette_overrides()
  -- Apply Zed-flavored highlight overrides on top of cyberdream. Called
  -- after each colorscheme load and after light/dark switches.
  for group, spec in pairs(M.zed_overrides()) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

-- Back-compat: older modules may still call solid_backgrounds().
M.solid_backgrounds = M.apply_palette_overrides

function M.setup_cyberdream()
  local ok, cyberdream = pcall(require, "cyberdream")
  if not ok then
    return false
  end
  local variant = vim.o.background == "light" and "light" or "default"
  cyberdream.setup({
    variant          = variant,
    transparent      = true,
    italic_comments  = false,
    terminal_colors  = true,
    borderless_pickers = true,
    colors           = M.cyberdream_colors(),
    overrides        = function()
      return M.zed_overrides()
    end,
    extensions = {
      telescope       = true,
      notify          = true,
      noice           = true,
      snacks          = true,
      lazy            = true,
      indentblankline = true,
      gitsigns        = true,
      whichkey        = true,
      trouble         = true,
      -- neo-tree + lualine: no cyberdream extension; styled in zed_overrides()
    },
  })
  return true
end

function M.apply()
  vim.opt.termguicolors = true
  vim.opt.winblend      = 0
  vim.opt.pumblend      = 0

  vim.o.background = M.system_is_dark() and "dark" or "light"

  if M.setup_cyberdream() then
    pcall(vim.cmd.colorscheme, "cyberdream")
  end
  M.apply_palette_overrides()

  pcall(function()
    require("tint").refresh()
  end)
end

function M.refresh_if_changed()
  local desired = M.system_is_dark() and "dark" or "light"
  if vim.o.background ~= desired then
    M.apply()
  end
end

local _refresh_timer
function M.start_auto_refresh()
  if _refresh_timer then return end
  _refresh_timer = (vim.uv or vim.loop).new_timer()
  -- Poll macOS appearance every 3s (cheap subprocess; skipped on non-Darwin)
  _refresh_timer:start(3000, 3000, vim.schedule_wrap(M.refresh_if_changed))

  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("ThemeAutoRefresh", { clear = true }),
    callback = M.refresh_if_changed,
  })
end

return M
