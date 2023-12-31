# Herokuデプロイ手順

ここではローカル環境で動作させているpotepanecアプリケーションをHerokuにデプロイする手順を説明します。

# ゴール

- ローカルと同じ動作がHeroku上でも実現できていること
- ユニークなURLが生成され、誰でもアクセス出来る状態になっていること

# 準備

## Herokuアカウントの作成

最終課題に入るタイミングで、Herokuより招待メールが送信されています。

Herokuアカウントを既にお持ちか否かで設定手順が異なってきますので、ご注意ください。

※**2022年10月30日以前に最終課題に入られた方には招待メールは送信されておりません**ので、「Heroku CLIをインストール」までスキップしてください。

### Herokuアカウントをお持ちの場合

`Invitation to collaborate on (アプリケーション名)`という件名の招待メールが送信されています。

その中の`visit the app in the dashboard`というリンクをクリックいただくと、Herokuのサイトへ遷移します。

遷移後、ご自身のGithubアカウントと同じ名前（※「大文字→小文字」、「アンダースコア→ハイフン」の形式で変換されています）のAppが表示されていれば、Herokuの事前準備は完了ですので、次のステップへ進んでいきましょう。

### Herokuアカウントをお持ちでない場合

`You've been invited to collaborate on a Heroku app`という件名の招待メールが送信されています。

このメールの中に `Accept Invitation`というボタンがありますので、そちらをクリックしてください。

その後、以下のようなアカウント作成ページ或いはパスワード設定ページへ遷移しますので、必要事項を記入してください。

