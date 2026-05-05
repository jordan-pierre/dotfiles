-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Sync Neovim theme with macOS light/dark appearance (so light mode is readable)
local function sync_theme_with_system()
  local os = (vim.uv or vim.loop).os_uname()
  if os and os.sysname ~= "Darwin" then
    return
  end
  local out = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null"):gsub("%s+", "")
  local is_dark = (out == "Dark")
  if is_dark then
    vim.opt.background = "dark"
    pcall(vim.cmd.colorscheme, "cyberdream")
  else
    vim.opt.background = "light"
    pcall(vim.cmd.colorscheme, "github_light")
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = sync_theme_with_system,
})

vim.api.nvim_create_autocmd("FocusGained", {
  callback = sync_theme_with_system,
})
