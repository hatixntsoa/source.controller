#!/bin/bash

function ghd {
	if [ $# -eq 1 ]; then
		if ! connected; then
			echo "${BOLD} Sorry, you are offline !${RESET}"
			return 0
		fi

		if ! gh_installed; then
			echo "${BOLD} gh is not installed !${RESET}"
			return 0
		fi

		repo_name="$1"
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)

		# Check if the repo doesn't exist
		if ! load_and_delete \
			"${BOLD} Checking the ${GREEN}repo${RESET_COLOR} named" \
			"${LIGHT_BLUE}$current_user/$repo_name ${RESET_COLOR}on GitHub" \
			"is_my_github_repo $current_user/$repo_name"; then

			echo "${BOLD} Sorry, there is ${GREEN}no repo ${RESET_COLOR}such as" \
				"${LIGHT_BLUE}$current_user/$repo_name ${RESET_COLOR}on GitHub ${RESET}"
			return 0
		fi

		isPrivate=$(gh repo view "$repo_name" --json isPrivate --jq '.isPrivate')
		repo_visibility=$([ "$isPrivate" = "true" ] && echo "private" || echo "public")

		delete_repo "$repo_name"
	else
		if ! is_a_git_repo; then
			echo "${BOLD} This won't work, you are not in a git repo!${RESET}"
			return 0
		fi

		if has_remote; then
			if connected; then
				if ! gh_installed; then
					echo "${BOLD} gh is not installed !${RESET}"
					return 0
				fi

				repo_url=$(git config --get remote.origin.url)
				current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
				repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')

				if [ "$repo_owner" != "$current_user" ]; then
					echo "${BOLD} Sorry, you are not the owner of this repo!${RESET}"
				else
					repo_name=$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')
					isPrivate=$(gh repo view "$repo_name" --json isPrivate --jq '.isPrivate')
					repo_visibility=$([ "$isPrivate" = "true" ] && echo "private" || echo "public")

					delete_repo "$repo_name"
					git remote remove origin
					echo
					delete_local_repo "$repo_name"
				fi
			else
				repo_name=$(basename "$(git rev-parse --show-toplevel)")
				delete_local_repo "$repo_name"
			fi
		else
			repo_name=$(basename "$(git rev-parse --show-toplevel)")
			delete_local_repo "$repo_name"
		fi
	fi
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
source "$UTILS_DIR/check_repo.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_remote.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/check_user.sh"
source "$UTILS_DIR/clean_repo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/loading.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
	show_help "Usage" "${ghd_arguments[@]}"
	show_help "Description" "${ghd_descriptions[@]}"
	show_help "Options" "${ghd_options[@]}"
	exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Function to delete local repo
function delete_local_repo {
	printf "${BOLD}${RESET} Delete ${GREEN}local ${RESET_COLOR}repo ${LIGHT_BLUE}$1 ${RESET}? (y/n) ${RESET}"
	read delete_local_repo

	if [ "$delete_local_repo" = "y" ]; then
		local repo_source=$(git rev-parse --show-toplevel)

		execute_with_loading \
			"${BOLD} Deleting ${GREEN}local ${RESET_COLOR}repo ${LIGHT_BLUE}$1 ${RESET}" \
			"rm -rf "$repo_source/.git""
	elif [ "$delete_local_repo" = "n" ]; then
		return 0
	else
		delete_local_repo "$1"
	fi
}

# Function to delete GitHub repo
function delete_repo {
	printf "${BOLD} Delete ${GREEN}$repo_visibility ${RESET_COLOR}repo ${LIGHT_BLUE}$1 ${RESET_COLOR}? (y/n) ${RESET}"
	read delete_repo

	if [ "$delete_repo" = "y" ]; then
		execute_with_loading \
			"${BOLD} Deleting repository ${LIGHT_BLUE}$1 ${RESET_COLOR}on GitHub" \
			"gh repo delete "$1" --yes"
	elif [ "$delete_repo" = "n" ]; then
		return 0
	else
		delete_repo "$1"
	fi
}

# Call ghd function
ghd "$@"
