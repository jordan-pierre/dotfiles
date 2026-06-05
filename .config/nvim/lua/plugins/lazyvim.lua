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
          require("config.theme").apply()
          vim.defer_fn(function()
            layout().apply_default_layout()
            require("config.theme").solid_backgrounds()
          end, 200)
        end,
      })
    end,
  },
}
