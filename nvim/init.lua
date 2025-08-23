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
      vim.schedule(function()
        MiniPick.set_picker_query({selected_text})
      end)
      MiniPick.builtin.live_grep()
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

      find_file_using_rg(file_to_edit, MiniPick.builtin.files)
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
vim.opt.showcmd = false       -- Don't show the current command in the bottom right, annoying
vim.opt.showmatch = true      -- Highlight search match
vim.opt.ignorecase = true     -- Ignore search casing
vim.opt.smartcase = true      -- But not when searching with uppercase letters
vim.opt.smartindent = true    -- Language-aware indent
vim.opt.autowrite = true      -- Automatically write on :n and :p
vim.opt.autoread = true       -- Automatically read file from disk on change
vim.opt.number = true         -- Set line numbers
vim.opt.relativenumber = true -- Set relative line numbers
vim.opt.colorcolumn = "120"   -- Show max column highlight.
vim.opt.cursorline = true     -- Show a horizontal line where the cursor is
vim.opt.splitbelow = true     -- Show the preview window (code documentation) to the bottom of the screen.
vim.opt.wildmode = { "longest", "full" }
vim.opt.swapfile = false      -- Disable swapfile
vim.opt.signcolumn = "yes"    -- Always show sign column to avoid indenting and jumping
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
vim.g.python3_host_prog = os.getenv("HOME") .. "/.local/share/nvim/venv/bin/python"

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
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
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
vim.pack.add({ "https://github.com/ellisonleao/gruvbox.nvim" })
require("gruvbox").setup()
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, "Search", { bg = "#b57614", fg = "#282828" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#af3a03", fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "CurSearch", { bg = "#8f3f71", fg = "#fbf1c7" })

-- project wide search, requires ripgrep
vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })


vim.pack.add({ "https://github.com/echasnovski/mini.pick" })
vim.pack.add({ "https://github.com/echasnovski/mini.extra" })
require('mini.pick').setup({
  window = {
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = 'NW', height = height, width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end
  }
})
require('mini.extra').setup()
vim.ui.select = require('mini.pick').ui_select

vim.keymap.set("n", "<leader>sF", MiniPick.builtin.files, {}) -- find files
vim.keymap.set("v", "<leader>sf", function()
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg("v")
  vim.schedule(function()
    MiniPick.set_picker_query({selected_text})
  end)
  MiniPick.builtin.files()
end)
vim.keymap.set("n", "<leader>sr", MiniPick.builtin.resume, {}) -- Resume last search
vim.keymap.set("n", "<leader>sg", MiniPick.builtin.grep_live, {})   -- live grep
vim.keymap.set("v", "<leader>sg", function()
  local selected_text = vim.fn.getreg("v")
  vim.schedule(function()
    MiniPick.set_picker_query({selected_text})
  end)
  MiniPick.builtin.grep_live()
end)
vim.keymap.set("n", "<leader>sf", function()
  MiniPick.builtin.files({
    tool = 'git'
  })
end, {})                                                               -- live find files (including hidden files)
vim.keymap.set("n", "<leader>sh", MiniPick.builtin.help)                                        -- Open help tags
vim.keymap.set("n", "<leader>so", MiniExtra.pickers.oldfiles)                                        -- Open old files
vim.keymap.set("n", "<leader>sj", function() MiniExtra.pickers.list({ scope = 'jumplist' }) end)     -- Open jumplist
vim.keymap.set("n", "<leader>sm", MiniExtra.pickers.marks)                                           -- Open marks
-- vim.keymap.set("n", "<leader>sb", Snacks.picker.buffers, {})                                         -- Open buffers
-- vim.keymap.set("n", "<leader>st", MiniExtra.pickers.tags) -- live find symbols
vim.keymap.set("n", "<leader>ws", function() MiniExtra.pickers.lsp({ scope = "workspace_symbols" }) end) -- live find workspace symbols

