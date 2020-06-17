ARG PHP_VERSION=7.4
FROM php:${PHP_VERSION}-apache
ARG PHP_VERSION

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP+Apache2" \
	org.opencontainers.image.description="Debian with PHP7.4 and Apache2 on x86_64 arch" \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	org.opencontainers.image.source="https://github.com/Tob1asDocker/php"

ENV LANG C.UTF-8
ENV TERM=xterm
ENV CFLAGS="-I/usr/src/php"

RUN apt-get update; \
	apt-get install -y --no-install-recommends \
		git \
		gnupg2 \
		nano \
		zip unzip \
		wget \
		curl \
		patch \
		openssl \
		libssl-dev \
		libcurl4-openssl-dev \
		libevent-dev \
		libmagickwand-dev \
		libpq-dev \
		libxslt-dev \
		libldap2-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libjpeg-dev \
		libgmp-dev \
		libicu-dev \
		libgd-dev \
		libmemcached-dev \
		#libapache2-mod-rpaf \
		#libssh2-1-dev \
		libyaml-dev \
		libxml2-dev \
		zlib1g-dev \
		libbz2-dev \
		libsqlite3-dev \
		libexif-dev \
		libzip-dev \
		libonig-dev \
		libmhash-dev \
		libenchant-dev \
		libc-client-dev \
		libkrb5-dev \
		freetds-dev \
		firebird-dev \
		libpspell-dev aspell-en aspell-de \
		libsnmp-dev \
		libtidy-dev \
		file \
	; \
	rm -rf /var/lib/apt/lists/*

RUN dpkgArch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)" && echo "dpkgArch=${dpkgArch}"; \
	ln -s /usr/include/${dpkgArch}/gmp.h /usr/include/gmp.h; \
	#ln -fs /usr/lib/${dpkgArch}/libldap.so /usr/lib/; \
	ln -s /usr/lib/${dpkgArch}/libsybdb.a /usr/lib/; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-configure ldap --with-libdir="lib/${dpkgArch}"; \
	docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
	docker-php-ext-install \
		bcmath \
		bz2 \
		calendar \
		ctype \
		curl \
		dba \
		dom \
		enchant \
		exif \
		ffi \
		fileinfo \
		filter \
		ftp \
		gd \
		gettext \
		gmp \
		#hash \
		iconv \
		imap \
		intl \
		json \
		ldap \
		mbstring \
		mysqli \
		#oci8 \
		#odbc \
		opcache \
		#pcntl \
		pdo \
		pdo_dblib \
		pdo_firebird \
		pdo_mysql \
		#pdo_oci \
		#pdo_odbc \
		pdo_pgsql \
		pdo_sqlite \
		pgsql \
		phar \
		#posix \
		pspell \
		#readline \
		#reflection \
		session \
		shmop \
		simplexml \
		snmp \
		#soap \
		#sockets \
		#sodium \
		#spl \
		#standard \
		#sysvmsg \
		#sysvsem \
		#sysvshm \
		tidy \
		tokenizer \
		xml \
		xmlreader \
		#xmlrpc \
		xmlwriter \
		xsl \
		#zend_test \
		zip \
	; \
	#pecl install ssh2; \
	pecl install mongodb; \
	pecl install yaml; \
	pecl install memcached; \
	pecl install redis; \
	pecl install imagick; \
	pecl install APCu; \
	docker-php-ext-enable \
		#ssh2
		mongodb \
		yaml \
		memcached \
		redis \
		imagick \
		apcu \
	; \
	docker-php-source delete; \
	rm -rf /tmp/*; \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer ; chmod +x /usr/local/bin/composer; \
	cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh ; \
	#sed -i -e 's/\r$//' /usr/local/bin/entrypoint.sh ; \
	mkdir /entrypoint.d

#WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
