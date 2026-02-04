# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t tobi312/php:8.4-fpm-alpine-wsc -f alpine.fpm.wsc.Dockerfile .
ARG PHP_VERSION=8.4
FROM tobi312/php:${PHP_VERSION}-fpm-alpine-slim
ARG PHP_VERSION

ARG VCS_REF
ARG BUILD_DATE

SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP-FPM for WSC" \
	org.opencontainers.image.description="Alpine with PHP-FPM ${PHP_VERSION} for WSC (WoltLab Suite Core)" \
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

# PHP
RUN PHP_EXTENSIONS_LIST=" \
	#	ctype \
	#	curl \
	#	dom \
		exif \
		gd \
		gmp \
		imagick \
		intl \
		ldap \
	#	libxml \
	#	mbstring \
	#	opcache \
	#	openssl \
	##  PDO \
		pdo_mysql \
		redis \
	#	zlib \
 	" ; \
    install-php-extensions $PHP_EXTENSIONS_LIST ; \
    php -m