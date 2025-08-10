function SetTabLength(tab_length)
  vim.opt.tabstop = tab_length
  vim.opt.shiftwidth = tab_length
  vim.opt.softtabstop = tab_length
  vim.opt.expandtab = true
end

local initgroup = vim.api.nvim_create_augroup("Initlua", { clear = true })

-- Set cursor position to old spot
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  group = initgroup,
  callback = function()
    vim.cmd([[ if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif ]])
  end,
})

-- Remove blank space, and put the cursor back where it was
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = initgroup,
  callback = function()
    vim.cmd([[ normal mi ]])
    vim.cmd([[ :%s/\s\+$//e ]])
    vim.cmd([[ normal 'i ]])
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = initgroup,
  pattern = { "javascript", "typescriptreact", "*.js", "*.jsx", "typescript", "*.ts", "*.tsx", "html", "htmldjango", "lua", "yaml", "yml" },
  callback = function()
    SetTabLength(2)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = initgroup,
  pattern = "markdown",
  command = "set spell nofoldenable"
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = initgroup,
  pattern = ".env.local",
  callback = function()
    vim.cmd([[ set filetype=sh ]])
  end,
})

local function find_file_using_rg(file, find_files)
  local file_in_same_path = vim.fn.expand("%:p:h") .. "/" .. file
  if vim.fn.filereadable(file_in_same_path) == 1 then
    vim.cmd("edit " .. file_in_same_path)
    return
  end

  vim.fn.jobstart("rg --files --color never . | rg " .. file, {
    on_stdout = function(_, data, _)
      if table.concat(data) == table.concat({ "" }) then
        return
      end
      local files = {}
      for _, found in ipairs(data) do
        if found ~= "" then
          table.insert(files, found)
        end
      end
      if #files == 1 then
        vim.cmd("edit " .. files[1])
      else
        find_files({ default_text = file })
      end
    end,
    on_stderr = function(_, data, _)
      local data_without_empty_strings = {}
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(data_without_empty_strings, line)
        end
      end
      if #data_without_empty_strings > 0 then
        print(table.concat(data_without_empty_strings, "\n"))
      end
    end,
    on_exit = function(_, code, _)
      if code ~= 0 then
        find_files({ default_text = file })
      end
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = initgroup,
  pattern = "python",
  callback = function()
    --
    -- set 'include' to '' so that we can use [<c-I> to go to the import.
    vim.opt.include = ""

    -- search for the current line
    vim.keymap.set("n", "gi", function()
      vim.cmd('normal! "vyiw')
      local selected_text = "def " .. vim.fn.getreg("v") .. "\\("
      Snacks.picker.grep({ search = selected_text })
    end)

    -- Go to the associated implementation file
    vim.keymap.set("n", "<leader><UP>", function()
      local current_file_name = vim.fn.expand("%:t")

      local file_to_edit = current_file_name
      if string.sub(current_file_name, 1, 2) == "i_" then
        file_to_edit = string.sub(current_file_name, 3)
      else
        file_to_edit = "i_" .. current_file_name
      end

      find_file_using_rg(file_to_edit, Snacks.picker.files)
    end)

    -- override treesitter keymap
    vim.keymap.set({ "x", "o" }, "am", "<Plug>(PythonsenseOuterFunctionTextObject)")

    -- Always use make. When entering `test_*.py` nvim automatically sets the makeprg to pytest.
    -- But I use neotest to run individual tests.
    vim.opt_local.makeprg = "make"
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = initgroup,
  pattern = { "*.html.j2" },
  command = "set filetype=htmldjango",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = initgroup,
  pattern = {
    "Fastfile",
    "Appfile",
    "Snapfile",
    "Scanfile",
    "Gymfile",
    "Matchfile",
    "Deliverfile",
    "Dangerfile",
    "*.gemspec",
  },
  callback = function()
    vim.cmd([[ set ft=ruby ]])
    vim.cmd([[compiler ruby]])

    SetTabLength(2)
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = initgroup,
  pattern = { "*.log", "*.logs", "*.out", "output", "dap-repl", "dap-repl.*" },
  callback = function()
    vim.cmd([[ set ft=log ]])
  end,
})

-- Open diagnostics on hover
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = initgroup,
  pattern = "*",
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

-- automatically load the file if it has changed from an external source
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = initgroup,
  callback = function()
    if vim.fn.mode() == "i" then
      return
    end
    if vim.fn.getbufvar(vim.fn.bufnr("%"), "&modifiable") == 0 then
      return
    end
    if vim.fn.getbufvar(vim.fn.bufnr("%"), "&buftype") ~= "nofile" then
      vim.api.nvim_command("checktime")
    end
  end,
})

-- options
vim.opt.showcmd = false -- Don't show the current command in the bottom right, annoying
vim.opt.showmatch = true -- Highlight search match
vim.opt.ignorecase = true -- Ignore search casing
vim.opt.smartcase = true -- But not when searching with uppercase letters
vim.opt.smartindent = true -- Language-aware indent
vim.opt.autowrite = true -- Automatically write on :n and :p
vim.opt.autoread = true -- Automatically read file from disk on change
vim.opt.number = true -- Set line numbers
vim.opt.relativenumber = true -- Set relative line numbers
vim.opt.colorcolumn = "120" -- Show max column highlight.
vim.opt.cursorline = true -- Show a horizontal line where the cursor is
vim.opt.splitbelow = true -- Show the preview window (code documentation) to the bottom of the screen.
vim.opt.wildmode = { "longest", "full" }
vim.opt.swapfile = false -- Disable swapfile
vim.opt.signcolumn = "yes" -- Always show sign column to avoid indenting and jumping
-- vim.cmd([[set virtualedit="block"]])

-- Remove annoying auto inserting comment string
vim.api.nvim_create_autocmd("BufEnter", {
  group = initgroup,
  callback = function()
    -- o means auto insert comment string only when hitting o in normal mode
    -- r means auto insert comment string only when hitting enter
    vim.opt.formatoptions:remove({ "o", "r" })
  end,
})

-- This setting controls how long to wait (in ms) before fetching type / symbol information.
vim.opt.updatetime = 500
-- -- Remove 'Press Enter to continue' message when type information is longer than one line.
-- vim.opt.cmdheight = 2 -- handled by auto-cmdheight
-- opt.cmdheight = 0     -- Hide the command line when not needed.

-- Handle tabs, expand to 4 spaces.
SetTabLength(4)

vim.opt.list = true -- Show whitespace characters.
vim.opt.listchars = { tab = "› ", trail = "·", extends = "›", precedes = "‹", nbsp = "+" } -- Show these characters
vim.opt.whichwrap = vim.opt.whichwrap + "<,>,[,],l,h" -- Move cursor to next line when typing these characters.

vim.opt.undofile = true -- Use undo file
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir" -- Set undo dir
vim.opt.scrolloff = 1 -- Scroll 1 line before cursor hits bottom
vim.opt.path:append("**") -- make :find search recursively
vim.opt.wildignore:append("*.o,*.obj,*.pyc,*.class") -- ignore build files when recursively searching
-- ignore git and pycache
vim.opt.wildignore:append("*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store,*/.vscode/*,*/.pytest_cache/*,*/__pycache__/*")
-- ignore venv
vim.opt.wildignore:append("*/venv/*,*/node_modules/*,*/target/*,*/build/*,*/dist/*,*/.next/*,*/.cache/*")

vim.g.markdown_enable_spell_checking = 0

-- Set leader to <space>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- show diagnostic source.
vim.diagnostic.config({
  float = {
    source = true,
  },
})

-- Git status of changed lines to the left.
vim.pack.add({"https://github.com/lewis6991/gitsigns.nvim"})
local gitsigns = require("gitsigns")
gitsigns.setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
  },
})
vim.keymap.set("n", "<leader>hd", gitsigns.reset_hunk)
vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk)

