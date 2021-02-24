# PHP (with Apache2 or FPM or NGINX) on x86_64 and ARM

### Supported tags and respective `Dockerfile` links
-	[`8.0-apache` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.x86_64.8_0_apache.Dockerfile) | [`8.0-apache-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.armhf.8_0_apache.Dockerfile)
-	[`8.0-fpm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.x86_64.8_0_fpm.Dockerfile) | [`8.0-fpm-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.armhf.8_0_fpm.Dockerfile)
- [`8.0-fpm-alpine` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.x86_64.8_0_fpm.Dockerfile) | [`8.0-fpm-alpine-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.armhf.8_0_fpm.Dockerfile) | [`8.0-fpm-nginx-alpine-slim` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.x86_64.8_0_fpm_nginx_slim.Dockerfile) | [`8.0-fpm-nginx-alpine-slim-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.armhf.8_0_fpm_nginx_slim.Dockerfile)
- [`8.0-fpm-nginx-alpine` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.x86_64.8_0_fpm_nginx.Dockerfile) | [`8.0-fpm-nginx-alpine-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.armhf.8_0_fpm_nginx.Dockerfile)
-	[`7.4-apache` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.x86_64.7_4_apache.Dockerfile) | [`7.4-apache-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.armhf.7_4_apache.Dockerfile)
-	[`7.4-fpm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.x86_64.7_4_fpm.Dockerfile) | [`7.4-fpm-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.armhf.7_4_fpm.Dockerfile)
- [`7.4-fpm-alpine` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.x86_64.7_4_fpm.Dockerfile) | [`7.4-fpm-alpine-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.armhf.7_4_fpm.Dockerfile)
- [`7.4-fpm-nginx-alpine-slim` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.x86_64.7_4_fpm_nginx_slim.Dockerfile) | [`7.4-fpm-nginx-alpine-slim-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.armhf.7_4_fpm_nginx_slim.Dockerfile)
- [`7.4-fpm-nginx-alpine` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.x86_64.7_4_fpm_nginx.Dockerfile) | [`7.4-fpm-nginx-alpine-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/alpine.armhf.7_4_fpm_nginx.Dockerfile)


### What is PHP?

PHP is a server-side scripting language designed for web development, but which can also be used as a general-purpose programming language. PHP can be added to straight HTML or it can be used with a variety of templating engines and web frameworks. PHP code is usually processed by an interpreter, which is either implemented as a native module on the web-server or as a common gateway interface (CGI).

> [wikipedia.org/wiki/PHP](https://en.wikipedia.org/wiki/PHP)

![logo](https://raw.githubusercontent.com/docker-library/docs/master/php/logo.png)

### About these images:
* based on official images: [https://hub.docker.com/_/php/](https://hub.docker.com/_/php/) / [https://github.com/docker-library/php](https://github.com/docker-library/php)
* The official base Images have the following PHP extensions enabled by default (check with: ```php -m```): ```Core ctype curl date dom fileinfo filter ftp hash iconv json libxml mbstring mysqlnd openssl pcre PDO pdo_sqlite Phar posix readline Reflection session SimpleXML sodium SPL sqlite3 standard tokenizer xml xmlreader xmlwriter zlib```
* These images extend the basic images with additional PHP extensions, for example: SQL-Databases, gd, imagick, ldap and more. For details see in dockerfiles.
* For easy install the extensions and get a smaller images it use [php-extension-installer](https://github.com/mlocati/docker-php-extension-installer).
* For information about PHP and extensions see here: [php.net](https://php.net) and [pecl.php.net](https://pecl.php.net).

### How to use these images:
* ``` $ docker run --name phpcontainer -v $(pwd)/html:/var/www/html:rw -p PORT:80 -e PHP_ERRORS=1 -e PHP_UPLOAD_MAX_FILESIZE=250 -d tobi312/php:8.0-apache```

* Environment Variables:  
  * `TZ` (set timezone, example: "Europe/Berlin")
  * `PHP_ERRORS` (set 1 to enable)
  * `PHP_MEM_LIMIT` (set Value in MB, example: 128)
  * `PHP_POST_MAX_SIZE` (set Value in MB, example: 250)
  * `PHP_UPLOAD_MAX_FILESIZE` (set Value in MB, example: 250)
  * `PHP_MAX_FILE_UPLOADS` (set number, example: 20)
  * `CREATE_PHPINFO_FILE` (set 1 to enable, for dev and testing)
  * `CREATE_INDEX_FILE` (set 1 to enable, for dev and testing)
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

* An own Dockerfile?, then here an example with copy additional own entrypoint-file(s) in apache image:  
  ``` $ echo -e "FROM tobi312/php:8.0-apache\nCOPY *.sh /entrypoint.d/" > Dockerfile```

#### Docker-Compose

```yaml
version: "2.4"
services:
  php:
    image: tobi312/php:8.0-apache
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

#### Troubleshooting

If your container fails to start with Images that based on Alpine 3.13 or newer Ubuntu on ARM devices with Raspbian/Debian 10 Buster (32 bit) then update `libseccomp2`[*](https://packages.debian.org/buster-backports/libseccomp2) to >=2.4.4 and restart the container. (Source: [1](https://docs.linuxserver.io/faq#libseccomp), [2](https://github.com/owncloud/docs/pull/3196#issue-577993147), [3](https://github.com/moby/moby/issues/40734))  
  
Example (wrong date):
```sh
$ docker run --rm --name testing -it alpine:3.13 date
Sun Jan  0 00:100:4174038  1900
```
  
Solution:
```sh
 sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
 echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/buster-backports.list
 sudo apt update
 sudo apt install -t buster-backports libseccomp2
```

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/php/)
* [GitHub](https://github.com/Tob1asDocker/php)
