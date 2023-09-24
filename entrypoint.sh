#!/bin/sh

set -eu
#set -euo pipefail
#IFS=$'\n\t'

## Variables
## https://stackoverflow.com/a/32343069/3441436
: "${TZ:=""}"                                 # set timezone, example: "Europe/Berlin"
: "${PHP_ERRORS:="0"}"                        # set 1 to enable
: "${PHP_MEM_LIMIT:=""}"                      # set Value in MB, example: 128
: "${PHP_POST_MAX_SIZE:=""}"                  # set Value in MB, example: 250
: "${PHP_UPLOAD_MAX_FILESIZE:=""}"            # set Value in MB, example: 250
: "${PHP_MAX_FILE_UPLOADS:=""}"               # set number, example: 20
: "${PHP_FPM_STATUS_PATH:="/php_fpm_status"}" # (default: /status but here use /php_fpm_status)
: "${ENABLE_PHP_FPM_STATUS:="0"}"             # set 1 to enable
: "${CREATE_PHPINFO_FILE:="0"}"               # set 1 to enable
: "${CREATE_INDEX_FILE:="0"}"                 # set 1 to enable
: "${ENABLE_APACHE_REWRITE:="0"}"             # set 1 to enable
: "${ENABLE_APACHE_ACTIONS:="0"}"             # set 1 to enable
: "${ENABLE_APACHE_SSL:="0"}"                 # set 1 to enable
: "${ENABLE_APACHE_HEADERS:="0"}"             # set 1 to enable
: "${ENABLE_APACHE_ALLOWOVERRIDE:="0"}"       # set 1 to enable
: "${ENABLE_APACHE_REMOTEIP:="0"}"            # set 1 to enable (use this only behind a proxy/loadbalancer)
: "${ENABLE_APACHE_STATUS:="0"}"              # set 1 to enable
: "${ENABLE_APACHE_SSL_REDIRECT:="0"}"        # set 1 to enable (required enable ssl and rewrite)
: "${APACHE_SERVER_NAME:=""}"                 # set server name, example: example.com
: "${APACHE_SERVER_ALIAS:=""}"                # set server name, example: 'www.example.com *.example.com'
: "${APACHE_SERVER_ADMIN:=""}"                # set server admin, example: admin@example.com
: "${DISABLE_APACHE_DEFAULTSITES:="0"}"       # set 1 to disable default sites (add or mount your own conf in /etc/apache2/sites-enabled)
: "${ENABLE_NGINX_REMOTEIP:="0"}"             # set 1 to enable (use this only behind a proxy/loadbalancer)
: "${ENABLE_NGINX_STATUS:="0"}"               # set 1 to enable

PHP_INI_FILE_NAME="50-php.ini"
lsb_dist="$(. /etc/os-release && echo "$ID")" # get os (example: debian or alpine) - do not change!

## check if php-fpm in this container image exists
if [ -d "/usr/local/etc/php-fpm.d" -a -f "/usr/local/etc/php-fpm.d/www.conf" ]; then
	PHP_FPM_IS_EXISTS="1"
else 
	PHP_FPM_IS_EXISTS="0"
fi

## check if apache in this container image exists
if [ -d "/etc/apache2" -a -f "/etc/apache2/apache2.conf" ]; then
	APACHE_IS_EXISTS="1"
else 
	APACHE_IS_EXISTS="0"
fi

## check if nginx in this container image exists
if [ -d "/etc/nginx" -a -f "/etc/nginx/nginx.conf" ]; then
	NGINX_IS_EXISTS="1"
else 
	NGINX_IS_EXISTS="0"
fi

## print versions
echo ">> print versions ..."
php -v | head -1
if [ "$APACHE_IS_EXISTS" -eq "1" ]; then
	#httpd -v
	apache2 -v | head -1
fi
if [ "$NGINX_IS_EXISTS" -eq "1" ]; then
	nginx -v | head -1
fi

####################################################
##################### PHP ##########################
####################################################

## create php ini file with comment
echo "; ${PHP_INI_FILE_NAME} create by entrypoint.sh in container image" > /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}

