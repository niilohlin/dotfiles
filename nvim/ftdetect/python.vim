

autocmd FileType python let g:syntastic_python_checkers = ['mypy', 'python']

" Make Vim tmux runner compatible with python
autocmd FileType python let g:VtrStripLeadingWhitespace = 0
autocmd FileType python let g:VtrClearEmptyLines = 0
autocmd FileType python let g:VtrAppendNewline = 1

augroup skeletonpy
    autocmd!
    autocmd bufnewfile *.py 0r ~/.config/nvim/skeleton/skeleton.py
augroup END

