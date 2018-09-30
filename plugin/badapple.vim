
command BadApple :call s:Start()

let s:path_head = expand('<sfile>:p:h:h')
let s:frames = []

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


  "timer = timer_start(500, 's:Play_V1',
        "\ {'repeat', 1})
  "map q call timer_stop(timer)
  while 1
    call s:Play_V1()
    let ans = input('Thanks for watching! Do you want to replay(y)?')
    if ans !=# 'y'
      break
    endif
  endwhile

  let &guifont=s:oldguifont
  bwipeout

endfunction


" play the bad apple of version 1
" 3 minutes 39 seconds (219,140 ms)
function! s:Play_V1()

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

  " play
  call s:Play_V1_Music()
endfunction

" this will play for 217 seconds on my machine
function! s:RefreshTxt_V1()
  let s:t = localtime()
  for i in range(len(s:frames))
    for ind_row in range(len(s:frames[i]))
      call setline(ind_row+1, s:frames[i][ind_row])
    endfor

    redraw
    " it is the most suitable value
    sleep 18m
  endfor
  let timespan = localtime() - s:t
  echom "play time: " . string(timespan) . "s"

endfunction


function! s:Play_V1_Music()
pythonx << EOF

# import vim, pygame, time, threading
import vim, pygame
path = vim.eval('s:path_v1_music')

# flag = True


pygame.mixer.init()
track = pygame.mixer.music.load(path)
pygame.mixer.music.play()
vim.command("call s:RefreshTxt_V1()")
pygame.mixer.music.stop()



# def callback1(path):
    # pygame.mixer.init()
    # track = pygame.mixer.music.load(path)
    # pygame.mixer.music.play()
    # #for i in range(219):
    # #    if vim.eval('g:thread1stop') == 1:
    # #        break
    # #    time.sleep(1)
    # #pygame.mixer.music.stop()


# def callback2():
    # vim.command("call s:RefreshTxt_V1()")


# thread2 = threading.Thread(target=callback2, name='RefreshTxtThread(2)')# , daemon=True)
# thread2.start()
# thread1 = threading.Thread(target=callback1, name='MusicThread(1)', args=(path, ))# , daemon=True)
# thread1.start()

# vim.command("let s:y = input('quit?(y)')")
# if vim.eval("s:y") == 'y':
    # pygame.mixer.music.stop()
    # flag = False
    # vim.command("let g:thread2stop = 1")

# thread1.join()
# thread2.join()
# if not flag:
    # pygame.mixer.music.stop()

EOF
endfunction
