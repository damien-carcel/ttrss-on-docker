FROM debian:buster-slim as debian

RUN echo 'APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;' > /etc/apt/apt.conf.d/01-no-recommended && \
    echo 'path-exclude=/usr/share/man/*' > /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
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
        php7.3-xml && \
    apt-get purge --yes apt-transport-https ca-certificates gpg gpg-agent wget && \
    apt-get clean && \
    apt-get --yes autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
           /usr/share/doc/* /usr/share/groff/* /usr/share/info/* /usr/share/linda/* \
           /usr/share/lintian/* /usr/share/locale/* /usr/share/man/*

RUN mkdir -p /run/php && sed -i "s/listen = .*/listen = 9000/" /etc/php/7.3/fpm/pool.d/www.conf

# TODO: Configure properly PHP CLI and FPM

CMD ["php-fpm7.3", "-F"]
