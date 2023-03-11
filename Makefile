
INFRA_WORKER_REPO=git@github.com:athmos-cloud/infra-worker-athmos.git
INFRA_WORKER_DIR=infra-worker
PLUGIN_DIR=plugins
PLUGIN_INFRA_HELM_DIR=$(PLUGIN_DIR)/infra/crossplane
PLUGIN_INFRA_REPO_DIR=git@github.com:athmos-cloud/infra-helm-plugin.git

.DEFAULT_GOAL := help

help: _banner ## Show help for all targets
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

rm: ## Remove ohmc containers
ifndef $(svc)
	@docker-compose rm
else
	@docker rm -f $(svc)
	@docker rmi -f docker-ohmc_$(svc)
endif
.PHONY: rm

up:  ## Run ohmc containers
	@docker compose up -V -d --build
.PHONY: up

ps: _banner ## List ohmc containers
	@docker compose ps
.PHONY: ps

logs: ## Show ohmc containers logs [svc=<container> for 1 container]
	@docker compose logs -f $(svc)
.PHONY: logs

nuke-containers: ## Remove all containers
	@docker rm -f $(docker ps -aq)
.PHONY: nuke-containers

_banner:
	@cat .assets/banner
.PHONY: _banner

_clone:
	@git clone $(repo) $(dir)
.PHONY: _clone

clone: ## Clone the repositories
	@mkdir -p $(PLUGIN_DIR)
	$(MAKE) _clone dir=$(INFRA_WORKER_DIR) repo=$(INFRA_WORKER_REPO)
	$(MAKE) _clone dir=$(PLUGIN_INFRA_HELM_DIR) repo=$(PLUGIN_INFRA_REPO_DIR)
.PHONY: clone