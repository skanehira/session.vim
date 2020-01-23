# テーマ
Vim scriptを使って簡易なプラグインを作ってみよう

## 前提知識
- ターミナルの操作方法

## 必要環境
- 以下のバージョンのVimかNeovimを用意

| エディタ | バージョン  |
|----------|-------------|
| Vim      | v8.1.1120 ~ |
| Neovim   | v0.4.0 ~    |

## 全体の流れ
- Vim scriptの基礎
- セッション管理のプラグインを作ってみよう

## Vim scriptの基礎
- Vim scriptはVim上で実行できるスクリプト言語
- Exコマンド(`:`で始まるコマンド)の集合体
- vimrcに記述しているのもVim script
- Vimのプラグインの多くはVim scriptで書かれている

### Vim scriptの実行
以下の手順通りに実施してみてください。コマンドラインに`gorilla`が表示されれば成功です。

1. `sample.vim`を作成

    ```bash
    $ mkdir sample
    $ cd sample
    $ vim sample.vim
    ```

2. Vimで以下のコードを記述して保存

    ```vim
    echo 'gorilla'
    ```

3. `:source`でVim scriptを実行

    ```vim
    :source sample.vim
    ```

### コメント
Vim scriptでは`"`がコメント行として解釈され処理をスキップします。

```vim
" この行は処理されない
" echo 'gorilla'
```

### データ型
主に以下のデータを使用できます。

| データ型 | 例                       |
|----------|--------------------------|
| 数値     | `5`                      |
| 小数     | `5.5`                    |
| 文字列   | `'gorilla'`、`"gorilla"` |
| リスト   | `[1, 2, 3]`              |
| 辞書     | `{'name': 'gorilla'}`    |

### 文字列
`"`や`'`で囲ったものは文字列になります。
`"`はタブを表す`\t`といった特殊な文字をタブとして出力しますが、`'`は囲った文字列をそのまま出力するといった違いがあります。

`sample.vim`の先程まで記述したコードを削除して、以下のコードを記述して実行してみてください。

```vim
echo 'hello\tgorilla'
echo "hello\tgorilla"
```

結果は以下になります。
```
hello\tgorilla
hello	gorilla
```

### 変数
- `let`を使っての宣言と値を代入する
- 宣言済みの変数でも値を代入するときは`let`を使用しなければいけない

```vim
let name = 'gorilla'
" letがないのでエラーになる
name = 'cat'
```
### 変数名
- アルファベット、数字、アンダースコアを使用できる
- 数字で始まることはできない

```vim
" OK
let _a1 = 1
echo _a1

" NG
let 1a = 1
let a-b = 1
```

### スコープ
- 変数や後述する関数にはスコープがある
- 接頭子によってスコープが変わる
- 関数内で`l:`を省略した場合は暗黙的に関数ローカル変数にアクセスする

| 接頭子 | スコープ                                             |
|--------|------------------------------------------------------|
| `g:`   | グローバルスコープ、どこからも利用可能               |
| `s:`   | スクリプトスコープ、スクリプトファイル内のみ使用可能 |
| `l:`   | 関数ローカルスコープ、関数内のみ使用可能             |
| `a:`   | 関数の引数、関数内のみ使用可能                       |
| `v:`   | グローバルスコープ、Vimが予め定義している変数        |

### 辞書
- `{}`で囲う
- 1つ要素は`{key}: {value}`からなる
- `{key}`は文字列でなければいけない
- 要素は`,`で区切られる

```vim
let animal = {'name': 'gorilla', 'age': 27}
" 結果 => {'age': '27', 'name': 'gorilla'}
echo animal
```

### 辞書の要素取得
- `{dict}.{key}`
- `{dict}[{key}]`
- `get({dict}, {key}, {default})`

```vim
let animal = {'name': 'gorilla', 'age': 27}
" 結果 => gorilla
echo animal.name
" 結果 =>  27
echo animal['age']
" 結果 =>  banana
echo get(animal, 'name', 'banana')
```

### 辞書の要素追加
- `{dict}.{key} = {expr}`
- `{dict}[{key}] = {expr}`

