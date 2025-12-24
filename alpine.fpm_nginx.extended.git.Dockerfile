ARG PHP_VERSION=8.4
ARG ARCH="amd64"

FROM golang:alpine AS builder
ARG ARCH

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GO111MODULE on
ENV GOOS linux
ENV GOARCH ${ARCH}

RUN \
    apk add --no-cache git ; \
    cd /go ; \
    PHP_FPM_EXPORTER_VERSION=$(wget -qO- https://api.github.com/repos/hipages/php-fpm_exporter/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
    echo "PHP_FPM_EXPORTER_VERSION=${PHP_FPM_EXPORTER_VERSION}" ; \
    git clone --branch ${PHP_FPM_EXPORTER_VERSION} https://github.com/hipages/php-fpm_exporter.git ; \
    cd php-fpm_exporter/ ; \
    BUILD_VERSION=$(echo ${PHP_FPM_EXPORTER_VERSION} | sed 's/[^.0-9][^.0-9]*//g') ; \
    VCS_REF=$(git rev-parse HEAD) ; \
    BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') ; \
    #go get -d -v ; \
    go build -trimpath -a -v -ldflags "-X main.version=${BUILD_VERSION} -X main.commit=${VCS_REF} -X main.date=${BUILD_DATE}" -o "/go/bin/php-fpm-exporter" ; \
    echo "php-fpm_exporter build finished!"

FROM tobi312/php:${PHP_VERSION}-fpm-nginx-alpine
ARG PHP_VERSION
ARG ARCH

# set environment variable
ENV ENABLE_NGINX_STATUS=1 \
    ENABLE_PHP_FPM_STATUS=1 \
    WWW_USER=www-data \
    ARCH="${ARCH}" \
    TARGETARCH="${ARCH}" \
    NGINX_EXPORTER="--nginx.scrape-uri='http://localhost/nginx_status' --web.listen-address=':9113' --web.telemetry-path='/metrics' --no-nginx.ssl-verify" \
    PHP_FPM_EXPORTER="server --phpfpm.scrape-uri='tcp://127.0.0.1:9000/php_fpm_status' --web.listen-address=':9253' --web.telemetry-path='/metrics' --log.level=info --phpfpm.fix-process-count=false"

# install tools
#RUN apk --no-cache add \
#        curl \
#        unzip \
#        ca-certificates \
#        tzdata

# install Nginx Exporter (latest release version) <https://github.com/nginxinc/nginx-prometheus-exporter>
RUN \
    NGINX_EXPORTER_VERSION=$(curl -s https://api.github.com/repos/nginxinc/nginx-prometheus-exporter/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
    echo "NGINX_EXPORTER_VERSION=${NGINX_EXPORTER_VERSION}" ; \
    curl -sSL https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/${NGINX_EXPORTER_VERSION}/nginx-prometheus-exporter_$(echo ${NGINX_EXPORTER_VERSION} | sed 's/[^.0-9][^.0-9]*//g')_linux_${TARGETARCH}.tar.gz | tar xvz -C /usr/local/bin ; \
    chmod +x /usr/local/bin/nginx-prometheus-exporter \
    ; \
    { \
        echo ''; \
        echo '[program:exporter-nginx]'; \
        echo 'command=sh -c "sleep 5 && /usr/local/bin/nginx-prometheus-exporter %(ENV_NGINX_EXPORTER)s"'; \
        echo "user=%(ENV_WWW_USER)s"; \
        echo 'stdout_logfile=/dev/stdout'; \
        echo 'stdout_logfile_maxbytes=0'; \
        echo 'stderr_logfile=/dev/stderr'; \
        echo 'stderr_logfile_maxbytes=0'; \
        echo 'priority=30'; \
        echo 'autorestart=unexpected'; \
    } >> /etc/supervisor.d/supervisord.ini

# install PHP-FPM Exporter (latest release version) <https://github.com/hipages/php-fpm_exporter>
COPY --from=builder /go/bin/php-fpm-exporter /usr/local/bin/php-fpm-exporter
RUN \
    chmod +x /usr/local/bin/php-fpm-exporter \
    ; \
    { \
        echo ''; \
        echo '[program:exporter-phpfpm]'; \
        echo 'command=sh -c "sleep 5 && /usr/local/bin/php-fpm-exporter %(ENV_PHP_FPM_EXPORTER)s"'; \
        echo "user=%(ENV_WWW_USER)s"; \
        echo 'stdout_logfile=/dev/stdout'; \
        echo 'stdout_logfile_maxbytes=0'; \
        echo 'stderr_logfile=/dev/stderr'; \
        echo 'stderr_logfile_maxbytes=0'; \
        echo 'priority=30'; \
        echo 'autorestart=unexpected'; \
    } >> /etc/supervisor.d/supervisord.ini

# envsubst for templating <https://github.com/nginxinc/docker-nginx/blob/master/stable/alpine-slim/Dockerfile#L86-L102>
RUN apk add --no-cache --virtual .gettext gettext ; \
    mv /usr/bin/envsubst /tmp/ \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    ; \
    apk add --no-cache $runDeps ; \
    apk del .gettext ; \
    mv /tmp/envsubst /usr/local/bin/ \
    ; \
    curl -sSL https://github.com/nginxinc/docker-nginx/raw/master/entrypoint/20-envsubst-on-templates.sh -o /entrypoint.d/20-envsubst-on-templates.sh ; \
    chmod +x /entrypoint.d/20-envsubst-on-templates.sh ; \
    mkdir /etc/nginx/templates

EXPOSE 80 443 9113 9253