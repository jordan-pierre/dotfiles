local theme = require("config.theme")

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    theme.solid_backgrounds()
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if vim.env.TERM_PROGRAM == "WezTerm" and vim.fn.exists("+termkey") == 1 then
      pcall(function()
        vim.o.termkey = "kitty"
      end)
    end
  end,
})
