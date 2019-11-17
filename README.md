# Tiny Tiny RSS running on Docker

## Requirements

- Docker
- Docker Compose
- Make
- [Traefik running through Docker](https://github.com/damien-carcel/traefik-as-local-reverse-proxy) to access the
  application through HTTPS.

## Running Tiny Tiny RSS

Start the containers:
```bash
$ make up
```

Then access the application through [ttrss.docker.localhost](https://ttrss.docker.localhost).
