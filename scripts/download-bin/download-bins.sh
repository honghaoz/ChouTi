#!/bin/bash

set -e

# remember the directory where the script was invoked
ORIGINAL_DIR=$(pwd)

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# OVERVIEW: Download bins to /bin, based on .versions.

# define colors
safe_tput() { [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
CYAN=$(safe_tput setaf 6)
RESET=$(safe_tput sgr0)

# define variables
CURRENT_DIR=$(pwd)
REPO_ROOT=$(git rev-parse --show-toplevel)
BIN_DIR="$REPO_ROOT/bin"

print_help() {
  echo "OVERVIEW: Download binaries from .versions file."
  echo ""
  echo "Usage: $(basename "$0") [options]"
  echo ""
  echo "OPTIONS:"
  echo "  --bin-dir <path>  The path to the folder where binaries will be downloaded to."
  echo "                    The folder must contain a .versions file that lists the binaries to download."
  echo "                    Defaults to $BIN_DIR"
  echo ""
  echo "EXAMPLES:"
  echo "  $(basename "$0")"
  echo "  $(basename "$0") --bin-dir ~/bin"
  exit 1
}

# parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --bin-dir)
    BIN_DIR="$2"
    shift
    ;;
  *) print_help ;;
  esac
  shift
done

# check if bin-folder is provided
if [ -z "$BIN_DIR" ]; then
  print_help
fi

# make BIN_DIR absolute (resolve relative to invocation dir)
if [[ "$BIN_DIR" != /* ]]; then
  BIN_DIR="$ORIGINAL_DIR/$BIN_DIR"
fi
if ! BIN_DIR="$(cd "$BIN_DIR" 2>/dev/null && pwd)"; then
  echo "🔴 ERROR: $BIN_DIR is not a valid directory."
  exit 1
fi

VERSIONS_FILE="$BIN_DIR/.versions"

# make sure the versions file exists
if [ ! -f "$VERSIONS_FILE" ]; then
  echo "🔴 ERROR: $VERSIONS_FILE not found."
  exit 1
fi

echo ".versions: $VERSIONS_FILE"

# function to download and install binaries
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
      echo "✅ ${CYAN}$name ($version)${RESET} is already installed."
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

  echo "Downloading ${CYAN}$name ($version)${RESET}..."
  "$CURRENT_DIR/download-$name.sh" --version "$version" --to-folder "$BIN_DIR"

  # make sure the binary is executable
  if [ -f "$BIN_DIR/$name" ] && [ ! -x "$BIN_DIR/$name" ]; then
    chmod +x "$BIN_DIR/$name"
  fi

  # remove old binary backup
  if [ -e "$BIN_DIR/$name.backup" ]; then
    rm -rf "$BIN_DIR/$name.backup"
  fi

  echo "✅ ${CYAN}$name ($version)${RESET} is installed."
}

cleanup() {
  # if backup exists, restore the binary
  if [ -e "$BIN_DIR/$name.backup" ]; then
    mv "$BIN_DIR/$name.backup" "$BIN_DIR/$name"
  fi
}
trap cleanup EXIT

# read the versions file and download binaries
while read -r line || [[ -n "$line" ]]; do
  # skip empty lines
  [[ -z "$line" ]] && continue

  # split line into name and version
  read -r name version <<< "$line"

  # skip if either name or version is missing
  [[ -z "$name" || -z "$version" ]] && continue

  download_and_install "$name" "$version"
done <"$VERSIONS_FILE"

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
