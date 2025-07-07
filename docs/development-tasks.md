# Q-App 開発タスクリスト

## 概要
ハッカソン1週間での開発タスクを管理するためのチェックリストです。
各タスクには推定時間と優先度を記載しています。

## タスク記号の説明
- [ ] 未着手
- [x] 完了
- [🔄] 作業中
- [⚠️] ブロック/課題あり

## Phase 1: 基盤構築とコア機能（Day 1-2）

### Day 1 AM - Backend認証基盤（4時間）

#### ミドルウェア実装（1時間）
- [ ] `src/middleware/auth.ts` - JWT認証ミドルウェア
- [ ] `src/middleware/validation.ts` - Joi バリデーション
- [ ] `src/middleware/errorHandler.ts` - エラーハンドリング

#### 認証サービス実装（2時間）
- [ ] `src/services/jwt.service.ts` - JWT生成・検証
- [ ] `src/services/auth.service.ts` - 認証ロジック
- [ ] `src/utils/emailValidator.ts` - 大学メール検証

#### 認証API実装（1時間）
- [ ] `POST /api/auth/register` - ユーザー登録
- [ ] `POST /api/auth/login` - ログイン
- [ ] `POST /api/auth/refresh` - トークンリフレッシュ
- [ ] 認証APIテスト（Postman/curl）

### Day 1 PM - 投稿機能API（4時間）

#### 投稿サービス実装（2時間）
- [ ] `src/services/post.service.ts` - 投稿CRUD
- [ ] `src/types/post.types.ts` - 型定義
- [ ] Prismaクエリ最適化

#### 投稿API実装（2時間）
- [ ] `GET /api/posts` - 一覧取得（ページネーション）
- [ ] `POST /api/posts` - 投稿作成
- [ ] `GET /api/posts/:id` - 詳細取得
- [ ] カテゴリフィルタリング実装

### Day 2 AM - Frontend基盤（4時間）

#### Vue.js初期設定（2時間）
- [ ] TypeScript設定
- [ ] Vue Router設定
- [ ] Pinia store設定
- [ ] Tailwind CSS設定
- [ ] ESLint/Prettier設定

#### API通信基盤（2時間）
- [ ] `src/composables/useApi.ts` - API通信
- [ ] `src/stores/auth.ts` - 認証状態管理
- [ ] `src/types/index.ts` - 共通型定義
- [ ] インターセプター設定

### Day 2 PM - 基本UI実装（4時間）

#### レイアウト実装（2時間）
- [ ] `DefaultLayout.vue` - 基本レイアウト
- [ ] `AppHeader.vue` - ヘッダー
- [ ] `AppNavigation.vue` - ナビゲーション

#### 画面実装（2時間）
- [ ] `LoginView.vue` - ログイン画面
- [ ] `PostsView.vue` - 投稿一覧
- [ ] `PostList.vue` - 投稿リスト
- [ ] `PostItem.vue` - 投稿アイテム

## Phase 2: 中核機能実装（Day 3-4）

### Day 3 AM - スレッド機能API（4時間）

#### スレッドサービス（2時間）
- [ ] `src/services/thread.service.ts` - スレッドCRUD
- [ ] 階層構造の再帰処理
- [ ] 深さ制限の実装

#### スレッドAPI（2時間）
- [ ] `GET /api/posts/:postId/threads` - スレッド取得
- [ ] `POST /api/posts/:postId/threads` - 返信作成
- [ ] パフォーマンステスト

### Day 3 PM - いいね機能API（4時間）

#### いいねサービス（2時間）
- [ ] `src/services/like.service.ts` - いいね処理
- [ ] トランザクション処理
- [ ] カウント更新最適化

#### いいねAPI（2時間）
- [ ] `POST /api/posts/:id/like` - 投稿いいね
- [ ] `DELETE /api/posts/:id/like` - いいね解除
- [ ] `POST /api/threads/:id/like` - スレッドいいね

### Day 4 AM - 投稿作成UI（4時間）

#### 投稿フォーム（2時間）
- [ ] `CreatePostView.vue` - 投稿作成画面
- [ ] `PostForm.vue` - 投稿フォーム
- [ ] `CategorySelector.vue` - カテゴリ選択

#### 投稿機能統合（2時間）
- [ ] 画像プレビュー（仮実装）
- [ ] 匿名投稿トグル
- [ ] バリデーション

### Day 4 PM - スレッド表示UI（4時間）

#### スレッドコンポーネント（2時間）
- [ ] `PostDetailView.vue` - 投稿詳細
- [ ] `ThreadList.vue` - スレッドリスト
- [ ] `ThreadItem.vue` - スレッドアイテム

