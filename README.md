# okblogger.vim

vim-metarwを利用してbloggerを読み書きするプラグイン

**初期開発中なので、このプラグインを使う前に投稿内容のバックアップ等は必ずしてくださいね。**


## Requirements

### 依存するvimプラグインとokblogger.vimのインストール

okblogger.vimは、次のプラグインに依存しているので、
インストールする時には、一緒にインストールする必要があります。

- vim-metarw
- webapi-vim


例えば、プラグイン管理にVim-Plugを使っているならインストールは、次の様になります。
```{vim}
" add this line to your .vimrc file
Plugin 'syunsuke/okblogger.vim'
Plugin 'kana/vim-metarw'
Plugin 'mattn/webapi-vim'
```

### 依存するpythonモジュール

bloggerのgoogle api制御にgoogleが公開しているpythonライブラリ
「[Blogger APIs Client Library for Python](https://developers.google.com/blogger/docs/3.0/api-lib/python)」
を使っています。

archlinuxの場合、公式リポジトリにある次のパッケージをインストールすればOKです。

- python-google-api-core
- python-google-auth-oauthlib


```{shell}
sudo pacman -S python-google-auth-oauthlib python-google-api-core
```

### google apiのOAuth2.0手続き用のファイル

さらに、OAuth2.0の手続きで必要になる、
IDとsecretが書かれているjson認証ファイルが必要になります。
「[Blogger API: Using the API](https://developers.google.com/blogger/docs/3.0/using)」のページを参考に
Google Cloude Platformから、自分のプロジェクトでblogger apiを利用可能にしてください。
そして、okblogger.vimアプリがアクセスするためのIDとシークレットを得て、
更にそれらが書かれてjsonファイルをダウンロードしましょう。

[https://console.cloud.google.com/](https://console.cloud.google.com/)


## okbloggerを使うための設定

vimrc等に設定すべきことは次のとおりです。


### blogのidを定義

編集対象となるbloggerのブログIDを設定します（必須）
グローバル変数`g:okblogger_blogids`に、
辞書データで定義します。
keyには、ブログの名称（自分で分かりやすいもの）を定義し、
valueは、これに対応するblogのidを文字列で定義します。

```vim
" 対象となるbloggerのブログid 
let g:okblogger_blogids
  \ = {"おしゃれなテストブログ":"174466310393865378",
  \    "おしゃれな例のブログ": "0000000000000000"}
```

### idとsecret入のjsonファイル
blogger google api を利用する際の
OAuth2.0でのリクエスト認証のために使う
ID,SECRETが書かれているjsonファイルのパスを設定します。

```vim
" jsonファイルのパス
let g:okblogger_googleapi_secretfile
      \ = "/home/neko/.config/nvim/client_secret.json"
```


## 使い方


### ブログ一覧を得る

下記のコマンドを実行します。

```
:e okblogger:
```

自分で定義してあるブログの一覧がでます。
一つしかない場合は、一つだけ表示されます。


### 記事一覧を得る

ここで、ブログを選択してエンターを押すと、
そのブログの記事一覧がでます。

さて、okbloggerは、vimのmetarw.vimのプラグインを利用して
ブログIDと投稿IDを用いたpath構造で記事を特定する様になっています。
なので、vimのコマンド的には以下のようにすることで、
指定ブログの記事一覧を表示します。


```
:e okblogger:174466310393865378
```

"174466310393865378"の部分は、「おしゃれなテストブログ」のブログIDです。
一覧から選んでエンターを押すことで、
自動的にこのコマンドを発行してくれます。


### 記事をバッファに読み込む

記事の一覧から、編集したい記事を選択してエンターを押すことで、
選択した記事をバッファに読み込むことが出来ます。

ブログ記事一覧と同様に、投稿記事の読み込みのコマンドは
次のようになっています。

```
:e okblogger:174466310393865378:1665820906097148355
```

"1665820906097148355"の部分は、投稿記事のIDです。
先ほどと同様に一覧から選んでエンターを押すことで、
自動的にこのコマンドを発行してくれます。

基本的にokblogger.vimでは、metarwのフレームワークが予定する通り、
`okblogger:<blogid>:<postid>`とういう構造で、ファイルを表現し、
`okblogger:<blogid>`や`okblogger:`は、ディレクトリを表現しています。


### タイトルと公開、非公開の編集

編集バッファの先頭はtitleとstatusの値が読み込まれます。
statusの部分は、Lが公開(Live)、Dが下書き（Draft）を書き換えることで、
切り替えることが出来ます。

```
---
title:楽しい一日
status:L
---
本文
.....
```

編集したものをblogger側へ反映したい場合、
通常のファイルと同様に:wコマンドを実行します。


```
:w
```


## 使い方のコツ

bloggerは、原稿をhtmlで書くので、
emmet-vim等、vim上のhtmlを書く環境を整えておけば、
bloggerのweb上での編集作業よりも
楽に原稿が書けるようになるのかな？と思って作ってみてます。

okbloggerの機能としては、
単に、bloggerの原稿をvimで開いて編集し、
アップロードするだけの単純なものです。

写真等のアップロードや実際のプレビューは出来ませんが、
それらはもともとblogger側でやったほうが楽ちんなので、
うちでは、vimとブラウザを並べて作業していたりします。

あったほうが便利かなと思って、付け加えているオマケ機能を
以下に紹介しておきます。

### マークダウンをhtmlへ変換

blogger原稿はhtmlで書く必要があります。

そこで、バッファに書いたマークダウンを
定番のpandcでhtmlに変換してくれる関数も用意してみました。
システムにpandocを入れている方は試してみてください。

```
:call okblogger#oktool#okdata_tohtml()
```

### bloggerの管理ページを呼び出す

先に述べたとおり、okbloggerは、
bloggerのページをブラウザで開いて利用したほうが便利です。
そこで、普段遣いのbrowserの起動コマンドを
グローバル変数`g:okblogger_browser`に定義しておきましょう。

```vim
" ブラウザを呼び出すコマンド
let g:okblogger_browser = "google-chrome-stable"
```

これを定義しておけば、
次のコマンドでブラウザがblogger管理ページを開いてくれます。

```
:call okblogger#oktool#openbrowser()
```

### おまけを使うのにvimrcに書いておくことのまとめ

```vim

" ブラウザを呼び出すコマンド
let g:okblogger_browser = "google-chrome-stable"

" ブラウザを呼び出す
nnoremap <silent><leader>bb :call okblogger#oktool#openbrowser()<CR>

" バッファ内のマークダウン書式をhtmlに変換する
nnoremap <silent><leader>bh :call okblogger#oktool#okdata_tohtml()<CR>
```
