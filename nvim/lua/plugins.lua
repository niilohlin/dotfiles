-- lazy.nvim package manager

require('lazy').setup({
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

  -- Gruvbox with treesitter support
  {
    'ellisonleao/gruvbox.nvim',
    config = function()
      local gruvbox = require('gruvbox')
      gruvbox.setup()
      vim.cmd('colorscheme gruvbox')
    end
  },

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


  -- cmd line in the middle of the screen
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- used for proper rendering and multiple views
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        presets = {
          command_palette = true,       -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false,           -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false,       -- add a border to hover docs and signature help
        },
        cmdline = {
          format = {
            cmdline = { icon = ":" },
            search_down = { icon = "/" },
            search_up = { icon = "?" },
            lua = { icon = "lua" },
            help = { icon = "help" },
          },
        }
      })
    end
  },

  -- Vim trainer
  'ThePrimeagen/vim-be-good',

  -- -- Targets, text objects, adds objects like ci,
  -- 'wellle/targets.vim',

  -- File explorer
  { 'echasnovski/mini.files', version = '*' },

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

-- Set leader to <space>
vim.g.mapleader = ' '

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
vim.keymap.set('n', '<C-U>', '<C-U>zz')                       -- Move cursor to middle of screen
vim.keymap.set('n', '<C-D>', '<C-D>zz')                       -- Move cursor to middle of screen

vim.keymap.set('n', '<leader>j', ':lua MiniFiles.open()<CR>') -- Show current file in mini.files

vim.keymap.set('n', '<leader>K', vim.diagnostic.open_float)

vim.keymap.set('n', '<leader>gd', ':GitGutterUndoHunk<CR>') -- Discard git

vim.keymap.set('v', '<leader>p', '"_dP')                    -- Paste without copying to clipboard

vim.api.nvim_command('command W w')                         -- Remap :W to :w

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

vim.keymap.set('n', ']c', ':cnext<CR>')            -- Go to next quickfix
vim.keymap.set('n', '[c', ':cprev<CR>')            -- Go to previous quickfix

vim.keymap.set('n', ']b', ':bnext<CR>')            -- Go to next buffer
vim.keymap.set('n', '[b', ':bprev<CR>')            -- Go to previous buffer

---

require('lint').linters_by_ft = {
  markdown = { 'vale', },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require('lint').try_lint()
  end,
})

---

require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'bash',
    'c',
    'cpp',
    'css',
    'javascript',
    'json',
    'lua',
    'python',
    'regex',
    'rust',
    'toml',
    'yaml',
    'swift',
    'haskell',
  },

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing
  ignore_install = {},

  -- Automatically install missing parsers when entering buffer
  auto_install = false,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.make = {
  install_info = {
    url = "~/workspace/tree-sitter-make/",  -- local path or git repo
    files = { "src/parser.c" },             -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = "main",                        -- default branch in case of git repo if different from master
    generate_requires_npm = false,          -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  }
}

vim.treesitter.language.register('make', 'make')

parser_config.pbxproj = {
  install_info = {
    url = '/Users/niilohlin/workspace/tree-sitter-pbxproj',
    files = { 'src/parser.c' },
    branch = 'main',
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = 'pbxproj',
}

vim.treesitter.language.register('pbxproj', 'pbxproj')

---

require('telescope').load_extension('fzf')

local my_prefix = function(fs_entry)
  if fs_entry.fs_type == 'directory' then
    return 'D ', 'MiniFilesDirectory'
  elseif fs_entry.fs_type == 'file' then
    return 'F ', 'MiniFilesFile'
  end
  return MiniFiles.default_prefix(fs_entry)
end

require('mini.files').setup({ content = { prefix = my_prefix } })

-- require('mini.files').setup({ content = { prefix = function() end } })

-- Disable netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-treesitter.configs').setup {
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
        -- You can also use captures from other query groups like `locals.scm`
        ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true or false
      include_surrounding_whitespace = true,
    },
  },
}


require('Comment').setup()

---

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.sourcekit.setup {}
lspconfig.marksman.setup {}
lspconfig.lua_ls.setup {}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- Search workspace symbols
    vim.keymap.set('n', '<leader>t', vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', builtin.lsp_type_definitions, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
    vim.keymap.set('n', '<leader>=', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- Set up nvim-cmp.
local cmp = require('cmp')
cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()


lspconfig.lua_ls.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   buffer = bufnr,
    --   command = "lua vim.lsp.buf.format { async = false }",
    -- })
  end,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        library = { [vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim')] = true },
      }
    },
  },
}

lspconfig.sourcekit.setup {
  capabilities = capabilities
}

lspconfig.tsserver.setup {
  capabilities = capabilities
}

lspconfig.eslint.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

lspconfig.pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        pylint = { enabled = true, executable = 'pylint' },
        mypy = { enabled = true, executable = 'mypy' },
        rope = { enabled = true, executable = 'rope' },
        rope_autoimport = {
          enabled = true,
          completions = { enabled = true }
        },
      }
    }
  },
  capabilities = capabilities
}

-- lspconfig.ruff_lsp.setup {
--   init_options = {
--     settings = {
--       args = {},
--     }
--   },
--   capabilities = capabilities
-- }

local ns_id = vim.api.nvim_create_namespace('quickfix diagnostics')
local function set_qf_diagnostics()
  local errors = vim.fn.getqflist()
  for _, error in ipairs(errors) do
    if error.bufnr < 0 then
      goto continue
    end
    local bufname = vim.fn.bufname(error.bufnr)
    if bufname == "" then
      goto continue
    end
    if error.lnum == 0 then
      goto continue
    end
    vim.diagnostic.set(ns_id, error.bufnr, vim.diagnostic.fromqflist({ error }))
    ::continue::
  end
end

local function clear_qf_diagnostics()
  local errors = vim.fn.getqflist()
  for _, error in ipairs(errors) do
    if error.bufnr < 0 then
      goto continue
    end
    local bufname = vim.fn.bufname(error.bufnr)
    if bufname == "" then
      goto continue
    end
    if error.lnum == 0 then
      goto continue
    end
    vim.diagnostic.set(ns_id, error.bufnr, {})
    ::continue::
  end
end

vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  callback = function()
    set_qf_diagnostics()
  end,
})

vim.api.nvim_create_autocmd('QuickFixCmdPre', {
  callback = function()
    clear_qf_diagnostics()
  end,
})
