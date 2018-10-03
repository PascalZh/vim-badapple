if exists('did_badapple_vim') || &cp || version < 700
  finish
endif
let did_badapple_vim = 1

command! -nargs=?
      \ -complete=customlist,BadAppleComplete
      \ -count=1
      \ BadApple
      \ call badapple#decorate_start('<args>', <count>)

fun BadAppleComplete(A, L, P)
  " candidate:
  " adjustversion1
  " clearmemory
  " restoregui
  " version1
  " version1extra
  if len(a:A) == 0
    return ['adjustversion1', 'clearmemory', 'restoregui'
          \ , 'version1', 'version1extra']
  endif

  if match('adjustversion1',  '^' . a:A) == 0
    return ['adjustversion1']

  elseif match('clearmemory', '^' . a:A) == 0
    return ['clearmemory']

  elseif match('restoregui', '^' . a:A) == 0
    return ['restoregui']

  elseif match('version1', '^' . a:A) == 0
    return ['version1', 'version1extra']
  elseif match('version1extra', '^' . a:A) == 0
    return ['version1extra']

  endif
endf
