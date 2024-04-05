
-- disable netrw at the very start of your init.lua
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
--
-- -- set termguicolors to enable highlight groups
-- vim.opt.termguicolors = true

require('telescope').load_extension('fzf')


-- Configure Wilder
local wilder = require('wilder')

-- Run Wilder in all modes
wilder.setup({
    modes = {':', '/', '?'},
})

wilder.set_option('pipeline', {
    -- Debounce the execution of the command by 300ms.
    -- This is because it's annoying that they window opens when empty.
    wilder.debounce(300),
    wilder.branch(
        wilder.cmdline_pipeline(),
        wilder.search_pipeline()
    )
})

-- Render results using a popup menu.
wilder.set_option('renderer', wilder.popupmenu_renderer({
    highlighter = wilder.basic_highlighter(),
}))
