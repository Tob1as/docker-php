# PHP (with Apache2) on x86_64

### Supported tags and respective `Dockerfile` links
-	`7.*-apache` *Coming soon*
-	`7.*-fpm` *Coming soon*
-	[`5.6-fpm` (*Dockerfile*)](https://github.com/TobiasH87Docker/php/blob/master/5.6-fpm/Dockerfile)
-	[`5.6-apache` (*Dockerfile*)](https://github.com/TobiasH87Docker/php/blob/master/5.6-apache/Dockerfile)

### Information:
This image with PHP extension for MySQL, PostgreSQL, GD, imagick and more based on the offical PHP image https://hub.docker.com/_/php/ . For information about PHP see here: https://php.net , https://packages.debian.org/en/jessie/php/ and https://pecl.php.net/

### How to use this image
* ``` $ docker pull tobi312/php:5.6-apache ```
* Optional: ``` $ mkdir -p /srv/html ```
* ``` $ docker run --name php5apache -d -p 80:80 -p 443:443 --link some-container:alias -v /srv/html:/var/www/html -e PHP_ERRORS=1 -e PHP_UPLOAD_MAX_FILESIZE=250 -e ENABLE_SSL=1 -e ENABLE_REWRITE=1 tobi312/php:5.6-apache ``` 

or build it yourself
* ``` $ git clone https://github.com/TobiasH87Docker/php.git && cd php/ ```
* Optional: ``` $ mkdir -p /srv/html ```
* ``` $ docker build -t tobi312/php:5.6-apache ./5.6-apache/ ``` 
* ``` $ docker run --name php5apache -d -p 80:80 -p 443:443 --link some-container:alias -v /srv/html:/var/www/html -e PHP_ERRORS=1 -e PHP_UPLOAD_MAX_FILESIZE=250 -e ENABLE_SSL=1 -e ENABLE_REWRITE=1 tobi312/php:5.6-apache ``` 
* http://localhost or https://localhost

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
	* `REMOTEIP` (set 1 to enable, use this only behind a proxy!)


### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/php/)
* [GitHub](https://github.com/TobiasH87Docker/php)
