FROM php:7.0-fpm-alpine

MAINTAINER Tobias Hargesheimer <docker@ison.ws>

ENV LANG C.UTF-8
ENV TZ Europe/Berlin
ENV TERM=xterm
	
RUN apk --no-cache add \
	git \
	nano \
	zip unzip \
	wget \
	curl \
	openssl \
	libressl-dev \
	imagemagick-dev \
	postgresql-dev \
	libxslt-dev \
	openldap-dev \
	freetype-dev \
	libjpeg-turbo-dev \
	libmcrypt-dev \
	libpng-dev \
	gmp-dev \
	icu-dev \
	libmemcached-dev \
	#libssh2-dev \
	yaml-dev \
	zlib-dev \
	bzip2-dev \
	sqlite-dev \
	libexif-dev \
	file
	
#RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/
RUN docker-php-ext-install \
	xsl \
	pdo_mysql \
	mysqli \
	#mysql \
	pdo_pgsql \
	pgsql \
	pdo_sqlite \
	#ldap \
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
	#pecl install xdebug-2.6.1 && \
	pecl install mongodb-1.5.3 && \
	#pecl install ssh2-0.13 && \
	pecl install yaml-2.0.2 && \
	pecl install memcached-3.0.4 && \
	pecl install redis-4.1.1 && \
	pecl install imagick-3.4.3 && \
	docker-php-ext-enable mongodb && \
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
