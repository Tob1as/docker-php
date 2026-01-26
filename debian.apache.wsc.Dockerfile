# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t tobi312/php:8.4-apache-wsc -f debian.apache.wsc.Dockerfile .
ARG PHP_VERSION=8.4
FROM tobi312/php:${PHP_VERSION}-apache-slim
ARG PHP_VERSION

ARG VCS_REF
ARG BUILD_DATE

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP+Apache2 for WSC" \
	org.opencontainers.image.description="Debian with PHP ${PHP_VERSION} and Apache2 for WSC (WoltLab Suite Core)" \
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
RUN \
	PHP_EXTENSIONS_LIST_BASE=" \
	#	ctype \
	#	curl \
	#	dom \
		exif \
		gd \
		gmp \
		imagick \
		intl \
	#	libxml \
	#	mbstring \
	#	openssl \
	##  PDO \
		pdo_mysql \
	#	zlib \
 	" ; \
	PHP_EXTENSIONS_LIST_OPTIONAL=" \
	#	opcache \
	#	curl \
		ldap \
		redis \
	" ; \
	PHP_EXTENSIONS_LIST="$PHP_EXTENSIONS_LIST_BASE $PHP_EXTENSIONS_LIST_OPTIONAL" ; \
    \
    install-php-extensions $PHP_EXTENSIONS_LIST ; \
    php -m

# opcache config
#COPY conf/php_55-opcache.ini /usr/local/etc/php/conf.d/55-opcache.ini
