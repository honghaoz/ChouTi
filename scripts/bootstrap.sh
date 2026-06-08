#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# OVERVIEW:
# This script is used to bootstrap the development environment.

REPO_ROOT=$(git rev-parse --show-toplevel)

cd "$REPO_ROOT" || exit 1

echo "🚀 Bootstrap development environment..."
git submodule update --init --recursive --remote

OS=$(uname -s)
case "$OS" in
'Darwin') # macOS
  CPU=$(uname -m)
  case "$CPU" in
  'arm64') # on Apple Silicon Mac
    # download bins
    echo ""
    echo "📦 Download bins..."
    "$REPO_ROOT/scripts/download-bin/download-bins.sh"

    # git hooks
    echo ""
    echo "🪝 Install git hooks..."
    "$REPO_ROOT/scripts/git/install-git-hooks.sh"

    # update packages if needed
    echo ""
    if [ "${CI:-}" = "true" ]; then
      echo "Skipping package update in CI"
    else
      echo "🔄 Update packages..."
      "$REPO_ROOT/scripts/swift-package/update-packages.sh" "$REPO_ROOT/playgrounds/ChouTiPlayground-iOS/ChouTiPlayground-iOS.xcodeproj"
      "$REPO_ROOT/scripts/swift-package/update-packages.sh" "$REPO_ROOT/playgrounds/ChouTiPlayground-macOS/ChouTiPlayground-macOS.xcodeproj"
      "$REPO_ROOT/scripts/swift-package/update-packages.sh" "$REPO_ROOT/playgrounds/ChouTiPlayground-tvOS/ChouTiPlayground-tvOS.xcodeproj"
      "$REPO_ROOT/scripts/swift-package/update-packages.sh" "$REPO_ROOT/playgrounds/ChouTiPlayground-watchOS/ChouTiPlayground-watchOS.xcodeproj"
      "$REPO_ROOT/scripts/swift-package/update-packages.sh" "$REPO_ROOT/playgrounds/ChouTiPlayground-visionOS/ChouTiPlayground-visionOS.xcodeproj"
    fi

    echo ""
    echo "🎉 Done."
    ;;
  'x86_64') # on Intel Mac
    echo "Does not support Intel Mac."
    ;;
  *)
    echo "Unknown CPU: $CPU"
    ;;
  esac
  ;;
'Linux') # on Ubuntu
  echo "Does not support Linux."
  ;;
*)
  echo "Unknown OS: $OS"
  ;;
esac

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
