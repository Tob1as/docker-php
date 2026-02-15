# PHP - Examples

All examples for [WSC (WoltLab Suite Core)](https://www.woltlab.com/en/woltlab-suite-download/)!

* DHI (Docker Hardened Images) without entrypoint script:
    * `dhi-fpm-nginx`: php-fpm, nginx, mysql, traefik, prometheus-exporters - for more Details/Help read README.md in folder!
    * `dhi-fpm-nginx-k8s`: like fpm-nginx-dhi but for Kubernetes/K8s (tested on K3s) - for more Details/Help read README.md in folder!
* DOI (Docker Official Images) without entrypoint script:
    * `doi-apache`: apache2 with php, mariadb, traefik, prometheus-exporters.
    * `doi-fpm-nginx`: php-fpm, nginx, mariadb, traefik, prometheus-exporters.
* DOI (Docker Official Images) with entrypoint script:
    * `apache`: apache2 with php, mariadb, traefik, prometheus-exporters.
    * `fpm-nginx`: php-fpm, nginx, mariadb, traefik, prometheus-exporters.
    * `fpm-nginx-aio`: like fpm-nginx, but php-fpm and nginx in single container/image.
