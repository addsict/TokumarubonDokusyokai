CSRF デモアプリ
==================
このディレクトリ以下にあるデモアプリを動かすことでCSRF攻撃を試すことができます。

ディレクトリ構成
---------------
```
csrf/
|- vulnerable-site/ # CSRF脆弱性のあるブロクサービスを模したサイト
|- attacker-site/ # CSRF脆弱性を利用しようとする悪意のあるサイト
```

手順
------------------
まず必要なモジュールをインストールします。
```sh
$ cd vulnerable-site/
$ carton install
$ cd ../attacker-site/
$ carton install
```

次にターミナルを2つ開き各々のサーバを立ちあげます。  
vulnerable-siteの方は必ず5000番ポートで動かすようにして下さい。
```sh
$ cd vulnerable-site/
$ carton exec -- plackup SampleApp/app.psgi -r -p 5000
```

```sh
$ cd attacker-site/
$ carton exec -- plackup SampleApp/app.psgi -r -p 5001
```

ブラウザでhttp://localhost:5000(vulnerable-siteの方)にアクセスしログインします。  
ユーザ名: **taro**  
パスワード: **pass**  
ログインしたらブログエントリをいくつか投稿してみて下さい。

次にブラウザでhttp://localhost:5001(attacker-siteの方)にアクセスします。  
アクセス後、先ほどのvulnerable-siteの方に再びアクセスしてみて下さい。  
CSRF攻撃が成立し、ブログエントリが勝手に投稿されてしまいました。

CSRF対策
----------
対策手法の例として,

- Refererをチェックする方法
- リクエストにTokenを埋め込む方法

のサンプルコードを含んでいます。  

それぞれ

- csrf/refererブランチ
- csrf/tokenブランチ

にあるので、ブランチを切り替えて攻撃が防がれるのを試してみてください。
