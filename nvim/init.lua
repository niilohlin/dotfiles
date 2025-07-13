---@diagnostic disable: missing-fields
-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

function SetTabLength(tab_length)
  vim.opt.tabstop = tab_length
  vim.opt.shiftwidth = tab_length
  vim.opt.softtabstop = tab_length
  vim.opt.expandtab = true
end

-- Set cursor position to old spot
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  callback = function()
    vim.cmd([[ if line("'\"") > 1 && line("'\"") <= line("$") | exe  "normal! g'\"" | endif ]])
  end,
})

-- Remove blank space, and put the cursor back where it was
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function()
    vim.cmd([[ normal mi ]])
    vim.cmd([[ :%s/\s\+$//e ]])
    vim.cmd([[ normal 'i ]])
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescriptreact", "*.js", "*.jsx", "typescript", "*.ts", "*.tsx", "html", "htmldjango" },
  callback = function()
    SetTabLength(2)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    SetTabLength(2)
  end,
})

vim.api.nvim_create_autocmd("FileType", { pattern = "markdown", command = "set spell nofoldenable" })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
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
  pattern = "python",
  callback = function()
    --
    -- set 'include' to '' so that we can use [<c-I> to go to the import.
    vim.opt.include = ""

    -- search for the current line
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "gi", function()
      vim.cmd('normal! "vyiw')
      local selected_text = "def " .. vim.fn.getreg("v") .. "\\("
      builtin.live_grep({ default_text = selected_text })
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

      find_file_using_rg(file_to_edit, builtin.find_files)
    end)

    -- override treesitter keymap
    vim.keymap.set({ "x", "o" }, "am", "<Plug>(PythonsenseOuterFunctionTextObject)")


    -- Always use make. When entering `test_*.py` nvim automatically sets the makeprg to pytest.
    -- But I use neotest to run individual tests.
    vim.opt_local.makeprg = "make"
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "swift",
  callback = function()
    vim.cmd([[ call clearmatches() ]])
    vim.cmd([[ call matchadd('ColorColumn', '\%121v', 100) ]])
    vim.cmd([[ setlocal textwidth=120 ]])
    vim.opt.commentstring = "// %s"
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "yaml", "yml" },
  callback = function()
    SetTabLength(2)
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.html.j2" },
  command = "set filetype=htmldjango",
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
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
  pattern = { "*.log", "*.logs", "*.out", "output", "dap-repl", "dap-repl.*" },
  callback = function()
    vim.cmd([[ set ft=log ]])

    local output_file = os.getenv("NVIM_OUTPUT_FILE")
    if output_file then
      vim.keymap.set("v", "<leader>v", function()
        vim.cmd('normal! "vy')
        local selected_text = vim.fn.getreg("v")
        local file = io.open(output_file, "a")
        if file == nil then
          print("Could not open file: " .. output_file)
          return
        end
        file:write(selected_text)
        file:close()
        vim.cmd("q")
      end)
    end
  end,
})

-- Open diagnostics on hover
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

-- automatically load the file if it has changed from an external source
vim.api.nvim_create_autocmd({ "CursorHold" }, {
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
vim.opt.showcmd = true        -- Show the current command in the bottom right
vim.opt.incsearch = true      -- Incremental search
vim.opt.showmatch = true      -- Highlight search match
vim.opt.ignorecase = true     -- Ignore search casing
vim.opt.smartcase = true      -- But not when searching with uppercase letters
vim.opt.smartindent = true    -- Language-aware indent
vim.opt.autowrite = true      -- Automatically write on :n and :p
vim.opt.autoread = true       -- Automatically read file from disk on change
vim.opt.number = true         -- Set line numbers
vim.opt.relativenumber = true -- Set relative line numbers
vim.opt.backspace = "2"       -- Make backspace work as expected in insert mode.
vim.opt.ruler = true          -- Show cursor col and row position
vim.opt.colorcolumn = "120"   -- Show max column highlight.
vim.opt.modifiable = true     -- Make buffers modifiable.
vim.opt.cursorline = true     -- Show a horizontal line where the cursor is
vim.opt.splitbelow = true     -- Show the preview window (code documentation) to the bottom of the screen.
vim.opt.wildmenu = true       -- Show a menu when using tab completion in command mode.
vim.opt.wildmode = { "longest", "full" }

-- Remove annoying auto inserting comment string
vim.api.nvim_create_autocmd("BufEnter", {
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
-- opt.cmdheight = 0          -- Hide the command line when not needed.

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
MiniDeps.add("lewis6991/gitsigns.nvim")
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
MiniDeps.add("ellisonleao/gruvbox.nvim")
require("gruvbox").setup()
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, "Search", { bg = "#b57614", fg = "#282828" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#af3a03", fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "CurSearch", { bg = "#8f3f71", fg = "#fbf1c7" })

-- project wide search, requires ripgrep
MiniDeps.add("nvim-lua/plenary.nvim")

-- fzf native plugin, make it possible to fuzzy search in telescope
-- Provides `load_extension("fzf")`
MiniDeps.add({
  source = "nvim-telescope/telescope-fzf-native.nvim",
  hooks = {
    post_install = function()
      vim.fn.system(
        "make")
    end
  }
})

MiniDeps.add({
  source = "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  }
})
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")

require("telescope").setup({
  defaults = {
    prompt_prefix = "",
  },
  pickers = {
    find_files = {
      mappings = {
        i = {
          ["<C-S-Q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        },
        n = {
          ["<C-S-Q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        },
      },
    },
  },
})
require("telescope").load_extension("fzf")
vim.keymap.set("n", "<leader>sF", builtin.find_files, {}) -- find files
vim.keymap.set("v", "<leader>sf", function()
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg("v")
  builtin.find_files({ default_text = selected_text })
end)
vim.keymap.set("n", "<leader>sr", builtin.resume, {})    -- Resume last telescope search
vim.keymap.set("n", "<leader>sg", builtin.live_grep, {}) -- live grep
vim.keymap.set("v", "<leader>sg", function()
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg("v")
  builtin.live_grep({ default_text = selected_text })
end)
vim.keymap.set("n", "<leader>sf", function()
  builtin.find_files({ hidden = true, find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } })
end, {})                                                                 -- live find files (including hidden files)
vim.keymap.set("n", "<leader>so", builtin.oldfiles)                      -- Open old files
vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols)          -- live find symbols
vim.keymap.set("n", "<leader>sb", builtin.buffers, {})                   -- Open buffers
vim.keymap.set("n", "<leader>st", builtin.tags)                          -- live find symbols
vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols) -- live find workspace symbols

vim.api.nvim_command("command! Commits lua require('telescope.builtin').git_commits()")
vim.api.nvim_command("command! BCommits lua require('telescope.builtin').git_bcommits()")
vim.api.nvim_command("command! Status lua require('telescope.builtin').git_status()")
vim.api.nvim_command("command! Stash lua require('telescope.builtin').git_stash()")
vim.api.nvim_command("command! Branches lua require('telescope.builtin').git_branches()")

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

vim.keymap.set("n", "<leader>o", function()
  if has_workspace_symbols() then
    builtin.lsp_dynamic_workspace_symbols()
  elseif vim.fn.filereadable("tags") then
    builtin.tags()
  else
    builtin.live_grep()
  end
end, {}) -- Search for tags or lsp workspace symbols

vim.keymap.set("n", "z=", builtin.spell_suggest)

-- Git plugin, provides :Git add, :Git blame etc.
MiniDeps.add("tpope/vim-fugitive")

-- async Make, Dispatch (run), and more, integrates with tmux
MiniDeps.add("tpope/vim-dispatch")

-- [q and ]q to navigate quickfix list for example
MiniDeps.add("tpope/vim-unimpaired")

-- Semantic syntax highlighting
MiniDeps.add("nvim-treesitter/nvim-treesitter")
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

  ignore_install = {},  -- List of parsers to ignore installing

  auto_install = false, -- Automatically install missing parsers when entering buffer

  highlight = {
    enable = true, -- `false` will disable the whole extension
    disable = {},  -- list of language that will be disabled
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

-- Tree sitter text objects
MiniDeps.add("nvim-treesitter/nvim-treesitter-textobjects")

-- Text objects plugin
MiniDeps.add({ source = "echasnovski/mini.ai", dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" } })
require("mini.ai").setup()

-- Surround plugin, adds text objects like ci" and so on.
MiniDeps.add("echasnovski/mini.surround")
local surround = require("mini.surround")
surround.setup({
  mappings = {
    add = "gs",          -- Add surrounding in Normal and Visual modes, overrides "sleep" mapping
    delete = "ds",       -- Delete surrounding
    replace = "cs",      -- Replace surrounding

    find = "",           -- Find surrounding (to the right)
    find_left = "",      -- Find surrounding (to the left)
    highlight = "",      -- Highlight surrounding
    update_n_lines = "", -- Update `n_lines`
    suffix_last = "",    -- Suffix to search with "prev" method
    suffix_next = "",    -- Suffix to search with "next" method
  },
})
vim.keymap.set("v", "C", function() -- C for "call"
  vim.cmd('normal "vc()"vPg;h')
  vim.cmd("startinsert")
end)

-- indentation text objects and jumps
MiniDeps.add("niilohlin/neoindent")
require("neoindent").setup({})


-- Nerd Icons (for example in oil buffers)
MiniDeps.add("echasnovski/mini.icons")
require("mini.icons").setup()

-- File explorer
MiniDeps.add({ source = "stevearc/oil.nvim", dependencies = { "echasnovski/mini.icons" } })
require("oil").setup()
vim.keymap.set("n", "<leader>j", ":Oil<CR>") -- Show current file in Oil
-- Disable netrw. We don't need it if we use oil
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Snippets collection
MiniDeps.add("rafamadriz/friendly-snippets")

-- Completion engine.
MiniDeps.add({
  source = "saghen/blink.cmp",
  hooks = {
    post_install = function()
      vim.fn.system("cd /Users/niilohlin/.local/share/nvim/site/pack/deps/opt/blink.cmp/ && cargo build --release")
    end
  }
})


-- nvim development utils
MiniDeps.add("folke/lazydev.nvim")
-- ft = "lua", -- only load on lua files
require("lazydev").setup({
  library = {
    -- See the configuration section for more details
    -- Load luvit types when the `vim.uv` word is found
    "$VIMRUNTIME",
    { path = "${HOME}/.local/share/nvim/lazy" },
    { path = "${3rd}/luv/library",            words = { "vim%.uv" } },
  },
})

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

-- LSP server Installer/manager
MiniDeps.add("mason-org/mason.nvim")
require("mason").setup()

-- LSP setup
MiniDeps.add("neovim/nvim-lspconfig")
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

lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
})
vim.lsp.config("rust_analyzer", lspconfig.rust_analyzer)

lspconfig.eslint.setup({
  on_attach = function(client, bufnr)
    -- Enable formatting capability for ESLint
    client.server_capabilities.documentFormattingProvider = true

    -- Auto-format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end,
})
vim.lsp.config("eslint", lspconfig.eslint)

-- ruff = {
--   capabilities = capabilities,
--   on_attach = function(client, bufnr)
--     if client.supports_method("textDocument/formatting") then
--       vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
--       vim.api.nvim_create_autocmd("BufWritePre", {
--         group = augroup,
--         buffer = bufnr,
--         callback = function()
--           vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
--         end,
--       })
--     end
--   end,
-- },

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
    -- disable workspace symbols
  },
  capabilities = capabilities,
  on_init = function()
    -- client.server_capabilities.workspaceSymbolProvider = false
  end,
})
vim.lsp.config("jedi_language_server", lspconfig.jedi_language_server)

-- Global mappings.
vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    local builtin = require("telescope.builtin")
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

    declare_method_if_supported("textDocument/definition", "gd", builtin.lsp_definitions)
    declare_method_if_supported("textDocument/implementation", "gri", builtin.lsp_implementations)
    declare_method_if_supported("textDocument/references", "grr", builtin.lsp_references)
    declare_method_if_supported("textDocument/documentSymbol", "gO", builtin.lsp_document_symbols)
    declare_method_if_supported("workspace/symbol", "<leader>ws", builtin.lsp_workspace_symbols)
  end,
})

-- local pwd = vim.loop.cwd()
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "python",
--   callback = function()
--     vim.lsp.start({
--       name = "Omnisearch LSP",
--       filetypes = { "python" },
--       root_dir = pwd,
--       --- @field cmd? string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient
--       cmd = function(dispatchers)
--       end,
--     })
--   end,
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


-- Make anything into an lsp, like linter output etc.
MiniDeps.add("nvimtools/none-ls.nvim")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local null_ls = require("null-ls")
local rope = require("rope")
null_ls.register(rope.auto_import)
-- null_ls.register(rope.completion)
vim.api.nvim_create_user_command("RopeGenerateCache", rope.GenerateRopeCache, { nargs = "*" })

local tailwind = require("tailwind")
null_ls.register(tailwind.completion)

local pylint_disable = {
  method = null_ls.methods.CODE_ACTION,
  filetypes = { "python" },
  generator = {
    fn = function(params)
      local actions = {}
      for _, diag in ipairs(params.lsp_params.context.diagnostics) do
        if diag.source == "pylint" then
          table.insert(actions, {
            title = "Disable pylint (" .. diag.code .. ")",
            action = function()
              local line = diag.range.start.line
              local line_text = vim.api.nvim_buf_get_lines(params.bufnr, line, line + 1, false)[1]
              local line_text_with_disable = line_text .. "  # pylint: disable=" .. diag.code
              vim.api.nvim_buf_set_lines(params.bufnr, line, line + 1, false, { line_text_with_disable })
            end,
          })
        elseif diag.source == "mypy" then
          table.insert(actions, {
            title = "Disable mypy [" .. diag.code .. "]",
            action = function()
              local line = diag.range.start.line
              local line_text = vim.api.nvim_buf_get_lines(params.bufnr, line, line + 1, false)[1]
              local line_text_with_disable = line_text .. "  # type: ignore[" .. diag.code .. "]"
              vim.api.nvim_buf_set_lines(params.bufnr, line, line + 1, false, { line_text_with_disable })
            end,
          })
        end
      end
      return actions
    end,
  },
}

null_ls.register(pylint_disable)

local generic_assignment = {
  method = null_ls.methods.COMPLETION,
  filetypes = { "python", "lua" },
  generator = {
    fn = function(params)
      local snake_case_word = params.content[params.row]:match("([%w_]+)[ =:]")
      if not snake_case_word then
        return {}
      end
      local words = {}
      for word in snake_case_word:gmatch("[^_]+") do
        table.insert(words, word:sub(1, 1):upper() .. word:sub(2))
      end
      local camel_case_word = table.concat(words)
      return {
        {
          items = {
            {
              label = camel_case_word,
              insertText = camel_case_word,
              documentation = "CamelCase",
            },
          },
          isIncomplete = true,
        },
      }
    end,
  },
}

null_ls.register(generic_assignment)
null_ls.register({
  name = "autoflake8_custom",
  method = null_ls.methods.FORMATTING,
  filetypes = { "python" },
  generator = null_ls.formatter({
    command = "autoflake8",
    args = {
      "$FILENAME",
    },
  }),
  to_stderr = true,
  to_stdout = true,
})

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.checkmake,
    null_ls.builtins.formatting.stylua.with({
      extra_args = { "--indent-type", "Spaces", "--indent-width", 2 },
    }),
    null_ls.builtins.formatting.black.with({
      condition = function()
        return vim.fn.filereadable(vim.loop.cwd() .. "/venv/bin/black") ~= 0
      end,
      timeout = 10 * 1000,
      prefer_local = "venv/bin",
      env = function(params)
        return { PYTHONPATH = params.root }
      end,
    }),
    null_ls.builtins.formatting.isort.with({
      condition = function()
        return vim.fn.filereadable(vim.loop.cwd() .. "/venv/bin/isort") ~= 0
      end,
      timeout = 10 * 1000,
      prefer_local = "venv/bin",
      env = function(params)
        return { PYTHONPATH = params.root }
      end,
    }),
    null_ls.builtins.diagnostics.pylint.with({
      condition = function()
        return vim.fn.filereadable(vim.loop.cwd() .. "/venv/bin/pylint") ~= 0
      end,
      timeout = 10 * 1000,
      prefer_local = "venv/bin",
      env = function(params)
        return { PYTHONPATH = params.root }
      end,
    }),
    null_ls.builtins.diagnostics.mypy.with({
      timeout = 10 * 1000,
      prefer_local = ".venv/bin",
      extra_args = {},
      env = function(params)
        return { PYTHONPATH = params.root }
      end,
    }),
    null_ls.builtins.formatting.prettier.with({
      prefer_local = "./node_modules/prettier/bin/",
      filetypes = {
        "css",
        "html",
        "htmldjango",
      },
      extra_args = { "--write" },
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
        end,
      })
    end
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.html",
      callback = function()
        print("formatting")
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})

-- CamelCase to snake case (crc, crm, crs, cru), including :Sub command to substitute with smart casing
MiniDeps.add("johmsalas/text-case.nvim")
require("textcase").setup({})
require("telescope").load_extension("textcase")

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

-- json5
MiniDeps.add({
  source = "Joakker/lua-json5",
  hooks = {
    post_install = function()
      vim.fn.system("./install.sh")
    end
  }
})

-- Debug support
MiniDeps.add("mfussenegger/nvim-dap")
require("dap.ext.vscode").json_decode = require("json5").parse
local dap = require("dap")
vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end)
vim.keymap.set("n", "<leader>b", function()
  dap.toggle_breakpoint()
end)
vim.keymap.set("n", "<leader>dr", function()
  dap.repl.open()
end)
vim.keymap.set("n", "<leader>dt", function()
  dap.terminate()
end)
vim.keymap.set("n", "<leader>dn", function()
  dap.continue({ new = true })
end)
vim.keymap.set("n", "<leader>ds", function()
  dap.step_over()
end)
vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })


