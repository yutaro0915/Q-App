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