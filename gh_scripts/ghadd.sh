#!/bin/bash

# Define colors
BOLD=$'\033[1m'
RED=$'\033[31m'
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
	echo "  $(basename "$0" .sh) [collaborator_username...]"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script interacts with a GitHub repository"
	echo "  associated with the current local Git repository."
	echo
	echo "  It allows you to invite new collaborators to the repository."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  [collaborator_username]  GitHub username(s) of the collaborators to invite."
	echo "                           Multiple usernames can be provided, separated by spaces."
	echo
	echo "  --help                   Display this help message."
	echo
	echo "  If no usernames are provided, the script will"
	echo "  prompt you to specify at least one."
	exit 0
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

# Check for internet connectivity to GitHub
if ! $SUDO ping -c 1 github.com &>/dev/null; then
	echo "${BOLD} ■■▶ This won't work, you are offline !${RESET}"
	exit 0
fi

# Check if it is a git repo
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# Initialize has_remote variable
has_remote=false

# Check if it has a remote
if git remote -v | grep -q .; then
  has_remote=true
fi

# check if the collaborator is a GitHub user
is_a_github_user() {
	username="$1"

	# Check if username is empty
	if [ -z "$username" ]; then
		return 1
	fi

	# Build the API URL
	url="https://api.github.com/users/$username"

	# Use wget to capture the response (redirecting output to a variable)
	# wget by default outputs content, so we use the -q (quiet) option to suppress it
	# -O- option specifies that the downloaded content should be written
	# to standard output (stdout) instead of a file.
	response=$(wget -qO- --no-check-certificate "$url")

	# Check if there is no output
	# meaning it is not found
	if [ -z "$response" ]; then
		# Not Found
		return 1
	else
		# Found
		return 0
	fi
}

# ghadd functions
if [ "$is_a_git_repo" = "true" ]; then
	if [ "$has_remote" ]; then
		if [ $# -eq 0 ]; then
			echo "${BOLD} ■■▶ Specify the username of the new collaborator !"
		elif [ $# -gt 0 ]; then
			current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
			repo_url=$(git config --get remote.origin.url)
			repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')
			repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"

			# check if we are not the owner of the repo
			if [ "$repo_owner" != "$current_user" ]; then
				echo "${BOLD} ■■▶ Sorry, you are not the owner of this repo !"
			else
				# Loop through each collaborator username provided as an argument
				for collaborator in "$@"; do
					printf "${BOLD} Inviting ${LIGHT_BLUE}$collaborator ${WHITE}to collaborate on ${LIGHT_BLUE}$repo_name${WHITE} "

					# Check if the collaborator exists on GitHub
					if is_a_github_user "$collaborator"; then
						# Add collaborator using gh api
						gh api --method=PUT "repos/$current_user/$repo_name/collaborators/$collaborator" >/dev/null 2>&1
						echo "${BOLD}${GREEN} ${WHITE}"
					else
						echo "${BOLD}${RED}✘ ${WHITE}"
					fi
				done
			fi
		fi
	else
		echo "${BOLD} ■■▶ This repo has no remote on GitHub !"
	fi
else
	echo "${BOLD} ■■▶ This won't work, you are not in a git repo !"
fi
