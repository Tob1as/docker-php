# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t docker.io/tobi312/php:8.4-doi-fpm-alpine-wsc -f doi.alpine.fpm.wsc.Dockerfile .
# check: docker run --rm --name phpcheck -it docker.io/tobi312/php:8.4-doi-fpm-alpine-wsc -m
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
FROM php:${BUILD_PHP_VERSION}-fpm-alpine
ARG BUILD_PHP_VERSION

ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	  org.opencontainers.image.title="DOI PHP-FPM for WSC" \
	  org.opencontainers.image.description="DOI (Docker Official Images): Alpine with PHP-FPM ${BUILD_PHP_VERSION} for WSC (WoltLab Suite Core)" \
	  org.opencontainers.image.created="${BUILD_DATE}" \
	  org.opencontainers.image.revision="${VCS_REF}" \
	  org.opencontainers.image.licenses="MIT" \
	  org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	  org.opencontainers.image.source="https://github.com/Tob1as/docker-php"

# persistent dependencies
RUN set -eux; \
    apk add --no-cache \
        tzdata \
        fcgi \
        # Alpine package for "imagemagick" contains ~120 .so files
		imagemagick \
    ; \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# install the PHP extensions we need
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        autoconf \
        # gd
        #libavif-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        #libxpm-dev \
        # gmp
        gmp-dev \
        # intl
        icu-dev \
        # ldap
        openldap-dev \
        # imagick
        imagemagick-dev \
    ; \
    \
    docker-php-ext-configure gd \
        #--with-avif \
        --with-freetype \
        --with-jpeg \
        --with-webp \
        #--with-xpm \
    ; \
    docker-php-ext-configure ldap; \
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
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive "$extDir" \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
    apk add --no-network --virtual .wsc-phpexts-rundeps $runDeps; \
    apk del --no-network .build-deps ; \
    \
    ! { ldd "$extDir"/*.so | grep 'not found'; }; \
    # check for output like "PHP Warning:  PHP Startup: Unable to load dynamic library 'foo' (tried: ...)
    err="$(php --version 3>&1 1>&2 2>&3)"; \
    [ -z "$err" ] ; \
    php -m
