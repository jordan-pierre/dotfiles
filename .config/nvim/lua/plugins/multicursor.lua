return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- VS Code-style: Ctrl+N to add the next match of the word/selection
      set({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end,
        { desc = "Add cursor at next match" })
      set({ "n", "x" }, "<C-S-n>", function() mc.matchSkipCursor(1) end,
        { desc = "Skip current match, add to next" })

      -- Vertical cursors with Ctrl+Up/Down
      set({ "n", "x" }, "<C-Up>",   function() mc.lineAddCursor(-1) end,
        { desc = "Add cursor above" })
      set({ "n", "x" }, "<C-Down>", function() mc.lineAddCursor(1) end,
        { desc = "Add cursor below" })

      -- Mouse: ctrl+click to drop a cursor
      set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Drop cursor at click" })

      -- Esc clears extra cursors when any exist, falls through to normal Esc otherwise
      set("n", "<Esc>", function()
        if mc.hasCursors() then
          mc.clearCursors()
        else
          vim.cmd("nohlsearch")
        end
      end)

      -- Align cursors columnwise (handy after vertical insert)
      set("n", "<leader>ma", mc.alignCursors, { desc = "Align cursors" })

      -- Match cyberdream accent
      vim.api.nvim_set_hl(0, "MultiCursorCursor", { reverse = true })
      vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
    end,
  },
}
