.DEFAULT_GOAL := help

REPO_ROOT = $(shell git rev-parse --show-toplevel)
MAKEFILE_DIR = $(shell cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

.Phony: bootstrap
bootstrap: # Bootstrap the environment.
	@scripts/bootstrap.sh

.Phony: format
format: # Format the code.
	@bin/swiftformat .
	@bin/swiftlint --autocorrect --config "$(REPO_ROOT)/.swiftlint.autocorrect.yml" --cache-path "$(REPO_ROOT)/.temp/swiftlint-cache"

.Phony: lint
lint: # Lint the code.
	@bin/swiftlint lint --cache-path "$(REPO_ROOT)/.temp/swiftlint-cache"

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?# "}; /^[a-zA-Z_-]+:.*?# .*$$/ && $$1 != "help" {system("tput bold; tput setaf 6"); printf "%-20s", $$1; system("tput sgr0"); print $$2}' $(MAKEFILE_LIST)
