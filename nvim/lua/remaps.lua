local g = vim.g
local api = vim.api

-- Set leader to <space>
g.mapleader = ' '

-- Remapping utility.
local vimp = require('vimp')

-- Insert remaps.

-- vimp.inoremap('tn', '<ESC>')
-- Makes so that indendation does not disappear when entering a new line.
vimp.inoremap('<CR>', '<CR>a<BS>')
-- Complete file name
vimp.inoremap('<C-F>', '<C-X><C-F>')
-- Complete line
vimp.inoremap('<C-L>', '<C-X><C-L>')
-- Complete from definition
vimp.inoremap('<C-D>', '<C-X><C-D>')
-- Omni complete
vimp.inoremap('<C-O>', '<C-X><C-O>')
-- Go to tag
vimp.inoremap('<C-]>', '<C-X><C-]>')

-- Switch v and V behavior.
vimp.nnoremap('v', 'V')
vimp.nnoremap('V', 'v')


-- Move lines up and down. When in visual mode, move the selected lines.
vimp.vnoremap('J', ":m '>+1<CR>gv=gv")
vimp.vnoremap('K', ":m '<-2<CR>gv=gv")

-- Never use Q for ex mode.
vimp.nnoremap('Q', '<nop>')

-- Map p & P to paste and indent
-- vimp.nnoremap('p', ']p')
-- vimp.nnoremap('P', '[P')

-- Map ]p & [P to ordinary paste
-- vimp.nnoremap(']p', 'p')
-- vimp.nnoremap('[P', 'P')

-- Terminal remap escape
-- vimp.tnoremap('<Esc>', '<C-\\><C-n>')

-- Normal remaps

-- Should be made into a Lua function later, but split commas to newlines. f(a, b, c) -> f(a,\nb,\nc\n)
vimp.nnoremap('<leader>a', "ma:s/, /,\\r/g<cr>'af(=%f(a<cr><esc>'af(%i<cr><esc>'a")

vimp.nnoremap('<leader>n', ':cnext <cr>') -- Go to next error
vimp.nnoremap('<leader>N', ':cprev <cr>') -- Go to previous issueerror

vimp.nnoremap('<F12>', ':%s/\\<<C-r><C-w>\\>//g<Left><Left>') -- Rename word under cursor

vimp.nnoremap('<leader>j', ':NvimTreeFindFile<CR>') -- Show current file in NerdTree

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

vimp.nnoremap('<leader>f', ':Telescope live_grep<CR>')  -- live grep search
vimp.nnoremap('<leader>F', ':Telescope resume<CR>')     -- Resume last telescope search
vimp.nnoremap('<leader>o', ':Telescope find_files<CR>') -- live find files
vimp.nnoremap('<leader>s', ':Telescope lsp_document_symbols<CR>') -- live find symbols
vimp.nnoremap('<Leader>O', ':lua require"telescope.builtin".find_files({ hidden = true })<CR>') -- live find files (including hidden files)

-- vimp.nnoremap('gd', 'g<C-]>') -- go to tag

local tb = require('telescope.builtin')

-- Open the current selection in a Telescope live_grep buffer
-- vimp.vnoremap({'expr', 'silent'}, '<leader>f', function()
-- 	local text = vim.getVisualSelection()
-- 	tb.live_grep({ default_text = text })
-- end)


vimp.nnoremap('<leader>ha', ':lua require("harpoon.mark").add_file()<CR>') -- Add file to harpoon
vimp.nnoremap('<leader>hh', ':lua require("harpoon.ui").toggle_quick_menu()<CR>') -- Toggle harpoon menu
vimp.nnoremap('<leader>hn', ':lua require("harpoon.ui").nav_next()<CR>') -- Navigate to next harpoon mark
vimp.nnoremap('<leader>hp', ':lua require("harpoon.ui").nav_prev()<CR>') -- Navigate to previous harpoon mark