MiniDeps.add("mfussenegger/nvim-dap-python")
require("dap-python").setup("./venv/bin/python")
vim.env.GEVENT_SUPPORT = "True"
table.insert(dap.configurations.python, {
  type = "python",
  request = "launch",
  name = "dap Django",
  program = vim.fn.getcwd() .. "/quickbit/manage.py", -- NOTE: Adapt path to manage.py as needed
  args = { "runserver", "--noreload" },
})

MiniDeps.add("theHamsta/nvim-dap-virtual-text")
require("nvim-dap-virtual-text").setup({ virt_text_pos = "eol" })

MiniDeps.add("nvim-neotest/nvim-nio")

MiniDeps.add("nvim-neotest/neotest")
MiniDeps.add("nvim-neotest/neotest-python")
---@module "neotest"
local neotest = require("neotest")
neotest.setup({
  summary = {
    mappings = {
      help = "g?", -- change "?" to "g?" so that you can search backwards.
    },
  },
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
      args = { "-vv" },
      -- args = { "--disable-warnings", "-n 10", "-m 'not slow'" },
    }),
  },
})

vim.keymap.set("n", "<leader>tr", neotest.run.run)
vim.keymap.set("n", "<leader>td", function()
  neotest.run.run({ strategy = "dap" })
end)