vim.keymap.set("n", "]c", function()
  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  else
    gitsigns.nav_hunk("next")
  end
end)

vim.keymap.set("n", "[c", function()
  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  else
    gitsigns.nav_hunk("prev")
  end
end)

vim.api.nvim_create_user_command("Review", function()
  gitsigns.change_base("main", true)
  gitsigns.setqflist("all")
end, { nargs = "*" })

vim.api.nvim_create_user_command("Unreview", function()
  gitsigns.change_base(nil, true)
end, { nargs = "*" })

-- Gruvbox with treesitter support
vim.pack.add({"https://github.com/ellisonleao/gruvbox.nvim"})
require("gruvbox").setup()
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, "Search", { bg = "#b57614", fg = "#282828" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#af3a03", fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "CurSearch", { bg = "#8f3f71", fg = "#fbf1c7" })

-- project wide search, requires ripgrep
vim.pack.add({"https://github.com/nvim-lua/plenary.nvim"})


vim.pack.add({"https://github.com/folke/snacks.nvim"})

vim.keymap.set("n", "<leader>sF", Snacks.picker.files, {}) -- find files
vim.keymap.set("v", "<leader>sf", function()
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg("v")
  Snacks.picker.files({ search = selected_text })
end)
vim.keymap.set("n", "<leader>sr", Snacks.picker.resume, {}) -- Resume last search
vim.keymap.set("n", "<leader>sg", Snacks.picker.grep, {}) -- live grep
vim.keymap.set("v", "<leader>sg", function()
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg("v")
  Snacks.picker.grep({ search = selected_text })
end)
vim.keymap.set("n", "<leader>sf", function()
  Snacks.picker.git_files({ hidden = true })
end, {}) -- live find files (including hidden files)
vim.keymap.set("n", "<leader>so", Snacks.picker.recent) -- Open old files
vim.keymap.set("n", "<leader>sj", Snacks.picker.jumps) -- Open jumplist
vim.keymap.set("n", "<leader>sm", Snacks.picker.marks) -- Open marks
vim.keymap.set("n", "<leader>ds", Snacks.picker.lsp_symbols) -- live find symbols
vim.keymap.set("n", "<leader>sb", Snacks.picker.buffers, {}) -- Open buffers
-- vim.keymap.set("n", "<leader>st", Snacks.picker.tags) -- live find symbols
vim.keymap.set("n", "<leader>ws", Snacks.picker.lsp_workspace_symbols) -- live find workspace symbols

local function has_workspace_symbols()
  if not vim.lsp.get_clients() then
    return false
  end

  for _, client in ipairs(vim.lsp.get_clients()) do
    if client.server_capabilities.workspaceSymbolProvider then
      return true
    end
  end

  return false
end

vim.keymap.set("n", "<leader>o", Snacks.picker.smart, {})

vim.keymap.set("n", "z=", Snacks.picker.spelling)

-- Git plugin, provides :Git add, :Git blame etc.
vim.pack.add({"https://github.com/tpope/vim-fugitive"})

-- async Make, Dispatch (run), and more, integrates with tmux
vim.pack.add({"https://github.com/tpope/vim-dispatch"})

-- [q and ]q to navigate quickfix list for example
vim.pack.add({"https://github.com/tpope/vim-unimpaired"})

-- Semantic syntax highlighting
vim.pack.add({"https://github.com/nvim-treesitter/nvim-treesitter"})
vim.api.nvim_create_autocmd("BufReadPre", {
  group = initgroup,
  once = true,
  callback = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "javascript",
        "json",
        "lua",
        "python",
        "regex",
        "rust",
        "toml",
        "yaml",
        "swift",
        "haskell",
        "html",
      },

      sync_install = false, -- Install languages synchronously (only applied to `ensure_installed`)

      ignore_install = {}, -- List of parsers to ignore installing

      auto_install = false, -- Automatically install missing parsers when entering buffer

      highlight = {
        enable = true, -- `false` will disable the whole extension
        disable = {}, -- list of language that will be disabled
        additional_vim_regex_highlighting = false,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ak"] = "@class.outer",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
          include_surrounding_whitespace = true,
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]k"] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[k"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>sa"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>sA"] = "@parameter.inner",
          },
        },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gV",
          node_incremental = "+",
          scope_incremental = "g+",
          node_decremental = "-",
        },
      },
      indent = {
        enable = true,
      },
    })
  end,
})

