ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm-alpine
ARG PHP_VERSION

ARG VCS_REF
ARG BUILD_DATE

SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP-FPM+NGINX" \
	org.opencontainers.image.description="Alpine with PHP-FPM ${PHP_VERSION} and NGINX" \
	org.opencontainers.image.created="${BUILD_DATE}" \
	org.opencontainers.image.revision="${VCS_REF}" \
	org.opencontainers.image.licenses="MIT" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	org.opencontainers.image.source="https://github.com/Tob1as/docker-php"

ENV LANG C.UTF-8
ENV TERM=xterm
ENV CFLAGS="-I/usr/src/php"
#ENV WWW_USER=www-data

# NGINX + Supervisor
RUN apk --no-cache add \
		tzdata \
		supervisor \
		nginx \
	; \
	#mkdir -p /run/nginx ; \
	mkdir -p /etc/ssl/nginx ; \
	mkdir /etc/supervisor.d/ ; \
	chown -R www-data:www-data /var/lib/nginx/ ; \
	mv /etc/nginx/http.d /etc/nginx/conf.d ; \
	ln -sf /dev/stdout /var/log/nginx/access.log ; \
	ln -sf /dev/stderr /var/log/nginx/error.log ; \
    #ln -s /etc/nginx/conf.d /etc/nginx/http.d ; \
	#sed -i "s+/etc/nginx/http.d+/etc/nginx/conf.d+g" /etc/nginx/nginx.conf ; \
	#sed -i "s/user nginx;/user www-data;/g" /etc/nginx/nginx.conf ; \
	#sed -i "s/ssl_session_cache shared:SSL:2m;/#ssl_session_cache shared:SSL:2m;/g" /etc/nginx/nginx.conf ; \
	#sed -i "s/client_max_body_size .*/client_max_body_size 0;/" /etc/nginx/nginx.conf ; \
	\
	{ \
		echo '[supervisord]'; \
		echo 'nodaemon=true'; \
		echo 'user=root'; \
		echo 'directory=/tmp'; \
		echo 'pidfile=/tmp/supervisord.pid'; \
		echo 'logfile=/tmp/supervisord.log'; \
		echo 'logfile_maxbytes=50MB'; \
		echo 'logfile_backups=0'; \
		echo 'loglevel=info'; \
		echo ''; \
		echo '[program:php-fpm]'; \
		echo 'command=/usr/local/sbin/php-fpm -F'; \
		#echo "user=%(ENV_WWW_USER)s"; \
		echo 'stdout_logfile=/dev/stdout'; \
		echo 'stdout_logfile_maxbytes=0'; \
		echo 'stderr_logfile=/dev/stderr'; \
		echo 'stderr_logfile_maxbytes=0'; \
		echo 'priority=10'; \
		echo 'autorestart=unexpected'; \
		echo ''; \
		echo '[program:nginx]'; \
		echo "command=/usr/sbin/nginx -g 'daemon off;'"; \
		#echo "user=%(ENV_WWW_USER)s"; \
		echo 'stdout_logfile=/dev/stdout'; \
		echo 'stdout_logfile_maxbytes=0'; \
		echo 'stderr_logfile=/dev/stderr'; \
		echo 'stderr_logfile_maxbytes=0'; \
		echo 'priority=20'; \
		echo 'autorestart=unexpected'; \
	} > /etc/supervisor.d/supervisord.ini \
	; \
	{ \
		echo ''; \
		echo 'user  www-data;'; \
		echo 'worker_processes  auto;'; \
		echo ''; \
		echo 'error_log  /var/log/nginx/error.log notice;'; \
		echo 'pid        /var/run/nginx.pid;'; \
		echo ''; \
		echo ''; \
		echo 'events {'; \
		echo '    worker_connections  1024;'; \
		echo '}'; \
		echo ''; \
		echo ''; \
		echo 'http {'; \
		echo '    include       /etc/nginx/mime.types;'; \
		echo '    default_type  application/octet-stream;'; \
		echo $'    log_format  main  \'$remote_addr - $remote_user [$time_local] "$request" \''; \
		echo $'                      \'$status $body_bytes_sent "$http_referer" \''; \
		echo $'                      \'"$http_user_agent" "$http_x_forwarded_for"\';'; \
		echo ''; \
		echo '    access_log  /var/log/nginx/access.log  main;'; \
		echo ''; \
		echo '    sendfile        on;'; \
		echo '    #tcp_nopush     on;'; \
		echo ''; \
		echo '    keepalive_timeout  65;'; \
		echo ''; \
		echo '    #gzip  on;'; \
		echo ''; \
		echo '    include /etc/nginx/conf.d/*.conf;'; \
		echo '}'; \
		echo ''; \
	} > /etc/nginx/nginx.conf \
    ; \
	{ \
		echo 'server {'; \
		echo '  listen 80 default_server;'; \
		echo '  listen [::]:80 default_server;'; \
		echo '  #server_name _;'; \
		echo ' '; \
		echo '  ##REPLACE_WITH_REMOTEIP_CONFIG##'; \
		echo ' '; \
		echo '  #client_max_body_size 64M;'; \
		echo ' '; \
		echo '  ##REPLACE_WITH_NGINXSTATUS_CONFIG##'; \
		echo ' '; \
		echo '  ##REPLACE_WITH_PHPFPMSTATUS_CONFIG##'; \
		echo ' '; \
		echo '  root /var/www/html;'; \
		echo '  index index.html index.htm index.php;'; \
		echo ' '; \
		echo '  location / {'; \
		echo '    try_files $uri $uri/ =404;'; \
		echo '  }'; \
		echo '  '; \
		echo '  # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000'; \
		echo '  location ~ \.php$ {'; \
		echo '    try_files $uri =404;'; \
		echo '    fastcgi_pass  127.0.0.1:9000;'; \
		echo '    fastcgi_split_path_info ^(.+\.php)(/.+)$;'; \
		echo '    fastcgi_index index.php;'; \
		echo '    fastcgi_param SCRIPT_NAME $fastcgi_script_name;'; \
		echo '    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;'; \
		echo '    #fastcgi_param REMOTE_ADDR $http_x_forwarded_for;'; \
		echo '    include fastcgi_params;'; \
		echo '  }'; \
		echo ' '; \
		echo ' '; \
		echo '  location = /favicon.ico { log_not_found off; access_log off; }'; \
		echo '  location = /robots.txt { log_not_found off; access_log off; }'; \
		echo ' '; \
		echo '}'; \
	} > /etc/nginx/conf.d/default.conf

# PHP-EXTENSION-INSTALLER
RUN \
	PHP_EXTENSION_INSTALLER_VERSION=$(curl -s https://api.github.com/repos/mlocati/docker-php-extension-installer/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
	echo "install-php-extensions Version: ${PHP_EXTENSION_INSTALLER_VERSION}" ; \
	curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/download/${PHP_EXTENSION_INSTALLER_VERSION}/install-php-extensions -o /usr/local/bin/install-php-extensions ; \
	chmod +x /usr/local/bin/install-php-extensions

# PHP
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# ENTRYPOINT
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh ; \
	#sed -i -e 's/\r$//' /usr/local/bin/entrypoint.sh ; \
	mkdir /entrypoint.d

#WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80 443

#STOPSIGNAL SIGQUIT

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
