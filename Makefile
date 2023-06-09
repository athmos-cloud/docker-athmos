
APP_REPO=git@github.com:athmos-cloud/app-athmos.git
APP_DIR=app
API_REPO=git@github.com:athmos-cloud/api-athmos.git
API_DIR=api
INFRA_WORKER_REPO=git@github.com:athmos-cloud/infra-worker-athmos.git
INFRA_WORKER_DIR=infra-worker
DOCKER_IMAGES_REPO=git@github.com:athmos-cloud/docker-images.git
DOCKER_IMAGES_DIR=docker-images

KIND_CONFIG=configs/kind/kind.yaml
KIND_CLUSTER_NAME=plugins
KUBE_CONFIG_DIR=configs/kube
KUBE_CONFIG_LOCATION=$(KUBE_CONFIG_DIR)/config
CROSSPLANE_CONFIG_DIR=configs/crossplane
.DEFAULT_GOAL := help

help: _banner ## Show help for all targets
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

all: cluster plugins-package up ## Clone the repositories and run athmos containers

rm: ## Remove athmos containers
ifndef $(svc)
	@docker-compose rm
else
	@docker rm -f $(svc)
	@docker rmi -f docker-athmos_$(svc)
endif
.PHONY: rm

rmw: ## Remove athmos containers in Windows
ifndef $(svc)
	@docker-compose -f docker-compose.win.yml rm
else
	@docker rm -f $(svc)
	@docker rmi -f docker-athmos_$(svc)
endif
.PHONY: rmw

up:  ## Run athmos containers
	@docker compose up -V -d --build
.PHONY: up

upw:  ## Run athmos containers in Windows
	@docker compose -f docker-compose.win.yml up -V -d --build
.PHONY: upw

ps: _banner ## List athmos containers
	@docker compose ps
.PHONY: ps

logs: ## Show athmos containers logs [svc=<container> for 1 container]
	@docker compose logs -f $(svc)
.PHONY: logs

nuke-containers: ## Remove all containers
	@docker rm -f $(docker ps -aq)
.PHONY: nuke-containers

_kind: _clear-kind ## Create a k3d cluster
	@mkdir -p $(KUBE_CONFIG_DIR)
	@kind create cluster --name $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG)
	@kind get kubeconfig --name $(KIND_CLUSTER_NAME) > /tmp/kubeconfig
	@cat /tmp/kubeconfig | sed "s/0.0.0.0/host.docker.internal/g" > $(KUBE_CONFIG_LOCATION)
	@rm -f /tmp/kubeconfig
	@export KUBECONFIG=$(KUBE_CONFIG_LOCATION)
	@#kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
.PHONY: _kind

_kind-test:
	@cat $(KUBE_CONFIG_LOCATION) | sed "s/0.0.0.0/host.docker.internal/g" > toto
.PHONY: _kind-test

_clear-kind:
	@kind delete cluster --name  $(KIND_CLUSTER_NAME)
.PHONY: _clear-kind

_crossplane-operator:
	@kubectl delete namespace --ignore-not-found=true crossplane-system
	@kubectl create namespace crossplane-system
	@helm repo add crossplane-stable https://charts.crossplane.io/stable &&\
   	helm repo update &&\
   	helm install crossplane --namespace crossplane-system crossplane-stable/crossplane
.PHONY: _crossplane-operator

_crossplane-configs:
	@kubectl apply -f $(CROSSPLANE_CONFIG_DIR)
.PHONY: _crossplane-configs

_crossplane: ## Install crossplane
	$(MAKE) _crossplane-operator
	@sleep 40
	$(MAKE) _crossplane-configs
.PHONY: _crossplane

cluster: _kind _crossplane ## Create a k3d cluster with crossplane installations

plugins-package: ## Create the plugin folder
	@cd $(PLUGIN_INFRA_HELM_DIR) && ./plugin.sh
.PHONY: plugins-package

_banner:
	@cat .assets/banner
.PHONY: _banner

_clone:
	@git clone $(repo) $(dir)
.PHONY: _clone

clone: ## Clone the repositories
	$(MAKE) _clone dir=$(APP_DIR) repo=$(APP_REPO)
	$(MAKE) _clone dir=$(API_DIR) repo=$(API_REPO)
	$(MAKE) _clone dir=$(INFRA_WORKER_DIR) repo=$(INFRA_WORKER_REPO)
	$(MAKE) _clone dir=$(DOCKER_IMAGES_DIR) repo=$(DOCKER_IMAGES_REPO)
.PHONY: clone