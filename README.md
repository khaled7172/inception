*This project has been created as part of the 42 curriculum by khhammou.*

# Inception

A Docker-based infrastructure project that sets up a complete WordPress website with NGINX, MariaDB, and several bonus services — all running in isolated containers orchestrated by Docker Compose.

## Description

Inception builds a small but production-like web stack entirely from custom Docker images (no pre-built images from DockerHub). Every service runs in its own container, built from Alpine Linux 3.23, communicating over a private Docker network.

### Architecture

```
         [ Browser ]
              |
           Port 443 (TLS 1.2/1.3)
              |
        [ NGINX container ]
              |
     (Docker named network)
      /                  \
[ WordPress+php-fpm ]  [ MariaDB ]
       |                    |
  [Volume: files]    [Volume: db]
  /home/khhammou/data  /home/khhammou/data
```

### Virtual Machines vs Docker

| Aspect | Virtual Machine | Docker Container |
|--------|----------------|-----------------|
| Isolation | Full OS with own kernel | Shares host kernel |
| Startup | Minutes | Seconds |
| Resource usage | Heavy (RAM, CPU, disk) | Lightweight |
| Image size | Gigabytes | Megabytes |
| Best for | Running different OS's | Running applications |

Docker containers share the host OS kernel and use Linux namespaces + cgroups for isolation, making them far more efficient than full VMs while still providing process-level isolation.

### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|----------------|
| Storage | In `.env` file, loaded into container env | Mounted as files under `/run/secrets/` |
| Visibility | Visible via `docker inspect`, `env` command | Only accessible inside the container's filesystem |
| Use case | Non-sensitive config (domain, DB name) | Passwords, API keys, credentials |
| Security | Should never contain passwords | Designed specifically for sensitive data |

This project uses `.env` for configuration (database name, usernames, domain) and Docker secrets for all passwords.

### Docker Network vs Host Network

| Aspect | Docker Bridge Network | Host Network |
|--------|----------------------|-------------|
| Isolation | Containers get private IPs | Container shares host's network stack |
| Port mapping | Explicit port publishing needed | No mapping needed, but no isolation |
| Service discovery | Containers reach each other by service name | Must use localhost + different ports |
| Security | Containers are isolated from host network | No network isolation |

This project uses a custom bridge network (`inception`) — containers communicate by service name (e.g., `wordpress` connects to `mariadb`), and only NGINX port 443 is exposed externally.

### Docker Volumes vs Bind Mounts

| Aspect | Named Volumes | Bind Mounts |
|--------|--------------|-------------|
| Management | Managed by Docker | You manage the host path |
| Portability | Docker handles storage location | Tied to specific host path |
| Backup | Via Docker CLI | Direct filesystem access |
| Permissions | Docker handles ownership | Must manage permissions manually |

This project uses named volumes with `driver_opts` to store data at `/home/khhammou/data/` on the host.

## Instructions

### Prerequisites
- Docker and Docker Compose installed
- A virtual machine (Alpine or Debian recommended)

### Installation & Execution

```bash
# Clone the repository
git clone <repo-url> inception && cd inception

# Edit secrets with real passwords
vi secrets/db_root_password.txt
vi secrets/db_password.txt
vi secrets/credentials.txt

# Add domain to /etc/hosts
echo "127.0.0.1 khhammou.42.fr" | sudo tee -a /etc/hosts

# Build and run all services
make
# Note: make bonus is functionally identical in this configuration.
```

### Access
- **Website:** https://khhammou.42.fr
- **WordPress Admin:** https://khhammou.42.fr/wp-admin
- **Adminer (bonus):** http://khhammou.42.fr:8080
- **Static Site (bonus):** http://khhammou.42.fr:8082
- **Netdata (bonus):** http://khhammou.42.fr:19999

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI Handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Alpine Linux Wiki](https://wiki.alpinelinux.org/)

### AI Usage

AI was used as a learning aid during this project for:
- Understanding Docker concepts (namespaces, cgroups, union filesystems)
- Debugging shell script syntax and MariaDB initialization sequence
- Clarifying NGINX TLS configuration and FastCGI proxy setup
- Reviewing Dockerfile best practices (PID 1, multi-stage considerations)

All generated suggestions were reviewed, understood, and adapted manually. Every line of the final submission can be explained and justified.
