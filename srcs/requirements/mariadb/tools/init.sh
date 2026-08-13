#!/bin/sh
set -e

DB_DATA_DIR="/var/lib/mysql"
SOCK="/run/mysqld/mysqld.sock"

# Read passwords from Docker secrets (not env vars — never in Dockerfiles)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# First-run: initialize the data directory and create DB + user
if [ ! -d "${DB_DATA_DIR}/mysql" ]; then
    echo "[init] First run: initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir="${DB_DATA_DIR}" > /dev/null

    # Start mysqld temporarily with networking disabled for local setup
    mysqld --user=mysql --datadir="${DB_DATA_DIR}" --skip-networking --socket="${SOCK}" &
    pid="$!"

    # Wait until MariaDB is ready to accept connections
    until mysqladmin --socket="${SOCK}" ping --silent 2>/dev/null; do
        sleep 1
    done

    # Run setup SQL: secure root, create WP database and user
    mysql --socket="${SOCK}" -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Shut down the temporary server cleanly
    mysqladmin --socket="${SOCK}" -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait "$pid"
    echo "[init] MariaDB initialized."
fi

# Start MariaDB as PID 1 (exec replaces the shell — proper foreground process)
exec mysqld --user=mysql --datadir="${DB_DATA_DIR}" --bind-address=0.0.0.0
