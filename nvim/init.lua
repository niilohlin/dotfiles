
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

vimp.inoremap('tn', '<ESC>')
vimp.nnoremap('v', 'V')
vimp.nnoremap('V', 'v')


