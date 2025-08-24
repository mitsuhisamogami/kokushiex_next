# KokushiEX Next Backend

Rails 7.2 APIサーバー - 理学療法士国家試験対策アプリケーションのバックエンド

## 技術スタック

* **Ruby** 3.3.6
* **Rails** 7.2.2.1 (API mode)
* **データベース** PostgreSQL 16
* **テスト** RSpec + FactoryBot
* **ファイル管理** Active Storage
* **コード品質** RuboCop, Brakeman

## セットアップ

### 前提条件
- Docker Desktop が起動中
- PostgreSQLサービスが利用可能

### 初期セットアップ
```bash
# 依存関係のインストール
bundle install

# データベースの作成
rails db:create

# マイグレーションの実行
rails db:migrate

# テストデータベースの準備
rails db:migrate RAILS_ENV=test
```

### 開発サーバー起動
```bash
# Dockerを使用（推奨）
docker-compose up -d backend

# またはローカルで起動
rails server -p 3000
```

## データベース設定

### PostgreSQL接続設定
- **開発環境**: `kokushi_development`
- **テスト環境**: `kokushi_test`
- **ユーザー**: `rails`
- **パスワード**: `password`
- **ホスト**: `DATABASE_HOST` 環境変数で制御（Docker: `db`, ローカル: `localhost`）

### Active Storage
画像ファイルの管理にActive Storageを使用：
- マイグレーション完了済み
- `image_processing` gem による画像処理対応
- ローカルストレージ設定

## テスト実行

```bash
# 全テスト実行
bundle exec rspec

# 特定のテストファイル実行
bundle exec rspec spec/models/user_spec.rb

# カバレッジ付きテスト実行
COVERAGE=true bundle exec rspec
```

## コード品質チェック

```bash
# スタイルチェック
bundle exec rubocop

# 自動修正
bundle exec rubocop -a

# セキュリティチェック
bundle exec brakeman --no-pager
```

## API エンドポイント

### ヘルスチェック
```
GET /api/health
```

レスポンス例：
```json
{
  "status": "ok",
  "message": "KokushiEX API is running!",
  "timestamp": "2024-08-24T12:34:56.789Z"
}
```

## 開発のポイント

### FactoryBot設定
テストでは `create`, `build` メソッドを直接使用可能：
```ruby
# spec/rails_helper.rb でinclude済み
config.include FactoryBot::Syntax::Methods
```

### CORS設定
フロントエンド（localhost:3000）からのAPI呼び出しに対応済み

### 環境変数
- `DATABASE_HOST`: データベースホスト名
- `RAILS_ENV`: 実行環境（development/test/production）

## ディレクトリ構成

```
backend/
├── app/
│   ├── controllers/api/    # APIコントローラー
│   └── models/            # ActiveRecordモデル
├── config/
│   ├── database.yml       # DB接続設定
│   └── routes.rb          # ルーティング設定
├── db/
│   ├── migrate/           # マイグレーションファイル
│   └── schema.rb          # データベーススキーマ
├── spec/
│   ├── factories/         # FactoryBot定義
│   ├── models/            # モデルテスト
│   └── rails_helper.rb    # RSpec設定
└── Dockerfile             # Docker設定
```