FROM alpine:3.23

RUN apk update && apk add --no-cache \
    php84 php84-fpm php84-mysqli php84-session \
    php84-mbstring php84-gd php84-curl php84-xml php84-zip \
    php84-phar php84-openssl php84-dom php84-fileinfo php84-tokenizer \
    curl tar mariadb-client bash ca-certificates netcat-openbsd

COPY conf/wp-cli.phar /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp

WORKDIR /var/www/html

# Increase PHP memory limit for WP-CLI and FPM (default 128M is too low for WP 7.x)
RUN echo "memory_limit = 512M" > /etc/php84/conf.d/99-custom.ini

COPY conf/www.conf /etc/php84/php-fpm.d/www.conf
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init.sh"]
