-- Set colorscheme
local monokai = require('monokai')

local palette = require('monokai').classic
palette['base2'] = 'none'

monokai.setup {
  palette = palette
}

local syntax = require('monokai').load_syntax(palette)

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none', fg = syntax['Normal']['fg'] })      -- Set the background for "Normal text" (i.e. text without highlighting to none)
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none', fg = syntax['Normal']['fg'] }) -- Normal text in floating windows
