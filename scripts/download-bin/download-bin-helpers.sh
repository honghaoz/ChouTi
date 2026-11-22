#!/bin/bash

# Download file with a shorter progress bar.
#
# Arguments:
#   $1 - URL to download
#   $2 - Output path
#   $3 - Desired width of the progress bar (default: 80)
#
# Example:
#   download_with_progress "https://example.com/file.zip" "file.zip"
#   download_with_progress "https://example.com/file.zip" "file.zip" 120
download_with_progress() {
  local url=$1
  local output_path=$2
  local desired_width=$3
  local is_desired_width_set=0
  if [ -n "$desired_width" ]; then
    is_desired_width_set=1
  fi

  # --retry covers timeouts and HTTP 408/429/5xx. --retry-all-errors is required
  # for a dropped connection (curl 56), and with -f it also retries 4xx.
  # --connect-timeout bounds a hung connect. --speed-limit 1024 and
  # --speed-time 30 abort a transfer slower than 1024 bytes/s for 30 seconds,
  # so a stall is retryable without capping a slow but progressing download.
  #
  # --retry-max-time only limits when a new retry may start.
  #
  # keep this array in sync with the same flags in scripts/bootstrap.sh
  local CURL_RETRY=(
    -fsSL
    --retry 5
    --retry-all-errors
    --retry-delay 2
    --retry-max-time 90
    --connect-timeout 10
    --speed-limit 1024
    --speed-time 30
  )

  # write to a temp file next to the destination so a failed or truncated
  # response can't replace a previously downloaded file
  #
  # this helper is sourced, so don't install an EXIT trap that would
  # replace the caller's
  local tmp
  tmp=$(mktemp "$output_path.XXXXXX") || return 1

  # --no-silent undoes -s from CURL_RETRY so --progress-bar still draws
  # and errors still print
  #
  # COLUMNS is honored by curl's progress bar, so the bar can be narrowed
  # without changing the terminal via stty
  #
  # || curl_status=$? keeps going under set -e so the temp file can be removed
  local curl_status=0
  local final_width=""
  if [ -t 1 ]; then
    terminal_width=$(tput cols) # get the terminal width
    final_width=$terminal_width

    # if desired width is set
    if [ "$is_desired_width_set" -eq 1 ]; then
      # desired width is smaller than terminal width, use it
      if [ "$desired_width" -lt "$terminal_width" ]; then
        final_width=$desired_width
      else
        final_width=$terminal_width
      fi
    else
      # desired width is not set, use terminal width, capped at 80
      if [ "$terminal_width" -lt 80 ]; then
        final_width=$terminal_width
      else
        final_width=80
      fi
    fi
  fi

  if [ -n "$final_width" ]; then
    COLUMNS="$final_width" curl "${CURL_RETRY[@]}" --no-silent --progress-bar "$url" -o "$tmp" || curl_status=$?
  else
    curl "${CURL_RETRY[@]}" --no-silent --progress-bar "$url" -o "$tmp" || curl_status=$?
  fi

  if [ "$curl_status" -ne 0 ]; then
    rm -f "$tmp"
    return "$curl_status"
  fi
  mv "$tmp" "$output_path"
}

# get_human_readable_size
#
# Converts a size in kilobytes to a human-readable format in KB, MB, or GB.
#
# Arguments:
#   $1 - Size in kilobytes (KB)
#
# Output:
#   Human-readable size string
#
# Example:
#   readable_size=$(get_human_readable_size 10240)
#   echo $readable_size  # Output: 10MB
#
#   size_kb=$(du -k somefile | cut -f1)
#   readable_size=$(get_human_readable_size $size_kb)
#   echo "Size: $readable_size"
get_human_readable_size() {
  local size_kb=$1
  local size_mb
  local size_gb

  # Convert to MB if size is greater than or equal to 1024 KB
  if [ "$size_kb" -ge 1024 ]; then
    size_mb=$(echo "scale=2; $size_kb / 1024" | bc)

    # Convert to GB if size is greater than or equal to 1024 MB
    if [ "$(echo "$size_mb >= 1024" | bc)" -eq 1 ]; then
      size_gb=$(echo "scale=2; $size_mb / 1024" | bc)
      echo "${size_gb}GB"
    else
      echo "${size_mb}MB"
    fi
  else
    echo "${size_kb}KB"
  fi
}

process_bin() {
  local bin_name=$1

  # Remove special file attributes
  echo "Removing special file attributes..."
  xattr -cr "$bin_name"

  # Strip the binary
  BEFORE_SIZE=$(du -k "$bin_name" | cut -f1)
  echo "Stripping the binary..."
  strip "$bin_name"
  AFTER_SIZE=$(du -k "$bin_name" | cut -f1)
  echo "Before: $(get_human_readable_size "$BEFORE_SIZE"), After: $(get_human_readable_size "$AFTER_SIZE")"
}
