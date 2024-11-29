#!/bin/bash

function gmb {
	if ! is_a_git_repo; then
		echo "${BOLD} This won't work, you are not in a git repo !"
		return 0
	fi

	if [ $# -eq 0 ]; then
		echo "${BOLD} Fatal ! Specify the Branch to merge to $current_branch"
		return 0
	fi

	current_branch=$(git branch | awk '/\*/ {print $2}')

	# check if the branch doesn't exist
	if ! is_a_git_branch "$1"; then
		echo "${BOLD} Fatal ! $1 is a Non Existing branch "
		return 0
	fi

	if [ "$current_branch" = "$1" ]; then
		echo "${BOLD} Fatal ! Cannot Merge Identical Branch "
		return 0
	fi

	git merge "$1"
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
source "$UTILS_DIR/check_branch.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${gmb_arguments[@]}"
  show_help "Description" "${gmb_descriptions[@]}"
  show_help "Options" "${gmb_options[@]}"
  show_help "Examples" "${gmb_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Call gmb function
gmb "$@"