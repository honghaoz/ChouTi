#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

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
trap 'rm -rf $temp_dir' EXIT

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
cd xcodegen/bin || (echo "Failed to navigate to xcodegen/bin" && exit 1)

process_bin xcodegen

cd ..

# remove install.sh and LICENSE
rm install.sh LICENSE

cd ..

# Ensure the download folder exists
mkdir -p "$download_folder"

# Move to the download folder
# if there is existing xcodegen in the download folder, either file or folder, ask for confirmation
if [ -e "$download_folder/xcodegen" ]; then
  read -p "xcodegen already exists in $download_folder, do you want to replace it? [y/n] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# move xcodegen folder to the download folder
mv xcodegen "$download_folder"

echo "XcodeGen ($version) saved to $download_folder/xcodegen"

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
