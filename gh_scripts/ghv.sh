#!/bin/bash

function ghv {
	if ! is_a_git_repo; then
		echo "${BOLD} This won't work, you are not in a git repo !"
		return 0
	fi

	if [ "$#" -eq 0 ] || [ "$1" = "show" ] || [ "$1" = "owner" ]; then
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)

		if has_remote; then
			repo_url=$(git config --get remote.origin.url)
			repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')
			repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"
		else
			repo_owner=$(git config user.username)
			repo_name=$(basename "$(git rev-parse --show-toplevel)")
		fi

		if [ "$repo_owner" != "$current_user" ] && [ "$1" != "owner" ]; then
			echo "${BOLD} Sorry, you are not the owner of this repo !"
		elif [ "$1" = "owner" ]; then
			if has_remote; then
				echo "${BOLD} The repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}is owned by ${GREEN}$repo_owner"
			else
				echo "${BOLD} The local repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}is owned by ${GREEN}$repo_owner"
			fi
		else
			if has_remote; then
				isPrivate=$(gh repo view "$repo_owner/$repo_name" --json isPrivate --jq '.isPrivate')

				if [ "$1" = "show" ]; then
					visibility=$([ "$isPrivate" = "true" ] && echo "private" || echo "public")
					echo "${BOLD} This repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}is ${GREEN}$visibility"
				else
					new_visibility=$([ "$isPrivate" = "true" ] && echo "public" || echo "private")
					toggle_visibility() {
						printf "${BOLD}${RESET_COLOR} Make ${LIGHT_BLUE}$repo_name ${RESET_COLOR}repo ${GREEN}$new_visibility ${RESET_COLOR}? (y/n) "
						read -r change_visibility
						if [ "$change_visibility" = "y" ]; then
							# toggle visibility
							printf "${BOLD} Changing repo visibility to ${GREEN}$new_visibility ${RESET_COLOR}... "
							gh repo edit "$repo_owner/$repo_name" --visibility "$new_visibility" &>/dev/null
							echo "${BOLD}${GREEN} ${RESET_COLOR}"
						elif [ "$change_visibility" = "n" ]; then
							return 0
						else
							toggle_visibility
						fi
					}
					toggle_visibility
				fi
			else
				echo "${BOLD} The local repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}is owned by ${GREEN}$repo_owner"
			fi
		fi
	else
		echo "${BOLD} Sorry, wrong command argument !"
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
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${ghv_arguments[@]}"
  show_help "Description" "${ghv_descriptions[@]}"
  show_help "Options" "${ghv_options[@]}"
  show_extra "${ghv_extras[@]}"
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

# Call ghv function
ghv "$@"