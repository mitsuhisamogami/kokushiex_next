# KokushiEX Next

理学療法士国家試験対策アプリケーション - モダンなWeb技術で構築された学習プラットフォーム

## 概要

KokushiEX Nextは、理学療法士国家試験の効率的な学習をサポートするWebアプリケーションです。最新のWeb技術とマイクロサービスアーキテクチャを採用し、高いパフォーマンスと開発体験を提供します。

## 技術スタック

### フロントエンド
- **Next.js 15.3.3** (App Router)
- **React 19** 
- **TypeScript**
- **Tailwind CSS 4**
- **Node.js 22.15.0**

### バックエンド
- **Rails 7.2** (API モード)
- **Ruby 3.3.6**
- **PostgreSQL 16**

### インフラ
- **Docker & Docker Compose**
- **専用Dockerネットワークでの連携**

## セットアップ

### 前提条件
- Docker Desktop
- Node.js 22.15.0 (ローカル開発用)

### 起動手順

1. **リポジトリをクローン**
   ```bash
   git clone <repository-url>
   cd kokushiex-next
   ```

2. **全サービスを起動**
   ```bash
   docker-compose up -d
   ```

3. **データベースのセットアップ（初回のみ）**
   ```bash
   docker-compose exec backend rails db:create
   docker-compose exec backend rails db:migrate
   docker-compose exec backend rails db:seed
   ```

4. **アプリケーションにアクセス**
   - フロントエンド: http://localhost:3000
   - バックエンドAPI: http://localhost:3001
   - データベース: localhost:5432

## 開発コマンド

### Docker操作
```bash
# 全サービス起動
docker-compose up -d

# 特定サービスのみ起動
docker-compose up -d frontend
docker-compose up -d backend

# ログ確認
docker-compose logs frontend
docker-compose logs backend

# サービス停止
docker-compose down
```

### フロントエンド開発
```bash
# 開発サーバー起動（Turbopack使用）
docker-compose exec frontend npm run dev

# ビルド
docker-compose exec frontend npm run build

# リント
docker-compose exec frontend npm run lint
```

### バックエンド開発
```bash
# Railsコンソール
docker-compose exec backend rails console

# マイグレーション
docker-compose exec backend rails db:migrate

# テスト実行
docker-compose exec backend bundle exec rspec

# コード品質チェック
docker-compose exec backend bundle exec rubocop
docker-compose exec backend bundle exec brakeman
```

## アーキテクチャ

### サービス構成
- **frontend**: Next.jsアプリケーション (ポート3000)
- **backend**: Rails APIサーバー (ポート3001)
- **db**: PostgreSQLデータベース (ポート5432)

### API通信
- フロントエンドの`/api/*`リクエストは自動的にバックエンドにプロキシされます
- Next.jsの`rewrites`機能により、`http://backend:3000/api/*`にルーティング
- CORS設定済みで、クロスオリジン通信に対応

### データベース接続
- 開発環境では`DATABASE_HOST=db`でDocker内のPostgreSQLに接続
- ローカル開発時は`DATABASE_HOST=localhost`に切り替え可能

## API接続テスト

フロントエンドには API 接続をテストできる機能が組み込まれています：
- http://localhost:3000 にアクセス
- 「APIテスト実行」ボタンをクリック
- `/api/health`エンドポイントでバックエンドとの接続を確認

## ディレクトリ構成

```
kokushiex-next/
├── docker-compose.yml      # サービス編成設定
├── frontend/               # Next.jsアプリケーション
│   ├── app/               # App Routerディレクトリ
│   ├── components/        # Reactコンポーネント
│   ├── Dockerfile         # フロントエンド用Docker設定
│   └── next.config.ts     # Next.js設定（APIプロキシ含む）
├── backend/               # Railsアプリケーション
│   ├── app/              # Railsアプリケーション本体
│   ├── config/           # Rails設定ファイル
│   └── Dockerfile        # バックエンド用Docker設定
└── CLAUDE.md             # 開発者向けガイド
```

## 開発のポイント

- **ホットリロード対応**: ソースコード変更時の自動反映
- **型安全性**: TypeScriptによる静的型チェック
- **コード品質**: ESLint, RuboCop, Brakemanによる自動検査
- **API設計**: RESTful APIとJSON形式でのデータ交換

## トラブルシューティング

### よくある問題

1. **ポートが使用中の場合**
   ```bash
   docker-compose down
   # 他のプロセスがポートを使用していないか確認
   lsof -i :3000 -i :3001 -i :5432
   ```

2. **データベース接続エラー**
   ```bash
   # データベースコンテナの再起動
   docker-compose restart db
   # データベースの再作成
   docker-compose exec backend rails db:drop db:create db:migrate
   ```

3. **Node.js版数エラー**
   ```bash
   # .node-versionファイルの確認
   cat .node-version
   # Dockerイメージの再構築
   docker-compose build --no-cache frontend
   ```
