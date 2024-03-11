
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
    ignore_install = { },

    -- Automatically install missing parsers when entering buffer
    auto_install = false,

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- list of language that will be disabled
        disable = { },

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
        url = "~/workspace/tree-sitter-make/", -- local path or git repo
        files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
        -- optional entries:
        branch = "main", -- default branch in case of git repo if different from master
        generate_requires_npm = false, -- if stand-alone parser without npm dependencies
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
