# Q-App 技術設計書

## システムアーキテクチャ

### 全体構成
```
[フロントエンド]     [バックエンド]      [データベース]
Vue.js 3.x    <--> FastAPI        <--> MySQL 8.0
(SPA)              (RESTful API)       (RDS)
  |                     |                 |
  |                     |                 |
[AWS CloudFront]   [AWS EC2/ECS]    [AWS RDS]
[S3 (静的ファイル)] [ALB]            [バックアップ]
```

### 技術スタック詳細
- **フロントエンド**: Vue.js 3.x + Composition API + TypeScript
- **CSS フレームワーク**: Tailwind CSS
- **状態管理**: Pinia
- **ルーティング**: Vue Router 4
- **HTTP クライアント**: Axios
- **バックエンド**: FastAPI + Python 3.11
- **ORM**: SQLAlchemy 2.0
- **認証**: JWT (JSON Web Token)
- **データベース**: MySQL 8.0
- **ファイルストレージ**: AWS S3
- **メール送信**: AWS SES
- **デプロイ**: AWS (EC2/ECS + RDS + CloudFront + S3)

## データベース設計

### ER図概要
```
Users (1) ----< (M) Posts (1) ----< (M) Threads
  |                   |
  |                   |
  +----< (M) Events   +----< (M) PostLikes
```

### テーブル定義

#### users テーブル
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    faculty ENUM('文学部', '教育学部', '法学部', '経済学部', '理学部', '医学部', '歯学部', '薬学部', '工学部', '芸術工学部', '農学部', '共創学部') NOT NULL,
    grade TINYINT NOT NULL CHECK (grade BETWEEN 1 AND 4),
    circle VARCHAR(100),
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_faculty (faculty)
);
```

#### posts テーブル
```sql
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category ENUM('授業', 'アルバイト', 'サークル', '雑談') NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    like_count INT DEFAULT 0,
    thread_count INT DEFAULT 0,
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_category (category),
    INDEX idx_created_at (created_at),
    INDEX idx_user_id (user_id),
    CONSTRAINT chk_content_length CHECK (CHAR_LENGTH(content) <= 140)
);
```

#### threads テーブル
```sql
CREATE TABLE threads (
    thread_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    parent_thread_id INT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    depth_level INT DEFAULT 0,
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_thread_id) REFERENCES threads(thread_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_parent_thread_id (parent_thread_id),
    INDEX idx_created_at (created_at),
    CONSTRAINT chk_thread_content_length CHECK (CHAR_LENGTH(content) <= 500)
);
```

#### post_likes テーブル
```sql
CREATE TABLE post_likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_post_like (post_id, user_id)
);
```

#### thread_likes テーブル
```sql
CREATE TABLE thread_likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    thread_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (thread_id) REFERENCES threads(thread_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_thread_like (thread_id, user_id)
);
```

#### events テーブル
```sql
CREATE TABLE events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    event_datetime DATETIME NOT NULL,
    location VARCHAR(200),
    external_url VARCHAR(500),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_category (category),
    INDEX idx_event_datetime (event_datetime),
    INDEX idx_created_at (created_at)
);
```

#### email_verifications テーブル
```sql
CREATE TABLE email_verifications (
    verification_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    verification_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_expires_at (expires_at)
);
```

## API 設計

### 認証関連 API

#### POST /api/auth/send-verification
メール認証コード送信
```json
Request:
{
    "email": "user@s.kyushu-u.ac.jp"
}

Response:
{
    "message": "認証コードを送信しました",
    "expires_in": 300
}
```

#### POST /api/auth/verify-email
メール認証
```json
Request:
{
    "email": "user@s.kyushu-u.ac.jp",
    "verification_code": "123456"
}

Response:
{
    "message": "メール認証が完了しました",
    "temp_token": "temp_jwt_token"
}
```

#### POST /api/auth/register
ユーザー登録
```json
Request:
{
    "temp_token": "temp_jwt_token",
    "username": "user123",
    "password": "password123",
    "display_name": "太郎",
    "faculty": "工学部",
    "grade": 3,
    "circle": "テニス部"
}

Response:
{
    "access_token": "jwt_access_token",
    "refresh_token": "jwt_refresh_token",
    "user": {
        "user_id": 1,
        "username": "user123",
        "display_name": "太郎",
        "faculty": "工学部",
        "grade": 3,
        "circle": "テニス部"
    }
}
```

#### POST /api/auth/login
ログイン
```json
Request:
{
    "username": "user123",
    "password": "password123"
}

Response:
{
    "access_token": "jwt_access_token",
    "refresh_token": "jwt_refresh_token",
    "user": {user_info}
}
```

### 投稿関連 API

#### GET /api/posts
投稿一覧取得
```json
Query Parameters:
- category: string (optional)
- page: int (default: 1)
- limit: int (default: 20)
- sort: string (default: "created_at")