vim.keymap.set("n", "z=", MiniExtra.pickers.spellsuggest)

-- Git plugin, provides :Git add, :Git blame etc.
vim.pack.add({ "https://github.com/tpope/vim-fugitive" })

-- async Make, Dispatch (run), and more, integrates with tmux
vim.pack.add({ "https://github.com/tpope/vim-dispatch" })

-- [q and ]q to navigate quickfix list for example
vim.pack.add({ "https://github.com/tpope/vim-unimpaired" })

-- Semantic syntax highlighting
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
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
  end,
})

-- Tree sitter text objects
-- Text objects plugin
vim.pack.add({ "https://github.com/echasnovski/mini.ai", "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("mini.ai").setup()
  end,
})

-- Surround plugin, adds text objects like ci" and so on.
vim.pack.add({ "https://github.com/echasnovski/mini.surround" })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = initgroup,
  once = true,
  callback = function()
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
  end,
})

-- indentation text objects and jumps
vim.pack.add({ "https://github.com/niilohlin/neoindent" })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = initgroup,
  once = true,
  callback = function()
    require("neoindent").setup({})
  end,
})

-- Nerd Icons (for example in oil buffers)
-- File explorer
vim.pack.add({ "https://github.com/stevearc/oil.nvim", "https://github.com/echasnovski/mini.icons" })
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
vim.pack.add({ "https://github.com/rafamadriz/friendly-snippets" })

-- Completion engine.
vim.api.nvim_create_autocmd('PackChanged', {
  group = initgroup,
  once = true,
  callback = function(event)
    if event.data.spec == "blink.cmp" then
      vim.fn.system(("cd %s && cargo build --release"):format(event.data.path))
    end
  end
})
vim.pack.add({
  "https://github.com/saghen/blink.cmp",
})

-- refactoring library
vim.pack.add({ "https://github.com/ThePrimeagen/refactoring.nvim" })
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
vim.pack.add({ "https://github.com/fei6409/log-highlight.nvim" })
require("log-highlight").setup({
  extension = { "*.log", "*.logs", "*.out", "output", "dap-repl", "dap-repl.*" },
  filename = {},
  pattern = {
    "/var/log/.*",
  },
})

-- Vim open file including line number, including gF
-- $ vim file.py:10
vim.pack.add({ "https://github.com/wsdjeg/vim-fetch" })

-- ChatGPT plugin
vim.pack.add({ "https://github.com/echasnovski/mini.diff" })
vim.pack.add({ "https://github.com/olimorris/codecompanion.nvim" })
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
vim.pack.add({ "https://github.com/brianhuster/unnest.nvim" })

-- neovim web server
vim.pack.add({ "https://github.com/gn0/nvim-web-server" })

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

vim.keymap.set("n", "p", "p=`]")             -- paste and reindent
vim.keymap.set("n", "P", "P=`]")             -- paste and reindent above

vim.keymap.set("i", "<C-X><C-G>", function()
  vim.api.nvim_put({ vim.fn.expand("%") }, "c", true, true)
end)

vim.api.nvim_command("command W w") -- Remap :W to :w

vim.api.nvim_create_user_command("PrettyPrint", function(input)
  if input.bang then
    vim.cmd("%s/\\\\n/\\r/g")
    return
  end

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
end, { nargs = "*", range = true, bang = true })

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
vim.keymap.set("c", "<C-e>", "<End>") -- Go to end of line

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

vim.keymap.set("n", "<leader>;", "A<C-c><C-\\><C-n>:q<CR>")

vim.api.nvim_create_autocmd("BufEnter", {
  group = initgroup,
  callback = function(ev)
    if not vim.fn.expand("%p"):match("quickfix%-%d+") then
      print(vim.fn.expand("%p"))
    end
  end
})

require("gui")
require("python_output")
require("rope")
require("project")
require("qflist_to_dianostics")
require("vault")