![アカウント作成ページ](https://res.cloudinary.com/he3zvdcui/image/upload/v1667202626/Heroku%20Set%20Up/create_your_account_rgcvdd.png)

![パスワード設定ページ](https://res.cloudinary.com/he3zvdcui/image/upload/v1667191171/Heroku%20Set%20Up/set_your_password_bctfof.png)

設定完了後、フォーム下部のボタンをクリックすると以下の利用規約ページへ遷移しますので、設定は変更せずそのまま`Accept`ボタンをクリックしてください。

![利用規約ページ](https://res.cloudinary.com/he3zvdcui/image/upload/v1667191190/Heroku%20Set%20Up/terms_of_service_w1nfiv.png)

ダッシュボードページ左上の`Personal`という部分をクリックいただくと、ダイアログの下部に`final-task`というメニューが表示されますので、そちらをクリックしてください。

![ダッシュボード](https://res.cloudinary.com/he3zvdcui/image/upload/v1667191203/Heroku%20Set%20Up/dashboard_trfy5w.png)

遷移後、ご自身のGithubアカウントと同じ名前（※「大文字→小文字」、「アンダースコア→ハイフン」の形式で変換されています）のAppが表示されていれば、Herokuの事前準備は完了ですので、次のステップへ進んでいきましょう。

## Heroku CLIをインストール

HerokuへのデプロイにはHeroku CLIを利用します。[インストール](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)しておきましょう。

## AWS S3との連携

開発環境ではローカルにそのまま画像が保存されていましたが、Herokuではクラウドファイルストレージサービスの利用が推奨されています。

ここでは[AWS S3](https://aws.amazon.com/jp/s3/)を使用するので、さっそく連携する設定を行いましょう。

AWS S3はクラウド上のストレージにファイルを保存、ダウンロードすることができるサービスです。多くの画像を扱うライブラリはこれに対応しておりますが、今回はRails標準の`Active Storage`を使用します。

ここではAWSの無料枠を使ってS3とアプリケーションを連携し、商品画像を保存した時にS3にそのファイルが保存されるようにします。また、商品ページにアクセスした時にS3から画像をダウンロードし、ブラウザに表示されるようにします。

### AWSアカウントの作成

まずはAWSのアカウントを作成しましょう。以下のURLから手順に従って情報を入力してください。
https://portal.aws.amazon.com/billing/signup

AWSにはいくつかのサービスで[無料枠](https://aws.amazon.com/jp/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc)があり、S3では5GBまで無料で使えます。途中、クレジットカード情報を入力する場面がありますが、無料枠内であれば実際に請求されることはないので安心してください。

### IAMユーザーの作成

アカウントが作成できれば、次は[IAM](https://console.aws.amazon.com/iam/home?region=ap-northeast-1#/home)ユーザーを作成します
IAMはAWSサービスの1つで、簡単に言うと先ほど作成したAWSアカウントに紐づくユーザー情報を作成・編集・削除出来るものです。IAMユーザーには各AWSサービスに対する権限、例えば「S3に画像をアップロードする権限」を設定できます。

ここではSolidusアプリケーションに設定するためのユーザー、`potepanec`ユーザーを作成し、必要な権限を付与していきましょう。

まずは[AWS IAM](https://console.aws.amazon.com/iam/home?region=ap-northeast-1#/home)のページにアクセスします。

左のメニューから`Users`->`Add users`を選択し、以下の手順でユーザーの作成を進めてください。

1. `User name`に`potepanec`を入力し、次へ進む（※`Enable console access`のチェックは不要です。）
2. `Permissions options`で`Attach policies directly`を選択する
3. `Permissions policies`から`AmazonS3FullAccess`を選択し、次へ進む
4. `Tags`には何も入れず、`Create user`をクリックする

無事ユーザーが作成されましたので、続いて、以下の手順でアクセス情報を生成していきます。

1. ユーザー一覧より、`potepanec`をクリックする
2. `Security credentials`のタブをクリックする
3. ページ中段の`Access keys`セクションの`create access key`をクリックする
4. `Access key best practices & alternatives`で`Other`を選択し、次へ進む
5. `Description tag`には何も入れず、`Create access key`をクリックする
6. `Download .csv file`をクリックし、アクセス情報をダウンロードする

このファイルは後にpotepanecアプリケーションとAWSを連携させる際に必要になるため、どこかに保存しておいてください。
（※秘匿情報ですので、他人には公開しないでください。）

### S3バケットの作成

バケット(bucket)とはS3上のフォルダのようなもので、ファイルを保存したり、さらにその下にフォルダを作成することができます。

AWS CLIを使ってバケットを作成するので、まずはAWS CLIをインストールしましょう。

```sh
$ brew install awscli
```

インストールが完了したことが確認できれば、先ほどダウンロードした`potepanec`ユーザーの情報が記載されたCSVファイルを参照しながら、AWS CLIの設定を行いましょう。

```sh
$ aws configure
AWS Access Key ID [None]: （potepanecユーザーのAccess key ID）
AWS Secret Access Key [None]: （potepanecユーザーのSecret access key）
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

設定できればAWS CLIを使ってバケットを作成します。

※バケット名はS3上でユニークでなければならないため、バケット名「potepanec」の部分は適宜変更してください。

```sh
$ aws s3 mb s3://potepanec
make_bucket: potepanec
$ aws s3api put-public-access-block --bucket potepanec --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
$ aws s3api put-bucket-ownership-controls --bucket potepanec --ownership-controls Rules=[{ObjectOwnership=ObjectWriter}]
$ aws s3api put-bucket-acl --bucket potepanec --acl public-read
$ aws s3 ls
YYYY-MM-DD HH:MM:SS potepanec
```

最後のコマンドでバケットの名前が表示されれば設定は完了です。

### Active Storageの設定

最後にpotepanecアプリケーションとS3を連携させ、商品画像がS3に保存されるようにしましょう。

Active Storageの基本設定は済んでいるので、AWSのアカウント情報、およびS3のバケット情報をActive Storageに伝える設定を行います。

[Active Storageのガイド](https://railsguides.jp/active_storage_overview.html)を参考にして`config/storage.yml`のamazonの項目のコメントアウトを外して必要な変更を加えましょう。

```yml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: ap-northeast-1
  bucket: バケット名
```

※「bucket: バケット名」の部分は一つ前の手順でAWS S3に作成したバケット名を設定してください。

最後に、この変更をコミットしましょう。

```sh
$ git commit -a -m "Configure Active Storage to use S3"
```

ここでは`AWS_ACCESS_KEY_ID`と`AWS_SECRET_ACCESS_KEY`という環境変数から、IAMユーザーの認証情報を取得するようにしています。環境変数を使っているのはセキュリティ上の懸念からです。認証情報をそのままコード内に記述してGitHubなどの不特定多数のユーザーがアクセスできる環境に公開されてしまうと、それを悪用される可能性があります。注意しましょう。

# 初めてのデプロイ

## HerokuへDeploy

まずはHerokuにデプロイするまでの手順を一通り行ってみましょう。

※**最終課題に入られたタイミングが2022年10月30日以前か否かで実行手順が異なっております**のでご注意ください。

### 2022年10月30日以前に最終課題に入られた方はこちら

まずはHeroku上に空のアプリケーションを作成します。

```sh
$ heroku create --stack heroku-20
```

次に、事前に準備したAWS S3バケットへの接続情報を`potepanec`アプリケーションが取得できるように、heroku CLIを使って設定します。

```sh
$ heroku config:set AWS_ACCESS_KEY_ID=(potepanecユーザーのAccess key ID) AWS_SECRET_ACCESS_KEY=(potepanecユーザーのSecret access key)
```

実行後、「最後にHeroku上にコードをデプロイします。...」までスキップしてください。

### 2022年10月31日以降に最終課題に入られた方はこちら

まずは各自にご用意しているHerokuアプリケーションの情報を確認します。

Herokuからの招待メールに記載されているアプリケーション名を確認の上、以下を実行しましょう。

```sh
$ heroku info -a (アプリケーション名)
```

次にアプリケーション情報の中からHerokuアプリケーション用の`Git URL`を確認し、push先のリポジトリとして登録しましょう。

```sh
$ git remote add heroku (Git URL)
```

次に、事前に準備したAWS S3バケットへの接続情報を`potepanec`アプリケーションが取得できるように、heroku CLIを使って設定します。

```sh
$ heroku config:set AWS_ACCESS_KEY_ID=(potepanecユーザーのAccess key ID) AWS_SECRET_ACCESS_KEY=(potepanecユーザーのSecret access key) -a (アプリケーション名)
```

最後にHeroku上にコードをデプロイします。
ここではデプロイしたいブランチ名を`testbranch`と仮定します。

```sh
$ git push heroku testbranch:master
```

デプロイが無事完了すると以下のようなメッセージが表示されます。

```
※2022年10月30日以前に最終課題に入られた方の場合
https://(ランダム値).herokuapp.com/ deployed to Heroku

※2022年10月31日以降に最終課題に入られた方の場合
https://(アプリケーション名).herokuapp.com/ deployed to Heroku
```

URLはHerokuによって自動的に生成されます。このURLがあなたのアプリケーションのURLとなります。
試しにブラウザでアクセスしてみましょう。

![heroku 500](../images/deploy/heroku_500.png)

おっと、何やらエラー画面が表示されています。
なぜエラーになっているのかを確認してみましょう。

```sh
$ heroku logs --source=app --tail
...
FATAL -- : [a5c760b6-7ccb-4009-9b26-b66de590879c] Mysql2::Error::ConnectionError (Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)):
...
```

どうやらデータベース(MySQL)に接続できていないようです。

これはHeroku上でRailsがアクセスするデータベースの情報が正しく設定されていないことが原因です。

## データベースの作成

Railsでは[環境毎に異なる設定を持たせることが可能](https://railsguides.jp/configuring.html#rails%E7%92%B0%E5%A2%83%E3%82%92%E4%BD%9C%E6%88%90%E3%81%99%E3%82%8B)です。これを利用してHeroku上での環境である`production`環境でデータベースに接続できるようにしましょう。

まずは接続するデータベースを作成していきます。

Herokuには[JawsDB](https://elements.heroku.com/addons/jawsdb)というMySQLデータベースを作成するためのプラグインが存在するため、これを利用します。

### 2022年10月30日以前に最終課題に入られた方はこちら

**2022年10月30日以前に最終課題に入られている場合**、JawsDBを利用するためにHerokuにクレジットカード情報を登録する必要があります(※実際に料金が請求されることはないので安心してください)。

[Herokuのアカウント情報](https://dashboard.heroku.com/account/billing)にアクセスし、クレジットカード情報を登録してください。

登録が完了したら以下のコマンドを実行してください。

```sh
$ heroku addons:create jawsdb:kitefin
```

実行後、「次にRailsに作成したデータベースの接続情報を追加していきます。...」までスキップしてください。

### 2022年10月31日以降に最終課題に入られた方はこちら

**2022年10月31日以降に最終課題に入られている場合、クレジットカード情報の登録は不要です**ので、このまま以下のコマンドを実行してください。

```sh
$ heroku addons:create jawsdb:kitefin
```

次にRailsに作成したデータベースの接続情報を追加していきます。
`config/database.yml`にある`production`の設定情報を以下のように変更してください。

```diff
 production:
   <<: *default
-  database: potepanec_2_7_production
-  username: potepanec
-  password: <%= ENV['POTEPANEC_DATABASE_PASSWORD'] %>
+  url: <%= ENV['JAWSDB_URL']&.sub('mysql://', 'mysql2://') %>
```

`JAWSDB_URL`は先程設定したJawsDBプラグインから提供される環境変数で、ユーザー名やパスワードを含めデータベースに接続するためのすべての情報が格納されています。

以上でデータベースの設定は完了です。

変更をcommitして、再度Herokuにデプロイしましょう。

```sh
$ git commit -a -m "Look for env var defined by JAWSDB addon on production"
$ git push heroku testbranch:master
```

デプロイが完了したら、もう一度URLにアクセスしてみましょう。

![heroku 500](../images/deploy/heroku_500.png)

うーん、また同じエラー画面が表示されてしまいました。ログを見てみましょう。

```sh
$ heroku logs --source=app --tail
...
FATAL -- : [dc87c41d-991b-4104-832d-5be8179f7150] ActiveRecord::StatementInvalid (Mysql2::Error: Table 'bcylltkygs644e41.spree_stores' doesn't exist: SHOW FULL FIELDS FROM `spree_stores`):
...
```

おっ、今度はエラーメッセージが変わりましたね。`spree_stores`というテーブルが存在していないようです。

これはデータベースには正常に接続できているものの、Solidusが必要とするテーブルが作成されていないことを意味します。

## データベースの設定

Solidusが必要とするテーブル、および初期データを作成していきましょう。

まずはテーブルの作成です。
```sh
$ heroku run bin/rails db:migrate
```
`heroku run`は与えられた任意のコマンドをHeroku上で実行するコマンドです。
ここでは `bin/rails db:migrate`を実行し、必要なテーブルを作成しています。

また、下記コマンドも実行もしてSample Storeのテーブルを作っておきましょう。
これを実行しないと商品をカートに入れる実装をした時にエラーカート系のテーブルがなくエラーが起こります。
```sh
$ heroku run bin/rails runner 'Spree::Store.create!(name: "Sample Store", code: "sample-store", url: "example.com", mail_from_address: "store@example.com")'
```

これで必要なテーブルは作成できたはずです。アプリケーションのURLにアクセスしてみましょう。

![Solidus initial view](../images/deploy/solidus_initial_view.png)

見事、正常な画面が表示されましたね! 🎉

しかし、まだ問題があります。商品のデータが存在しません。

幸運にもSolidusではサンプルデータを作成するための方法を用意してくれています。
以下のコマンドを実行して、サンプルデータを作成しましょう。

```sh
$ heroku run bin/rails runner "['products', 'taxons', 'option_values', 'product_option_types', 'product_properties', 'variants', 'assets'].each { |table| Spree::Sample.load_sample(table) }"
```

実行が完了したらアプケーションのURLにアクセスしてみましょう。

![Solidus initial view](../images/deploy/solidus_images_displayed.png)

以上でおしまいです! 商品データが表示されましたか?

念の為、課題で実装したページでも画像が表示されていることを確認しておきましょう。

![Solidus initial view](../images/deploy/images_on_custom_page.png)

### 補足

通常であれば `heroku run bin/rails g spree:install`を実行することでサンプルデータも同時に作成されます。しかし、これを実行した時にデータベースに発行されるクエリの回数がJawsDBの無料プランの上限を超えてしまいエラーになってしまいます。

ここでは代わりに必要なサンプルデータだけを作成するコマンドを実行することで、無料プランによる制限に引っかかるのを回避しています。
