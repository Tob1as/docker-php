# build: docker build --no-cache --progress=plain --target=production-alpine -t docker.io/tobi312/php:dhi-helper-alpine -f dhi.helper.Dockerfile .
ARG ALPINE_OS_VERSION=3.23
ARG DEBIAN_OS_VERSION=trixie
FROM dhi.io/alpine-base:${ALPINE_OS_VERSION}-dev AS dev-alpine

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

COPY <<'EOF' /usr/local/bin/php-fpm-healthcheck.sh
#!/bin/sh
# required: fcgi (alpine) or libfcgi-bin (debian)
: "${PHP_FPM_STATUS_HOST:="127.0.0.1"}"       # set host
: "${PHP_FPM_STATUS_PORT:="9001"}"            # PHP-FPM Status/Ping Port (default: 9000, but here use 9001)
: "${PHP_FPM_PING_PATH:="/php_fpm_ping"}"     # (default: /ping, but here use /php_fpm_ping)
echo ">> FCGI Settings: Host=${PHP_FPM_STATUS_HOST}, Port=${PHP_FPM_STATUS_PORT}, Path=${PHP_FPM_PING_PATH}"
SCRIPT_NAME="${PHP_FPM_PING_PATH}" SCRIPT_FILENAME="${PHP_FPM_PING_PATH}" REQUEST_METHOD=GET cgi-fcgi -bind -connect "${PHP_FPM_PING_HOST}:${PHP_FPM_STATUS_PORT}" >/dev/null 2>&1
echo $?
EOF

RUN chmod +x /usr/local/bin/*.sh


FROM dev-alpine AS builder-alpine

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

WORKDIR /tmp

ENV PACKAGE_LIST_CURL=""
ENV PACKAGE_LIST_NANO=""
ENV PACKAGE_LIST_DB=""
ENV PACKAGE_LIST_Q=""
# example package extractor: https://github.com/Tob1as/docker-php/blob/master/dhi.alpine.fpm.wsc.Dockerfile#L131
# List of packages for download separated by spaces.
ENV PACKAGE_LIST_CURL="curl libcurl zlib c-ares nghttp3 nghttp2-libs libidn2 libpsl libssl3 libcrypto3 zstd-libs brotli-libs libunistring"
#ENV PACKAGE_LIST_NANO="nano libncursesw ncurses-terminfo-base"
ENV PACKAGE_LIST_DB="mysql-client mariadb-client libstdc++ libgcc mariadb-connector-c"
#ENV PACKAGE_LIST_DB="${PACKAGE_LIST_DB} mariadb-backup pcre2 libaio"
ENV PACKAGE_LIST_Q="jq oniguruma yq-go"
ENV PACKAGE_LIST="fcgi unzip kubectl ${PACKAGE_LIST_CURL} ${PACKAGE_LIST_NANO} ${PACKAGE_LIST_DB} ${PACKAGE_LIST_Q}"
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

COPY --from=dev-alpine /usr/local/bin/php-fpm-healthcheck.sh /apkroot/usr/local/bin/php-fpm-healthcheck.sh

RUN tree /apkroot


FROM dhi.io/alpine-base:${ALPINE_OS_VERSION} AS production-alpine
ARG BUILD_PHP_VERSION
ARG VCS_REF
ARG BUILD_DATE
#ENV TERM=xterm
LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
      org.opencontainers.image.title="Helper tools (dhi alpine)" \
      org.opencontainers.image.description="DHI (Docker Hardened Images): Helper tools on Alpine" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-php"
# Copy the libraries from the extractor/dev stage into root
COPY --from=builder-alpine /apkroot /
WORKDIR /tmp
#USER nonroot
CMD [ "tail", "-f", "/dev/null" ]


FROM dhi.io/debian-base:${DEBIAN_OS_VERSION} AS production-debian
ARG BUILD_PHP_VERSION
ARG VCS_REF
ARG BUILD_DATE
#ENV TERM=xterm
LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
      org.opencontainers.image.title="Helper tools (dhi debian)" \
      org.opencontainers.image.description="DHI (Docker Hardened Images): Helper tools on Debian" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
      org.opencontainers.image.source="https://github.com/Tob1as/docker-php"

#USER root

RUN apt-get update && \
    apt-get install -y \
        libfcgi-bin \
        unzip \
        curl \
        wget \
        netcat-openbsd \
        #nano \
        mariadb-client \
        jq \
        #yq \
        kubectl \
    && \
    rm -rf /var/lib/apt/lists/*

COPY --from=dev-alpine /usr/local/bin/php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck.sh

WORKDIR /tmp
USER nonroot
CMD [ "tail", "-f", "/dev/null" ]
