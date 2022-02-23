# okblogger.vim

vim-metarwを利用してbloggerを読み書きするプラグイン

**初期開発中で、まだひどいバグがあると思います。ですからブログの内容を壊す可能性が高いので投稿内容のバックアップ等を必ずしてくださいね。**


## Requirements

vimのプラグインとして以下のものを準備

- vim-metarw
- webapi-vim

google apiの制御は、googleの
[Blogger APIs Client Library for Python](https://developers.google.com/blogger/docs/3.0/api-lib/python)
を利用しています。
pythonの環境と以下のpythonモジュールを準備します。

- google-api-python-client

以下は、依存するもの(pipでは一緒にインストールされると思います)

- httplib2
- uritemplate

さらに、OAuth2.0の手続きで必要になる、
IDとsecretが書かれているjson認証ファイルを用意します。
[Blogger API: Using the API](https://developers.google.com/blogger/docs/3.0/using)
これは、Google Cloude Platformから、自分のプロジェクトでblogger apiを利用可能にし、IDとシークレットを得て、更にそれらが書かれてjsonファイルをダウンロードすることが出来ます。



## vimの変数

編集対象となるbloggerのブログIDを設定する（必須）

```vim
" 対象となるbloggerのブログid 
let g:okblogger_blogid = "174466310393865378"
```

blogger api を利用する際の
OAuth2.0でのリクエスト認証のために使う
ID,SECRETが書かれているjsonファイルのパスを設定する。

```vim
" jsonファイルのパス
let g:okblogger_googleapi_secretfile
      \ = "/home/neko/.config/nvim/client_secrets.json"
```


## Usage


### 投稿一覧を得る

```
:e okblogger:list
```

一覧から投稿を選択すると、
その投稿をファイルとして、その内容がバッファーに読み込まれる。
メタパスはブログのポストID。


### 編集内容を保存


```
:w
```

現在バッファの内容をblogger側に反映させる。

