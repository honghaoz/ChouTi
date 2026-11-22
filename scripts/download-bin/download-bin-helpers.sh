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


# install_bin
#
# Installs a staged file or directory into a destination folder. The staged
# path should already be on the same filesystem as the destination, so the
# final rename is atomic. An existing install is renamed aside and restored
# if the swap fails or is interrupted.
#
# This function temporarily replaces the EXIT trap. It runs any previous EXIT
# trap after its own cleanup, and puts the previous trap back before a
# normal return, so a caller's staging cleanup is not lost.
#
# Arguments:
#   $1 - Path to the staged file or directory
#   $2 - Destination folder
#   $3 - Name of the install in the destination folder
#
# Example:
#   install_bin "$staging/swiftformat" "$download_folder" swiftformat
_install_bin_pending=""
_install_bin_dest=""
_install_bin_backup=""
_install_bin_saved_trap=""

_install_bin_restore() {
  if [ -z "${_install_bin_pending:-}" ] || [ ! -e "$_install_bin_backup" ]; then
    return 0
  fi
  # a failed or interrupted mv can leave a partial dest that would nest the backup
  rm -rf "$_install_bin_dest"
  if mv -f "$_install_bin_backup" "$_install_bin_dest"; then
    echo "Restored the previous $_install_bin_pending to $_install_bin_dest"
    _install_bin_pending=""
  else
    echo "Failed to restore the previous $_install_bin_pending. The backup is at $_install_bin_backup"
  fi
}

_install_bin_run_saved_trap() {
  if [ -z "${_install_bin_saved_trap:-}" ]; then
    return 0
  fi
  # trap -p EXIT prints: trap -- 'command' EXIT
  eval "set -- $_install_bin_saved_trap"
  if [ -n "${3:-}" ]; then
    eval "$3"
  fi
}

_install_bin_on_exit() {
  _install_bin_restore
  _install_bin_run_saved_trap
}

_install_bin_release_trap() {
  if [ -n "${_install_bin_saved_trap:-}" ]; then
    eval "$_install_bin_saved_trap"
  else
    trap - EXIT
  fi
}

install_bin() {
  local staged_path=$1
  local dest_folder=$2
  local bin_name=$3

  if [ -z "$staged_path" ] || [ -z "$dest_folder" ] || [ -z "$bin_name" ]; then
    echo "🛑 ERROR: install_bin requires a staged path, destination folder, and name."
    return 1
  fi
  if [ ! -e "$staged_path" ]; then
    echo "🛑 ERROR: staged path not found: $staged_path"
    return 1
  fi
  if [ "$(basename "$staged_path")" != "$bin_name" ]; then
    echo "🛑 ERROR: staged path must be named $bin_name: $staged_path"
    return 1
  fi

  # initialize swap state inside this helper, do not reuse caller environment
  _install_bin_pending=""
  _install_bin_dest="$dest_folder/$bin_name"
  _install_bin_backup="$dest_folder/$bin_name.backup"
  _install_bin_saved_trap=$(trap -p EXIT || true)

  trap _install_bin_on_exit EXIT

  # a leftover backup would block the rename
  rm -rf "$_install_bin_backup"
  if [ -e "$_install_bin_dest" ]; then
    mv -f "$_install_bin_dest" "$_install_bin_backup"
    _install_bin_pending="$bin_name"
  fi

  if mv -f "$staged_path" "$dest_folder"; then
    # the new install is in place
    _install_bin_pending=""
    rm -rf "$_install_bin_backup"
    _install_bin_release_trap
    return 0
  fi

  _install_bin_restore
  _install_bin_release_trap
  return 1
}