-- Tree sitter text objects
-- Text objects plugin
vim.pack.add({"https://github.com/echasnovski/mini.ai", "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("mini.ai").setup()
  end,
})

-- Surround plugin, adds text objects like ci" and so on.
vim.pack.add({"https://github.com/echasnovski/mini.surround"})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = initgroup,
  once = true,
  callback = function()
    local surround = require("mini.surround")
    surround.setup({
      mappings = {
        add = "gs", -- Add surrounding in Normal and Visual modes, overrides "sleep" mapping
        delete = "ds", -- Delete surrounding
        replace = "cs", -- Replace surrounding

        find = "", -- Find surrounding (to the right)
        find_left = "", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        update_n_lines = "", -- Update `n_lines`
        suffix_last = "", -- Suffix to search with "prev" method
        suffix_next = "", -- Suffix to search with "next" method
      },
    })
    vim.keymap.set("v", "C", function() -- C for "call"
      vim.cmd('normal "vc()"vPg;h')
      vim.cmd("startinsert")
    end)
  end,
})

-- indentation text objects and jumps
vim.pack.add({"https://github.com/niilohlin/neoindent"})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("neoindent").setup({})
  end,
})

-- Nerd Icons (for example in oil buffers)
-- File explorer
vim.pack.add({"https://github.com/stevearc/oil.nvim", "https://github.com/echasnovski/mini.icons" })
require("mini.icons").setup()
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("oil").setup()
    vim.keymap.set("n", "<leader>j", ":Oil<CR>") -- Show current file in Oil
    -- Disable netrw. We don't need it if we use oil
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    -- vim.pack.add({"https://github.com/benomahony/oil-git.nvim"})
  end,
})

