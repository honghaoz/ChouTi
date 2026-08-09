#!/bin/bash

set -euo pipefail

# define colors
safe_tput() { [ -n "${TERM:-}" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
BOLD=$(safe_tput bold)
CYAN=$(safe_tput setaf 6)
RESET=$(safe_tput sgr0)

# OVERVIEW:
# Build a Swift package on one or more platforms with xcodebuild.

print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Build a Swift package with xcodebuild, no workspace needed."
  echo ""
  echo "${BOLD}Usage:${RESET} $0 --package <package_path> [--scheme <scheme_name>] [--configuration <configuration>] [--os <macOS iOS tvOS visionOS watchOS>]"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --package <package_path>                The path to the Swift package directory. Required."
  echo "  --scheme <scheme_name>                  The scheme to build. Optional. Default is the package name from Package.swift."
  echo "  --configuration <configuration>         The build configuration. Optional. Default is Debug."
  echo "  --os <iOS macOS tvOS visionOS watchOS>  The list of OS to build for. Optional. Default is 'macOS iOS tvOS visionOS watchOS'."
  echo "  --beautify [true|false]                 Use xcbeautify to beautify the output. Optional. Default is true."
  echo "  --derived-data-path <path>              Use a fixed DerivedData path. Optional. Default is Xcode's DerivedData."
  echo "  --help, -h                              Show this help message."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  $0 --package path/to/Package --configuration Release --os macOS iOS tvOS visionOS watchOS"
}

# MARK: - Arguments

PACKAGE_PATH=""
SCHEME=""
CONFIGURATION="Debug"
OS=""
BEAUTIFY=true
DERIVED_DATA_PATH=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --package)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --package" >&2
      exit 1
    fi
    PACKAGE_PATH="$2"
    shift # past option
    shift # past value
    ;;
  --scheme)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --scheme" >&2
      exit 1
    fi
    SCHEME="$2"
    shift # past option
    shift # past value
    ;;
  --configuration)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --configuration" >&2
      exit 1
    fi
    CONFIGURATION="$2"
    shift # past option
    shift # past value
    ;;
  --os)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --os" >&2
      exit 1
    fi
    # consume a list of arguments
    OS="$2"
    shift # past option
    shift # past value
    # consume all remaining arguments
    while [[ "$#" -gt 0 ]] && [[ "$1" != "--"* ]]; do
      # arguments should be in [macOS iOS tvOS visionOS watchOS]
      if [[ "$1" != "macOS" ]] && [[ "$1" != "iOS" ]] && [[ "$1" != "tvOS" ]] && [[ "$1" != "visionOS" ]] && [[ "$1" != "watchOS" ]]; then
        echo "🛑 Invalid OS: $1" >&2
        exit 1
      fi
      OS="$OS $1"
      shift
    done
    ;;
  --beautify)
    if [ -z "$2" ] || [[ "$2" == "--"* ]]; then
      # No value provided, default to true
      BEAUTIFY=true
      shift # past option
    else
      # Value provided
      if [[ "$2" != "true" ]] && [[ "$2" != "false" ]]; then
        echo "🛑 Invalid value for --beautify: $2. Must be 'true' or 'false'" >&2
        exit 1
      fi
      BEAUTIFY="$2"
      shift # past option
      shift # past value
    fi
    ;;
  --derived-data-path)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --derived-data-path" >&2
      exit 1
    fi
    DERIVED_DATA_PATH="$2"
    shift # past option
    shift # past value
    ;;
  --help | -h)
    print_help
    exit 0
    ;;
  *)
    # if the argument has "-" prefix, then it's an unknown option
    if [[ "$1" == "-"* ]]; then
      echo "🛑 Unknown option: $1" >&2
    else
      # otherwise, it's an unknown parameter
      echo "🛑 Unknown parameter: $1" >&2
    fi
    exit 1
    ;;
  esac
done

