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
  echo "${BOLD}Usage:${RESET} $0 --workspace-path <workspace_path> --scheme <scheme_name> --os <macOS iOS tvOS visionOS watchOS>"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --workspace-path <workspace_path>       The path to the workspace. Required."
  echo "  --scheme <scheme_name>                  The scheme to build. Required."
  echo "  --os <iOS macOS tvOS visionOS watchOS>  The list of OS to build for. Optional. Default is 'macOS iOS tvOS visionOS watchOS'."
  echo "  --help, -h                              Show this help message."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  $0 --workspace path/to/Project.xcworkspace --scheme ChouTi --os macOS iOS tvOS visionOS watchOS"
}

WORKSPACE_PATH=""
SCHEME=""
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
      if [[ "$1" != "macOS" ]] && [[ "$1" != "iOS" ]] && [[ "$1" != "tvOS" ]] && [[ "$1" != "visionOS" ]] && [[ "$1" != "watchOS" ]]; then
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

echo "🎯 Test workspace: ${CYAN}$WORKSPACE${RESET}, scheme: ${CYAN}$SCHEME${RESET}, os: ${CYAN}$OS${RESET}"

echo "${BOLD}Swift Version:${RESET} ${CYAN}$(swift --version 2>/dev/null | tr '\n' ' ')${RESET}"
echo "${BOLD}Xcode Version:${RESET} ${CYAN}$(xcodebuild -version 2>&1 | tr '\n' ' ')${RESET}"
echo "${BOLD}Available devices:${RESET}"
DEVICES=$(xcrun simctl list devices available)
echo "$DEVICES"

echo ""
echo "ℹ️  ${CYAN}$WORKSPACE${RESET}, Scheme: ${CYAN}$SCHEME${RESET}, available destinations:"
DESTINATIONS=$(xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -showdestinations)
echo "$DESTINATIONS"

# For macOS
if [[ "$OS" == *"macOS"* ]]; then
  echo ""
  echo "➡️  Running tests for macOS..."
  # use swift test:
  # pass 'TEST' compiler flag so the code can use "#if TEST" to conditionally 'import XCTest'.
  # set -o pipefail && swift test -Xswiftc -DTEST | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
  # TODO: can use '--parallel --xunit-output test-results.xml' to generate test results and re-run failed tests.

  # use xcodebuild:
  # DESTINATION="platform=macOS,name=Any Mac"
  # set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -test-iterations 3 -retry-tests-on-failure | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?

  RAW_OUTPUT=$(swift test -Xswiftc -DTEST || ERROR_CODE=$?)
  echo "$RAW_OUTPUT" | "$REPO_ROOT"/bin/xcbeautify

  # Extract failed test case information
  # RAW_OUTPUT may include failed test cases like:
  #   /Users/foo/Developer/bluebox/packages/ChouTiExt/Tests/ChouTiExtTests/Utilities/EventFlowControl/ThrottlerTests.swift:134: error: -[ChouTiExtTests.ThrottlerTests test_latest_invokeImmediately] : failed - expect "[1.0, 2.0, 4.0, 5.0, 0.0]" to be equal to "[1.0, 2.0, 4.0, 5.0]"
  # Extract the test case name like: ChouTiExt.ThrottlerTests/test_latest_invokeImmediately
  FAILED_TESTS=$(echo "$RAW_OUTPUT" | grep -E ' error: ' | sed -E 's|.*error: -\[(.+)\.(.+) (.+)\] :.*|\1.\2/\3|')

  # dedupe FAILED_TESTS
  FAILED_TESTS=$(echo "$FAILED_TESTS" | sort | uniq)

  if [ -n "$FAILED_TESTS" ]; then
    echo ""
    echo "❌ Failed tests:"
    echo "$FAILED_TESTS"
    echo ""

    # can use the following command to re-run failed tests:
    # swift test -Xswiftc -DTEST --filter 'ChouTiExtTests.ThrottlerTests/test_latest_invokeImmediately'

    # temporarily disable exit on error, so that `swift test -Xswiftc -DTEST --filter "$test"` won't stop the script.
    set +e

    FINAL_FAILED_TESTS=""
    MAX_RETRY_ATTEMPTS=3

    # Re-run failed tests up to 3 times
    while IFS= read -r test; do
      echo "🔄 Re-running failed test: $test"
      for attempt in $(seq 1 $MAX_RETRY_ATTEMPTS); do
        echo ""
        echo "Attempt $attempt for $test"
        swift test -Xswiftc -DTEST --filter "$test"
        TEST_EXIT_CODE=$?
        if [ $TEST_EXIT_CODE -eq 0 ]; then
          echo "✅ Test passed on attempt $attempt: $test"
          break
        elif [ "$attempt" -eq $MAX_RETRY_ATTEMPTS ]; then
          echo "❌ Test failed after $MAX_RETRY_ATTEMPTS attempts: $test"
          FINAL_FAILED_TESTS+="$test"$'\n'
        else
          echo "Test failed on attempt $attempt: $test. Retrying..."
        fi
      done
    done <<< "$FAILED_TESTS"

    # re-enable exit on error
    set -e

    # if all failed succeeded after re-runs, set ERROR_CODE to 0
    if [ -z "$FINAL_FAILED_TESTS" ]; then
      ERROR_CODE=0
    else
      echo ""
      echo "❌ Final failed tests after retries:"
      echo "$FINAL_FAILED_TESTS"
      ERROR_CODE=1
    fi
  fi
