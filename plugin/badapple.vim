if exists('did_badapple_vim') || &cp || version < 700
  finish
endif
let did_badapple_vim = 1

command -nargs=? -complete=customlist,BadAppleComplete BadApple
      \ call s:start('<args>')
fun BadAppleComplete(A, L, P)
  return ['version1', 'adjustversion1', 'version1extra', 'clearmemory']
endf

command BadAppleRestoreGUI :call s:restoreGUI()
command BadAppleClearMemory :call s:clearMemory()
command BadAppleAdjust :call s:start('adjustv1')


" variables {{{1
let s:oldguifont=&guifont
let s:oldlines=&lines
let s:oldcolumns=&columns
let s:guifont="monofur for Powerline 4"

let s:DEBUG_ON = 0
function! IsDebugOn()
  return s:DEBUG_ON
endfunction
let s:path_head = expand('<sfile>:p:h:h')
let s:frames = []
let s:initialized = 0
let s:adjust_play=0

let s:width_v1 = 288
let s:height_v1 = 108
let s:nr_of_frames_v1 = 6570

if has('win32')
  let s:path_v1_music = s:path_head . '\version1\badapple.mp3'
  let s:path_config = s:path_head . '\config'
  let s:path_log_v1 = s:path_head . '\v1.log'
else
  let s:path_v1_music = s:path_head . '/version1/badapple.mp3'
  let s:path_config = s:path_head . '/config'
  let s:path_log_v1 = s:path_head . '/v1.log'
endif

" config
let s:config = []
" units: ms
let s:delay_per_frame = 23
call add(s:config, s:delay_per_frame)
let s:play_time = 0

" read s:config and s:delay_per_frame
if findfile(s:path_config) != ''
  let s:config = readfile(s:path_config)
  let s:delay_per_frame = s:config[0]
else
  call writefile(s:config, s:path_config)
endif

" function! s:start() {{{1
function! s:start(mesg)
  if a:mesg ==# 'clearmemory'
    call s:clearMemory()
    return
  endif

  tabnew

  setlocal bufhidden=delete
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nowrap
  setlocal modifiable
  setlocal mousehide
  setlocal noruler
  setlocal nonumber
  setlocal norelativenumber
  setlocal cmdheight=1

  set background=dark
  AirlineToggle

  let &guifont=s:guifont
  if !has('gui_running')
    resize 4999
    vertical resize 4999
  else
    winpos 0 0
  endif
  let &columns=s:width_v1
  let &lines=s:height_v1

  while 1
    if a:mesg == ''
      call s:dispatchPlay('version1')
    else
      call s:dispatchPlay(a:mesg)
    endif
    let &guifont=s:oldguifont
    let ans = input('Thanks for watching! Do you want to replay(y)?')
    if ans !=# 'y'
      break
    endif
    let &guifont=s:guifont
    let &columns=s:width_v1
    let &lines=s:height_v1
  endwhile

  call s:restoreGUI()
  AirlineToggle
  bwipeout

endfunction

" fun s:dispatchPlay(mesg){{{1
fun! s:dispatchPlay(mesg)
  if a:mesg ==# 'version1'
    call s:PLAY_V1()
  elseif a:mesg ==# 'version1extra'
    call s:PLAY_V1_E()
  elseif a:mesg ==# 'adjustversion1'
    call s:adjustV1()
  endif
endf
" function! s:PLAY_V1() (219,140 ms){{{1
" play the bad apple of version 1
" 3 minutes 39 seconds (219,140 ms)
function! s:PLAY_V1()
  
  let s:config = readfile(s:path_config)
  let s:delay_per_frame = s:config[0]

  if s:initialized == 0
    let s:initialized = 1
    call s:initializeV1()
  endif

  if !s:adjust_play
    if IsDebugOn()
      echom "s:twitchDelay() called"
    endif
    call s:twitchDelay(s:play_time)
  endif
  " play
  call s:playMusic()

  let s:time = localtime()
  call s:play()
  let s:play_time = localtime() - s:time


  call s:stopMusic()
endfunction

