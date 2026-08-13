FROM alpine:3.23

RUN apk update && apk add --no-cache php82 php82-mysqli php82-session curl

WORKDIR /var/www
RUN curl -sSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o index.php

EXPOSE 8080

CMD ["php82", "-S", "0.0.0.0:8080", "-t", "/var/www"]
