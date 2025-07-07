# Docker コンテナ設計書

## コンテナ構成

### 開発環境構成
```
docker-compose.yml
├── frontend (Vue.js)
├── backend (Express.js)
├── database (MySQL)
├── redis (キャッシュ)
└── nginx (リバースプロキシ)
```

### 本番環境構成
```
AWS ECS Cluster
├── frontend-service (Vue.js build + Nginx)
├── backend-service (Express.js)
├── RDS MySQL (外部)
└── ElastiCache Redis (外部)
```

## Docker 設定ファイル

### docker-compose.yml
```yaml
version: '3.8'

services:
  frontend:
    build: 
      context: ./frontend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - VITE_API_URL=http://localhost:8000
    depends_on:
      - backend

  backend:
    build: 
      context: ./backend
      dockerfile: Dockerfile.dev
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    environment:
      - DATABASE_URL=mysql://user:password@database:3306/qapp
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=your-jwt-secret-key
      - MAIL_SERVER=smtp.gmail.com
      - MAIL_PORT=587
      - MAIL_USERNAME=your-email@gmail.com
      - MAIL_PASSWORD=your-app-password
    depends_on:
      - database
      - redis
    command: npm run dev

  database:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=qapp
      - MYSQL_USER=user
      - MYSQL_PASSWORD=password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - frontend
      - backend

volumes:
  mysql_data:
  redis_data:
```

### Frontend Dockerfile.dev
```dockerfile
FROM node:18-alpine

WORKDIR /app

# package.json と package-lock.json をコピー
COPY package*.json ./

# 依存関係をインストール
RUN npm ci

# アプリケーションコードをコピー
COPY . .

# 開発サーバーを起動
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

### Frontend Dockerfile (本番用)
```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Backend Dockerfile.dev
```dockerfile
FROM node:18-alpine

WORKDIR /app

# package.json と package-lock.json をコピー
COPY package*.json ./

# 依存関係をインストール
RUN npm ci

# アプリケーションコードをコピー
COPY . .

# TypeScript をグローバルにインストール
RUN npm install -g typescript ts-node nodemon

EXPOSE 8000
CMD ["npm", "run", "dev"]
```

### Backend Dockerfile (本番用)
```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# package.json と package-lock.json をコピー
COPY package*.json ./

# 依存関係をインストール
RUN npm ci

# アプリケーションコードをコピー
COPY . .

# TypeScript をビルド
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# 本番用の依存関係のみインストール
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# ビルド済みファイルをコピー
COPY --from=builder /app/dist ./dist

# 本番用のユーザーを作成
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# アプリケーションファイルの所有者を変更
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 8000
CMD ["node", "dist/index.js"]
```

### nginx/nginx.conf
```nginx
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:8000;
    }

    server {
        listen 80;
        server_name localhost;

        # フロントエンドへのプロキシ
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # バックエンドAPIへのプロキシ
        location /api {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # WebSocketサポート（必要に応じて）
        location /ws {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### database/init.sql
```sql
-- 初期データベース設定
CREATE DATABASE IF NOT EXISTS qapp;
USE qapp;

