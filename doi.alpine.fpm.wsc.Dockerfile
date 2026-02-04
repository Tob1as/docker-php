# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t docker.io/tobi312/php:8.4-doi-fpm-alpine-wsc -f doi.alpine.fpm.wsc.Dockerfile .
# check: docker run --rm --name phptest -it docker.io/tobi312/php:8.4-doi-fpm-alpine-wsc -m
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

# WSC = WoltLab Suite Core <https://www.woltlab.com/en/>
# PHP Extensions Requirements:
# - https://manual.woltlab.com/en/requirements/#php-extensions
# - https://manual.woltlab.com/en/elasticsearch/#system-requirements
# - https://manual.woltlab.com/en/ldap/#system-requirements
# Note: Some PHP Extensions/Modules are installed by default, so these have been commented out.

RUN \
    PHP_EXTENSION_INSTALLER_VERSION=$(curl -s https://api.github.com/repos/mlocati/docker-php-extension-installer/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
    echo "install-php-extensions Version: ${PHP_EXTENSION_INSTALLER_VERSION}" ; \
    curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/download/${PHP_EXTENSION_INSTALLER_VERSION}/install-php-extensions -o /usr/local/bin/install-php-extensions ; \
    chmod +x /usr/local/bin/install-php-extensions ; \
    PHP_EXTENSIONS_LIST=" \
    #   ctype \
    #   curl \
    #   dom \
        exif \
        gd \
        gmp \
        imagick \
        intl \
        ldap \
    #   libxml \
    #   mbstring \
    #   openssl \
    #   opcache \
    #   PDO \
        pdo_mysql \
        redis \
    #   zlib \
    " ; \
    install-php-extensions $PHP_EXTENSIONS_LIST ; \
    php -m ; \
    apk --no-cache add \
        tzdata \
        fcgi \
    ; \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini