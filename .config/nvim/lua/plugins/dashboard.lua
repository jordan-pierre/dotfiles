return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
  
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
            "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
            "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
            "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
            "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
            "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          }, "\n"),
  
          -- Default-like menu with icons (bright green) + yellow keys
          keys = {
            { icon = " ", key = "f", desc = "Find Files",      action = function() Snacks.picker.files() end },
            { icon = " ", key = "n", desc = "New File",        action = function() vim.cmd("enew") end },
            { icon = " ", key = "p", desc = "Projects",        action = function() Snacks.picker.projects() end },
            { icon = " ", key = "g", desc = "Find Text",       action = function() Snacks.picker.grep() end },
            { icon = " ", key = "r", desc = "Recent Files",    action = function() Snacks.picker.recent() end },
            { icon = " ", key = "t", desc = "Change Theme",    action = function() Snacks.picker.colorscheme() end },
            { icon = " ", key = "c", desc = "Config",          action = function() Snacks.picker.config() end },
            { icon = "󰒲 ", key = "l", desc = "Lazy",            action = function() vim.cmd("Lazy") end },
            { icon = " ", key = "q", desc = "Quit",            action = function() vim.cmd("qa") end },
          },
        },
  
        sections = {
          { { section = "header", padding = 1 }, { section = "startup" } },
          { pane = 2, { section = "keys", gap = 1, padding = 1 } },
        },
      },
  
      -- Make the Projects picker look in ~/Projects
      picker = {
        sources = {
          projects = {
            dev = { vim.fn.expand("~/Projects") },
          },
        },
      },
  
      bigfile = { enabled = true },
      quickfile = { enabled = true },
    },
  
    config = function(_, opts)
      require("snacks").setup(opts)
  
      -- Everblush-ish styling: transparent bg, bright-green icons, yellow keys
      local green_bright = "#5df669" -- icon green
      local yellow       = "#e5c76b" -- key hint yellow
      local text_green   = "#8ccf7e" -- general text
  
      -- Transparent background
      vim.api.nvim_set_hl(0, "Normal",      { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = text_green, bg = "NONE" })
  
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "Normal",      { bg = "NONE" })
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "FloatBorder", { fg = text_green, bg = "NONE" })
        end,
      })
  
      -- Dashboard text + icons
      vim.api.nvim_set_hl(0, "SnacksDashboard",       { fg = text_green, bg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = text_green, bg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { fg = text_green, bg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksDashboardDesc",   { fg = text_green, bg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksDashboardTitle",  { fg = text_green, bg = "NONE" })
      vim.api.nvim_set_hl(0, "SnacksDashboardIcon",   { fg = green_bright, bg = "NONE", bold = true })
      vim.api.nvim_set_hl(0, "SnacksDashboardKey",    { fg = yellow, bg = "NONE", bold = true })
    end,
  }
  