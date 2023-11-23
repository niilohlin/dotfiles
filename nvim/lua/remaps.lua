local g = vim.g
local api = vim.api

-- Set leader to <space>
g.mapleader = ' '

-- Remapping utility.
local vimp = require('vimp')

-- Insert remaps.

vimp.inoremap('tn', '<ESC>')
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

-- Map H & L to go back and go forward.
-- vimp.nnoremap('H', '<C-O>')
-- vimp.nnoremap('L', '<C-I>')

-- Map p & P to paste and indent
-- vimp.nnoremap('p', ']p')
-- vimp.nnoremap('P', '[P')

-- Map ]p & [P to ordinary paste
-- vimp.nnoremap(']p', 'p')
-- vimp.nnoremap('[P', 'P')

-- Do not let paragraph-wise movement affect jumps as it just boggles up <C-O> and <C-L> movements.
-- vimp.nnoremap('}', ':silent! exec "keepjumps normal! }"<CR>')
-- vimp.nnoremap('{', ':silent! exec "keepjumps normal! {"<CR>')

-- Terminal remap escape
-- vimp.tnoremap('<Esc>', '<C-\\><C-n>')

-- Normal remaps

-- Should be made into a Lua function later, but split commas to newlines. f(a, b, c) -> f(a,\nb,\nc\n)
vimp.nnoremap('<leader>a', "ma:s/, /,\\r/g<cr>'af(=%f(a<cr><esc>'af(%i<cr><esc>'a")

vimp.nnoremap('<leader>n', ':cnext <cr>') -- Go to next error
vimp.nnoremap('<leader>N', ':cprev <cr>') -- Go to previous issueerror

vimp.nnoremap('<F12>', ':%s/\\<<C-r><C-w>\\>//g<Left><Left>') -- Rename word under cursor

vimp.nnoremap('<leader>j', ':NvimTreeFindFile<CR>') -- Show current file in NerdTree

api.nvim_command('command W w') -- Remap :W to :w
api.nvim_command('command NT :NvimTreeToggle') -- Toggle nvim-tree with :NT

vimp.nnoremap('<leader>f', ':Telescope live_grep<CR>')  -- live grep search
vimp.nnoremap('<leader>F', ':Telescope resume<CR>')     -- Resume last telescope search
vimp.nnoremap('<leader>o', ':Telescope find_files<CR>') -- live find files

-- vimp.nnoremap('gd', 'g<C-]>') -- go to tag

local tb = require('telescope.builtin')

-- Open the current selection in a Telescope live_grep buffer
-- vimp.vnoremap({'expr', 'silent'}, '<leader>f', function()
-- 	local text = vim.getVisualSelection()
-- 	tb.live_grep({ default_text = text })
-- end)

