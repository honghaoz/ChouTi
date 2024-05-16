#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# OVERVIEW: Download bins to /bin, based on .versions.

CURRENT_DIR=$(pwd)
REPO_ROOT=$(git rev-parse --show-toplevel)
BIN_DIR="$REPO_ROOT/bin"
VERSIONS_FILE="$BIN_DIR/.versions"

# Make sure the versions file exists
if [ ! -f "$VERSIONS_FILE" ]; then
  echo "🔴 ERROR: $VERSIONS_FILE not found."
  exit 1
fi

# Make sure the binaries directory exists
mkdir -p "$BIN_DIR"

# Function to download and install binaries
download_and_install() {
  local name=$1
  local version=$2

  # skips download if the binary already exists with the same version
  if [ -e "$BIN_DIR/$name" ]; then
    bin_path="$BIN_DIR/$name"
    # special handling for xcodegen/bin/xcodegen
    if [ "$name" == "xcodegen" ]; then
      bin_path="$BIN_DIR/xcodegen/bin/xcodegen"
    fi

    installed_version=$("$bin_path" --version)

    # skips "Version: " prefix if exists
    installed_version=$(echo "$installed_version" | sed 's/Version: //g')

    if [ "$installed_version" == "$version" ]; then
      echo "✅ $name ($version) already installed."
      return
    fi
  fi

  # make sure the script exist
  if [ ! -f "$CURRENT_DIR/download-$name.sh" ]; then
    echo "🔴 ERROR: download script for $name not found."
    return
  fi

  # make sure the script is executable
  if [ ! -x "$CURRENT_DIR/download-$name.sh" ]; then
    chmod +x "$CURRENT_DIR/download-$name.sh"
  fi

  # backup old binary if exists
  if [ -e "$BIN_DIR/$name" ]; then
    mv "$BIN_DIR/$name" "$BIN_DIR/$name.backup"
  fi

  echo "Downloading $name version $version..."
  "$CURRENT_DIR/download-$name.sh" --version "$version" --to-folder "$BIN_DIR"

  # make sure the binary is executable
  if [ -f "$BIN_DIR/$name" ] && [ ! -x "$BIN_DIR/$name" ]; then
    chmod +x "$BIN_DIR/$name"
  fi

  # remove old binary backup
  if [ -e "$BIN_DIR/$name.backup" ]; then
    rm -rf "$BIN_DIR/$name.backup"
  fi

  echo "✅ $name version $version installed."
}

# Read the versions file and download binaries
while IFS=" " read -r name version; do
  # skips empty lines
  [ -z "$name" ] && continue
  [ -z "$version" ] && continue
  download_and_install "$name" "$version"
done <"$VERSIONS_FILE"

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
