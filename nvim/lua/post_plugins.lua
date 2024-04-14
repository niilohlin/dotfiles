
-- disable netrw at the very start of your init.lua
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
--
-- -- set termguicolors to enable highlight groups
-- vim.opt.termguicolors = true

require('telescope').load_extension('fzf')

-- `:` cmdline setup.
local cmp = require('cmp')
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})
