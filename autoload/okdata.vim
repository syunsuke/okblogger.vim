
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" get
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okdata#get()
  let l:res = {}
  let l:data_end = okdata#find()

  if l:data_end == 0
    return l:res
  endif

  let l:data_list = getline(2,l:data_end - 1)
  for l:prop in l:data_list
    let l:tmp = split(l:prop, ':', 1)
    let l:res[trim(l:tmp[0])] = trim(l:tmp[1])
  endfor

  return l:res

endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" set
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okdata#set(data)
  let l:res_list = ["---"]

  for l:k in keys(a:data)
    let l:res_list = add(l:res_list, printf("%s:%s", l:k, a:data[l:k]))
  endfor

  let l:res_list = add(l:res_list, "---")

  return l:res_list

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" delete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okdata#delete()

  let l:data_end = okdata#find()

  if l:data_end == 0
    "何もしない
    return 0
  endif

  execute printf("1,%ddelete", l:data_end)

endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" find
"""""""""""""""""""""""""""""""""""""""""""""""""""""""'
function! okdata#find()

  let l:first_line = getline(1)
  if l:first_line !=# "---"
    return 0
  endif

  call cursor(2,1)
  let l:end_line = search('^---$',"eW")

  return l:end_line

endfunction