```vim
let animal = {}
let animal.name = 'gorilla'
let animal['age'] = 27

" 結果 => {'age': 27, 'name': 'gorilla'}
echo animal
```

### 辞書の要素削除
- remove({dict}, {key})

```vim
call remove(animal, 'age')
" 結果 => {'name': 'gorilla'}
echo animal
```

### リスト
- `[]`の中にカンマで区切って複数の要素を保持できるリストを作れる

```vim
let list = ['cat', 10, {'name': 'gorilla'}]
" 結果 => ['cat', 10, {'name': 'gorilla'}]
echo list
```

### リストの要素取得
- `{list}[{idx}]`
- `get({list}, {idx}, {default})`

```vim
let list = ['cat', 10, {'name': 'gorilla'}]

" 結果 => cat
echo list[0]

" 結果 => 10
echo get(list, 1, 'NONE')
```

### リストの結合
- `join({list}, {sep})`で`{list}`を`{sep}`で結合して1つの文字列を返す

```vim
let list = ['hello', 'my', 'name', 'is', 'gorilla']

" 結果 => hello my name is gorilla
echo join(list, ' ')
```

### if文
- if文の基本形は`if {expr} | endif`
- `{expr}`が0以外の場合はtrue、0の場合はfalse

```vim
if {expr}
  " do something
elseif {expr}
  " do something
else
  " do something
endif
```

### 比較演算子
- Vim scriptで主な比較演算子は次の通り
- `ignorecase`の設定次第で動きが変わる演算子がある
- 基本的に`#`がつく大文字小文字考慮の比較演算子を使うと良い

| `ignorecase`次第 | 大小文字考慮 | 大小文字無視 | 意味                 |
|------------------|--------------|--------------|----------------------|
| `==`             | `==#`        | `==?`        | 等しい               |
| `!=`             | `!=#`        | `!=?`        | 等しくない           |
| `>`              | `>#`         | `>?`         | より大きい           |
| `>=`             | `>=#`        | `>=?`        | より大きいか等しい   |
| `<`              | `<#`         | `<?`         | より小さい           |
| `<=`             | `<=#`        | `<=?`        | より小さいか等しい   |
| `is`             | `is#`        | `is?`        | 同一のインスタンス   |
| `isnot`          | `isnot#`     | `isnot?`     | 異なるインスタンス   |

### バッファについて
- メモリ上にロードされたファイルのこと
- バッファには名前と番号があり、名前はファイル名で、番号は作成された順で割り当てられる
- バッファは`:bwipeout`で明示的に削除するかVimを終了しなければメモリに残る

### バッファの存在チェック
- `bufexists({expr})`で`{expr}`のバッファがあるかを確認できる
- `{expr}`が数値の場合はバッファ番号、文字列の場合はバッファ名とみなされる

### バッファのタイプ
- `set buftype={type}`でバッファのタイプを設定できる
- 一時的に使うバッファは`nofile`というタイプするのが一般的
- 詳細は`:h buftype`を参照

### バッファのテキストを取得
- カレントバッファからテキストを取得するには`getline({lnum}, {end})`を使用する
`{end}`を指定しない場合は`{lnum}`で指定した行だけを取得する

```vim
" 結果 => 1行目のテキストが出力される
echo getline(1)

" 結果 => 1~3行目のテキストがリストで取得できる
echo getline(1, 3)
```

### バッファのテキストを変更
- カレントバッファのテキストを変更するには`setline({lnum}, {text})`を使用する
- `{text}`がリストの場合は、`{lnum}`行目とそれ以降の行がリストの要素に変更される

```vim
" 結果 => 1行目に my name is gorilla が挿入される
call setline(1, 'my name is gorilla')

" 結果 => 1行目がmy、2行目がnameが挿入される
call setline(1, ['my', 'name'])
```

### ウィンドウについて
- ウィンドウはバッファを表示するための領域
- ウィンドウにはIDが割り当てられる
- 複数のウィンドウを開けばそれぞれのウィンドウでバッファを表示できる
- `:q`といったコマンドではウィンドウを閉じるだけなのでバッファは残る

### ウィンドウIDを取得
- `win_getid()`で現在のウィンドウIDを取得できる
- 引数を受け取ることもできるので詳細は`:h win_getid()`を参照