# ensure the package is provided
if [ -z "$PACKAGE_PATH" ]; then
  echo "🛑 --package is required."
  echo ""
  print_help
  exit 1
fi

# ensure the package path exists
if [ ! -d "$PACKAGE_PATH" ]; then
  echo "🛑 Package not found: $PACKAGE_PATH"
  exit 1
fi

# ensure the OS is provided
if [ -z "$OS" ]; then
  OS="macOS iOS tvOS visionOS watchOS"
fi

# MARK: - Main

ERROR_CODE=0

PACKAGE_PATH=$(realpath "$PACKAGE_PATH")

# make sure Package.swift exists
if [ ! -f "$PACKAGE_PATH/Package.swift" ]; then
  echo "Error: Package.swift not found"
  exit 1
fi

# xcodebuild picks its container from the current directory. A workspace or
# project in the package directory would silently take over as the container,
# and the build would not run against the bare package.
if ls -d "$PACKAGE_PATH"/*.xcworkspace >/dev/null 2>&1 || ls -d "$PACKAGE_PATH"/*.xcodeproj >/dev/null 2>&1; then
  echo "🛑 The package directory contains a workspace or project:"
  ls -d "$PACKAGE_PATH"/*.xcworkspace "$PACKAGE_PATH"/*.xcodeproj 2>/dev/null || true
  echo "xcodebuild would use it instead of the package. Move it out of the package directory."
  exit 1
fi

# The default scheme is the package name from Package.swift (the auto generated 
# scheme is named after the package, not the directory). Falls back to the directory 
# name when the manifest name cannot be parsed.
if [ -z "$SCHEME" ]; then
  SCHEME=$(sed -n 's/.*name:[[:space:]]*"\([^"]*\)".*/\1/p' "$PACKAGE_PATH/Package.swift" | head -n 1)
  if [ -z "$SCHEME" ]; then
    SCHEME=$(basename "$PACKAGE_PATH")
  fi
fi

# repo root of the package, for repo-local tools. Falls back to the package path 
# when the package is not in a git repo.
REPO_ROOT=$(git -C "$PACKAGE_PATH" rev-parse --show-toplevel 2>/dev/null || echo "$PACKAGE_PATH")

# jq is used to pick simulators. Prefer the repo-local binary.
if [ -x "$REPO_ROOT/bin/jq" ]; then
  JQ_BIN="$REPO_ROOT/bin/jq"
elif command -v jq &> /dev/null; then
  JQ_BIN="jq"
else
  echo "🛑 jq not found. Run bootstrap or install jq."
  exit 1
fi

echo "🚀 Build package: ${CYAN}$PACKAGE_PATH${RESET}, scheme: ${CYAN}$SCHEME${RESET}, configuration: ${CYAN}$CONFIGURATION${RESET}, os: ${CYAN}$OS${RESET}"
echo "${BOLD}Xcode Version:${RESET} ${CYAN}$(xcodebuild -version 2>&1 | tr '\n' ' ')${RESET}"

# Emits a GitHub check-run annotation, only when running in GitHub Actions.
# Annotations are publicly readable via the Checks API, which makes CI phase
# timing measurable without log access.
notice() {
  if [ "${GITHUB_ACTIONS:-false}" = "true" ]; then
    echo "::notice title=ci-timing::$*"
  fi
}

run_xcodebuild() {
  if [ "$BEAUTIFY" = true ] && [ -x "$REPO_ROOT/bin/xcbeautify" ]; then
    set -o pipefail
    "$@" | "$REPO_ROOT/bin/xcbeautify"
  else
    "$@"
  fi
}

# Passes -derivedDataPath only when a fixed path was requested. Expand with
# ${DD_ARGS[@]+"${DD_ARGS[@]}"} so an empty array is safe under set -u on
# the macOS default bash 3.2.
DD_ARGS=()
if [ -n "$DERIVED_DATA_PATH" ]; then
  DD_ARGS=(-derivedDataPath "$DERIVED_DATA_PATH")
fi

