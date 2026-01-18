# PHP - Examples: PHP-FPM & NGINX & MySQL

## Information

This example docker-compose setup for [WSC (WoltLab Suite Core)](https://www.woltlab.com) contains 3 Docker Images:
* **PHP** Image from this GitHub Repository.  
  It based on [PHP Image](https://dhi.io/catalog/php) from DHI (Docker Hardened Images) and includes extensions required for WSC.
* [NGINX Image](https://dhi.io/catalog/nginx) from DHI
* [MySQL Image](https://dhi.io/catalog/mysql) from DHI

In this setup [Traefik](https://traefik.io/traefik) is use as Proxy, a example can find here [https://github.com/Tob1as/docker-kubernetes-collection](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/traefik_v3.yml).  
If you don't want to use it, make adjustments in the NGINX configuration file in "config" folder.  

**Important: To pull Images from DHI you must login with your docker account.**  
(Sourcecode from DH-Images can found here [https://github.com/docker-hardened-images](https://github.com/docker-hardened-images/catalog/tree/main/image).)

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
5. [Download WSC](https://www.woltlab.com/en/woltlab-suite-download/) and unzip archive and copy all files from "upload" folder to "html" folder on your server.
6. Start the container setup with:  
   `docker-compose up -d`
7. call your domain and file test.php, example: `http://example.com/test.php`
8. Now follows the installation setup of the WSC.  
   Manual/Help: https://manual.woltlab.com/en/installation/  
   (Notice: Database Host is `wsc-db`!)
9. Installation complete.

If necessary, make further configurations for nginx or php in the files in the "config" folder.
