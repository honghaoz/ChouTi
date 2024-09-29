.DEFAULT_GOAL := help

REPO_ROOT = $(shell git rev-parse --show-toplevel)
MAKEFILE_DIR = $(shell cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

.PHONY: bootstrap
bootstrap: # Bootstrap the environment.
	@scripts/bootstrap.sh

.PHONY: build
build: # Build the package.
	@echo build: $(MAKEFILE_DIR_NAME)
	swift build -c release

.PHONY: build-playgrounds
build-playgrounds: # Build the playgrounds.
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-macOS/ChouTiPlayground-macOS.xcodeproj" --scheme "ChouTiPlayground-macOS" --configuration "Release" --os "macOS"
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-iOS/ChouTiPlayground-iOS.xcodeproj" --scheme "ChouTiPlayground-iOS" --configuration "Release" --os "iOS"
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-tvOS/ChouTiPlayground-tvOS.xcodeproj" --scheme "ChouTiPlayground-tvOS" --configuration "Release" --os "tvOS"
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-visionOS/ChouTiPlayground-visionOS.xcodeproj" --scheme "ChouTiPlayground-visionOS" --configuration "Release" --os "visionOS"
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-watchOS/ChouTiPlayground-watchOS.xcodeproj" --scheme "ChouTiPlayground-watchOS" --configuration "Release" --os "watchOS"

.PHONY: build-playground-macOS
build-playground-macOS: # Build the macOS playground.
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-macOS/ChouTiPlayground-macOS.xcodeproj" --scheme "ChouTiPlayground-macOS" --configuration "Release" --os "macOS"

.PHONY: build-playground-iOS
build-playground-iOS: # Build the iOS playground.
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-iOS/ChouTiPlayground-iOS.xcodeproj" --scheme "ChouTiPlayground-iOS" --configuration "Release" --os "iOS"

.PHONY: build-playground-tvOS
build-playground-tvOS: # Build the tvOS playground.
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-tvOS/ChouTiPlayground-tvOS.xcodeproj" --scheme "ChouTiPlayground-tvOS" --configuration "Release" --os "tvOS"

.PHONY: build-playground-visionOS
build-playground-visionOS: # Build the visionOS playground.
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-visionOS/ChouTiPlayground-visionOS.xcodeproj" --scheme "ChouTiPlayground-visionOS" --configuration "Release" --os "visionOS"

.PHONY: build-playground-watchOS
build-playground-watchOS: # Build the watchOS playground.
	@./scripts/xcodebuild/build-project.sh --project "./playgrounds/ChouTiPlayground-watchOS/ChouTiPlayground-watchOS.xcodeproj" --scheme "ChouTiPlayground-watchOS" --configuration "Release" --os "watchOS"

.PHONY: format
format: # Format the code.
	@"$(REPO_ROOT)/scripts/format.sh" --all

.PHONY: lint
lint: # Lint the code.
	@"$(REPO_ROOT)/scripts/lint.sh" --all

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?# "}; /^[a-zA-Z_-]+:.*?# .*$$/ && $$1 != "help" {system("tput bold; tput setaf 6"); printf "%-28s", $$1; system("tput sgr0"); print $$2}' $(MAKEFILE_LIST)
