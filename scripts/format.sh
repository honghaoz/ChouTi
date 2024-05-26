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
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  --help | -h)
    print_help
    exit 0
    ;;
  --all)
    echo "➡️  Formatting all files..."
    FORMAT_ALL=true
    shift
    ;;
  # no arguments
  "")
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
done

REPO_ROOT=$(git rev-parse --show-toplevel)

if [[ "$FORMAT_ALL" == "true" ]]; then
  # swiftformat
  echo ""
  echo "➡️  Executing swiftformat..."
  start_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track start time

  command "$REPO_ROOT/bin/swiftformat" --baseconfig "$REPO_ROOT/configs/.swiftformat" "$REPO_ROOT"

  end_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track end time
  time_diff=$(echo "$end_time - $start_time" | bc) # calculate time difference
  formatted_time_diff=$(printf "%.3f" "$time_diff") # format time difference to 3 decimal places
  printf "✅ swiftformat took $GREEN%s$NORMAL seconds.\n" "$formatted_time_diff"

  # swiftlint
  echo ""
  echo "➡️  Executing swiftlint..."
  start_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track start time

  command "$REPO_ROOT/bin/swiftlint" --autocorrect --config "$REPO_ROOT/configs/.swiftlint.autocorrect.yml" --cache-path "$REPO_ROOT/.temp/swiftlint-cache" "$REPO_ROOT" 2>&1 | "$REPO_ROOT/scripts/swiftlint-beautify"

  end_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track end time
  time_diff=$(echo "$end_time - $start_time" | bc) # calculate time difference
  formatted_time_diff=$(printf "%.3f" "$time_diff") # format time difference to 3 decimal places
  printf "✅ swiftlint took $GREEN%s$NORMAL seconds.\n" "$formatted_time_diff"
else
  echo "TODO: Format staged files"
fi
