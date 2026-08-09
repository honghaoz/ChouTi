#!/bin/bash

set -euo pipefail

# define colors
safe_tput() { [ -n "${TERM:-}" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
BOLD=$(safe_tput bold)
CYAN=$(safe_tput setaf 6)
RESET=$(safe_tput sgr0)

# OVERVIEW:
# Test a Swift package on one or more platforms with xcodebuild.
#
# Simulator platforms use an optimized flow:
# - no `xcodebuild -showdestinations` dump, simulators are picked via `simctl`
# - `build-for-testing` runs separately from `test-without-building`, so CI
#   can run them as separate steps: this gives per-phase timing, and keeps the
#   CPU-heavy simulator boot from competing with the CPU-heavy build on
#   few-core CI runners (overlapping boot with compile was measured slower
#   than running them serially there)
#
# PHASES (single --os only):
#   pick  - pick a destination (and simulator, if any), record it for later
#           phases
#   boot  - kick off simulator boot in the background (returns immediately,
#           no-op for macOS)
#   build - xcodebuild build-for-testing
#   test  - boot (if needed) and wait for the simulator, then run
#           xcodebuild test-without-building
#   all   - run all phases in order (default). Local machines have enough
#           cores for the detached boot to overlap the build.

print_help() {
  echo "${BOLD}OVERVIEW:${RESET} Test a Swift package with xcodebuild, no workspace needed."
  echo ""
  echo "${BOLD}Usage:${RESET} $0 --package <package_path> [--scheme <scheme_name>] [--os <macOS iOS tvOS visionOS watchOS>]"
  echo ""
  echo "${BOLD}OPTIONS:${RESET}"
  echo "  --package <package_path>                The path to the Swift package directory. Required."
  echo "  --scheme <scheme_name>                  The scheme to test. Optional. Default is the package name from Package.swift."
  echo "  --os <macOS iOS tvOS visionOS watchOS>  The list of OS to test for. Optional. Default is 'macOS iOS tvOS visionOS watchOS'."
  echo "  --beautify [true|false]                 Use xcbeautify to beautify the output. Optional. Default is true."
  echo "  --derived-data-path <path>              Use a fixed DerivedData path. Optional. Default is Xcode's DerivedData."
  echo "  --phase <pick|boot|build|test|all>      Run one phase of the test flow. Optional. Default is 'all'."
  echo "  --help, -h                              Show this help message."
  echo ""
  echo "${BOLD}PHASES:${RESET}"
  echo "  Tests run in phases. CI can run each phase as a separate workflow step to get"
  echo "  per-step timing. A single phase works with exactly one --os."
  echo ""
  echo "  pick   Pick a destination (and simulator, if any), save the choice for the later phases."
  echo "  boot   Start booting the picked simulator in the background, without waiting."
  echo "  build  Build the tests (xcodebuild build-for-testing)."
  echo "  test   Boot the simulator if needed, wait for it to be ready, then run the"
  echo "         built tests (xcodebuild test-without-building)."
  echo "  all    Run all phases in order in one go (default)."
  echo ""
  echo "${BOLD}EXAMPLES:${RESET}"
  echo "  $0 --package path/to/Package --os macOS iOS tvOS visionOS watchOS"
  echo "  $0 --package path/to/Package --os iOS --phase build"
}

# MARK: - Arguments

PACKAGE_PATH=""
SCHEME=""
OS=""
BEAUTIFY=true
DERIVED_DATA_PATH=""
PHASE="all"

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
  --phase)
    if [ -z "$2" ]; then
      echo "🛑 Missing value for --phase" >&2
      exit 1
    fi
    PHASE="$2"
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

case "$PHASE" in
pick | boot | build | test | all) ;;
*)
  echo "🛑 Invalid --phase: $PHASE (expected pick|boot|build|test|all)"
  exit 1
  ;;
esac

# Phases run as separate processes (CI steps), so they only support a single
# OS per invocation.
if [ "$PHASE" != "all" ]; then
  if [[ "$OS" == *" "* ]]; then
    echo "🛑 --phase can only be used with a single --os"
    exit 1
  fi
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
# and the tests would not run against the bare package.
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

