---IDE layout: neo-tree + editor inside Neovim; shell + Claude in WezTerm panes.
local M = {}

M.term_shell_id = 1
M.term_claude_id = 2

local SKIP_FT = {
  ["neo-tree"] = true,
  ["toggleterm"] = true,
  ["lazy"] = true,
  ["mason"] = true,
  ["alpha"] = true,
  ["dashboard"] = true,
  ["snacks_dashboard"] = true,
  ["trouble"] = true,
  ["Trouble"] = true,
  ["neominimap"] = true,
}

function M.in_wezterm()
  local pane = vim.env.WEZTERM_PANE
  return pane ~= nil and pane ~= ""
end

function M.wezterm_cli(args)
  return vim.fn.system(vim.list_extend({ "wezterm", "cli" }, args))
end

function M.wezterm_list_panes()
  if not M.in_wezterm() then
    return nil
  end
  local raw = M.wezterm_cli({ "list", "--format", "json" })
  if vim.v.shell_error ~= 0 or raw == "" then
    return nil
  end
  local ok, data = pcall(vim.json.decode, raw)
  if not ok then
    return nil
  end
  return data
end

function M.current_tab_panes()
  local cur = tonumber(vim.env.WEZTERM_PANE)
  local all = M.wezterm_list_panes()
  if not all or not cur then
    return {}
  end
  local tab_id
  for _, p in ipairs(all) do
    if p.pane_id == cur then
      tab_id = p.tab_id
      break
    end
  end
  if not tab_id then
    return {}
  end
  local out = {}
  for _, p in ipairs(all) do
    if p.tab_id == tab_id then
      out[#out + 1] = p
    end
  end
  return out
end

function M.clear_wezterm_aux_panes()
  if not M.in_wezterm() then
    return
  end
  local cur = tonumber(vim.env.WEZTERM_PANE)
  for _, p in ipairs(M.current_tab_panes()) do
    if p.pane_id ~= cur then
      M.wezterm_cli({ "kill-pane", "--pane-id", tostring(p.pane_id) })
    end
  end
end

function M.setup_wezterm_panes()
  if not M.in_wezterm() then
    return false
  end

  local tab_panes = M.current_tab_panes()
  if #tab_panes >= 3 then
    M.wezterm_cli({ "activate-pane", "--pane-id", vim.env.WEZTERM_PANE })
    return true
  end

  local nvim_pane = vim.env.WEZTERM_PANE
  local claude_pct = tostring(math.max(18, math.min(25, math.floor(100 * 28 / vim.o.columns))))

  -- Right column: Claude shell (full height). Bottom-left: project shell under nvim only.
  M.wezterm_cli({ "split-pane", "--pane-id", nvim_pane, "--right", "--percent", claude_pct })
  M.wezterm_cli({ "split-pane", "--pane-id", nvim_pane, "--bottom", "--cells", "15" })
  M.wezterm_cli({ "activate-pane", "--pane-id", nvim_pane })
  return true
end

function M.reset_wezterm_panes()
  if not M.in_wezterm() then
    return
  end
  M.clear_wezterm_aux_panes()
  vim.defer_fn(function()
    M.setup_wezterm_panes()
  end, 80)
end

function M.is_neotree_window(win)
  win = win or vim.api.nvim_get_current_win()
  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree"
end

function M.term_window_for_id(id)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.b[vim.api.nvim_win_get_buf(win)].toggle_number == id then
      return win
    end
  end
end

function M.find_window(pred)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if pred(win) then
      return win
    end
  end
end

function M.center_editor_win()
  local best, best_row, best_col
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "" and not SKIP_FT[vim.bo[buf].filetype] then
      local row, col = vim.api.nvim_win_get_position(win)
      if not best or row < best_row or (row == best_row and col < best_col) then
        best, best_row, best_col = win, row, col
      end
    end
  end
  return best
end

function M.focus_editor()
  local win = M.center_editor_win()
  if win then
    vim.api.nvim_set_current_win(win)
    return true
  end
  return false
end

function M.close_all_terminals()
  if not pcall(require, "toggleterm.terminal") then
    return
  end
  for _, term in ipairs(require("toggleterm.terminal").get_all(true)) do
    if term:is_open() then
      term:close()
    end
  end
end

function M.close_neotree()
  pcall(function()
    require("neo-tree.command").execute({ action = "close" })
  end)
end

function M.get_terminal(id, direction, size, display_name)
  local terms = require("toggleterm.terminal")
  local term = terms.get(id, true)
  if term then
    return term
  end
  return terms.Terminal:new({
    id = id,
    direction = direction,
    size = size,
    display_name = display_name,
    close_on_exit = true,
    start_in_insert = false,
  })
end

function M.open_terminal(id, direction, size, display_name)
  local term = M.get_terminal(id, direction, size, display_name)
  if not term:is_open() then
    term:open(size, direction)
  end
  return term
end

function M.smart_focus(direction)
  local ok, smart = pcall(require, "smart-splits")
  if not ok then
    return false
  end
  if direction == "down" then
    smart.move_cursor_down()
  elseif direction == "right" then
    smart.move_cursor_right()
  elseif direction == "up" then
    smart.move_cursor_up()
  elseif direction == "left" then
    smart.move_cursor_left()
  end
  return true
end

function M.toggle_neotree()
  local win = M.find_window(M.is_neotree_window)
  if win then
    if vim.api.nvim_get_current_win() == win then
      M.close_neotree()
      M.focus_editor()
    else
      vim.api.nvim_set_current_win(win)
    end
  else
    pcall(function()
      require("neo-tree.command").execute({ action = "focus", source = "filesystem" })
    end)
  end
end

function M.focus_neotree()
  -- Open (if needed) and focus the file tree. Never hides it.
  pcall(function()
    require("neo-tree.command").execute({ action = "focus", source = "filesystem" })
  end)
end

function M.toggle_neotree_show()
  -- Toggle visibility WITHOUT stealing focus: show unfocused if hidden, close if shown.
  local win = M.find_window(M.is_neotree_window)
  if win then
    M.close_neotree()
  else
    pcall(function()
      require("neo-tree.command").execute({ action = "show", source = "filesystem" })
    end)
  end
end

function M.toggle_terminal(id, direction, size, display_name)
  local win = M.term_window_for_id(id)
  if win then
    if vim.api.nvim_get_current_win() == win then
      require("toggleterm").toggle(id)
      M.focus_editor()
    else
      vim.api.nvim_set_current_win(win)
    end
  else
    local editor = M.center_editor_win()
    if editor then
      vim.api.nvim_set_current_win(editor)
    end
    M.open_terminal(id, direction, size, display_name)
    vim.schedule(function()
      local new_win = M.term_window_for_id(id)
      if new_win then
        vim.api.nvim_set_current_win(new_win)
      end
    end)
  end
end

function M.toggle_shell()
  if M.in_wezterm() then
    M.smart_focus("down")
    return
  end
  M.toggle_terminal(M.term_shell_id, "horizontal", 15, "Shell")
end

function M.toggle_claude()
  if M.in_wezterm() then
    M.smart_focus("right")
    return
  end
  M.toggle_terminal(
    M.term_claude_id,
    "vertical",
    math.max(28, math.floor(vim.o.columns * 0.2)),
    "Claude"
  )
end

function M.editor_buffers()
  local bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf)
      and vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buflisted
    then
      local ft = vim.bo[buf].filetype
      if vim.bo[buf].buftype == "" and not SKIP_FT[ft] then
        local info = vim.fn.getbufinfo(buf)[1]
        bufs[#bufs + 1] = { buf = buf, lastused = info and info.lastused or 0 }
      end
    end
  end
  table.sort(bufs, function(a, b)
    return a.lastused > b.lastused
  end)
  local out = {}
  for i, entry in ipairs(bufs) do
    out[i] = entry.buf
  end
  return out
end

function M.goto_buffer_slot(n)
  -- Resolve slot n from bufferline's rendered order so the number shown on a
  -- buffer is the same n that jumps to it. Fall back to the MRU list if
  -- bufferline isn't loaded.
  local buf
  local ok, bufferline = pcall(require, "bufferline")
  if ok then
    local elements = bufferline.get_elements().elements
    buf = elements[n] and elements[n].id
  end
  buf = buf or M.editor_buffers()[n]
  if not buf then
    return
  end
  if not vim.api.nvim_buf_is_loaded(buf) then
    vim.api.nvim_buf_load(buf)
  end
  local win = vim.fn.bufwinid(buf)
  if win > 0 and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  else
    M.focus_editor()
    vim.api.nvim_set_current_buf(buf)
  end
end

function M.apply_nvim_layout()
  M.close_all_terminals()
  M.close_neotree()

  vim.cmd("only")
  if #vim.fn.argv() == 0 then
    pcall(vim.cmd, "enew")
  end

  pcall(function()
    require("neo-tree.command").execute({ action = "show", source = "filesystem" })
  end)

  M.focus_editor()
end

function M.apply_default_layout()
  local skip = vim.g.started_with_layout
  if skip == false or skip == 0 then
    return
  end

  vim.schedule(function()
    M.apply_nvim_layout()
    M.reset_wezterm_panes()
  end)
end

function M.reset_layout()
  M.apply_default_layout()
end

return M
