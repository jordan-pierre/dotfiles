-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_python_lsp = "ty"


local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Gutter: show BOTH the absolute and relative line number on every line.
-- Overrides LazyVim's statuscolumn. %s preserves the sign column
-- (git / diagnostics); the fold-arrow column is dropped (folding is disabled).
function _G.dual_statuscolumn()
  -- Windows without line numbers (neo-tree, terminals, etc.) shouldn't get the
  -- dual-number gutter — keep just the sign column there.
  if not (vim.wo.number or vim.wo.relativenumber) then
    return "%s"
  end
  local hl = vim.v.relnum == 0 and "%#CursorLineNr#" or "%#LineNr#"
  return "%s" .. hl .. ("%3d "):format(vim.v.lnum) .. ("%2d "):format(vim.v.relnum)
end
opt.statuscolumn = "%!v:lua.dual_statuscolumn()"

-- Some windows (file tree, terminals, Trouble) shouldn't get the dual-number
-- gutter — the statuscolumn function can't reliably detect them from inside,
-- so blank the gutter and disable numbers per-window here instead.
local NO_GUTTER_FT = { ["neo-tree"] = true, ["toggleterm"] = true, ["trouble"] = true }
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  callback = function()
    if NO_GUTTER_FT[vim.bo.filetype] then
      vim.opt_local.statuscolumn = ""
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    end
  end,
})

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance (background set by theme sync in autocmds when on macOS)
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- File encoding
opt.fileencoding = "utf-8"

-- Reload files changed outside Neovim (e.g. Claude Code agent writes)
opt.autoread = true

-- Undo & backup
opt.undofile = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Update time
opt.updatetime = 300
opt.timeoutlen = 500

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Column guide
opt.colorcolumn = "120"

-- Show whitespace
opt.list = true
opt.listchars = {
  lead = "·",
  trail = "·",
  tab = "↠ ",
  extends = "›",
  precedes = "‹",
  nbsp = "␣",
}

-- Mouse
opt.mouse = "a"

-- Command line height
opt.cmdheight = 1

-- Show mode
opt.showmode = false

-- Folding: LazyVim sets foldmethod=expr (treesitter). Keep folds ENABLED but
-- start fully open (foldlevelstart=99) so nothing is ever hidden — files open
-- fully expanded, while fold-navigation motions still work: ]z / [z jump to the
-- end / start of the current block, zj / zk to the next / previous fold.
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Window title
opt.title = true

-- Conceallevel for markdown
opt.conceallevel = 2

-- Filter out unwanted built-in colorschemes
vim.api.nvim_create_autocmd("ColorSchemePre", {
  callback = function()
    local unwanted = {
      "blue", "darkblue", "default", "delek", "desert", "elflord",
      "evening", "habamax", "industry", "koehler", "lunaperche",
      "morning", "murphy", "pablo", "peachpuff", "quiet", "ron",
      "shine", "slate", "sorbet", "torte", "vim", "wildcharm", "zaibatsu"
    }
    -- This will prevent loading of unwanted schemes
    for _, scheme in ipairs(unwanted) do
      if vim.g.colors_name == scheme then
        vim.notify("Colorscheme '" .. scheme .. "' is disabled", vim.log.levels.WARN)
        return true
      end
    end
  end,
})
