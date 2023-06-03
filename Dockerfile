ARG PHP_VERSION=8.2

FROM php:${PHP_VERSION}-apache as app_php

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    locales \
    apt-utils \
    git \
    nano \
    libicu-dev \
    g++ \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    libxslt-dev \
    make \
    imagemagick \
    libmagickwand-dev \
	libpng-dev \
	libwebp-dev \
	libfreetype6-dev \
    unzip;

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/

RUN docker-php-ext-configure gd  \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --with-webp=/usr/include/

RUN install-php-extensions \
    gd \
    imagick \
    intl \
    pdo_mysql \
    opcache \
    calendar \
    apcu \
    redis \
    amqp \
    zip

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN curl -o /usr/local/bin/composer https://getcomposer.org/download/latest-stable/composer.phar \
  && chmod +x /usr/local/bin/composer

RUN curl -sS https://get.symfony.com/cli/installer | bash \
   && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

COPY ./docker/php/conf.d/app.ini $PHP_INI_DIR/conf.d/
COPY ./docker/php/conf.d/opcache.ini $PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini
COPY ./docker/apache/vhosts/vhosts.conf /etc/apache2/sites-available/000-default.conf

ARG WORKDIR=/var/www/app

WORKDIR ${WORKDIR}

#COPY ./composer.* ${WORKDIR}

#RUN composer install --prefer-dist --no-dev --no-scripts --no-progress --no-interaction

#COPY ./ ${WORKDIR}

#RUN composer dump-autoload --optimize

RUN rm -rf /var/www/html

RUN groupadd dev -g 1000
RUN useradd dev -g dev -d /home/dev -m
RUN echo '%dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER dev:dev

ARG GIT_MAIL
ARG GIT_NAME
RUN git config --global user.email ${GIT_MAIL} \
 && git config --global user.name ${GIT_NAME}

FROM app_php as app_php_dev

USER root:root

ENV XDEBUG_MODE=off

COPY ./docker/php/conf.d/xdebug.ini $PHP_INI_DIR/conf.d/xdebug.ini

RUN install-php-extensions xdebug

USER dev:dev
