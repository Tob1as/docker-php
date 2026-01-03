# build: docker build --no-cache --progress=plain --build-arg PHP_VERSION=8.4 -t tobi312/php:8.4-fpm-nginx-alpine-extended -f alpine.fpm_nginx.extended.git.Dockerfile .
ARG PHP_VERSION=8.4
FROM golang:alpine AS builder

ENV GOPATH=/go
ENV CGO_ENABLED=0

RUN apk add --no-cache git


FROM builder AS build-nginxexporter

WORKDIR /go/src/nginx-prometheus-exporter

# NGINX Prometheus Exporter (latest release version) <https://github.com/nginxinc/nginx-prometheus-exporter>
RUN \
    NGINX_EXPORTER_VERSION=$(wget -qO- https://api.github.com/repos/nginxinc/nginx-prometheus-exporter/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
    echo "NGINX_EXPORTER_VERSION=${NGINX_EXPORTER_VERSION}" ; \
    BUILD_VERSION=$(echo ${NGINX_EXPORTER_VERSION} | sed 's/[^.0-9][^.0-9]*//g') ; \
    GOOS="$(go env GOOS)" GOARCH="$(go env GOARCH)" ; \
    wget -qO- https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/${NGINX_EXPORTER_VERSION}/nginx-prometheus-exporter_${BUILD_VERSION}_${GOOS}_${GOARCH}.tar.gz | tar -xz -C "${GOPATH}/bin" nginx-prometheus-exporter ; \
    ${GOPATH}/bin/nginx-prometheus-exporter --version


FROM builder AS build-phpfpmexporter

WORKDIR /go/src/php-fpm_exporter

# PHP-FPM Exporter (latest release version) <https://github.com/hipages/php-fpm_exporter>
RUN \
    PHP_FPM_EXPORTER_VERSION=$(wget -qO- https://api.github.com/repos/hipages/php-fpm_exporter/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
    echo "PHP_FPM_EXPORTER_VERSION=${PHP_FPM_EXPORTER_VERSION}" ; \
    git clone --branch ${PHP_FPM_EXPORTER_VERSION} --single-branch https://github.com/hipages/php-fpm_exporter.git . ; \
    BUILD_VERSION=$(echo ${PHP_FPM_EXPORTER_VERSION} | sed 's/[^.0-9][^.0-9]*//g') ; \
    VCS_REF=$(git rev-parse HEAD) ; \
    BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') ; \
    rm go.mod go.sum && go mod init github.com/hipages/php-fpm_exporter && go mod tidy ; \
    GOOS="$(go env GOOS)" GOARCH="$(go env GOARCH)" \
    go build -trimpath -a -v -ldflags "-X main.version=${BUILD_VERSION} -X main.commit=${VCS_REF} -X main.date=${BUILD_DATE}" -o "${GOPATH}/bin/php-fpm_exporter" ; \
    ${GOPATH}/bin/php-fpm_exporter version


FROM tobi312/php:${PHP_VERSION}-fpm-nginx-alpine
ARG PHP_VERSION

ARG VCS_REF
ARG BUILD_DATE

# set environment variable
ENV ENABLE_NGINX_STATUS=1 \
    ENABLE_PHP_FPM_STATUS=1 \
    WWW_USER=www-data \
    NGINX_EXPORTER="--nginx.scrape-uri='http://localhost/nginx_status' --web.listen-address=':9113' --web.telemetry-path='/metrics' --no-nginx.ssl-verify" \
    PHP_FPM_EXPORTER="server --phpfpm.scrape-uri='tcp://127.0.0.1:9000/php_fpm_status' --web.listen-address=':9253' --web.telemetry-path='/metrics' --log.level=info --phpfpm.fix-process-count=false"

# install tools
#RUN apk --no-cache add \
#        curl \
#        unzip \
#        ca-certificates \
#        tzdata

# copy exporter
COPY --from=build-nginxexporter /go/bin/nginx-prometheus-exporter /usr/local/bin/
COPY --from=build-phpfpmexporter /go/bin/php-fpm_exporter /usr/local/bin/

# supervisord for exporter
RUN \
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
    } >> /etc/supervisor.d/supervisord.ini ; \
    \
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
    } >> /etc/supervisor.d/supervisord.ini ; \
    echo "add exporter to /etc/supervisor.d/supervisord.ini done"

# envsubst for templating <https://github.com/nginx/docker-nginx/blob/master/stable/alpine-slim/Dockerfile#L86-L87>
RUN apk add --no-cache gettext-envsubst ; \
    curl -sSL https://github.com/nginxinc/docker-nginx/raw/master/entrypoint/20-envsubst-on-templates.sh -o /entrypoint.d/20-envsubst-on-templates.sh ; \
    chmod +x /entrypoint.d/20-envsubst-on-templates.sh ; \
    mkdir /etc/nginx/templates

EXPOSE 80 443 9113 9253