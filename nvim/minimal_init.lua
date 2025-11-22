-- options
vim.opt.showcmd = false       -- Don't show the current command in the bottom right, annoying
vim.opt.showmatch = true      -- Highlight search match vim.opt.ignorecase = true     -- Ignore search casing
vim.opt.smartcase = true      -- But not when searching with uppercase letters
vim.opt.smartindent = true    -- Language-aware indent
vim.opt.autowrite = true      -- Automatically write on :n and :p
vim.opt.autoread = true       -- Automatically read file from disk on change
vim.opt.number = true         -- Set line numbers
vim.opt.relativenumber = true -- Set relative line numbers
vim.opt.cursorline = true     -- Show a horizontal line where the cursor is
vim.opt.splitbelow = true     -- Show the preview window (code documentation) to the bottom of the screen.
vim.opt.wildmode = { "longest", "full" }
vim.opt.signcolumn = "yes"    -- Always show sign column to avoid indenting and jumping
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.updatetime = 500
vim.opt.list = true -- Show whitespace characters.
vim.opt.listchars = { tab = "› ", trail = "·", extends = "›", precedes = "‹", nbsp = "+" } -- Show these characters
vim.opt.whichwrap = vim.opt.whichwrap + "<,>,[,],l,h" -- Move cursor to next line when typing these characters.
vim.opt.undofile = true -- Use undo file
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir" -- Set undo dir
vim.opt.scrolloff = 1 -- Scroll 1 line before cursor hits bottom
vim.opt.path:append("**") -- make :find search recursively
vim.opt.wildignore:append("*.o,*.obj,*.pyc,*.class") -- ignore build files when recursively searching
vim.opt.wildignore:append("*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store,*/.vscode/*,*/.pytest_cache/*,*/__pycache__/*")
vim.opt.wildignore:append("*/venv/*,*/.venv/*,*/node_modules/*,*/target/*,*/build/*,*/dist/*,*/.next/*,*/.cache/*")
vim.cmd([[set virtualedit="block"]])
-- Set leader to <space>
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.diagnostic.config({
  float = {
    source = true,
  },
})


vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/ellisonleao/gruvbox.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

require("gruvbox").setup()
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, "Search", { bg = "#b57614", fg = "#282828" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#af3a03", fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "CurSearch", { bg = "#8f3f71", fg = "#fbf1c7" })

require("oil").setup()
vim.keymap.set("n", "-", "<CMD>Oil<CR>") -- Show current file in Oil
-- Disable netrw. We don't need it if we use oil
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("mini.pick").setup()
vim.keymap.set("n", "<leader>sf", "<CMD>Pick files<CR>")
vim.keymap.set("n", "<leader>sg", "<CMD>Pick grep_live<CR>")

-- LSP setup
local lspconfig = require("lspconfig")

lspconfig.jedi_language_server.setup({
  cmd = { "uvx", "jedi-language-server" },
  init_options = {
    completion = {
      -- LSP snippets turned out to insisting on inserting parens everywhere
      disableSnippets = true,
    },
  },
})
vim.lsp.config("jedi_language_server", lspconfig.jedi_language_server)
vim.lsp.enable('jedi_language_server')

vim.lsp.config("ruff", lspconfig.ruff)
vim.lsp.enable('ruff')

local configs = require("nvim-treesitter.configs")
configs.setup({
  modules = {},
  ensure_installed = {
    "lua",
    "python",
  },
  sync_install = false, -- Install languages synchronously (only applied to `ensure_installed`)
  ignore_install = {},  -- List of parsers to ignore installing
  auto_install = false, -- Automatically install missing parsers when entering buffer
  highlight = {
    enable = true, -- `false` will disable the whole extension
    disable = {},  -- list of language that will be disabled
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

-- enable extui nightly
require('vim._extui').enable({
  enable = true,
})
