#!/bin/bash

# Set TimeZone
if [ ! -z "$TZ" ]; then
	echo ">> set timezone"
	cp /usr/share/zoneinfo/${TZ} /etc/localtime
	echo ${TZ} >  /etc/timezone
	date
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

# exec CMD
echo ">> exec docker CMD"
echo "$@"
exec "$@"
