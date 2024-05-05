-- lazy.nvim package manager

return require('lazy').setup({
  -- Git status of changed lines to the left.
  'airblade/vim-gitgutter',

  -- Git plugin
  'tpope/vim-fugitive',

  -- Syntax highlight for pbxproj (TODO switch to treesitter later)
  'cfdrake/vim-pbxproj',

  -- Send text to tmux pane
  'christoomey/vim-tmux-navigator',

  -- Send text to tmux pane
  'christoomey/vim-tmux-runner',

  -- Markdown utility, go to link and so on.
  'plasticboy/vim-markdown',

  -- nvim Commenter/uncommenter (replaces vim-commentary)
  { 'numToStr/Comment.nvim',                    lazy = false },

  -- Change surrounding.
  'tpope/vim-surround',

  -- Reapeat surround commands
  'tpope/vim-repeat',

  -- -- fuzzy file finder
  'junegunn/fzf',

  -- fzf binding
  'junegunn/fzf.vim',

  -- project wide search, requires ripgrep
  { 'nvim-telescope/telescope.nvim',            dependencies = { 'nvim-lua/plenary.nvim' } },

  -- fzf native plugin, make it possible to fuzzy search in telescope
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

  -- Silversearcher plugin (search project)
  { 'kelly-lin/telescope-ag',                   dependencies = { 'nvim-telescope/telescope.nvim' } },

  -- Disable search highlight after searching.
  'romainl/vim-cool',

  -- Better syntax highlighting
  'nvim-treesitter/nvim-treesitter',

  -- Treesitter text objects
  'nvim-treesitter/nvim-treesitter-textobjects',

  -- Treesitter playground, for interactive evaluation of the current syntax tree in tree-sitter
  'nvim-treesitter/playground',

  -- Monokai with treesitter support
  'tanvirtin/monokai.nvim',

  -- Yaml utility, helps distinguish indendation
  'Einenlum/yaml-revealer',

  -- Github Copilot, AI completions
  'github/copilot.vim',

  -- Better wild menu, while typing
  'hrsh7th/cmp-cmdline',

  -- Make anything into an lsp, like linter output etc.
  'mfussenegger/nvim-lint',

  -- LSP setup
  'neovim/nvim-lspconfig',

  -- Generic log highlighting
  'MTDL9/vim-log-highlighting',

  -- Vim trainer
  'ThePrimeagen/vim-be-good',

  -- -- Targets, text objects, adds objects like ci,
  -- 'wellle/targets.vim',

  -- Indent object, adds objects like ai "delete around indent"
  'michaeljsmith/vim-indent-object',

  -- LSP completion
  -- This version is compatible with nvim 0.9.x master requires 0.10
  { 'hrsh7th/nvim-cmp' },

  -- LSP completion
  'hrsh7th/cmp-nvim-lsp',

  -- snip manager required by nvim-cmp
  {
    'L3MON4D3/LuaSnip',
    -- follow latest release.
    version = 'v2.3.0',
    -- install jsregexp (optional!).
    -- build = "make install_jsregexp"
  },

  -- Linter spawner and parser
  'mfussenegger/nvim-lint',
})
