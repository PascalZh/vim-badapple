
command BadApple :call s:Start()

let s:path_head = expand('<sfile>:p:h:h')
let s:frames = []
let s:thread_v1_stop = 0
let s:initialized = 0
let s:interrupted = 0

if has('win32')
  let s:path_v1_music = s:path_head . '\version1\badapple.mp3'
else
  let s:path_v1_music = s:path_head . '/version1/badapple.mp3'
endif

function! s:Start()

  tabnew

  setlocal bufhidden=delete
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nowrap
  setlocal modifiable
  setlocal mousehide

  let s:oldguifont=&guifont
  set guifont=monofur\ for\ Powerline\ 5

  while 1
    call s:Play_V1()
    if s:interrupted == 0
      let ans = input('Thanks for watching! Do you want to replay(y)?')
      if ans !=# 'y'
        break
      endif
    else
      break
    endif
  endwhile

  let &guifont=s:oldguifont
  bwipeout

endfunction

function! s:Initialize()
  " read file into s:frames
  for i in range(1, 6570)

    if has('win32')
      let path = s:path_head . '\version1\_' . string(i) . '.txt'
    else
      let path = s:path_head . '/version1/_' . string(i) . '.txt'
    endif

    let frame = readfile(path)
    call add(s:frames, frame)

  endfor
endfunction

" play the bad apple of version 1
" 3 minutes 39 seconds (219,140 ms)
function! s:Play_V1()

  if s:initialized == 0
    let s:initialized = 1
    call s:Initialize()
  endif

  " play
  call s:Play_V1_With_Thread()
endfunction

" this will play for 217 seconds on my machine
function! s:cbRefresh_V1()
  let s:t = localtime()
  for i in range(len(s:frames))
    for ind_row in range(len(s:frames[i]))
      call setline(ind_row+1, s:frames[i][ind_row])
    endfor

    if s:thread_v1_stop == 1
      break
    endif

    redraw
    " it is the most suitable value
    sleep 25m
  endfor
  let timespan = localtime() - s:t
  echom "play time: " . string(timespan) . "s"

endfunction


function! s:Play_V1_With_Thread()
pythonx << EOF

import vim, threading, time
path = vim.eval('s:path_v1_music')

if vim.eval("has('gui_running')") == "0":
    import pygame
    pygame.mixer.init()
    pygame.mixer.music.load(path)
    time.sleep(0.5)
    pygame.mixer.music.play(1)
elif vim.eval("has('gui_running')") == "1":
    import pygame
    pygame.mixer.init()
    pygame.mixer.music.load(path)
    pygame.mixer.music.play(1)

def cb():
    vim.command("call s:cbRefresh_V1()")

t = threading.Thread(target=cb, name='RefreshTxtThread(2)')
t.start()

vim.command("let s:y=input('quit?(q)')")
if vim.eval("s:y") == 'q':
    vim.command("let s:interrupted=1")
    vim.command("let s:thread_v1_stop=1")

t.join()

if vim.eval("has('gui_running')") == "0":
    pygame.mixer.music.stop()
elif vim.eval("has('gui_running')") == "1":
    pygame.mixer.music.stop()

EOF
endfunction
