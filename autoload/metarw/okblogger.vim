""""""""""""""""""""""""""""""""""""""""""
" id/pass file path for google api
" g:okblogger_googleapi_secretfile
""""""""""""""""""""""""""""""""""""""""""
if !exists('g:okblogger_googleapi_secretfile')
  let g:okblogger_googleapi_secretfile
     \ = printf('%s/client_secrets.json', expand('<sfile>:p:h'))

endif

""""""""""""""""""""""""""""""""""""""""""
" target bologger's ID
" g:okblogger_blogid
" for my test blog
" let g:okblogger_blogid = "174466310393865378"
""""""""""""""""""""""""""""""""""""""""""
if !exists('g:okblogger_blogid')
  echo "you need to set 'g:okblogger_blogid'"
  finish
endif

""""""""""""""""""""""""""""""""""""""""""
" to set python path
" g:okblogger_python_path
""""""""""""""""""""""""""""""""""""""""""
if !exists('s:okblogger_python_path')
  let g:okblogger_python_path = '/usr/bin/python'
endif

let s:okblogger_py_command = printf('%s %s/okblogger.py', 
                                \ g:okblogger_python_path, 
                                \ expand('<sfile>:p:h'))

""""""""""""""""""""""""""""""""""""""""""
" store file for google api token 
""""""""""""""""""""""""""""""""""""""""""
let s:token_file 
  \ = printf('%s/token.pickle', expand('<sfile>:p:h'))

""""""""""""""""""""""""""""""""""""""""""
" complete
"
" not yet
""""""""""""""""""""""""""""""""""""""""""
function! metarw#okblogger#complete(arglead, cmdline, cursorpos)
  " a:arglead always contains "okblogger:".
  let _ = s:parse_incomplete_fakepath(a:arglead)
  return []
endfunction

""""""""""""""""""""""""""""""""""""""""""
" metarw's read function
"
" when :e is call
"  (1) if arg is list, show post list
"  (2) if arg is number as postid, 
"         show contents of the post
""""""""""""""""""""""""""""""""""""""""""
function! metarw#okblogger#read(fakepath)

  let _ = s:parse_incomplete_fakepath(a:fakepath)

  """"""""""""""""""""""""""""""""""""""""""
  " (1) list
  "     投稿の一覧を表示する
  "     pythonのlistを呼ぶ
  """"""""""""""""""""""""""""""""""""""""""
  if _.method == 'list'

    let s:browse = []

    let s:posts_data 
          \ = webapi#json#decode(
                \ system(printf('%s %s %s "list" %s',
                               \ s:okblogger_py_command,
                               \ g:okblogger_googleapi_secretfile,
                               \ s:token_file,
                               \ g:okblogger_blogid)))

    for post in s:posts_data['items']

      let pre_string = ""
      if post.status == "LIVE"
        let pre_string = "(公開) "
        let status_mark = "L:"
      else
        let pre_string = "(下書) "
        let status_mark = "D:"
      endif

      let s:browse 
        \ = add(s:browse, 
            \ {'label'    : pre_string .. post['title'],
            \  'fakepath' : 'okblogger:' .. status_mark .. post['id']})
    endfor

    return ['browse', s:browse]

    
  """"""""""""""""""""""""""""""""""""""""""
  " (2) file
  "     postを一つ読み込み
  "     pythonのshowを呼ぶ
  """"""""""""""""""""""""""""""""""""""""""
  elseif _.method == 'file'

    setfiletype html

    if _.status ==# "L"
      let py_method = '"show"'
    else
      let py_method = '"showdraft"'
    endif

    "put =_.status
    "put =_.postid
    let post_data
          \ = webapi#json#decode(
                \ system(printf('%s %s %s %s %s %s',
                               \ s:okblogger_py_command,
                               \ g:okblogger_googleapi_secretfile,
                               \ s:token_file,
                               \ py_method,
                               \ g:okblogger_blogid,
                               \ _.postid)))

    "let content = post_data['content']
    " TODO
    " データをバッファにどう展開するかを考える
    " タイトルやタグ、公開or書きかけ
    "put =content

    call s:drawpost(post_data, _.status)

    return ['done','' ] 

  """"""""""""""""""""""""""""""""""""""""""
  " (X) ない場合のエラー処理
  """"""""""""""""""""""""""""""""""""""""""
  else
    " TODO: Detail information on error
    return ['error', '???']
  endif


