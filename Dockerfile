FROM php:7.4-fpm

ENV COMPOSER_HOME /var/composer
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN apt-get update && apt-get install -y wget curl git libcurl4-gnutls-dev zlib1g-dev libicu-dev g++ libxml2-dev libpq-dev zip libzip-dev unzip \
 libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libxpm-dev libjpeg-dev libwebp-dev gnupg2 poppler-utils \
 libmagickwand-dev imagemagick ghostscript \
 --no-install-recommends
RUN apt-get autoremove && apt-get autoclean \
 && rm -rf /var/lib/apt/lists/*

 # install Node.js
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs build-essential yarn curl libcurl4-gnutls-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl install redis apcu imagick

RUN docker-php-ext-enable redis apcu imagick
RUN docker-php-ext-configure gd  \
    --enable-gd \
    --with-webp \
    --with-jpeg \
    --with-xpm \
    --with-freetype
RUN docker-php-ext-install gettext sockets pdo pdo_mysql mysqli intl curl json opcache xml gd zip bcmath

RUN pecl install xdebug

# Install Composer
RUN mkdir /var/composer
RUN mkdir /var/composer/cache
RUN chmod -R 777 /var/composer/cache
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && mv /root/.symfony/bin/symfony /usr/local/bin/symfony

ARG XDEBUG_ENABLE=0
ARG XDEBUG_MODE=debug
RUN if [ "$XDEBUG_ENABLE" = "0" ] ; then echo "xdebug.mode=off" >> /usr/local/etc/php/conf.d/xdebug.ini ; fi
RUN if [ "$XDEBUG_ENABLE" = "1" ] ; then echo "xdebug.mode=${XDEBUG_MODE}" >> /usr/local/etc/php/conf.d/xdebug.ini ; fi
RUN if [ "$XDEBUG_ENABLE" = "1" ] ; then echo "zend_extension=xdebug" >> /usr/local/etc/php/conf.d/xdebug.ini ; fi

EXPOSE 9000
CMD ["php-fpm"]
