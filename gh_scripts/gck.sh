#!/bin/bash

# Define colors
BOLD=$'\033[1m'
RESET=$'\033[0m'
LIGHT_BLUE=$'\033[94m'
WHITE=$'\033[97m'
GREEN=$'\033[32m'

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

# Setup git
setup_git() {
	echo "${BOLD}Installing Git...${RESET}"

	if command -v apt-get &>/dev/null; then
		$SUDO apt-get update -y >/dev/null 2>&1
		$SUDO apt-get install -y git >/dev/null 2>&1
	elif command -v yum &>/dev/null; then
		$SUDO yum update -y >/dev/null 2>&1
		$SUDO yum install -y git >/dev/null 2>&1
	elif command -v dnf &>/dev/null; then
		$SUDO dnf update -y >/dev/null 2>&1
		$SUDO dnf install -y git >/dev/null 2>&1
	elif command -v pacman &>/dev/null; then
		$SUDO pacman -Syu --noconfirm git >/dev/null 2>&1
	elif command -v zypper &>/dev/null; then
		$SUDO zypper update >/dev/null 2>&1
		$SUDO zypper install -y git >/dev/null 2>&1
	else
		echo "No supported package manager found. Please install Git manually."
		exit 1
	fi
}

# Check if Git is installed
if ! git --version >/dev/null 2>&1; then
	echo "Git is not installed."
	setup_git
fi

# Check if GitHub CLI is installed
if gh --version >/dev/null 2>&1; then
	gh_installed=true
fi

# Usage function to display help
usage() {
	echo "${BOLD}Usage:${RESET}"
	echo "  $(basename "$0" .sh) [branch_name]"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script helps manage Git branches"
	echo "  by switching to the default branch,"
	echo "  or creating new branches"
	echo "  locally and remotely if needed."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  [branch_name]      Switch to the specified branch"
	echo "                     or create it if it doesn't exist."
	echo
	echo "  --help             Display this help message."
	echo
	echo "  No arguments means to switch to the default branch,"
	echo "  or prompt to create a new branch named after the current unix user."
	exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Check if the current directory is a Git repository
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# Check if it has a remote
if git remote -v >/dev/null 2>&1; then
  has_remote=true
fi

if [ "$is_a_git_repo" = "true" ]; then
	current_branch=$(git branch | awk '/\*/ {print $2}')

	if [ "$has_remote" ]; then
		default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
		repo_url=$(git config --get remote.origin.url)
		repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"
	else
		default_branch=$(git config --get init.defaultBranch)
		repo_name=$(basename "$(git rev-parse --show-toplevel)")
	fi

	if [ -z "$default_branch" ]; then
		default_branch=$(git config --get init.defaultBranch)
	fi

	if [ $# -eq 0 ]; then
		if [ "$current_branch" != "$default_branch" ]; then
			git checkout "$default_branch"
		else
			user="$(whoami)"
			if ! git rev-parse --verify "$user" >/dev/null 2>&1; then
				check_new_branch() {
					printf "${BOLD}${WHITE}New branch${GREEN} "$user"${WHITE} ? (y/n) "
					read branch
					if [ "$branch" = "y" ]; then
						git checkout -b "$user" >/dev/null 2>&1

						# check for remote
						if [ "$has_remote" ] && [ "$gh_installed" = "true" ]; then
							check_new_remote_branch() {
								printf "${BOLD}${WHITE}Add${GREEN} "$user"${WHITE} branch to ${LIGHT_BLUE}$repo_name ${WHITE}on GitHub ? (y/n) "
								read remote_branch
								if [ "$remote_branch" = "y" ]; then
									git push origin "$user"
								elif [ "$remote_branch" = "n" ]; then
									return 0
								else
									check_new_remote_branch
								fi
							}

							# Check for internet connectivity to GitHub
							if $SUDO ping -c 1 github.com &>/dev/null; then
								check_new_remote_branch
							else
								echo "${BOLD} ■■▶ Cannot push to remote branch, you are offline !${RESET}"
							fi
						fi
					elif [ "$branch" = "n" ]; then
						return 0
					else
						check_new_branch
					fi
				}
				check_new_branch
			else
				git checkout "$user"
			fi
		fi
	elif [ $# -eq 1 ]; then
		# check if the branch doesn't exist yet
		if ! git rev-parse --verify "$1" >/dev/null 2>&1; then
			new_branch="$1"
			check_new_branch() {
				printf "${BOLD}${WHITE}New branch${GREEN} "$new_branch"${WHITE} ? (y/n) "
				read branch
				if [ "$branch" = "y" ]; then
					git checkout -b "$new_branch" >/dev/null 2>&1

					# check for remote
					if [ "$has_remote" ]; then
						check_new_remote_branch() {
							printf "${BOLD}${WHITE}Add${GREEN} "$new_branch"${WHITE} branch to ${LIGHT_BLUE}$repo_name ${WHITE} on GitHub ? (y/n) "
							read remote_branch
							echo ${RESET}
							if [ "$remote_branch" = "y" ]; then
								git push origin "$new_branch"
							elif [ "$remote_branch" = "n" ]; then
								return 0
							else
								check_new_remote_branch
							fi
						}

						# Check for internet connectivity to GitHub
						if $SUDO ping -c 1 github.com &>/dev/null; then
							check_new_remote_branch
						else
							echo "${BOLD} ■■▶ Cannot push to remote branch, you are offline !${RESET}"
						fi
					fi
				elif [ "$branch" = "n" ]; then
					return 0
				else
					check_new_branch
				fi
			}
			check_new_branch
		else
			git checkout "$1"
		fi
	else
		echo "${BOLD} ■■▶ Usage : gck branch or gck (switch default branch)"
	fi
else
	echo "${BOLD} ■■▶ This won't work, you are not in a git repo !"
fi
