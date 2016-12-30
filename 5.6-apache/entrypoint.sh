#!/bin/bash

# Set TimeZone
if [ ! -z "$TZ" ]; then
	echo ">> set timezone"
	echo ${TZ} >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata
	echo "date.timezone=${TZ}" > /usr/local/etc/php/php.ini
fi

# Display PHP error's or not
if [[ "$PHP_ERRORS" == "1" ]] ; then
	echo "display_errors = On" >> /usr/local/etc/php/php.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
	echo "upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M" >> /usr/local/etc/php/php.ini
fi

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

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
