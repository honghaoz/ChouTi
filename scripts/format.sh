#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# shellcheck disable=SC1091
source ./colors.sh

function print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Format Swift source files."
  echo ""
  echo "${BOLD}USAGE:${RESET}"
  echo "  $0 [--all]"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --all: Format all Swift files in the current directory recursively."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo ""
  echo "  - Format staged files:"
  echo "    ${GREEN}$0${RESET}"
  echo ""
  echo "  - Format all files:"
  echo "    ${GREEN}$0 --all${RESET}"
  echo ""
}

FORMAT_ALL=false
case "$1" in
--help | -h)
  print_help
  exit 0
  ;;
--all)
  # Add the logic for --all option here
  echo "➡️  Formatting all files..."
  FORMAT_ALL=true
  ;;
# no arguments
"")
  # Add the logic for no arguments here
  echo "➡️  Formatting staged files..."
  FORMAT_ALL=false
  ;;
*)
  # If an unrecognized option is provided, print help
  echo "🛑 Error: Unrecognized option '$1'"
  echo ""
  print_help
  exit 1
  ;;
esac

REPO_ROOT=$(git rev-parse --show-toplevel)

if [[ "$FORMAT_ALL" == "true" ]]; then
  echo ""
  echo "➡️  Executing swiftformat..."
  command "$REPO_ROOT/bin/swiftformat" --baseconfig "$REPO_ROOT/configs/.swiftformat" "$REPO_ROOT"

  echo ""
  echo "➡️  Executing swiftlint..."
  command "$REPO_ROOT/bin/swiftlint" --autocorrect --config "$REPO_ROOT/configs/.swiftlint.autocorrect.yml" --cache-path "$REPO_ROOT/.temp/swiftlint-cache" --progress "$REPO_ROOT"
else
  echo "TODO: ..."
fi
