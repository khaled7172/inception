FROM alpine:3.23

RUN apk update && apk add --no-cache \
    php82 php82-fpm php82-mysqli php82-json php82-session \
    php82-mbstring php82-gd php82-curl php82-xml php82-zip \
    php82-phar php82-openssl php82-dom php82-fileinfo \
    curl tar mariadb-client bash

# Install WP-CLI for command-line WordPress management
RUN curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init.sh"]
