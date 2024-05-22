#!/bin/bash

set -e

tput-safe() {
  if [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
    tput "$@"
  fi
}

tput-bold() {
  tput-safe bold
}

tput-cyan() {
  tput-safe setaf 6
}

tput-reset() {
  tput-safe sgr0
}

print_help() {
  echo "$(tput-bold)OVERVIEW:$(tput-reset) Build Swift package via a workspace for all platforms."
  echo ""
  echo "$(tput-bold)Usage:$(tput-reset) $0 --workspace-path <workspace_path> --scheme <scheme_name>"
  echo ""
  echo "$(tput-bold)OPTIONS:$(tput-reset)"
  echo "  --workspace-path <workspace_path>  The path to the workspace. Required."
  echo "  --scheme <scheme_name>             The scheme to build. Required."
  echo "  --help, -h                         Show this help message."
  echo ""
  echo "$(tput-bold)EXAMPLES:$(tput-reset)"
  echo "  $0 --workspace path/to/Project.xcworkspace --scheme ChouTi --configuration Debug|Release"
}

WORKSPACE_PATH=""
SCHEME=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --workspace-path)
    WORKSPACE_PATH="$2"
    shift # past option
    shift # past value
    ;;
  --scheme)
    SCHEME="$2"
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

cd "$WORKSPACE_DIR" || exit 1

echo "🎯 Test workspace: $(tput-cyan)$WORKSPACE$(tput-reset), scheme: $(tput-cyan)$SCHEME$(tput-reset)"

echo "$(tput-bold)Swift Version:$(tput-reset) $(swift --version)"
echo "$(tput-bold)Xcode Version:$(tput-reset) $(xcodebuild -version)"
echo "$(tput-bold)Available Simulators:$(tput-reset)"
xcrun simctl list devices available

echo "ℹ️  $WORKSPACE, Scheme: $SCHEME, available destinations:"
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations

# For macOS
echo "➡️  [1/2] Running tests for macOS..."
# use swift test:
# pass 'TEST' compiler flag so the code can use "#if TEST" to conditionally 'import XCTest'.
set -o pipefail && swift test -Xswiftc -DTEST | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
# use xcodebuild:
# DESTINATION="platform=macOS,name=Any Mac"
# set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?

# For iOS
echo ""
echo "➡️  [2/2] Running tests for iOS..."
SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'iPhone' | grep -Eo 'iPhone \d+' | sort -t ' ' -k 2 -nr | head -1)
PLATFORM="iOS Simulator"
DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
echo "Running tests for $SIMULATOR_NAME..."
set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?

# For visionOS
echo ""
echo "➡️  [3/3] Running tests for visionOS..."
SIMULATOR_NAME=$(xcrun simctl list devices available | grep "Apple Vision" | head -n 1 | awk -F'(' '{print $1}' | xargs)
PLATFORM="visionOS Simulator"
DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
echo "Running tests for $SIMULATOR_NAME..."
set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?

if [ $ERROR_CODE -ne 0 ]; then
  echo "🛑 Tests failed."
  exit $ERROR_CODE
else
  echo "✅ Tests passed."
fi

# can omit the workspace, but looks like using workspace can get code coverage.
# https://www.jessesquires.com/blog/2021/11/03/swift-package-ios-tests/

# References:
# Pass Swift Complication Flags:
# https://forums.swift.org/t/swiftsettings-flags-arent-being-sent-to-dependencies/55919/4
# https://blog.krzyzanowskim.com/2016/10/10/conditional-swift-testing/
