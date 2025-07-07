# Q-App 実装計画書

## 概要

本ドキュメントは、Q-App（九大生専用SNS）の実装計画を定義します。
ハッカソン期間（1週間）での完成を目指し、4つのフェーズに分けて段階的に実装を進めます。

## 実装方針

- **MVP優先**: まず動くものを作り、段階的に機能を追加
- **機能の優先順位**: 掲示板 > イベント > 認証 > マップ
- **並行開発**: Backend APIとFrontend UIを並行して開発
- **日次リリース**: 毎日動作する成果物を確認

## Phase 1: 基盤構築とコア機能（Day 1-2）

### 目標
基本的な投稿・閲覧機能を実装し、アプリケーションの基盤を確立する。

### Backend実装

#### 1.1 認証基盤（Day 1 AM）
```
backend/src/
├── middleware/
│   ├── auth.ts          # JWT認証ミドルウェア
│   └── validation.ts    # リクエスト検証
├── controllers/
│   └── auth.controller.ts
├── routes/
│   └── auth.routes.ts
└── services/
    ├── auth.service.ts
    └── jwt.service.ts
```

- [ ] JWT認証ミドルウェア実装
- [ ] ユーザー登録API (`POST /api/auth/register`)
- [ ] ログインAPI (`POST /api/auth/login`)
- [ ] トークンリフレッシュAPI (`POST /api/auth/refresh`)

#### 1.2 投稿機能API（Day 1 PM）
```
backend/src/
├── controllers/
│   └── post.controller.ts
├── routes/
│   └── post.routes.ts
└── services/
    └── post.service.ts
```

- [ ] 投稿一覧取得 (`GET /api/posts`)
- [ ] 投稿作成 (`POST /api/posts`)
- [ ] 投稿詳細取得 (`GET /api/posts/:id`)
- [ ] カテゴリフィルタリング

### Frontend実装

#### 1.3 Vue.js基本設定（Day 2 AM）
```
frontend/src/
├── App.vue
├── main.ts
├── router/
│   └── index.ts
├── stores/
│   ├── auth.ts
│   └── posts.ts
├── composables/
│   └── useApi.ts
└── types/
    └── index.ts
```

- [ ] Vue 3 + TypeScript設定
- [ ] Vue Router設定
- [ ] Pinia状態管理設定
- [ ] Tailwind CSS設定
- [ ] Axios設定とAPI通信基盤

#### 1.4 基本UI実装（Day 2 PM）
```
frontend/src/
├── layouts/
│   └── DefaultLayout.vue
├── views/
│   ├── HomeView.vue
│   ├── LoginView.vue
│   └── PostsView.vue
└── components/
    ├── common/
    │   ├── AppHeader.vue
    │   └── AppNavigation.vue
    └── posts/
        ├── PostList.vue
        └── PostItem.vue
```

- [ ] 基本レイアウト作成
- [ ] ログイン画面
- [ ] 投稿一覧画面
- [ ] 投稿表示コンポーネント

### 成果物
- ユーザーがログインして投稿を閲覧できる最小限のアプリケーション

## Phase 2: 中核機能実装（Day 3-4）

### 目標
スレッド機能、いいね機能、投稿作成機能を実装し、SNSとしての基本機能を完成させる。

### Backend実装

#### 2.1 スレッド機能API（Day 3 AM）
```
backend/src/
├── controllers/
│   └── thread.controller.ts
├── routes/
│   └── thread.routes.ts
└── services/
    └── thread.service.ts
```

- [ ] スレッド一覧取得 (`GET /api/posts/:postId/threads`)
- [ ] スレッド作成 (`POST /api/posts/:postId/threads`)
- [ ] 階層構造の処理ロジック

#### 2.2 いいね機能API（Day 3 PM）
```
backend/src/
├── controllers/
│   └── like.controller.ts
└── services/
    └── like.service.ts
```

- [ ] 投稿いいね (`POST /api/posts/:id/like`)
- [ ] 投稿いいね解除 (`DELETE /api/posts/:id/like`)
- [ ] スレッドいいね機能

### Frontend実装

#### 2.3 投稿作成UI（Day 4 AM）
```
frontend/src/
├── views/
│   └── CreatePostView.vue
└── components/
    └── posts/
        ├── PostForm.vue
        └── CategorySelector.vue
```

- [ ] 投稿作成フォーム
- [ ] カテゴリ選択
- [ ] 画像アップロード（仮）
- [ ] 匿名投稿オプション

#### 2.4 スレッド表示UI（Day 4 PM）
```
frontend/src/
├── views/
│   └── PostDetailView.vue
└── components/
    └── threads/
        ├── ThreadList.vue
        ├── ThreadItem.vue
        └── ThreadForm.vue
```

