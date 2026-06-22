.PHONY: install build dev up down logs test generate-api shell curl-check

# Default HTTP port (override: make up PORT=9090)
PORT ?= 8081
export PORT

## install: install backend PHP dependencies (inside the container)
install:
	docker-compose run --rm backend composer install

## build: build the backend Docker image
build:
	docker-compose build

## dev / up: start the stack in the background
dev: up
up:
	docker-compose up -d

## down: stop the stack
down:
	docker-compose down

## logs: follow backend logs
logs:
	docker-compose logs -f backend

## test: run the PHPUnit test suite (inside the container)
test:
	docker-compose run --rm -e APP_ENV=test backend php bin/phpunit

## generate-api: compile TypeSpec -> OpenAPI and sync it into the backend
generate-api:
	npm run generate:api
	cp openapi/schema/openapi.yaml backend/public/openapi.yaml

## shell: open a shell inside the backend container
shell:
	docker-compose run --rm backend sh

## curl-check: quick smoke test against the running API
curl-check:
	curl -fsS http://localhost:$(PORT)/api/event-types && echo
