#!/bin/bash

set -e

# define colors
safe_tput() { [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
BOLD=$(safe_tput bold)
GREEN=$(safe_tput setaf 2)
YELLOW=$(safe_tput setaf 3)
RESET=$(safe_tput sgr0)

print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Filter LCOV file to keep only the specified source file."
  echo ""
  echo "${BOLD}Usage:${RESET} $0 input_lcov_file --keep-pattern 'regex_pattern'"
  echo ""
  echo "${YELLOW}WARNING:${RESET} This script modifies the passed in input LCOV file."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  ${GREEN}$0 coverage.lcov --keep-pattern '.+packages/ChouTi/Sources/.+'${RESET}"
}

input_file=""
keep_pattern=""

# Argument parsing
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --help | -h)
      print_help
      exit 0
      ;;
    --keep-pattern)
      if [ -z "$2" ]; then
        echo "🛑 Error: --keep-pattern requires an argument"
        echo ""
        print_help
        exit 1
      fi
      keep_pattern="$2"
      shift # past option
      shift # past value
      ;;
    *)
      if [ -z "$input_file" ]; then
        input_file="$1"
        shift
      elif [[ $1 == -* ]]; then # if prefixed "-"
        echo "🛑 Error: Unrecognized option '$1'"
        echo ""
        print_help
        exit 1
      else
        echo "🛑 Error: Unrecognized argument '$1'"
        echo ""
        print_help
        exit 1
      fi
      ;;
  esac
done

# Check if input file exists
if [ ! -f "$input_file" ]; then
  echo "🛑 Error: Input file '$input_file' not found"
  echo ""
  print_help
  exit 1
fi

# Check if keep pattern is provided
if [ -z "$keep_pattern" ]; then
  print_help
fi

# Temporary file to store the filtered result
temp_file=$(mktemp)

# Flag to indicate whether to print the current block
print_block=false

# Read the input file line by line
while IFS= read -r line; do
  # Check for the SF: (source file) line
  if [[ $line =~ ^SF: ]]; then
    # If the source file matches the keep pattern, start printing the block
    if [[ $line =~ $keep_pattern ]]; then
      print_block=true
    else
      print_block=false
    fi
  fi

  # If print_block is true, print the current line to the temporary file
  if $print_block; then
    echo "$line" >> "$temp_file"
  fi
done < "$input_file"

# Replace the original file with the filtered result
mv "$temp_file" "$input_file"
