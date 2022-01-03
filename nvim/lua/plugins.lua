
-- Package manager. https://github.com/savq/paq-nvim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'         -- let Packer manage itself
  use 'euclidianAce/BetterLua.vim'     -- Lua improvements
  use 'svermeulen/vimpeccable'         -- Adds vimp utility module
    -- {'ms-jpq/chadtree', branch='chad', run = 'python -m chadtree deps'};                -- Better NerdTree
  use { 'neoclide/coc.nvim', branch = 'release'} -- Completion engine
  use 'airblade/vim-gitgutter'         -- Git status of changed lines to the left.
  use 'cfdrake/vim-pbxproj'            -- Syntax highlight for pbxproj (TODO switch to treesitter later)

  use 'christoomey/vim-tmux-navigator' -- Send text to tmux pane
  use 'christoomey/vim-tmux-runner'    -- Send text to tmux pane
  use 'kien/ctrlp.vim'                 -- Fuzzy file opener
  use 'plasticboy/vim-markdown'        -- Markdown utility, go to link and so on.
  use 'mhinz/vim-startify'             -- Startscreen.
  use 'scrooloose/nerdtree'            -- File explorer
  use 'tpope/vim-commentary'           -- Commenter/uncommenter
  use 'tpope/vim-surround'             -- Change surrounding.
  use 'junegunn/fzf'                   -- fuzzy file finder
  use 'junegunn/fzf.vim'               -- fzf binding
  use 'rking/ag.vim'                   -- Silversearcher plugin (search project)

  use 'vim-syntastic/syntastic'        -- External syntax checkers, like linters and so on.
  use 'romainl/vim-cool'               -- Disable search highlight after searching.
  use { 'numirias/semshi', run = ':UpdateRemotePlugins<CR>'} -- Semantic highligting for python.
  use 'neovimhaskell/haskell-vim'      -- Haskell
  use 'eagletmt/ghcmod-vim'            -- More haskell
  use 'vim-ruby/vim-ruby'              -- Ruby

    -- nvim lsp
  use 'neovim/nvim-lspconfig'
  use 'prabirshrestha/async.vim'
    -- 'prabirshrestha/asyncomplete-lsp.vim'; -- Clashes with Coc
    -- 'prabirshrestha/asyncomplete.vim';     -- Clashes with Coc
  use 'prabirshrestha/vim-lsp'
  use 'keith/swift.vim'

  use 'onsails/lspkind-nvim'             -- unicode pictograms alognside lsp completions for modules/functions etc.

  -- use {'nvim-orgmode/orgmode', config = function() require('orgmode').setup{} end } -- Text management
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }  -- Better syntax highlighting

  use 'tanvirtin/monokai.nvim'           -- Monokai with treesitter support
end)