endfunction


""""""""""""""""""""""""""""""""""""""""""
" make post content buffer
""""""""""""""""""""""""""""""""""""""""""
function s:drawpost(post_data, status)

    let propdata = {}
    let content = a:post_data['content']
    let propdata['title'] = a:post_data['title']
    let propdata['status'] = a:status

    let content = join(okdata#set(propdata),"\n") .. "\n" .. content

    put =content

endfunction



""""""""""""""""""""""""""""""""""""""""""
" metarw's write function
" when :w is call
"  (1) if arg is creat, make a new post
"  (2) if arg is number as postid, 
"         update contents of the post
""""""""""""""""""""""""""""""""""""""""""
function! metarw#okblogger#write(fakepath, line1, line2, append_p)

  let _ = s:parse_incomplete_fakepath(a:fakepath)

  if _.method == 'creat'
    echo 'create'

  elseif _.method == 'file'

    let s:buffer_contents
      \ = join(getline(okdata#find() + 1, line("$")),"\n")

    let s:shell_escaped_contents 
      \ = substitute(s:buffer_contents, '"', '\\"', "g")

    if _.status ==# "L"
      let py_method = 'update'
      let status = "L"
    else
      let py_method = '"updatedraft"'
      let status = "D"
    endif

    let prop = okdata#get()
    let title = substitute(prop.title, '"', '\\"', "g")

    if prop.status ==# "L"
      let status = "L"
    elseif prop.status ==# "D"
      let status = "D"
    endif

    let s:post_res
      \ = system(printf('%s %s %s %s %s %s "%s" "%s"',
                               \ s:okblogger_py_command,
                               \ g:okblogger_googleapi_secretfile,
                               \ s:token_file,
                               \ py_method,
                               \ g:okblogger_blogid,
                               \ _.postid,
                               \ title,
                               \ status),s:buffer_contents)

    echo s:post_res

  else
    " TODO: Detail information on error
    return ['error', '???']
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""
" function of dealing with fakepath
" Return value '_' has the following items:
"
" 引数は、:e okblogger:list のokblogger:list部分
" これがincomplete_fakepathに渡されてくる
" :e でも :w でもこのルーチンで解析
"
" Key                 Value
" ------------------  -----------------------------------------
" given_fakepath      same as a:incomplete_fakepath
" scheme              {scheme} part in a:incomplete_fakepath (always 'okblogger')
" postid              'okblogger:{postid}' or nil
" method              'create', 'list' or 'file'
""""""""""""""""""""""""""""""""""""""""""
function! s:parse_incomplete_fakepath(incomplete_fakepath)
  let _ = {}

  let fragments = split(a:incomplete_fakepath, ':', !0)

  if  len(fragments) <= 1
    echoerr 'Unexpected a:incomplete_fakepath:' string(a:incomplete_fakepath)
    throw 'metarw:okblogger#e1'
  endif

  let _.given_fakepath = a:incomplete_fakepath
  let _.scheme = fragments[0]

  if len(fragments) < 2
    " error
    " fragment[1]が、
    "   createなら、新規作成メソッドcreate
    "   listなら、post一覧メソッドlist
    "   それ以外なら、個別postの読み込みとしてメソッドfile
    "   postidをつける


  elseif fragments[1] == 'create'
    let _.method = 'create'
  
  elseif fragments[1] == 'list'
    let _.method = 'list'
  
  else
    let _.method = 'file'
    let _.status = fragments[1]
    let _.postid = fragments[2]
  endif

  return _
endfunction
