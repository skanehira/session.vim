" session
" Author: skanehira
" License: MIT

" buffer name
let s:session_list_buffer = 'SESSIONS'
" path separator
let s:sep = fnamemodify('.', ':p')[-1:]

if exists('*readdir')
  let s:readdir = function('readdir')
else
  function! s:readdir(dir) abort
    return map(glob(a:dir . s:sep . '*', 1, 1), 'fnamemodify(v:val, ":t")')
  endfunction
endif

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'session.vim:' a:msg
  echohl None
endfunction

function! s:files() abort
  let session_path = get(g:, 'session_path', '')
  if session_path is# ''
    call s:echo_err('session_path is empty')
    return []
  endif

  let session_path = expand(session_path)
  let Filter = { file -> !isdirectory(session_path . s:sep . file) }
  return filter(s:readdir(session_path), Filter)
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
      execute 'sbuffer' s:session_list_buffer
    endif
  else
    execute 'new' s:session_list_buffer
    set buftype=nofile

    nnoremap <silent> <buffer>
          \   <Plug>(session-close)
          \   :<C-u>bwipeout!<CR>
    nnoremap <silent> <buffer>
          \   <Plug>(session-open)
          \   :<C-u>call session#load_session(trim(getline('.')))<CR>

    nmap <buffer> q <Plug>(session-close)
    nmap <buffer> <CR> <Plug>(session-open)
  endif

  " delete buffer contents
  %delete _
  call setline(1, files)
endfunction

function! session#create_session(file) abort
  execute 'mksession!' join([g:session_path, a:file], s:sep)
  redraw
  echo 'session.vim: created'
endfunction

function! session#load_session(file) abort
  execute 'source' join([g:session_path, a:file], s:sep)
endfunction
