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
RUN install-php-extensions \
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
	#grpc \
	#igbinary \
	imagick \
	imap \
	intl \
	ldap \
	#mailparse \
	#maxminddb \
	#mcrypt \
	memcached \
	mongodb \
	#msgpack \
	mysqli \
	#oauth \
	#oci8 \
	#odbc \
	opcache \
	#pcntl \
	#pcov \
	pdo_dblib \
	#pdo_firebird \
	pdo_mysql \
	##pdo_oci \
	#pdo_odbc \
	pdo_pgsql \
	pgsql \
	#protobuf \
	pspell \
	#raphf \
	redis \
	shmop \
	snmp \
	#soap \
	#sockets \
	#solr \
	##ssh2 \
	#sysvmsg \
	#sysvsem \
	#sysvshm \
	tidy \
	#timezonedb \
	#uuid \
	#xdebug \
	xsl \
	yaml \
	zip