### ウィンドウに移動
- `win_gotoid({expr})`で`{expr}`のIDのウィンドウに移動

### バッファが表示されているウィンドウのIDを取得
- `bufwinid({expr})`で`{expr}`のバッファが表示されているウィンドウのIDを取得

### 関数
- 関数は`function`と`endfunction`で囲い、処理はその間に記述

```vim
function! Echo(msg) abort
  echo a:msg
endfunction
```

### 関数の存在チェック
- `exists({expr})`で`{expr}`の変数があるかをチェックできる
- 関数をチェックするときは関数名の前に`*`をつける

```vim
if exists('*readdir')
  " do something
else
```

### `!`と`abort`
- `!`は同名の関数がある場合は上書きする
- `abort`は関数内でエラーが発生した場合、そこで処理を終了する
- Vim scriptはデフォルトでエラーがあっても処理が継続されるため基本的に`abort`をつける

### 引数
- 引数を使用するときは`a:`スコープ接頭子を付ける必要がある

### 戻り値
- `return {expr}`で`{expr}`の評価結果を返すことができる

```vim
" 結果 => gorillaが返る
function! MyName() abort
  return 'gorilla'
endfunction
```

### Exコマンド実行
- `execute {expr} ..`で`{expr}`の評価結果の文字列をExコマンドとして実行できる
- 複数の引数がある場合、それらはスペースで結合される

```vim
" 結果 => godzilla
execute 'echo' '"godzilla"'

" 結果 => gorilla godzilla
execute 'echo' '"gorilla"' '"godzilla"'
```

### 外部コマンド実行
- `system({expr}, {input})`で`{expr}`の評価結果の文字列を外部コマンドとして実行できる
- `{input}`は省略可能で、指定した場合はその文字列をそのままコマンドの標準入力として渡される

```vim
" 結果 => my name is gorilla
echo system('echo "my name is gorilla"')

" 結果 => my name is gorilla
echo system('cat', 'my name is gorilla')
```

### Lambda
- `{ args -> expr }`という形でLambdaを書くことができる

```vim
let F = {a, b -> a - b}
" 結果 => [1, 2, 3, 4, 7]
echo sort([3, 7, 2, 1, 4], F)
```

## セッション管理のプラグインを作ってみよう
今回作成するプラグインはVimのセッション機能を少し便利にするプラグインで、仕様は以下になります。

- `let g:session_path = {path}`でセッション保存先を設定できる(必須オプション)
- `:SessionCreate {name}`で`{name}`の名前でセッションファイルを保存できる
- `:SessionList`でセッション一覧をバッファに表示し、`Enter`を押下するとカーソル上にあるセッションをロードできる

### ディレクトリ構成
プラグインの基本的なディレクトリ構成は次のようになります。
`*.vim`はスクリプトファイルと呼びます。

```
session.vim/
├── autoload
│   └── session.vim
├── doc
│   └── session.txt
└── plugin
    └── session.vim
```

### `plugin`ディレクトリについて
`plugin`配下はプラグインが提供するExコマンドやオプションを記述したスクリプトファイルを置きます。
メインの処理はここではなく後述する`autoload`に記述します。

スクリプトファイル名はプラグイン名と同じにするのが一般的です。

### `autoload`ディレクトリについて
`autoload`配下はメインの処理を記述したスクリプトファイルを置きます。
配下のスクリプトファイルはVim起動時ではなく、コマンド実行時に一度だけ読み込まれます。

また、スクリプトファイル名はプラグイン名にすることが一般的です。

`plugin`配下から呼ぶことができる関数を`autoload`配下に定義する時、`ファイル名#関数名()`という命名規則に従う必要があります。
これはコマンドを実行する時に`autoload`配下のどのファイルのどの関数を呼べば良いのかを知る必要があるからです。

そのため、プラグイン名が被ると`autoload`配下のスクリプトファイル名も被り、最悪違うプラグインの関数で上書きされる可能性があります。
これがプラグイン名がかぶらないようにする必要がある理由です。

### `doc`ディレクトリについて
`doc`配下はヘルプファイルを置きます。`:h SessionList`というようにコマンドのヘルプを引けるようにするためです。
基本的にヘルプに書かれているものは公式、書かれていないものは非公式の機能になります。プラグインを公開する時はREADME.mdだけでなくヘルプを書きましょう。

