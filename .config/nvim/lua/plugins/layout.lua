vim.g.smart_splits_multiplexer_integration = "wezterm"

local layout = function()
  return require("config.layout")
end

local function snacks_picker()
  return Snacks or require("snacks")
end

return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    priority = 900,
    opts = {
      at_edge = "wrap",
      default_amount = 3,
    },
    config = function(_, opts)
      local s = require("smart-splits")
      s.setup(opts)
      -- LazyVim registers default <C-h/j/k/l> -> :wincmd ... AFTER plugin
      -- config runs. Hook VeryLazy so our overrides are the last writers.
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local set = vim.keymap.set
          set({ "n", "t" }, "<C-h>", s.move_cursor_left,
            { desc = "Move to left window",  silent = true })
          set({ "n", "t" }, "<C-j>", s.move_cursor_down,
            { desc = "Move to lower window", silent = true })
          set({ "n", "t" }, "<C-k>", s.move_cursor_up,
            { desc = "Move to upper window", silent = true })
          set({ "n", "t" }, "<C-l>", s.move_cursor_right,
            { desc = "Move to right window", silent = true })
        end,
      })
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    lazy = false,
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.max(28, math.floor(vim.o.columns * 0.2))
        end
      end,
      hide_numbers = true,
      shade_terminals = false,
      start_in_insert = false,
      insert_mappings = true,
      persist_size = true,
      direction = "horizontal",
      close_on_exit = true,
      shell = vim.o.shell,
    },
    keys = {
      { "<D-b>", function() layout().toggle_neotree() end, mode = "n", desc = "Toggle file tree" },
      { "<D-p>", function() snacks_picker().picker.files() end, mode = "n", desc = "Quick open file" },
      { "<D-S-f>", function() snacks_picker().picker.grep() end, mode = "n", desc = "Search in project" },
      { "<leader>p", function() snacks_picker().picker.files() end, mode = "n", desc = "Quick open file" },
      {
        "<leader>el",
        function() layout().toggle_neotree() end,
        desc = "Toggle file tree",
      },
      {
        "<leader>eb",
        function() layout().toggle_shell() end,
        desc = "Toggle bottom terminal",
      },
      {
        "<leader>er",
        function() layout().toggle_claude() end,
        desc = "Toggle Claude terminal",
      },
      {
        "<leader>fe",
        function() layout().focus_editor() end,
        desc = "Focus editor",
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.width = math.max(28, math.floor(vim.o.columns * 0.22))
      return opts
    end,
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>e", group = "IDE layout / panes" },
        { "<leader>f", group = "find" },
        { "<leader>c", group = "code / preview" },
        { "<leader>m", group = "minimap / markdown" },
        { "<leader>1", desc = "Buffer 1", hidden = false },
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
    },
  },
}
