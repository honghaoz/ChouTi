#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# OVERVIEW:
# This script is used to bootstrap the development environment.

REPO_DIR=$(git rev-parse --show-toplevel)

cd "$REPO_DIR" || exit 1

echo "🚀 Bootstrap the development environment..."
git submodule update --init --recursive

# updated on 2022-08-21:
# - deprecates git lfs for large files
# - replace git lfs with artifact command

# # Git LFS
# if ! command-exists "git-lfs" ; then
#   echo "➡️  Install Git LFS"
#   brew install git-lfs
# fi
#
# git lfs install
# git lfs pull

OS=$(uname -s)
case "$OS" in
'Darwin') # macOS
  CPU=$(uname -m)
  case "$CPU" in
  'arm64') # on Apple Silicon Mac
    # download bins
    "$REPO_DIR/scripts/download-bin/download-bins.sh"
    ;;
  'x86_64') # on Intel Mac
    echo "Does not support Intel Mac yet."
    ;;
  *)
    echo "Unknown CPU: $CPU"
    ;;
  esac
  ;;
'Linux') # on Ubuntu
  ;;
*)
  echo "Unknown OS: $OS"
  ;;
esac

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
