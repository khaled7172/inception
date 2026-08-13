#!/bin/sh
set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# Create the FTP user if it doesn't exist yet (first run)
if ! id "${FTP_USER}" >/dev/null 2>&1; then
    adduser -D -h /var/www/html -s /bin/sh "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
fi

chown -R "${FTP_USER}":"${FTP_USER}" /var/www/html
mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd/vsftpd.conf
