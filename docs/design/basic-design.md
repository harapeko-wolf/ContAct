# ContAct 基本設計書

## 1. システム構成

### 1.1 全体構成
```
[フロントエンド] ←→ [バックエンド] ←→ [データベース]
     ↑                    ↑
     └── [TimeRex] ←──────┘
```

### 1.2 コンポーネント構成
- フロントエンド（Next.js）
  - PDFビューア
  - トラッキングシステム
  - モーダル表示
  - 管理画面

- バックエンド（Laravel）
  - APIサーバー
  - ファイル管理
  - ログ管理
  - スコアリング

- データベース（MySQL）
  - 顧客情報
  - PDF情報
  - 閲覧ログ
  - 予約情報

## 2. データベース設計

### 2.1 テーブル構成
```sql
-- 顧客テーブル
CREATE TABLE customers (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- PDFテーブル
CREATE TABLE pdfs (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    path VARCHAR(255) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- 閲覧リンクテーブル
CREATE TABLE view_links (
    id UUID PRIMARY KEY,
    customer_id UUID,
    pdf_id UUID,
    uuid VARCHAR(255) NOT NULL,
    created_at TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (pdf_id) REFERENCES pdfs(id)
);

-- 閲覧ログテーブル
CREATE TABLE view_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    view_link_id UUID,
    page_number INT NOT NULL,
    viewed_at TIMESTAMP,
    duration_sec INT NOT NULL,
    FOREIGN KEY (view_link_id) REFERENCES view_links(id)
);

-- 予約テーブル
CREATE TABLE reservations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    view_link_id UUID,
    reserved_at TIMESTAMP,
    FOREIGN KEY (view_link_id) REFERENCES view_links(id)
);
```

### 2.2 インデックス設計
```sql
-- 顧客テーブル
CREATE INDEX idx_customers_email ON customers(email);

-- 閲覧リンクテーブル
CREATE INDEX idx_view_links_uuid ON view_links(uuid);
CREATE INDEX idx_view_links_customer ON view_links(customer_id);
CREATE INDEX idx_view_links_pdf ON view_links(pdf_id);

-- 閲覧ログテーブル
CREATE INDEX idx_view_logs_link ON view_logs(view_link_id);
CREATE INDEX idx_view_logs_viewed ON view_logs(viewed_at);

-- 予約テーブル
CREATE INDEX idx_reservations_link ON reservations(view_link_id);
```

## 3. API設計

### 3.1 エンドポイント一覧
```
GET    /api/customers           # 顧客一覧取得
POST   /api/customers           # 顧客登録
GET    /api/customers/{id}      # 顧客詳細取得
PUT    /api/customers/{id}      # 顧客情報更新
DELETE /api/customers/{id}      # 顧客削除

GET    /api/pdfs               # PDF一覧取得
POST   /api/pdfs               # PDFアップロード
GET    /api/pdfs/{id}          # PDF詳細取得
DELETE /api/pdfs/{id}          # PDF削除

GET    /api/view-links         # 閲覧リンク一覧取得
POST   /api/view-links         # 閲覧リンク生成
GET    /api/view-links/{uuid}  # 閲覧リンク詳細取得

POST   /api/view-logs         # 閲覧ログ記録
GET    /api/view-logs         # 閲覧ログ一覧取得

POST   /api/reservations      # 予約情報登録
GET    /api/reservations      # 予約情報一覧取得
```

### 3.2 リクエスト/レスポンス例
```json
// 顧客登録リクエスト
{
  "name": "株式会社サンプル",
  "email": "sample@example.com"
}

// 顧客登録レスポンス
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "株式会社サンプル",
  "email": "sample@example.com",
  "created_at": "2024-03-20T10:00:00Z"
}

// 閲覧ログ記録リクエスト
{
  "view_link_id": "550e8400-e29b-41d4-a716-446655440000",
  "page_number": 1,
  "duration_sec": 30
}
```

## 4. 画面設計

### 4.1 管理画面
- ダッシュボード
  - 顧客一覧
  - PDF一覧
  - 閲覧状況
  - 商談スコア

- 顧客管理
  - 顧客登録フォーム
  - 顧客一覧テーブル
  - 顧客詳細画面

- PDF管理
  - PDFアップロード
  - PDF一覧テーブル
  - PDF詳細画面

### 4.2 PDF閲覧画面
- PDF表示エリア
- ページナビゲーション
- 予約モーダル
- トラッキング情報

## 5. セキュリティ設計

### 5.1 認証・認可
- JWT認証の実装
- ロールベースのアクセス制御
- セッション管理

### 5.2 データ保護
- 顧客情報の暗号化
- PDFファイルのアクセス制御
- 閲覧ログの保護

### 5.3 セキュリティ対策
- CSRF対策
- XSS対策
- SQLインジェクション対策
- レート制限

## 6. パフォーマンス設計

### 6.1 キャッシュ戦略
- Redisによるセッション管理
- ページキャッシュ
- データベースクエリキャッシュ

### 6.2 最適化方針
- インデックス最適化
- クエリ最適化
- 画像最適化
- コード分割

## 7. 運用設計

### 7.1 監視設計
- エラーモニタリング
- パフォーマンスモニタリング
- アクセスログ監視

### 7.2 バックアップ設計
- データベースバックアップ
- ファイルバックアップ
- リストア手順

### 7.3 デプロイ設計
- CI/CDパイプライン
- 環境分離
- ロールバック手順 