#!/bin/bash

function ghdel {
	if ! is_a_git_repo; then
		echo "${BOLD} This won't work, you are not in a git repo !"
		return 0
	fi

	if ! has_remote; then
		echo "${BOLD} This repo has no remote on Github !"
		return 0
	fi

	if [ $# -eq 0 ]; then
		echo "${BOLD} Specify the username of the collaborator to remove !"
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

	# Retrieve the list of collaborators
	collaborators=$(gh api "repos/$current_user/$repo_name/collaborators" --jq '.[].login')
	invitations=$(gh api "repos/$current_user/$repo_name/invitations" --jq '.[].invitee.login')

	# Loop through each collaborator username provided as an argument
	for collaborator in "$@"; do
		# Check if the collaborator exists in the list of collaborators
		if echo "$collaborators" | grep -q "$collaborator" ||
			echo "$invitations" | grep -q "$collaborator"; then
			printf "${BOLD} Removing ${LIGHT_BLUE}$collaborator ${RESET_COLOR}from ${LIGHT_BLUE}$repo_name${RESET_COLOR} "
			# Check for pending invitations
			invitation_id=$(gh api "repos/$current_user/$repo_name/invitations" --jq ".[] | select(.invitee.login==\"$collaborator\") | .id")

			if [ -n "$invitation_id" ]; then
				# Delete the pending invitation
				gh api --method=DELETE "repos/$current_user/$repo_name/invitations/$invitation_id" >/dev/null 2>&1
				printf " ${BOLD}(invitation deleted) "
			fi

			# Remove collaborator using gh api
			gh api --method=DELETE "repos/$current_user/$repo_name/collaborators/$collaborator" >/dev/null 2>&1
			echo "${BOLD}${GREEN} ${RESET_COLOR}"
		else
			echo "${BOLD}${LIGHT_BLUE}$collaborator ${RESET_COLOR}is not a ${LIGHT_BLUE}collaborator ${RED}✘ ${RESET_COLOR}"
		fi
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
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${ghdel_arguments[@]}"
  show_help "Description" "${ghdel_descriptions[@]}"
  show_help "Options" "${ghdel_options[@]}"
  show_extra "${ghdel_extras[@]}"
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

# Call ghdel function
ghdel "$@"