## set TimeZone
if [ -n "$TZ" ]; then
	echo ">> set timezone to ${TZ} ..."
	#if [ "$lsb_dist" = "alpine" ]; then apk add --no-cache --virtual .fetch-tmp tzdata; fi
	#ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
	cp /usr/share/zoneinfo/${TZ} /etc/localtime
	echo ${TZ} >  /etc/timezone
	echo "date.timezone=${TZ}" >> /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}
	#if [ "$lsb_dist" = "alpine" ]; then apk del --no-network .fetch-tmp; fi
	date
fi

## display PHP error's
if [ "$PHP_ERRORS" -eq "1" ] ; then
	echo ">> set display_errors"
	echo "display_errors = On" >> /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}
fi

## changes the memory_limit
if [ -n "$PHP_MEM_LIMIT" ]; then
	echo ">> set memory_limit"
	echo "memory_limit = ${PHP_MEM_LIMIT}M" >> /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}
fi

## changes the post_max_size
if [ -n "$PHP_POST_MAX_SIZE" ]; then
	echo ">> set post_max_size"
	echo "post_max_size = ${PHP_POST_MAX_SIZE}M" >> /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}
fi

## changes the upload_max_filesize
if [ -n "$PHP_UPLOAD_MAX_FILESIZE" ]; then
	echo ">> set upload_max_filesize"
	echo "upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M" >> /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}
fi

## changes the max_file_uploads
if [ -n "$PHP_MAX_FILE_UPLOADS" ]; then
	echo ">> set max_file_uploads"
	echo "max_file_uploads = ${PHP_MAX_FILE_UPLOADS}" >> /usr/local/etc/php/conf.d/${PHP_INI_FILE_NAME}
fi

####################################################
##################### PHP-FPM ######################
####################################################

PHP_FPM_CONF_FILE="/usr/local/etc/php-fpm.d/www.conf"

if [ "$PHP_FPM_IS_EXISTS" -eq "1" -a "$ENABLE_PHP_FPM_STATUS" -eq "1" ]; then
	echo ">> enabling php-fpm status!"
	#echo -e "[www]\npm.status_path = /status\nping.path = /ping" > /usr/local/etc/php-fpm.d/y-status.conf
	#echo -e "[www]\npm.status_path = ${PHP_FPM_STATUS_PATH}\nping.path = /ping" > /usr/local/etc/php-fpm.d/y-status.conf
    #sed -i "s|;pm.status_path.*|pm.status_path = /status|g" ${PHP_FPM_CONF_FILE}
	sed -i "s|;pm.status_path.*|pm.status_path = ${PHP_FPM_STATUS_PATH}|g" ${PHP_FPM_CONF_FILE}
    sed -i "s|;ping.path.*|ping.path = /ping|g" ${PHP_FPM_CONF_FILE}
fi

####################################################
############ for dev and testing ###################
####################################################

## create phpinfo-file
if [ "$CREATE_PHPINFO_FILE" -eq "1" -a ! -e "/var/www/html/phpinfo.php" ]; then
	echo ">> create phpinfo-file"
	echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
fi

## create index file
#if [ \( "$NGINX_IS_EXISTS" -eq "1" -o "$APACHE_IS_EXISTS" -eq "1" \) -a "$CREATE_INDEX_FILE" -eq "1" -a ! -e "/var/www/html/index.php" ]; then
if [ "$CREATE_INDEX_FILE" -eq "1" -a ! -e "/var/www/html/index.php" ]; then
	echo ">> create index file"

	cat > /var/www/html/index.php <<EOF
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="generator" content="Docker Image: tobi312/php">
		<title>Site</title>
		<!--<link rel="stylesheet" href="style.css">-->
	</head>
	<body>
		<h1>Hello!</h1>
		<p>
			This is a simple website. Time:<br>
			<?php
				echo date("Y-m-d H:i:s");
			?>
		</p>
	</body>
</html>

EOF

fi

####################################################
#################### APACHE2 #######################
####################################################

