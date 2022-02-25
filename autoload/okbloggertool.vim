"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" modify to html with range
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okbloggertool#tohtml(start, end)

  " form start to end
  let buf_content = join(getline(a:start,a:end),"\n")
  let output = system('pandoc -f markdown -t html', buf_content)

  " form start to end
  " 変更部分を削除する
  execute printf("%d,%ddelete", a:start, a:end)

  " putは指定の次の行にはいるので
  " start -1で一つ前にする
  call cursor(a:start-1,0)
  put =output

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" modify to html with all range
" バッファ全体
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okbloggertool#tohtmlall()
  call okbloggertool#tohtml(1, line("$"))
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" modify to html with okdata
" okdata付きのバッファ
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okbloggertool#okdata_tohtml()
  let content_start = okdata#find() + 1
  call okbloggertool#tohtml(content_start, line("$"))
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" open web browser
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okbloggertool#openbrowser()
  if !exists(g:okbrowser)
    let g:okbrowser = "google-chrome-stable"
  endif
  let blogURL = "https://www.blogger.com/blog/posts/"
            \ .. g:okblogger_blogid
  call system(printf("%s %s > /dev/null 2>&1 &", g:okbrowser, blogURL))
endfunction



