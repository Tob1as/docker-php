FROM php:5.6-apache

MAINTAINER Tobias Hargesheimer <docker@ison.ws>

RUN apt-get update && apt-get install -y \
	git \
	nano \
	zip \
	wget \
	imagemagick \
	libpq-dev \
	libxslt-dev \
	libldap2-dev \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libpng12-dev \
	libgmp-dev \
	libicu-dev \
	libmemcached-dev \
	libssh2-1-dev \
	libyaml-dev \
	zlib1g-dev \
	libbz2-dev \
	libsqlite3-dev \
	--no-install-recommends && \
	rm -rf /var/lib/apt/lists/*
	
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
	ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ && \
	docker-php-ext-install \
	xsl \
	pdo_mysql \
	mysqli \
	mysql \
	pdo_pgsql \
	pgsql \
	pdo_sqlite \
	ldap \
	iconv \
	soap \
	intl \
	mcrypt \
	gmp \
	zip \
	bz2 \
	ftp \
	sockets \
	bcmath \
	mbstring \
	pcntl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN echo Europe/Berlin >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata && \
	echo "date.timezone=Europe/Berlin" > /usr/local/etc/php/php.ini && echo "display_errors = On" >> /usr/local/etc/php/php.ini
