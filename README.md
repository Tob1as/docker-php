# PHP (with Apache2 or FPM or NGINX) on x86_64 and ARM

### Supported tags and respective `Dockerfile` links
- [`8.X-fpm-alpine-slim` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/alpine.fpm.slim.Dockerfile)
- [`8.X-fpm-alpine` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/alpine.fpm.Dockerfile)
- [`8.X-fpm-alpine-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/alpine.fpm.wsc.Dockerfile)
- [`8.X-fpm-nginx-alpine-slim` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/alpine.fpm_nginx.slim.Dockerfile)
- [`8.X-fpm-nginx-alpine` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/alpine.fpm_nginx.Dockerfile)
- [`8.X-fpm-nginx-alpine-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/alpine.fpm_nginx.wsc.Dockerfile)
- [`8.X-fpm-nginx-alpine-extended` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/alpine.fpm_nginx.extended.Dockerfile)
- [`8.X-apache-debian-slim` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/debian.apache.slim.Dockerfile)
- [`8.X-apache-debian` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/debian.apache.Dockerfile)
- [`8.X-apache-debian-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/debian.apache.wsc.Dockerfile)
- [`8.X-fpm-debian-slim` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/debian.fpm.slim.Dockerfile)
- [`8.X-fpm-debian` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/debian.fpm.Dockerfile)
- [`8.X-fpm-debian-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/debian.fpm.wsc.Dockerfile)
- [`8.X-doi-fpm-alpine-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/doi.alpine.fpm.wsc.Dockerfile) (No entrypoint!)
- [`8.X-doi-fpm-debian-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/doi.debian.fpm.wsc.Dockerfile) (No entrypoint!)
- [`8.X-doi-apache-debian-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/doi.debian.apache.wsc.Dockerfile) (No entrypoint!)
- [`8.X-dhi-fpm-alpine-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/dhi.alpine.fpm.wsc.Dockerfile) (No entrypoint, no shell and nonroot!)
- [`8.X-dhi-fpm-debian-wsc` (*Dockerfile*)](https://github.com/Tob1as/docker-php/blob/master/dhi.debian.fpm.wsc.Dockerfile) (No entrypoint, no shell and nonroot!)

**All container images are available in versions `8.3`, `8.4` and `8.5`.** ;-)   
  
