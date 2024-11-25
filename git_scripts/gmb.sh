#!/bin/bash

function gmb {
	if is_a_git_repo; then
		current_branch=$(git branch | awk '/\*/ {print $2}')
		if [ $# -eq 1 ]; then
			# check if the branch doesn't exist
			if ! git rev-parse --verify "$1" >/dev/null 2>&1; then
				echo "${BOLD} Fatal ! $1 is a Non Existing branch "
			else
				if [ "$current_branch" = "$1" ]; then
					echo "${BOLD} Fatal ! Cannot Merge Identical Branch "
				else
					git merge "$1"
				fi
			fi
		elif [ $# -eq 0 ]; then
			echo "${BOLD} Fatal ! Specify the Branch to merge to $current_branch"
		fi
	else
		echo "${BOLD} This won't work, you are not in a git repo !"
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