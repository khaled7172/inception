FROM alpine:3.23

ARG DOMAIN_NAME

RUN apk update && apk add --no-cache nginx openssl

# Generate self-signed SSL certificate at build time
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=LB/ST=MountLebanon/L=Beirut/O=42/CN=${DOMAIN_NAME}"

# Copy nginx config template and bake in the domain name
COPY conf/nginx.conf /etc/nginx/http.d/default.conf.template
RUN sed "s/DOMAIN_PLACEHOLDER/${DOMAIN_NAME}/g" \
    /etc/nginx/http.d/default.conf.template > /etc/nginx/http.d/default.conf && \
    rm /etc/nginx/http.d/default.conf.template

EXPOSE 443

# nginx runs as PID 1 in the foreground — no hacky loops
CMD ["nginx", "-g", "daemon off;"]
