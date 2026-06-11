return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Apply immediately (priority=1000 means this runs before all other plugins).
      -- theme.apply() detects macOS system appearance, configures cyberdream with
      -- the correct dark/light variant, loads the colorscheme, and sets overrides.
      local theme = require("config.theme")
      theme.apply()
      theme.start_auto_refresh()
    end,
  },
}