#### インタラクション実装（2時間）
- [ ] `ThreadForm.vue` - 返信フォーム
- [ ] いいねボタン実装
- [ ] リアルタイム更新（仮）

## Phase 3: イベント機能とUX向上（Day 5-6）

### Day 5 AM - イベントAPI（4時間）

#### イベントサービス（2時間）
- [ ] `src/services/event.service.ts` - イベントCRUD
- [ ] 日時バリデーション
- [ ] カテゴリ管理

#### イベントAPI（2時間）
- [ ] `GET /api/events` - 一覧取得
- [ ] `POST /api/events` - 作成
- [ ] `GET /api/events/:id` - 詳細

### Day 5 PM - 画像アップロード（4時間）

#### アップロード実装（2時間）
- [ ] `src/middleware/upload.ts` - Multer設定
- [ ] `src/services/storage.service.ts` - ストレージ
- [ ] 画像リサイズ処理

#### セキュリティ実装（2時間）
- [ ] ファイルサイズ制限
- [ ] ファイル形式検証
- [ ] ウイルススキャン（仮）

### Day 6 AM - イベントUI（4時間）

#### イベント画面（2時間）
- [ ] `EventsView.vue` - 一覧画面
- [ ] `EventList.vue` - リスト
- [ ] `EventItem.vue` - アイテム

#### イベント作成（2時間）
- [ ] `CreateEventView.vue` - 作成画面
- [ ] `EventForm.vue` - フォーム
- [ ] `EventDetailView.vue` - 詳細画面

### Day 6 PM - UI/UX改善（4時間）

#### UIコンポーネント（2時間）
- [ ] `LoadingSpinner.vue` - ローディング
- [ ] `ErrorMessage.vue` - エラー表示
- [ ] `SuccessToast.vue` - 成功通知

#### UX改善（2時間）
- [ ] `SearchBar.vue` - 検索バー
- [ ] `FilterPanel.vue` - フィルター
- [ ] レスポンシブ調整

## Phase 4: 最終調整と追加機能（Day 7）

### Day 7 AM - マップ機能（4時間）

#### マップ実装（2時間）
- [ ] `MapView.vue` - マップ画面
- [ ] `CampusMap.vue` - キャンパス地図
- [ ] 建物情報オーバーレイ

#### 検索機能（2時間）
- [ ] 建物名検索
- [ ] カテゴリフィルター
- [ ] ズーム機能（仮）

### Day 7 PM - 最終調整（4時間）

#### バグ修正（2時間）
- [ ] 既知のバグ修正
- [ ] クロスブラウザテスト
- [ ] モバイル対応確認

#### デプロイ準備（2時間）
- [ ] 環境変数設定
- [ ] ビルド最適化
- [ ] デプロイスクリプト
- [ ] 動作確認

## 追加タスク（時間があれば）

### パフォーマンス最適化
- [ ] 画像遅延読み込み
- [ ] API キャッシング
- [ ] バンドルサイズ削減

### セキュリティ強化
- [ ] CSRFトークン
- [ ] XSS対策強化
- [ ] SQLインジェクション再確認

### テスト実装
- [ ] Unit テスト（Jest）
- [ ] E2E テスト（Cypress）
- [ ] API テスト自動化

## 進捗管理

### 日次チェックポイント
- [ ] Day 1: 認証・投稿APIの動作確認
- [ ] Day 2: ログイン・投稿閲覧の確認
- [ ] Day 3: スレッド・いいねAPIの確認
- [ ] Day 4: 投稿作成・返信UIの確認
- [ ] Day 5: イベントAPI・画像の確認
- [ ] Day 6: イベントUI・UXの確認
- [ ] Day 7: 全機能統合テスト

### リスク項目
- ⚠️ Prisma/MySQLの日本語対応
- ⚠️ 画像アップロードのサイズ制限
- ⚠️ リアルタイム更新の実装判断
- ⚠️ メール送信の実装判断

## メモ・備考

### 実装のポイント
1. **MVP優先**: まず動くものを作る
2. **段階的実装**: 各フェーズで動作確認
3. **シンプル実装**: 複雑な機能は後回し

### 技術的決定事項
- 画像は当面Base64で実装
- メール送信は模擬実装でOK
- リアルタイム更新は優先度低

### チーム連携
- 毎朝スタンドアップミーティング
- Slackで進捗共有
- GitHubでコードレビュー

---

最終更新: 2025-01-07
次回更新: Day 1 終了時