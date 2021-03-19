ARG BASE_IMAGE_TAG=8.0-fpm-nginx-alpine
FROM tobi312/php:${BASE_IMAGE_TAG}
ARG BASE_IMAGE_TAG

## example build command: docker build -t tobi312/php:8.0-fpm-nginx-extended-alpine --build-arg BASE_IMAGE_TAG=8.0-fpm-nginx-slim-alpine -f alpine.x86_64.8_0_fpm_nginx_extended.Dockerfile .

# set environment variable
ENV ENABLE_NGINX_STATUS=1 \
    ENABLE_PHP_FPM_STATUS=1 \
    WWW_USER=www-data \
    ARCH="amd64" \
    NGINX_EXPORTER="-nginx.scrape-uri='http://localhost/nginx_status' -web.listen-address=':9113' -web.telemetry-path='/metrics' -nginx.ssl-verify=false" \
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
    curl -sSL https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/${NGINX_EXPORTER_VERSION}/nginx-prometheus-exporter-$(echo ${NGINX_EXPORTER_VERSION} | cut -c 2- )-linux-${ARCH}.tar.gz | tar xvz -C /usr/local/bin ; \
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

# install PHP-FPM Exporter (latest release version) <https://github.com/hipages/php-fpm_exporter> (or https://github.com/bakins/php-fpm-exporter ?)
RUN \
    PHP_FPM_EXPORTER_VERSION=$(curl -s https://api.github.com/repos/hipages/php-fpm_exporter/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
    echo "PHP_FPM_EXPORTER_VERSION=${PHP_FPM_EXPORTER_VERSION}" ; \
    curl -sSL https://github.com/hipages/php-fpm_exporter/releases/download/${PHP_FPM_EXPORTER_VERSION}/php-fpm_exporter_$(echo ${PHP_FPM_EXPORTER_VERSION} | cut -c 2- )_linux_${ARCH} -o /usr/local/bin/php-fpm-exporter ; \
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

# envsubst for templating <https://github.com/nginxinc/docker-nginx/blob/master/stable/alpine/Dockerfile#L87>
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
    chmod +x /entrypoint.d/20-envsubst-on-templates.sh

EXPOSE 80 443 9113 9114
