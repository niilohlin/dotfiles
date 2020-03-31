

autocmd FileType python let g:syntastic_python_checkers = ['pylint'] " mypy

" Make Vim tmux runner compatible with python
autocmd FileType python let g:VtrStripLeadingWhitespace = 0
autocmd FileType python let g:VtrClearEmptyLines = 0
autocmd FileType python let g:VtrAppendNewline = 1


