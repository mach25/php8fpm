FROM php:8.0-fpm AS mhsendmail

WORKDIR /build

RUN apt-get update && apt-get install -y \
    apt-utils \
    golang-go \
    git \
    && go get github.com/mailhog/mhsendmail \
    && go build github.com/mailhog/mhsendmail

FROM php:8.0-fpm

# COPY mhsendmail from previous layer
COPY --from=mhsendmail /build/mhsendmail /usr/bin/mhsendmail

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    libmemcached-dev \
    libgmp-dev \
    curl \
    wget \
    less \
    && docker-php-ext-install -j$(nproc) opcache gd mysqli pdo pdo_mysql xsl zip intl soap bcmath exif gmp iconv  \
    && pecl install -a imagick-3.0.3 && docker-php-ext-enable imagick \
    && pecl install -a xdebug-3.1.0 && docker-php-ext-enable xdebug \
    && pecl install -a igbinary-3.2.6 && docker-php-ext-enable igbinary \
    && pecl install -a msgpack-2.1.2 && docker-php-ext-enable msgpack \
    && pecl install --nobuild memcached-3.1.5 \
    && cd "$(pecl config-get temp_dir)/memcached" && phpize \
    && ./configure --enable-memcached-igbinary --enable-memcached-msgpack \
    && make -j$(nproc) && make install && cd /tmp/ && docker-php-ext-enable memcached \
    && pecl install -a uploadprogress-2.0.2 && docker-php-ext-enable uploadprogress \
    && pecl install -a apcu-5.1.20 && docker-php-ext-enable apcu

# php configuration
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY ./phpconf/memory_limit.ini $PHP_INI_DIR/conf.d/memory_limit.ini
COPY ./phpconf/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini
COPY ./phpconf/xdebug.ini $PHP_INI_DIR/conf.d/xdebug.ini
COPY ./phpconf/sendmail.ini $PHP_INI_DIR/conf.d/sendmail.ini
COPY ./phpconf/max_execution_time.ini $PHP_INI_DIR/conf.d/max_execution_time.ini
COPY ./phpconf/upload_max_filesize.ini $PHP_INI_DIR/conf.d/upload_max_filesize.ini
COPY ./phpconf/www.conf /usr/local/etc/php-fpm.d/www.conf

EXPOSE 9000
