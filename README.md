# テーマ
Vim scriptを使って簡易なプラグインを作ってみよう

# 前提知識
- ターミナルの操作方法

# 必要環境
- 以下のバージョンのVimとNeovimを用意

# 全体の流れ
- Vim scriptの基礎
- セッション管理のプラグインを作ってみよう

# Vim scriptの基礎
- Vim scriptはVim上で実行できるスクリプト言語
- Exコマンド(`:`で始まるコマンド)の集合体
- vimrcに記述しているのもVim script
- Vimのプラグインの多くはVim scriptで書かれている

## Vim scriptの実行
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

## コメント
Vim scriptでは`"`がコメント行として解釈され処理をスキップします。

```vim
" この行は処理されない
" echo 'gorilla'
```

## データ型
主に以下のデータを使用できます。

| データ型 | 例                   |
|----------|----------------------|
| 数値     | 5                    |
| 小数     | 5.5                  |
| 文字列   | 'gorilla'、"gorilla" |
| リスト   | [1, 2, 3]            |
| 辞書     | {'name': 'gorilla'}  |

## 文字列
`"`と`'`で囲ったものは文字列になります。
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

## 変数
- `let`を使っての宣言と値を代入する
- 宣言済みの変数でも値を代入するときは`let`を使用しなければいけない

```vim
let name = 'gorilla'
" letがないのでエラーになる
name = 'cat'
```
## 変数名
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

## スコープ
- 変数や後述する関数にはスコープがある
- 接頭子によってスコープが変わる
- 関数内で`l:`を省略した場合は暗黙的にローカル変数にアクセスする

| 接頭子 | スコープ                                             |
|--------|------------------------------------------------------|
| `g:`   | グローバルスコープ、どこからも利用可能               |
| `s:`   | スクリプトスコープ、スクリプトファイル内のみ使用可能 |
| `l:`   | ローカルスコープ、関数内のみ使用可能                 |
| `a:`   | 関数の引数、関数内のみ使用可能                       |
| `v:`   | グローバルスコープ、Vimが予め定義している変数        |

## 辞書
- `{{key}: {value}}`の形になる
- `{key}`は文字列でなければいけない

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

## リスト
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

## if文
- if文の基本形は`if {expr} | endif`
- `{expr}`が1の場合はtrue、0の場合はfalse

```vim
if {expr}
  " do something
elseif {expr}
  " do something
else
  " do something
endif
```

## 比較演算子
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
| `isnot`          | `isnot#`     | `isnot?`     | 異なるのインスタンス |

## バッファについて
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

### バッファにテキストを挿入
- カレントバッファにテキストを挿入するには`setline({lnum}, {text})`を使用する
- `{text}`はリストの場合は、`{lnum}`行目とそれ以降の行に要素が挿入される

```vim
" 結果 => 1行目に my name is gorilla が挿入される
call setline(1, 'my name is gorilla')

" 結果 => 1行目がmy、2行目がnameが挿入される
call setline(1, ['my', 'name'])
```

### ウィンドウについて
- ウィンドウはバッファを表示するための領域
- ウィンドウにはIDが割り当てられます。
- 複数のウィンドウで複数のバッファを表示できます。
- `:q`といったコマンドではウィンドウを閉じるだけなのでバッファは残る

#### ウィンドウIDを取得
- `winnr()`で現在のウィンドウIDを取得できる
- 引数を受け取ることもできるので詳細は`:h winnr()`を参照

#### ウィンドウに移動
- `win_gotoid({expr})`で`{expr}`のIDのウィンドウに移動

#### バッファが表示されているウィンドウのIDを取得
- `bufwinid({expr})`で`{expr}`のバッファが表示されているウィンドウのIDを取得

### 関数
- 関数は`function`と`endfunction`で囲い、処理はその間に記述

```vim
function! Echo(msg) abort
  echo a:msg
endfunction
```

#### 関数の存在チェック
- `exists({expr})`で関数があるかをチェックできる
- 関数をチェックするとき`{expr}`は関数名の前に`*`をつける

```vim
if exists('*readdir')
  " do something
else
```

#### `!`と`abort`
- `!`は同名の関数がある場合は上書きする
- `abort`は関数内でエラーが発生した場合、そこで処理を終了する
- Vim scriptはデフォルトでエラーがあっても処理が継続されるため基本的に`abort`をつける

#### 引数
- 引数を使用するときは`a:`スコープ接頭子を付ける必要がある

#### 戻り値
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
- `{input}`は省略可能で指定した場合はその文字列をそのままコマンドの標準入力として渡される

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

# セッション管理のプラグインを作ってみよう

### ディレクトリ構成
#### `plugin`ディレクトリについて
#### `autoload`ディレクトリについて
#### `doc`ディレクトリについて
## 開発の大まかな流れ
### `autoload/session.vim`の実装
#### セッション保存処理
#### セッションロード処理
#### セッション一覧取得処理
##### セッションファイルのリストを取得
##### リストを表示するバッファを作成（すでにあれば表示）
### `plugin/session.vim`の実装
#### グローバルガード
#### コマンド定義