-- Snippets collection
vim.pack.add({"https://github.com/rafamadriz/friendly-snippets"})

-- Completion engine.
vim.pack.add({
  "https://github.com/saghen/blink.cmp",
      -- vim.fn.system("cd /Users/niilohlin/.local/share/nvim/site/pack/deps/opt/blink.cmp/ && cargo build --release")
})

-- nvim development utils
vim.pack.add({"https://github.com/folke/lazydev.nvim"})
vim.api.nvim_create_autocmd("FileType", {
  group = initgroup,
  pattern = "lua",
  once = true,
  callback = function()
    require("lazydev").setup({
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        "$VIMRUNTIME",
        { path = "${HOME}/.local/share/nvim/lazy" },
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "FileType" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("blink.cmp").setup({
      keymap = {
        preset = "default",
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
        ["<C-k>"] = { "show_documentation", "fallback" },
        ["<C-c>"] = { "cancel", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
      },

      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      completion = {
        -- Some LSPs might add brackets themselves anyways
        accept = { auto_brackets = { enabled = false } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
        },
        -- signature = { enabled = true }
      },
    })
    -- ?? idk where this is going
    -- opts_extend = { "sources.default" },
  end,
})

-- LSP server Installer/manager
vim.pack.add({"https://github.com/mason-org/mason.nvim"})
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "FileType" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("mason").setup()
  end,
})

-- LSP setup
vim.pack.add({"https://github.com/neovim/nvim-lspconfig"})
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "FileType" }, {
  group = initgroup,
  once = true,
  callback = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    local vim_runtime_paths = {
      vim.fn.expand("$VIMRUNTIME/lua"),
      vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
      vim.fn.expand("$VIMRUNTIME/lua/vim"),
    }
    local rest = vim.api.nvim_list_runtime_paths()
    table.move(rest, 1, #rest, #vim_runtime_paths + 1, vim_runtime_paths)

    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          format = {
            enable = true,
            defaultConfig = {
              indent_style = "space",
              indent_size = 2,
            },
          },
          runtime = { version = "LuaJIT" },
          diagnostics = {},
          workspace = {
            checkThirdParty = false,
            library = vim_runtime_paths,
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })
    vim.lsp.config("lua_ls", lspconfig.lua_ls)

    lspconfig.ts_ls.setup({
      capabilities = capabilities,
    })
    vim.lsp.config("ts_ls", lspconfig.ts_ls)

    lspconfig.eslint.setup({
      on_attach = function(client, bufnr)
        -- Enable formatting capability for ESLint
        client.server_capabilities.documentFormattingProvider = true
        local lspformatgroup = vim.api.nvim_create_augroup("lspformatgroup", { clear = true })

        -- Auto-format on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = lspformatgroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr })
          end,
        })
      end,
    })
    vim.lsp.config("eslint", lspconfig.eslint)

    lspconfig.jedi_language_server.setup({
      init_options = {
        codeAction = {
          nameExtractVariable = "jls_extract_var",
          nameExtractFunction = "jls_extract_def",
        },
        completion = {
          -- LSP snippets turned out to insisting on inserting parens everywhere
          disableSnippets = true,
        },
      },
      capabilities = capabilities,
    })
    vim.lsp.config("jedi_language_server", lspconfig.jedi_language_server)

    -- Global mappings.
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist)

    -- local pwd = vim.loop.cwd()
    -- vim.api.nvim_create_autocmd("FileType", {
    --  pattern = "python",
    --  callback = function()
    --   vim.lsp.start({
    --    name = "Omnisearch LSP",
    --    filetypes = { "python" },
    --    root_dir = pwd,
    --    --- @field cmd? string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient
    --    cmd = function(dispatchers)
    --    end,
    --   })
    --  end,
    -- })

    vim.filetype.add({
      extension = {
        jinja = "jinja",
        jinja2 = "jinja",
        j2 = "jinja",
      },
    })

    local lsp_configs = require("lspconfig.configs")

    if not lsp_configs.jinja_lsp then
      lsp_configs.jinja_lsp = {
        default_config = {
          name = "jinja-lsp",
          cmd = { vim.fn.stdpath("data") .. "/mason/bin/jinja-lsp" },
          filetypes = { "jinja", "html", "htmldjango" },
          root_dir = function(fname)
            return "."
            --return nvim_lsp.util.find_git_ancestor(fname)
          end,
          init_options = {
            templates = "./templates",
            backend = { "./src" },
            lang = "python",
          },
        },
      }
    end
    lspconfig.jinja_lsp.setup({
      capabilities = capabilities,
    })

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- Do not override the keymap if the lsp server does not support the method.
        local function declare_method_if_supported(method, command, fn)
          if client == nil then
            return
          end
          if client:supports_method(method) then
            vim.keymap.set("n", command, fn, opts)
          end
        end

        declare_method_if_supported("textDocument/definition", "gd", Snacks.picker.lsp_definitions)
        declare_method_if_supported("textDocument/implementation", "gri", Snacks.picker.lsp_implementations)
        declare_method_if_supported("textDocument/references", "grr", Snacks.picker.lsp_references)
        declare_method_if_supported("textDocument/documentSymbol", "gO", Snacks.picker.lsp_symbols)
        declare_method_if_supported("workspace/symbol", "<leader>ws", Snacks.picker.lsp_workspace_symbols)
      end,
    })
    vim.api.nvim_create_autocmd("DirChanged", {
      group = vim.api.nvim_create_augroup("ReloadLSPGroup", { clear = true }),
      callback = function(ev)
        vim.cmd("LspRestart")
      end
    })
  end,
})

