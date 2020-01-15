" session
" Author: skanehira
" License: MIT

let s:save_cpo = &cpo
set cpo&vim

" buffer name
let s:session_list_buffer = 'SESSIONS'
" path separator
let s:sep = fnamemodify('.', ':p')[-1:]

"let g:session_path = expand('~/.vim/sessions')

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echom 'session.vim:' a:msg
  echohl None
endfunction

function! s:files() abort
  let session_path = get(g:, 'session_path', '')
  if session_path is# ''
    call s:echo_err('session_path is empty')
    return []
  endif

  return readdir(session_path, '!isdirectory(v:val)')
endfunction

function! session#sessions() abort
  let files = s:files()
  if empty(files)
    return
  endif

  " if buffer exists
  if bufexists(s:session_list_buffer)
    " if buffer display in window
    let winid = bufwinid(s:session_list_buffer)
    if winid isnot# -1
      call win_gotoid(winid)
    else
      exec 'b' s:session_list_buffer
    endif
  else
    exec 'new' s:session_list_buffer
    set buftype=nofile
    nnoremap <buffer>q :<C-u>bw!<CR>
    nnoremap <buffer> <CR> :<C-u>call session#load_session(trim(getline('.')))<CR>
  endif

  " delete buffer contents
  exec '%d_'
  call setline(1, files)
endfunction

function! session#create_session(file) abort
  exec 'mksession!' join([g:session_path, a:file], s:sep)
  redraw
  echo 'session.vim: created'
endfunction

function! session#load_session(file) abort
  exec 'source' join([g:session_path, a:file], s:sep)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
