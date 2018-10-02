if exists('did_badapple_vim') || &cp || version < 700
  finish
endif
let did_badapple_vim = 1

command BadApple :call s:start()
command BadAppleRestoreGUI :call s:restoreGUI()
command BadAppleClearMemory :call s:clearMemory()

" variables {{{1
let s:DEBUG_ON = 0
let s:path_head = expand('<sfile>:p:h:h')
let s:frames = []
let s:initialized = 0

let s:width = 288
let s:height = 108

if has('win32')
  let s:path_v1_music = s:path_head . '\version1\badapple.mp3'
else
  let s:path_v1_music = s:path_head . '/version1/badapple.mp3'
endif

function! IsDebugOn()
  return s:DEBUG_ON
endfunction

" function! s:start() {{{1
function! s:start()

  tabnew

  setlocal bufhidden=delete
  setlocal nobuflisted
  "setlocal buftype=nofile
  setlocal noswapfile
  setlocal nowrap
  setlocal modifiable
  setlocal mousehide
  setlocal noruler
  setlocal nonumber
  setlocal norelativenumber
  setlocal cmdheight=1
  AirlineToggle
  hi clear
  set background=dark
  winpos 0 0
  sleep 10m
  set guifont=monofur\ for\ Powerline\ 4
  if !has('gui_running')
    resize 4999
    vertical resize 4999
  endif
  set columns=4999
  set lines=4999

  while 1
    call s:dispatchPlay('v1')
    let ans = input('Thanks for watching! Do you want to replay(y)?')
    if ans !=# 'y'
      break
    endif
  endwhile

  call s:restoreGUI()
  AirlineToggle
  bwipeout

endfunction

" fun s:dispatchPlay(mesg){{{1
fun! s:dispatchPlay(mesg)
  if a:mesg ==# 'v1'
    call s:PLAY_V1()
  elseif a:mesg ==# 'v1e'
    call s:PLAY_V1_E()
  endif
  
endf
" function! s:PLAY_V1() {{{1
" play the bad apple of version 1
" 3 minutes 39 seconds (219,140 ms)
function! s:PLAY_V1()

  if s:initialized == 0
    let s:initialized = 1
    call s:initializeV1()
  endif

  " play
  call s:playMusic()
  call s:play()
  call s:stopMusic()
endfunction

" function! s:initializeV1() {{{2
function! s:initializeV1()
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

  " transform s:frames
  "let s:x = 0
  "let s:y = 0
  "let columns = getwininfo()[0]['width']
  "let lines = getwininfo()[0]['height']
  "if columns > s:width
    "let s:x = (&columns - s:width) / 2
  "endif
  "if lines > s:height
    "let s:y = (&lines - s:height) / 2
  "endif
  "call s:transformFrames(s:x, s:y)
  "echom "BadApple: transform to (" .
        "\ string(s:x) . ", " .
        "\ string(s:y) . ") succeed!"
endfunction

" function! s:play() {{{2
" this will play for 217 seconds on my machine
function! s:play()
  for i in range(len(s:frames))
    for ind_row in range(len(s:frames[i]))
      call setline(ind_row+1, s:frames[i][ind_row])
    endfor
    redraw

    " it is the most suitable value
    sleep 20m
  endfor
endfunction

" function! s:PLAY_V1_E() {{{1
function! s:PLAY_V1_E()

  call input("ready to play")
  for i in range(1, 6570)

    if has('win32')
      let path = s:path_head . '\version1\_' . string(i) . '.txt'
    else
      let path = s:path_head . '/version1/_' . string(i) . '.txt'
    endif

    execute "read " . path

    redraw
    sleep 20m
    redraw
    bdelete!
  endfor

endfunction
" function! s:playMusic() {{{1
function! s:playMusic()
pythonx << EOF
import vim
import pygame
path = vim.eval('s:path_v1_music')
pygame.mixer.init()
pygame.mixer.music.load(path)
pygame.mixer.music.play(1)
EOF
endfunction

" function! s:stopMusic() {{{1
function! s:stopMusic()
  pythonx pygame.mixer.music.stop()
endfunction

" function! s:transformFrames(x, y) {{{1
"function! s:transformFrames(x, y)
  "if a:x == 0 && a:y == 0
    "return
  "elseif a:x < 0 || a:y < 0
    "echom "BadApple(error) s:transformFrames(x, y)  improper (x, y)"
  "endif

  "for i in range(len(s:frames))
    "" y axis
    "for times in range(a:y)
      "let temp = Mstr(' ', len(s:frames[i][0]))
      "call insert(s:frames[i], temp)
    "endfor
    "" x axis
    "for j in range(len(s:frames[i]))
      "let s:frames[i][j] = Mstr(' ', a:x) . s:frames[i][j]
    "endfor
  "endfor
"endfunction

" func! Mstr(str, i) multiply strings {{{2
function! Mstr(str, i)
  let res=""
  for j in range(a:i)
    let res = res . a:str
  endfor
  return res
endfunction

" function! s:clearMemory() {{{1
function! s:clearMemory()
  let s:frames=[]
  let s:initialized=0
  echom "BadApple clear memory succeed!"
endfunction

" function! s:restoreGUI() {{{1
let s:oldguifont=&guifont
let s:oldlines=&lines
let s:oldcolumns=&columns

function! s:restoreGUI()
  let &lines = s:oldlines
  let &columns = s:oldcolumns
  let &guifont = s:oldguifont
  color industry
endfunction

