NAME        = inception
ENV_FILE    = srcs/.env
LOGIN       := $(shell grep -E '^LOGIN=' $(ENV_FILE) | cut -d '=' -f2)
DATA_DIR    = /home/$(LOGIN)/data
COMPOSE     = docker compose -f srcs/docker-compose.yml
COMPOSE_ALL = docker compose -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml

all: up

up:
	mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

bonus:
	mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wordpress
	$(COMPOSE_ALL) up -d --build

down:
	$(COMPOSE_ALL) down

stop:
	$(COMPOSE_ALL) stop

start:
	$(COMPOSE_ALL) start

logs:
	$(COMPOSE_ALL) logs -f

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all up bonus down stop start logs clean fclean re
