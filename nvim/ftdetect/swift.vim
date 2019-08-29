call clearmatches()
call matchadd('ColorColumn', '\%121v', 100)

autocmd BufNewFile,BufRead *.stencil set filetype=swift
autocmd FileType swift setlocal textwidth=120


let g:tagbar_type_swift = {
  \ 'ctagstype': 'swift',
  \ 'kinds' : [
    \ 'n:Enums',
    \ 't:Typealiases',
    \ 'p:Protocols',
    \ 's:Structs',
    \ 'c:Classes',
    \ 'f:Functions',
    \ 'v:Variables',
    \ 'e:Extensions'
  \ ],
  \ 'sort' : 0
\ }

let g:syntastic_swift_checkers = ['swift', 'swiftpm', 'swiftlint']
