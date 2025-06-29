#!/bin/bash

function grst {
  if ! is_a_git_repo; then
    echo "${BOLD}${RESET_COLOR} This won't work, you are not in a git repo !"
    return 0
  fi

  if [ $# -eq 0 ]; then
    git checkout -- .
    return 0
  fi

  if [ -f "$1" ]; then
    git reset "$1"
    return 0
  fi

  if [ $1 = "cmt" ]; then
    git reset --soft HEAD~1
    return 0
  fi

  # Loop through each argument and check if it's a file
  for arg in "$@"; do
    if [ ! -f "$arg" ]; then
      echo "${BOLD}${RESET_COLOR} Sorry, only restore file(s). ${LIGHT_BLUE}'$arg'${RESET_COLOR} is not a valid file."
      exit 1
    fi
  done

  # If all arguments are valid files, restore them
  git restore "$@"
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"
CATEGORY="git_scripts"

HELPS_DIR="$PARENT_DIR/helps/$CATEGORY"
HELP_FILE="$(basename "$0" .sh)_help.sh"

UTILS_DIR="$PARENT_DIR/utils"

# Import necessary variables and functions
source "$UTILS_DIR/check_git.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${grst_arguments[@]}"
  show_help "Description" "${grst_descriptions[@]}"
  show_help "Options" "${grst_options[@]}"
  show_extra "${grst_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Call grst function
grst "$@"
