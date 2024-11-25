#!/bin/bash

function gcb {
	if is_a_git_repo; then
		if [ $# -eq 0 ]; then
			git checkout -
		else
			echo "${BOLD}${RESET_COLOR} Usage : gcb (no argument)"
		fi
	else
		echo "${BOLD}${RESET_COLOR} This won't work, you are not in a git repo !"
	fi
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
function usage() {
  show_help "Usage" "${gcb_arguments[@]}"
  show_help "Description" "${gcb_descriptions[@]}"
  show_help "Options" "${gcb_options[@]}"
  show_extra "${gcb_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Call gcb function
gcb