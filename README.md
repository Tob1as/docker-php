# PHP (with Apache2) on x86_64

### Supported tags and respective `Dockerfile` links
-	`7.*-apache-extend` *Coming soon*
-	[`5.6-apache-extend` (*Dockerfile*)](https://github.com/TobiasH87Docker/php/blob/master/5.6-apache-extend/Dockerfile)

### Information:
This image based on the offical PHP image https://hub.docker.com/_/php/ and for more Information about PHP see here: https://php.net , https://packages.debian.org/en/jessie/php/ and https://pecl.php.net/

### How to use this image
* ``` $ docker pull tobi312/php:5.6-apache-extend ```
* Optional: ``` $ mkdir -p /srv/html ```
* ``` $ docker run --name php5apache -d -p 80:80 -p 443:443 --link some-container:alias -v /srv/html:/var/www/html tobi312/php:5.6-apache-extend ``` 

or build it yourself
* ``` $ git clone REPOSITORY && cd php/ ```
* ``` $ docker build -t tobi312/php:5.6-apache-extend ./5.6-apache-extend/ ``` 
* ``` $ docker run --name php5apache -d -p 80:80 -p 443:443 --link some-container:alias -v /srv/html:/var/www/html tobi312/php:5.6-apache-extend ``` 
* http://localhost or https://localhost

### This Image on
* [DockerHub](https://hub.docker.com/r/tobi312/php/)
* [GitHub](https://github.com/TobiasH87Docker/php)