Response:
{
    "posts": [
        {
            "post_id": 1,
            "user_id": 1,
            "display_name": "太郎",
            "category": "授業",
            "content": "線形代数の授業について",
            "image_url": "https://...",
            "like_count": 5,
            "thread_count": 3,
            "is_anonymous": false,
            "created_at": "2024-01-01T00:00:00Z"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 20,
        "total": 100,
        "has_next": true
    }
}
```

#### POST /api/posts
投稿作成
```json
Request:
{
    "category": "授業",
    "content": "線形代数の授業について",
    "image": "base64_encoded_image_data",
    "is_anonymous": false
}

Response:
{
    "post_id": 1,
    "message": "投稿が作成されました"
}
```

#### GET /api/posts/{post_id}/threads
スレッド一覧取得
```json
Response:
{
    "threads": [
        {
            "thread_id": 1,
            "post_id": 1,
            "parent_thread_id": null,
            "user_id": 2,
            "display_name": "花子",
            "content": "その授業取りました！",
            "like_count": 2,
            "depth_level": 0,
            "is_anonymous": false,
            "created_at": "2024-01-01T01:00:00Z",
            "children": [
                {
                    "thread_id": 2,
                    "parent_thread_id": 1,
                    "content": "どうでしたか？",
                    "depth_level": 1,
                    ...
                }
            ]
        }
    ]
}
```

#### POST /api/posts/{post_id}/threads
スレッド作成
```json
Request:
{
    "content": "その授業取りました！",
    "parent_thread_id": null,
    "is_anonymous": false
}

Response:
{
    "thread_id": 1,
    "message": "返信が作成されました"
}
```

#### POST /api/posts/{post_id}/like
投稿いいね
```json
Response:
{
    "message": "いいねしました",
    "like_count": 6
}
```

### イベント関連 API

#### GET /api/events
イベント一覧取得
```json
Query Parameters:
- category: string (optional)
- date_from: string (optional)
- date_to: string (optional)
- page: int (default: 1)
- limit: int (default: 20)

Response:
{
    "events": [
        {
            "event_id": 1,
            "user_id": 1,
            "display_name": "太郎",
            "title": "テニス部新歓",
            "description": "新入生歓迎会です",
            "category": "新歓",
            "event_datetime": "2024-04-15T18:00:00Z",
            "location": "体育館",
            "external_url": "https://forms.google.com/...",
            "image_url": "https://...",
            "created_at": "2024-01-01T00:00:00Z"
        }
    ],
    "pagination": {pagination_info}
}
```

#### POST /api/events
イベント作成
```json
Request:
{
    "title": "テニス部新歓",
    "description": "新入生歓迎会です",
    "category": "新歓",
    "event_datetime": "2024-04-15T18:00:00Z",
    "location": "体育館",
    "external_url": "https://forms.google.com/...",
    "image": "base64_encoded_image_data"
}

Response:
{
    "event_id": 1,
    "message": "イベントが作成されました"
}
```

## フロントエンド設計

### 画面遷移図
```
/                  (ランディングページ)
├── /login         (ログイン)
├── /register      (ユーザー登録)
├── /dashboard     (ダッシュボード)
├── /posts         (投稿一覧)
│   ├── /posts/:id (投稿詳細)
│   └── /posts/new (新規投稿)
├── /events        (イベント一覧)
│   ├── /events/:id (イベント詳細)
│   └── /events/new (新規イベント)
├── /map           (キャンパスマップ)
└── /profile       (プロフィール)
```

### コンポーネント設計

#### 共通コンポーネント
- `AppHeader.vue` - ヘッダー
- `AppNavigation.vue` - ナビゲーション
- `AppFooter.vue` - フッター
- `LoadingSpinner.vue` - ローディング表示
- `ErrorMessage.vue` - エラーメッセージ
- `SuccessMessage.vue` - 成功メッセージ

#### 認証コンポーネント
- `LoginForm.vue` - ログインフォーム
- `RegisterForm.vue` - 登録フォーム
- `EmailVerification.vue` - メール認証

#### 投稿コンポーネント
- `PostList.vue` - 投稿一覧
- `PostItem.vue` - 投稿アイテム
- `PostDetail.vue` - 投稿詳細
- `PostForm.vue` - 投稿フォーム
- `ThreadList.vue` - スレッド一覧
- `ThreadItem.vue` - スレッドアイテム
- `ThreadForm.vue` - スレッドフォーム

#### イベントコンポーネント
- `EventList.vue` - イベント一覧
- `EventItem.vue` - イベントアイテム
- `EventDetail.vue` - イベント詳細
- `EventForm.vue` - イベントフォーム

#### その他コンポーネント
- `CampusMap.vue` - キャンパスマップ
- `UserProfile.vue` - ユーザープロフィール

### 状態管理設計 (Pinia)

#### auth.js
```javascript
export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    accessToken: null,
    refreshToken: null,
    isAuthenticated: false
  }),
  
  actions: {
    async login(credentials),
    async register(userData),
    async logout(),
    async refreshAccessToken(),
    async sendVerificationCode(email),
    async verifyEmail(email, code)
  }
})
```

#### posts.js
```javascript
export const usePostsStore = defineStore('posts', {
  state: () => ({
    posts: [],
    currentPost: null,
    threads: [],
    categories: ['授業', 'アルバイト', 'サークル', '雑談'],
    pagination: {}
  }),
  
  actions: {
    async fetchPosts(params),
    async createPost(postData),
    async fetchPost(postId),
    async fetchThreads(postId),
    async createThread(threadData),
    async likePost(postId),
    async likeThread(threadId)
  }
})
```

#### events.js
```javascript
export const useEventsStore = defineStore('events', {
  state: () => ({
    events: [],
    currentEvent: null,
    categories: [],
    pagination: {}
  }),
  
  actions: {
    async fetchEvents(params),
    async createEvent(eventData),
    async fetchEvent(eventId),
    async fetchCategories()
  }
})
```

## セキュリティ設計

### 認証・認可
- JWT トークンによる認証
- Access Token (1日) + Refresh Token (7日) 方式
- 大学メールアドレスによる学生認証
- パスワードハッシュ化 (bcrypt)

### セキュリティ対策
- CORS 設定
- SQL インジェクション対策 (SQLAlchemy ORM)
- XSS 対策 (入力値エスケープ)
- CSRF 対策 (SameSite Cookie)
- レート制限 (API 呼び出し制限)
- 画像アップロード制限 (サイズ・形式・内容チェック)

### データ保護
- HTTPS 通信必須
- 機密情報の環境変数管理
- データベース暗号化
- ログの個人情報マスキング

## 開発・デプロイ環境

### 開発環境
```
Frontend:
- Node.js 18.x
- Vue.js 3.x
- Vite (開発サーバー)
- npm / yarn

