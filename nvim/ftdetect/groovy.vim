au BufNewFile,BufRead Jenkinsfile setf groovy
autocmd FileType groovy let g:syntastic_groovy_checkers = ['npm_groovy_lint']
