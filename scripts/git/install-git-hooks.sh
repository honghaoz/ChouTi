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
  COMMAND_CONTENT="\$(git rev-parse --show-toplevel)/scripts/git/git-hooks/$HOOK_NAME"

  # use -x to make sure the whole line is matched
  # https://stackoverflow.com/a/69022922/3164091
  if [[ ! -z $(grep -x "$COMMAND_CONTENT" "$HOOK_SCRIPT") ]]; then
    echo "✅ ${CYAN}$HOOK_NAME${RESET} is already installed."
  else
    echo "" >> "$HOOK_SCRIPT"
    echo "# [$TAG] $HOOK_NAME" >> "$HOOK_SCRIPT"
    echo $COMMAND_CONTENT >> "$HOOK_SCRIPT"
    echo "✅ ${CYAN}$HOOK_NAME${RESET} is installed."
  fi
}

# declare a string array of all the hooks we want to install
declare -a HOOK_NAMES=("pre-commit" "post-checkout" "post-merge")

# read the array values with space
for HOOK_NAME in "${HOOK_NAMES[@]}"; do
  write-hook-script-content "$HOOK_NAME"
done