Backend:
- Python 3.11
- FastAPI
- uvicorn (開発サーバー)
- Poetry (依存関係管理)

Database:
- MySQL 8.0 (Docker)
- phpMyAdmin (開発用)
```

### 本番環境 (AWS)
```
Frontend:
- AWS S3 (静的ファイル配信)
- AWS CloudFront (CDN)

Backend:
- AWS ECS (コンテナオーケストレーション)
- AWS ALB (ロードバランサー)
- AWS EC2 (バックアップ用)

Database:
- AWS RDS (MySQL)
- AWS RDS バックアップ

Other:
- AWS SES (メール送信)
- AWS Route 53 (DNS)
- AWS Certificate Manager (SSL/TLS)
```

### CI/CD パイプライン
```
GitHub Actions:
1. コードプッシュ
2. テスト実行
3. ビルド
4. AWS デプロイ
5. ヘルスチェック
```

## 実装スケジュール (7日間)

### Day 1: 環境構築・基盤実装
- [ ] プロジェクト初期化
- [ ] Docker 環境構築
- [ ] データベース設計・構築
- [ ] 認証システム基盤実装

### Day 2: 認証機能実装
- [ ] メール認証 API
- [ ] ユーザー登録 API
- [ ] ログイン・ログアウト API
- [ ] JWT トークン管理

### Day 3: 投稿機能実装 (バックエンド)
- [ ] 投稿 CRUD API
- [ ] スレッド機能 API
- [ ] いいね機能 API
- [ ] 画像アップロード機能

### Day 4: 投稿機能実装 (フロントエンド)
- [ ] 投稿一覧画面
- [ ] 投稿詳細画面
- [ ] 投稿作成画面
- [ ] スレッド表示・作成機能

### Day 5: イベント機能実装
- [ ] イベント CRUD API
- [ ] イベント一覧画面
- [ ] イベント作成画面
- [ ] イベント詳細画面

### Day 6: 追加機能・マップ機能
- [ ] キャンパスマップ実装
- [ ] ユーザープロフィール機能
- [ ] 各種フィルタ・検索機能

### Day 7: 統合テスト・デプロイ
- [ ] 統合テスト
- [ ] バグ修正
- [ ] AWS デプロイ
- [ ] 本番環境テスト

## パフォーマンス最適化

### データベース最適化
- 適切なインデックス設定
- クエリ最適化
- コネクションプーリング

### フロントエンド最適化
- 画像遅延読み込み
- コンポーネント遅延読み込み
- バンドルサイズ最適化

### キャッシュ戦略
- Redis キャッシュ (将来的)
- ブラウザキャッシュ
- CDN キャッシュ

## 監視・ログ

### ログ管理
- アプリケーションログ
- アクセスログ
- エラーログ
- セキュリティログ

### 監視項目
- API レスポンス時間
- データベース接続数
- エラー発生率
- ユーザー数