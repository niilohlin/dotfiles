
-- lazy.nvim

return require('lazy').setup({
  -- Adds vimp utility module
  'svermeulen/vimpeccable',
  -- Git status of changed lines to the left.
  'airblade/vim-gitgutter',
  -- Git plugin
  'tpope/vim-fugitive',
  -- Syntax highlight for pbxproj (TODO switch to treesitter later)
  -- 'cfdrake/vim-pbxproj'
  -- Send text to tmux pane
  'christoomey/vim-tmux-navigator',
  -- Send text to tmux pane
  'christoomey/vim-tmux-runner',
  -- Markdown utility, go to link and so on.
  'plasticboy/vim-markdown',
  -- Startscreen.
  'mhinz/vim-startify',
  --
  -- File explorer
  'nvim-tree/nvim-tree.lua',

  -- nvim Commenter/uncommenter (replaces vim-commentary)
  { 'numToStr/Comment.nvim', opts = {}, lazy = false },
  -- Change surrounding.
  'tpope/vim-surround',
  -- fuzzy file finder
  'junegunn/fzf',
  -- fzf binding
  'junegunn/fzf.vim',
  -- project wide search, requires ripgrep
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }},
  -- Silversearcher plugin (search project)
  { 'kelly-lin/telescope-ag', dependencies = { 'nvim-telescope/telescope.nvim' } },
  -- Disable search highlight after searching.
  'romainl/vim-cool',

  -- Quick File Switcher
  { 'ThePrimeagen/harpoon', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Better syntax highlighting
  { 'nvim-treesitter/nvim-treesitter' },

  -- Treesitter playground, for interactive evaluation of the current syntax tree in tree-sitter
  'nvim-treesitter/playground',

  -- Monokai with treesitter support
  'tanvirtin/monokai.nvim',

  -- Yaml utility, helps distinguish indendation
  'Einenlum/yaml-revealer',

  -- Github Copilot, AI completions
  'github/copilot.vim',

  -- LSP setup
  'neovim/nvim-lspconfig',

  -- LSP completion
  'hrsh7th/nvim-cmp',

  -- LSP completion
  'hrsh7th/cmp-nvim-lsp',

  -- snip manager required by nvim-cmp
  'L3MON4D3/LuaSnip',

  -- Linter spawner and parser
  'mfussenegger/nvim-lint',
})

