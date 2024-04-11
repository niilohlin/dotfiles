
-- lazy.nvim

return require('lazy').setup({
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

  -- nvim Commenter/uncommenter (replaces vim-commentary)
  { 'numToStr/Comment.nvim', opts = {}, lazy = false },
  -- Change surrounding.
  'tpope/vim-surround',

  -- -- fuzzy file finder
  'junegunn/fzf',
  -- -- fzf binding
  'junegunn/fzf.vim',
  -- project wide search, requires ripgrep
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }},
  -- fzf native plugin, make it possible to fuzzy search in telescope
  -- { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  -- Silversearcher plugin (search project)
  { 'kelly-lin/telescope-ag', dependencies = { 'nvim-telescope/telescope.nvim' } },
  -- Disable search highlight after searching.
  'romainl/vim-cool',

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

  -- Better wild menu, while typing
  'gelguy/wilder.nvim',

  -- Make anything into an lsp, like linter output etc.
  'mfussenegger/nvim-lint',

  -- LSP setup
  'neovim/nvim-lspconfig',

  -- Local jump list experimental plugin
  { dir = '~/workspace/file-jumps', lazy = false },

  -- LSP completion
  -- This version is compatible with nvim 0.9.x master requires 0.10
  { 'hrsh7th/nvim-cmp', version = '763c720d512516c4af25a510a88b2d073e3c41a9' },

  -- LSP completion
  'hrsh7th/cmp-nvim-lsp',

  -- snip manager required by nvim-cmp
  {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.1.1", -- This is not the latest release, but it works.
      -- install jsregexp (optional!).
      -- build = "make install_jsregexp"
  },

  -- Linter spawner and parser
  'mfussenegger/nvim-lint',
})