-- CamelCase to snake case (crc, crm, crs, cru), including :Sub command to substitute with smart casing
vim.pack.add({"https://github.com/johmsalas/text-case.nvim"})
require("textcase").setup({})

vim.api.nvim_create_user_command("TrainAbolish", function()
  math.randomseed(os.time())
  -- Read words from dictionary file
  local words = {}
  local file = io.open("/usr/share/dict/words", "r")
  if file then
    for line in file:lines() do
      table.insert(words, line)
    end
    file:close()
  else
    print("Could not open dictionary file")
    os.exit(1)
  end

  local function to_camel_case(word1, word2)
    return word1:sub(1, 1):upper() .. word1:sub(2):lower() .. word2:sub(1, 1):upper() .. word2:sub(2):lower()
  end

  local function to_lower_camel_case(word1, word2)
    return word1:lower() .. word2:sub(1, 1):upper() .. word2:sub(2):lower()
  end

  local function to_snake_case(word1, word2)
    return word1:lower() .. "_" .. word2:lower()
  end

  local function to_screaming_case(word1, word2)
    return word1:upper() .. "_" .. word2:upper()
  end

  local cases = { to_camel_case, to_lower_camel_case, to_snake_case, to_screaming_case }

  local output_file = io.open("/tmp/output.txt", "w")
  if output_file == nil then
    return
  end
  for _ = 1, 20 do
    local word1 = words[math.random(#words)]
    local word2 = words[math.random(#words)]
    local case_func = cases[math.random(#cases)]
    local target_func = cases[math.random(#cases)]
    output_file:write(case_func(word1, word2) .. " -- " .. target_func(word1, word2) .. "\n")
  end
  output_file:close()

  vim.cmd("edit /tmp/output.txt")
end, {})

-- nicer status line
vim.pack.add({"https://github.com/nvim-lualine/lualine.nvim"})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = initgroup,
  once = true,
  callback = function()
    local custom_gruvbox = require("lualine.themes.gruvbox")
    -- Remove the constant changing of colors while changing modes
    custom_gruvbox.insert = custom_gruvbox.normal
    custom_gruvbox.visual = custom_gruvbox.normal
    custom_gruvbox.replace = custom_gruvbox.normal
    custom_gruvbox.command = custom_gruvbox.normal
    custom_gruvbox.inactive = custom_gruvbox.normal

    require("lualine").setup({
      options = {
        theme = custom_gruvbox,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "branch" },
        -- lualine_a = { "branch", "gitstatus" },
        lualine_b = {
          "diff",
          function()
            return "|"
          end,
          "diagnostics",
        },
        lualine_x = { },
        lualine_y = {
          function()
            local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
            if #attached_clients == 0 then
              return ""
            end
            local names = vim
              .iter(attached_clients)
              :map(function(client)
                local name = client.name:gsub("language.server", "ls")
                return name
              end)
              :totable()
            return table.concat(names, " ")
          end,
        },
        lualine_z = { "filetype" },
      },
      inactive_sections = {
        lualine_a = { "filename" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
})

local terminals = {}
local term_info = 0
local term_error = 1
-- Improved tabs
vim.pack.add({"https://github.com/nanozuki/tabby.nvim"})
local custom_fill = { fg = "#7c6f64", bg = "#504945", style = "italic" }
local tab_api = require("tabby.module.api")
require("tabby").setup({
  line = function(line)
    return {
      {
        { hl = "TabLine" },
        line.sep(" ", "TabLine", custom_fill),
      },
      line.tabs().foreach(function(tab)
        local hl = tab.is_current() and "TabLineSel" or "TabLine"
        local windows = tab_api.get_tab_wins(tab.id)
        for _, window_id in ipairs(windows) do
          local buf_id = vim.api.nvim_win_get_buf(window_id)
          if tab.is_current() then
            terminals[buf_id] = nil
          end
          if terminals[buf_id] == term_info then
            return {
              line.sep(" ", hl, custom_fill),
              tab.number(),
              tab.name(),
              "󰋼",
              line.sep("", hl, custom_fill),
              hl = hl,
              margin = " ",
            }
          elseif terminals[buf_id] == term_error then
            return {
              line.sep(" ", hl, custom_fill),
              tab.number(),
              tab.name(),
              "",
              line.sep("", hl, custom_fill),
              hl = hl,
              margin = " ",
            }
          end
        end
        return {
          line.sep(" ", hl, custom_fill),
          tab.number(),
          tab.name(),
          line.sep("", hl, custom_fill),
          hl = hl,
          margin = " ",
        }
      end),
      line.spacer(),
      hl = custom_fill,
    }
  end,
  -- option = {}, -- setup modules' option,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = initgroup,
  callback = function(ev)
    local buf = ev.buf
    vim.api.nvim_buf_attach(buf, false, {
      on_lines = function(_, bufnr, _, _, last, new_last)
        terminals[buf] = math.max(term_info, terminals[buf] or 0)
        local lines = vim.api.nvim_buf_get_lines(bufnr, last - 1, new_last, false)
        for _, line in ipairs(lines) do
          local lower_line = line:lower()
          if lower_line:find("error") or lower_line:find("fail") or lower_line:find("exception") or lower_line:find("traceback") then
            terminals[buf] = term_error
            break
          end
        end
      end,
    })
  end,
})

-- Markdown utility, go to link and so on.
vim.pack.add({"https://github.com/plasticboy/vim-markdown"})

-- quickfix improvement
vim.pack.add({"https://github.com/stevearc/quicker.nvim"})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = initgroup,
  pattern = "qf",
  once = true,
  callback = function()
    require("quicker").setup({})
  end,
})

-- Disable search highlight after searching.
vim.pack.add({"https://github.com/romainl/vim-cool"})

-- multi cursor support
vim.pack.add({"https://github.com/jake-stewart/multicursor.nvim"})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = initgroup,
  once = true,
  callback = function()
    local mc = require("multicursor-nvim")
    mc.setup()
    vim.keymap.set("c", "<c-x>", function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
      vim.defer_fn(function()
        local start_pos = vim.api.nvim_win_get_cursor(0)
        local start_line = start_pos[1]
        local start_col = start_pos[2]

        local current_line = nil
        local current_col = nil

        local max_matches = 100

        while not (start_line == current_line and start_col == current_col) and max_matches do
          mc.toggleCursor()
          vim.cmd("normal n")
          local current_pos = vim.api.nvim_win_get_cursor(0)
          current_line = current_pos[1]
          current_col = current_pos[2]
          max_matches = max_matches - 1
        end
        mc.enableCursors()
      end, 0)
    end)

    vim.keymap.set("v", "I", mc.insertVisual)
    vim.keymap.set("v", "A", mc.appendVisual)

    vim.keymap.set("n", "]<c-x>", mc.nextCursor)
    vim.keymap.set("n", "[<c-x>", mc.prevCursor)
    vim.keymap.set("n", "[<c-x>", mc.prevCursor)
    vim.keymap.set("n", "<leader><down>", function()
      mc.lineAddCursor(1)
    end)
    vim.keymap.set("n", "<leader><c-x>", mc.clearCursors)
  end,
})

-- removes all "press enter to continue"
vim.pack.add({"https://github.com/jake-stewart/auto-cmdheight.nvim"})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("auto-cmdheight").setup()
  end,
})

-- add a scroll bar
vim.pack.add({"https://github.com/petertriho/nvim-scrollbar"})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("scrollbar").setup({
      marks = {
        Cursor = {
          text = " ", -- Remove cursor indicator
        },
      },
    })
  end,
})
-- https://github.com/kevinhwang91/nvim-hlslens

-- better python movements and text objects
vim.pack.add({"https://github.com/jeetsukumaran/vim-pythonsense"})
vim.g.is_pythonsense_suppress_object_keymaps = 1

-- refactoring library
vim.pack.add({"https://github.com/ThePrimeagen/refactoring.nvim"})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = initgroup,
  once = true,
  callback = function()
    local refactoring = require("refactoring")
    refactoring.setup({})
    vim.keymap.set({ "n", "x" }, "<leader>cr", function() -- code/refactor in the same style as codeAction
      refactoring.select_refactor()
    end)
    vim.keymap.set({ "n", "x" }, "<leader>iv", function()
      refactoring.refactor("Inline Variable")
    end)
    vim.keymap.set({ "n", "x" }, "<leader>if", function()
      refactoring.refactor("Inline Function")
    end)
    vim.keymap.set({ "n", "x" }, "<leader>ev", function()
      refactoring.refactor("Extract Variable")
    end)
    vim.keymap.set({ "n", "x" }, "<leader>ef", function()
      refactoring.refactor("Extract Function")
    end)
    vim.keymap.set("n", "<leader>pv", refactoring.debug.print_var_operatorfunc)
    vim.keymap.set("n", "<leader>pf", refactoring.debug.printf_operatorfunc)
    vim.api.nvim_create_user_command("RefactorClean", function()
      refactoring.debug.cleanup({})
    end, { nargs = "*" })
  end,
})

