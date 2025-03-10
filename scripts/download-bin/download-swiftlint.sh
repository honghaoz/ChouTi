#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

print_help() {
  echo "OVERVIEW: Download SwiftLint CLI (macOS, arm64)."
  echo ""
  echo "Usage: $0 --version <version> --to-folder <folder>"
  echo ""
  echo "EXAMPLES:"
  echo "  $0 --version 0.55.0 --to-folder ~/Downloads"
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

# Helper Function

# Test URL reachability.
#
# Example usage:
# URL="https://github.com/realm/SwiftLint/releases/download/0.58.0/SwiftLintBinary.artifactbundle.zip"
# test_url "$URL"
# if [ $? -eq 0 ]; then
#   echo "URL is valid"
# else
#   echo "URL is invalid"
# fi
test_url() {
  local URL="$1"
  local RESPONSE
  local STATUS
  local HTTP_CODE
  RESPONSE=$(curl --silent --head --fail "$URL")
  STATUS=$?
  HTTP_CODE=$(echo "$RESPONSE" | grep -E "^HTTP/[0-9.]+ [0-9]+" | awk '{print $2}')

  if [ $STATUS -ne 0 ]; then
    echo "--------------------------------"
    echo "🛑 Error: Invalid URL"
    echo "URL: $URL"
    echo "HTTP Status: $HTTP_CODE"
    echo -n "Response: $RESPONSE"
    echo "--------------------------------"
    return 1
  fi

  return 0
}

# Define download URL and temporary directory

# url before 0.58.0
URL_MACOS="https://github.com/realm/SwiftLint/releases/download/$version/SwiftLintBinary-macos.artifactbundle.zip"

# url since 0.58.0
# https://github.com/realm/SwiftLint/releases/tag/0.58.0
URL_GENERIC="https://github.com/realm/SwiftLint/releases/download/$version/SwiftLintBinary.artifactbundle.zip"

# Test URL reachability and select the working URL
echo "Testing SwiftLint download URLs..."
if test_url "$URL_GENERIC"; then
  URL="$URL_GENERIC"
elif test_url "$URL_MACOS"; then
  URL="$URL_MACOS"
else
  echo "🛑 ERROR: No valid SwiftLint download URL found."
  echo "Tried:"
  echo "  - $URL_GENERIC"
  echo "  - $URL_MACOS"
  exit 1
fi

temp_dir=$(mktemp -d)
trap 'rm -rf $temp_dir' EXIT

# Download the binary
set +e
echo "Downloading swiftlint ($version) to $temp_dir"
download_with_progress "$URL" "$temp_dir/swiftlint.zip"

# exit if download failed
if [ $? -ne 0 ]; then
  echo "🛑 ERROR: Failed to download swiftlint ($version)"
  echo "Download URL: $URL"
  exit 1
fi
set -e

# Navigate to temporary directory and unzip
cd "$temp_dir" || (echo "Failed to navigate to $temp_dir" && exit 1)
echo "Unzipping..."
unzip -q swiftlint.zip

# Move the binary to the current directory
mv SwiftLintBinary.artifactbundle/swiftlint-*/bin/swiftlint .

process_bin swiftlint

# Ensure the download folder exists
mkdir -p "$download_folder"

# Move to the download folder
# if there is existing swiftlint in the download folder, ask for confirmation
if [ -f "$download_folder/swiftlint" ]; then
  read -p "swiftlint already exists in $download_folder, do you want to replace it? [y/n] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# move swiftlint to the download folder
mv swiftlint "$download_folder"

echo "SwiftLint ($version) saved to $download_folder/swiftlint"

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