### プラグインディレクトリ`session.vim`の作成
開発中のプラグインを動作確認をするために、プラグインをロードする必要があります。
今回ではVimにビルドインされているパッケージ機能を利用して、開発中のプラグインをロードします。
開発の準備としてパッケージ機能で使用するディレクトリと、今回開発するプラグインのディレクトリ構成を作成します。

```sh
# パッケージ機能で使用するディレクトを作成します。ここにプラグインのディレクトリを置くとVim起動時にruntimepathに追加され、プラグインがロードされます
$ mkdir -p ~/.vim/pack/plugins/start/
# Neovimの場合は以下のディレクトリになります。以下手順は適宜読み替えてください
$ mkdir -p ~/.config/nvim/pack/plugins/start/

# プラグインのディレクトリ構成を作成します
$ cd ~/.vim/pack/plugins/start/
# Neovimの場合は以下
$ cd ~/.config/nvim/pack/plugins/start/

$ mkdir session.vim
$ cd session.vim
$ mkdir autoload plugin
$ touch autoload/session.vim
$ touch plugin/session.vim
```

### セッションファイルを保存するディレクトリの作成
```sh
# Vimの方は~/.vim/session
mkdir -p ~/.vim/session

# Neovimの方は~/.config/nvim/session
mkdir -p ~/.config/nvim/session
```

### `autoload/session.vim`の実装
#### 1. セッションを保存する関数
まずは`g:session_path`にセッションファイルを保存する関数を作ります。

```vim
let s:sep = fnamemodify('.', ':p')[-1:]

function! session#create_session(file) abort
  execute 'mksession!' join([g:session_path, a:file], s:sep)
  redraw
  echo 'session.vim: created'
endfunction
```

関数を実装したら、`so %`で一度スクリプトファイルをロードします。そうすると関数を実行できるようになります。
次にコマンドラインで`g:session_path`を設定します。それぞれの環境に合わせて先ほど作成したパスを設定してください。

```vim
:let g:session_path = {path}
```

では実際関数を実行して、セッションファイルを作ってみましょう。正常に作成できたら`session.vim: created`メッセージが出力されます。

```vim
:call session#create_session('test')
```

#### 2. セッションをロードする関数
以下の関数を作ります。

```vim
function! session#load_session(file) abort
  execute 'source' join([g:session_path, a:file], s:sep)
endfunction
```

関数を作ったら、一度Vimを再起動して先程保存したセッションファイルを実際ロードしてみましょう。
ウィンドウの状態が戻ったらOKです。

```vim
call session#load_session('test')
```

#### 3. エラーメッセージを出力する関数
処理中に何かしらエラーが発生した場合、エラーメッセージであることがわかるように、
`echohl`を使ってコマンドラインに赤いメッセージを出力する関数を作ります。

```vim
function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'session.vim:' a:msg
  echohl None
endfunction
```

実際メッセージは赤くなるのかを確かめるため、グローバルな関数`TestEcho()`を作ります。

```vim
function! TestEcho(msg) abort
    call s:echo_err(a:msg)
endfunction
```

上記2つの関数を作ったら`TestEecho`を実行して、赤いメッセージが出たらOKです。

```vim
:call TestEcho('I am gorilla')
```

これは動作確認の関数なので削除しておきましょう。`:delfunc TestEcho`で削除するか、一度Vimを再起動するかしましょう。

#### 4. `g:session_path`からセッションファイル一覧を取得する関数を実装
`s:readdir`関数を使って`g:session_path`配下にあるファイルのリストを取得します。

ここでのキモは`exists()`で`readdir()`関数があるかを確認するところです。

`readdir()`がなければ`glob()`関数を使ってファイルとディレクトリ一覧を取得する関数`s:readdir()`を用意している部分です。Neovimでは`readdir()`がないため`glob()`を使う必要があります。

`readdir()`がある場合は`function()`で関数への参照を取得して`s:readdir`変数に代入して、NeovimでもVimでも同じ変数名でファイル一覧を取得できるようにします。

