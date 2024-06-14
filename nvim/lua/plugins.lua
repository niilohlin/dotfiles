function ReviewerMode()
  vim.o.statuscolumn = "%s %l %r"
end

require('lazy').setup({
  -- Git status of changed lines to the left.
  'airblade/vim-gitgutter',

  -- Syntax highlight for pbxproj (TODO switch to treesitter later)
  'cfdrake/vim-pbxproj',

  -- Send text to tmux pane
  'christoomey/vim-tmux-navigator',

  -- Send text to tmux pane
  'christoomey/vim-tmux-runner',

  -- Markdown utility, go to link and so on.
  'plasticboy/vim-markdown',

  -- Git plugin
  'tpope/vim-fugitive',

  { -- Surround plugin, adds text objects like ci" and so on.
    'echasnovski/mini.surround',
    config = function()
      require('mini.surround').setup {
        mappings = {
          add = '',            -- Add surrounding in Normal and Visual modes
          delete = 'ds',       -- Delete surrounding
          replace = 'cs',      -- Replace surrounding

          find = '',           -- Find surrounding (to the right)
          find_left = '',      -- Find surrounding (to the left)
          highlight = '',      -- Highlight surrounding
          update_n_lines = '', -- Update `n_lines`
          suffix_last = '',    -- Suffix to search with "prev" method
          suffix_next = '',    -- Suffix to search with "next" method
        },
      }
    end
  },

  { -- Text objects plugin
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    'echasnovski/mini.ai',
    config = function()
      require('mini.ai').setup {
      }
    end
  },

  -- [q and ]q to navigate quickfix list for example
  'tpope/vim-unimpaired',

  -- -- fuzzy file finder
  'junegunn/fzf',

  -- fzf binding
  'junegunn/fzf.vim',

  -- project wide search, requires ripgrep
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- fzf native plugin, make it possible to fuzzy search in telescope
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup()
      require('telescope').load_extension('fzf')
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sf', builtin.find_files, {}) -- find files
      vim.keymap.set('n', '<leader>sr', builtin.resume, {})     -- Resume last telescope search
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, {})  -- live grep
      vim.keymap.set('n', '<Leader>sF', function()
        builtin.find_files({ hidden = true })
      end, {})                                                                 -- live find files (including hidden files)
      vim.keymap.set('n', '<leader>so', builtin.oldfiles)                      -- Open old files
      vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols)          -- live find symbols
      vim.keymap.set('n', '<leader>sb', builtin.buffers, {})                   -- Open buffers
      vim.keymap.set('n', '<leader>st', builtin.tags)                          -- live find symbols
      vim.keymap.set('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols) -- live find workspace symbols

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
    end

  },

  -- Silversearcher plugin (search project)
  { 'kelly-lin/telescope-ag',                  dependencies = { 'nvim-telescope/telescope.nvim' } },

  -- Disable search highlight after searching.
  'romainl/vim-cool',

  { -- Semantic syntax highlighting
    'nvim-treesitter/nvim-treesitter',
    config = function()
      local configs = require('nvim-treesitter.configs')
      configs.setup {
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

        sync_install = false, -- Install languages synchronously (only applied to `ensure_installed`)

        ignore_install = {},  -- List of parsers to ignore installing

        auto_install = false, -- Automatically install missing parsers when entering buffer

        highlight = {
          enable = true, -- `false` will disable the whole extension
          disable = {},  -- list of language that will be disabled

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ak'] = '@class.outer',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ['ik'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
              -- You can also use captures from other query groups like `locals.scm`
              ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
              ['is'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
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

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.make = {
        install_info = {
          url = "~/personal/tree-sitter-make/",   -- local path or git repo
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
          url = '~/personal/tree-sitter-pbxproj',
          files = { 'src/parser.c' },
          branch = 'main',
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = 'pbxproj',
      }

      vim.treesitter.language.register('pbxproj', 'pbxproj')
    end
  },

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

  -- Integrate quickfix list with diagnostics
  { dir = '~/personal/qflist-diagnostics.nvim' },

  -- Yaml utility, helps distinguish indendation
  'Einenlum/yaml-revealer',

  -- Github Copilot, AI completions
  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap('i', '<Right>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
    end
  },

  { -- Make anything into an lsp, like linter output etc.
    'nvimtools/none-ls.nvim',
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          null_ls.builtins.diagnostics.checkmake,
          null_ls.builtins.diagnostics.pylint.with({
            prefer_local = "venv/bin",
            env = function(params)
              return { PYTHONPATH = params.root }
            end,
          }),
          null_ls.builtins.diagnostics.mypy.with({
            prefer_local = "venv/bin",
            env = function(params)
              return { PYTHONPATH = params.root }
            end,
          }),
        },
      })
    end
  },


  { -- LSP setup
    dependencies = {
      -- Mason makes sure that LSPs are installed
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    'neovim/nvim-lspconfig',
    config = function()
      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
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

      -- Set up lspconfig.
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')

      lspconfig['sourcekit'].setup { capabilities = capabilities }

      local servers = {
        lua_ls = {
          capabilities = capabilities,
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = {
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                  [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                  [vim.fn.expand('$VIMRUNTIME/lua/vim')] = true,
                  [unpack(vim.api.nvim_list_runtime_paths())] = true,
                },
              },
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },

        tsserver = {
          capabilities = capabilities
        },

        eslint = {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        },

        jedi_language_server = {
          capabilities = capabilities
        },
      }

      -- local client = vim.lsp.start_client {
      --   -- root_dir = lspconfig.util.root_pattern('setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt', '.git'),
      --   name = "ctags-lsp",
      --   cmd = { "/Users/niilohlin/personal/ctags-lsp/src/main.py" },
      --   on_attach = function(client, bufnr)
      --   end,
      --   capabilities = capabilities,
      -- }
      --
      -- if not client then
      --   print("ctags-lsp failed to start")
      -- end
      --
      -- vim.api.nvim_create_autocmd('BufEnter', {
      --   pattern = '*.py',
      --   callback = function()
      --     vim.lsp.buf_attach_client(0, client)
      --   end,
      -- })

      require('mason').setup()
      local ensure_installed = vim.tbl_keys(servers or {})
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end
  },


  -- Generic log highlighting
  'MTDL9/vim-log-highlighting',

  -- Vim open file including line number, including gF
  -- $ vim file.py:10
  'wsdjeg/vim-fetch',

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
      -- if we are using noice and nui, we don't need the statusline
      vim.opt.cmdheight = 1
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

  -- Targets, text objects, adds objects like ci,
  -- 'wellle/targets.vim',

  -- File explorer
  {
    'stevearc/oil.nvim',
    event = 'VimEnter',
    config = function()
      require('oil').setup()
      vim.keymap.set('n', '<leader>j', ":Oil<CR>") -- Show current file in Oil
      -- Disable netrw. We don't need it if we use oil
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end
  },

  -- Indent object, adds objects like ai "delete around indent"
  'michaeljsmith/vim-indent-object',

  -- LSP completion
  -- This version is compatible with nvim 0.9.x master requires 0.10
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',                  -- Complete from buffer
      'hrsh7th/cmp-nvim-lsp-signature-help', -- Improved completions, completions for argument signature
      'hrsh7th/cmp-cmdline',                 -- Better wild menu, while typing
      'hrsh7th/cmp-path',                    -- Complete file paths
      'hrsh7th/cmp-nvim-lsp',                -- LSP completion
      {                                      -- Nvim api completion
        'hrsh7th/cmp-nvim-lua',
        config = function()
          require('cmp_nvim_lsp').setup {
            sources = {
              { name = 'nvim_lua' },
            }
          }
        end
      },
    },
    config = function()
      -- Set up nvim-cmp.
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'nvim_lsp_signature_help' },
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
    end
  },

  -- snip manager required by nvim-cmp
  {
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      { -- Pre made snippets
        'rafamadriz/friendly-snippets',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
    },
    'L3MON4D3/LuaSnip',
    -- follow latest release.
    version = 'v2.3.0',
    -- install jsregexp (optional!).
    -- build = "make install_jsregexp"
  },

  -- Formatting manager. Makes sure that we can autoformat on save without leaving the buffer changed
  -- when exiting
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          lua = { "stylua" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          javascript = { { "prettierd", "prettier" } },
          json = { "jq" },
        },
      }
    end
  },
})

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
vim.keymap.set('n', '<C-U>', '<C-U>zz')                     -- Move cursor to middle of screen
vim.keymap.set('n', '<C-D>', '<C-D>zz')                     -- Move cursor to middle of screen

vim.keymap.set('n', '<leader>gd', ':GitGutterUndoHunk<CR>') -- Discard git

vim.keymap.set('v', '<leader>p', '"_dP')                    -- Paste without copying to clipboard

vim.api.nvim_command('command W w')                         -- Remap :W to :w

vim.keymap.set('n', '<leader>rr', ':%s/\\\\n/\\r/g<CR>')    -- Replace Returns:  Replace all \n with new lines

-- disable { and } to untrain myself from using them
vim.keymap.set('n', '{', '<nop>')
vim.keymap.set('n', '}', '<nop>')

vim.keymap.set('n', 'g[', function()
  local word_under_cursor = vim.fn.expand('<cword>')
  vim.cmd('execute "keepjumps normal! gg"')
  vim.cmd('/' .. word_under_cursor)
end)

vim.keymap.set('n', 'gp', '`[v`]') -- Select last paste

-- map textobject to select the continuous comment with vim._comment.textobject
local comment = require('vim._comment')
vim.keymap.set('x', 'ic', comment.textobject)
vim.keymap.set('o', 'ic', comment.textobject)
