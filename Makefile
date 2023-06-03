PROJECT_NAME=docker_sf6_init

DOCKER = docker
DOCKER_RUN = $(DOCKER) run
DOCKER_PHP_EXEC = $(DOCKER) exec $(PROJECT_NAME)_php
DOCKER_PHP_EXEC_IT = $(DOCKER) exec -it $(PROJECT_NAME)_php bash
DOCKER_NODE_EXEC = $(DOCKER) exec -it $(PROJECT_NAME)_node
DOCKER_NODE_EXEC_IT = $(DOCKER) exec -it $(PROJECT_NAME)_node sh
DOCKER_COMPOSE_DEV = docker-compose -f./docker-compose.dev.yml --env-file ./.docker.env.local
DOCKER_COMPOSE_BUILD_DEV = $(DOCKER_COMPOSE_DEV) build
DOCKER_COMPOSE_UP_DEV = $(DOCKER_COMPOSE_DEV) up -d
DOCKER_COMPOSE_STOP_DEV = $(DOCKER_COMPOSE_DEV) stop
DOCKER_COMPOSE_DOWN_DEV = $(DOCKER_COMPOSE_DEV) down


COMPOSER = $(DOCKER_PHP_EXEC) composer

CONSOLE = $(DOCKER_PHP_EXEC) php bin/console

NPM = $(DOCKER_NODE_EXEC) npm

help: ## Show this help.
	@echo "Symfony-And-Docker-Makefile"
	@echo "---------------------------"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
#---------------------------------------------#

##=== 🐋  DOCKER ================================================
docker-build-dev: ## Build dev docker containers.
	$(DOCKER_COMPOSE_BUILD_DEV)
.PHONY: docker-build-dev

docker-up-dev: ## Start dev docker containers.
	$(DOCKER_COMPOSE_UP_DEV)
.PHONY: docker-up-dev

docker-stop-dev: ## Stop dev docker containers.
	$(DOCKER_COMPOSE_STOP_DEV)
.PHONY: docker-stop-dev

docker-down-dev: ## Down dev docker containers.
	$(DOCKER_COMPOSE_DOWN_DEV)
.PHONY: docker-down-dev

docker-restart-dev: ## Restart dev docker containers.
	make docker-stop-dev docker-up-dev
.PHONY: docker-restart-dev
#---------------------------------------------#

##=== 🎛️  SYMFONY ===============================================
sf-dd: ## Drop dev database
	$(CONSOLE) doctrine:database:drop --if-exists --force
.PHONY: sf-dc

sf-dc: ## Create dev database
	$(CONSOLE) doctrine:database:create
.PHONY: sf-dc

sf-su: ## Update symfony schema database.
	$(CONSOLE) doctrine:schema:update --force --no-interaction
.PHONY: sf-su

sf-mm: ## Make migrations.
	$(CONSOLE) make:migration
.PHONY: sf-mm

sf-dmm: ## Migrate all migrations.
	$(CONSOLE) doctrine:migrations:migrate --no-interaction
.PHONY: sf-dmm

sf-fixtures: ## Load fixtures.
	$(CONSOLE) doctrine:fixtures:load --no-interaction
.PHONY: sf-fixtures

sf-cc: ## Clear cache
	$(CONSOLE) cache:clear
	$(CONSOLE) cache:warmup
.PHONY: sf-fixtures

##=== 📦  COMPOSER ==============================================
composer-install: ## Install composer dependencies.
	$(COMPOSER) install
.PHONY: composer-install

composer-update: ## Update composer dependencies.
	$(COMPOSER) update
.PHONY: composer-update

composer-validate: ## Validate composer.json file.
	$(COMPOSER) validate --strict
.PHONY: composer-validate
#---------------------------------------------#

##=== 📦  NPM ===================================================
npm-install: ## Install npm dependencies.
	$(NPM) install
.PHONY: npm-install

npm-update: ## Update npm dependencies.
	$(NPM) update
.PHONY: npm-update

npm-build: ## Build assets.
	$(NPM) run build
.PHONY: npm-build

npm-dev: ## Build assets in dev mode.
	$(NPM) run dev
.PHONY: npm-dev

npm-watch: ## Watch assets.
	$(NPM) run watch
.PHONY: npm-watch

#---------------------------------------------#

##=== ⭐  OTHERS ================================================
app-php-shell: ## Enter in the app php shell terminal
	$(DOCKER_PHP_EXEC_IT)
.PHONY: app-php-shell

app-node-shell: ## Enter in the app node shell terminal
	$(DOCKER_NODE_EXEC_IT)
.PHONY: app-node-shell
#---------------------------------------------#
