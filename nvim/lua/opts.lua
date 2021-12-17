local HOME = os.getenv("HOME")

opt = vim.opt
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
opt.wildmenu = true         -- Expanded in-line menus
opt.wildmode = { 'list', 'longest' } -- Full extended menu
opt.cursorline = true       -- Show a horizontal line where the cursor is
opt.splitbelow = true       -- Show the preview window (code documentation) to the bottom of the screen.
-- Status line, the line above the ex column TODO take a look at later and fix.
opt.statusline = '%f%#warningmsg#%{SyntasticStatuslineFlag()}%*'

-- This setting controls how long to wait (in ms) before fetching type / symbol information.
opt.updatetime = 500
-- Remove 'Press Enter to continue' message when type information is longer than one line.
opt.cmdheight = 2

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
opt.undodir = HOME .. '/.config/nvim/undodir'   -- Set undo dir
opt.scrolloff = 1                               -- Scroll 1 line before cursor hits bottom

-- opt.spellang = 'en'
-- opt.spellfile = HOME .. '/.config/nvim/spell/en.utf-8.add' -- Set custom spelling words path
