# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t docker.io/tobi312/php:8.4-dhi-fpm-alpine-wsc -f dhi.alpine.fpm.wsc.Dockerfile .
# check: docker run --rm --name phptest -it docker.io/tobi312/php:8.4-dhi-fpm-alpine-wsc -m
# https://hub.docker.com/hardened-images/catalog/dhi/php | short: https://dhi.io/catalog/php
# https://github.com/docker-hardened-images/catalog
ARG PHP_VERSION=8.4
ARG BUILD_PHP_VERSION=${PHP_VERSION}
ARG BUILD_OS=alpine3.22
# =========================
# Stage 0: Build Base Image
# =========================
FROM dhi.io/php:${BUILD_PHP_VERSION}${BUILD_OS:+-${BUILD_OS}}-dev AS dev
ARG BUILD_PHP_VERSION

# =========================
# Stage 1: Build Extensions
# =========================
FROM dev AS builder
ARG BUILD_PHP_VERSION

WORKDIR /tmp

# Install required system libraries for building PHP extensions
RUN apk add --no-cache \
    git \
    unzip \
    autoconf \
    build-base \
    linux-headers \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    freetype-dev \
    icu-dev \
    openldap-dev \
    gmp-dev \
    imagemagick-dev

# =========================
# Preparation:
# - move existing extensions, such as opcache, so that 
#   they are not copied into the final image (again).
# =========================

RUN mkdir -p /tmp/extension/ \
    #&& ls ${PHP_PREFIX}/etc/php/conf.d/ \
    && mv ${PHP_PREFIX}/etc/php/conf.d/* /tmp/extension/ \
    && VAR_PHP_EXTENSION_DIR=$(php -r "echo ini_get('extension_dir');") \
    #&& ls ${VAR_PHP_EXTENSION_DIR} \
    && mv ${VAR_PHP_EXTENSION_DIR}/* /tmp/extension/ \
    && ls /tmp/extension/

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

# Redis <https://github.com/phpredis/phpredis/>
RUN pecl download redis \
    && tar xzf redis-*.tgz \
	&& rm redis-*.tgz \
    && cd redis-* \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd ..

# Imagick <https://github.com/Imagick/imagick>
RUN pecl download imagick \
    && tar xzf imagick-*.tgz \
    && rm imagick-*.tgz \
    && cd imagick-* \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd ..
	
# Enable all extensions
RUN echo "" \
    && echo "extension=gd.so" > $PHP_INI_DIR/conf.d/docker-php-ext-gd.ini \
    && echo "extension=pdo_mysql.so" > $PHP_INI_DIR/conf.d/docker-php-ext-pdo_mysql.ini \
    && echo "extension=ldap.so" > $PHP_INI_DIR/conf.d/docker-php-ext-ldap.ini \
    && echo "extension=gmp.so" > $PHP_INI_DIR/conf.d/docker-php-ext-gmp.ini \
    && echo "extension=exif.so" > $PHP_INI_DIR/conf.d/docker-php-ext-exif.ini \
    && echo "extension=redis.so" > $PHP_INI_DIR/conf.d/docker-php-ext-redis.ini \
    && echo "extension=imagick.so" > $PHP_INI_DIR/conf.d/docker-php-ext-imagick.ini \
    && echo ""

# =========================
# Stage 2: Package extractor
# =========================
# more see: https://github.com/Tob1as/docker-build-example/blob/main/distroless.debian.Dockerfile#L54-L100
FROM dev AS apk-extractor

WORKDIR /tmp
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# List of packages for download separated by spaces. (Helpful: https://pkgs.alpinelinux.org/contents)
ENV PACKAGE_LIST_LDAP='libldap libsasl'
ENV PACKAGE_LIST_GD="gmp libpng libwebp libjpeg-turbo freetype libsharpyuv libxpm libx11 libbz2 libxcb libxau libxdmcp libbsd libmd"
ENV PACKAGE_LIST_IMAGICK="libgomp imagemagick-libs lcms2 fftw-double-libs fontconfig libxext libltdl libexpat"
ENV PACKAGE_LIST="${PACKAGE_LIST_LDAP} ${PACKAGE_LIST_GD} ${PACKAGE_LIST_IMAGICK}"

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
    #apk fetch --no-cache --recursive $PACKAGE_LIST && \
    apk fetch --no-cache $PACKAGE_LIST && \
    mkdir -p /apkroot && \
    for pkg in *.apk; do \
        tar -xzf "$pkg" -C /apkroot; \
    done && \
    echo "Packages have been processed !"

# List directory and file structure
#RUN tree /apkroot

# Delete everything except libraries (*.so) that are required for PHP extensions
RUN find /apkroot -mindepth 1 \
    ! -path '/apkroot/usr' \
    ! -path '/apkroot/usr/lib' \
    ! -path '/apkroot/usr/lib/*' \
    -exec rm -rf {} + \
    && find /apkroot -type f \( -name '*.a' -o -name '*.la' \) -exec rm -f {} +

# List directory and file structure
RUN tree /apkroot

# =========================
# Stage 3: DHI FPM Image
# =========================
FROM dhi.io/php:${BUILD_PHP_VERSION}${BUILD_OS:+-${BUILD_OS}}-fpm AS production
ARG BUILD_PHP_VERSION
#ARG BUILD_OS
ARG VCS_REF
ARG BUILD_DATE
LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
      org.opencontainers.image.title="DHI PHP-FPM for WSC" \
      org.opencontainers.image.description="DHI (Docker Hardened Images): Alpine with PHP-FPM ${BUILD_PHP_VERSION} for WSC (WoltLab Suite Core)" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-php"
# Copy php extensions
COPY --from=builder ${PHP_PREFIX}/lib/php/extensions/ ${PHP_PREFIX}/lib/php/extensions/
COPY --from=builder ${PHP_PREFIX}/etc/php/conf.d/ ${PHP_PREFIX}/etc/php/conf.d/
# Copy the libraries from the extractor stage into root
COPY --from=apk-extractor /apkroot /
