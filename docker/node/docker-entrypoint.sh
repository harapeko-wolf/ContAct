#!/bin/sh

# 依存関係のインストール
if [ ! -d "node_modules" ]; then
    npm install
fi

# 環境変数ファイルの設定
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

# コンテナの起動
exec "$@" 