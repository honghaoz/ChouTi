#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# shellcheck disable=SC1091
source ./colors.sh

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

REPO_ROOT=$(git rev-parse --show-toplevel)

if [[ "$LINT_ALL" == "true" ]]; then
  ERROR_CODE=0

  # swiftformat
  echo ""
  echo "➡️  Executing swiftformat..."
  start_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track start time

  set -o pipefail && "$REPO_ROOT/bin/swiftformat" --lint --baseconfig "$REPO_ROOT/configs/.swiftformat" --cache "$REPO_ROOT/.temp/swiftformat-cache" "$REPO_ROOT" 2>&1 | "$REPO_ROOT/scripts/swiftformat-beautify" || ERROR_CODE=$?

  end_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track end time
  time_diff=$(echo "$end_time - $start_time" | bc) # calculate time difference
  formatted_time_diff=$(printf "%.3f" "$time_diff") # format time difference to 3 decimal places
  printf "⏱️  swiftformat took $GREEN%s$NORMAL seconds.\n" "$formatted_time_diff"

  # swiftlint

  # copy $REPO_ROOT/configs/swiftlint.yml to $REPO_ROOT/.swiftlint.yml
  # so that .swiftlint.yml in child directories can be nested
  cp "$REPO_ROOT/configs/.swiftlint.yml" "$REPO_ROOT/.swiftlint.yml"

  cleanup() {
    # remove $REPO_ROOT/.swiftlint.yml
    if [ -f "$REPO_ROOT/.swiftlint.yml" ]; then
      rm "$REPO_ROOT/.swiftlint.yml"
    fi
  }
  trap cleanup EXIT

  # run swiftlint
  cd "$REPO_ROOT" || exit 1

  echo ""
  echo "➡️  Executing swiftlint..."
  start_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track start time

  # command "$REPO_ROOT/bin/swiftlint" lint --cache-path "$REPO_ROOT/.temp/swiftlint-cache" "$REPO_ROOT" 2>&1 | "$REPO_ROOT/scripts/swiftlint-beautify"
  lint_output=$("$REPO_ROOT/bin/swiftlint" lint --cache-path "$REPO_ROOT/.temp/swiftlint-cache" "$REPO_ROOT" 2>&1)
  echo "$lint_output" | "$REPO_ROOT/scripts/swiftlint-beautify"

  # if lint_output find non zero violations, set ERROR_CODE to 1
  # Example of violation line: "Done linting! Found 8 violations, 0 serious in 120 files."
  # Example of non violation line: "Done linting! Found 0 violations, 0 serious in 120 files."
  if echo "$lint_output" | grep -q "Found [1-9][0-9]* violations"; then
    ERROR_CODE=1
  fi

  end_time="$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')" # track end time
  time_diff=$(echo "$end_time - $start_time" | bc) # calculate time difference
  formatted_time_diff=$(printf "%.3f" "$time_diff") # format time difference to 3 decimal places
  printf "⏱️  swiftlint took $GREEN%s$NORMAL seconds.\n" "$formatted_time_diff"

  cleanup

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
