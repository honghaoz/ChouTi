#!/bin/bash

# OVERVIEW:
# This file defines constants for printing colored text in the terminal.

# Save the current state of 'errexit'
[[ $- == *e* ]] && ERREXIT_SET=1 || ERREXIT_SET=0

set +e # disable 'errexit' since tput dim may return 1

# define colors if TERM is good to handle them
if [[ -t 1 ]]; then
  NORMAL=$(tput sgr0)
  RESET=$NORMAL

  BOLD=$(tput bold)
  DIM=$(tput dim)
  UNDERLINE=$(tput smul)
  BLINK=$(tput blink)
  REVERSE=$(tput rev)
  HIDDEN=$(tput invis)

  BLACK=$(tput setaf 0)
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  MEGENTA=$(tput setaf 5)
  CYAN=$(tput setaf 6)
  WHITE=$(tput setaf 7)
  LIGHTGRAY=$(tput setaf 8)

  BG_BLACK=$(tput setab 0)
  BG_RED=$(tput setab 1)
  BG_GREEN=$(tput setab 2)
  BG_YELLOW=$(tput setab 3)
  BG_BLUE=$(tput setab 4)
  BG_MEGENTA=$(tput setab 5)
  BG_CYAN=$(tput setab 6)
  BG_WHITE=$(tput setab 7)
  BG_LIGHTGRAY=$(tput setab 8)
else
  NORMAL=""
  RESET=$NORMAL

  BOLD=""
  DIM=""
  UNDERLINE=""
  BLINK=""
  REVERSE=""
  HIDDEN=""

  BLACK=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  MEGENTA=""
  CYAN=""
  WHITE=""
  LIGHTGRAY=""

  BG_BLACK=""
  BG_RED=""
  BG_GREEN=""
  BG_YELLOW=""
  BG_BLUE=""
  BG_MEGENTA=""
  BG_CYAN=""
  BG_WHITE=""
  BG_LIGHTGRAY=""
fi

# restore 'errexit' if it was set
[[ $ERREXIT_SET == 1 ]] && set -e
