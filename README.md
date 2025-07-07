# Q-App - 九大生専用SNS

九州大学の学生による学生のための、大学生活総合SNSプラットフォーム

## 🎯 プロジェクト概要

分散している九大生の「生の声」や情報を一箇所に集約し、履修、サークル、アルバイト、日々の生活といった、あらゆる面で九大生のキャンパスライフを豊かにすることを目指しています。

## 🚀 主要機能

- **掲示板機能**: 履修、アルバイト、サークル、雑談のカテゴリ別投稿・閲覧
- **スレッド機能**: Reddit風のスレッド表示で議論を深める
- **イベント機能**: サークルや部活の新歓イベント告知・予約
- **マップ機能**: 九州大学伊都キャンパスの建物・施設案内
- **認証機能**: 大学メール認証による学生限定アクセス

## 🛠️ 技術スタック

- **Frontend**: Vue.js 3 + TypeScript + Tailwind CSS
- **Backend**: FastAPI + Python 3.11 + SQLAlchemy
- **Database**: MySQL 8.0
- **Cache**: Redis 7
- **Container**: Docker + Docker Compose
- **Deploy**: AWS (ECS + RDS + S3 + CloudFront)

## 🏗️ プロジェクト構成

```
Q-App/
├── frontend/           # Vue.js アプリケーション
│   ├── Dockerfile.dev  # 開発用Dockerfile
│   └── Dockerfile      # 本番用Dockerfile
├── backend/            # FastAPI アプリケーション
│   ├── Dockerfile.dev  # 開発用Dockerfile
│   └── Dockerfile      # 本番用Dockerfile
├── database/           # データベース設定
│   └── init.sql        # 初期化SQLファイル
├── nginx/              # Nginx設定
│   └── nginx.conf      # Nginx設定ファイル
├── docs/               # ドキュメント
│   ├── requirements.md # 要件定義書
│   ├── technical-design.md # 技術設計書
│   └── docker-setup.md # Docker設定書
├── docker-compose.yml  # 開発環境Docker設定
├── .env.example        # 環境変数設定例
└── README.md          # このファイル
```

## 🔧 開発環境セットアップ

### 必要なソフトウェア

- Docker
- Docker Compose
- Git

### 1. リポジトリのクローン

```bash
git clone https://github.com/yutaro0915/Q-App.git
cd Q-App
```

### 2. 環境変数の設定

```bash
cp .env.example .env
# .envファイルを編集して適切な値を設定
```

### 3. Docker環境の構築・起動

```bash
# 全サービスの起動
docker-compose up -d

# ログの確認
docker-compose logs -f

# 特定のサービスのみ起動
docker-compose up -d database redis
```

### 4. アプリケーションへのアクセス

- **フロントエンド**: http://localhost:3000
- **バックエンドAPI**: http://localhost:8000
- **Nginx経由**: http://localhost:80
- **データベース**: localhost:3306

## 📋 開発コマンド

```bash
# 開発環境の起動
docker-compose up -d

# 開発環境の停止
docker-compose down

# データベースのリセット
docker-compose down -v
docker-compose up -d database

# ログの確認
docker-compose logs -f [service-name]

# コンテナ内でのコマンド実行
docker-compose exec backend bash
docker-compose exec frontend bash
```

## 🗂️ データベース設計

### 主要テーブル

- `users`: ユーザー情報
- `posts`: 投稿情報
- `threads`: スレッド（返信）情報
- `events`: イベント情報
- `post_likes`: 投稿いいね情報
- `thread_likes`: スレッドいいね情報

詳細な設計については [technical-design.md](docs/technical-design.md) を参照してください。

## 🚀 本番環境デプロイ

### AWS環境

```bash
# 本番用イメージのビルド
docker build -f frontend/Dockerfile -t qapp-frontend .
docker build -f backend/Dockerfile -t qapp-backend .

# ECRへのプッシュ
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin [ACCOUNT].dkr.ecr.ap-northeast-1.amazonaws.com
docker tag qapp-frontend:latest [ACCOUNT].dkr.ecr.ap-northeast-1.amazonaws.com/qapp-frontend:latest
docker push [ACCOUNT].dkr.ecr.ap-northeast-1.amazonaws.com/qapp-frontend:latest
```

## 🧪 テスト

```bash
# バックエンドテスト
docker-compose exec backend pytest

# フロントエンドテスト
docker-compose exec frontend npm test
```

## 📝 開発ルール

### Git フロー

1. `main` ブランチから新しいブランチを作成
2. 機能開発・バグ修正を実行
3. プルリクエストを作成
4. コードレビューを経て `main` にマージ

### コミットメッセージ

```
feat: 新機能の追加
fix: バグ修正
docs: ドキュメント更新
style: コードスタイル修正
refactor: リファクタリング
test: テスト追加・修正
chore: その他の変更
```

## 🎯 実装優先度

1. **最優先**: 掲示板機能（投稿・閲覧・スレッド・いいね）
2. **高優先**: イベント機能
3. **中優先**: 認証機能
4. **低優先**: マップ機能

## 🔒 セキュリティ

- HTTPS通信必須
- JWT認証
- 大学メール認証
- SQL インジェクション対策
- XSS対策
- CSRF対策

## 📞 サポート

質問や問題がある場合は、以下にご連絡ください：

- GitHub Issues: [Issues](https://github.com/yutaro0915/Q-App/issues)
- Email: [メールアドレス]

## 📜 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

## 🤝 貢献

プルリクエストや Issue の作成を歓迎します。貢献する前に以下を確認してください：

1. 既存の Issue を確認する
2. 新しい機能を追加する場合は、事前に Issue で相談する
3. テストを追加する
4. コードスタイルを統一する

---

**🎓 九大生による九大生のための SNS プラットフォーム**