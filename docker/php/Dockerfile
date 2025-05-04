FROM php:8.4-fpm

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 開発用ツールのインストール
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# PHP設定のコピー
COPY docker/php/php.ini /usr/local/etc/php/conf.d/local.ini

# 作業ディレクトリの設定
WORKDIR /var/www/html

# ユーザーの設定
RUN useradd -G www-data,root -u 1000 -d /home/dev dev \
    && mkdir -p /home/dev/.composer \
    && chown -R dev:dev /home/dev

# 環境変数の設定
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/home/dev/.composer

# エントリーポイントの設定
COPY docker/php/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 開発用ユーザーに切り替え
USER dev

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"] 