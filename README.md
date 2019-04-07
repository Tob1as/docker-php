# PHP (with Apache2) on x86_64

### Supported tags and respective `Dockerfile` links
-	[`7.1-apache` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/7.1-apache/Dockerfile)
-	[`7.1-fpm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/7.1-fpm/Dockerfile)
-	[`7.0-apache` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/7.0-apache/Dockerfile)
-	[`7.0-fpm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/7.0-fpm/Dockerfile)
-	[`7.0-fpm-alpine` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/7.0-fpm-alpine/Dockerfile)
-	[`5.6-apache` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/5.6-apache/Dockerfile)
-	[`5.6-fpm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/5.6-fpm/Dockerfile)

### Information:
This image with PHP extension for MySQL, PostgreSQL, GD, imagick and more based on the offical PHP image https://hub.docker.com/_/php/ . For information about PHP see here: https://php.net , https://packages.debian.org/en/stretch/php/ and https://pecl.php.net/

### How to use this image
* ``` $ docker pull tobi312/php:TAG ```
* Optional: ``` $ mkdir -p /srv/html ```
* ``` $ docker run --name php -d -p PORT:PORT --link some-container:alias -v /srv/html:/var/www/html -e PHP_ERRORS=1 -e PHP_UPLOAD_MAX_FILESIZE=250 tobi312/php:TAG ``` 

### Environment Variables
* `TZ` (Default: Europe/Berlin)
* `PHP_ERRORS` (set 1 to enable)
* `PHP_MEM_LIMIT` (Value in MB)
* `PHP_POST_MAX_SIZE` (Value in MB)
* `PHP_UPLOAD_MAX_FILESIZE` (Value in MB)
* `PHP_MAX_FILE_UPLOADS` (number)
* Apache2:
	* `ENABLE_REWRITE` (set 1 to enable)
	* `ENABLE_SSL` (set 1 to enable)
	* `REMOTEIP` (set 1 to enable (X-Forwarded-For), use this only behind a proxy/loadbalancer!)


### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/php/)
* [GitHub](https://github.com/Tob1asDocker/php)
