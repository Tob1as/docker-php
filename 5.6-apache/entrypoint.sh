#!/bin/bash

# Set TimeZone
if [ ! -z "$TZ" ]; then
	echo ">> set timezone"
	echo ${TZ} >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata
	echo "date.timezone=${TZ}" > /usr/local/etc/php/php.ini
fi

# Display PHP error's or not
if [[ "$PHP_ERRORS" == "1" ]] ; then
	echo ">> set display_errors"
	echo "display_errors = On" >> /usr/local/etc/php/php.ini
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
	echo ">> set memory_limit"
	echo "memory_limit = ${PHP_MEM_LIMIT}M" >> /usr/local/etc/php/php.ini
fi

# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
	echo ">> set post_max_size"
	echo "post_max_size = ${PHP_POST_MAX_SIZE}M" >> /usr/local/etc/php/php.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
	echo ">> set upload_max_filesize"
	echo "upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M" >> /usr/local/etc/php/php.ini
fi

# Increase the max_file_uploads
if [ ! -z "$PHP_MAX_FILE_UPLOADS" ]; then
	echo ">> set max_file_uploads"
	echo "max_file_uploads = ${PHP_MAX_FILE_UPLOADS}" >> /usr/local/etc/php/php.ini
fi

#echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# enable apache2 rewrite
if [ "$ENABLE_REWRITE" == "1" ]; then
	echo ">> enabling rewrite support"
	/usr/sbin/a2enmod rewrite
	#/usr/sbin/a2enmod actions
fi

# enable apache2 ssl and generating ssl files
if [ "$ENABLE_SSL" == "1" ]; then
	echo ">> enabling SSL support"
	/usr/sbin/a2ensite default-ssl
	/usr/sbin/a2enmod ssl
	#/usr/sbin/a2enmod headers
	
	if [ ! -e "/etc/ssl/private/ssl-cert-snakeoil.key" ] || [ ! -e "/etc/ssl/certs/ssl-cert-snakeoil.pem" ]; then
		echo ">> generating self signed cert"
		openssl req -x509 -newkey rsa:4086 -subj "/C=/ST=/L=/O=/CN=localhost" -keyout "/etc/ssl/private/ssl-cert-snakeoil.key" -out "/etc/ssl/certs/ssl-cert-snakeoil.pem" -days 3650 -nodes -sha256
	fi
fi

if [ "$ALLOWOVERRIDE" == "1" ]; then
	echo ">> set AllowOverride form none to all"
	# diff -uNr /etc/apache2/apache2.conf /etc/apache2/apache2.conf.txt > /etc/apache2/apache2.conf.diff
	
	cat > /etc/apache2/apache2.conf.diff <<EOF
--- /etc/apache2/apache2.conf	2016-12-06 17:12:19.000000000 +0100
+++ /etc/apache2/apache2.conf.txt	2016-12-06 18:28:08.000000000 +0100
@@ -162,8 +162,8 @@
 </Directory>
 
 <Directory /var/www/>
-	Options Indexes FollowSymLinks
-	AllowOverride None
+	Options FollowSymLinks
+	AllowOverride All
 	Require all granted
 </Directory>
 

EOF
	
	patch /etc/apache2/apache2.conf < /etc/apache2/apache2.conf.diff
fi

if [ "$REMOTEIP" == "1" ]; then
	echo ">> enabling remoteip support, use this only behind a proxy!"
	
	cat > /etc/apache2/mods-available/remoteip.conf <<EOF
<IfModule mod_remoteip.c>
    RemoteIPHeader X-Forwarded-For
</IfModule>

EOF
	
	/usr/sbin/a2enmod remoteip
	
	sed -i -e 's/LogFormat "%h /LogFormat "%a /g' /etc/apache2/apache2.conf
	
fi

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
