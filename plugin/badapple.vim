
command BadApple :call s:Start()

function! s:Start()

  tabnew

  setlocal bufhidden=delete
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nowrap
  setlocal modifiable

  set guifont=monofur\ for\ Powerline\ 7

  while 1
    call s:Play()
    ans = input('Thanks for watching! Do you want to replay(y)?')
    if ans !=# 'y'
      break
    endif
  endwhile

  bwipeout

endfunction


" play the bad apple
function! s:Play()

  let path_head = expand('%:p:h:h')

  " read file into frames
  let frames = []
  for i in range(1, 6571)

    if has('win32')
      let path = path_head . '\txt\_' . string(i) . '.txt'
    else
      let path = path_head . '/txt/_' . string(i) . '.txt'
    endif

    let frame = readfile(path)
    call add(frames, frame)

  endfor

  " print
  for i in range(6570)
    for ind_row in len(frames[i])
      call setline(ind_row+1, frames[i][ind_row])
    endfor

    redraw
    sleep 70m
  endfor

endfunction
