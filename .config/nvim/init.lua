-- Neovim 0.11.3 compatible config with mason v2, ts_ls, and warning sign support

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.colorcolumn = "120"
vim.opt.list = true
vim.opt.listchars = { trail = "·", tab = "»·", extends = "›", precedes = "‹", nbsp = "␣" }

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

if vim.g.neovide or vim.fn.has("gui_running") == 1 then
  vim.opt.guifont = "JetBrainsMono NFM:h14"
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
      })
      vim.cmd.colorscheme("catppuccin")
      for _, g in ipairs({ "Normal", "NormalFloat", "FloatBorder", "SignColumn", "EndOfBuffer", "LineNr", "Folded", "StatusLine", "StatusLineNC" }) do
        pcall(vim.api.nvim_set_hl, 0, g, { bg = "none" })
      end
    end,
  },
  { "nvim-lualine/lualine.nvim", config = true },
  { "folke/which-key.nvim", config = true },
  {
    "stevearc/oil.nvim",
    opts = {},
    keys = { { "-", function() require("oil").open() end } },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "python", "bash", "json", "yaml", "toml", "markdown", "markdown_inline"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" } }, { { name = "buffer" }, { name = "path" } }),
      })
    end,
  },
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim", version = ">=2.0.0", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    version = ">=2.0.0",
    dependencies = { "neovim/nvim-lspconfig", "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "lua_ls", "pyright", "bashls", "jsonls", "yamlls", "marksman", "ts_ls" },
    },
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      format_on_save = { lsp_fallback = true },
      formatters_by_ft = {
        python = { "ruff_organize_imports_uv", "ruff_format_uv" },
        json = { "prettierd", "prettier" },
        yaml = { "prettierd", "prettier" },
        toml = { "taplo" },
        ["*"] = { "trim_whitespace", "trim_newlines" },
      },
      formatters = {
        ruff_format_uv = {
          command = "uvx",
          args = { "ruff", "format", "--stdin-filename", "$FILENAME", "-" },
          stdin = true,
        },
        ruff_organize_imports_uv = {
          command = "uvx",
          args = { "ruff", "check", "--select=I", "--fix", "--stdin-filename", "$FILENAME", "-" },
          stdin = true,
        },
      },
    },
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.g.VM_default_mappings = 0
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Select All"] = "g<C-n>",
        ["Add Cursor Down"] = "<C-Down>",
        ["Add Cursor Up"] = "<C-Up>",
      }
    end,
  },
  { "numToStr/Comment.nvim", config = true },
  { "lewis6991/gitsigns.nvim", config = true },
  { "windwp/nvim-autopairs", config = true },
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc or "" })
  end
  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>e", function() vim.diagnostic.open_float({ border = "rounded", scope = "line" }) end, "Show diagnostics")
  map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
end

local servers = { "lua_ls", "pyright", "bashls", "jsonls", "yamlls", "marksman", "ts_ls" }
for _, server in ipairs(servers) do
  local opts = { capabilities = capabilities, on_attach = on_attach }
  if server == "lua_ls" then
  opts.settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = { enable = false },
    },
  }
  end
  lspconfig[server].setup(opts)
end

vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save file" })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
