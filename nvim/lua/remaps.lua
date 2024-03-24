local g = vim.g
local api = vim.api

-- Set leader to <space>
g.mapleader = ' '

-- Insert remaps.
-- vim.keymap.set('i', 'tn', '<ESC>')
-- Makes so that indendation does not disappear when entering a new line.
vim.keymap.set('i', '<CR>', '<CR>a<BS>')
-- Complete file name
vim.keymap.set('i', '<C-F>', '<C-X><C-F>')
-- Complete line
vim.keymap.set('i', '<C-L>', '<C-X><C-L>')
-- Complete from definition
vim.keymap.set('i', '<C-D>', '<C-X><C-D>')
-- Omni complete
vim.keymap.set('i', '<C-O>', '<C-X><C-O>')
-- Go to tag
vim.keymap.set('i', '<C-]>', '<C-X><C-]>')

-- Switch v and V behavior.
vim.keymap.set('n', 'v', 'V')
vim.keymap.set('n', 'V', 'v')

-- Never use Q for ex mode.
vim.keymap.set('n', 'Q', '<nop>')

-- Map p & P to paste and indent
-- vim.keymap.set('n', 'p', ']p')
-- vim.keymap.set('n', 'P', '[P')

-- Map ]p & [P to ordinary paste
-- vim.keymap.set('n', ']p', 'p')
-- vim.keymap.set('n', '[P', 'P')

-- Terminal remap escape
-- vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Normal remaps

-- Should be made into a Lua function later, but split commas to newlines. f(a, b, c) -> f(a,\nb,\nc\n)
vim.keymap.set('n', '<leader>a', "ma:s/, /,\\r/g<cr>'af(=%f(a<cr><esc>'af(%i<cr><esc>'a")

vim.keymap.set('n', '<leader>n', ':cnext <cr>') -- Go to next error
vim.keymap.set('n', '<leader>N', ':cprev <cr>') -- Go to previous issueerror

vim.keymap.set('n', '<F12>', ':%s/\\<<C-r><C-w>\\>//g<Left><Left>') -- Rename word under cursor

vim.keymap.set('n', '<leader>j', ':NvimTreeFindFile<CR>') -- Show current file in NerdTree

function Open_netrw_in_split()
    -- if api.nvim_eval('exists("g:netrw_winnr")') == 1 then
    --     -- close the netrw window
    --     local i = api.nvim_command('bufwinnr(g:netrw_winnr)')
    --     api.nvim_command(i .. 'wincmd w')
    --     api.nvim_command('q')
    -- end

    api.nvim_command('vsplit')
    api.nvim_command('vertical resize 30')
    api.nvim_command('Explore')
    -- set the window id
    api.nvim_command('let g:netrw_winnr = winnr()')
end
api.nvim_command('command W w') -- Remap :W to :w
-- call Open_netrw_in_split() when :NT is called
api.nvim_command('command NT lua Open_netrw_in_split()')

vim.keymap.set('n', '<leader>f', ':Telescope live_grep<CR>')  -- live grep search
vim.keymap.set('n', '<leader>F', ':Telescope resume<CR>')     -- Resume last telescope search
vim.keymap.set('n', '<leader>o', ':Telescope find_files<CR>') -- live find files
vim.keymap.set('n', '<leader>s', ':Telescope lsp_document_symbols<CR>') -- live find symbols
vim.keymap.set('n', '<Leader>O', ':lua require"telescope.builtin".find_files({ hidden = true })<CR>') -- live find files (including hidden files)

-- vim.keymap.set('n', 'gd', 'g<C-]>') -- go to tag

local tb = require('telescope.builtin')

-- Open the current selection in a Telescope live_grep buffer
-- vim.keymap.set('v', {'expr', 'silent'}, '<leader>f', function()
-- 	local text = vim.getVisualSelection()
-- 	tb.live_grep({ default_text = text })
-- end)


vim.keymap.set('n', '<leader>ha', ':lua require("harpoon.mark").add_file()<CR>') -- Add file to harpoon
vim.keymap.set('n', '<leader>hh', ':lua require("harpoon.ui").toggle_quick_menu()<CR>') -- Toggle harpoon menu
vim.keymap.set('n', '<leader>hn', ':lua require("harpoon.ui").nav_next()<CR>') -- Navigate to next harpoon mark
vim.keymap.set('n', '<leader>hp', ':lua require("harpoon.ui").nav_prev()<CR>') -- Navigate to previous harpoon mark

