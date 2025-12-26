ARG PHP_VERSION=8.4
FROM tobi312/php:${PHP_VERSION}-apache-slim
ARG PHP_VERSION

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP+Apache2" \
	org.opencontainers.image.description="Debian with PHP ${PHP_VERSION} and Apache2" \
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
	#	gd \
		gettext \
		gmp \
		imagick \
		imap \
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
    \
    ARCH=`uname -m` ; \
    echo "ARCH=$ARCH" ; \
    if [[ "$ARCH" == "armv"* ]]; then \
		# fix: /usr/lib/gcc/arm-linux-gnueabihf/10/include/arm_neon.h:10403:1: error: inlining failed in call to ‘always_inline’ ‘vld1q_u8’: target specific option mismatch
		apt-get update ; \
		apt-get install -y --no-install-recommends libfreetype6 libjpeg62-turbo ^libpng[0-9]+-[0-9]+$ libxpm4 ^libwebp[0-9]+$ ; \
		temp_package="libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libwebp-dev" ; \
		apt-get install -y --no-install-recommends $temp_package ; \
		docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype ; \
		docker-php-ext-install -j$(nproc) gd ; \
		apt-get purge -y $temp_package ; apt-get autoremove -y ; \
		rm -rf /var/lib/apt/lists/* ; \
		#php -i | grep 'GD' ; \
    else \
        PHP_EXTENSIONS_LIST="$PHP_EXTENSIONS_LIST gd" ; \
    fi ; \
    # bugfix/workarround: https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=libmemcachedutil2
    DISTRO="$(cat /etc/os-release | grep -E ^ID= | cut -d = -f 2)" ; \
    DISTRO_VERSION_NUMBER="$(cat /etc/os-release | grep -E ^VERSION_ID= | cut -d = -f 2 | cut -d '"' -f 2 | cut -d . -f 1,2)" ; \
    if [ "$DISTRO" = "debian" ] && [ "$DISTRO_VERSION_NUMBER" -ge 13 ]; then \
        if grep -q 'libmemcachedutil2' /usr/local/bin/install-php-extensions && \
           ! grep -q 'libmemcachedutil2t64' /usr/local/bin/install-php-extensions; then \
            echo ">> Applying libmemcachedutil2 → libmemcachedutil2t64 workaround"; \
            sed -i 's/libmemcachedutil2/libmemcachedutil2t64/g' /usr/local/bin/install-php-extensions; \
        else \
            echo ">> Workaround not needed (already fixed upstream)"; \
        fi; \
    fi; \
    install-php-extensions $PHP_EXTENSIONS_LIST ; \
    php -m
