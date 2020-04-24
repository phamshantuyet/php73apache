FROM phamshantuyet/phalconphp_alpine:latest
LABEL maintainer="Pham Shan Tuyet <phamshantuyet@gmail.com>"

ARG APPLICATION_ENV
ENV APPLICATION_ENV=${APPLICATION_ENV}

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# COPY . /var/www/html

RUN apk --no-cache add php7.3-gd && cp /usr/lib/php/7.3/modules/gd.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/ && cp /etc/php/7.3/conf.d/00_gd.ini /usr/local/etc/php/conf.d/

RUN apk --no-cache add libzip-dev zip && docker-php-ext-configure zip --with-libzip && docker-php-ext-install zip

RUN apk --no-cache add php7.3-soap && cp /usr/lib/php/7.3/modules/soap.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/ && cp /etc/php/7.3/conf.d/00_soap.ini /usr/local/etc/php/conf.d/

RUN cp /usr/lib/php/7.3/modules/pdo_mysql.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/ && cp /etc/php/7.3/conf.d/02_pdo_mysql.ini /usr/local/etc/php/conf.d/

# RUN cd /var/www/html && /usr/local/bin/composer install --no-dev && rm -rf /root/.composer
# RUN chmod -R 0777 /var/www/html/storage

COPY docker/000-default-website.conf /etc/apache2/conf.d/000-default.conf
COPY docker/php.ini /etc/php/7.3/php.ini

RUN apk add --update supervisor && rm  -rf /tmp/* /var/cache/apk/*

RUN apk add --update --no-cache autoconf g++ make
RUN pecl install redis
RUN docker-php-ext-enable redis

WORKDIR /var/www/html/

EXPOSE 80

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]

