#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# define colors
safe_tput() { [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
BOLD=$(safe_tput bold)
GREEN=$(safe_tput setaf 2)
RESET=$(safe_tput sgr0)

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

# ===------ Measure time taken [START] ------===
start_time=""
end_time=""
formatted_time_diff=""
function measure_start() {
  start_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track start time
}
function measure_end() {
  tag="$1"
  end_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track end time
  time_diff=$(echo "$end_time - $start_time" | bc) # calculate time difference
  formatted_time_diff=$(printf "%.3f" "$time_diff") # format time difference to 3 decimal places
  printf "⏱️  $tag took $GREEN%s$RESET seconds.\n" "$formatted_time_diff"
}
# ===------ Measure time taken [END] ------===

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

SWIFTFORMAT_BIN="$REPO_ROOT/bin/swiftformat" && [[ ! -f "$SWIFTFORMAT_BIN" ]] && { echo "🛑 Error: swiftformat not found."; exit 1; }
SWIFTFORMAT_VERSION=$("$SWIFTFORMAT_BIN" --version)
SWIFTFORMAT_CONFIG="$REPO_ROOT/configs/.swiftformat" && [[ ! -f "$SWIFTFORMAT_CONFIG" ]] && { echo "🛑 Error: swiftformat config not found."; exit 1; }
SWIFTFORMAT_CACHE="$REPO_ROOT/.temp/swiftformat-cache" && mkdir -p "$REPO_ROOT/.temp"
SWIFTFORMAT_BEAUTIFY="$REPO_ROOT/scripts/swiftformat-beautify"

SWIFTLINT_BIN="$REPO_ROOT/bin/swiftlint" && [[ ! -f "$SWIFTLINT_BIN" ]] && { echo "🛑 Error: swiftlint not found."; exit 1; }
SWIFTLINT_VERSION=$("$SWIFTLINT_BIN" version)
SWIFTLINT_AUTOCORRECT_CONFIG="$REPO_ROOT/configs/.swiftlint.autocorrect.yml" && [[ ! -f "$SWIFTLINT_AUTOCORRECT_CONFIG" ]] && { echo "🛑 Error: swiftlint autocorrect config not found."; exit 1; }
SWIFTLINT_CACHE_DIR="$REPO_ROOT/.temp/swiftlint-cache" && mkdir -p "$SWIFTLINT_CACHE_DIR"
SWIFTLINT_BEAUTIFY="$REPO_ROOT/scripts/swiftlint-beautify"

if [[ "$FORMAT_ALL" == "true" ]]; then
  # swiftformat
  echo ""
  echo "➡️  Executing swiftformat ($SWIFTFORMAT_VERSION)..."

  measure_start
  command "$SWIFTFORMAT_BIN" --baseconfig "$SWIFTFORMAT_CONFIG" --cache "$SWIFTFORMAT_CACHE" "$REPO_ROOT" 2>&1 | "$SWIFTFORMAT_BEAUTIFY"
  measure_end "swiftformat"

  # swiftlint
  echo ""
  echo "➡️  Executing swiftlint ($SWIFTLINT_VERSION)..."

  measure_start
  command "$SWIFTLINT_BIN" --autocorrect --config "$SWIFTLINT_AUTOCORRECT_CONFIG" --cache-path "$SWIFTLINT_CACHE_DIR" "$REPO_ROOT" 2>&1 | "$SWIFTLINT_BEAUTIFY"
  measure_end "swiftlint"
else
  echo "TODO: Format staged files"
fi