fi

# For iOS
if [[ "$OS" == *"iOS"* ]]; then
  SIMULATOR_NAME=$(echo "$DEVICES" | grep 'iPhone' | grep -Eo 'iPhone \d+' | sort -ru | head -n 1 |sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/')
  SIMULATOR_OS=$(echo "$DESTINATIONS" | grep "name:$SIMULATOR_NAME" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  if [ -z "$SIMULATOR_NAME" ] || [ -z "$SIMULATOR_OS" ]; then
    echo "🛑 No available iOS simulator found. SIMULATOR_NAME: '$SIMULATOR_NAME', SIMULATOR_OS: '$SIMULATOR_OS'"
    exit 1
  fi
  PLATFORM="iOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  echo ""
  echo "➡️  Running tests for ${CYAN}iOS${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -test-iterations 3 -retry-tests-on-failure | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For tvOS
if [[ "$OS" == *"tvOS"* ]]; then
  SIMULATOR_NAME=$(echo "$DEVICES" | grep 'Apple TV 4K' | sort -ru | head -n 1 | sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/')
  SIMULATOR_OS=$(echo "$DESTINATIONS" | grep "name:$SIMULATOR_NAME" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  if [ -z "$SIMULATOR_NAME" ] || [ -z "$SIMULATOR_OS" ]; then
    echo "🛑 No available tvOS simulator found. SIMULATOR_NAME: '$SIMULATOR_NAME', SIMULATOR_OS: '$SIMULATOR_OS'"
    exit 1
  fi
  PLATFORM="tvOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  echo "➡️  Running tests for ${CYAN}tvOS${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -test-iterations 3 -retry-tests-on-failure | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For visionOS
if [[ "$OS" == *"visionOS"* ]]; then
  # { platform:visionOS Simulator, id:D2732A54-2256-431D-A54E-20FC9E555B4B, OS:2.3, name:Apple Vision Pro }
  # { platform:visionOS Simulator, variant:Designed for [iPad,iPhone], id:D2732A54-2256-431D-A54E-20FC9E555B4B, OS:2.3, name:Apple Vision Pro }
  DESIGNED_FOR_IPAD="variant:Designed"
  SIMULATOR_NAME=$(echo "$DEVICES" | grep "Apple Vision" | grep -v "$DESIGNED_FOR_IPAD" | sort -ru | head -n 1 | sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/')
  SIMULATOR_OS=$(echo "$DESTINATIONS" | grep "name:$SIMULATOR_NAME" | grep -v "$DESIGNED_FOR_IPAD" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  if [ -z "$SIMULATOR_NAME" ] || [ -z "$SIMULATOR_OS" ]; then
    echo "🛑 No available visionOS simulator found. SIMULATOR_NAME: '$SIMULATOR_NAME', SIMULATOR_OS: '$SIMULATOR_OS'"
    exit 1
  fi
  PLATFORM="visionOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  echo "➡️  Running tests for ${CYAN}visionOS${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -test-iterations 3 -retry-tests-on-failure | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

# For watchOS
if [[ "$OS" == *"watchOS"* ]]; then
  SIMULATOR_NAME=$(echo "$DEVICES" | grep "Apple Watch" | sort -ru | head -n 1 | sed -E 's/[[:space:]]*(.*) \([[:xdigit:]-]+\).*/\1/')
  SIMULATOR_OS=$(echo "$DESTINATIONS" | grep "name:$SIMULATOR_NAME" | sed -E 's/.*OS:([0-9.]+).*/\1/' | sort -t. -k1,1nr -k2,2nr | head -1)
  if [ -z "$SIMULATOR_NAME" ] || [ -z "$SIMULATOR_OS" ]; then
    echo "🛑 No available watchOS simulator found. SIMULATOR_NAME: '$SIMULATOR_NAME', SIMULATOR_OS: '$SIMULATOR_OS'"
    exit 1
  fi
  PLATFORM="watchOS Simulator"
  DESTINATION="platform=$PLATFORM,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
  echo "➡️  Running tests for ${CYAN}watchOS${RESET} on ${CYAN}$DESTINATION${RESET}..."
  set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$DESTINATION" -test-iterations 3 -retry-tests-on-failure | "$REPO_ROOT"/bin/xcbeautify || ERROR_CODE=$?
fi

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
