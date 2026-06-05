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
map("n", "<leader>el", function() layout().toggle_neotree() end, "Toggle file tree")
map("n", "<leader>er", function() layout().toggle_claude() end, "Toggle Claude terminal")
map("n", "<leader>eb", function() layout().toggle_shell() end, "Toggle bottom terminal")
map("n", "<leader>fe", function() layout().focus_editor() end, "Focus editor")
map("n", "<leader>p", function() snacks_picker().picker.files() end, "Quick open file")
map("n", "<leader>sg", function() snacks_picker().picker.grep() end, "Search in project")

for i = 1, 9 do
  map("n", "<leader>" .. i, function() layout().goto_buffer_slot(i) end, "Buffer " .. i)
end

