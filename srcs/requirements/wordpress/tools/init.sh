#!/bin/sh
set -e

mkdir -p /run/php

# Read secrets from Docker secrets (passwords never in env vars or Dockerfiles)
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d '=' -f2)
WP_USER_PASSWORD=$(grep WP_USER_PASSWORD /run/secrets/credentials | cut -d '=' -f2)

# First-run: download WordPress, create config, install site, create users
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[init] Downloading WordPress core..."
    wp core download --allow-root --force

    echo "[init] Waiting for MariaDB to be reachable..."
    until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
        sleep 2
    done

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root


    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    chown -R nobody:nobody /var/www/html
    echo "[init] WordPress installed."
fi

# Bonus: Redis object cache — only runs if REDIS_HOST env var is set
# (set by docker-compose.bonus.yml). Idempotent, safe to run every start.
if [ -n "${REDIS_HOST}" ] && [ -f /var/www/html/wp-config.php ]; then
    if ! wp plugin is-installed redis-cache --path=/var/www/html --allow-root 2>/dev/null; then
        echo "[init] Setting up Redis object cache..."
        wp plugin install redis-cache --activate --path=/var/www/html --allow-root
        wp config set WP_REDIS_HOST "${REDIS_HOST}" --path=/var/www/html --allow-root
        wp redis enable --path=/var/www/html --allow-root
    fi
fi

# Start php-fpm as PID 1 in the foreground (exec replaces the shell)
exec php-fpm84 -F
