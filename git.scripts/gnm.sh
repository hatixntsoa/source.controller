#!/bin/bash

function gnm {
	if ! is_a_git_repo; then
		echo "${BOLD}${RESET_COLOR} This won't work, you are not in a git repo !"
		return 0
	fi

	if [ $# -eq 0 ]; then
		echo "${BOLD}${RESET_COLOR} Please pass the new name of '$current_branch' branch as argument "
		return 0
	fi

	current_branch=$(git branch | awk '/\*/ {print $2}')

	if [ $# -eq 1 ]; then
		git branch -M $current_branch "$1"
		return 0
	fi

	echo "${BOLD}${RESET_COLOR} Usage : gnm new_name_of_the_branch"
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"
CATEGORY="git.scripts"

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
  show_help "Usage" "${gnm_arguments[@]}"
  show_help "Description" "${gnm_descriptions[@]}"
  show_help "Options" "${gnm_options[@]}"
  show_help "Examples" "${gnm_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Call gnm function
gnm "$@"