local layout = function()
  return require("config.layout")
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
    init = function()
      vim.api.nvim_create_user_command("IDELayout", function()
        layout().reset_layout()
      end, { desc = "Reset IDE layout (nvim tree+editor, WezTerm shell+Claude panes)" })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        once = true,
        callback = function()
          local theme = require("config.theme")
          theme.apply()
          theme.start_auto_refresh()
          vim.defer_fn(function()
            layout().apply_default_layout()
            theme.apply_palette_overrides()
          end, 200)
        end,
      })
    end,
  },
}
