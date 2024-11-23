#!/bin/bash

function ghcls {
	if is_a_git_repo; then
		if has_remote; then
			current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
			repo_url=$(git config --get remote.origin.url)
			repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')
			repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"

			# check if we are not the owner of the repo
			if [ "$repo_owner" != "$current_user" ]; then
				echo "${BOLD} ■■▶ Sorry, you are not the owner of this repo !"
			else
				printf "${BOLD} ${LIGHT_BLUE}Collaborators ${RESET_COLOR}for the ${LIGHT_BLUE}$repo_name ${RESET_COLOR}repository "

				# List collaborators using gh api
				collaborators=$(gh api "repos/$current_user/$repo_name/collaborators" --jq '.[].login')
				invitations=$(gh api "repos/$current_user/$repo_name/invitations" --jq '.[].invitee.login')

				collaborators_count=$(echo "$collaborators" | wc -l)
				invitations_count=$(echo "$invitations" | wc -l)
				collaborators_num=$((collaborators_count + invitations_count))
				echo "${RESET_COLOR}${BOLD}($collaborators_count)"

				# Iterate through each collaborator
				if [ -n "$collaborators" ]; then
					echo "$collaborators" | while IFS= read -r collaborator; do
						if [ "$collaborator" = "$current_user" ]; then
							echo " ● $collaborator (owner)"
						else
							echo " ● $collaborator"
						fi
					done
				else
					echo "No collaborators found."
				fi

				# Check if there are pending invitations
				if [ -n "$invitations" ]; then
					# Print pending invitations
					echo "$invitations" | while IFS= read -r invitee; do
						echo " ● $invitee (invitation pending)"
					done
				fi
			fi
		else
			echo "${BOLD} ■■▶ This repo has no remote on GitHub !"
		fi
	else
		echo "${BOLD} ■■▶ This won't work, you are not in a git repo !"
	fi
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"
CATEGORY="gh_scripts"

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
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${ghcls_arguments[@]}"
	show_help "Description" "${ghcls_descriptions[@]}"
	show_help "Options" "${ghcls_options[@]}"
	show_extra "${ghcls_extras[@]}"
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

# Call ghcls function
ghcls