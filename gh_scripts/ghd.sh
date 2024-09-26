#!/bin/bash

# Define colors
BOLD=$'\033[1m'
GREEN=$'\033[32m'
LIGHT_BLUE=$'\033[94m'
WHITE=$'\033[97m'
RESET=$'\033[0m'

# Check if the script is running on Android
if [ -f "/system/build.prop" ]; then
	SUDO=""
else
	# Check for sudo availability on other Unix-like systems
	if command -v sudo >/dev/null 2>&1; then
		SUDO="sudo"
	else
		echo "Sorry, sudo is not available."
		exit 1
	fi
fi

# this will check for sudo permission
allow_sudo() {
	if [ -n "$SUDO" ]; then
		$SUDO -n true 2>/dev/null
		if [ $? -ne 0 ]; then
			$SUDO -v
		fi
	fi
}

# Function to display usage
usage() {
	echo "${BOLD}Usage:${RESET}"
	echo "  $(basename "$0" .sh)"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  Deletes a local and/or remote GitHub repository."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  --help           Display this help message."
	echo
	exit 0
}

# Function to sanitize the repository name
clean_repo() {
	repo_name="$1"
	# Replace spaces with underscores
  printf "%s" "$repo_name" | sed -E 's/ /_/g'
}

# Check if GitHub CLI is installed
if ! gh --version >/dev/null 2>&1; then
	echo "gh is not installed."
	exit 1
fi

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Function to delete local repo
delete_local_repo() {
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
delete_repo() {
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

# Check if it is a git repo
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# Check if it has a remote
if git remote -v >/dev/null 2>&1; then
	has_remote=true
fi

if [ "$is_a_git_repo" = "true" ]; then
	if [ "$has_remote" ]; then
		if $SUDO ping -c 1 github.com &>/dev/null; then
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
