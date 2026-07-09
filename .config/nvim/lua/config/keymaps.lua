local layout = function()
  return require("config.layout")
end

local function snacks_picker()
  return Snacks or require("snacks")
end

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- Leader fallbacks (always work in WezTerm terminal Neovim)
map("n", "<leader>el", function() layout().focus_neotree() end, "Focus / open file tree")
map("n", "<leader>er", function() layout().toggle_claude() end, "Toggle Claude terminal")
map("n", "<leader>eb", function() layout().toggle_neotree_show() end, "Show / hide file tree (no focus)")
map("n", "<leader>fe", function() layout().focus_editor() end, "Focus editor")
map("n", "<leader>p", function() snacks_picker().picker.files() end, "Quick open file")
map("n", "<leader>sg", function() snacks_picker().picker.grep() end, "Search in project")
map("n", "<leader>rg", function() snacks_picker().picker.grep() end, "Search in project (ripgrep)")

for i = 1, 9 do
  map("n", "<leader>" .. i, function() layout().goto_buffer_slot(i) end, "Buffer " .. i)
end

-- Cmd+W → close buffer if focused on a regular buffer, otherwise close tab.
-- If closing the last listed buffer, open a new empty buffer instead so the
-- editor window stays alive (prevents neo-tree from targeting the minimap pane).
local function close_buffer_or_tab()
  local ft = vim.bo.filetype
  local buftype = vim.bo.buftype
  if buftype == "" and ft ~= "neo-tree" and ft ~= "toggleterm" then
    local cur = vim.api.nvim_get_current_buf()
    local remaining = vim.tbl_filter(function(b)
      return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and b ~= cur
    end, vim.api.nvim_list_bufs())
    if #remaining == 0 then
      vim.cmd("enew")
    end
    vim.cmd("bdelete " .. cur)
  else
    vim.cmd("quit")
  end
end
map("n", "<D-w>", close_buffer_or_tab, "Close buffer or tab")

-- Cmd+Alt+Arrows → resize focused split (matches WezTerm pane resize chord)
local function smart_resize(direction)
  return function()
    local ok, smart = pcall(require, "smart-splits")
    if not ok then return end
    if direction == "left"  then smart.resize_left(3)
    elseif direction == "right" then smart.resize_right(3)
    elseif direction == "up"    then smart.resize_up(3)
    elseif direction == "down"  then smart.resize_down(3)
    end
  end
end
map("n", "<D-M-Left>",  smart_resize("left"),  "Shrink split left")
map("n", "<D-M-Right>", smart_resize("right"), "Grow split right")
map("n", "<D-M-Up>",    smart_resize("up"),    "Grow split up")
map("n", "<D-M-Down>",  smart_resize("down"),  "Shrink split down")

-- VS Code-style move-line aliases. LazyVim already ships <A-j>/<A-k>;
-- these add Alt-Up/Alt-Down for muscle memory.
map("n", "<A-Up>",   "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", "Move line up")
map("n", "<A-Down>", "<cmd>execute 'move .+' . v:count1<cr>==",       "Move line down")
map("i", "<A-Up>",   "<esc><cmd>m .-2<cr>==gi", "Move line up")
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", "Move line down")
vim.keymap.set("v", "<A-Up>",
  ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
  { desc = "Move line up", silent = true })
vim.keymap.set("v", "<A-Down>",
  ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",
  { desc = "Move line down", silent = true })

-- Minimap toggle (uses neominimap.nvim; defined in plugins/ui.lua)
map("n", "<leader>mm", "<cmd>Neominimap Toggle<cr>", "Toggle minimap")

-- Treesitter function motions (nvim-treesitter main branch).
-- ]f / [f = next / prev function start; ]F / [F = next / prev function end.
-- Set after plugins load so the move API is available; guarded with pcall.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
    if not ok then return end
    local function tsmap(lhs, fn, query, desc)
      vim.keymap.set({ "n", "x", "o" }, lhs, function()
        fn(query, "textobjects")
      end, { desc = desc, silent = true })
    end
    tsmap("]f", move.goto_next_start, "@function.outer", "Next function start")
    tsmap("[f", move.goto_previous_start, "@function.outer", "Prev function start")
    tsmap("]F", move.goto_next_end, "@function.outer", "Next function end")
    tsmap("[F", move.goto_previous_end, "@function.outer", "Prev function end")
  end,
})

