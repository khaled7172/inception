FROM alpine:3.23

RUN apk update && apk add --no-cache vsftpd shadow

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/init.sh"]
