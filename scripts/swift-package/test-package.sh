#!/bin/bash

set -euo pipefail

# define colors
safe_tput() { [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
BOLD=$(safe_tput bold)
CYAN=$(safe_tput setaf 6)
RESET=$(safe_tput sgr0)

print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Run Swift package test command with retries and optional CI summary output."
  echo ""
  echo "${BOLD}Usage:${RESET} $0 --package PACKAGE_PATH [OPTIONS] [SWIFT_TEST_OPTIONS]"
  echo
  echo "${BOLD}Options:${RESET}"
  echo "  --package PATH               Path to the Swift package. Required."
  echo "  --max-attempts N             Maximum number of attempts (default: 1)"
  echo "  --delay N                    Delay in seconds between attempts (default: 3)"
  echo "  --beautifier PATH            Optional command used to format each attempt's output"
  echo "  --summary PATH               Optional Markdown summary output file, if specified, the summary will be appended to the file"
  echo "  --help, -h                   Show this help message and exit"
  echo
  echo "All remaining arguments are passed to 'swift test'."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  $0 --package path/to/Package --max-attempts 3 --delay 3 --beautifier path/to/beautifier --summary path/to/summary.md"
}

package_path=""
max_attempts=1
delay=3
beautifier=""
summary_output=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "🛑 Missing value for --package"
        print_help
        exit 1
      fi
      package_path="$2"
      shift
      shift
      ;;
    --max-attempts)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "🛑 Missing value for --max-attempts"
        print_help
        exit 1
      fi
      max_attempts="$2"
      shift
      shift
      ;;
    --delay)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "🛑 Missing value for --delay"
        print_help
        exit 1
      fi
      delay="$2"
      shift
      shift
      ;;
    --beautifier)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "🛑 Missing value for --beautifier"
        print_help
        exit 1
      fi
      beautifier="$2"
      shift
      shift
      ;;
    --summary)
      if [ "$#" -lt 2 ]; then
        echo "🛑 Missing value for --summary"
        print_help
        exit 1
      fi
      summary_output="$2"
      shift
      shift
      ;;
    --)
      shift
      break
      ;;
    --help | -h)
      print_help
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "$package_path" ]; then
  echo "🛑 --package is required."
  print_help
  exit 1
fi

if [[ ! "$max_attempts" =~ ^[0-9]+$ ]] || [ "$max_attempts" -lt 1 ]; then
  echo "🛑 --max-attempts must be a positive integer."
  exit 1
fi

if [[ ! "$delay" =~ ^[0-9]+$ ]]; then
  echo "🛑 --delay must be a non-negative integer."
  exit 1
fi

if [ ! -d "$package_path" ]; then
  echo "🛑 Package path does not exist: $package_path"
  exit 1
fi

package_path=$(cd "$package_path" && pwd) || exit 1
package_name=$(basename "$package_path")

if [ ! -f "$package_path/Package.swift" ]; then
  echo "🛑 Package.swift not found at package path: $package_path"
  exit 1
fi

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/swift-package-test.XXXXXX") || exit 1
trap 'rm -rf "$tmp_dir"' EXIT

failures_tsv="$tmp_dir/failures.tsv"
final_failures="$tmp_dir/final-failures.txt"
: > "$failures_tsv"
: > "$final_failures"

parse_failed_tests() {
  local output_file="$1"

  sed -E -n \
    -e 's|.* error: -\[([^]]+) ([^]]+)\] :.*|\1/\2|p' \
    -e "s|.*Test Case '-\\[([^]]+) ([^]]+)\\]' failed.*|\\1/\\2|p" \
    "$output_file" | sort | uniq
}

