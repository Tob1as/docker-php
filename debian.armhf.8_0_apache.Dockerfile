ARG PHP_VERSION=8.0.0
FROM arm32v7/php:${PHP_VERSION}-apache
ARG PHP_VERSION

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP+Apache2" \
	org.opencontainers.image.description="Debian with PHP 8.0 and Apache2 on ARM arch" \
	org.opencontainers.image.licenses="MIT" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	org.opencontainers.image.source="https://github.com/Tob1asDocker/php"

ENV LANG C.UTF-8
ENV TERM=xterm
ENV CFLAGS="-I/usr/src/php"

# TOOLS
#RUN apt-get update; \
#	apt-get install -y --no-install-recommends \
#		curl \
#		wget \
#		#git \
#		#zip unzip \
#		#patch \
#	; \
#	rm -rf /var/lib/apt/lists/*

# COMPOSER
RUN \
	curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer ; \
	chmod +x /usr/local/bin/composer

# PHP-EXTENSION-INSTALLER
RUN \
	PHP_EXTENSION_INSTALLER_VERSION=$(curl -s https://api.github.com/repos/mlocati/docker-php-extension-installer/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
	echo "install-php-extensions Version: ${PHP_EXTENSION_INSTALLER_VERSION}" ; \
	curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/download/${PHP_EXTENSION_INSTALLER_VERSION}/install-php-extensions -o /usr/local/bin/install-php-extensions ; \
	chmod +x /usr/local/bin/install-php-extensions

# PHP
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini ; \
	install-php-extensions \
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

# ENTRYPOINT
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh ; \
	#sed -i -e 's/\r$//' /usr/local/bin/entrypoint.sh ; \
	mkdir /entrypoint.d

#WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
