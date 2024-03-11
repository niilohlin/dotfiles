local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('custom_functions')
require('opts')
require('remaps')
require('colorscheme')
require('gui')
require('onwrite')
require('globals')
require('plugins')
require('post_plugins')
require('lsp')
require('treesitter-config')
require('lint-conf')
require('autocmd')