-- テーブル作成（technical-design.md の SQL を使用）
-- ここに前述のテーブル定義を配置
```

## 本番環境デプロイ設定

### AWS ECS Task Definition (backend)
```json
{
  "family": "qapp-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "ACCOUNT.dkr.ecr.REGION.amazonaws.com/qapp-backend:latest",
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "DATABASE_URL",
          "value": "mysql://user:password@rds-endpoint:3306/qapp"
        },
        {
          "name": "REDIS_URL",
          "value": "redis://elasticache-endpoint:6379"
        }
      ],
      "secrets": [
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:secretsmanager:REGION:ACCOUNT:secret:qapp/jwt-secret"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/qapp-backend",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### AWS ECS Service Definition
```json
{
  "serviceName": "qapp-backend-service",
  "cluster": "qapp-cluster",
  "taskDefinition": "qapp-backend",
  "desiredCount": 2,
  "launchType": "FARGATE",
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-12345", "subnet-67890"],
      "securityGroups": ["sg-backend"],
      "assignPublicIp": "DISABLED"
    }
  },
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:REGION:ACCOUNT:targetgroup/qapp-backend-tg",
      "containerName": "backend",
      "containerPort": 8000
    }
  ]
}
```

### GitHub Actions デプロイワークフロー
```yaml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ap-northeast-1

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build and push backend image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: qapp-backend
        IMAGE_TAG: ${{ github.sha }}
      run: |
        cd backend
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

    - name: Build and push frontend image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: qapp-frontend
        IMAGE_TAG: ${{ github.sha }}
      run: |
        cd frontend
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

    - name: Deploy to ECS
      run: |
        aws ecs update-service \
          --cluster qapp-cluster \
          --service qapp-backend-service \
          --force-new-deployment

        aws ecs update-service \
          --cluster qapp-cluster \
          --service qapp-frontend-service \
          --force-new-deployment
```

## 開発コマンド

### 開発環境起動
```bash
# 全サービス起動
docker-compose up -d

# 特定のサービスのみ起動
docker-compose up -d backend database

# ログ確認
docker-compose logs -f backend

# サービス停止
docker-compose down

# データベースリセット
docker-compose down -v
docker-compose up -d database
```

### 本番ビルド
```bash
# フロントエンドビルド
docker build -f frontend/Dockerfile -t qapp-frontend .

# バックエンドビルド
docker build -f backend/Dockerfile -t qapp-backend .

# イメージプッシュ
docker tag qapp-backend:latest ACCOUNT.dkr.ecr.REGION.amazonaws.com/qapp-backend:latest
docker push ACCOUNT.dkr.ecr.REGION.amazonaws.com/qapp-backend:latest
```

### データベース管理
```bash
# データベースマイグレーション
docker-compose exec backend python -m alembic upgrade head

# データベース接続
docker-compose exec database mysql -u user -p qapp

# データベースバックアップ
docker-compose exec database mysqldump -u user -p qapp > backup.sql

# データベースリストア
docker-compose exec -T database mysql -u user -p qapp < backup.sql
```

## 環境変数管理

### .env.development
```env
# Database
DATABASE_URL=mysql://user:password@localhost:3306/qapp
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-development-jwt-secret
JWT_EXPIRE_MINUTES=1440

# Email
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# AWS (開発用)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=ap-northeast-1
S3_BUCKET=qapp-dev-bucket

# Frontend
VITE_API_URL=http://localhost:8000
VITE_APP_NAME=Q-App Development
```

### .env.production
```env
# Database
DATABASE_URL=mysql://user:password@rds-endpoint:3306/qapp
REDIS_URL=redis://elasticache-endpoint:6379

# JWT
JWT_SECRET=your-production-jwt-secret
JWT_EXPIRE_MINUTES=1440

# Email
MAIL_SERVER=email-smtp.ap-northeast-1.amazonaws.com
MAIL_PORT=587
MAIL_USERNAME=your-ses-username
MAIL_PASSWORD=your-ses-password

# AWS
AWS_ACCESS_KEY_ID=your-production-access-key
AWS_SECRET_ACCESS_KEY=your-production-secret-key
AWS_REGION=ap-northeast-1
S3_BUCKET=qapp-prod-bucket

# Frontend
VITE_API_URL=https://api.qapp.com
VITE_APP_NAME=Q-App
```

## セキュリティ設定

### Docker セキュリティベストプラクティス
```dockerfile
# 非root ユーザーの使用
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

# 最小限の権限
COPY --chown=appuser:appuser . .

# セキュリティアップデート
RUN apt-get update && apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# 不要なファイルの削除
RUN rm -rf /tmp/* /var/tmp/*
```

### ネットワークセキュリティ
- プライベートサブネット内でのコンテナ実行
- セキュリティグループによるアクセス制御
- ALB による HTTPS 終端
- WAF による攻撃防御

## 監視・ログ設定

### CloudWatch ログ設定
```json
{
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/ecs/qapp-backend",
      "awslogs-region": "ap-northeast-1",
      "awslogs-stream-prefix": "ecs"
    }
  }
}
```

### プロメテウス・グラファナ (将来的)
```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```