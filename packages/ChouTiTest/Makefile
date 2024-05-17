.DEFAULT_GOAL := help

REPO_ROOT = $(shell git rev-parse --show-toplevel)
MAKEFILE_DIR = $(shell cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MAKEFILE_DIR_NAME = $(shell basename $(MAKEFILE_DIR))

.Phony: build
build: # Build with debug configuration.
	@echo build: $(MAKEFILE_DIR_NAME)
	swift build -c debug

.Phony: build-release
build-release: # Build with release configuration.
	@echo build release: $(MAKEFILE_DIR_NAME)
	swift build -c release

.Phony: test
test: # Run tests.
	@echo test: $(MAKEFILE_DIR_NAME)
	swift test | $(REPO_ROOT)/bin/xcbeautify

.Phony: clean
clean: # Clean build data.
	@echo clean: $(MAKEFILE_DIR_NAME)
	swift package clean

.Phony: help
help:
	@awk 'BEGIN {FS = ":.*?# "}; /^[a-zA-Z_-]+:.*?# .*$$/ && $$1 != "help" {system("tput bold; tput setaf 6"); printf "%-20s", $$1; system("tput sgr0"); print $$2}' $(MAKEFILE_LIST)
