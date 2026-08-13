FROM alpine:3.23

RUN apk update && apk add --no-cache nginx

COPY site/ /usr/share/nginx/html/
COPY conf/static.conf /etc/nginx/http.d/default.conf

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]