*How long php versions are supported (End of Life): [https://www.php.net/supported-versions.php](https://www.php.net/supported-versions.php)  
Do not use an container image which php version is no longer supported!*

### What is PHP?

PHP is a server-side scripting language designed for web development, but which can also be used as a general-purpose programming language. PHP can be added to straight HTML or it can be used with a variety of templating engines and web frameworks. PHP code is usually processed by an interpreter, which is either implemented as a native module on the web-server or as a common gateway interface (CGI).

> [wikipedia.org/wiki/PHP](https://en.wikipedia.org/wiki/PHP)

![logo](https://raw.githubusercontent.com/docker-library/docs/master/php/logo.png)

### About these images:
* based on Docker Official Images (DOI): [DockerHub](https://hub.docker.com/_/php/) / [GitHub](https://github.com/docker-library/php)
* For easy install the extensions and get a smaller images it use [php-extension-installer](https://github.com/mlocati/docker-php-extension-installer).
* For information about PHP and extensions see here: [php.net](https://php.net) and [pecl.php.net](https://pecl.php.net).
* The official base Images have the following PHP extensions enabled by default (check with: ```php -m```): ```Core ctype curl date dom fileinfo filter hash iconv json libxml mbstring mysqlnd openssl pcre PDO pdo_sqlite Phar posix random readline Reflection session SimpleXML sodium SPL sqlite3 standard tokenizer xml xmlreader xmlwriter 'Zend OPcache' zlib```
* These images extend the basic images with additional PHP extensions, for example: SQL-Databases, gd, imagick, ldap and more. For details see in dockerfiles.  
  * *Images with `-slim` suffix have only the PHP extensions like offical base image, but with entrypoint script for some settings and other adjustments. This is the base image for all others.* 
  * *Images without `-slim` or other suffix have a mix of additional extensions, which should maybe sufficient for most PHP web applications.*
  * *Images with `-wsc` suffix only contain PHP extensions for [WSC (WoltLab Suite Core)](https://www.woltlab.com) [[Software Download](https://www.woltlab.com/en/woltlab-suite-download/)].*
  * *Images with `-extended` suffix at present only for php images with nginx. (Prometheus Exporter and other)*
  * *Images containing `apache` or `nginx` are integrated with the web server.*
  * *Images containing `debian` or `alpine` specify the operating system.*
  * *Images containing `doi` based on [DOI (Docker Official Images)](https://github.com/docker-library/php) like the other images in this repository, but without an entrypoint script, so the environment variables from this README are not supported. Mount your configuration file(s)*
  * *Images containing `dhi` based on [DHI (Docker Hardened Images)](https://dhi.io/catalog/php) and NOT based on Docker Offical Images (from Community). This DHI run as nonroot user, do not have a shell and therefore NO entrypoint script. The environment variables listed in the README therefore do not supported here. Mount your configuration file(s). A example setup for docker-compose you can find [here](https://github.com/Tob1as/docker-php/tree/master/examples/fpm-nginx-dhi) and for K8s [here](https://github.com/Tob1as/docker-php/tree/master/examples/fpm-nginx-dhi-k8s).*
* UID:GID: 
  * Alpine: 82 (www-data)
  * Debian: 33 (www-data)
  * DHI (Alpine/Debian): 65532 (nonroot)
  * When switching from one Version/OS to another, execute `chown -R <UID>:<GID> <FOLDER>` before starting the respective container.

### How to use these images:

> Note: Only works with Images with entrypoint script!

* Environment Variables:  
  * `TZ` (set timezone, example: "Europe/Berlin")
  * `PHP_ERRORS` (set 1 to enable, default: disabled)
  * `PHP_MEM_LIMIT` (set Value in MB, example: 256, default: 128)
  * `PHP_POST_MAX_SIZE` (set Value in MB, example: 250, default: 8)
  * `PHP_UPLOAD_MAX_FILESIZE` (set Value in MB, example: 240, default: 2)
  * `PHP_MAX_FILE_UPLOADS` (set number, example: 25, default: 20)
  * `PHP_MAX_EXECUTION_TIME` (set Value in Seconds, example: 120, default: 30)
  * `CREATE_PHPINFO_FILE` (set 1 to enable, for dev and testing)
  * `CREATE_INDEX_FILE` (set 1 to enable, for dev and testing)
  * PHP-FPM (only):
    * `ENABLE_PHP_FPM_STATUS` (set 1 to enable on `/php_fpm_status`)
  * Apache2 (only):
    * `ENABLE_APACHE_REWRITE` (set 1 to enable)
    * `ENABLE_APACHE_ACTIONS` (set 1 to enable)
    * `ENABLE_APACHE_SSL` (set 1 to enable)
    * `ENABLE_APACHE_HEADERS` (set 1 to enable)
    * `ENABLE_APACHE_ALLOWOVERRIDE` (set 1 to enable)
    * `ENABLE_APACHE_REMOTEIP` (set 1 to enable (X-Forwarded-For), use this only behind a proxy/loadbalancer!)
    * `ENABLE_APACHE_STATUS` (set 1 to enable)
    * `ENABLE_APACHE_SSL_REDIRECT` (set 1 to enable, required enable ssl and rewrite)
    * `APACHE_SERVER_NAME` (set server name, example: example.com)
    * `APACHE_SERVER_ALIAS` (set server name, example: 'www.example.com *.example.com')
    * `APACHE_SERVER_ADMIN` (set server admin, example: admin@example.com)
    * `DISABLE_APACHE_DEFAULTSITES` (set 1 to disable default sites, then add or mount your own conf in /etc/apache2/sites-enabled)
  * NGINX (only):
    * `ENABLE_NGINX_REMOTEIP` (set 1 to enable (X-Forwarded-For), use this only behind a proxy/loadbalancer!)
    * `ENABLE_NGINX_STATUS` (set 1 to enable)
    * or mount own config to `/etc/nginx/conf.d/default.conf`

* Ports:
  * php with apache/nginx: `80` (http), optional: `443` (https)
  * php with fpm: `9000`

* ``` $ docker run --name phpcontainer -v $(pwd)/html:/var/www/html:rw -p 8080:80 -e PHP_ERRORS=1 -e PHP_UPLOAD_MAX_FILESIZE=250 -d tobi312/php:8.4-apache```

* An own Dockerfile?, then here an example with copy additional own entrypoint-file(s) in apache image:  
  ``` $ echo -e "FROM tobi312/php:8.4-apache-debian\nCOPY *.sh /entrypoint.d/" > Dockerfile```

#### Docker-Compose

```yaml
version: "2.4"
services:
  php:
    image: tobi312/php:8.4-apache-debian
    #image: tobi312/php:8.4-fpm-nginx-alpine
    container_name: phpcontainer
    restart: unless-stopped
    ## ports ONLY with apache/nginx:
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./html:/var/www/html:rw
      ## optional: folder with own entrypoint-file(s) mount:
      #- ./entrypoint.d:/entrypoint.d:ro
      ## optional for apache: own ssl-cert and -key:
      #- ./ssl/mySSL.crt:/etc/ssl/certs/ssl-cert-snakeoil.pem:ro
      #- ./ssl/mySSL.key:/etc/ssl/private/ssl-cert-snakeoil.key:ro
      ## optional for nginx: own nginx default.conf:
      #- ./nginx_default.conf:/etc/nginx/conf.d/default.conf:ro
    environment:
      TZ: "Europe/Berlin"
      PHP_ERRORS: 1
      PHP_MEM_LIMIT: 128
      PHP_POST_MAX_SIZE: 250
      PHP_UPLOAD_MAX_FILESIZE: 250
      PHP_MAX_FILE_UPLOADS: 20
      PHP_MAX_EXECUTION_TIME: 120
      CREATE_PHPINFO_FILE: 0
      CREATE_INDEX_FILE: 0
      ## next env only with apache
      ENABLE_APACHE_REWRITE: 1
      ENABLE_APACHE_ACTIONS: 0
      ENABLE_APACHE_SSL: 0
      ENABLE_APACHE_HEADERS: 0
      ENABLE_APACHE_ALLOWOVERRIDE: 1
      ENABLE_APACHE_REMOTEIP: 0
      ENABLE_APACHE_STATUS: 0
      #ENABLE_APACHE_SSL_REDIRECT: 0
      #APACHE_SERVER_NAME: ""
      #APACHE_SERVER_ALIAS: ""
      #APACHE_SERVER_ADMIN: ""
      #DISABLE_APACHE_DEFAULTSITES: 0
      ## next env only with nginx
      #ENABLE_NGINX_REMOTEIP: 0
      #ENABLE_NGINX_STATUS: 0
```

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/php/)
* [GitHub](https://github.com/Tob1as/docker-php)
