

help: banner ## Show help for all targets
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

ps: banner ## List ohmc containers
	@docker compose ps
.PHONY: ps

logs: ## Show ohmc containers logs [svc=<container> for 1 container]
	@docker compose logs -f $(svc)
.PHONY: logs

nuke-containers: ## Remove all containers
	@docker rm -f $(docker ps -aq)
.PHONY: nuke-containers

banner:
	@cat .assets/banner
.PHONY: banner