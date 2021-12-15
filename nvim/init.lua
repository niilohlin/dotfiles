
-- Package manager. https://github.com/savq/paq-nvim
require "paq" {
    'savq/paq-nvim';                  -- Let Paq manage itself
    'euclidianAce/BetterLua.vim';     -- Lua improvements
    'svermeulen/vimpeccable';         -- Adds vimp utility module
}

local opt = vim.opt
local cmd = vim.cmd
local g = vim.g
local api = vim.api
local HOME = os.getenv("HOME")

-- Legacy config
cmd('source ~/.config/nvim/vimrc')
-- Set colorscheme
api.nvim_command('colorscheme monokai')

-- options
opt.showcmd = true          -- Show the current command in the bottom right
opt.incsearch = true        -- Incremental search
opt.showmatch = true        -- Highlight search match
opt.ignorecase = true       -- Ignore search casing
opt.smartcase = true        -- But not when searching with uppercase letters
opt.smartindent = true      -- Language-aware indent
opt.autowrite = true        -- Automatically write on :n and :p
opt.number = true           -- Set line numbers
opt.relativenumber = true   -- Set relative line numbers
opt.backspace = "2"         -- Make backspace work as expected in insert mode.
opt.ruler = true            -- Show cursor col and row position
opt.colorcolumn = "120"     -- Show max column highlight.
opt.modifiable = true       -- Make buffers modifiable.


-- Handle tabs, expand to 4 spaces.
local tabLength = 4
opt.tabstop = tabLength
opt.shiftwidth = tabLength
opt.softtabstop = tabLength
opt.expandtab = true

opt.list = true                                 -- Show whitespace characters.
opt.listchars = { tab = '› ', trail = '·', extends ='›', precedes = '‹', nbsp = '+' } -- Show these characters
opt.whichwrap = opt.whichwrap + "<,>,[,],l,h"   -- Move cursor to next line when typing these characters.

opt.undofile = true                             -- Use undo file
opt.undodir = HOME .. "/.config/nvim/undodir"   -- Set undo dir
opt.scrolloff = 1                               -- Scroll 1 line before cursor hits bottom


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

-- Terminal remap escape
vimp.tnoremap('<Esc>', '<C-\\><C-n>')