ファイル、ディレクトリ一覧を取得したあとに、ファイルのみを抽出するために`Filter`Lambdaを用意し`filter()`関数を使って絞り込みます。

```vim
if exists('*readdir')
  let s:readdir = function('readdir')
else
  function! s:readdir(dir) abort
    return map(glob(a:dir . s:sep . '*', 1, 1), 'fnamemodify(v:val, ":t")')
  endfunction
endif

function! s:files() abort
  let session_path = get(g:, 'session_path', '')
  if session_path is# ''
    call s:echo_err('session_path is empty')
    return []
  endif

  let session_path = expand(session_path)
  let Filter = { file -> !isdirectory(session_path . s:sep . file) }
  return filter(s:readdir(session_path), Filter)
endfunction
```

では、実際ファイル一覧を取得できるかを確認してみましょう。グローバルな関数`TestFiles()`を作ります。

```vim
function! TestFiles() abort
  echo s:files()
endfunction
```

作った関数を実行して、先程作成した`test`ファイルが出力されればOKです。

```vim
:call TestFiles()
```

このテストのための関数も不要なので削除しておきましょう。

#### 5. セッション一覧を表示する
セッションファイルをリストで取得できるようになったので、次に取得したセッション一覧をバッファに書き出します。

```vim
let s:session_list_buffer = 'SESSIONS'

function! session#sessions() abort
  let files = s:files()
  if empty(files)
    return
  endif

  execute 'new' s:session_list_buffer
  set buftype=nofile

  call setline(1, files)
endfunction
```

これで`:call session#sessions()`を実行すると`SESSIONS`というバッファにセッションファイル一覧が表示されます。

しかし、このままでは関数を実行するたびに新しいウィンドウが作れてしまうので、以下のことを考慮して改善する必要があります。

- バッファがなければ新規作成
- バッファがあるがウィンドウに表示されていないならウィンドウに表示させる
- バッファがあってウィンドウに表示されているなら、バッファの中身をクリア

```diff
function! session#sessions() abort
  let files = s:files()
  if empty(files)
    return
  endif

+ " if buffer exists
+ if bufexists(s:session_list_buffer)
+   " if buffer display in window
+   let winid = bufwinid(s:session_list_buffer)
+   if winid isnot# -1
+     call win_gotoid(winid)
+   else
+     execute 'sbuffer' s:session_list_buffer
+   endif
+ else
    execute 'new' s:session_list_buffer
    set buftype=nofile
+ endif
+
+ " delete buffer contents
+ %delete _
  call setline(1, files)
endfunction
```

diffの処理を追加したら`:so %`で再度スクリプトをロードして関数を実行してみましょう。新たなウィンドは作れず既存バッファとウィンドウを使うようになっているはずです。

#### 6. キーマッピングを追加
表示はできたので、最後に以下のキーマッピングを追加していきます。

- `Enter`でカーソル下にあるセッションファイルをロード
- `q`でバッファを破棄

```diff
function! session#sessions() abort
  let files = s:files()
  if empty(files)
    return
  endif

  " if buffer exists
  if bufexists(s:session_list_buffer)
    " if buffer display in window
    let winid = bufwinid(s:session_list_buffer)
    if winid isnot# -1
      call win_gotoid(winid)
    else
      execute 'sbuffer' s:session_list_buffer
    endif
  else
    execute 'new' s:session_list_buffer
    set buftype=nofile

+   nnoremap <silent> <buffer>
+         \   <Plug>(session-close)
+         \   :<C-u>bwipeout!<CR>
+   nnoremap <silent> <buffer>
+         \   <Plug>(session-open)
+         \   :<C-u>call session#load_session(trim(getline('.')))<CR>
+
+   nmap <buffer> q <Plug>(session-close)
+   nmap <buffer> <CR> <Plug>(session-open)
  endif

  " delete buffer contents
  %delete _
  call setline(1, files)
endfunction
```

`<Plug>`は特殊でどのキーともマッピングしないです。多くのプラグインではこの`<Plug>(xxxx)`を提供して、ユーザが自由にキーマッピングできる仕組みを提供しています。

`<buffer>`は現在のバッファだけにキーマッピングを適用します。今回のような他のバッファに影響しないキーマップを用意するときは付ける必要があります。