# The pick phase records the chosen destination here so the later build/test
# phases (separate processes when run as CI steps) target the same device.
# Kept outside the repo so local runs don't dirty the working tree.
STATE_FILE="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/test-package-xcodebuild-state-$(echo "$PACKAGE_PATH" | shasum | cut -c1-12).env"

echo "🎯 Test package: ${CYAN}$PACKAGE_PATH${RESET}, scheme: ${CYAN}$SCHEME${RESET}, os: ${CYAN}$OS${RESET}, phase: ${CYAN}$PHASE${RESET}"
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

save_state() {
  {
    printf 'TEST_PACKAGE_OS=%q\n' "$1"
    printf 'TEST_PACKAGE_UDID=%q\n' "$DEVICE_UDID"
    printf 'TEST_PACKAGE_NAME=%q\n' "$DEVICE_NAME"
    printf 'TEST_PACKAGE_OS_VERSION=%q\n' "$DEVICE_OS_VERSION"
    printf 'TEST_PACKAGE_DESTINATION=%q\n' "$DESTINATION"
  } >"$STATE_FILE"
}

load_state() {
  local expected_os="$1"
  if [ ! -f "$STATE_FILE" ]; then
    echo "🛑 State file not found: $STATE_FILE. Run the pick phase first."
    exit 1
  fi
  # shellcheck disable=SC1090
  source "$STATE_FILE"
  # Guard against reusing a stale state file from a different platform, for
  # example running '--os iOS --phase build' after a tvOS pick.
  if [ "$TEST_PACKAGE_OS" != "$expected_os" ]; then
    echo "🛑 Saved destination is for $TEST_PACKAGE_OS, expected $expected_os. Run the pick phase first."
    exit 1
  fi
  CURRENT_OS="$TEST_PACKAGE_OS"
  DEVICE_UDID="$TEST_PACKAGE_UDID"
  DEVICE_NAME="$TEST_PACKAGE_NAME"
  DEVICE_OS_VERSION="$TEST_PACKAGE_OS_VERSION"
  DESTINATION="$TEST_PACKAGE_DESTINATION"
}

phase_pick() {
  local os="$1"
  pick_device "$os"
  echo "📱 Destination: ${CYAN}$DEVICE_NAME ($DEVICE_OS_VERSION)${RESET}${DEVICE_UDID:+, UDID: $DEVICE_UDID}"
  save_state "$os"
  notice "pick os=$os device=$DEVICE_NAME ($DEVICE_OS_VERSION)"
}

phase_boot() {
  load_state "$1"
  if [ -z "$DEVICE_UDID" ]; then
    echo "ℹ️  No simulator to boot for $CURRENT_OS"
    return
  fi
  # simctl boot blocks until the device reaches the Booted state, which takes
  # minutes for iPhone simulators on CI runners. Detach it so the boot runs
  # concurrently with the build phase. The test phase waits for readiness and
  # re-boots if this detached boot failed. The overlap only helps on many-core
  # machines (local use), CI runners are faster booting after the build.
  echo "🚀 Booting simulator in the background: $DEVICE_NAME ($DEVICE_OS_VERSION)..."
  nohup xcrun simctl boot "$DEVICE_UDID" >/dev/null 2>&1 &
  echo "✅ Boot kicked off (not waiting)"
}

phase_build() {
  load_state "$1"
  echo "🔨 Building for testing on ${CYAN}$DEVICE_NAME ($DEVICE_OS_VERSION)${RESET}..."
  local start=$SECONDS
  # Building for a simulator destination does not require the device to be
  # booted. xcodebuild uses the current directory (the package) as the
  # container, no -workspace or -project is passed.
  cd "$PACKAGE_PATH"
  run_xcodebuild xcodebuild build-for-testing \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    ${DD_ARGS[@]+"${DD_ARGS[@]}"} \
    COMPILER_INDEX_STORE_ENABLE=NO
  local duration=$((SECONDS - start))
  notice "build os=$CURRENT_OS duration_s=$duration"
  echo "✅ Build finished in ${duration}s"
}

