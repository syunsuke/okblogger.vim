"/////////////////////////////////////////////////
"
" 変数関係
"
"/////////////////////////////////////////////////
"
""""""""""""""""""""""""""""""""""""""""""
" google api id/secret file path
""""""""""""""""""""""""""""""""""""""""""
if !exists('g:okblogger_googleapi_secretfile')
  let g:okblogger_googleapi_secretfile
     \ = printf('%s/client_secrets.json', expand('<sfile>:p:h'))
endif


""""""""""""""""""""""""""""""""""""""""""
" target bologger's ID
""""""""""""""""""""""""""""""""""""""""""
"let g:okblogger_blogids =
"      \ {"test01":"174466310393865378"}

if !exists('g:okblogger_blogids')
  echo "you need to set 'g:okblogger_blogids'"
  finish
endif


""""""""""""""""""""""""""""""""""""""""""
" python path
""""""""""""""""""""""""""""""""""""""""""
if !exists('g:okblogger_python_path')
  let g:okblogger_python_path = '/usr/bin/python'
endif
let s:okblogger_py_command = printf('%s %s/okblogger.py',
                                \ g:okblogger_python_path,
                                \ expand('<sfile>:p:h'))

""""""""""""""""""""""""""""""""""""""""""
" okblogger.vim path
""""""""""""""""""""""""""""""""""""""""""
let s:basepath = expand('<sfile>:p:h')

"/////////////////////////////////////////////////
"
" metarw main function
"
"/////////////////////////////////////////////////

""""""""""""""""""""""""""""""""""""""""""
" complete (not yet)
""""""""""""""""""""""""""""""""""""""""""
function! metarw#okblogger#complete(arglead, cmdline, cursorpos)
  " a:arglead always contains "okblogger:".
  let _ = s:parse_incomplete_fakepath(a:arglead)
  return []
endfunction


""""""""""""""""""""""""""""""""""""""""""
" read
""""""""""""""""""""""""""""""""""""""""""
function! metarw#okblogger#read(fakepath)

  let fakepath_obj = s:parse_incomplete_fakepath(a:fakepath)

  " blogのリスト
  if fakepath_obj.method == 'list_blogger'
    return s:bloggerlist()

  " 投稿のリスト
  elseif fakepath_obj.method == 'list_post'
    return s:postlist(fakepath_obj.blogid)

  " 投稿の読み込み
  elseif fakepath_obj.method == 'file'
    call s:loadpost(fakepath_obj.blogid, fakepath_obj.postid)
    return ['done', '']

  else
    return ['error', 'unknown method']
  endif

endfunction


""""""""""""""""""""""""""""""""""""""""""
" write
""""""""""""""""""""""""""""""""""""""""""
function! metarw#okblogger#write(fakepath, line1, line2, append_p)

  let fakepath_obj = s:parse_incomplete_fakepath(a:fakepath)

  if fakepath_obj.method == 'file'
    call s:updatepost(fakepath_obj.blogid, fakepath_obj.postid)
    return ['done', '']

  else
    return ['error', 'invalid method']
  endif

endfunction



"/////////////////////////////////////////////////
"
" metarw sub utils
"
"/////////////////////////////////////////////////

"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" update_post
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:updatepost(blogid, postid)

  let prop = okblogger#okdata#get()
  let title = substitute(prop.title, '"', '\\"', "g")
  let status = prop.status

  let buffer_contents
        \ = join(getline(okblogger#okdata#find() + 1, line("$")),"\n")

  let content_data = { "title": title,
        \ "status": status,
        \ "content": buffer_contents}

  call s:update_post_data( a:blogid,
        \ a:postid,
        \ content_data)
endfunction


"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" make blog list
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:bloggerlist()

    let anslist = []

    for k in keys(g:okblogger_blogids)
      let anslist
        \ = add(anslist,
            \ {'label'    : k,
            \  'fakepath' : 'okblogger:' . g:okblogger_blogids[k]})
    endfor

  return ['browse', anslist]

endfunction


"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" make post list
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:postlist(blogid)

  let anslist = []
  let posts_data = s:get_blog_data(a:blogid)

  for post in posts_data['items']

    let pre_string = ""
    if post.status == "LIVE"
      let pre_string = "[L] "
    else
      let pre_string = "[D] "
    endif

    let anslist
          \ = add(anslist,
          \ {'label'    : pre_string . post['title'],
          \  'fakepath' : 'okblogger:' . a:blogid . ":" . post['id']})
  endfor

  return ['browse', anslist]

endfunction


"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" load post to buffer
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:loadpost(blogid, postid)
  let post_data = s:get_post_data(a:blogid, a:postid)

  let b:okblogger_blogid = a:blogid

  let propdata = {}
  let content = post_data['content']
  let propdata['title'] = post_data['title']
  let propdata['status'] = post_data['status']

  let content = join(okblogger#okdata#set(propdata),"\n") . "\n" . content

  execute printf("%d,%ddelete", 1, line("$"))
  put =content

endfunction



"/////////////////////////////////////////////////
"
" misc subroutine
"
"/////////////////////////////////////////////////



"/////////////////////////////////////////////////
"
" parse metarw path
"
" pattern
" scheme:bloggerId:postId
"
" return object is like below
"
" Key                 Value
" ------------------  -----------------------------------------
" given_fakepath      same as a:incomplete_fakepath
" scheme              {scheme} okblogger
" method              'list_blogger' 'list_post' 'file'
" blogid
" postid
"
"/////////////////////////////////////////////////

function! s:parse_incomplete_fakepath(incomplete_fakepath)

  let _ = {}
  let fragments = split(a:incomplete_fakepath, ':', 0)

  let _.given_fakepath = a:incomplete_fakepath
  let _.scheme = fragments[0]

  if len (fragments) == 1
    let _.method = 'list_blogger'

  elseif len (fragments) == 2
    let _.method = 'list_post'
    let _.blogid = fragments[1]

  else
    let _.method = 'file'
    let _.blogid = fragments[1]
    let _.postid = fragments[2]

  endif

  return _
endfunction



"/////////////////////////////////////////////////
"
" IO function
" pythonライブラリを使用
"
"/////////////////////////////////////////////////

"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" get blog data
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:get_blog_data(blogid)

  let cmd = printf('%s %s %s "list" %s',
                  \ s:okblogger_py_command,
                  \ g:okblogger_googleapi_secretfile,
                  \ s:tokenpath(a:blogid),
                  \ a:blogid)

  return webapi#json#decode(system(cmd))

endfunction


"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" get post data
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:get_post_data(blogid, postid)

  let cmd = printf('%s %s %s "show" %s %s',
                  \ s:okblogger_py_command,
                  \ g:okblogger_googleapi_secretfile,
                  \ s:tokenpath(a:blogid),
                  \ a:blogid,
                  \ a:postid)

  return webapi#json#decode(system(cmd))

endfunction


"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" update post
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:update_post_data(blogid, postid, dataobj)

  let cmd =
        \ printf('%s %s %s "update" %s %s "%s" "%s"',
                  \ s:okblogger_py_command,
                  \ g:okblogger_googleapi_secretfile,
                  \ s:tokenpath(a:blogid),
                  \ a:blogid,
                  \ a:postid,
                  \ a:dataobj['title'],
                  \ a:dataobj['status'])

  let post_res = system(cmd, a:dataobj['content'])
  echo post_res

endfunction



"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
" token file utility
"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function! s:tokenpath(blogid)
  let token_file_path
    \ = printf('%s/token%s.pickle', s:basepath, a:blogid)
  return token_file_path
endfunction


