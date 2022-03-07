"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" modify to html with range
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#oktool#tohtml(start, end)

  " from start to end
  let buf_content = join(getline(a:start,a:end),"\n")
  let output = system('pandoc -f markdown -t html', buf_content)

  " form start to end
  " 変更部分を削除する
  execute printf("%d,%ddelete", a:start, a:end)

  call cursor(a:start - 1,0)
  put =output

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" modify to html with all range
" バッファ全体
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#oktool#tohtmlall()
  call okblogger#oktool#tohtml(1, line("$"))
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" modify to html with okdata
" okdata付きのバッファ
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#oktool#okdata_tohtml()
  let content_start = okblogger#okdata#find() + 1
  call okblogger#oktool#tohtml(content_start, line("$"))
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" open web browser
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#oktool#openbrowser()

  if !exists(g:okblogger_browser)
    let g:okblogger_browser = "google-chrome-stable"
  endif

  let blogURL = "https://www.blogger.com/blog/posts/"
            \ . b:okblogger_blogid
  call system(printf("%s %s > /dev/null 2>&1 &", g:okblogger_browser, blogURL))
  echo blogURL
endfunction



