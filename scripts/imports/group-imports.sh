#!/bin/bash

# Groups the imports at the top of the Swift files that `configs/.import-groups` applies to, in the order of its groups,
# with a blank line between groups. `format.sh` runs it with `--fix` before SwiftFormat, whose `sortImports` sorts the
# imports in each group, and `lint.sh` runs it with `--check`, in a repository that has the config.
#
# The grouping's logic is in `ImportGroups.swift`, next to this script, which `ImportGroupsTests.swift` tests with
# `swift test --package-path scripts/imports`. A repository that downloads ChouTi's scripts downloads this script,
# `group-imports.swift` and `ImportGroups.swift`.
#
# Usage: group-imports.sh --fix|--check
#   --fix:   Group the imports of the files whose imports aren't grouped.
#   --check: List the files whose imports aren't grouped, and exit with 1 when there are any.

set -euo pipefail

# resolve the repo from this script's location so group-imports works from any
# directory.
#
# unset GIT_DIR so a linked worktree hook cannot make --show-toplevel
# return the current directory
if [ -z "${BASH_SOURCE[0]:-}" ]; then
  echo "Error: group-imports must be run as a file, not piped to bash." >&2
  exit 1
fi
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 1
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && unset GIT_DIR && git rev-parse --show-toplevel) || exit 1
if [ ! -f "$REPO_ROOT/scripts/imports/group-imports.sh" ]; then
  echo "Error: resolved $REPO_ROOT does not look like the repository root." >&2
  exit 1
fi

if [[ $# -ne 1 || ("$1" != "--fix" && "$1" != "--check") ]]; then
  echo "usage: $0 --fix|--check"
  exit 2
fi
LOGIC="$SCRIPT_DIR/ImportGroups.swift"
ENTRY="$SCRIPT_DIR/group-imports.swift"
CONFIG="$REPO_ROOT/configs/.import-groups"

for file in "$LOGIC" "$ENTRY" "$CONFIG"; do
  if [[ ! -f "$file" ]]; then
    echo "🛑 Error: $file not found."
    exit 2
  fi
done

# compiling the tool takes a couple of seconds, so it's built once for each version of its sources and of this script,
# which has the compiler's arguments. each run builds into a file of its own, so that a run that stops halfway, or
# another run building at the same time, can't leave a broken tool behind
BUILD_DIR="$REPO_ROOT/.temp/group-imports"
TOOL="$BUILD_DIR/group-imports-$(cat "$LOGIC" "$ENTRY" "${BASH_SOURCE[0]}" | shasum | cut -c1-12)"
if [[ ! -x "$TOOL" ]]; then
  mkdir -p "$BUILD_DIR"
  swiftc -parse-as-library -o "$TOOL.$$" "$LOGIC" "$ENTRY"
  mv "$TOOL.$$" "$TOOL"
  # remove the other versions' tools, and the builds that another run may still be writing, such as a hook's during a
  # rebase, only once they're an hour old, which a run that stopped halfway leaves behind
  find "$BUILD_DIR" -type f ! -name "$(basename "$TOOL")" \( ! -name "*.*" -o -mmin +60 \) -delete
fi

"$TOOL" "$1" "$CONFIG" "$REPO_ROOT"