run_test_attempt() {
  local output_file="$1"
  shift

  set +e
  if [ -n "$beautifier" ] && [ -x "$beautifier" ]; then
    (
      cd "$package_path" || exit 1
      echo "swift test $*"
      swift test "$@"
    ) 2>&1 | tee "$output_file" | "$beautifier"
    local pipeline_status=("${PIPESTATUS[@]}")
    set -e

    if [ "${pipeline_status[1]}" -ne 0 ]; then
      echo "⚠️  Failed to write attempt output log."
    fi
    if [ "${pipeline_status[2]}" -ne 0 ]; then
      echo "⚠️  Beautifier failed."
    fi

    return "${pipeline_status[0]}"
  fi

  if [ -n "$beautifier" ] && [ ! -x "$beautifier" ]; then
    echo "⚠️  Beautifier is not executable: $beautifier"
  fi

  (
    cd "$package_path" || exit 1
    echo "swift test $*"
    swift test "$@"
  ) 2>&1 | tee "$output_file"
  local pipeline_status=("${PIPESTATUS[@]}")
  set -e

  if [ "${pipeline_status[1]}" -ne 0 ]; then
    echo "⚠️  Failed to write attempt output log."
  fi

  return "${pipeline_status[0]}"
}

write_summary() {
  local completed_attempts="$1"
  local final_exit_code="$2"

  if [ ! -s "$failures_tsv" ] && [ "$final_exit_code" -eq 0 ]; then
    return
  fi

  local by_test="$tmp_dir/failures-by-test.tsv"
  local summary="$tmp_dir/github-summary.md"

  awk -F '\t' '
    $2 != "" {
      attempts[$2] = attempts[$2] == "" ? $1 : attempts[$2] ", " $1
    }
    END {
      for (test in attempts) {
        print test "\t" attempts[test]
      }
    }
  ' "$failures_tsv" | sort > "$by_test"

  {
    echo "## Test Summary: $package_name"
    echo
    if [ "$final_exit_code" -eq 0 ]; then
      echo "Result: passed after $completed_attempts attempt(s)."
    else
      echo "Result: failed after $completed_attempts attempt(s)."
    fi
    echo

    if [ -s "$by_test" ]; then
      echo "| Result | Test | Failed attempt(s) |"
      echo "| --- | --- | --- |"
      awk -F '\t' '
        FILENAME == ARGV[1] {
          final[$1] = 1
          next
        }
        {
          status = final[$1] ? "Failed after retries" : "Passed after retry"
          order = final[$1] ? 0 : 1
          print order "\t" status "\t" $1 "\t" $2
        }
      ' "$final_failures" "$by_test" | sort -t '	' -k1,1n -k3,3 | awk -F '\t' '
        {
          print "| " $2 " | `" $3 "` | " $4 " |"
        }
      '
    fi

    if [ "$final_exit_code" -ne 0 ] && [ ! -s "$final_failures" ]; then
      echo
      echo "> The command failed, but no XCTest failure lines were found. Check the raw log for build or runtime errors."
    fi
  } > "$summary"

  echo
  cat "$summary"

  if [ -n "$summary_output" ]; then
    {
      cat "$summary"
      echo
    } >> "$summary_output"
  fi
}

attempt=1
final_exit_code=1

while [ "$attempt" -le "$max_attempts" ]; do
  if [ "$attempt" -gt 1 ]; then
    echo "Attempt $attempt of $max_attempts..."
  fi

  output_file="$tmp_dir/attempt-$attempt.log"
  if run_test_attempt "$output_file" "$@"; then
    exit_code=0
  else
    exit_code=$?
  fi

  failed_tests_file="$tmp_dir/attempt-$attempt-failed-tests.txt"
  parse_failed_tests "$output_file" > "$failed_tests_file"

  while IFS= read -r test; do
    if [ -n "$test" ]; then
      printf "%s\t%s\n" "$attempt" "$test" >> "$failures_tsv"
    fi
  done < "$failed_tests_file"

  if [ "$exit_code" -eq 0 ]; then
    final_exit_code=0
    : > "$final_failures"
    break
  fi

  echo "‼️  Attempt $attempt failed."
  if [ "$attempt" -eq "$max_attempts" ]; then
    if [ "$max_attempts" -eq 1 ]; then
      echo "❌ Test command failed."
    else
      echo "❌ All attempts failed."
    fi
    final_exit_code="$exit_code"
    cp "$failed_tests_file" "$final_failures"
    break
  fi

  echo "🔁  Retrying in $delay seconds..."
  sleep "$delay"
  attempt=$((attempt + 1))
done

write_summary "$attempt" "$final_exit_code"

exit "$final_exit_code"
