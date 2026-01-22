# PHP - Examples: PHP-FPM & NGINX & MySQL (using DHI)

## Information

This example docker-compose setup for [WSC (WoltLab Suite Core)](https://www.woltlab.com) contains 3 Docker Images:
* **PHP** Image from this GitHub Repository.  
  It based on [PHP Image](https://dhi.io/catalog/php) from DHI (Docker Hardened Images) and includes extensions required for WSC.  
  This DHI image has no shell and entrypoint.
* [NGINX Image](https://dhi.io/catalog/nginx) from DHI
* [MySQL Image](https://dhi.io/catalog/mysql) from DHI

  
Notes:
* In this setup [Traefik](https://traefik.io/traefik) is use as Proxy, a example can find here [https://github.com/Tob1as/docker-kubernetes-collection](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/traefik_v3.yml).  
If you don't want to use it, make adjustments in the NGINX configuration file in "config" folder.  
* **Important: To pull Images from DHI you must login with your docker account.** 
* (Sourcecode from DH-Images can found here [https://github.com/docker-hardened-images](https://github.com/docker-hardened-images/catalog/tree/main/image).)
* DHI images (mostly) have no shell and no entrypoint.
* Images build for AMD64 (x86_64) and ARM64.

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
5. Start the container setup with:  
   `docker compose up -d`
6. Create MySQL Databse and User:
   ```sh
   # create database
   docker exec -it wsc-mysql bash -c 'mysql -uroot -e "CREATE DATABASE ${MYSQL_DATABASE};"'
   # create user and set permissions
   docker exec -it wsc-mysql bash -c 'mysql -uroot -e "CREATE USER \"${MYSQL_USER}\"@\"%\" IDENTIFIED BY \"${MYSQL_PASSWORD}\"; GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO \"${MYSQL_USER}\"@\"%\";"'
   ```
7. [Download WSC](https://www.woltlab.com/en/woltlab-suite-download/) and unzip archive and copy all files from "upload" folder in "html" folder on your server.
8. Call your domain and file test.php, example: `http://example.com/test.php`
9. Now follows the installation setup of the WSC.  
   Manual/Help: https://manual.woltlab.com/en/installation/  
   (Notice: Database Host is `wsc-db`!)
10. Installation complete.

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