- [ ] 投稿詳細画面
- [ ] スレッド表示（Reddit風）
- [ ] 返信フォーム
- [ ] いいねボタン実装

### 成果物
- 投稿作成、スレッド返信、いいね機能が動作する掲示板システム

## Phase 3: イベント機能とUX向上（Day 5-6）

### 目標
イベント機能を実装し、UIの洗練とユーザビリティを向上させる。

### Backend実装

#### 3.1 イベント機能API（Day 5 AM）
```
backend/src/
├── controllers/
│   └── event.controller.ts
├── routes/
│   └── event.routes.ts
└── services/
    └── event.service.ts
```

- [ ] イベント一覧取得 (`GET /api/events`)
- [ ] イベント作成 (`POST /api/events`)
- [ ] イベント詳細取得 (`GET /api/events/:id`)
- [ ] カテゴリ管理

#### 3.2 画像アップロード（Day 5 PM）
```
backend/src/
├── middleware/
│   └── upload.ts
└── services/
    └── storage.service.ts
```

- [ ] Multer設定
- [ ] 画像アップロードAPI
- [ ] 画像サイズ・形式検証

### Frontend実装

#### 3.3 イベント機能UI（Day 6 AM）
```
frontend/src/
├── views/
│   ├── EventsView.vue
│   ├── CreateEventView.vue
│   └── EventDetailView.vue
└── components/
    └── events/
        ├── EventList.vue
        ├── EventItem.vue
        └── EventForm.vue
```

- [ ] イベント一覧画面
- [ ] イベント作成フォーム
- [ ] イベント詳細画面
- [ ] 外部URL連携

#### 3.4 UI/UX改善（Day 6 PM）
```
frontend/src/components/
├── common/
│   ├── LoadingSpinner.vue
│   ├── ErrorMessage.vue
│   └── SuccessToast.vue
└── ui/
    ├── SearchBar.vue
    ├── FilterPanel.vue
    └── SortSelector.vue
```

- [ ] ローディング状態
- [ ] エラーハンドリング
- [ ] 検索・フィルター機能
- [ ] レスポンシブデザイン調整

### 成果物
- イベント機能が実装され、UIが洗練されたアプリケーション

## Phase 4: 最終調整と追加機能（Day 7）

### 目標
マップ機能の実装、バグ修正、パフォーマンス最適化、デプロイ準備を行う。

### 実装項目

#### 4.1 マップ機能（AM）
```
frontend/src/
├── views/
│   └── MapView.vue
└── components/
    └── map/
        └── CampusMap.vue
```

- [ ] 静的地図画像の表示
- [ ] 建物情報のオーバーレイ
- [ ] 簡易検索機能

#### 4.2 最終調整（PM）
- [ ] バグ修正
- [ ] パフォーマンス最適化
- [ ] セキュリティチェック
- [ ] 本番環境設定
- [ ] デプロイ準備

### 成果物
- 全機能が実装された完成版アプリケーション

## タスク管理

### 日次スケジュール
```
Day 1 (月): Backend認証 + 投稿API
Day 2 (火): Frontend基盤 + 基本UI
Day 3 (水): スレッド・いいねAPI
Day 4 (木): 投稿作成・スレッドUI
Day 5 (金): イベントAPI + 画像
Day 6 (土): イベントUI + UX改善
Day 7 (日): マップ + 最終調整
```

### チェックポイント
- **Day 2終了時**: ログインして投稿が見られる
- **Day 4終了時**: 投稿・返信・いいねが可能
- **Day 6終了時**: イベント機能が動作
- **Day 7終了時**: 全機能完成

## 技術的な実装詳細

### API設計原則
- RESTful設計
- JWT Bearer認証
- エラーレスポンスの統一
- ページネーション対応

### Frontend設計原則
- Composition API使用
- TypeScript厳密モード
- コンポーネント再利用性
- レスポンシブ優先

### データベース最適化
- インデックス設定
- N+1問題の回避
- トランザクション処理

## リスクと対策

### 技術的リスク
- **Prismaの互換性問題**: 既に解決済み
- **認証実装の複雑さ**: シンプルなJWT実装から開始
- **画像アップロード**: Phase 3で実装、初期は画像なしでも動作

### スケジュールリスク
- **遅延対策**: 各Phaseで動作する成果物を確保
- **優先順位**: 掲示板機能を最優先、マップは最後

## 実装開始チェックリスト

- [x] 開発環境構築完了
- [x] データベース接続確認
- [x] 基本的なプロジェクト構造
- [x] 実装計画書作成
- [ ] APIエンドポイント一覧作成
- [ ] UIワイヤーフレーム作成

## 次のアクション

1. このドキュメントをチームで共有
2. Phase 1のBackend認証実装から開始
3. 日次で進捗を確認し、計画を調整

---

最終更新: 2025-01-07
作成者: Q-App Development Team