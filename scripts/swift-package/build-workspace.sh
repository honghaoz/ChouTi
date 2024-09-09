#!/bin/bash

set -e

# define colors
safe_tput() { [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
BOLD=$(safe_tput bold)
CYAN=$(safe_tput setaf 6)
RESET=$(safe_tput sgr0)

print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Build Swift package via a workspace for all platforms."
  echo ""
  echo "${BOLD}Usage:${RESET} $0 --workspace-path <workspace_path> --scheme <scheme_name> --configuration <configuration> --os <iOS macOS tvOS visionOS>"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --workspace-path <workspace_path>  The path to the workspace. Required."
  echo "  --scheme <scheme_name>             The scheme to build. Required."
  echo "  --configuration <configuration>    The build configuration. Optional. Default is Debug."
  echo "  --os <iOS macOS tvOS visionOS>     The list of OS to build for. Optional. Default is 'iOS macOS tvOS visionOS'."
  echo "  --help, -h                         Show this help message."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  $0 --workspace path/to/Project.xcworkspace --scheme ChouTi --configuration Debug|Release --os iOS macOS tvOS visionOS"
}

WORKSPACE_PATH=""
SCHEME=""
CONFIGURATION="Debug"
OS=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --workspace-path)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --workspace-path" >&2
      exit 1
    fi
    WORKSPACE_PATH="$2"
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
    while [[ "$1" != "--"* ]] && [[ "$#" -gt 0 ]]; do
      # arguments should be in [iOS macOS tvOS visionOS]
      if [[ "$1" != "iOS" ]] && [[ "$1" != "macOS" ]] && [[ "$1" != "tvOS" ]] && [[ "$1" != "visionOS" ]]; then
        echo "🛑 Invalid OS: $1" >&2
        exit 1
      fi
      OS="$OS $1"
      shift
    done
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

# ensure the configuration is either Debug or Release
if [ "$CONFIGURATION" != "Debug" ] && [ "$CONFIGURATION" != "Release" ]; then
  echo "🛑 Invalid configuration: $CONFIGURATION"
  echo ""
  print_help
  exit 1
fi

# ensure the workspace is provided
if [ -z "$WORKSPACE_PATH" ]; then
  echo "🛑 --workspace-path is required."
  echo ""
  print_help
  exit 1
fi

# ensure the scheme is provided
if [ -z "$SCHEME" ]; then
  echo "🛑 --scheme is required."
  echo ""
  print_help
  exit 1
fi

# ensure the OS is provided
if [ -z "$OS" ]; then
  OS="iOS macOS tvOS visionOS"
fi

# ensure workspace path exists
if [ ! -d "$WORKSPACE_PATH" ]; then
  echo "🛑 Workspace not found: $WORKSPACE_PATH"
  exit 1
fi

# ===------ MAIN ------===

REPO_ROOT=$(git rev-parse --show-toplevel)
ERROR_CODE=0

WORKSPACE_DIR=$(dirname "$WORKSPACE_PATH")
WORKSPACE=$(basename "$WORKSPACE_PATH")
WORKSPACE_PACKAGE_RESOLVED="$WORKSPACE_PATH/xcshareddata/swiftpm/Package.resolved"

cd "$WORKSPACE_DIR" || exit 1

echo "Update Package.resolved..."
swift package update

if [ -f "$WORKSPACE_PACKAGE_RESOLVED" ]; then
  echo "Copy Package.resolved to $WORKSPACE_PACKAGE_RESOLVED"
  # remove the file if it exists
  rm -f "$WORKSPACE_PACKAGE_RESOLVED"
  cp "$WORKSPACE_DIR/Package.resolved" "$WORKSPACE_PACKAGE_RESOLVED"
fi

echo "🚀 Build workspace: ${CYAN}$WORKSPACE${RESET}, scheme: ${CYAN}$SCHEME${RESET}, configuration: ${CYAN}$CONFIGURATION${RESET}, os: ${CYAN}$OS${RESET}"

echo "${BOLD}Swift Version:${RESET} $(swift --version)"
echo "${BOLD}Xcode Version:${RESET} $(xcodebuild -version)"
echo "${BOLD}Available Simulators:${RESET}"
xcrun simctl list devices available

echo "ℹ️  $WORKSPACE, Scheme: $SCHEME, available destinations:"
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations

# For macOS
if [[ "$OS" == *"macOS"* ]]; then
  echo ""
  echo "➡️  Building for macOS ($CONFIGURATION)..."
  SWIFT_BUILD_CONFIG="debug"
  if [ "$CONFIGURATION" == "Release" ]; then
    SWIFT_BUILD_CONFIG="release"
  fi
  set -o pipefail && swift build -c "$SWIFT_BUILD_CONFIG" || ERROR_CODE=$?
fi

# For iOS
if [[ "$OS" == *"iOS"* ]]; then
  echo ""
  echo "➡️  Building for iOS ($CONFIGURATION)..."
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'iPhone' | grep -Eo 'iPhone \d+' | sort -t ' ' -k 2 -nr | head -1)
  PLATFORM="iOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
  # DESTINATION="generic/platform=iOS"
  set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For tvOS
if [[ "$OS" == *"tvOS"* ]]; then
  echo ""
  echo "➡️  Building for tvOS ($CONFIGURATION)..."
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'Apple TV' | head -n 1 | awk -F'(' '{print $1}' | xargs)
  PLATFORM="tvOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
  set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For visionOS
if [[ "$OS" == *"visionOS"* ]]; then
  echo ""
  echo "➡️  Building for visionOS ($CONFIGURATION)..."
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep "Apple Vision" | head -n 1 | awk -F'(' '{print $1}' | xargs)
  PLATFORM="visionOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
  # DESTINATION="generic/platform=visionOS"
  set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

if [ $ERROR_CODE -ne 0 ]; then
  echo "🛑 Build failed."
  exit $ERROR_CODE
else
  echo "✅ Build succeeded."
fi
