" session
" Author: skanehira
" License: MIT

if exists('g:loaded_session')
  finish
endif
let g:loaded_session = 1

let s:save_cpo = &cpo
set cpo&vim

command! Sessions call session#sessions()

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
