
au BufNewFile,BufRead Fastfile,Appfile,Snapfile,Scanfile,Gymfile,Matchfile,Deliverfile,Dangerfile,*.gemspec set filetype=ruby
autocmd FileType ruby setlocal shiftwidth=2
autocmd FileType ruby setlocal tabstop=2
autocmd FileType ruby setlocal softtabstop=2
autocmd FileType ruby setlocal expandtab
autocmd FileType ruby compiler ruby
" autocmd FileType ruby let g:VtrStripLeadingWhitespace = 0
" autocmd FileType ruby let g:VtrClearEmptyLines = 0
" autocmd FileType ruby let g:VtrAppendNewline = 1

let g:syntastic_ruby_checkers = ['rubocop']
augroup skeleton
    autocmd!
    "adds bash shebang to .sh files
    autocmd bufnewfile *.rb 0r ~/.config/nvim/skeleton/skeleton.rb
augroup END
