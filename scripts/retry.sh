#!/bin/bash

show_help() {
  echo "Usage: $0 [OPTIONS] COMMAND"
  echo
  echo "Retry a command multiple times until it succeeds."
  echo
  echo "Options:"
  echo "  --max-attempts N  Maximum number of attempts (default: 3)"
  echo "  --delay N         Delay in seconds between attempts (default: 3)"
  echo "  -h, --help        Display this help message and exit"
  echo
  echo "Example:"
  echo "  $0 --max-attempts 5 --delay 3 some_command arg1 arg2"
}

# Default values
max_attempts=3
delay=3

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --max-attempts)
      max_attempts="$2"
      shift # past argument
      shift # past value
      ;;
    --delay)
      delay="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      break # Exit the loop when we hit the command to execute
      ;;
  esac
done

# check if a command was provided
if [ $# -eq 0 ]; then
  echo "Error: No command specified."
  show_help
  exit 1
fi

# The command to execute is all remaining arguments
command_to_execute="$@"

# Retry logic
for ((i=1; i<=max_attempts; i++)); do
  # print retry message if it's not the first attempt
  if [ $i -gt 1 ]; then
    echo "Attempt $i of $max_attempts..."
  fi

  if $command_to_execute; then
    exit 0
  else
    echo "‼️  Attempt $i failed."
    if [ $i -eq $max_attempts ]; then
      echo "❌ All attempts failed."
      exit 1
    fi
    echo "🔁  Retrying in $delay seconds..."
    sleep $delay
  fi
done
