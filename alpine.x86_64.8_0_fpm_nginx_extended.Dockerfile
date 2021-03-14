ARG BASE_IMAGE=8.0-fpm-nginx-alpine
FROM tobi312/php:${BASE_IMAGE}
ARG BASE_IMAGE

# set environment variable
ENV ENABLE_NGINX_STATUS=1 \
    WWW_USER=www-data \
    NGINX_EXPORTER="-nginx.ssl-verify=false -nginx.scrape-uri='http://localhost/nginx_status' -web.listen-address=':9113' -web.telemetry-path='/metrics'" \
    #PHP_FPM_EXPORTER="--addr='127.0.0.1:9114' --endpoint='http://127.0.0.1:9000/status' --fastcgi='tcp://127.0.0.1:9090/status' --web.telemetry-path='/metrics'"
    PHP_FPM_EXPORTER="--addr='0.0.0.0:9114' --fastcgi='tcp://127.0.0.1:9090/status' --web.telemetry-path='/metrics'"

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
    ARCH="amd64" ; \
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

# install PHP-FPM Exporter (latest release version) <https://github.com/bakins/php-fpm-exporter>
RUN \
    PHP_FPM_EXPORTER_VERSION=$(curl -s https://api.github.com/repos/bakins/php-fpm-exporter/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
    echo "PHP_FPM_EXPORTER_VERSION=${PHP_FPM_EXPORTER_VERSION}" ; \
    ARCH="amd64" ; \
    curl -sSL https://github.com/bakins/php-fpm-exporter/releases/download/${PHP_FPM_EXPORTER_VERSION}/php-fpm-exporter.linux.${ARCH} -o /usr/local/bin/php-fpm-exporter ; \
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
    } >> /etc/supervisor.d/supervisord.ini \
    ; \
    #echo -e "[www]\npm.status_path = /status\nping.path = /ping" > /usr/local/etc/php-fpm.d/y-status.conf ; \
    PHP_FPM__CONF_FILE="/usr/local/etc/php-fpm.d/www.conf" ; \
    sed -i "s|;pm.status_path.*|pm.status_path = /status|g" ${PHP_FPM__CONF_FILE} ; \
    sed -i "s|;ping.path.*|ping.path = /ping|g" ${PHP_FPM__CONF_FILE} ; \
    NGINX_CONF_FILE="/etc/nginx/conf.d/default.conf" ; \
    sed -i '/##REPLACE_WITH_NGINXSTATUS_CONFIG##/a ##REPLACE_WITH_PHPFPMSTATUS_CONFIG##' ${NGINX_CONF_FILE} ; \
    php_fpm_status_string="\n  location /status {\n    access_log off;\n    allow 127.0.0.1;\n    allow ::1;\n    allow 10.0.0.0/8;\n    allow 172.16.0.0/12;\n    allow 192.168.0.0/16;\n    deny all;\n    fastcgi_param SCRIPT_NAME  /status;\n    fastcgi_param SCRIPT_FILENAME  \"\";\n    include fastcgi_params;\n    fastcgi_pass 127.0.0.1:9000;\n  }\n\n  location /ping {\n    access_log off;\n    allow 127.0.0.1;\n    allow ::1;\n    allow 10.0.0.0/8;\n    allow 172.16.0.0/12;\n    allow 192.168.0.0/16;\n    deny all;\n    fastcgi_param SCRIPT_NAME  /ping;\n    fastcgi_param SCRIPT_FILENAME  \"\";\n    include fastcgi_params;\n    fastcgi_pass 127.0.0.1:9000;\n  }" ; \
    sed -i "s|##REPLACE_WITH_PHPFPMSTATUS_CONFIG##|${php_fpm_status_string}|g" ${NGINX_CONF_FILE}

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
