# tiny_s3_uploader

## こんなシーンを想定して作りました

- S3 にアップロードしてほしいけど credential を発行 / 増やしたくない
- 担当者が aws cli を使ってくれない
- 担当者に Cyberduck も拒否られてしまった

単一のバケットにただファイルをアップロードするだけのサーバレスアプリケーションです。

## デプロイ方法

1. terraform/tiny_s3_uploader.tfvars を編集する
    - s3_bucket_prefix : S3 バケット名
    - source_ip_list: terraformを実行する(AWSコンソールを操作する)環境のIPとアップロードする環境のIPを設定する
1. terraform 実行
    - `cd terraform/`
    - `terraform apply -var-file tiny_s3_uploader.tfvars`
1. assets/tinyS3Uploader.js を編集する
    - docsBucketName : ファイルをアップロードする S3 バケット名 (terraform環境変数 s3_bucket_prefix + "docs")
    - bucketRegion : S3, cognito のあるリージョン
    - IdentityPoolId : terraform で構築した cognito id pool の id
1. web ホスティング用の s3 バケットにコードをアップロードする
    - `aws s3 cp ../assets s3://${terraform環境変数 s3_bucket_prefix} ----recursive`

## 使用方法

1. ブラウザから S3 バケット名 (terraform環境変数 s3_bucket_prefix) のバケットウェブサイトエンドポイントにアクセスする
1. 画面に従いファイルをアップロードする
    - ファイルは S3 バケット名 (terraform環境変数 s3_bucket_prefix + "docs") に保存される

## 注意事項

- アプリケーションへのアクセスは、アクセス元 IP のみで制限しています
    - 認証は入れていないので必要な場合は別途cognitoに入れてください
- 社内アクセスのみを想定しているので http で通信しています
    - 必要であれば https 化してください
- 独自ドメインも付与していません
    - 必要であれば設定してください