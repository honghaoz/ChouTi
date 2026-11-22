#!/bin/bash

set -e

# change to the directory in which this script is located
CDPATH= pushd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# Function to display help information
print_help() {
  echo "OVERVIEW: Download XcodeGen CLI (macOS, arm64)."
  echo ""
  echo "Usage: $0 --version <version> --to-folder <folder>"
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

# Define download URL and temporary directory
url="https://github.com/yonaskolb/XcodeGen/releases/download/$version/xcodegen.zip"
temp_dir=$(mktemp -d)
pending_old=""
cleanup() {
  if [ -n "${pending_old:-}" ] && [ -e "$download_folder/xcodegen.old" ]; then
    # a failed or interrupted mv can leave a partial folder that would nest the backup
    rm -rf "$download_folder/xcodegen"
    if mv -f "$download_folder/xcodegen.old" "$download_folder/xcodegen"; then
      echo "Restored the previous xcodegen to $download_folder/xcodegen"
    else
      echo "Failed to restore the previous xcodegen. The backup is at $download_folder/xcodegen.old"
    fi
  fi
  rm -rf "$temp_dir"
}
trap cleanup EXIT

# Download the binary
set +e
echo "Downloading xcodegen ($version) to $temp_dir"
download_with_progress "$url" "$temp_dir/xcodegen.zip"

# exit if download failed
if [ $? -ne 0 ]; then
  echo "🛑 ERROR: Failed to download xcodegen ($version)"
  exit 1
fi
set -e

# Navigate to temporary directory and unzip
cd "$temp_dir" || (echo "Failed to navigate to $temp_dir" && exit 1)
echo "Unzipping..."
unzip -q xcodegen.zip

# cd into the binary directory
CDPATH= cd -- "xcodegen/bin" >/dev/null || (echo "Failed to navigate to xcodegen/bin" && exit 1)

process_bin xcodegen

CDPATH= cd -- ".." >/dev/null

# remove install.sh and LICENSE
rm install.sh LICENSE

CDPATH= cd -- ".." >/dev/null

# Ensure the download folder exists
mkdir -p "$download_folder"

# Move to the download folder
# overwrite without asking when stdin is not a terminal or when CI is true,
# since nobody can answer the prompt
if [ -e "$download_folder/xcodegen" ]; then
  if [ "${CI:-}" != "true" ] && [ -t 0 ]; then
    read -p "xcodegen already exists in $download_folder, do you want to replace it? [y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
  fi
fi

# rename any existing install aside so a failed mv can put it back
if [ -e "$download_folder/xcodegen" ]; then
  # a leftover backup would block the rename
  rm -rf "$download_folder/xcodegen.old"
  mv -f "$download_folder/xcodegen" "$download_folder/xcodegen.old"
  pending_old=1
  if mv -f xcodegen "$download_folder"; then
    pending_old=""
    rm -rf "$download_folder/xcodegen.old"
  else
    exit 1
  fi
else
  mv -f xcodegen "$download_folder"
fi

echo "XcodeGen ($version) saved to $download_folder/xcodegen"

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
