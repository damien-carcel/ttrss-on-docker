.PHONY: pull
pull:
	docker-compose pull --ignore-pull-failures

.PHONY: build-front
build-front:
	DOCKER_BUILDKIT=1 docker build --pull . --tag carcel/ttrss:nginx --target=nginx

.PHONY: build-fpm
build-fpm:
	DOCKER_BUILDKIT=1 docker build --pull . --tag carcel/ttrss:fpm --target=fpm

.PHONY: build-daemon
build-daemon:
	DOCKER_BUILDKIT=1 docker build --pull . --tag carcel/ttrss:daemon --target=cli

.PHONY: build
build: build-fpm build-daemon build-front

.PHONY: up
up: pull build
	docker-compose up -d

.PHONY: down
down:
	docker-compose down -v
