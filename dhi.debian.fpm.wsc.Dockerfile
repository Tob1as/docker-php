# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t docker.io/tobi312/php:8.4-dhi-fpm-debian-wsc -f dhi.debian.fpm.wsc.Dockerfile .
# check: docker run --rm --name phptest -it docker.io/tobi312/php:8.4-dhi-fpm-debian-wsc -m
# https://hub.docker.com/hardened-images/catalog/dhi/php | short: https://dhi.io/catalog/php
# https://github.com/docker-hardened-images/catalog
ARG PHP_VERSION=8.4
ARG BUILD_PHP_VERSION=${PHP_VERSION}
ARG BUILD_OS=debian13
# =========================
# Stage 1: Build Extensions
# =========================
FROM dhi.io/php:${BUILD_PHP_VERSION}${BUILD_OS:+-${BUILD_OS}}-dev AS builder
ARG BUILD_PHP_VERSION

WORKDIR /tmp

# Install required system libraries for building PHP extensions
RUN apt-get update \ 
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        autoconf \
        build-essential \
        libjpeg-dev \
        libpng-dev \
        libxpm-dev \
        libfreetype6-dev \
        libicu-dev \
        libldap2-dev \
        libgmp-dev \
    && apt-get install -y \
        libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# =========================
# Core PHP Extensions
# =========================

# gd
RUN cd $PHP_SRC_DIR/ext/gd \
    && phpize \
    && ./configure --with-webp --with-jpeg --with-xpm --with-freetype \
    && make -j$(nproc) \
    && make install

# pdo_mysql
RUN cd $PHP_SRC_DIR/ext/pdo_mysql \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install

# ldap
RUN cd $PHP_SRC_DIR/ext/ldap \
    && phpize \
    && ./configure --with-ldap \
    && make -j$(nproc) \
    && make install

# gmp
RUN cd $PHP_SRC_DIR/ext/gmp \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install

# exif
RUN cd $PHP_SRC_DIR/ext/exif \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install

# =========================
# PECL Extensions
# =========================
WORKDIR /tmp

# Redis
RUN pecl download redis \
    && tar xzf redis-*.tgz \
	&& rm redis-*.tgz \
    && cd redis-* \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd ..

## Imagick
#RUN pecl download imagick \
#    && tar xzf imagick-*.tgz \
#	&& rm imagick-*.tgz \
#    && cd imagick-* \
#    && phpize \
#    && ./configure \
#    && make -j$(nproc) \
#    && make install \
#    && cd ..
	
# Enable all extensions
RUN echo "" \
    && echo "extension=gd.so" > $PHP_INI_DIR/conf.d/gd.ini \
    && echo "extension=pdo_mysql.so" > $PHP_INI_DIR/conf.d/pdo_mysql.ini \
    && echo "extension=ldap.so" > $PHP_INI_DIR/conf.d/ldap.ini \
    && echo "extension=gmp.so" > $PHP_INI_DIR/conf.d/gmp.ini \
    && echo "extension=exif.so" > $PHP_INI_DIR/conf.d/exif.ini \
    && echo "extension=redis.so" > $PHP_INI_DIR/conf.d/redis.ini \
    #&& echo "extension=imagick.so" > $PHP_INI_DIR/conf.d/imagick.ini \
    && echo ""

## create symlinks
#RUN ls -lah ${PHP_PREFIX}/lib/php/extensions/no-debug-non-zts-20240924/ \
#	&& mkdir -p /usr/local/lib/php \
#	&& ln -s $(php -r "echo ini_get('extension_dir');") /usr/local/lib/php/extensions \
#	&& ls -lah $PHP_INI_DIR/conf.d/ \
#	&& ln -s $PHP_INI_DIR/conf.d /usr/local/lib/php/conf.d

# =========================
# Stage 2: Package extractor
# =========================
# more see: https://github.com/Tob1as/docker-build-example/blob/main/distroless.debian.Dockerfile#L54-L100
FROM dhi.io/php:${BUILD_PHP_VERSION}${BUILD_OS:+-${BUILD_OS}}-dev AS deb-extractor

WORKDIR /tmp
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# List of packages for download separated by spaces.
ENV PACKAGE_LIST='libpng16-16t64 libwebp7 libjpeg62-turbo libxpm4 libfreetype6 libbz2-1.0 libsharpyuv0 libx11-6 libxau6 libxcb1 libxdmcp6'

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
    apt-get update && \
    apt-get install -y apt-rdepends tree && \
    # Search subpackages for package (apt-rdepends PACKAGE | grep -v "^ " | sort -u | tr '\n' ' ')
    #packages=$(for package in $PACKAGE_LIST; do \
    #    apt-rdepends $package 2>/dev/null | \
    #    grep -v "^ " | \
    #    grep -v "^PreDepends:" | \
    #    sort -u; \
    #done | sort -u) && \
    packages=$PACKAGE_LIST ; \
    # Download packages
    echo ">> Packages to Download: $(echo $packages | tr '\n' ' ')" && \
    apt-get download \
        $packages \
    && \
    mkdir -p /dpkg/var/lib/dpkg/status.d/ && \
    for deb in *.deb; do \
        package_name=$(dpkg-deb -I "${deb}" | awk '/^ Package: .*$/ {print $2}'); \
        echo "Processing: ${package_name}"; \
        dpkg --ctrl-tarfile "$deb" | tar -Oxf - ./control > "/dpkg/var/lib/dpkg/status.d/${package_name}"; \
        dpkg --extract "$deb" /dpkg || exit 10; \
    done \
    && \
    echo "Packages have been processed !"

# Remove unnecessary files extracted from deb packages like man pages and docs etc.
RUN find /dpkg/ -type d -empty -delete && \
    rm -r /dpkg/usr/share/doc/

# List directory and file structure
#RUN tree /dpkg

# =========================
# Stage 3: DHI FPM Image
# =========================
FROM dhi.io/php:${BUILD_PHP_VERSION}${BUILD_OS:+-${BUILD_OS}}-fpm AS production
ARG BUILD_PHP_VERSION
LABEL org.opencontainers.image.source="https://github.com/Tob1as/docker-php"
# Copy php extensions
COPY --from=builder ${PHP_PREFIX}/lib/php/extensions/ ${PHP_PREFIX}/lib/php/extensions/
COPY --from=builder ${PHP_PREFIX}/etc/php/conf.d ${PHP_PREFIX}/etc/php/conf.d
# Copy the libraries from the extractor stage into root
COPY --from=deb-extractor /dpkg /
