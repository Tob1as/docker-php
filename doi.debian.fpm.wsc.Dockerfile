# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t docker.io/tobi312/php:8.4-doi-fpm-debian-wsc -f doi.debian.fpm.wsc.Dockerfile .
# check: docker run --rm --name phpcheck -it docker.io/tobi312/php:8.4-doi-fpm-debian-wsc -m
# https://github.com/Tob1as/docker-php
# 
# https://github.com/docker-library/php
# https://hub.docker.com/_/php/
#
# WSC = WoltLab Suite Core <https://www.woltlab.com/en/>
# PHP Extensions Requirements:
# - https://manual.woltlab.com/en/requirements/#php-extensions
# - https://manual.woltlab.com/en/elasticsearch/#system-requirements
# - https://manual.woltlab.com/en/ldap/#system-requirements
# Note: Some PHP Extensions/Modules are installed by default:
#       ctype curl dom libxml mbstring openssl opcache PDO zlib
# These are still needed: exif gd gmp imagick intl ldap pdo_mysql redis
#
ARG PHP_VERSION=8.4
ARG BUILD_PHP_VERSION=${PHP_VERSION}
FROM php:${BUILD_PHP_VERSION}-fpm
ARG BUILD_PHP_VERSION

ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	  org.opencontainers.image.title="DOI PHP-FPM for WSC" \
	  org.opencontainers.image.description="DOI (Docker Official Images): Debian with PHP-FPM ${BUILD_PHP_VERSION} for WSC (WoltLab Suite Core)" \
	  org.opencontainers.image.created="${BUILD_DATE}" \
	  org.opencontainers.image.revision="${VCS_REF}" \
	  org.opencontainers.image.licenses="MIT" \
	  org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	  org.opencontainers.image.source="https://github.com/Tob1as/docker-php"

# persistent dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        wget \
        netcat-openbsd \
        libfcgi-bin \
    ; \
    rm -rf /var/lib/apt/lists/* ; \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini


# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # gd
        #libavif-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        #libxpm-dev \
        # gmp
        libgmp-dev \
        # intl
        libicu-dev \
        # ldap
        libldap2-dev \
        # imagick
        libmagickwand-dev \
    ; \
    \
    docker-php-ext-configure gd \
        #--with-avif \
        --with-freetype \
        --with-jpeg \
        --with-webp \
        #--with-xpm \
    ; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
    docker-php-ext-install -j "$(nproc)" \
        exif \
        gd \
        gmp \
        intl \
        ldap \
        pdo_mysql \
    ; \
    \
    pecl install imagick; \
    pecl install redis; \
    docker-php-ext-enable \
        imagick \
        redis \
    ; \
    rm -r /tmp/pear; \
    \
    # some misbehaving extensions end up outputting to stdout
    out="$(php -r 'exit(0);')"; \
    [ -z "$out" ]; \
    err="$(php -r 'exit(0);' 3>&1 1>&2 2>&3)"; \
    [ -z "$err" ]; \
    \
    extDir="$(php -r 'echo ini_get("extension_dir");')"; \
    [ -d "$extDir" ]; \
    # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$extDir"/*.so \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    \
    ! { ldd "$extDir"/*.so | grep 'not found'; }; \
    # check for output like "PHP Warning:  PHP Startup: Unable to load dynamic library 'foo' (tried: ...)
    err="$(php --version 3>&1 1>&2 2>&3)"; \
    [ -z "$err" ] ; \
    php -m