phase_test() {
  load_state "$1"

  if [ -n "$DEVICE_UDID" ]; then
    echo "⏳ Booting simulator (or waiting for an in-flight boot)..."
    local start=$SECONDS
    # bootstatus -b boots the device if the boot phase was skipped or failed,
    # otherwise it waits for the in-flight boot to finish.
    xcrun simctl bootstatus "$DEVICE_UDID" -b
    # Emit the boot wait before running tests: test output can produce enough
    # annotations to hit GitHub's 10-per-step cap, which would drop this one.
    local boot_wait=$((SECONDS - start))
    notice "test os=$CURRENT_OS boot_wait_s=$boot_wait"
    echo "✅ Simulator ready (waited ${boot_wait}s)"

    # Set CI environment variables inside the simulator, so tests can detect
    # CI. These will be inherited by all processes including test runners.
    local ci_value="${CI:-false}"
    local continuous_integration_value="${CONTINUOUS_INTEGRATION:-false}"
    local github_actions_value="${GITHUB_ACTIONS:-false}"
    if [ "$ci_value" != "false" ] || [ "$continuous_integration_value" != "false" ] || [ "$github_actions_value" != "false" ]; then
      echo "🔧 Setting CI environment variables on simulator..."
      echo "  CI=$ci_value"
      echo "  CONTINUOUS_INTEGRATION=$continuous_integration_value"
      echo "  GITHUB_ACTIONS=$github_actions_value"
      xcrun simctl spawn "$DEVICE_UDID" launchctl setenv CI "$ci_value"
      xcrun simctl spawn "$DEVICE_UDID" launchctl setenv CONTINUOUS_INTEGRATION "$continuous_integration_value"
      xcrun simctl spawn "$DEVICE_UDID" launchctl setenv GITHUB_ACTIONS "$github_actions_value"
      echo "✅ Environment variables set"
    fi
  fi

  echo "➡️  Running $CURRENT_OS tests on ${CYAN}$DEVICE_NAME ($DEVICE_OS_VERSION)${RESET}..."
  local test_status=0
  cd "$PACKAGE_PATH"
  run_xcodebuild xcodebuild test-without-building \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    ${DD_ARGS[@]+"${DD_ARGS[@]}"} \
    -retry-tests-on-failure \
    -test-iterations 3 || test_status=$?

  if [ -n "$DEVICE_UDID" ]; then
    echo "🧹 Cleaning up CI environment variables..."
    xcrun simctl spawn "$DEVICE_UDID" launchctl unsetenv CI 2>/dev/null || true
    xcrun simctl spawn "$DEVICE_UDID" launchctl unsetenv CONTINUOUS_INTEGRATION 2>/dev/null || true
    xcrun simctl spawn "$DEVICE_UDID" launchctl unsetenv GITHUB_ACTIONS 2>/dev/null || true
  fi

  return $test_status
}

# single-phase mode: run one phase for a single OS and exit
if [ "$PHASE" != "all" ]; then
  case "$PHASE" in
  pick)
    phase_pick "$OS"
    ;;
  boot)
    phase_boot "$OS"
    ;;
  build)
    phase_build "$OS"
    ;;
  test)
    phase_test "$OS"
    ;;
  esac
  exit 0
fi

# all mode: run every requested OS, continue on failure, report at the end
for os in $OS; do
  echo ""
  echo "➡️  Running tests for $os..."
  # chain in a subshell so a failed phase short-circuits the rest for this
  # OS without aborting the loop over the remaining OSes
  (phase_pick "$os" && phase_boot "$os" && phase_build "$os" && phase_test "$os") || ERROR_CODE=$?
done

if [ $ERROR_CODE -ne 0 ]; then
  echo "🛑 Tests failed."
  exit $ERROR_CODE
else
  echo "✅ Tests passed."
fi
