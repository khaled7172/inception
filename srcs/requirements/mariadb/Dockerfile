FROM alpine:3.23

RUN apk update && apk add --no-cache mariadb mariadb-client

COPY conf/my.cnf /etc/my.cnf.d/50-server.cnf
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh && \
    mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init.sh"]