vim.keymap.set("n", "<leader>ts", neotest.summary.open)
vim.api.nvim_create_user_command("NeotestStopTest", neotest.run.stop, { nargs = "*" })
vim.keymap.set("n", "<c-w>t", neotest.output.open)
vim.keymap.set("n", "<c-w><c-t>", neotest.output.open)
vim.keymap.set("n", "]j", function()
  neotest.jump.next({ status = "failed" })
end)
vim.keymap.set("n", "[j", function()
  neotest.jump.prev({ status = "failed" })
end)

vim.api.nvim_create_user_command("NeotestOpenOutputPanel", neotest.output_panel.open, { nargs = "*" })
vim.api.nvim_create_user_command("NeotestOpenSummary", neotest.summary.open, { nargs = "*" })


-- nicer status line
MiniDeps.add("nvim-lualine/lualine.nvim")

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
    lualine_x = {},
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


-- Markdown utility, go to link and so on.
MiniDeps.add("plasticboy/vim-markdown")


-- quickfix improvement
MiniDeps.add("stevearc/quicker.nvim")
require("quicker").setup({})

-- Disable search highlight after searching.
MiniDeps.add("romainl/vim-cool")

-- multi cursor support
MiniDeps.add("jake-stewart/multicursor.nvim")
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

-- normal mode in the cmd line
MiniDeps.add("jake-stewart/normal-cmdline.nvim")
-- make the cmdline insert mode a beam
vim.opt.guicursor:append("ci:ver1,c:ver1")
local cmd = require("normal-cmdline")
cmd.setup({
  -- key to hit within cmdline to enter normal mode:
  key = "<esc>",
  -- the cmdline text highlight when in normal mode:
  hl = "Normal",
  -- these mappings only apply to normal mode in cmdline:
  mappings = {
    ["k"] = cmd.history.prev,
    ["j"] = cmd.history.next,
    ["<cr>"] = cmd.accept,
    ["<esc>"] = cmd.cancel,
    ["<c-c>"] = cmd.cancel,
    [":"] = cmd.reset,
  },
})


