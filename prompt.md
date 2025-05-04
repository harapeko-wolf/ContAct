確認事項があれば生成前に私に質問してください。

# 資料がダウンロードされても商談につながらないを解決！コンテンツ配信で資料請求リードを商談化するツール


温度感の低い見込み顧客の商談獲得サインを見逃さず  
商談化を実現するコンテンツ配信ツール

## 役割付与

　あなたは、WEBエンジニアです サービスの実装を行います
　チームにわかるように、ドキュメント化します
　ベストプラクティスを心掛ける
  

## タスク（＝ゴール）

- ユーザーフロント画面にて、PDFの閲覧状況 で、TimeRexに商談予約するよう促す（１スライド見たら..TimeRexのURLボタンを出す　or まだコンテンツを見る　など　選択させる　モーダルで）Google slide　など、は閲覧状況を取得できないため自前での実装になります PDF.jsなどベストプラクティスで　ログは、Laravel側にAPIで行います
- 管理画面フロント画面で　商談予約しなかったが、期待値が高い顧客を管理画面に表示する
- 要件定義 ドキュメント化
- 基本設計 ドキュメント化
- 詳細設計 ドキュメント化

### 🔧 主な機能

  

- **コンテンツ共有**

  - 営業資料、動画、事例などをまとめた提案ページを作成（PDFをスライドで表示）

  - URLで簡単に顧客へ共有可能（こちらが、会社名、メールアドレスを持っているので、知らない人が見られないようにUUIDで、リンクを生成する（知らない人に見られないようにしなければならない、正確な閲覧状況を取得できないため））

  

- **閲覧ログの可視化**

  - 閲覧者・閲覧時間・どこを見たかを詳細に記録（PDFスライドの閲覧状況を正確に記録できるといい　nページ をいつ　何秒みたか）

  - 顧客の関心度を可視化し、検討フェーズを把握（PDFを熟読していたり、何回も見直したりなど、期待値のスコア化）

  

- **フォロータイミングの最適化**

  - 「資料を読んだタイミング」で通知（管理画面に、表示）

  - 最適なタイミングで営業フォロー可能（管理画面に、表示）

  

- **多拠点・チーム利用**

  - 部門・営業チームごとにデータを分けて管理可能

  - 権限管理機能あり




## 前提情報

-  **バックエンド**: Laravel 12 + PHP 8.4

-  **フロントエンド**: Next.js 15 + TypeScript

-  **インフラ**: Docker Compose, AWS (Terraform + Ansible)

-  **監視/運用**: Sentry

-  **ダークモード**: 対応しません

- **Dockerfile**: Dockerfileの管理はdockerフォルダで行う backend frontendなどでフォルダ分け ベストプラクティスでフォルダ分けしてください



## フォルダ構成

必要なものはさらに追加

```text

/

├── backend/ # Laravelアプリケーション

├── frontend/ # Next.jsアプリケーション

├── docker/ # Dockerfile／nginx／MySQL設定

├── .github/ # GitHub Actionsワークフロー

├── docs/ # ドキュメント

│ ├── architecture.md # アーキテクチャ図

│ ├── api/ # OpenAPI spec

│ └── adr/ # 設計決定記録

├── run-tests.sh # ローカル一括テスト・Lintスクリプト

└── README.md

```

  

## 前提条件

- MacOS (Docker Desktopインストール済)

- Docker / Docker Compose

- Git

- Node.js (v21 推奨) / npm

-  **Docker コンテナ実行**: `docker compose up frontend` で Next.js が動作するため、ホストに Node.js をインストールする必要はありません。

-  **ローカル開発（ホストマシン上で直接実行する場合）**: コンテナを使わずに `npm run dev` などを実行する際にのみ、ホストマシンに Node.js と npm が必要です。

- PHP: ホストへのインストール不要（Laravel は Docker 内で動作します）

* 全てDockerで行なってください！

  

## ローカル開発環境のセットアップ

1. リポジトリをクローン

```bash

git clone git@github.com:<your-org>/ContAct.git

cd ContAct

```

2. コンテナを起動

```bash

docker compose up -d

```

3. 初期設定

```bash

docker compose exec backend php artisan key:generate

docker compose exec backend php artisan migrate

docker compose exec frontend npm ci

```

  

## 実行方法

-  **Laravel**: http://localhost:9000

-  **Next.js**: http://localhost:3000

  

## テスト

-  **ローカルで一括テスト／Lint**

```bash

./run-tests.sh

```

-  **個別コマンド**

```bash

docker compose exec backend php artisan test

docker compose exec frontend npm run lint

```

  

## CI/CD

- GitHub Actions を利用

-  `main` への Push/PR で `test-backend` + `test-frontend` ジョブが実行

