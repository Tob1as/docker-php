# Dockerfile for php and apache2 on x86_64
* https://hub.docker.com/_/php/
* https://packages.debian.org/en/jessie/php/

Use:
* ``` git clone REPOSITORY && cd php/5.6-apache-extend/ ```
* ``` docker build -t php:5.6-apache-extend . ``` 
* ``` docker run --name phpapache -d -p 80:80 --link some-container:alias -v /srv/html:/var/www/html php:5.6-apache-extend ``` 
* http://localhost 