-- Generic log highlighting
vim.pack.add({"https://github.com/fei6409/log-highlight.nvim"})
require("log-highlight").setup({
  extension = { "*.log", "*.logs", "*.out", "output", "dap-repl", "dap-repl.*" },
  filename = {},
  pattern = {
    "/var/log/.*",
  },
})

-- Vim open file including line number, including gF
-- $ vim file.py:10
vim.pack.add({"https://github.com/wsdjeg/vim-fetch"})

-- ChatGPT plugin
vim.pack.add({"https://github.com/MeanderingProgrammer/render-markdown.nvim"})
vim.pack.add({"https://github.com/echasnovski/mini.diff"})
vim.pack.add({"https://github.com/olimorris/codecompanion.nvim"})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = initgroup,
  once = true,
  callback = function()
    local diff = require("mini.diff")
    diff.setup({
      -- Disabled by default
      source = diff.gen_source.none(),
    })
    require("codecompanion").setup({
      adapters = {
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = os.getenv("OPEN_API_KEY"),
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "openai" },
        inline = { adapter = "openai" },
        agent = { adapter = "openai" },
      },
    })

    vim.keymap.set({ "i", "v" }, "<C-X><C-E>", function()
      vim.cmd("CodeCompanion")
    end)
    -- vim.keymap.set("<D-C>")

    vim.keymap.set({ "n", "v" }, "<leader>cp", function()
      vim.cmd("CodeCompanionChat")
    end)
  end,
})

