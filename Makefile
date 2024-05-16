.DEFAULT_GOAL := help

REPO_DIR = $(shell git rev-parse --show-toplevel)
MAKEFILE_DIR = $(shell cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

.Phony: bootstrap
bootstrap: ## Bootstrap the environment.
	@scripts/bootstrap.sh

.Phony: help
help: ## Shows this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
