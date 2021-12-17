local g = vim.g
local api = vim.api

-- Set leader to <space>
g.mapleader = " "

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

-- Makes so that indendation does not disappear when entering normal mode.
vimp.nnoremap('o', 'oa<BS>')
vimp.nnoremap('O', 'Oa<BS>')

-- Map H & L to go back and go forward.
vimp.nnoremap('H', '<C-O>')
vimp.nnoremap('L', '<C-I>')

-- Do not let paragraph-wise movement affect jumps as it just boggles up H and L movements.
vimp.nnoremap('}', ':silent! exec "keepjumps normal! }"<CR>')
vimp.nnoremap('{', ':silent! exec "keepjumps normal! {"<CR>')

-- Terminal remap escape
vimp.tnoremap('<Esc>', '<C-\\><C-n>')

-- Normal remaps

-- Should be made into a Lua function later, but split commas to newlines. f(a, b, c) -> f(a,\nb,\nc\n)
vimp.nnoremap('<leader>a', "ma:s/, /,\\r/g<cr>'af(=%f(a<cr><esc>'af(%i<cr><esc>'a")


vimp.nnoremap('<leader>n', ':cnext <cr>') -- Go to next error
vimp.nnoremap('<leader>N', ':cprev <cr>') -- Go to previous issueerror

vimp.nnoremap('<F12>', ':%s/\\<<C-r><C-w>\\>//g<Left><Left>') -- Rename word under cursor

vimp.nnoremap('K', 'kJ') -- Remap K to be the inverse of J
vimp.nnoremap('<leader>j', ':NERDTreeFind<CR>') -- Show current file in NerdTree

api.nvim_command('command W w') -- Remap :W to :w
api.nvim_command('command NT :NERDTreeToggle') -- Toggle NerdTree with :NT
