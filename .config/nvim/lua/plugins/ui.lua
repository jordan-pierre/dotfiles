return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      open_files_do_not_replace_types = { "terminal", "toggleterm", "trouble", "qf", "neominimap" },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            "node_modules",
            ".DS_Store",
            "Thumbs.db",
          },
          hide_by_pattern = {
            "*.tmp",
            "*.log",
          },
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
        bind_to_cwd = true,
        respect_gitignore = false,
      },
      window = {
        position = "left",
        width = math.max(28, math.floor(vim.o.columns * 0.22)),
        winblend = 0,
        mappings = {
          ["<space>"] = "toggle_node",
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = function(state)
            local node = state.tree:get_node()
            if node.type == "file" then
              local layout = require("config.layout")
              if not layout.center_editor_win() then
                pcall(vim.cmd, "Neominimap off")
                vim.schedule(function()
                  require("neo-tree.sources.filesystem.commands").open(state)
                end)
                return
              end
            end
            require("neo-tree.sources.filesystem.commands").open(state)
          end,
          ["<esc>"] = "cancel",
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["l"] = "focus_preview",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["w"] = "open_with_window_picker",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          ["a"] = {
            "add",
            config = {
              show_path = "none",
            },
          },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["H"] = "toggle_hidden",
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = nil,
          expander_collapsed = "▶",
          expander_expanded = "▼",
          expander_highlight = "NeoTreeExpander",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
          },
        },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_extend("force", opts.options or {}, {
        -- cyberdream.nvim registers its lualine theme when extensions.lualine=true;
        -- "auto" then picks it up and gives mode-coloured blocks like Cursor.
        theme = "auto",
        globalstatus = true,
        -- Flat separators: no powerline arrows, matches Cursor/Zed style
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
      })
      opts.sections = vim.tbl_extend("force", opts.sections or {}, {
        -- Left: mode | branch | diff hunks | diagnostics
        lualine_a = { "mode" },
        lualine_b = { "branch", {
          "diff",
          source = function()
            local gs = vim.b.gitsigns_status_dict
            if gs then
              return { added = gs.added, modified = gs.changed, removed = gs.removed }
            end
          end,
        } },
        lualine_c = {
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = "󰌶 " },
          },
        },
        -- Center: relative file path
        lualine_x = { { "filename", path = 1 } },
        -- Right: filetype | line:col
        lualine_y = { { "filetype", icon_only = false } },
        lualine_z = { "location" },
      })
      return opts
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        layout_strategy = "horizontal",
        layout_config = {
          prompt_position = "top",
          preview_width = 0.55,
          horizontal = {
            width = 0.9,
            height = 0.85,
          },
        },
        sorting_strategy = "ascending",
        winblend = 0,
        file_ignore_patterns = { "node_modules", ".git/", "dist/" },
      })
      return opts
    end,
    config = function()
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },

  {
    "Isrothy/neominimap.nvim",
    version = "v3.*.*",
    event = "VeryLazy",
    init = function()
      vim.g.neominimap = {
        auto_enable = true,
        layout = "split",
        split = {
          direction = "right",
          close_if_last_window = true,
          fix_width = true,
          minimap_width = 16,
        },
        git = { enabled = true },
        diagnostic = { enabled = true },
        treesitter = { enabled = true },
        search = { enabled = true },
        click = { enabled = true, auto_switch_focus = false },
      }
    end,
  },

  {
    "levouh/tint.nvim",
    event = "VeryLazy",
    opts = function()
      local is_dark = vim.o.background ~= "light"
      return {
        tint = is_dark and -45 or 35,
        saturation = 0.6,
        transforms = require("tint").transforms.SATURATE_TINT,
        tint_background_colors = true,
        highlight_ignore_patterns = {
          "WinSeparator", "NeoTreeWinSeparator",
          "Comment", "LineNr", "SignColumn", "EndOfBuffer",
        },
        window_ignore_function = function(winid)
          local buf = vim.api.nvim_win_get_buf(winid)
          local ft  = vim.bo[buf].filetype
          -- Don't tint floating windows or notify popups
          if vim.api.nvim_win_get_config(winid).relative ~= "" then
            return true
          end
          return ft == "notify" or ft == "noice" or ft == "TelescopePrompt"
        end,
      }
    end,
  },
}
