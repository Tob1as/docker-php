FROM php:5.6-fpm

MAINTAINER Tobias Hargesheimer <docker@ison.ws>

ENV LANG C.UTF-8
ENV TZ Europe/Berlin
ENV TERM=xterm

RUN apt-get update && apt-get install -y \
	git \
	nano \
	zip unzip \
	wget \
	curl \
	openssl \
	libmagickwand-dev \
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
	#libssh2-1-dev \
	libyaml-dev \
	zlib1g-dev \
	libbz2-dev \
	libsqlite3-dev \
	libexif-dev \
	file \
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
	exif \
	fileinfo \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
	docker-php-ext-install gd && \
	pecl install yaml-1.3.1 && \
	pecl install memcached-2.2.0 && \
	pecl install redis-3.1.3 && \
	pecl install imagick-3.4.3 && \
	docker-php-ext-enable yaml && \
	docker-php-ext-enable memcached && \
	docker-php-ext-enable redis && \
	docker-php-ext-enable imagick && \
	rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
	
#VOLUME /var/www/html

#EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
