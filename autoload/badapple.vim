
" func s:LoadConfig() !!!NEVER BE CALLED SINCE YOU HAVE SEE THIS{{{1
" ':' is not allowed in the config file
" value should be number or string(better not to mix them)
func s:LoadConfig()
  if findfile(s:path_config) != ''
    let s:config_list = readfile(s:path_config)
    for i in range(len(s:config_list))
      let temp = split(s:config_list[i], ':')
      if match(temp[1], '^\<[-0-9]\{1,}\>$') == 0
        let s:config[temp[0]] = str2nr(temp[1])
      else
        let s:config[temp[0]] = temp[1]
      endif
    endfor
  else
    if IsDebugOn()
      echom "DEBUG(BadApple) call into s:writeconfig()"
    endif
    call s:writeconfig()
  endif
endfunc

" fun s:WriteConfig(key, value) {{{1
fun s:WriteConfig(key, value)
  call s:LoadConfig()
  let s:config[a:key] = a:value
  call s:writeconfig()
endf
fun s:writeconfig()
  let temp = []
  let keys_ = keys(s:config)
  let values_ = values(s:config)
  for i in range(len(keys_))
    if match(values_[i], '^<[-0-9]\{1,}\>$') == 0
      call add(temp, keys_[i] . ':' . string(values_[i]))
    else
      call add(temp, keys_[i] . ':' . values_[i])
    endif
  endfor
  if IsDebugOn()
    echom 'DEBUG(BadApple) variable: s:writeconfig()::temp'
    echom "'" . string(temp) . "'"
  endif
  call writefile(temp, s:path_config)
endf
" }}}

" fun s:Log(list, file) {{{1
fun s:Log(list, file)
  let list = a:list

  if a:file == s:path_log_v1
    if len(list) == 2
      let list[0] = 'delay(x): ' . string(list[0])
            \ . ' | ' . 'playtime(y): ' . string(list[1])
            \ . ' | ' . strftime("20%y.%m.%d %R")
      unlet list[1]
    elseif len(list) == 3
      let list[0] = 'delay(x): ' . string(list[0])
            \ . ' | ' . 'playtime(y): ' . string(list[1])
            \ . ' | ' . 'distribution of x: ' . list[2]
            \ . ' | ' . strftime("20%y.%m.%d %R")
      unlet list[1]
      unlet list[1]
    endif
  endif

  call writefile(list, a:file, "a")
endf

" fun s:ReadLog(path) {{{1
fun s:ReadLog(path)
  let ret = []
  let list = readfile(a:path)

  if a:path == s:path_log_v1
    for i in range(len(list))
      let l = split(list[i], '|')
      let n1 = str2nr(matchstr(l[0], '\<\d*\>'))
      let n2 = str2nr(matchstr(l[1], '\<\d*\>'))
      call add(ret, n1)
      call add(ret, n2)
    endfor
  endif

  if IsDebugOn()
    echom "ReadLog()::ret:"
    echom "'".string(ret)."'"
  endif

  return ret
endf

" }}}

" variables {{{1
let s:oldguifont=&guifont
let s:oldlines=&lines
let s:oldcolumns=&columns
let s:guifont="monofur for Powerline 4"
let s:airlinetoggleon=0

let s:DEBUG_ON = 1
function! IsDebugOn()
  return s:DEBUG_ON
endfunction

let s:frames = []
let s:initialized = 0
let s:no_interaction = 0
let s:adjust_play=0

let s:width_v1 = 288
let s:height_v1 = 108
let s:nr_of_frames_v1 = 6570

let s:path_head = expand('<sfile>:p:h:h')
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
let s:config = {}
" units: ms
let s:config.delay_per_frame = 23
let s:config.delay_per_frame_for_adjust = 23
" The configure option show above are the default values.
" They will be modified by config file.
" Or if there is not a config file, it(LoadConfig) will just create

let s:play_time = 0
" }}}

" fun badapple#decorate_start(mesg, count) {{{1
fun badapple#decorate_start(mesg, count)
  if a:count > 1
    let s:no_interaction = 1
  elseif a:count == 1
    let s:no_interaction = 0
  else
    echom "BadApple(error) count can't be less than 1"
    return
  endif
  for i in range(a:count)
    call s:start(a:mesg)
  endfor
  
endf

" function! s:start() {{{1
function! s:start(mesg)
  if a:mesg ==# 'clearmemory'
    call s:clearMemory(0)
    return
  endif
  if a:mesg == 'restoregui'
    call s:restoreGUI()
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
  let s:oldguifont=&guifont
  let s:oldlines=&lines
  let s:oldcolumns=&columns

  set background=dark
  if exists(':AirlineToggle')
  AirlineToggle
  let s:airlinetoggleon=0
  endif

  let &guifont=s:guifont
  if !has('gui_running')
    if exists("+lines") && exists("+columns")
      let &columns=s:width_v1
      let &lines=s:height_v1
    endif
    execute "resize " . s:width_v1
    execute "vertical resize " . s:height_v1
  else
    "winpos 0 0
    let &columns=s:width_v1
    let &lines=s:height_v1
  endif

  while 1
    if a:mesg == ''
      call s:dispatchPlay('version1')
    else
      call s:dispatchPlay(a:mesg)
    endif
    let &guifont=s:oldguifont

    if s:no_interaction == 0
      let ans = s:InteractiveInterface()
      if ans !=# 'y'
        break
      endif
    endif

    let &guifont=s:guifont
    let &columns=s:width_v1
    let &lines=s:height_v1

    if s:no_interaction == 1
      break
    endif

  endwhile

  call s:restoreGUI()
  if exists(':AirlineToggle')
    AirlineToggle
    let s:airlinetoggleon = 1
    AirlineRefresh
  endif
  bwipeout

