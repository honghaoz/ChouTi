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
  echo "${BOLD}Usage:${RESET} $0 --workspace-path <workspace_path> --scheme <scheme_name> --configuration <configuration> --os <macOS iOS tvOS visionOS watchOS>"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --workspace-path <workspace_path>       The path to the workspace. Required."
  echo "  --scheme <scheme_name>                  The scheme to build. Required."
  echo "  --configuration <configuration>         The build configuration. Optional. Default is Debug."
  echo "  --os <iOS macOS tvOS visionOS watchOS>  The list of OS to build for. Optional. Default is 'macOS iOS tvOS visionOS watchOS'."
  echo "  --help, -h                              Show this help message."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  $0 --workspace path/to/Project.xcworkspace --scheme ChouTi --configuration Debug|Release --os macOS iOS tvOS visionOS watchOS"
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
      # arguments should be in [macOS iOS tvOS visionOS watchOS]
      if [[ "$1" != "macOS" ]] && [[ "$1" != "iOS" ]]&& [[ "$1" != "tvOS" ]] && [[ "$1" != "visionOS" ]] && [[ "$1" != "watchOS" ]]; then
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
  OS="macOS iOS tvOS visionOS watchOS"
fi

# ensure workspace path exists
if [ ! -d "$WORKSPACE_PATH" ]; then
  echo "🛑 Workspace not found: $WORKSPACE_PATH"
  exit 1
fi

# ===------ MAIN ------===

REPO_ROOT=$(git rev-parse --show-toplevel)
ERROR_CODE=0

WORKSPACE_PATH=$(realpath "$WORKSPACE_PATH")
WORKSPACE_DIR=$(dirname "$WORKSPACE_PATH")
WORKSPACE=$(basename "$WORKSPACE_PATH")

# find Package.swift location
PACKAGE_DIR=""
CONTENTS_FILE="$WORKSPACE_PATH/contents.xcworkspacedata"
if [ -f "$CONTENTS_FILE" ]; then
  # extract the path of the package
  #  <FileRef
  #      location = "group:..">
  #   </FileRef>
  PACKAGE_DIR=$(sed -n 's/.*location = "group:\([^"]*\)".*/\1/p' "$CONTENTS_FILE" | head -n 1)
  PACKAGE_DIR=$(realpath "$WORKSPACE_DIR/$PACKAGE_DIR")
  echo "Package: $PACKAGE_DIR/Package.swift"
else
  echo "Error: contents.xcworkspacedata not found"
  exit 1
fi

cd "$PACKAGE_DIR" || exit 1

# make sure Package.swift exists
if [ ! -f "Package.swift" ]; then
  echo "Error: Package.swift not found"
  exit 1
fi

echo "Update Package.resolved..."
swift package update

cd "$WORKSPACE_DIR" || exit 1

WORKSPACE_PACKAGE_RESOLVED="$WORKSPACE_PATH/xcshareddata/swiftpm/Package.resolved"
if [ -f "$WORKSPACE_PACKAGE_RESOLVED" ]; then
  echo "Copy $PACKAGE_DIR/Package.resolved to $WORKSPACE_PACKAGE_RESOLVED"
  # remove the file if it exists
  rm -f "$WORKSPACE_PACKAGE_RESOLVED"
  cp "$PACKAGE_DIR/Package.resolved" "$WORKSPACE_PACKAGE_RESOLVED"
fi

echo "🚀 Build workspace: ${CYAN}$WORKSPACE${RESET}, scheme: ${CYAN}$SCHEME${RESET}, configuration: ${CYAN}$CONFIGURATION${RESET}, os: ${CYAN}$OS${RESET}"

echo "${BOLD}Swift Version:${RESET} ${CYAN}$(swift --version 2>/dev/null | tr '\n' ' ')${RESET}"
echo "${BOLD}Xcode Version:${RESET} ${CYAN}$(xcodebuild -version 2>&1 | tr '\n' ' ')${RESET}"
echo "${BOLD}Available devices:${RESET}"
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
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'iPhone' | sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/' | sort -u | head -n 1)
  SIMULATOR_OS=$(xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations | grep "$SIMULATOR_NAME" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  PLATFORM="iOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  # DESTINATION="generic/platform=iOS"
  echo ""
  echo "➡️  Building for ${CYAN}iOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For tvOS
if [[ "$OS" == *"tvOS"* ]]; then
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'Apple TV 4K' | head -n 1 | sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/')
  SIMULATOR_OS=$(xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations | grep "$SIMULATOR_NAME" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  PLATFORM="tvOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  echo ""
  echo "➡️  Building for ${CYAN}tvOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For visionOS
if [[ "$OS" == *"visionOS"* ]]; then
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep "Apple Vision" | head -n 1 | sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/')
  SIMULATOR_OS=$(xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations | grep "$SIMULATOR_NAME" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  PLATFORM="visionOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  # DESTINATION="generic/platform=visionOS"
  echo ""
  echo "➡️  Building for ${CYAN}visionOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For watchOS
if [[ "$OS" == *"watchOS"* ]]; then
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep "Apple Watch" | head -n 1 | sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/')
  SIMULATOR_OS=$(xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations | grep "$SIMULATOR_NAME" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  PLATFORM="watchOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  # DESTINATION="generic/platform=watchOS"
  echo ""
  echo "➡️  Building for ${CYAN}watchOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

if [ $ERROR_CODE -ne 0 ]; then
  echo "🛑 Build failed."
  exit $ERROR_CODE
else
  echo "✅ Build succeeded."
fi
