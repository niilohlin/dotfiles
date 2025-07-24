" Syntax for .stage files

if exists("b:current_syntax")
  finish
endif

" Commands
syntax match StageCommand /^\s*\(add\|a\|rm\|remove\|r\|restore\|e\|edit\)\>/
highlight def link StageCommand Keyword

" Staged statuses (green if first character is non-space)
syntax match StageStaged /\v\s(M.|A.|D.|R.|C.|U.)/
highlight StageStaged ctermfg=Green guifg=Green

" Unstaged statuses (red if second character is non-space)
syntax match StageUnstaged /\v\s(.M|.D|.U|.\?\?)/
highlight StageUnstaged ctermfg=Red guifg=Red

" Untracked (??) special case
syntax match StageUntracked /\v\s\?\?/
highlight StageUntracked ctermfg=Red guifg=Red

" Path (rest of the line)
syntax match StagePath /\v(\s..)\s+.*/ contains=StageStaged,StageUnstaged,StageUntracked

" Comments
syntax match StageComment /^#.*$/
highlight def link StageComment Comment

let b:current_syntax = "interactive_stage"
