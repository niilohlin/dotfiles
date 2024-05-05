local HOME = os.getenv("HOME")
local cmd = vim.cmd

local opt = vim.opt
-- options
opt.showcmd = true                   -- Show the current command in the bottom right
opt.incsearch = true                 -- Incremental search
opt.showmatch = true                 -- Highlight search match
opt.ignorecase = true                -- Ignore search casing
opt.smartcase = true                 -- But not when searching with uppercase letters
opt.smartindent = true               -- Language-aware indent
opt.autowrite = true                 -- Automatically write on :n and :p
opt.autoread = true                  -- Automatically read file from disk on change
cmd([[ au CursorHold * checktime ]]) -- When idle, check time and check if the file has changed from disk
opt.number = true                    -- Set line numbers
opt.relativenumber = true            -- Set relative line numbers
opt.backspace = "2"                  -- Make backspace work as expected in insert mode.
opt.ruler = true                     -- Show cursor col and row position
opt.colorcolumn = "120"              -- Show max column highlight.
opt.modifiable = true                -- Make buffers modifiable.
opt.cursorline = true                -- Show a horizontal line where the cursor is
opt.splitbelow = true                -- Show the preview window (code documentation) to the bottom of the screen.
opt.wildmenu = true                  -- Show a menu when using tab completion in command mode.
opt.wildmode = { "longest", "full" }

-- This setting controls how long to wait (in ms) before fetching type / symbol information.
opt.updatetime = 500
-- -- Remove 'Press Enter to continue' message when type information is longer than one line.
opt.cmdheight = 2
-- opt.cmdheight = 0          -- Hide the command line when not needed.

-- Handle tabs, expand to 4 spaces.
local tabLength = 4
opt.tabstop = tabLength
opt.shiftwidth = tabLength
opt.softtabstop = tabLength
opt.expandtab = true

opt.list = true -- Show whitespace characters.
opt.listchars = { tab = '› ', trail = '·', extends = '›', precedes = '‹', nbsp = '+' } -- Show these characters
opt.whichwrap = opt.whichwrap + "<,>,[,],l,h" -- Move cursor to next line when typing these characters.

opt.undofile = true -- Use undo file
opt.undodir = HOME .. '/.config/nvim/undodir' -- Set undo dir
opt.scrolloff = 1 -- Scroll 1 line before cursor hits bottom
opt.mouse = "" -- Disable mouse

local g = vim.g
g.markdown_enable_spell_checking = 0

g.python_host_prog = '~/.local/share/mise/installs/python/3/bin/python3'
g.python2_host_prog = '/usr/local/bin/python2'
g.python3_host_prog = '~/.local/share/mise/installs/python/3/bin/python3'
