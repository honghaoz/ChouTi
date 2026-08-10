#!/bin/bash

set -e

# change to the directory in which this script is located
pushd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1

# ===------ BEGIN ------===

# define colors
safe_tput() { [ -n "$TERM" ] && [ "$TERM" != "dumb" ] && tput "$@" || echo ""; }
CYAN=$(safe_tput setaf 6)
RESET=$(safe_tput sgr0)

TAG="ChouTi"
GIT_DIR=$(git rev-parse --git-dir)

cd "$GIT_DIR" || exit 1

if [[ ! -d "hooks" ]]; then
  mkdir hooks
fi

function write-hook-script-content() {
  HOOK_NAME="$1"
  HOOK_SCRIPT="./hooks/$HOOK_NAME"

  # 1) prepare empty hook script file if needed
  if ! [[ -f "$HOOK_SCRIPT" || -L "$HOOK_SCRIPT" ]]; then
    touch "$HOOK_SCRIPT"
    chmod +x "$HOOK_SCRIPT"
    echo "#!/bin/sh" >> "$HOOK_SCRIPT"
  fi

  # 2) write the hook script content
  # forward the hook arguments, hooks like prepare-commit-msg need them
  COMMAND_CONTENT="\$(git rev-parse --show-toplevel)/scripts/git/git-hooks/$HOOK_NAME \"\$@\""

  # match by the hook script path so older installed lines (without argument
  # forwarding) are not duplicated
  if [[ ! -z $(grep -F "/scripts/git/git-hooks/$HOOK_NAME" "$HOOK_SCRIPT") ]]; then
    echo "✅ ${CYAN}$HOOK_NAME${RESET} is already installed."
  else
    echo "" >> "$HOOK_SCRIPT"
    echo "# [$TAG] $HOOK_NAME" >> "$HOOK_SCRIPT"
    echo "$COMMAND_CONTENT" >> "$HOOK_SCRIPT"
    echo "✅ ${CYAN}$HOOK_NAME${RESET} is installed."
  fi
}

# declare a string array of all the hooks we want to install
declare -a HOOK_NAMES=("pre-commit" "post-checkout" "post-merge" "prepare-commit-msg")

# read the array values with space
for HOOK_NAME in "${HOOK_NAMES[@]}"; do
  write-hook-script-content "$HOOK_NAME"
done
