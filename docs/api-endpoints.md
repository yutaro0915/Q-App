# Q-App API エンドポイント仕様書

## 基本情報

- **Base URL**: `http://localhost:8005/api`
- **認証方式**: JWT Bearer Token
- **Content-Type**: `application/json`
- **日時形式**: ISO 8601 (例: `2025-01-07T10:00:00Z`)

## 認証ヘッダー

```
Authorization: Bearer <jwt_token>
```

## エラーレスポンス形式

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "エラーの説明",
    "details": {} // オプション
  }
}
```

## エンドポイント一覧

### 認証 (Authentication)

#### メール認証コード送信
```http
POST /api/auth/send-verification
```
**Body:**
```json
{
  "email": "user@s.kyushu-u.ac.jp"
}
```
**Response:** `200 OK`
```json
{
  "message": "認証コードを送信しました",
  "expiresIn": 300
}
```

#### メール認証確認
```http
POST /api/auth/verify-email
```
**Body:**
```json
{
  "email": "user@s.kyushu-u.ac.jp",
  "verificationCode": "123456"
}
```
**Response:** `200 OK`
```json
{
  "message": "メール認証が完了しました",
  "tempToken": "temp_jwt_token"
}
```

#### ユーザー登録
```http
POST /api/auth/register
```
**Body:**
```json
{
  "tempToken": "temp_jwt_token",
  "username": "user123",
  "password": "SecurePass123!",
  "displayName": "山田太郎",
  "faculty": "ENGINEERING",
  "grade": 3,
  "circle": "テニス部"
}
```
**Response:** `201 Created`
```json
{
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "user": {
    "userId": 1,
    "username": "user123",
    "displayName": "山田太郎",
    "faculty": "ENGINEERING",
    "grade": 3,
    "circle": "テニス部"
  }
}
```

#### ログイン
```http
POST /api/auth/login
```
**Body:**
```json
{
  "username": "user123",
  "password": "SecurePass123!"
}
```
**Response:** `200 OK`
```json
{
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "user": { /* user object */ }
}
```

#### トークンリフレッシュ
```http
POST /api/auth/refresh
```
**Body:**
```json
{
  "refreshToken": "jwt_refresh_token"
}
```
**Response:** `200 OK`
```json
{
  "accessToken": "new_jwt_access_token",
  "refreshToken": "new_jwt_refresh_token"
}
```

#### ログアウト
```http
POST /api/auth/logout
Authorization: Bearer <token>
```
**Response:** `200 OK`
```json
{
  "message": "ログアウトしました"
}
```

### 投稿 (Posts)

#### 投稿一覧取得
```http
GET /api/posts?category=CLASS&page=1&limit=20&sort=createdAt
```
**Query Parameters:**
- `category`: `CLASS` | `PART_TIME` | `CLUB` | `CHAT` (optional)
- `page`: ページ番号 (default: 1)
- `limit`: 1ページあたりの件数 (default: 20, max: 100)
- `sort`: `createdAt` | `likeCount` (default: createdAt)

**Response:** `200 OK`
```json
{
  "posts": [
    {
      "postId": 1,
      "userId": 1,
      "displayName": "山田太郎",
      "category": "CLASS",
      "content": "線形代数の授業について...",
      "imageUrl": "https://...",
      "likeCount": 5,
      "threadCount": 3,
      "isAnonymous": false,
      "isLiked": true,
      "createdAt": "2025-01-07T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5,
    "hasNext": true,
    "hasPrev": false
  }
}
```

#### 投稿作成
```http
POST /api/posts
Authorization: Bearer <token>
```
**Body:**
```json
{
  "category": "CLASS",
  "content": "線形代数の授業について質問があります",
  "imageBase64": "data:image/jpeg;base64,...", // optional
  "isAnonymous": false
}
```
**Response:** `201 Created`
```json
{
  "postId": 1,
  "message": "投稿が作成されました"
}
```

#### 投稿詳細取得
```http
GET /api/posts/:postId
```
**Response:** `200 OK`
```json
{
  "postId": 1,
  "userId": 1,
  "displayName": "山田太郎",
  "category": "CLASS",
  "content": "線形代数の授業について...",
  "imageUrl": "https://...",
  "likeCount": 5,
  "threadCount": 3,
  "isAnonymous": false,
  "isLiked": false,
  "createdAt": "2025-01-07T10:00:00Z",
  "updatedAt": "2025-01-07T10:00:00Z"
}
```

#### 投稿削除
```http
DELETE /api/posts/:postId
Authorization: Bearer <token>
```
**Response:** `200 OK`
```json
{
  "message": "投稿が削除されました"
}
```

### スレッド (Threads)

#### スレッド一覧取得
```http
GET /api/posts/:postId/threads
```
**Response:** `200 OK`
```json
{
  "threads": [
    {
      "threadId": 1,
      "postId": 1,
      "parentThreadId": null,
      "userId": 2,
      "displayName": "鈴木花子",
      "content": "その授業取りました！",
      "likeCount": 2,
      "depthLevel": 0,
      "isAnonymous": false,
      "isLiked": false,
      "createdAt": "2025-01-07T11:00:00Z",
      "children": [
        {
          "threadId": 2,
          "parentThreadId": 1,
          "content": "どうでしたか？",
          "depthLevel": 1,
          /* ... */
        }
      ]
    }
  ]
}
```

#### スレッド作成
```http
POST /api/posts/:postId/threads
Authorization: Bearer <token>
```
**Body:**
```json
{
  "content": "その授業取りました！参考になります",
  "parentThreadId": null, // optional
  "isAnonymous": false
}
```
**Response:** `201 Created`
```json
{
  "threadId": 1,
  "message": "返信が作成されました"
}
```

### いいね (Likes)

#### 投稿にいいね
```http
POST /api/posts/:postId/like
Authorization: Bearer <token>
```
**Response:** `200 OK`
```json
{
  "message": "いいねしました",
  "likeCount": 6
}
```

#### 投稿のいいね解除
```http
DELETE /api/posts/:postId/like
Authorization: Bearer <token>
```
**Response:** `200 OK`
```json
{
  "message": "いいねを解除しました",
  "likeCount": 5
}
```

#### スレッドにいいね
```http
POST /api/threads/:threadId/like
Authorization: Bearer <token>
```
**Response:** `200 OK`
```json
{
  "message": "いいねしました",
  "likeCount": 3
}
```

### イベント (Events)

#### イベント一覧取得
```http
GET /api/events?category=新歓&dateFrom=2025-01-01&dateTo=2025-12-31&page=1&limit=20
```
**Query Parameters:**
- `category`: カテゴリ名 (optional)
- `dateFrom`: 開始日 (optional)
- `dateTo`: 終了日 (optional)
- `page`: ページ番号 (default: 1)
- `limit`: 1ページあたりの件数 (default: 20)

**Response:** `200 OK`
```json
{
  "events": [
    {
      "eventId": 1,
      "userId": 1,
      "displayName": "山田太郎",
      "title": "テニス部新歓",
      "description": "新入生歓迎会を開催します",
      "category": "新歓",
      "eventDatetime": "2025-04-15T18:00:00Z",
      "location": "体育館",
      "externalUrl": "https://forms.google.com/...",
      "imageUrl": "https://...",
      "createdAt": "2025-01-07T10:00:00Z"
    }
  ],
  "pagination": { /* pagination info */ }
}
```

#### イベント作成
```http
POST /api/events
Authorization: Bearer <token>
```
**Body:**
```json
{
  "title": "テニス部新歓",
  "description": "新入生歓迎会を開催します。初心者大歓迎！",
  "category": "新歓",
  "eventDatetime": "2025-04-15T18:00:00Z",
  "location": "体育館",
  "externalUrl": "https://forms.google.com/...", // optional
  "imageBase64": "data:image/jpeg;base64,..." // optional
}
```
**Response:** `201 Created`
```json
{
  "eventId": 1,
  "message": "イベントが作成されました"
}
```

#### イベント詳細取得
```http
GET /api/events/:eventId
```
**Response:** `200 OK`
```json
{
  "eventId": 1,
  "userId": 1,
  "displayName": "山田太郎",
  "title": "テニス部新歓",
  "description": "新入生歓迎会を開催します",
  "category": "新歓",
  "eventDatetime": "2025-04-15T18:00:00Z",
  "location": "体育館",
  "externalUrl": "https://forms.google.com/...",
  "imageUrl": "https://...",
  "isActive": true,
  "createdAt": "2025-01-07T10:00:00Z",
  "updatedAt": "2025-01-07T10:00:00Z"
}
```

### ユーザー (Users)

#### 現在のユーザー情報取得
```http
GET /api/users/me
Authorization: Bearer <token>
```
**Response:** `200 OK`
```json
{
  "userId": 1,
  "username": "user123",
  "email": "user@s.kyushu-u.ac.jp",
  "displayName": "山田太郎",
  "faculty": "ENGINEERING",
  "grade": 3,
  "circle": "テニス部",
  "emailVerified": true,
  "createdAt": "2025-01-01T00:00:00Z"
}
```

#### ユーザー情報更新
```http
PATCH /api/users/me
Authorization: Bearer <token>
```
**Body:**
```json
{
  "displayName": "山田太郎",
  "grade": 4,
  "circle": "テニス部・写真部"
}
```
**Response:** `200 OK`
```json
{
  "message": "プロフィールが更新されました"
}
```

### その他

#### ヘルスチェック
```http
GET /api/health
```
**Response:** `200 OK`
```json
{
  "status": "OK",
  "timestamp": "2025-01-07T10:00:00Z",
  "service": "Q-App Backend"
}
```

#### カテゴリ一覧取得（イベント用）
```http
GET /api/categories/events
```
**Response:** `200 OK`
```json
{
  "categories": ["新歓", "勉強会", "コンパ", "その他"]
}
```

## 画像アップロード仕様

- **最大サイズ**: 10MB
- **対応形式**: JPEG, PNG, GIF, WebP
- **アップロード方式**: Base64エンコード
- **保存先**: ローカル（開発）/ AWS S3（本番）

## ページネーション仕様

```json
{
  "pagination": {
    "page": 1,        // 現在のページ
    "limit": 20,      // 1ページあたりの件数
    "total": 100,     // 総件数
    "totalPages": 5,  // 総ページ数
    "hasNext": true,  // 次ページの有無
    "hasPrev": false  // 前ページの有無
  }
}
```

## レート制限

- 一般エンドポイント: 100リクエスト/15分/IP
- 認証エンドポイント: 10リクエスト/15分/IP
- ファイルアップロード: 10リクエスト/1時間/ユーザー

## HTTPステータスコード

- `200 OK`: 成功
- `201 Created`: リソース作成成功
- `400 Bad Request`: リクエスト不正
- `401 Unauthorized`: 認証エラー
- `403 Forbidden`: 権限エラー
- `404 Not Found`: リソース未発見
- `409 Conflict`: 競合（ユーザー名重複等）
- `429 Too Many Requests`: レート制限
- `500 Internal Server Error`: サーバーエラー

---

最終更新: 2025-01-07
バージョン: 1.0.0