" function! s:initializeV1() {{{1
function! s:initializeV1()
  " read file into s:frames
  for i in range(1, s:nr_of_frames_v1)
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
  "if columns > s:width_v1
    "let s:x = (&columns - s:width_v1) / 2
  "endif
  "if lines > s:height_v1
    "let s:y = (&lines - s:height_v1) / 2
  "endif
  "call s:transformFrames(s:x, s:y)
  "echom "BadApple: transform to (" .
        "\ string(s:x) . ", " .
        "\ string(s:y) . ") succeed!"
endfunction

" function! s:play() {{{1
" this will play for 217 seconds on my machine
function! s:play()
  for i in range(len(s:frames))
    for ind_row in range(len(s:frames[i]))
      call setline(ind_row+1, s:frames[i][ind_row])
    endfor
    redraw
    execute "sleep " . s:delay_per_frame . "m"
  endfor
endfunction

" fun s:twitchDelay(play_time) {{{1
" this function twitch delay according to delay
fun s:twitchDelay(play_time)
  " calculate the delay
  let delay = s:delay_per_frame
  " we use linear regression to get the answer

  " load and save the log file

  " if path_log_v1 not created
  if findfile(s:path_log_v1) == ''
    return
  endif

  let log = readfile(s:path_log_v1)

  " delay_per_frame as x, play_time as y
  " we build linear regression model

  let x = [] | let y = [] | let l1 = []
  for i in range(0, len(log)-1, 2)
    call add(x, log[i])
    call add(l1, 1)
  endfor
  for i in range(1, len(log), 2)
    call add(y, log[i])
  endfor
  call assert_equal(len(x), len(y))

  " calculate a and b
  let n = len(x)

  let denominator = MulSum(x, x) - n * MulAverage(x, l1) * MulAverage(x, l1)
  if denominator != 0

    let b = (MulSum(x, y) - n * MulAverage(x, l1) * MulAverage(y, l1)) /
          \ denominator
    let a = MulAverage(y, l1) - b * MulAverage(x, l1)
    " calculate delay_per_frame use regression equation y = a + bx
    " as required y is 219.14s
    let delay = float2nr(round((219.14 - a) / b))
  endif

  " save to config
  let s:delay_per_frame = delay
  let s:config[0] = s:delay_per_frame
  call writefile(s:config, s:path_config)
endf

" fun MulSum(x1, x2) {{{1
fun MulSum(x1, x2)
  let res = 0.0
  for i in range(len(a:x1))
    res += a:x1[i] * a:x2[i] * 1.0
  endfor
  return res
endf
" fun MulAverage(x1, x2) {{{1
fun MulAverage(x1, x2)
  let res = 0.0
  for i in range(len(a:x1))
    res += a:x1[i] * a:x2[i] * 1.0
  endfor
  return res / len(a:x1)
endf


" fun s:adjustV1() {{{1
fun s:adjustV1()
  let s:adjust_play = 1
  call s:PLAY_V1()
  if findfile(s:path_log_v1) == ''
    if IsDebugOn()
      echom "file:" . s:path_log_v1 . " not found!"
    endif
    call writefile([], s:path_log_v1)
  endif

  let s:log_v1 = readfile(s:path_log_v1)

  if IsDebugOn()
    echom "BEFORE add to the list"
    for i in range(len(s:log_v1))
      echom s:log_v1[i]
    endfor
  endif

  call add(s:log_v1, s:delay_per_frame)
  call add(s:log_v1, s:play_time)

  if IsDebugOn()
    echom "AFTER add to the list"
    for i in range(len(s:log_v1))
      echom s:log_v1[i]
    endfor
  endif

  call writefile(s:log_v1, s:path_log_v1)
  " reset delay_per_frame to other number
  " that
  let random_number = localtime() % 10
  let random_number = random_number / 2 + 1
  let s:config[0] = s:config[0] + random_number
  let s:delay_per_frame = s:config[0]
  call writefile(s:config, s:path_config)
endf

" function! s:PLAY_V1_E() {{{1
function! s:PLAY_V1_E()

  call input("ready to play")
  for i in range(1, s:nr_of_frames_v1)

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

function! s:restoreGUI()
  let &lines = s:oldlines
  let &columns = s:oldcolumns
  let &guifont = s:oldguifont
  color dracula
endfunction