# Prefer the newest available matching simulator without dumping every destination 
# via the slow `xcodebuild -showdestinations`.
pick_simulator() {
  local name_regex="$1"
  # JSON is more reliable than grepping the human-readable device list. Sort
  # the OS version numerically, a plain text sort would put "9.4" after "26.5". 
  # Ties on the same OS version pick the last device name alphabetically, matching 
  #the previous name-based sort.
  xcrun simctl list devices available -j | "$JQ_BIN" -r --arg re "$name_regex" '
    [
      .devices
      | to_entries[]
      | .key as $runtime
      | .value[]
      | select(.isAvailable == true and (.name | test($re)))
      | {
          runtime: $runtime,
          name: .name,
          udid: .udid,
          version: ($runtime | sub(".*OS-"; "") | split("-") | map(tonumber? // 0))
        }
    ]
    | sort_by([.version, .name])
    | last // empty
    | [.runtime, .name, .udid]
    | @tsv
  '
}

pick_device() {
  local os="$1"

  if [ "$os" == "macOS" ]; then
    DEVICE_NAME="macOS"
    DEVICE_UDID=""
    DEVICE_OS_VERSION=$(sw_vers -productVersion)
    DESTINATION="platform=macOS"
    return
  fi

  local device_info=""
  case "$os" in
  iOS)
    # Prefer the plain base model (for example "iPhone 17"), fall back to any iPhone.
    device_info=$(pick_simulator '^iPhone [0-9]+$')
    if [ -z "$device_info" ]; then
      device_info=$(pick_simulator '^iPhone')
    fi
    ;;
  tvOS)
    # Prefer Apple TV 4K when present, fall back to any Apple TV.
    device_info=$(pick_simulator '^Apple TV 4K')
    if [ -z "$device_info" ]; then
      device_info=$(pick_simulator '^Apple TV')
    fi
    ;;
  visionOS)
    device_info=$(pick_simulator '^Apple Vision')
    ;;
  watchOS)
    device_info=$(pick_simulator '^Apple Watch')
    ;;
  esac
  if [ -z "$device_info" ]; then
    echo "🛑 No available $os simulator found"
    exit 1
  fi

  local runtime
  runtime=$(echo "$device_info" | cut -f1)
  DEVICE_NAME=$(echo "$device_info" | cut -f2)
  DEVICE_UDID=$(echo "$device_info" | cut -f3)
  # runtime looks like "com.apple.CoreSimulator.SimRuntime.iOS-26-0"
  DEVICE_OS_VERSION=$(echo "$runtime" | sed -E 's/.*OS-//' | tr '-' '.')
  DESTINATION="platform=$os Simulator,id=$DEVICE_UDID"
}

# xcodebuild uses the current directory (the package) as the container, no
# -workspace or -project is passed. Building for a simulator destination does
# not require the device to be booted.
cd "$PACKAGE_PATH"

for os in $OS; do
  pick_device "$os"
  echo ""
  echo "➡️  Building for ${CYAN}$os ($CONFIGURATION)${RESET} on ${CYAN}$DEVICE_NAME ($DEVICE_OS_VERSION)${RESET}..."
  start=$SECONDS
  build_status=0
  run_xcodebuild xcodebuild build \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration "$CONFIGURATION" \
    ${DD_ARGS[@]+"${DD_ARGS[@]}"} \
    COMPILER_INDEX_STORE_ENABLE=NO || build_status=$?
  duration=$((SECONDS - start))
  notice "build os=$os configuration=$CONFIGURATION duration_s=$duration"
  if [ $build_status -eq 0 ]; then
    echo "✅ Build for $os finished in ${duration}s"
  else
    echo "❌ Build for $os failed after ${duration}s"
    ERROR_CODE=$build_status
  fi
done

if [ $ERROR_CODE -ne 0 ]; then
  echo "🛑 Build failed."
  exit $ERROR_CODE
else
  echo "✅ Build succeeded."
fi
