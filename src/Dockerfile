FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    mariadb-server mariadb-client \
    php-fpm php-mysql php-mbstring php-zip php-gd php-curl php-xml \
    wget unzip ca-certificates curl dos2unix \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html/wordpress /var/www/html/phpmyadmin /var/www/html/files

RUN wget -q https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && mv wordpress/* /var/www/html/wordpress/ \
    && rm -rf wordpress latest.tar.gz

RUN wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip \
    && unzip -q phpMyAdmin-latest-all-languages.zip \
    && cp -r phpMyAdmin-*/* /var/www/html/phpmyadmin/ \
    && rm -rf phpMyAdmin-* phpMyAdmin-latest-all-languages.zip

RUN chown -R www-data:www-data /var/www/html

COPY nginx.conf /etc/nginx/sites-available/default
COPY start.sh /start.sh

RUN dos2unix /start.sh && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]