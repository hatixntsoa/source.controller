#!/bin/bash

function ghadd {
	if ! is_a_git_repo; then
		echo "${BOLD} This won't work, you are not in a git repo !"
		return 0
	fi

	if ! has_remote; then
		echo "${BOLD} This repo has no remote on GitHub !"
		return 0
	fi

	if [ $# -eq 0 ]; then
		echo "${BOLD} Specify the username of the new collaborator !"
		return 0
	fi

	current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
	repo_url=$(git config --get remote.origin.url)
	repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')
	repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"

	# check if we are not the owner of the repo
	if [ "$repo_owner" != "$current_user" ]; then
		echo "${BOLD} Sorry, you are not the owner of this repo !"
		return 0
	fi

	# Loop through each collaborator username provided as an argument
	for collaborator in "$@"; do
		# Check if the collaborator exists on GitHub
		if ! is_a_github_user "$collaborator"; then
			printf "${BOLD} Cannot invite ${LIGHT_BLUE}$collaborator ${RESET_COLOR}to collaborate on ${LIGHT_BLUE}$repo_name${RESET_COLOR} "
			continue
		fi

		execute_with_loading \
			"${BOLD} Inviting ${LIGHT_BLUE}$collaborator ${RESET_COLOR}to collaborate on ${LIGHT_BLUE}$repo_name${RESET_COLOR}" \
			"gh api --method=PUT repos/$current_user/$repo_name/collaborators/$collaborator"
	done
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"
CATEGORY="gh.scripts"

HELPS_DIR="$PARENT_DIR/helps/$CATEGORY"
HELP_FILE="$(basename "$0" .sh)_help.sh"

UTILS_DIR="$PARENT_DIR/utils"

# Import necessary variables and functions
source "$UTILS_DIR/check_connection.sh"
source "$UTILS_DIR/check_git.sh"
source "$UTILS_DIR/check_gh.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_remote.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/check_user.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/loading.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${ghadd_arguments[@]}"
  show_help "Description" "${ghadd_descriptions[@]}"
  show_help "Options" "${ghadd_options[@]}"
  show_extra "${ghadd_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Check gh
check_gh

# Check for internet connectivity to GitHub
check_connection

# Call ghadd function
ghadd "$@"