## enable apache2 rewrite
if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_REWRITE" -eq "1" ]; then
	echo ">> enabling rewrite support"
	/usr/sbin/a2enmod rewrite
	
fi

## enable apache2 actions
if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_ACTIONS" -eq "1" ]; then
	echo ">> enabling actions support"
	/usr/sbin/a2enmod actions
fi

## enable apache2 ssl and generating self-sign ssl files
if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_SSL" -eq "1" ]; then
	echo ">> enabling SSL support"
	/usr/sbin/a2ensite default-ssl
	/usr/sbin/a2enmod ssl
	
	if [ ! -e "/etc/ssl/private/ssl-cert-snakeoil.key" ] || [ ! -e "/etc/ssl/certs/ssl-cert-snakeoil.pem" ]; then
		echo ">> generating self signed cert ; optional: later you can mount a own certs in container"
		openssl req -x509 -newkey rsa:4086 -subj "/C=no/ST=none/L=none/O=none/CN=none" -keyout "/etc/ssl/private/ssl-cert-snakeoil.key" -out "/etc/ssl/certs/ssl-cert-snakeoil.pem" -days 3650 -nodes -sha256
	fi
fi

## enable apache2 headers
if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_HEADERS" -eq "1" ]; then
	echo ">> enabling headers support"
	/usr/sbin/a2enmod headers
fi

## set AllowOverride to all
#if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_ALLOWOVERRIDE" == "1" ]; then
#	echo ">> set AllowOverride form none to all"
#	## diff -uNr /etc/apache2/apache2.conf /etc/apache2/apache2.conf.txt > /etc/apache2/apache2.conf.diff
#	
#	cat > /etc/apache2/apache2.conf.diff <<EOF
#--- /etc/apache2/apache2.conf	2016-12-06 17:12:19.000000000 +0100
#+++ /etc/apache2/apache2.conf.txt	2016-12-06 18:28:08.000000000 +0100
#@@ -162,8 +162,8 @@
# </Directory>
# 
# <Directory /var/www/>
#-	Options Indexes FollowSymLinks
#-	AllowOverride None
#+	Options FollowSymLinks
#+	AllowOverride all
# 	Require all granted
# </Directory>
# 
#
#EOF
#	
#	patch /etc/apache2/apache2.conf < /etc/apache2/apache2.conf.diff
#fi

## set AllowOverride to all
if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_ALLOWOVERRIDE" -eq "1" ]; then
	echo ">> set AllowOverride form none to all"
	sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/apache2/apache2.conf
	sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/apache2/apache2.conf
fi

## enable remote ip (X-Forwarded-For), use this only behind a proxy/loadbalancer!
## https://gist.github.com/patrocle/43f688e8cfef1a48c66f22825e9e0678
## https://www.globo.tech/learning-center/x-forwarded-for-ip-apache-web-server/
## https://www.digitalocean.com/community/questions/get-client-public-ip-on-apache-server-used-behind-load-balancer
if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_REMOTEIP" -eq "1" ]; then
	echo ">> enabling remoteip support, use this only behind a proxy!"
	
	cat > /etc/apache2/conf-available/remoteip.conf <<EOF
<IfModule mod_remoteip.c>
    RemoteIPHeader X-Forwarded-For
</IfModule>

EOF
	
	/usr/sbin/a2enmod remoteip
	/usr/sbin/a2enconf remoteip
	
	sed -i -e 's/LogFormat "%h /LogFormat "%a (%{X-Forwarded-For}i) /g' /etc/apache2/apache2.conf
	
fi

if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_STATUS" -eq "1" ]; then
	echo ">> enabling apache status!"
	
	[ -d "/etc/apache2/docker" ] || mkdir /etc/apache2/docker

	cat > /etc/apache2/docker/status.conf <<EOF
<IfModule mod_status.c>
    #ExtendedStatus on
    <Location /server-status>
        SetHandler server-status
        Order deny,allow
        Require all denied
        Require local
        Require ip 10.0.0.0/8
        Require ip 172.16.0.0/12
        Require ip 192.168.0.0/16
        #Require ip fd00::/7
    </Location>
