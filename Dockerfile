##########################################################
# Base image used only to download Tiny Tiny RSS archive #
# to optimize the layer caching in FPM and daemon images #
##########################################################

FROM debian:buster-slim as ttrss

WORKDIR /tmp

ADD https://git.tt-rss.org/fox/tt-rss/archive/master.tar.gz .

RUN tar -xvzf master.tar.gz

################################################################
# FPM image to configure and run Tiny Tiny RSS.                #
# It will also runs the daemon to regularly refresh the feeds. #
################################################################

FROM debian:buster-slim AS fpm

RUN echo 'APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;' > /etc/apt/apt.conf.d/01-no-recommended && \
    echo 'path-exclude=/usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/groff/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/linda/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/lintian/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    apt-get update && \
    apt-get --yes install apt-transport-https ca-certificates gpg gpg-agent wget && \
    echo 'deb https://packages.sury.org/php/ buster main' > /etc/apt/sources.list.d/sury.list && \
    wget -O sury.gpg https://packages.sury.org/php/apt.gpg && apt-key add sury.gpg && rm sury.gpg && \
    apt-get update && \
    apt-get --yes install \
        php7.3-apcu \
        php7.3-cli \
        php7.3-fpm \
        php7.3-intl \
        php7.3-json \
        php7.3-mbstring \
        php7.3-opcache \
        php7.3-pdo \
        php7.3-pgsql \
        php7.3-xml && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /run/php

COPY php/ttrss.ini /etc/php/7.3/cli/conf.d/99-ttrss.ini
COPY php/ttrss.ini /etc/php/7.3/fpm/conf.d/99-ttrss.ini
COPY fpm/ttrss.conf /etc/php/7.3/fpm/pool.d/zzz-ttrss.conf

COPY --from=ttrss --chown=www-data:www-data /tmp/tt-rss /srv/ttrss

RUN sed -i "s/define('SESSION_COOKIE_LIFETIME'.*/define('SESSION_COOKIE_LIFETIME', 86400*30);/" /srv/ttrss/config.php-dist

VOLUME /srv/ttrss
WORKDIR /srv/ttrss

######################################
# Nginx image to be ran with FPM one #
######################################

FROM nginx AS nginx

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /srv/ttrss && chown -R www-data:www-data /srv/ttrss

VOLUME /srv/ttrss
WORKDIR /srv/ttrss
