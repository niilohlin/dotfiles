
local cmd = vim.cmd
-- Lua does not have support for autogroups yet.
cmd([[
augroup onWrite
    " Set cursor position to old spot
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe  "normal! g'\"" | endif

    " Clear trailing space
    autocmd BufWritePre * :%s/\s\+$//e
augroup END
]])
