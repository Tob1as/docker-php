ARG PHP_VERSION=8.1
FROM tobi312/php:${PHP_VERSION}-apache-slim
ARG PHP_VERSION

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP+Apache2" \
	org.opencontainers.image.description="Debian with PHP ${PHP_VERSION} and Apache2" \
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
