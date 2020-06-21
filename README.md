# PHP (with Apache2 or FPM) on x86_64 and arm

### Supported tags and respective `Dockerfile` links
-	[`7.4-apache` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.x86_64.7_4_apache.Dockerfile)
-	[`7.4-fpm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.x86_64.7_4_fpm.Dockerfile)
-	[`7.4-apache-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.armhf.7_4_apache.Dockerfile)
-	[`7.4-fpm-arm` (*Dockerfile*)](https://github.com/Tob1asDocker/php/blob/master/debian.armhf.7_4_fpm.Dockerfile)
- `7.4-fpm-alpine` (*Coming soon ...*)
- `7.4-fpm-alpine-arm` (*Coming soon ...*)
- *for older versions see unsupported ["old"](https://github.com/Tob1asDocker/php/tree/old)-branch*

### What is PHP?

PHP is a server-side scripting language designed for web development, but which can also be used as a general-purpose programming language. PHP can be added to straight HTML or it can be used with a variety of templating engines and web frameworks. PHP code is usually processed by an interpreter, which is either implemented as a native module on the web-server or as a common gateway interface (CGI).

> [wikipedia.org/wiki/PHP](https://en.wikipedia.org/wiki/PHP)

![logo](https://raw.githubusercontent.com/docker-library/docs/master/php/logo.png)

### About these images:
* based on official Images: [https://hub.docker.com/_/php/](https://hub.docker.com/_/php/) / [https://github.com/docker-library/php](https://github.com/docker-library/php)
* This image extends the base image with many php extensions, for example: SQL-Databases, GD, imagick, ldap and more. For information about PHP and extensions see here: https://php.net and https://pecl.php.net/

### How to use these images:
* ``` $ docker run --name phpcontainer -v $(pwd)/html:/var/www/html:rw -p PORT:PORT -e PHP_ERRORS=1 -e PHP_UPLOAD_MAX_FILESIZE=250 -d tobi312/php:TAG```

* Environment Variables:  
  * `TZ` (set timezone, example: "Europe/Berlin")
  * `PHP_ERRORS` (set 1 to enable)
  * `PHP_MEM_LIMIT` (set Value in MB, example: 128)
  * `PHP_POST_MAX_SIZE` (set Value in MB, example: 250)
  * `PHP_UPLOAD_MAX_FILESIZE` (set Value in MB, example: 250)
  * `PHP_MAX_FILE_UPLOADS` (set number, example: 20)
  * `CREATE_PHPINFO_FILE` (set 1 to enable)
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

* Ports:
  * php with apache: `80` (http), optional: `443` (https)
  * php with fpm: `9000`

* An own Dockerfile?, then here an example with copy additional own entrypoint-file(s) in apache image:  
  ``` $ echo -e "FROM tobi312/7.4-apache\nCOPY *.sh /entrypoint.d/" > Dockerfile```

#### Docker-Compose

```yaml
version: "2.4"
services:
  php:
    image: tobi312/php:7.4-apache
    #image: tobi312/php:7.4-fpm
    container_name: phpcontainer
    restart: unless-stopped
    ports:
      ## only with apache:
      - "80:80"
      - "443:443"
      ## only with fpm (optional)
      #- "9000"
    volumes:
      - ./html:/var/www/html:rw
      ## optional: folder with own entrypoint-file(s) mount:
      #- ./entrypoint.d:/entrypoint.d:ro
      ## optional: own ssl-cert and -key:
      #- ./ssl/mySSL.crt:/etc/ssl/certs/ssl-cert-snakeoil.pem:ro
      #- ./ssl/mySSL.key:/etc/ssl/private/ssl-cert-snakeoil.key:ro
    environment:
      TZ: "Europe/Berlin"
      PHP_ERRORS: 1
      PHP_MEM_LIMIT: 128
      PHP_POST_MAX_SIZE: 250
      PHP_UPLOAD_MAX_FILESIZE: 250
      PHP_MAX_FILE_UPLOADS: 20
      CREATE_PHPINFO_FILE: 0
      ## next env only with apache
      ENABLE_APACHE_REWRITE: 1
      ENABLE_APACHE_ACTIONS: 0
      ENABLE_APACHE_SSL: 0
      ENABLE_APACHE_HEADERS: 0
      ENABLE_APACHE_ALLOWOVERRIDE: 1
      ENABLE_APACHE_REMOTEIP: 0
      ENABLE_APACHE_STATUS: 1
      #ENABLE_APACHE_SSL_REDIRECT: 0
      #APACHE_SERVER_NAME: ""
      #APACHE_SERVER_ALIAS: ""
      #APACHE_SERVER_ADMIN: ""
      #DISABLE_APACHE_DEFAULTSITES: 0
```

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/php/)
* [GitHub](https://github.com/Tob1asDocker/php)
