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
	echo "  $(basename "$0" .sh) [show|owner]"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script interacts with a GitHub repository"
	echo "  associated with the current local Git repository."
	echo
	echo "  It can show the repository's visibility,"
	echo "  toggle the visibility between 'public' and 'private',"
	echo "  or display the repository's owner."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  show             Display the visibility status of the repository."
	echo "  owner            Show the owner of the repository."
	echo
	echo "  --help           Display this help message."
	echo
	echo "  If no arguments are provided, it checks the repository visibility"
	echo "  and will prompt to toggle it according to its current state."
	exit 0
}

# Check if GitHub CLI is installed
if ! gh --version >/dev/null 2>&1; then
	echo "gh is not installed."
	exit 1
fi

# Function to sanitize the repository name
clean_repo() {
	repo_name="$1"
	# Replace spaces with underscores
  printf "%s" "$repo_name" | sed -E 's/ /_/g'
}

# Check if --help is the first argument
if [ "$1" = "--help" ]; then
	usage
fi

# Check if it is a git repo
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# Initialize has_remote variable
has_remote=false

# Check if it has a remote
if git remote -v | grep -q .; then
  has_remote=true
fi

# ghv functions
if [ "$is_a_git_repo" = "true" ]; then
	if [ "$#" -eq 0 ] || [ "$1" = "show" ] || [ "$1" = "owner" ]; then
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)

		if [ "$has_remote" ]; then
			repo_url=$(git config --get remote.origin.url)
			repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')
			repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"
		else
			repo_owner=$(git config user.username)
			repo_name=$(basename "$(git rev-parse --show-toplevel)")
		fi

		if [ "$repo_owner" != "$current_user" ] && [ "$1" != "owner" ]; then
			echo "${BOLD} ■■▶ Sorry, you are not the owner of this repo !"
		elif [ "$1" = "owner" ]; then
			if [ "$has_remote" ]; then
				echo "${BOLD} The repo ${LIGHT_BLUE}$repo_name ${WHITE}is owned by ${GREEN}$repo_owner"
			else
				echo "${BOLD} The local repo ${LIGHT_BLUE}$repo_name ${WHITE}is owned by ${GREEN}$repo_owner"
			fi
		else
			if [ "$has_remote" ]; then
				# prompt for sudo
				# password if required
				allow_sudo

				# Check for internet connectivity to GitHub
				if $SUDO ping -c 1 github.com &>/dev/null; then
					isPrivate=$(gh repo view "$repo_owner/$repo_name" --json isPrivate --jq '.isPrivate')

					if [ "$1" = "show" ]; then
						visibility=$([ "$isPrivate" = "true" ] && echo "private" || echo "public")
						echo "${BOLD} This repo ${LIGHT_BLUE}$repo_name ${WHITE}is ${GREEN}$visibility"
					else
						new_visibility=$([ "$isPrivate" = "true" ] && echo "public" || echo "private")
						toggle_visibility() {
							printf "${BOLD}${WHITE} Make ${LIGHT_BLUE}$repo_name ${WHITE}repo ${GREEN}$new_visibility ${WHITE}? (y/n) "
							read -r change_visibility
							if [ "$change_visibility" = "y" ]; then
								# toggle visibility
								printf "${BOLD} Changing repo visibility to ${GREEN}$new_visibility ${WHITE}... "
								gh repo edit "$repo_owner/$repo_name" --visibility "$new_visibility" &>/dev/null
								echo "${BOLD}${GREEN} ${WHITE}"
							elif [ "$change_visibility" = "n" ]; then
								return 0
							else
								toggle_visibility
							fi
						}
						toggle_visibility
					fi
				else
					echo "${BOLD} ■■▶ This won't work, you are offline !${RESET}"
				fi
			else
				echo "${BOLD} The local repo ${LIGHT_BLUE}$repo_name ${WHITE}is owned by ${GREEN}$repo_owner"
			fi
		fi
	else
		echo "${BOLD} ■■▶ Sorry, wrong command argument !"
	fi
else
	echo "${BOLD} ■■▶ This won't work, you are not in a git repo !"
fi
