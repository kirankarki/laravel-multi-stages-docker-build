#
# PHP Dependencies
#
FROM composer:1.9.0 as vendor

COPY database/ database/

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist


#
# Frontend
#
FROM node:10.16 as frontend

RUN mkdir -p /app/public

COPY package.json webpack.mix.js yarn.lock /app/
COPY resources/js /app/resources/js
COPY resources/sass /app/resources/sass

WORKDIR /app

RUN yarn install && yarn production


# #
# # Application
# #
FROM php:7.2-apache-stretch

COPY . /var/www/html
COPY --from=vendor /app/vendor/ /var/www/html/vendor/
COPY --from=frontend /app/public/js/ /var/www/html/public/js/
COPY --from=frontend /app/public/css/ /var/www/html/public/css/
COPY --from=frontend /app/mix-manifest.json /var/www/html/mix-manifest.json