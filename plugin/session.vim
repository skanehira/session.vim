" session
" Author: skanehira
" License: MIT

if exists('g:loaded_session')
  finish
endif
let g:loaded_session = 1

let s:save_cpo = &cpo
set cpo&vim

command! SessionList call session#sessions()
command! -nargs=1 SessionCreate call session#create_session(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
