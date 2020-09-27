#
# Ref: https://hub.docker.com/r/easyengine/php7.4/dockerfile
#

FROM php:7.4-fpm

RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    imagemagick \
    libc-client-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libkrb5-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libicu-dev \
    libgmp-dev \
    libxml2-dev \
    libpng-dev \
    libzip-dev \
    libssl-dev \
    zip

RUN pecl install imagick && \
    docker-php-ext-enable imagick &&\
    docker-php-ext-install exif && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure zip && \
    docker-php-ext-install gd && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install opcache && \
    docker-php-ext-install intl && \
    docker-php-ext-install zip && \
    docker-php-ext-install bcmath && \
    docker-php-ext-configure gmp && \
    docker-php-ext-install gmp && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini


WORKDIR /var/www

EXPOSE 9000
CMD ["php-fpm"]