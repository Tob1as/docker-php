ARG PHP_VERSION=8.0.0
FROM arm32v7/php:${PHP_VERSION}-fpm-alpine
ARG PHP_VERSION

SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP+FPM+NGINX" \
	org.opencontainers.image.description="Alpine with PHP-FPM 8.0 and NGINX on ARM arch" \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	org.opencontainers.image.source="https://github.com/Tob1asDocker/php"

ENV LANG C.UTF-8
ENV TERM=xterm
ENV CFLAGS="-I/usr/src/php"
#ENV WWW_USER=www-data

# NGINX + Supervisor
RUN apk --no-cache add \
		#tzdata \
		supervisor \
		nginx \
	; \
	mkdir -p /run/nginx ; \
	mkdir -p /etc/ssl/nginx ; \
	mkdir /etc/supervisor.d/ ; \
	sed -i "s/user nginx;/user www-data;/g" /etc/nginx/nginx.conf ; \
	sed -i "s/ssl_session_cache shared:SSL:2m;/#ssl_session_cache shared:SSL:2m;/g" /etc/nginx/nginx.conf ; \
	sed -i "s/client_max_body_size .*/client_max_body_size 0;/" /etc/nginx/nginx.conf ; \
	ln -sf /dev/stdout /var/log/nginx/access.log ; \
	ln -sf /dev/stderr /var/log/nginx/error.log ; \
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
		echo 'server {'; \
		echo '  listen 80 default_server;'; \
		echo '  listen [::]:80 default_server;'; \
		echo '  #server_name _;'; \
		echo ' '; \
		echo '  #client_max_body_size 64M;'; \
		echo ' '; \
		echo '  location /nginx_status {'; \
		echo '    stub_status on;'; \
		echo '    access_log off;'; \
		echo '    allow 127.0.0.1;'; \
		echo '    allow ::1;'; \
		echo '    allow 10.0.0.0/8;'; \
		echo '    allow 172.16.0.0/12;'; \
		echo '    allow 192.168.0.0/16;'; \
		echo '    deny all;'; \
		echo '  }'; \
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
		echo '    include fastcgi_params;'; \
		echo '  }'; \
		echo ' '; \
		echo ' '; \
		echo '  location = /favicon.ico { log_not_found off; access_log off; }'; \
		echo '  location = /robots.txt { log_not_found off; access_log off; }'; \
		echo ' '; \
		echo '}'; \
	} > /etc/nginx/conf.d/default.conf

# PHP
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh ; \
	#sed -i -e 's/\r$//' /usr/local/bin/entrypoint.sh ; \
	mkdir /entrypoint.d

#WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