endfunction

" fun s:dispatchPlay(mesg){{{1
fun! s:dispatchPlay(mesg)
  call s:LoadConfig()

  if a:mesg ==# 'version1'
    call s:PLAY_V1()
  elseif a:mesg ==# 'version1extra'
    call s:PLAY_V1_E()
  elseif a:mesg ==# 'adjustversion1'
    call s:adjustV1()
  endif

  call s:clearMemory(1)
endf
" }}}

" function! s:PLAY_V1() (219,140 ms){{{1
" play the bad apple of version 1
" 3 minutes 39 seconds (219,140 ms)
function! s:PLAY_V1()
  if s:initialized == 0
    let s:initialized = 1
    call s:initializeV1()
  endif

  call s:twitchDelay()
  if s:adjust_play
    let s:config.delay_per_frame = s:config.delay_per_frame_for_adjust
  endif

  " play
  call s:playMusic()

  let time = localtime()
  call s:play()
  let s:play_time = localtime() - time

  call s:stopMusic()

  if !s:adjust_play
    call s:Log([s:config.delay_per_frame, s:play_time], s:path_log_v1)
  endif
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
    execute "sleep " . s:config["delay_per_frame"] . "m"
  endfor
endfunction

" fun s:twitchDelay(play_time) {{{1
" this function twitch delay according to delay
fun s:twitchDelay()
  " calculate the delay
  let delay = s:config.delay_per_frame
  " we use linear regression to get the answer

  " if path_log_v1 not created
  if findfile(s:path_log_v1) == ''
    return
  endif

  let log = s:ReadLog(s:path_log_v1)

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
  if IsDebugOn()
    echom 'twitchDelay::denominator' . string(denominator)
  endif
  if denominator > 0

    let b = (MulSum(x, y) - n * MulAverage(x, l1) * MulAverage(y, l1)) /
          \ denominator
    let a = MulAverage(y, l1) - b * MulAverage(x, l1)
    " calculate delay_per_frame use regression equation y = a + bx
    " as required y is 219.14s
    let delay = float2nr(round((219.14 - a) / b))
    if IsDebugOn()
      echom 'twitchDelay::delay:' . string(delay)
    endif
  endif

  " save to config
  call s:WriteConfig("delay_per_frame", delay)
endf

" fun MulSum(x1, x2) {{{1
fun MulSum(x1, x2)
  let res = 0.0
  for i in range(len(a:x1))
    let res += a:x1[i] * a:x2[i] * 1.0
  endfor
  return res
endf
" fun MulAverage(x1, x2) {{{1
fun MulAverage(x1, x2)
  let res = 0.0
  for i in range(len(a:x1))
    let res += a:x1[i] * a:x2[i] * 1.0
  endfor
  return res / len(a:x1)
endf


" fun s:adjustV1() {{{1
fun s:adjustV1()
  let s:adjust_play=1
  call s:PLAY_V1()
  let s:adjust_play=0

  call s:Log([s:config.delay_per_frame, s:play_time, 'Gaussian dist'], s:path_log_v1)
  " set config.delay_per_frame_for_adjust
  " the delay(x) follow a Gaussian distribution
  let random_number = localtime() % 10
  let random_number = random_number - 5

  let value = s:config.delay_per_frame_for_adjust + random_number
  if value < 0
    let value = 0
  elseif value > 50
    let value = 50
  endif

  call s:WriteConfig("delay_per_frame_for_adjust", value)
endf

" }}}

" function! s:PLAY_V1_E() {{{1
function! s:PLAY_V1_E()

  let &lines = s:oldlines
  let &columns = s:oldcolumns
  let &guifont = s:oldguifont
  let ans = input('Have closed other file in the vim?(y for yes)')
  let &guifont=s:guifont
  let &columns=s:width_v1
  let &lines=s:height_v1

  if ans != 'y'
    return
  endif
  call s:playMusic()
  for i in range(1, s:nr_of_frames_v1)

    if has('win32')
      let path = s:path_head . '\version1\_' . string(i) . '.txt'
    else
      let path = s:path_head . '/version1/_' . string(i) . '.txt'
    endif

    execute "read " . path

    setlocal nowrap
    setlocal buftype=nofile
    setlocal mousehide
    setlocal noswapfile
    setlocal noruler
    setlocal nonumber
    setlocal norelativenumber

    redraw
    sleep 21m
    bwipeout
  endfor
  call s:stopMusic()

endfunction
" }}}

" function! s:playMusic() {{{1
function! s:playMusic()
  if !has('python3')
    return
  endif
  
python3 << EOF
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
  if !has('python3')
    return
  endif
  python3 pygame.mixer.music.stop()
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
function! s:clearMemory(mute)
  for i in range(len(s:frames))
    unlet s:frames[0]
  endfor
  let s:initialized=0
  if !a:mute
    echom "BadApple clear memory succeed!"
  endif
endfunction

" function! s:restoreGUI() {{{1

function! s:restoreGUI()
  let &lines = s:oldlines
  let &columns = s:oldcolumns
  let &guifont = s:oldguifont
  if exists(':AirlineToggle')
    if !s:airlinetoggleon
      AirlineToggle
      AirlineRefresh
    endif
  endif
  color dracula
endfunction

" fun s:InteractiveInterface() {{{1
fun s:InteractiveInterface()
  let ret = input('Thanks for watching! Do you want to replay(y for yes)?')
  return ret
endf

