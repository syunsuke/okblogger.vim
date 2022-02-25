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



## okbloggerを使うための設定

vimrc等に設定すべきことは次のとおりです。

編集対象となるbloggerのブログIDを設定します（必須）

```vim
" 対象となるbloggerのブログid 
let g:okblogger_blogid = "174466310393865378"
```

blogger api を利用する際の
OAuth2.0でのリクエスト認証のために使う
ID,SECRETが書かれているjsonファイルのパスを設定します。

```vim
" jsonファイルのパス
let g:okblogger_googleapi_secretfile
      \ = "/home/neko/.config/nvim/client_secrets.json"
```

bloggerのページをブラウザーで呼び出すために、
ブラウザのコマンドを定義しておきます。

```vim
" ブラウザを呼び出すコマンド
let g:okbrowser = "google-chrome-stable"
```


```vim
" ブラウザを呼び出す
nnoremap <silent><leader>bb :call okbloggertool#openbrowser()<CR>

" バッファ内のマークダウン書式をhtmlに変換する
" (要pandoc)
nnoremap <silent><leader>bh :call okbloggertool#okdata_tohtml()<CR>
```

## Usage


### 投稿一覧を得る

```
:e okblogger:list
```

一覧から投稿を選択すると、
その投稿をファイルとして、その内容がバッファーに読み込まれます。
メタパスはブログのポストID。

### タイトルと公開、非公開の編集

編集バッファの先頭はtitleとstatusの値が読み込まれます。
statusの部分は、Lが公開(Live)、Dが下書き（Draft）を書き換えることで、
切り替えることが出来ます。

```
---
status:L
title:楽しい一日
---
本文
.....
```


### マークダウンでをhtmlへ変換

blogger原稿はhtmlで表現されています。
ラフにマークダウンで書いて、
適当にhtmlに変換してから調整できるように、
pandocを呼び出すokbloggertool#okdata_tohtml()関数も入れてあります。
バッファを書き換えるので注意してください。

なお、システムにpandocをインストールしてないと使えません。


### 編集内容を保存


```
:w
```

現在バッファの内容をblogger側に反映させることができます。

### コツ

bloggerは、原稿をhtmlで書くので、
vim上で、htmlを書く環境を整えておけば、
bloggerのweb上での編集作業よりも
楽に原稿が書けるようになるのかな？と思っています。
例えば、文字の色つけとか、センタリングとかの簡単なデザイン付が
楽になるかもしれないと予想しています。

okbloggerの機能としては、
単に、bloggerの原稿をvimで開いて編集し、アップロードできるだけです。
写真等のアップロードや実際のプレビューは、
blogger側でやったほうが楽ちんです。

ですから、vimとブラウザを並べて作業するのがよいかなぁ？と思っています。
