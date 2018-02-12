
autocmd FileType haskell noremap <silent> <leader>ht :GhcModType<CR>
autocmd FileType haskell noremap <silent> <leader>hh :GhcModTypeClear<CR>
autocmd FileType haskell noremap <silent> <leader>t  :GhcModTypeInsert<CR>
autocmd FileType haskell noremap <silent> <leader>hc :SyntasticCheck ghc_mod<CR>:lopen<CR>
