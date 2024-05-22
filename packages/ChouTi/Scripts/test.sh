#!/bin/bash

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# OVERVIEW:
# Run unit tests for all platfotms.

REPO_ROOT=$(git rev-parse --show-toplevel)
ERROR_CODE=0

echo "Swift Version: $(swift --version)"
echo "Xcode Version: $(xcodebuild -version)"
echo "Available Simulators:"
xcrun simctl list devices available

cd ..

WORKSPACE="Project.xcworkspace"
SCHEME="ChouTi"

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

# ===------ END ------===

# return to whatever directory we were in when this script was run
popd >/dev/null 2>&1 || exit 0

# References:
# Pass Swift Complication Flags:
# https://forums.swift.org/t/swiftsettings-flags-arent-being-sent-to-dependencies/55919/4
# https://blog.krzyzanowskim.com/2016/10/10/conditional-swift-testing/
