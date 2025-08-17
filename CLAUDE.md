# CLAUDE.md

このファイルは、このリポジトリのコードを扱う際のClaude Code (claude.ai/code) への指針を提供します。

## プロジェクト概要

KokushiEX Nextは、日本の理学療法士国家試験対策のための最新のWebアプリケーションで、フロントエンドとバックエンドサービスを分離したDockerコンテナ化されたマイクロサービスアーキテクチャとして構築されています。

## アーキテクチャ

**マルチサービスDockerセットアップ:**
- **フロントエンド**: Next.js 15.3.3、React 19、TypeScript、Tailwind CSS 4
- **バックエンド**: Rails 7.2 APIオンリーアプリケーション、Ruby 3.3.6
- **データベース**: PostgreSQL 16

**サービス間通信:**
- フロントエンドはポート3000、バックエンドはポート3001（コンテナポート3000からマッピング）で動作
- Next.jsはDockerネットワーク経由で `/api/*` リクエストを `http://backend:3000/api/*` にリライト
- ローカル開発用にlocalhost:5432でデータベースにアクセス可能

## 開発コマンド

### Docker操作
```bash
# 全サービスを起動
docker-compose up -d

# 特定のサービスを起動
docker-compose up -d frontend
docker-compose up -d backend

# 変更後にサービスを再ビルド
docker-compose build frontend
docker-compose build backend

# ログを表示
docker-compose logs frontend
docker-compose logs backend
docker-compose logs db

# 全サービスを停止
docker-compose down
```

### フロントエンド (Next.js)
```bash
# frontend/ディレクトリ内またはDocker経由
npm run dev          # Turbopackで開発サーバーを起動
npm run build        # プロダクションビルド
npm run start        # プロダクションサーバーを起動
npm run lint         # ESLintを実行
```

### バックエンド (Rails)
```bash
# Docker経由（推奨）
docker-compose exec backend rails console
docker-compose exec backend rails db:migrate
docker-compose exec backend rails db:seed
docker-compose exec backend bundle exec rspec

# データベース操作
docker-compose exec backend rails db:create
docker-compose exec backend rails db:reset
```

### リンティングと品質管理
```bash
# フロントエンド
docker-compose exec frontend npm run lint

# バックエンド
docker-compose exec backend bundle exec rubocop
docker-compose exec backend bundle exec brakeman
```

## 主要な設定

**APIルーティング**: Next.jsはDockerネットワーキングを通じて `/api/*` リクエストをRailsバックエンドに自動的にプロキシします。バックエンドは `/api/` 名前空間下でAPIエンドポイントを公開します。

**データベース**: 環境変数 `DATABASE_HOST` を使用して `localhost`（ローカル）と `db`（Docker）を切り替えます。接続は `backend/config/database.yml` で設定されています。

**Node.jsバージョン**: `.node-version`、`package.json` engines、DockerイメージにわたってNode.js 22.15.0に固定されています。

**環境変数**:
- `NEXT_PUBLIC_API_URL`: フロントエンドAPIベースURL 
- `DATABASE_HOST`: データベースホスト名（Dockerでは `db` に設定）
- `RAILS_ENV`: Rails環境モード

## API統合のテスト

`frontend/components/api-test.tsx` にテストコンポーネントが存在し、`/api/health` エンドポイント経由でフロントエンド・バックエンド間の接続を確認できます。

## 重要なファイル

- `docker-compose.yml`: サービスオーケストレーションとネットワーキング
- `frontend/next.config.ts`: APIプロキシ設定と画像処理
- `backend/config/database.yml`: データベース接続設定
- `backend/config/routes.rb`: APIルート定義
- `.node-version`: Node.jsバージョン指定

## 開発ルール

### ブランチ戦略
- **必須**: 新機能や修正を実装する際は、必ず`feature/`ブランチを作成すること
- ブランチ名の例: `feature/issue-番号-機能名` (例: `feature/issue-123-user-authentication`)
- mainブランチへの直接プッシュは禁止

### コード品質チェック（必須）
コードの変更または新規実装後は、以下のチェックを必ず実行すること：

#### フロントエンド
```bash
# リントチェック
docker-compose exec frontend npm run lint

# 型チェック
docker-compose exec frontend npm run type-check
```

#### バックエンド
```bash
# リントチェック
docker-compose exec backend bundle exec rubocop

# セキュリティチェック
docker-compose exec backend bundle exec brakeman

# テストの実行
docker-compose exec backend bundle exec rspec
```

### テスト作成（必須）
- **バックエンド**: 新機能やメソッドには必ず単体テストを作成すること
  - モデル、コントローラー、サービスオブジェクトすべてにテストを実装
  - カバレッジ80%以上を維持
- **フロントエンド**: 重要なビジネスロジックやユーティリティ関数にはテストを作成

### コミットメッセージ規約
```
<type>(<scope>): <subject>
```

**形式の詳細：**
- `type`: 変更の種類（必須）
- `scope`: 変更の影響範囲（オプション）
- `subject`: 変更内容の簡潔な説明（必須、現在形、小文字始まり、句点なし）

**タイプ：**
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（空白、フォーマット等）
- `refactor`: バグ修正や機能追加を伴わないコード変更
- `test`: テストの追加や修正
- `chore`: ビルドプロセスやツールの変更
- `perf`: パフォーマンス改善
- `ci`: CI関連の変更

**スコープの例：**
- `auth`: 認証関連
- `api`: API関連
- `db`: データベース関連
- `ui`: UI/UXコンポーネント
- `deps`: 依存関係
- `config`: 設定ファイル

**コミットメッセージの例：**
```
feat(auth): ユーザーログイン機能を追加
fix(api): レスポンスヘッダーのCORS設定を修正
docs(readme): インストール手順を更新
refactor(ui): ボタンコンポーネントを再構成
test(auth): ログイン失敗時のテストケースを追加
chore(deps): next.jsを15.3.3にアップデート
```

### コードレビュー
- プルリクエストは最低1名のレビューが必要
- CIのすべてのチェックがグリーンになってからマージ
- 大きな変更は小さなPRに分割すること

### その他のベストプラクティス
- **環境変数**: 秘密情報は絶対にコミットしない。`.env.example`を更新
- **依存関係**: パッケージを追加する際は、必要性を説明すること
- **パフォーマンス**: N+1問題に注意（Rails）、不要な再レンダリングを避ける（React）
- **エラーハンドリング**: 適切なエラー処理とログ出力を実装
- **ドキュメント**: APIエンドポイントや複雑なロジックにはコメントを追加