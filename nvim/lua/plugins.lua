
-- Package manager. https://github.com/savq/paq-nvim

-- Only required if you have packer configured as `opt`

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- let Packer manage itself
  use 'wbthomason/packer.nvim'
  -- Adds vimp utility module
  use 'svermeulen/vimpeccable'
  -- Git status of changed lines to the left.
  use 'airblade/vim-gitgutter'
  -- Git plugin
  use 'tpope/vim-fugitive'
  -- Syntax highlight for pbxproj (TODO switch to treesitter later)
  -- use 'cfdrake/vim-pbxproj'
  -- Send text to tmux pane
  use 'christoomey/vim-tmux-navigator'
  -- Send text to tmux pane
  use 'christoomey/vim-tmux-runner'
  -- Markdown utility, go to link and so on.
  use 'plasticboy/vim-markdown'
  -- Startscreen.
  use 'mhinz/vim-startify'
  --
  -- File explorer
  use 'nvim-tree/nvim-tree.lua'

  -- nvim Commenter/uncommenter (replaces vim-commentary)
  use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }
  -- Change surrounding.
  use 'tpope/vim-surround'
  -- fuzzy file finder
  use 'junegunn/fzf'
  -- fzf binding
  use 'junegunn/fzf.vim'
  -- project wide search
  use({ 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/plenary.nvim' } }, run = 'which ripgrep || brew install ripgrep'})
  -- Silversearcher plugin (search project)
  use({ 'kelly-lin/telescope-ag', requires = { { 'nvim-telescope/telescope.nvim' } } })
  -- Disable search highlight after searching.
  use 'romainl/vim-cool'

  -- Quick File Switcher
  use({ 'ThePrimeagen/harpoon', requires = { { 'nvim-lua/plenary.nvim' } } })

  -- Better syntax highlighting
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  -- Treesitter playground, for interactive evaluation of the current syntax tree in tree-sitter
  use { 'nvim-treesitter/playground' }
  -- Monokai with treesitter support
  use 'tanvirtin/monokai.nvim'
  -- Yaml utility, helps distinguish indendation
  use 'Einenlum/yaml-revealer'
  -- Github Copilot, AI completions
  use 'github/copilot.vim'


  -- LSP setup
  use 'neovim/nvim-lspconfig'

  -- LSP completion
  use 'hrsh7th/nvim-cmp'
  -- LSP completion
  use 'hrsh7th/cmp-nvim-lsp'

  -- snip manager required by nvim-cmp
  use 'L3MON4D3/LuaSnip'

  -- Linter spawner and parser
  use 'mfussenegger/nvim-lint'
end)

