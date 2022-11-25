ARG PHP_VERSION=8.1
FROM tobi312/php:${PHP_VERSION}-fpm-alpine-slim
ARG PHP_VERSION

SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP-FPM" \
	org.opencontainers.image.description="Alpine with PHP-FPM ${PHP_VERSION}" \
	org.opencontainers.image.licenses="MIT" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	org.opencontainers.image.source="https://github.com/Tob1asDocker/php"

# PHP
RUN \
	PHP_EXTENSIONS_LIST=" \
		@composer \
		apcu \
		bcmath \
		bz2 \
		calendar \
		dba \
		enchant \
		exif \
		ffi \
		gd \
		gettext \
		gmp \
		imagick \
		imap \
		intl \
		ldap \
		memcached \
		mongodb \
		mysqli \
		opcache \
		pdo_dblib \
		pdo_mysql \
		pdo_pgsql \
		pgsql \
		pspell \
		redis \
		shmop \
		snmp \
		tidy \
		xsl \
		yaml \
		zip \
	" \
	; \
    \
    ARCH=`uname -m` ; \
    echo "ARCH=$ARCH" ; \
	install-php-extensions $PHP_EXTENSIONS_LIST ; \
	php -m
