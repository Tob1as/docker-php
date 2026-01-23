# PHP - Examples: PHP-FPM & NGINX & MySQL (using DHI)

## Information

This example docker-compose setup for [WSC (WoltLab Suite Core)](https://www.woltlab.com) contains 3 Docker Images:
* **PHP** Image from this GitHub Repository.  
  It based on [PHP Image](https://dhi.io/catalog/php) from DHI (Docker Hardened Images) and includes extensions required for WSC.  
  This DHI image has no shell and entrypoint.
* [NGINX Image](https://dhi.io/catalog/nginx) from DHI
* [MySQL Image](https://dhi.io/catalog/mysql) from DHI
* optional Exporter Images from DHI: [MySQL/MariaDB](https://dhi.io/catalog/mysqld-exporter) and [NGINX](https://dhi.io/catalog/nginx-exporter)
* [Traefik Image](https://dhi.io/catalog/traefik) from DHI

  
Notes:
* In this setup [Traefik](https://traefik.io/traefik) is use as Proxy.  
If you don't want to use it, make adjustments in the NGINX configuration file in "config" folder.  
* **Important: To pull Images from DHI you must login with your docker account.** 
* (Sourcecode from DH-Images can found here [https://github.com/docker-hardened-images](https://github.com/docker-hardened-images/catalog/tree/main/image).)
* DHI Docs: https://docs.docker.com/dhi
* DHI images (mostly) have no shell and no entrypoint.
* Images build for AMD64 (x86_64) and ARM64 with Linux.

## Steps
1. Important: Login to dhi.io (`docker login dhi.io`) and optional to docker.io (`docker login`) on your server, if not already done.
2. Copy this folder to your server and move into it.
3. Rename `.env.example` to `.env` and configure your  domain and database settings.  
   (Password generator: [randompasswordgenerator.com](https://randompasswordgenerator.com))
   * `mv .env.example .env`
   * `nano .env`
4. create some subfolder:
   * `mkdir ./html && chown 65532:65532 ./html`
   * `mkdir ./data-db && chown 65532:65532 ./data-db`
5. Configure **Traefik**, set your domains in `./config/traefik/dynamic/traefik-dashboard.yml` and `./config/traefik/dynamic/wsc.yml` or remove `Host(*) &&`. Also in `traefik-dashboard.yml`change basicAuth user and password. Additionally, create SSL certificates contains domain name(s) and set the path within the container in `./config/traefik/dynamic/ssl.yml` or use [Let's Encrypt](https://doc.traefik.io/traefik/reference/install-configuration/tls/certificate-resolvers/acme/).  
   * (1) set domain as variable from `.env`:  
     ```sh
     DOMAIN=$(grep '^DOMAIN=' .env | cut -d= -f2-)
     ```
   * (2) replace domain in dynamic configs:
     ```sh
     find ./config/traefik/dynamic -type f -exec sed -i "s/example.com/${DOMAIN}/g" {} +
     ```
   * (3) example SSL Cert (self sign):  
     create folder:
     ```sh
     mkdir ./ssl-certs
     ```
     create cert (change domain name):
     ```sh
     openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes -subj "/C=DE/ST=none/L=Town/O=Linux Community/CN=${DOMAIN}" -keyout ./ssl-certs/ssl.key -out ./ssl-certs/ssl.crt -addext "subjectAltName=DNS:${DOMAIN},DNS:*.${DOMAIN}" -addext "basicConstraints=CA:FALSE" -addext "keyUsage=digitalSignature,keyEncipherment" -addext "extendedKeyUsage=serverAuth"
     ```  
     Check:  
     ```sh
     openssl x509  -text -noout -in ./ssl-certs/ssl.crt
     ```  
     Change permissions:
     ```sh
     chown 65532:65532 ./ssl-certs/*
     ```
6. optional:
   * update timezone in php conf:
     ```sh
     sed -i "s|^date\.timezone=.*|date.timezone=$(grep '^TIMEZONE=' .env | cut -d= -f2-)|" ./config/php_wsc.ini
     ```
   * check docker-compose.yml:
     ```sh
     docker-compose config
     ```
6. Start the container setup with:  
   ```sh
   docker compose up -d
   ```
7. Create MySQL Databse and User:
   ```sh
   # create database
   docker exec -it wsc-db bash -c 'mysql -uroot -e "CREATE DATABASE ${MYSQL_DATABASE};"'
   # create user and set permissions
   docker exec -it wsc-db bash -c 'mysql -uroot -e "CREATE USER \"${MYSQL_USER}\"@\"%\" IDENTIFIED BY \"${MYSQL_PASSWORD}\"; GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO \"${MYSQL_USER}\"@\"%\";"'
   ```
8. [Download WSC](https://www.woltlab.com/en/woltlab-suite-download/) and unzip archive and copy all files from "upload" folder in "html" folder on your server.
9. Call your domain and file test.php, example: `http://example.com/test.php`
10. Now follows the installation setup of the WSC.  
   Manual/Help: https://manual.woltlab.com/en/installation/  
   (Notice: Database Host is `wsc-db`!)
11. Installation complete.

If necessary, make further configurations for nginx or php in the files in the "config" folder.  
  
> If you want to migrate from another PHP image, e.g. the official community image or other images in this repository, then adjust the folder and file permissions for the html folder:  
`chown 65532:65532 ./html`

## PHP extensions

The base [PHP Image](https://dhi.io/catalog/php) of DHI includes the following PHP extensions by default:   
`cgi-fcgi Core ctype curl date dom fileinfo filter hash iconv intl json libxml mbstring mysqlnd openssl pcre PDO pdo_sqlite Phar posix random readline Reflection session SimpleXML sodium SPL sqlite3 standard tokenizer xml xmlreader xmlwriter 'Zend OPcache' zlib`  
(Check with: `docker run --rm dhi.io/php:<PHP_VERSION>-<OS>-fpm -m`)

The following extensions have been added (for WSC) to the image of this repository:  
`gd pdo_mysql ldap gmp exif redis imagick`  
(Check with: `docker run --rm docker.io/tobi312/php:<PHP_VERSION>-dhi-fpm-<OS>-wsc -m`)

You can check it with `-m` in docker run command or you can place a phpinfo.php file in the "html" folder and call in web browser:  
`echo '<?php phpinfo(); ?>' > ./html/phpinfo.php`  
Please delete the file afterwards!  
