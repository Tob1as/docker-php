ARG PHP_VERSION=8.4
FROM tobi312/php:${PHP_VERSION}-apache-slim
ARG PHP_VERSION

ARG VCS_REF
ARG BUILD_DATE

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP+Apache2" \
	org.opencontainers.image.description="Debian with PHP ${PHP_VERSION} and Apache2" \
	org.opencontainers.image.created="${BUILD_DATE}" \
	org.opencontainers.image.revision="${VCS_REF}" \
	org.opencontainers.image.licenses="MIT" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	org.opencontainers.image.source="https://github.com/Tob1as/docker-php"

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
	#	imap \
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
    install-php-extensions $PHP_EXTENSIONS_LIST ; \
    php -m
