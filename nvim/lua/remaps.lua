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

-- Never use Q for ex mode.
vim.keymap.set('n', 'Q', '<nop>')

-- Normal remaps
vim.keymap.set('n', '<C-U>', '<C-U>zz') -- Move cursor to middle of screen
vim.keymap.set('n', '<C-D>', '<C-D>zz') -- Move cursor to middle of screen

vim.keymap.set('n', '<leader>n', ':cnext <cr>')  -- Go to next error
vim.keymap.set('n', '<leader>p', ':cprev <cr>')  -- Go to previous issueerror

vim.keymap.set('n', '<leader>j', ':lua MiniFiles.open()<CR>') -- Show current file in mini.files

vim.keymap.set('n', '<leader>K', vim.diagnostic.open_float)

vim.keymap.set('n', '<leader>gd', ':GitGutterUndoHunk<CR>') -- Discard git

vim.keymap.set('v', '<leader>p', '"_dP')                    -- Paste without copying to clipboard

api.nvim_command('command W w')                             -- Remap :W to :w

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- find files
vim.keymap.set('n', '<leader>fr', builtin.resume, {})     -- Resume last telescope search
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})  -- live grep
vim.keymap.set('n', '<Leader>fF', function()
  builtin.find_files({ hidden = true })
end, {})                                                        -- live find files (including hidden files)
vim.keymap.set('n', '<Leader>fo', builtin.oldfiles)             -- Open old files
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols) -- live find symbols
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})          -- Open buffers
vim.keymap.set('n', '<leader>rr', ':%s/\\\\n/\\r/g<CR>')        -- Replace Returns:  Replace all \n with new lines

local function has_workspace_symbols()
  if not vim.lsp.buf_get_clients() then
    return false
  end

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.server_capabilities.workspaceSymbolProvider then
      return true
    end
  end

  return false
end

vim.keymap.set('n', '<leader>o', function()
  if has_workspace_symbols() then
    builtin.lsp_dynamic_workspace_symbols()
  elseif vim.fn.filereadable('tags') then
    builtin.tags()
  else
    builtin.live_grep()
  end
end, {}) -- Search for tags or lsp workspace symbols


-- disable { and } to untrain myself from using them
vim.keymap.set('n', '{', '<nop>')
vim.keymap.set('n', '}', '<nop>')

vim.keymap.set('n', 'g[', ':ijump <C-R><C-W><CR>') -- Jump to first occurrence of word under cursor

vim.keymap.set('n', 'gp', '`[v`]')                 -- Select last paste
