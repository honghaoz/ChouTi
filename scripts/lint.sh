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

print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Lint Swift source files."
  echo ""
  echo "${BOLD}USAGE:${RESET}"
  echo "  $0 [--all]"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --all: Lint all Swift files in the current directory recursively."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo ""
  echo "  - Lint staged files:"
  echo "    ${GREEN}$0${RESET}"
  echo ""
  echo "  - Lint all Swift files:"
  echo "    ${GREEN}$0${RESET}"
  echo ""
}

LINT_ALL=false
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  --help | -h)
    print_help
    exit 0
    ;;
  --all)
    echo "➡️  Linting all files..."
    LINT_ALL=true
    shift
    ;;
  # no arguments
  "")
    echo "➡️  Linting staged files..."
    LINT_ALL=false
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
SWIFTLINT_CONFIG_NAME=".swiftlint.yml"
SWIFTLINT_CONFIG="$REPO_ROOT/configs/$SWIFTLINT_CONFIG_NAME" && [[ ! -f "$SWIFTLINT_CONFIG" ]] && { echo "🛑 Error: swiftlint config not found."; exit 1; }
SWIFTLINT_REPO_ROOT_CONFIG="$REPO_ROOT/$SWIFTLINT_CONFIG_NAME"
SWIFTLINT_CACHE_DIR="$REPO_ROOT/.temp/swiftlint-cache" && mkdir -p "$SWIFTLINT_CACHE_DIR"
SWIFTLINT_BEAUTIFY="$REPO_ROOT/scripts/swiftlint-beautify"

ERROR_CODE=0

if [[ "$LINT_ALL" == "true" ]]; then
  # swiftformat
  echo ""
  echo "➡️  Executing swiftformat ($SWIFTFORMAT_VERSION)..."

  measure_start
  set -o pipefail && "$SWIFTFORMAT_BIN" --lint --baseconfig "$SWIFTFORMAT_CONFIG" --cache "$SWIFTFORMAT_CACHE" "$REPO_ROOT" 2>&1 | "$SWIFTFORMAT_BEAUTIFY" || ERROR_CODE=$?
  measure_end "swiftformat"

  # swiftlint

  # copy $REPO_ROOT/configs/swiftlint.yml to $REPO_ROOT/.swiftlint.yml
  # so that .swiftlint.yml in child directories can be nested
  cp "$SWIFTLINT_CONFIG" "$SWIFTLINT_REPO_ROOT_CONFIG"

  cleanup() {
    # remove $REPO_ROOT/.swiftlint.yml
    if [ -f "$SWIFTLINT_REPO_ROOT_CONFIG" ]; then
      rm "$SWIFTLINT_REPO_ROOT_CONFIG"
    fi
  }
  trap cleanup EXIT

  # run swiftlint
  echo ""
  echo "➡️  Executing swiftlint ($SWIFTLINT_VERSION)..."

  measure_start
  lint_output=$("$SWIFTLINT_BIN" lint --cache-path "$SWIFTLINT_CACHE_DIR" "$REPO_ROOT" 2>&1)
  echo "$lint_output" | "$SWIFTLINT_BEAUTIFY"
  measure_end "swiftlint"

  # check last line of lint_output for violations info
  #
  # Examples of no violation line:
  # - "Done linting! Found 0 violations, 0 serious in 120 files."
  # Examples of violation line:
  # - "Done linting! Found 1 violation, 0 serious in 120 files."
  # - "Done linting! Found 8 violations, 0 serious in 120 files."
  if echo "$lint_output" | tail -n 1 | grep -q -E "Found [1-9][0-9]* violation"; then
    ERROR_CODE=1
  fi

  cleanup

  echo ""
  if [ "$ERROR_CODE" -ne 0 ]; then
    echo "🛑 Found code style issues."
    exit 1
  else
    echo "✅ No code style issues found."
  fi
else
  echo "TODO: Lint staged files"
fi

# ===------ END ------===
