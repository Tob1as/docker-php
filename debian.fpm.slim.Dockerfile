ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm
ARG PHP_VERSION

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

LABEL org.opencontainers.image.authors="Tobias Hargesheimer <docker@ison.ws>" \
	org.opencontainers.image.title="PHP-FPM" \
	org.opencontainers.image.description="Debian with PHP ${PHP_VERSION} with FPM" \
	org.opencontainers.image.licenses="MIT" \
	org.opencontainers.image.url="https://hub.docker.com/r/tobi312/php" \
	org.opencontainers.image.source="https://github.com/Tob1as/docker-php"

ENV LANG C.UTF-8
ENV TERM=xterm
ENV CFLAGS="-I/usr/src/php"

# TOOLS
#RUN apt-get update; \
#	apt-get install -y --no-install-recommends \
#		curl \
#		wget \
#		#git \
#		#zip unzip \
#		#patch \
#	; \
#	rm -rf /var/lib/apt/lists/*

# PHP-EXTENSION-INSTALLER
RUN \
	PHP_EXTENSION_INSTALLER_VERSION=$(curl -s https://api.github.com/repos/mlocati/docker-php-extension-installer/releases/latest | grep 'tag_name' | cut -d '"' -f4) ; \
	echo "install-php-extensions Version: ${PHP_EXTENSION_INSTALLER_VERSION}" ; \
	curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/download/${PHP_EXTENSION_INSTALLER_VERSION}/install-php-extensions -o /usr/local/bin/install-php-extensions ; \
	chmod +x /usr/local/bin/install-php-extensions

# PHP
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# ENTRYPOINT
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh ; \
	#sed -i -e 's/\r$//' /usr/local/bin/entrypoint.sh ; \
	mkdir /entrypoint.d

#WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
