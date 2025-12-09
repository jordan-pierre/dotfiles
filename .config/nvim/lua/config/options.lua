-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

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

-- Appearance
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

-- Folding (using treesitter)
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false -- Don't fold by default

-- Performance
opt.lazyredraw = false
opt.ttyfast = true

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
