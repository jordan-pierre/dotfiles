-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Tell the WezTerm pane that we're nvim, so wezterm.lua's is_nvim_pane()
-- detects this pane reliably (rather than falling back to process-name sniffing).
-- Writes to /dev/tty (the controlling PTY) so the OSC reaches WezTerm
-- without fighting nvim's UI layer for stdout.
if vim.env.WEZTERM_PANE and vim.env.WEZTERM_PANE ~= "" then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      -- base64("true") = "dHJ1ZQ=="
      vim.fn.jobstart({
        "sh", "-c",
        "printf '\\033]1337;SetUserVar=IS_NVIM=dHJ1ZQ==\\007' > /dev/tty",
      }, { detach = true })
    end,
  })
end