-- removes all "press enter to continue"
MiniDeps.add("jake-stewart/auto-cmdheight.nvim")
require("auto-cmdheight").setup()

-- add a scroll bar
MiniDeps.add("petertriho/nvim-scrollbar")
require("scrollbar").setup({
  marks = {
    Cursor = {
      text = " ", -- Remove cursor indicator
    },
  },
})
-- https://github.com/kevinhwang91/nvim-hlslens

-- better python movements and text objects
MiniDeps.add("jeetsukumaran/vim-pythonsense")
vim.g.is_pythonsense_suppress_object_keymaps = 1



-- refactoring library
MiniDeps.add("ThePrimeagen/refactoring.nvim")
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


-- Generic log highlighting
MiniDeps.add("fei6409/log-highlight.nvim")
require("log-highlight").setup({
  extension = { "*.log", "*.logs", "*.out", "output", "dap-repl", "dap-repl.*" },
  filename = {},
  pattern = {
    "/var/log/.*",
  },
}
)

-- Vim open file including line number, including gF
-- $ vim file.py:10
MiniDeps.add("wsdjeg/vim-fetch")


-- code action previewer
MiniDeps.add("nvim-telescope/telescope-ui-select.nvim")
require("telescope").load_extension("ui-select")
MiniDeps.add("aznhe21/actions-preview.nvim")

