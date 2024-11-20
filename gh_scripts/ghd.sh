#!/bin/bash

function ghd {
	if is_a_git_repo; then
		if has_remote; then
			if connected; then
				repo_url=$(git config --get remote.origin.url)
				current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
				repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')

				if [ "$repo_owner" != "$current_user" ]; then
					echo "${BOLD} ■■▶ Sorry, you are not the owner of this repo!${RESET}"
				else
					repo_name=$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')
					isPrivate=$(gh repo view "$repo_name" --json isPrivate --jq '.isPrivate')
					repo_visibility=$([ "$isPrivate" = "true" ] && echo "private" || echo "public")

					delete_repo
				fi
			else
				repo_name=$(basename "$(git rev-parse --show-toplevel)")
				delete_local_repo
			fi
		else
			repo_name=$(basename "$(git rev-parse --show-toplevel)")
			delete_local_repo
		fi
	else
		echo "${BOLD} ■■▶ This won't work, you are not in a git repo!${RESET}"
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
source "$UTILS_DIR/clean_repo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Check gh
check_gh

# Usage function to display help
function usage {
  show_help "Usage" "${ghd_arguments[@]}"
	show_help "Description" "${ghd_descriptions[@]}"
	show_help "Options" "${ghd_options[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# Check for internet connectivity to GitHub
check_connection

# Function to delete local repo
function delete_local_repo {
	printf "${BOLD}${WHITE} Delete ${GREEN}local ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
	read delete_local_repo
	if [ "$delete_local_repo" = "y" ]; then
		local repo_source=$(git rev-parse --show-toplevel)
		printf "${BOLD} Deleting ${GREEN}local ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}... ${RESET}"
		rm -rf "$repo_source/.git"
		echo "${BOLD}${GREEN} ${WHITE}"
	elif [ "$delete_local_repo" = "n" ]; then
		return 0
	else
		delete_local_repo
	fi
}

# Function to delete GitHub repo
function delete_repo {
	printf "${BOLD}${WHITE} Delete ${GREEN}$repo_visibility ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
	read delete_repo
	if [ "$delete_repo" = "y" ]; then
		printf "${BOLD} Deleting repository ${LIGHT_BLUE}$repo_name ${WHITE}on GitHub ... ${RESET}"
		gh repo delete "$repo_name" --yes &>/dev/null
		git remote remove origin
		echo "${BOLD}${GREEN} ${WHITE}"
		delete_local_repo
	elif [ "$delete_repo" = "n" ]; then
		return 0
	else
		delete_repo
	fi
}

# Call ghd function
ghd