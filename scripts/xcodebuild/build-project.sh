#!/bin/bash

set -e

# define colors
safe_tput() { [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
BOLD=$(safe_tput bold)
CYAN=$(safe_tput setaf 6)
RESET=$(safe_tput sgr0)

print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Build Xcode project for a specific platform."
  echo ""
  echo "${BOLD}Usage:${RESET} $0 --project <project_path> --scheme <scheme_name> --configuration <configuration> --os <macOS iOS tvOS visionOS watchOS>"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --project <project_path>                The path to the project. Required."
  echo "  --scheme <scheme_name>                  The scheme to build. Required."
  echo "  --configuration <configuration>         The build configuration. Optional. Default is Debug."
  echo "  --os <iOS macOS tvOS visionOS watchOS>  The list of OS to build for. Optional. Default is 'macOS iOS tvOS visionOS watchOS'."
  echo "  --help, -h                              Show this help message."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  $0 --project path/to/Project.xcodeproj --scheme ChouTi --configuration Debug|Release --os macOS iOS tvOS visionOS watchOS"
}

PROJECT_PATH=""
SCHEME=""
CONFIGURATION="Debug"
OS=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --project)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --project" >&2
      exit 1
    fi
    PROJECT_PATH="$2"
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

# ensure the project is provided
if [ -z "$PROJECT_PATH" ]; then
  echo "🛑 --project is required."
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

# ensure project path exists
if [ ! -d "$PROJECT_PATH" ]; then
  echo "🛑 Project not found: $PROJECT_PATH"
  exit 1
fi

# ===------ MAIN ------===

REPO_ROOT=$(git rev-parse --show-toplevel)
ERROR_CODE=0

PROJECT_DIR=$(dirname "$PROJECT_PATH")
PROJECT=$(basename "$PROJECT_PATH")

cd "$PROJECT_DIR" || exit 1

# == Update Package ==
# https://stackoverflow.com/a/79035750/3164091
echo "Update Package..."

# remove derived data
DERIVED_DATA_PATH=$(xcodebuild -showBuildSettings | grep -m 1 BUILD_DIR | grep -oE "\/.*" | sed 's|/Build/Products||')
if [ -d "$DERIVED_DATA_PATH" ]; then
  echo "Remove derived data: $DERIVED_DATA_PATH..."
  rm -rf "$DERIVED_DATA_PATH"
fi

# remove Package.resolved
PACKAGE_RESOLVED="$PROJECT/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
if [ -f "$PACKAGE_RESOLVED" ]; then
  echo "Remove Package.resolved: $PACKAGE_RESOLVED..."
  rm -f "$PACKAGE_RESOLVED"
fi
# == Update Package [END] ==

echo "🚀 Build project: ${CYAN}$PROJECT${RESET}, scheme: ${CYAN}$SCHEME${RESET}, configuration: ${CYAN}$CONFIGURATION${RESET}, os: ${CYAN}$OS${RESET}"

echo "${BOLD}Swift Version:${RESET} $(swift --version)"
echo "${BOLD}Xcode Version:${RESET} $(xcodebuild -version)"
echo "${BOLD}Available Simulators:${RESET}"
xcrun simctl list devices available

echo "ℹ️  $PROJECT, Scheme: $SCHEME, available destinations:"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showdestinations

# For macOS
if [[ "$OS" == *"macOS"* ]]; then
  echo ""
  echo "➡️  Building for macOS ($CONFIGURATION)..."
  set -o pipefail && xcodebuild clean build -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For iOS
if [[ "$OS" == *"iOS"* ]]; then
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'iPhone' | grep -Eo 'iPhone \d+' | sort -t ' ' -k 2 -nr | head -1)
  PLATFORM="iOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
  # DESTINATION="generic/platform=iOS"
  echo ""
  echo "➡️  Building for ${CYAN}iOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild clean build -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For tvOS
if [[ "$OS" == *"tvOS"* ]]; then
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'Apple TV' | head -n 1 | awk -F'(' '{print $1}' | xargs)
  PLATFORM="tvOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
  echo ""
  echo "➡️  Building for ${CYAN}tvOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild clean build -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For visionOS
if [[ "$OS" == *"visionOS"* ]]; then
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep "Apple Vision" | head -n 1 | awk -F'(' '{print $1}' | xargs)
  PLATFORM="visionOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
  # DESTINATION="generic/platform=visionOS"
  echo ""
  echo "➡️  Building for ${CYAN}visionOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild clean build -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For watchOS
if [[ "$OS" == *"watchOS"* ]]; then
  SIMULATOR_NAME=$(xcrun simctl list devices available | grep "Apple Watch" | head -n 1 | awk -F'(' '{print $1}' | xargs)
  PLATFORM="watchOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
  # DESTINATION="generic/platform=watchOS"
  echo ""
  echo "➡️  Building for ${CYAN}watchOS ($CONFIGURATION)${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild clean build -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

if [ $ERROR_CODE -ne 0 ]; then
  echo "🛑 Build failed."
  exit $ERROR_CODE
else
  echo "✅ Build succeeded."
fi
