FROM php:7.1-fpm-alpine

RUN apk update \
    && apk add icu-dev zlib-dev graphviz git openssh \
    && docker-php-ext-install mysqli pdo pdo_mysql intl zip mbstring iconv

RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

RUN curl -OL https://github.com/phpmetrics/PhpMetrics/releases/download/v2.4.1/phpmetrics.phar && \
    chmod +x phpmetrics.phar && \
    mv phpmetrics.phar /usr/local/bin/phpmetrics

RUN curl -OL http://www.phpdoc.org/phpDocumentor.phar && \
    chmod +x phpDocumentor.phar && \
    mv phpDocumentor.phar /usr/local/bin/phpdoc

RUN apk update \
    && apk add autoconf g++ make \
    && pecl install xdebug-2.5.5 \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_dir=/app/profiling" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo "date.timezone=Europe/London" > /usr/local/etc/php/conf.d/zz-custom.ini \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/zz-custom.ini \
    && echo "display_errors = on" >> /usr/local/etc/php/conf.d/zz-custom.ini \
    && echo "session.autostart=0" >> /usr/local/etc/php/conf.d/zz-custom.ini

ENV PATH "$PATH:/var/www/html/vendor/bin"

RUN echo "env[\"XDEBUG_CONFIG\"] = \$XDEBUG_CONFIG" >> /usr/local/etc/php-fpm.d/zz-docker.conf
