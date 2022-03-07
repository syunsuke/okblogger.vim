"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" find
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#okdata#find()

  let first_line = getline(1)
  if first_line !=# "---"
    return 0
  endif

  call cursor(2,1)
  let end_line = search('^---$',"eW")

  return end_line

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" get
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#okdata#get()

  let res = {}
  let data_end = okblogger#okdata#find()

  if data_end == 0
    return res
  endif

  let data_list = getline(2, data_end - 1)
  for prop in data_list
    let tmp = split(prop, ':', !0)
    let res[trim(tmp[0])] = trim(tmp[1])
  endfor

  if res['status'] ==# "L"
    let res['status'] = "LIVE"
  else
    let res['status'] = "DRAFT"
  endif

  return res

endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" set
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#okdata#set(data)

  let res_list = 
        \["---",
        \ printf("title:%s",a:data['title']),
        \ printf("status:%s", a:data['status'] == "LIVE" ? "L" : "D"),
        \ "---"]

  return res_list

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" delete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okblogger#okdata#delete()

  let data_end = okblogger#okdata#find()

  if data_end == 0
    "何もしない
    return 0
  endif

  execute printf("1,%ddelete", data_end)

endfunction

