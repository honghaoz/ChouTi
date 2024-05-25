#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# shellcheck disable=SC1091
source ./colors.sh

REPO_ROOT=$(git rev-parse --show-toplevel)

# copy $REPO_ROOT/configs/swiftlint.yml to $REPO_ROOT/.swiftlint.yml
# so that .swiftlint.yml in child directories can be nested
cp "$REPO_ROOT/configs/.swiftlint.yml" "$REPO_ROOT/.swiftlint.yml"

cleanup() {
  # remove $REPO_ROOT/.swiftlint.yml
  if [ -f "$REPO_ROOT/.swiftlint.yml" ]; then
    rm "$REPO_ROOT/.swiftlint.yml"
  fi
}
trap cleanup EXIT

# run swiftlint
cd "$REPO_ROOT" || exit 1
command "$REPO_ROOT/bin/swiftlint" lint --cache-path "$REPO_ROOT/.temp/swiftlint-cache" --progress "$REPO_ROOT"

cleanup

# ===------ END ------===
