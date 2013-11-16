SQLインジェクション デモアプリ
================================
このディレクトリ以下にあるデモアプリを動かすことでSQLインジェクション攻撃を試すことができます。

ディレクトリ構成
---------------
```
sql-injection/
|- vulnerable-site/ # SQLインジェクション脆弱性のあるサイト
```

セットアップ手順
---------------
まず必要なモジュールをインストールします。
```sh
$ cd vulnerable-site/
$ carton install
```

データベースとしてMySQLを使うのでセットアップスクリプトを流し込み, MySQLサーバを起動します.  
またWebアプリからMySQLにアクセスするための設定も行います.
```sh
$ mysql {DB_NAME} -u {DB_USER} -p < vulnerable-site/setup.sql
$ mysql.server start
$ cp vulnerable-site/SampleApp/lib/SampleApp/{Config.pm.dist,Config.pm}
$ vi vulnerable-site/SampleApp/lib/SampleApp/Config.pm # edit MySQL configurations
```

MySQLのセットアップが完了したらWebサーバを立ちあげ, ブラウザでhttp://localhost:5000/にアクセスしてみてください。

```sh
$ cd vulnerable-site/
$ carton exec -- plackup SampleApp/app.psgi -r -E development -p 5000
```

SQLインジェクション攻撃を行う
-----------------------------
検索用のフォームに悪意のある入力を入れて, ユーザの預金残高を増やしてみてください.