以上が`autoload/session.vim`の実装になります。

### `plugin/session.vim`の実装
続けて`plugin`配下を実装していきます。`plugin/session.vim`でやることは2つです。

- プラグイン無効化、二重ロード防止
- コマンド定義

#### プラグイン無効化、二重ロード防止
Vim起動時に`plugin`配下のスクリプトがロードされるので、そこでロード済みかどうかを判断するグローバル変数を用意します。変数名はプラグイン名にプレフィックス`g:loaded_`をつけます。

この変数がすでに定義済みなら、`finish`でロード処理を中止します。ユーザがプラグインを無効化したい場合はこの変数を予めvimrcに設定しておくことで、プラグインを無効化できます。

```vim
if exists('g:loaded_session')
  finish
endif
let g:loaded_session = 1
```

#### コマンド定義
`command`関数でExコマンドを定義します。`-nargs`はコマンドに渡せる引数の数を設定できます。
今回はセッションの作成時にファイル名が必要なので`-nargs=1`で1つ引数が必要の設定にします。
`<q-args>`は引数を意味します。詳細は`:h <q-args>`を参照して下さい。

```vim
command! SessionList call session#sessions()
command! -nargs=1 SessionCreate call session#create_session(<q-args>)
```

以上、`plugin/session.vim`の実装は終わりです。これでコマンドでセッションの保存とセッション一覧表示とロードが出来るようになります。

実際にVimを再起動して`:SessionCreate`と`:SessionList`を実行して`Enter`でロードできるか確認してみましょう。

### ヘルプ
プラグインの実装は終わったのですが、プラグインを公開するにあたりヘルプを書く必要があります。ヘルプはユーザがプラグインで使用できる設定変数やコマンド、関数、キーマッピングの使い方を知るのに必要です。

今回はコマンド2つに設定変数が1つなので記述する量は少ないのですが、大きなプラグインとなると記述量も増えます。そこで[LeafCage/vimhelpgenerator](https://github.com/LeafCage/vimhelpgenerator)を使ってある程度ヘルプのテンプレートを生成します。

プラグインを導入して`:VimHelpGenerator`を実行すると`doc/session.txt`が作られます。それがヘルプファイルになります。

今回追記する部分は以下になります。

```
------------------------------------------------------------------------------
VARIABLES                                               *session-variables*
ここにユーザが使用できる変数の説明を記述


------------------------------------------------------------------------------
COMMANDS                                                *session-commands*
ここにユーザが使用できるコマンドの説明を記述


------------------------------------------------------------------------------
KEY-MAPPINGS                                            *session-key-mappings*
ここにユーザが使用できるキーマップの説明を記述
```

一例ですが、以下の様に設定変数と説明を記述します。`*`で囲っている部分は実際`:h`で検索される部分なので、そこは必ず記述しましょう。

```
------------------------------------------------------------------------------
VARIABLES                                               *session-variables*

g:session_path                                          *g:session_path*
    セッションを保存するファイルパスを設定します。


------------------------------------------------------------------------------
COMMANDS                                                *session-commands*
ここにユーザが使用できるコマンドの説明を記述

:SessionList                                            *:SessionList*
セッション一覧を開きます。
Enterでカーソル上にあるセッションをロードします。

:SessionCreate {name}                                   *:SessionCreate*
セッションを{name}で保存します。

------------------------------------------------------------------------------
KEY-MAPPINGS                                            *session-key-mappings*
<CR>                                                    *session-list-<cr>*
カーソル下のセッションをロードします。

q                                                       *session-list-q*
セッションリストのバッファを閉じます。
```

ヘルプを記述し終わったら、ちゃんとヘルプを引けるかどうか`:helptags doc`でヘルプタグを生成して実際引いてみましょう。

### 最後に
これでハンズオンは終わりです。Vim scriptの基礎とプラグインの作り方について一通り解説しましたがわからないところもあるかと思います。不明点などあればいつでも[ゴリラ](https://twitter.com/gorilla0513)まで質問してください。

このハンズオンでみなさんにプラグインの作り方について体験して頂くことで、なにかしらを持ち帰っていただけたらと思います。

お疲れさまでした。
