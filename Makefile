.PHONY: build-cli
build-cli:
	DOCKER_BUILDKIT=1 docker build --pull . --tag carcel/ttrss:php-7.3 --target=cli

.PHONY: build-fpm
build-fpm:
	DOCKER_BUILDKIT=1 docker build --pull . --tag carcel/ttrss:php-7.3-fpm --target=fpm

.PHONY: build
build: build-cli build-fpm
