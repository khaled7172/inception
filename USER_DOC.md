# User Documentation — Inception

## What This Stack Provides

Inception runs a complete WordPress website with the following services:

| Service | Purpose | Access |
|---------|---------|--------|
| **NGINX** | Reverse proxy + TLS termination | https://khhammou.42.fr (port 443) |
| **WordPress** | Website CMS (content management) | Via NGINX |
| **MariaDB** | Database for WordPress | Internal only (port 3306) |
| **Redis** *(bonus)* | WordPress object cache | Internal only (port 6379) |
| **FTP** *(bonus)* | File access to WordPress uploads | Port 21 |
| **Adminer** *(bonus)* | Database management web UI | http://khhammou.42.fr:8080 |
| **Static Site** *(bonus)* | Standalone HTML/CSS showcase page | http://khhammou.42.fr:8082 |
| **Netdata** *(bonus)* | Real-time server monitoring | http://khhammou.42.fr:19999 |

## How to Start and Stop

```bash
# Start all services (mandatory + bonus)
make

# Note: make bonus is provided for subject compatibility but does the exact same thing.
make bonus

# Stop all services (containers stay, just stopped)
make stop

# Start previously stopped services
make start

# Stop and remove all containers
make down

# Full cleanup (remove containers, images, volumes, host data)
make fclean

# Rebuild from scratch
make re
```

## Accessing the Website

1. Make sure `khhammou.42.fr` points to your VM's IP in `/etc/hosts`:
   ```
   <VM-IP>  khhammou.42.fr
   ```
2. Open a browser and go to: **https://khhammou.42.fr**
3. Accept the self-signed certificate warning.

### WordPress Admin Panel

- URL: **https://khhammou.42.fr/wp-admin**
- Admin user: `wp_owner` (set in `.env`)
- Admin password: value in `secrets/credentials.txt` (`WP_ADMIN_PASSWORD=...`)

### Second User (Editor)

- Username: `wp_editor`
- Password: value in `secrets/credentials.txt` (`WP_USER_PASSWORD=...`)

## Credentials Management

All passwords are stored as **Docker secrets** in the `secrets/` directory:

| File | Contains |
|------|----------|
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/db_password.txt` | MariaDB WordPress user password |
| `secrets/credentials.txt` | WordPress admin + editor passwords |
| `secrets/ftp_password.txt` | FTP user password (bonus) |

**To change a password:**
1. Edit the relevant file in `secrets/`
2. Run `make fclean && make` to rebuild with new credentials

> ⚠️ These files are git-ignored and must **never** be committed.

## Verifying Services Are Running

```bash
# Check all containers are up
docker ps

# Check logs for a specific service
docker logs mariadb
docker logs wordpress
docker logs nginx

# Follow all logs live
make logs

# Test NGINX is responding
curl -k https://khhammou.42.fr

# Test MariaDB is accepting connections
docker exec mariadb mysqladmin ping -u wp_user -p<password>
```
