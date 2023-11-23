
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
    auto_install = true,

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

local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
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
