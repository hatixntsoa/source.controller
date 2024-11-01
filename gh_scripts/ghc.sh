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
	echo "  $(basename "$0" .sh) [repo_name] [visibility]"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script creates a new GitHub repository and optionally sets it as the remote"
	echo "  for the current local Git repository. "
	echo "  If the current directory is a Git repository and does not"
	echo "  already have a remote, it will ask if you want to"
	echo "  create a new remote repository and push local commits to it."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  [repo_name]      Name of the GitHub repository to create."
	echo "                   If omitted, the name of the current directory is used."
	echo "                   (e.g., ghc or ghc private)"
	echo
	echo "  [visibility]     Repository visibility. Options are 'public' or 'private'."
	echo "                   If omitted, the default is 'public'."
	echo "                   (e.g., ghc repo_name)"
	echo
	echo "  --help           Display this help message."
	echo
	echo " If no arguments are provided, the script uses the current directory name"
	echo " as the repository name and creates a public repository."
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
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Check if it is a git repo and suppress errors
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    is_a_git_repo=true
else
    is_a_git_repo=false
fi

# Initialize has_remote variable
has_remote=false

# Check if it has a remote only if it's a git repo
if [ "$is_a_git_repo" = true ]; then
    if git remote -v | grep -q .; then
        has_remote=true
    fi
fi

# Get the repo name and visibility
if [ $# -eq 0 ]; then
	repo="$(basename "$PWD")"
	repo_visibility="public"
elif [ $# -eq 1 ]; then
	if [ "$1" = "private" ]; then
		repo="$(basename "$PWD")"
		repo_visibility="private"
	else
		repo="$1"
		repo_visibility="public"
	fi
elif [ $# -eq 2 ]; then
	repo="$1"
	repo_visibility="$2"
else
	echo "${BOLD}${RED}Error: Too many arguments.${RESET}"
	usage
fi

# Clean the repo name
repo_name=$(clean_repo "$repo")

if [ "$is_a_git_repo" = "true" ]; then
	if [ "$has_remote" = "true" ]; then
		printf "${BOLD}■■▶ This repo already has a remote on GitHub!${RESET}\n"
	else
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)

		check_set_repo() {
			printf "${BOLD}${WHITE} Create ${GREEN}$repo_visibility ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
			read set_repo
			if [ "$set_repo" = "y" ]; then
				# Create the repo & set it as remote of the local one
				printf "${BOLD} New repository ${LIGHT_BLUE}$repo_name ${WHITE}on GitHub ... ${RESET}"
				gh repo create "$repo_name" --"$repo_visibility" &>/dev/null
				git remote add origin "git@github.com:$current_user/$repo_name.git"
				printf "${BOLD}${GREEN} ${RESET}\n"

				check_push() {
					printf "${BOLD}${WHITE} Push local commits to ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
					read check_push_commit

					if [ "$check_push_commit" = "y" ]; then
						current_branch=$(git branch | awk '/\*/ {print $2}')
						git push origin "$current_branch"
					elif [ "$check_push_commit" = "n" ]; then
						return 0
					else
						check_push
					fi
				}

				current_branch=$(git branch | awk '/\*/ {print $2}')

				if git rev-list --count "$current_branch" 2>/dev/null | grep -q '^[1-9]'; then
					check_push
				fi
			elif [ "$set_repo" = "n" ]; then
				return 0
			else
				check_set_repo
			fi
		}
		check_set_repo
	fi
else
	# Check for internet connectivity to GitHub
	if ! $SUDO ping -c 1 github.com &>/dev/null; then
		echo "${BOLD} ■■▶ Sorry, you are offline !${RESET}"
		check_local() {
			printf "${BOLD}${WHITE} Create ${GREEN}local ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
			read create_local

			if [ "$create_local" = "y" ]; then
				git init &>/dev/null
			elif [ "$create_local" = "n" ]; then
				return 0
			else
				check_local
			fi
		}
		check_local
	else
		check_create_repo() {
			printf "${BOLD}${WHITE} Create ${GREEN}$repo_visibility ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
			read create_repo
			if [ "$create_repo" = "y" ]; then
				# Create the repo & clone it locally
				printf "${BOLD} New repository ${LIGHT_BLUE}$repo_name ${WHITE}on GitHub ... ${RESET}"
				gh repo create "$repo_name" --"$repo_visibility" -c &>/dev/null
				mv "$repo_name/.git" . && rm -rf "$repo_name"
				printf "${BOLD}${GREEN} ${RESET}\n"
			elif [ "$create_repo" = "n" ]; then
				check_local() {
					printf "${BOLD}${WHITE} Create ${GREEN}local ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
					read create_local

					if [ "$create_local" = "y" ]; then
						git init &>/dev/null
					elif [ "$create_local" = "n" ]; then
						return 0
					else
						check_local
					fi
				}
				check_local
			else
				check_create_repo
			fi
		}
		check_create_repo
	fi
fi
