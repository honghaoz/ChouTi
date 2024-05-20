#!/bin/bash

print_help() {
  echo "OVERVIEW: Filter LCOV file to keep only the specified source file."
  echo ""
  echo "WARNING: This script modifies the input LCOV file."
  echo ""
  echo "Usage: $0 input_lcov_file --keep-pattern 'regex_pattern'"
  echo ""
  echo "EXAMPLES:"
  echo "  $0 coverage.lcov --keep-pattern '.+packages/ChouTi/Sources/.+'"
  exit 1
}

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
  print_help
fi

# Input LCOV file
input_file="$1"
shift

keep_pattern=""

# Argument parsing
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --keep-pattern)
      keep_pattern="$2"
      shift
      ;;
    *)
      print_help
      ;;
  esac
  shift
done

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