-  **README.md や docs/** のみの変更は `paths-ignore` 設定により CI スキップ

- リリース時はタグ付けで ECS デプロイ自動化予定

  

## 開発フロー

### 1. 開発環境のセットアップ

#### 1.1 リポジトリのクローン
```bash
git clone git@github.com:<your-org>/ContAct.git
cd ContAct
```

#### 1.2 Docker環境の構築
```bash
# 初回セットアップ
docker compose build

# コンテナの起動
docker compose up -d

# コンテナの状態確認
docker compose ps
```

#### 1.3 バックエンド環境のセットアップ
```bash
# Laravelの依存関係インストール
docker compose exec backend composer install

# 環境変数の設定
cp backend/.env.example backend/.env

# アプリケーションキーの生成
docker compose exec backend php artisan key:generate

# データベースのマイグレーション
docker compose exec backend php artisan migrate

# テストデータの投入（必要な場合）
docker compose exec backend php artisan db:seed
```

#### 1.4 フロントエンド環境のセットアップ
```bash
# Node.jsの依存関係インストール
docker compose exec frontend npm install

# 環境変数の設定
cp frontend/.env.example frontend/.env
```

### 2. 開発サイクル

#### 2.1 ブランチ戦略
- メインブランチ: `main`
- 開発ブランチ: `develop`
- 機能ブランチ: `feature/*`
- ホットフィックス: `hotfix/*`
- リリースブランチ: `release/*`

#### 2.2 新機能開発の流れ
1. 開発ブランチの作成
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

2. 開発作業
```bash
# バックエンドの開発サーバー起動（必要な場合）
docker compose exec backend php artisan serve

# フロントエンドの開発サーバー起動（必要な場合）
docker compose exec frontend npm run dev
```

3. テストの実行
```bash
# バックエンドテスト
docker compose exec backend php artisan test

# フロントエンドテスト
docker compose exec frontend npm run test

# 全テストの実行
./run-tests.sh
```

4. コードのコミット
```bash
git add .
git commit -m "feat: 機能の説明"
```

5. プッシュとプルリクエスト
```bash
git push origin feature/your-feature-name
```

### 3. コードレビュー

1. プルリクエストの作成
   - タイトル: 変更内容を簡潔に
   - 説明: 変更内容の詳細、テスト結果、スクリーンショット（UI変更の場合）

2. レビュー項目
   - コードの品質
   - テストの網羅性
   - セキュリティチェック
   - パフォーマンスへの影響

### 4. デプロイフロー

#### 4.1 ステージング環境へのデプロイ
```bash
# ステージングブランチへのマージ
git checkout staging
git merge develop
git push origin staging
```

#### 4.2 本番環境へのデプロイ
```bash
# 本番ブランチへのマージ
git checkout main
git merge staging
git tag v1.0.0
git push origin main --tags
```

### 5. トラブルシューティング

#### 5.1 一般的な問題解決
```bash
# コンテナの再起動
docker compose restart

# ログの確認
docker compose logs -f

# キャッシュのクリア
docker compose exec backend php artisan cache:clear
docker compose exec frontend npm run clean
```

#### 5.2 データベース関連
```bash
# マイグレーションのリセット
docker compose exec backend php artisan migrate:reset
docker compose exec backend php artisan migrate

# テストデータの再投入
docker compose exec backend php artisan db:seed
```

### 6. チーム開発のベストプラクティス

1. コミットメッセージの規約
   - feat: 新機能
   - fix: バグ修正
   - docs: ドキュメント
   - style: フォーマット
   - refactor: リファクタリング
   - test: テスト
   - chore: ビルドプロセス

2. コードレビューのガイドライン
   - 1日以内のレビュー対応
   - 建設的なフィードバック
   - セキュリティとパフォーマンスの確認

3. ドキュメントの更新
   - コード変更に伴うドキュメント更新
   - API仕様の更新
   - データベーススキーマの更新

## ドキュメント

-  `docs/architecture.md`: システム全体のアーキテクチャ図

-  `docs/api/openapi.yaml`: API 仕様 (OpenAPI)

-  `docs/adr/`: Architecture Decision Records (設計判断記録)

-  `docs/contributing.md`: コントリビュートガイドライン



確認事項があれば生成前に私に質問してください。

## データベース仕様

- **MySQL**: 8.4（最新版）
- **文字コード**: utf8mb4
- **照合順序**: utf8mb4_unicode_ci
- **バックアップ**: 日次フルバックアップ + 1時間ごとの増分バックアップ
- **レプリケーション**: マスター-スレーブ構成（読み取り負荷分散）

## セキュリティ要件

- **認証・認可**
  - JWT認証の実装
  - ロールベースのアクセス制御（RBAC）
  - セッション管理の適切な実装

- **セキュリティ対策**
  - CSRF対策の実装
  - XSS対策の実装
  - SQLインジェクション対策
  - レート制限の実装
  - 入力値の厳密なバリデーション

- **ファイルセキュリティ**
  - セキュアなファイルアップロード処理
  - ファイルタイプの検証
  - ファイルサイズ制限
  - マルウェアスキャン

## パフォーマンス要件

- **データベース**
  - インデックス最適化
  - クエリパフォーマンスの監視
  - スロークエリログの分析

- **キャッシュ戦略**
  - Redisによるセッション管理
  - ページキャッシュ
  - データベースクエリキャッシュ

- **フロントエンド最適化**
  - 画像の最適化と遅延読み込み
  - コード分割
  - バンドルサイズの最適化
  - コンポーネントの遅延読み込み

## 監視・運用要件

- **エラーモニタリング**
  - Sentryによるエラー追跡
  - エラーログの収集と分析
  - アラート設定

- **パフォーマンスモニタリング**
  - レスポンスタイムの監視
  - リソース使用率の監視
  - スロークエリの検出

- **アクセスログ**
  - ユーザーアクティビティの記録
  - セキュリティイベントの記録
  - アクセス統計の分析

## バックアップ・ディザスタリカバリ

- **バックアップ戦略**
  - データベースの定期的なバックアップ
  - ファイルシステムのバックアップ
  - バックアップの暗号化
  - オフサイトバックアップ

- **リストア手順**
  - データベースリストア手順の文書化
  - ファイルシステムリストア手順の文書化
  - 障害復旧手順の文書化