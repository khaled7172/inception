FROM alpine:3.23

RUN apk update && apk add --no-cache php84 php84-mysqli php84-session curl

WORKDIR /var/www
RUN curl -skSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o index.php

EXPOSE 8080

CMD ["php84", "-S", "0.0.0.0:8080", "-t", "/var/www"]
