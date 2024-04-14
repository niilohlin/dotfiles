local g = vim.g
local api = vim.api

-- Set leader to <space>
g.mapleader = ' '

-- Insert remaps.
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

-- Normal remaps

vim.keymap.set('n', '<leader>n', ':cnext <cr>') -- Go to next error
vim.keymap.set('n', '<leader>p', ':cprev <cr>') -- Go to previous issueerror

vim.keymap.set('n', '<leader>j', ':Explore<CR>') -- Show current file in NerdTree

vim.keymap.set('n', '<leader>K', vim.diagnostic.open_float)

vim.keymap.set('n', '<leader>gd', ':GitGutterUndoHunk<CR>') -- Discard git

vim.keymap.set('v', '<leader>p', '"_dP') -- Paste without copying to clipboard

api.nvim_command('command W w') -- Remap :W to :w
api.nvim_command('command NT lua Open_netrw_in_split()')

vim.keymap.set('n', '<leader>f', ':Telescope live_grep<CR>')  -- live grep search
vim.keymap.set('n', '<leader>F', ':Telescope resume<CR>')     -- Resume last telescope search
vim.keymap.set('n', '<leader>o', ':Telescope find_files<CR>') -- live find files
vim.keymap.set('n', '<Leader>O', ':lua require"telescope.builtin".find_files({ hidden = true })<CR>') -- live find files (including hidden files)
vim.keymap.set('n', '<Leader>;', ':Telescope oldfiles<CR>') -- Open old files
vim.keymap.set('n', '<leader>s', ':Telescope lsp_document_symbols<CR>') -- live find symbols
vim.keymap.set('n', '<leader>b', ':Telescope buffers<CR>') -- Open buffers

-- disable { and } to untrain myself from using them
vim.keymap.set('n', '{', '<nop>')
vim.keymap.set('n', '}', '<nop>')

vim.keymap.set('n', 'H', ':FileJumpBackward<CR>') --
vim.keymap.set('n', 'L', ':FileJumpForward<CR>') --

