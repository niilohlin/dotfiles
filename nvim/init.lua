
require "paq" {
    'savq/paq-nvim';                  -- Let Paq manage itself
    'euclidianAce/BetterLua.vim';
    'svermeulen/vimpeccable'
}

local opt = vim.opt
local cmd = vim.cmd
local g = vim.g
local HOME = os.getenv("HOME")

cmd('source ~/.config/nvim/vimrc')
vim.api.nvim_command('colorscheme monokai')

-- options

opt.showcmd = true
opt.incsearch = true
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true
opt.smartindent = true
opt.autowrite = true
opt.number = true
opt.relativenumber = true
opt.backspace = "2"
opt.ruler = true
opt.showcmd = true
opt.colorcolumn = "120"
opt.modifiable = true


-- handle tabs
local tabLength = 4
opt.tabstop = tabLength
opt.shiftwidth = tabLength
opt.softtabstop = tabLength
opt.expandtab = true

opt.list = true
opt.whichwrap = opt.whichwrap + "<,>,[,],l,h"

opt.undofile = true
opt.undodir = HOME .. "/.config/nvim/undodir"
opt.scrolloff = 1

opt.listchars = { tab = '› ', trail = '·', extends ='›', precedes = '‹', nbsp = '+' }


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

-- Terminal remap escape
vimp.tnoremap('<Esc>', '<C-\\><C-n>')
