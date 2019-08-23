.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build --pull . --tag carcel/ttrss:latest --target=debian
