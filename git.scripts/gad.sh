#!/bin/bash

function gad {
	if ! is_a_git_repo; then
		echo "${BOLD} This won't work, you are not in a git repo!${RESET}"
		return 0
	fi

	if [ $# -eq 0 ]; then
		# If no arguments, add all changes and commit (opens editor for commit message)
		git add --all && git commit
		return 0
	fi

	if [ $# -lt 1 ]; then
		# File is specified but no commit message
		echo "${BOLD}${RED}Error: no commit message!${RESET}"
		return 0
	fi

	if [ -f "$1" ]; then
		# Add the file and commit with message from arguments 2 onwards
		git add "$1" && git commit "$1" -m "${*:2}"
		return 0
	fi

	# Add all changes and commit with the provided message
	git add --all && git commit -m "$*"
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
  show_help "Usage" "${gad_arguments[@]}"
  show_help "Description" "${gad_descriptions[@]}"
  show_help "Options" "${gad_options[@]}"
  show_extra "${gad_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Call gad function
gad "$@"