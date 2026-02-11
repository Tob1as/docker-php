# PHP - Examples

All examples for [WSC (WoltLab Suite Core)](https://www.woltlab.com/en/woltlab-suite-download/)!

* fpm-nginx-dhi: php-fpm, nginx, mysql, traefik, prometheus-exporters without entrypoint script - only using DHI (Docker Hardened Images) - for more Details/Help read README.md in folder!
* fpm-nginx-dhi-k8s: like fpm-nginx-dhi but for Kubernetes/K8s (tested on K3s) - for more Details/Help read README.md in folder!
* fpm-nginx-doi: like fpm-nginx-dhi, but Docker Offical Images (DOI, from Community) and also without entrypoint script.
* fpm-nginx: like fpm-nginx-doi, but Docker Offical Images with entrypoint script from this repo. (Notice: mysql replaced by mariadb) 
* fpm-nginx-aio: like fpm-nginx, but php-fpm and nginx in single container/image with entrypoint script from this repo.
* apache: apache2 and php in single container/image, mariadb, traefik, prometheus-exporters with entrypoint script from this repo.
* apache-doi: like apache, but without entryoint script.