</IfModule>

EOF
	
	/usr/sbin/a2enmod status

	sed -i "/^ \ \ \ \ \ \ \ Include docker\/status.conf/d" /etc/apache2/sites-available/000-default.conf
	sed -i "/#Include conf-available/a \ \ \ \ \ \ \ \ Include docker/status.conf" /etc/apache2/sites-available/000-default.conf
	sed -i "/^ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Include docker\/status.conf/d" /etc/apache2/sites-available/default-ssl.conf
	sed -i "/#Include conf-available/a \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Include docker/status.conf" /etc/apache2/sites-available/default-ssl.conf
fi

if [ "$APACHE_IS_EXISTS" -eq "1" -a "$ENABLE_APACHE_SSL_REDIRECT" -eq "1" ]; then
	echo ">> enabling ssl redirect! (required enable ssl and rewrite)"
	
	[ -d "/etc/apache2/docker" ] || mkdir /etc/apache2/docker

	cat > /etc/apache2/docker/redirect_http_to_https.conf <<EOF
<IfModule mod_ssl.c>
    <IfModule mod_rewrite.c>		
        RewriteEngine on
        #RewriteBase /
        RewriteCond %{HTTPS} off
        RewriteCond %{REQUEST_URI} !^/.well-known/
		RewriteCond %{REQUEST_URI} !=/server-status
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    </IfModule>
    #Redirect permanent / https://%{HTTP_HOST}/
</IfModule>

EOF
	
	sed -i "/^ \ \ \ \ \ \ \ Include docker\/redirect_http_to_https.conf/d" /etc/apache2/sites-available/000-default.conf
	sed -i "/#Include conf-available/a \ \ \ \ \ \ \ \ Include docker\/redirect_http_to_https.conf" /etc/apache2/sites-available/000-default.conf
fi

if [ "$APACHE_IS_EXISTS" -eq "1" -a -n "$APACHE_SERVER_NAME" ]; then
	#APACHE_SERVER_NAME=$(hostname) ## only for debug
	echo ">> set ServerName to ${APACHE_SERVER_NAME}"
	sed -i "s/#ServerName .*/ServerName ${APACHE_SERVER_NAME}/" /etc/apache2/sites-available/000-default.conf
	sed -i "/^ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ServerName /d" /etc/apache2/sites-available/default-ssl.conf
	sed -i "/ServerAdmin /i \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ServerName ${APACHE_SERVER_NAME}" /etc/apache2/sites-available/default-ssl.conf
fi

if [ "$APACHE_IS_EXISTS" -eq "1" -a -n "$APACHE_SERVER_ALIAS" ]; then
	echo ">> set ServerAlias to ${APACHE_SERVER_ALIAS}"
	sed -i "/^ \ \ \ \ \ \ \ ServerAlias /d" /etc/apache2/sites-available/000-default.conf
	#sed -i "/ServerName .*/a \ \ \ \ \ \ \ \ ServerAlias ${APACHE_SERVER_ALIAS}" /etc/apache2/sites-available/000-default.conf
	sed -i "/ServerAdmin /i \ \ \ \ \ \ \ \ ServerAlias ${APACHE_SERVER_ALIAS}" /etc/apache2/sites-available/000-default.conf
	sed -i "/^ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ServerAlias /d" /etc/apache2/sites-available/default-ssl.conf
	#sed -i "/ServerName .*/a \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ServerAlias ${APACHE_SERVER_ALIAS}" /etc/apache2/sites-available/default-ssl.conf
	sed -i "/ServerAdmin /i \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ServerAlias ${APACHE_SERVER_ALIAS}" /etc/apache2/sites-available/default-ssl.conf
fi