local actions_preview = require("actions-preview")
actions_preview.setup({
  telescope = {
    sorting_strategy = "ascending",
    layout_strategy = "vertical",
    layout_config = {
      width = 0.8,
      height = 0.9,
      prompt_position = "top",
      preview_cutoff = 20,
      preview_height = function(_, _, max_lines)
        return max_lines - 15
      end,
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfigActionsPreview", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set({ "v", "n" }, "gra", actions_preview.code_actions, opts)
  end,
})


-- ChatGPT plugin
MiniDeps.add("echasnovski/mini.diff")
MiniDeps.add("olimorris/codecompanion.nvim")
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

-- Pure lua replacement for github/copilot. Has more features and is more efficient.
-- MiniDeps.add("zbirenbaum/copilot.lua")
-- require("copilot").setup({
--   suggesion = {
--     keymap = {
--       accept = "<Right>",
--       next = "<C-X><C-E>",
--     },
--   },
-- })
-- vim.keymap.set("i", "<C-X><C-e>", function()
--   require("copilot.suggestion").next()
-- end)
-- vim.keymap.set("i", "<Right>", function()
--   require("copilot.suggestion").accept()
-- end)

-- end plugins


require("project").setup({})

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

vim.api.nvim_create_user_command("Translate", function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 1 then
    local line = lines[1]
    local start_col = start_pos[3]
    local end_col = end_pos[3]
    local selected = line:sub(start_col, end_col)
    lines[1] = line:sub(1, start_col - 1) .. '{{ _("' .. selected .. '") }}' .. line:sub(end_col + 1)
  else
    print("Multiline selection is not supported yet.")
    return
  end

  -- Replace lines
  vim.fn.setline(start_pos[2], lines)
end, { range = true })

local bullseye = require("bullseye")
vim.keymap.set("n", "<leader>ma", bullseye.toggle_current_loc_to_loclist)

-- Never use Q for ex mode.
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "p", "p=`]") -- paste and reindent
vim.keymap.set("n", "P", "P=`]") -- paste and reindent above

-- Normal remaps
vim.keymap.set("n", "<C-U>", "<C-U>zz")      -- Move cursor to middle of screen
vim.keymap.set("n", "<C-D>", "<C-D>zz")      -- Move cursor to middle of screen

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
      result[#result + 1] = string.rep("    ", indentation)
    elseif closers[c] then
      indentation = indentation - 1
      result[#result + 1] = string.rep("    ", indentation) .. c
    elseif c == "," then
      result[#result] = result[#result] .. c
      result[#result + 1] = string.rep("    ", indentation)
    else
      result[#result] = result[#result] .. c
    end
  end
  -- write result
  vim.api.nvim_buf_set_lines(0, input.line1 - 1, input.line2, true, result)
end, { nargs = "*", range = true })

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

-- check if running via ssh
if os.getenv("SSH_CLIENT") then
  vim.keymap.set("v", '"*y', function()
    -- copy to system clipboard
    vim.cmd('normal! "+y')
    -- run sync-clipboard terminal program
    vim.fn.jobstart("sync-clipboard", {
      on_exit = function(_, _, _)
        print("Synced to client clipboard")
      end,
    })
  end)
end

vim.api.nvim_create_autocmd("Filetype", {
  pattern = "sql",
  callback = function()
    vim.keymap.del("i", "<left>", { buffer = true })
    vim.keymap.del("i", "<right>", { buffer = true })
  end,
})
require("gui")

local yank_path = vim.fn.stdpath("state") .. "/yank"
local augroup = vim.api.nvim_create_augroup("shared_yank_register", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained" }, {
  callback = function()
    if vim.fn.filereadable(yank_path) == 1 then
      vim.fn.setreg('"', vim.fn.readfile(yank_path))
    end
  end,
  group = augroup,
})

vim.api.nvim_create_autocmd({ "FocusLost" }, {
  callback = function()
    local file = io.open(yank_path, "w")
    if file ~= nil then
      io.output(file)
      io.write(vim.fn.getreg('"'))
      io.close(file)
    end
  end,
  group = augroup,
})
-- (call
--   function: (identifier) @func_name  (#eq? @func_name "Template")
--   arguments: (argument_list (string) @content)
-- ) @template_call
--
-- (call
--   function: (identifier) @func_name  (#eq? @func_name "HTMLResponse")
--   arguments: (argument_list (string) @content)

-- ) @template_call
