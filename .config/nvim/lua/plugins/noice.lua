return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- Cmdline popup view (styling comes from colorscheme; cyberdream has a noice extension)
    opts.cmdline = {
      enabled = true,
      view = "cmdline_popup",
      opts = {
        border = { style = "rounded", padding = { 0, 1 } },
        position = { row = 5, col = "50%" },
        size = { width = 60, height = "auto" },
      },
      format = {
        cmdline = { pattern = "^:", icon = " ", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = " ", lang = "bash" },
        lua = { pattern = "^:%s*lua%s+", icon = " ", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = " " },
        input = {},
      },
    }
    return opts
  end,
}
