#!/bin/bash

# ディレクトリのパーミッションを設定
if [ ! -d "/var/www/html/storage" ]; then
    mkdir -p /var/www/html/storage
fi

if [ ! -d "/var/www/html/bootstrap/cache" ]; then
    mkdir -p /var/www/html/bootstrap/cache
fi

chown -R dev:www-data /var/www/html/storage
chown -R dev:www-data /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

# アプリケーションキーの生成
if [ ! -f "/var/www/html/.env" ]; then
    cp /var/www/html/.env.example /var/www/html/.env
    php artisan key:generate
fi

# データベースのマイグレーション
php artisan migrate --force

# コンテナの起動
exec "$@" 