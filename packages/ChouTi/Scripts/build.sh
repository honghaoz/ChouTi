#!/bin/bash

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# OVERVIEW:
# Build for all platfotms.

print_help() {
  echo "OVERVIEW: Build for all platfotms."
  echo ""
  echo "Usage: $0 --configuration <configuration>"
  echo ""
  echo "OPTIONS:"
  echo "  --configuration <configuration> The build configuration. Default is Debug."
  echo ""
  echo "EXAMPLES:"
  echo "  $0 --configuration Debug|Release"
  exit 1
}

CONFIGURATION="Debug"

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --configuration)
    CONFIGURATION="$2"
    shift
    ;;
  *) print_help ;;
  esac
  shift
done

# ensure the configuration is either Debug or Release
if [ "$CONFIGURATION" != "Debug" ] && [ "$CONFIGURATION" != "Release" ]; then
  echo "Invalid configuration: $CONFIGURATION"
  print_help
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
ERROR_CODE=0

echo "Swift Version: $(swift --version)"
echo "Xcode Version: $(xcodebuild -version)"
echo "Available Simulators:"
xcrun simctl list devices available

cd ..

WORKSPACE="Project.xcworkspace"
SCHEME="ChouTi"

# For macOS
echo "➡️  [1/2] Building for macOS..."
SWIFT_BUILD_CONFIG="debug"
if [ "$CONFIGURATION" == "Release" ]; then
  SWIFT_BUILD_CONFIG="release"
fi
set -o pipefail && swift build -c "$SWIFT_BUILD_CONFIG" || ERROR_CODE=$?

# For iOS
echo ""
echo "➡️  [2/2] Building for iOS..."
SIMULATOR_NAME=$(xcrun simctl list devices available | grep 'iPhone' | grep -Eo 'iPhone \d+' | sort -t ' ' -k 2 -nr | head -1)
PLATFORM="iOS Simulator"
DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?

# For visionOS
echo ""
echo "➡️  [3/3] Building for visionOS..."
SIMULATOR_NAME=$(xcrun simctl list devices available | grep "Apple Vision" | head -n 1 | awk -F'(' '{print $1}' | xargs)
PLATFORM="visionOS Simulator"
DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME"
set -o pipefail && xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -configuration "$CONFIGURATION" | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?

if [ $ERROR_CODE -ne 0 ]; then
  echo "Build failed."
  exit $ERROR_CODE
fi

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0
