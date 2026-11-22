#!/bin/bash

set -e

# remember the directory where the script was invoked
ORIGINAL_DIR=$(pwd)

# change to the directory in which this script is located
CDPATH= pushd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

print_help() {
  echo "OVERVIEW: Download xcbeautify CLI (macOS, arm64)."
  echo ""
  echo "Usage: $0 --version <version> --to-folder <folder>"
  echo ""
  echo "EXAMPLES:"
  echo "  $0 --version 2.3.1 --to-folder ~/Downloads"
  exit 1
}

# shellcheck disable=SC1091
source ./download-bin-helpers.sh

# Variables
version=""
download_folder=""

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
url="https://github.com/cpisciotta/xcbeautify/releases/download/$version/xcbeautify-$version-arm64-apple-macosx.zip"
staging=$(mktemp -d "$download_folder/.tmp.XXXXXX") || exit 1
trap 'rm -rf -- "$staging"' EXIT

# Download the binary
set +e
echo "Downloading xcbeautify ($version) to $staging"
download_with_progress "$url" "$staging/xcbeautify.zip"

# exit if download failed
if [ $? -ne 0 ]; then
  echo "🛑 ERROR: Failed to download xcbeautify ($version)"
  exit 1
fi
set -e

# Navigate to staging directory and unzip
CDPATH= cd -- "$staging" >/dev/null || { echo "Failed to navigate to $staging"; exit 1; }
echo "Unzipping..."
unzip -q xcbeautify.zip

process_bin xcbeautify

# overwrite without asking when stdin is not a terminal or when CI is true,
# since nobody can answer the prompt
if [ -e "$download_folder/xcbeautify" ]; then
  if [ "${CI:-}" != "true" ] && [ -t 0 ]; then
    read -p "xcbeautify already exists in $download_folder, do you want to replace it? [y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
  fi
fi

install_bin "$staging/xcbeautify" "$download_folder" xcbeautify

echo "xcbeautify ($version) saved to $download_folder/xcbeautify"

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
