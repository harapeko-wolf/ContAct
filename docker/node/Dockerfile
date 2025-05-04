FROM node:21-alpine

# 必要なパッケージのインストール
RUN apk add --no-cache \
    git \
    curl \
    python3 \
    make \
    g++

# 作業ディレクトリの設定
WORKDIR /app

# ユーザーの設定
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app

# 環境変数の設定
ENV NODE_ENV=development
ENV PATH /app/node_modules/.bin:$PATH

# エントリーポイントの設定
COPY docker/node/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 開発用ユーザーに切り替え
USER appuser

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npm", "run", "dev"] 