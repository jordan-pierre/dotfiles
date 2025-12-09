return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      ----------------------------------------------------------------
      -- 1) Cmdline popup view
      ----------------------------------------------------------------
      opts.cmdline = {
        enabled = true,
        view = "cmdline_popup",
        opts = {
          border = { style = "rounded", padding = { 0, 1 } },
          position = { row = 5, col = "50%" },
          size = { width = 60, height = "auto" },
        },
        format = {
          cmdline     = { pattern = "^:",   icon = "📡", lang = "vim" },
          search_down = { kind = "search",  pattern = "^/",  icon = "🔍", lang = "regex" },
          search_up   = { kind = "search",  pattern = "^%?", icon = "🔍", lang = "regex" },
          filter      = { pattern = "^:%s*!", icon = "📡",   lang = "bash" },
          lua         = { pattern = "^:%s*lua%s+", icon = "📡", lang = "lua" },
          help        = { pattern = "^:%s*he?l?p?%s+", icon = "📡" },
          input       = {},
        },
      }
  
      ----------------------------------------------------------------
      -- 2) Map the popup window to OUR neon groups
      --    Important: map NormalFloat; include Normal as fallback.
      ----------------------------------------------------------------
      opts.views = opts.views or {}
      opts.views.cmdline_popup = vim.tbl_deep_extend("force", opts.views.cmdline_popup or {}, {
        border = { style = "rounded", padding = { 0, 1 } },
        win_options = {
          winhighlight = table.concat({
            "NormalFloat:MyCmdlinePopup",
            "Normal:MyCmdlinePopup",           -- fallback if a theme uses Normal
            "FloatBorder:MyCmdlinePopupBorder",
            "FloatTitle:MyCmdlinePopupTitle",
          }, ","),
        },
      })
  
      ----------------------------------------------------------------
      -- 3) Define neon groups (no links) and reapply when needed
      ----------------------------------------------------------------
      local function apply_neon()
        local neon = "#00ff00"
        local defs = {
          { "MyCmdlinePopup",       { fg = neon, bg = "NONE", bold = true } },
          { "MyCmdlinePopupBorder", { fg = neon, bg = "NONE", bold = true } },
          { "MyCmdlinePopupTitle",  { fg = neon, bg = "NONE", bold = true } },
        }
        for _, d in ipairs(defs) do
          vim.api.nvim_set_hl(0, d[1], d[2])
        end
      end
  
      -- Re-apply after themes/lazy phases (so schemes can’t override)
      vim.api.nvim_create_autocmd({ "ColorScheme", "User" }, {
        pattern = { "VeryLazy", "LazyDone" },
        callback = function() vim.schedule(apply_neon) end,
      })
  
      -- And once when UI starts
      vim.api.nvim_create_autocmd("UIEnter", {
        once = true,
        callback = function() vim.schedule(apply_neon) end,
      })
  
      return opts
    end,
  }
  