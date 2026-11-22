#!/bin/bash

set -e

# remember the directory where the script was invoked
ORIGINAL_DIR=$(pwd)

# change to the directory in which this script is located
CDPATH= pushd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# Function to display help information
print_help() {
  echo "OVERVIEW: Download XcodeGen CLI (macOS, arm64)."
  echo ""
  echo "Usage: $0 --version <version> --to-folder <folder> [--force]"
  echo ""
  echo "OPTIONS:"
  echo "  --force  Overwrite an existing install without prompting."
  echo ""
  echo "EXAMPLES:"
  echo "  $0 --version 2.40.1 --to-folder ~/Downloads"
  exit 1
}

# shellcheck disable=SC1091
source ./download-bin-helpers.sh

# Variables
version=""
download_folder=""
force=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --version)
    version="$2"
    shift
    ;;
  --to-folder)
    download_folder="$2"
    shift
    ;;
  --force)
    force=1
    ;;
  *) print_help ;;
  esac
  shift
done

# Check if version is provided
if [ -z "$version" ]; then
  print_help
fi

# Check if download folder is provided
if [ -z "$download_folder" ]; then
  print_help
fi

# resolve a relative destination against the invocation dir, then make it
# absolute before cd into the staging directory
if [[ "$download_folder" != /* ]]; then
  download_folder="$ORIGINAL_DIR/$download_folder"
fi
mkdir -p "$download_folder"
if ! download_folder="$(CDPATH= cd -- "$download_folder" >/dev/null 2>&1 && pwd)"; then
  echo "🛑 ERROR: $download_folder is not a valid directory."
  exit 1
fi

# Define download URL and staging directory
url="https://github.com/yonaskolb/XcodeGen/releases/download/$version/xcodegen.zip"
staging=$(mktemp -d "$download_folder/.tmp.XXXXXX") || exit 1
trap 'rm -rf -- "$staging"' EXIT

# Download the binary
set +e
echo "Downloading xcodegen ($version) to $staging"
download_with_progress "$url" "$staging/xcodegen.zip"

# exit if download failed
if [ $? -ne 0 ]; then
  echo "🛑 ERROR: Failed to download xcodegen ($version)"
  exit 1
fi
set -e

# Navigate to staging directory and unzip
CDPATH= cd -- "$staging" >/dev/null || { echo "Failed to navigate to $staging"; exit 1; }
echo "Unzipping..."
unzip -q xcodegen.zip

# cd into the binary directory
CDPATH= cd -- "xcodegen/bin" >/dev/null || { echo "Failed to navigate to xcodegen/bin"; exit 1; }

process_bin xcodegen

CDPATH= cd -- ".." >/dev/null

# remove install.sh and LICENSE
rm install.sh LICENSE

CDPATH= cd -- ".." >/dev/null

# prompt only for a direct interactive run
if [ -e "$download_folder/xcodegen" ]; then
  if [ -z "${force:-}" ] && [ "${CI:-}" != "true" ] && [ -t 0 ]; then
    read -p "xcodegen already exists in $download_folder, do you want to replace it? [y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
  fi
fi

install_bin "$staging/xcodegen" "$download_folder" xcodegen

echo "XcodeGen ($version) saved to $download_folder/xcodegen"

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