-- Do not nest vim sessions
vim.pack.add({"https://github.com/brianhuster/unnest.nvim"})

-- end plugins

vim.keymap.set({ "s" }, "<c-e>", function()
  if vim.snippet then
    vim.snippet.stop()
  end
end)
vim.api.nvim_create_user_command("SnippetStop", function()
  if vim.snippet then
    vim.snippet.stop()
  end
end, { nargs = "*" })

-- Never use Q for ex mode.
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "p", "p=`]") -- paste and reindent
vim.keymap.set("n", "P", "P=`]") -- paste and reindent above

vim.keymap.set("v", "<leader>cq", function() -- open selected in quickfix list
  vim.cmd('normal "vy')
  vim.cmd([[ cexpr split(@v, "\n") ]])
  vim.cmd("copen")
end)

vim.keymap.set("i", "<C-X><C-G>", function()
  vim.api.nvim_put({ vim.fn.expand("%") }, "c", true, true)
end)

vim.api.nvim_command("command W w") -- Remap :W to :w

vim.api.nvim_create_user_command("ReplaceReturns", function()
  vim.cmd("%s/\\\\n/\\r/g")
end, { nargs = "*" })

vim.api.nvim_create_user_command("PrettyPrint", function(input)
  local text_range = vim.fn.getline(input.line1, input.line2)

  local text = ""
  if type(text_range) == "table" then
    text = table.concat(text_range)
  else
    text = text_range
  end

  local indentation = 0
  local result = { "" }
  for i = 1, #text do
    local c = text:sub(i, i)
    local openers = { ["{"] = true, ["["] = true, ["("] = true }
    local closers = { ["}"] = true, ["]"] = true, [")"] = true }
    if openers[c] then
      indentation = indentation + 1
      result[#result] = result[#result] .. c
      result[#result + 1] = string.rep("  ", indentation)
    elseif closers[c] then
      indentation = indentation - 1
      result[#result + 1] = string.rep("  ", indentation) .. c
    elseif c == "," then
      result[#result] = result[#result] .. c
      result[#result + 1] = string.rep("  ", indentation)
    else
      result[#result] = result[#result] .. c
    end
  end
  -- write result
  vim.api.nvim_buf_set_lines(0, input.line1 - 1, input.line2, true, result)
end, { nargs = "*", range = true })

vim.api.nvim_create_user_command("LoadVscodeEnv", function()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = file ~= "" and vim.fn.fnamemodify(file, ":p:h") or vim.loop.cwd()

  local envfile = dir .. "/.vscodeenv"

  local f = io.open(envfile, "r")
  if not f then
    -- vim.notify(".vscodeenv not found in " .. dir, vim.log.levels.WARN)
    return
  end

  for line in f:lines() do
    local k, v = line:match("^(%w+)[ ]*=[ ]*(.+)$")
    if k and v then
      vim.env[k] = v
    end
  end
  f:close()
  -- vim.notify("Loaded .vscodeenv from " .. envfile, vim.log.levels.INFO)
end, { nargs = "*" })

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
  group = initgroup,
  command = "LoadVscodeEnv",
})

-- Last paste object
vim.keymap.set({ "o" }, "iP", function()
  vim.cmd("normal `[v`]`")
end)
vim.keymap.set("x", "iP", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
  vim.cmd("normal `[v`]`")
end)

vim.keymap.set("c", "<C-a>", "<Home>") -- Go to start of line

-- map textobject to select the continuous comment with vim._comment.textobject
vim.keymap.set("o", "ic", require("vim._comment").textobject)
vim.keymap.set("x", "ic", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
  require("vim._comment").textobject()
end)

vim.keymap.set("o", "ie", function()
  vim.cmd("normal! ggVG")
end)

vim.keymap.set("x", "ie", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
  vim.cmd("normal! ggVG")
end)

vim.keymap.set("o", "ae", function()
  vim.cmd("normal! ggVG")
end)

vim.keymap.set("x", "ae", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", false, true, true), "nx", false)
  vim.cmd("normal! ggVG")
end)

require("gui")
require("python_tmux_output")
require("project")
require("qflist_to_dianostics")

vim.keymap.set("n", "<leader>;", "A<C-c><C-\\><C-n>:q<CR>")

vim.api.nvim_create_autocmd("BufEnter", {
  group = initgroup,
  callback = function(ev)
    if not vim.fn.expand("%p"):match("quickfix%-%d+") then
      print(vim.fn.expand("%p"))
    end
  end
})