if [ "$APACHE_IS_EXISTS" -eq "1" -a -n "$APACHE_SERVER_ADMIN" ]; then
	echo ">> set ServerAdmin to ${APACHE_SERVER_ADMIN}"
	sed -i "s/ServerAdmin .*/ServerAdmin ${APACHE_SERVER_ADMIN}/" /etc/apache2/sites-available/000-default.conf
	sed -i "s/ServerAdmin .*/ServerAdmin ${APACHE_SERVER_ADMIN}/" /etc/apache2/sites-available/default-ssl.conf
fi

if [ "$APACHE_IS_EXISTS" -eq "1" -a "$DISABLE_APACHE_DEFAULTSITES" -eq "1" ]; then
	echo ">> disable default sites (add or mount your own conf in /etc/apache2/sites-enabled)"
	if [ -f "/etc/apache2/sites-available/000-default.conf" ]; then
		/usr/sbin/a2dissite 000-default
	fi
	if [ -f "/etc/apache2/sites-available/default-ssl.conf" ]; then
		/usr/sbin/a2dissite default-ssl
	fi
fi

####################################################
##################### NGINX ########################
####################################################

NGINX_CONF_FILE="/etc/nginx/conf.d/default.conf"

if [ "$NGINX_IS_EXISTS" -eq "1" -a "$ENABLE_NGINX_STATUS" -eq "1" ]; then
	echo ">> enabling nginx status!"
	nginx_status_string="location /nginx_status {\n    stub_status on;\n    access_log off;\n    allow 127.0.0.1;\n    allow ::1;\n    allow 10.0.0.0/8;\n    allow 172.16.0.0/12;\n    allow 192.168.0.0/16;\n    deny all;\n  }"
	sed -i "s|##REPLACE_WITH_NGINXSTATUS_CONFIG##|${nginx_status_string}|g" ${NGINX_CONF_FILE}
fi

if [ "$NGINX_IS_EXISTS" -eq "1" -a "$ENABLE_PHP_FPM_STATUS" -eq "1" ]; then
	echo ">> enabling php-fpm status in nginx!"
    php_fpm_status_string="location ${PHP_FPM_STATUS_PATH} {\n    access_log off;\n    allow 127.0.0.1;\n    allow ::1;\n    allow 10.0.0.0/8;\n    allow 172.16.0.0/12;\n    allow 192.168.0.0/16;\n    deny all;\n    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n    include fastcgi_params;\n    fastcgi_pass 127.0.0.1:9000;\n  }\n\n  location /ping {\n    access_log off;\n    allow 127.0.0.1;\n    allow ::1;\n    allow 10.0.0.0/8;\n    allow 172.16.0.0/12;\n    allow 192.168.0.0/16;\n    deny all;\n    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n    include fastcgi_params;\n    fastcgi_pass 127.0.0.1:9000;\n  }" ; \
    sed -i "s|##REPLACE_WITH_PHPFPMSTATUS_CONFIG##|${php_fpm_status_string}|g" ${NGINX_CONF_FILE}
fi

if [ "$NGINX_IS_EXISTS" -eq "1" -a "$ENABLE_NGINX_REMOTEIP" -eq "1" ]; then
	# https://nginx.org/en/docs/http/ngx_http_realip_module.html
	echo ">> enabling remoteip support, use this only behind a proxy!"
	nginx_remoteip_string="set_real_ip_from 172.20.0.0/8;\n  #set_real_ip_from fd00:dead:beef::/48;\n  set_real_ip_from fd00::/8;\n  ##REPLACE_WITH_MORE_REAL_IP##\n  real_ip_header X-Forwarded-For;\n  #real_ip_recursive on;\n"
	sed -i "s|##REPLACE_WITH_REMOTEIP_CONFIG##|${nginx_remoteip_string}|g" ${NGINX_CONF_FILE}
fi

####################################################

## more entrypoint-files
find "/entrypoint.d/" -follow -type f -print | sort -n | while read -r f; do
	case "$f" in
		*.sh)
			if [ ! -x "$f" ] ; then 
				echo ">> $f is not executable! Set +x ..."
				chmod +x $f
			fi
			echo ">> $f is executed ..."
			/bin/sh $f
			;;
		*)  echo ">> $f is no *.sh-file!" ;;
	esac
done

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
