
-- Package manager. https://github.com/savq/paq-nvim
require "paq" {
    -- paq options:
    -- as - name a package
    -- branch - repo branch
    -- opt - set to optional (lazy loading)
    -- pin - do not update
    -- run - run after install/update
    -- url - url of remote repo.
    'savq/paq-nvim';                  -- Let Paq manage itself
    'euclidianAce/BetterLua.vim';     -- Lua improvements
    'svermeulen/vimpeccable';         -- Adds vimp utility module
    -- {'ms-jpq/chadtree', branch='chad', run = 'python -m chadtree deps'};                -- Better NerdTree
    { 'neoclide/coc.nvim', branch = 'release'}; -- Completion engine
    'airblade/vim-gitgutter';         -- Git status of changed lines to the left.
    'cfdrake/vim-pbxproj';            -- Syntax highlight for pbxproj (TODO switch to treesitter later)

    'christoomey/vim-tmux-navigator'; -- Send text to tmux pane
    'christoomey/vim-tmux-runner';    -- Send text to tmux pane
    'kien/ctrlp.vim';                 -- Fuzzy file opener
    'plasticboy/vim-markdown';        -- Markdown utility, go to link and so on.
    'mhinz/vim-startify';             -- Startscreen.
    'scrooloose/nerdtree';            -- File explorer
    'tpope/vim-commentary';           -- Commenter/uncommenter
    'tpope/vim-surround';             -- Change surrounding.

    'vim-syntastic/syntastic';        -- External syntax checkers, like linters and so on.
    'romainl/vim-cool';               -- Disable search highlight after searching.
    { 'numirias/semshi', run = ':UpdateRemotePlugins<CR>'}; -- Semantic highligting for python.
    'neovimhaskell/haskell-vim';      -- Haskell
    'eagletmt/ghcmod-vim';            -- More haskell
    'vim-ruby/vim-ruby';              -- Ruby

    -- nvim lsp
    'neovim/nvim-lspconfig';
    'prabirshrestha/async.vim';
    -- 'prabirshrestha/asyncomplete-lsp.vim'; -- Clashes with Coc
    -- 'prabirshrestha/asyncomplete.vim';     -- Clashes with Coc
    'prabirshrestha/vim-lsp';
    'keith/swift.vim';
}

local opt = vim.opt
local cmd = vim.cmd
local g = vim.g
local api = vim.api
local HOME = os.getenv("HOME")

-- Set colorscheme
api.nvim_command('colorscheme monokai')

-- Set leader to <space>
g.mapleader = " "

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
opt.hidden = true -- Don't ask to save when changing buffers (i.e. when jumping to a type definition)

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

-- Lua does not have support for autogroups yet.
cmd([[
augroup onWrite
    " Set cursor position to old spot
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe  "normal! g'\"" | endif

    " Clear trailing space
    autocmd BufWritePre * :%s/\s\+$//e
augroup END
]])

-- Globals

g.ctrlp_map = '<leader>o'
g.Powerline_symbols = 'fancy'
g.syntastic_always_populate_loc_list = 1
g.syntastic_auto_loc_list = 0
g.syntastic_check_on_open = 0
g.syntastic_check_on_wq = 0
g.syntastic_aggregate_errors = 1
g.clang_library_path='/Library/Developer/CommandLineTools/usr/lib/'
g.ctrlp_cmd = 'CtrlP'
g.markdown_enable_spell_checking = 0

g.python_host_prog='~/.pyenv/shims/python'
g.python2_host_prog='/usr/local/bin/python2'
g.python3_host_prog='~/.pyenv/shims/python3'

-- -- LSP bindings
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'sourcekit' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
