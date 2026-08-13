# Developer Documentation — Inception

## Prerequisites

- A Virtual Machine running Alpine Linux (or Debian)
- Docker and Docker Compose installed
- `git` installed
- Root access or user in the `docker` group

### Installing Docker on Alpine

```bash
sudo apk add --update docker docker-cli-compose openrc
sudo rc-update add docker default
sudo service docker start
sudo addgroup $USER docker
# Log out and back in for group change to take effect
```

## Setup From Scratch

### 1. Clone the repository

```bash
git clone <repo-url> inception
cd inception
```

### 2. Configure secrets

Create the secret files with real passwords (these are git-ignored):

```bash
# MariaDB root password
echo "YourSecureRootPass123!" > secrets/db_root_password.txt

# MariaDB WordPress user password
echo "YourSecureDbPass123!" > secrets/db_password.txt

# WordPress admin and editor passwords
cat > secrets/credentials.txt << EOF
WP_ADMIN_PASSWORD=YourSecureAdminPass123!
WP_USER_PASSWORD=YourSecureEditorPass123!
EOF

# FTP password (bonus)
echo "YourSecureFtpPass123!" > secrets/ftp_password.txt
```

### 3. Configure environment variables

Edit `srcs/.env` to set your login and domain:

```bash
LOGIN=khhammou
DOMAIN_NAME=khhammou.42.fr
```

### 4. Set up DNS

```bash
echo "<VM-IP>  khhammou.42.fr" | sudo tee -a /etc/hosts
```

### 5. Create host data directories

```bash
sudo mkdir -p /home/khhammou/data/db /home/khhammou/data/wordpress
```

## Build & Launch

```bash
# Mandatory services only (nginx + wordpress + mariadb)
make

# All services including bonus (redis, ftp, adminer, static-site, netdata)
make bonus
```

The Makefile calls `docker compose` which reads `srcs/docker-compose.yml` (and `srcs/docker-compose.bonus.yml` for bonus). Docker Compose:
1. Builds each image from its Dockerfile under `srcs/requirements/`
2. Creates named volumes, the bridge network, and loads secrets
3. Starts containers in dependency order (mariadb → wordpress → nginx)

## Useful Commands

### Container Management

```bash
# List running containers
docker ps

# View logs (all services)
make logs

# View logs for a single service
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb

# Enter a container shell
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh

# Restart a single service
docker restart wordpress
```

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_db_data
docker volume inspect srcs_wp_data
```

### Network Management

```bash
# List networks
docker network ls

# Inspect the inception network
docker network inspect srcs_inception
```

### Cleanup

```bash
# Stop containers
make stop

# Stop and remove containers + network
make down

# Remove everything (containers, images, build cache)
make clean

# Remove everything + delete host data
make fclean

# Full rebuild
make re
```

## Project Data Storage

| Data | Container Path | Host Path | Persists? |
|------|---------------|-----------|-----------|
| MariaDB database | `/var/lib/mysql` | `/home/khhammou/data/db` | ✅ Yes (named volume) |
| WordPress files | `/var/www/html` | `/home/khhammou/data/wordpress` | ✅ Yes (named volume) |
| NGINX SSL certs | `/etc/nginx/ssl/` | — | ❌ Rebuilt on image build |
| NGINX config | `/etc/nginx/http.d/` | — | ❌ Baked into image |

Data in named volumes persists across `docker compose down` and `docker compose up`. It is only deleted by `make fclean` (which runs `sudo rm -rf /home/khhammou/data`).

## File Structure

```
./
├── Makefile                          # Build/run orchestrator
├── README.md                         # Project overview + comparisons
├── USER_DOC.md                       # End-user documentation
├── DEV_DOC.md                        # This file (developer docs)
├── secrets/                          # Docker secrets (git-ignored)
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── ftp_password.txt
└── srcs/
    ├── .env                          # Environment variables (git-ignored)
    ├── docker-compose.yml            # Mandatory services
    ├── docker-compose.bonus.yml      # Bonus services overlay
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/my.cnf
        │   └── tools/init.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/www.conf
        │   └── tools/init.sh
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/redis.conf
            ├── ftp/
            │   ├── Dockerfile
            │   ├── conf/vsftpd.conf
            │   └── tools/init.sh
            ├── adminer/
            │   └── Dockerfile
            ├── static-site/
            │   ├── Dockerfile
            │   ├── conf/static.conf
            │   └── site/{index.html,style.css}
            └── netdata/
                └── Dockerfile
```
