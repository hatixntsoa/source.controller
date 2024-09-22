#!/bin/bash

# Define colors
BOLD=$'\033[1m'
RED=$'\033[31m'
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

# this will check for sudo permission
allow_sudo() {
	if [ -n "$SUDO" ]; then
		$SUDO -n true 2>/dev/null
		if [ $? -ne 0 ]; then
			$SUDO -v
		fi
	fi
}

# Check if Git is installed
if ! git --version >/dev/null 2>&1; then
	echo "Git is not installed."
	setup_git
fi

# Usage function to display help
usage() {
	echo "${BOLD}Usage:${RESET}"
	echo "  $(basename "$0" .sh)"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script simplifies the process of pulling"
	echo "  remote commits to local Git repository."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  --help            Display this help message."
	echo
	echo "  No arguments are required. Just run the script to pull changes."
	exit 0
}

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

# Check if the current directory is a Git repository
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# Check if it has a remote
if git remote -v >/dev/null 2>&1; then
  has_remote=true
fi

if [ "$is_a_git_repo" = "true" ]; then
	if [ -n "$has_remote" ]; then
		repo_url=$(git config --get remote.origin.url)
		repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"
	else
		repo_name=$(basename "$(git rev-parse --show-toplevel)")
	fi
	
	current_branch=$(git branch | awk '/\*/ {print $2}')

	# check if it has a remote to push
	if [ -n "$has_remote" ]; then
		is_remote_branch=$(git branch -r | grep "origin/$current_branch")

		# check if the current branch has remote
		if [ -n "$is_remote_branch" ]; then
			git pull origin $current_branch
		else
			echo "${BOLD} ■■▶ The remote repo ${LIGHT_BLUE}$repo_name ${WHITE}has no branch named ${GREEN}$current_branch ${WHITE}!"
		fi
	else
		echo "${BOLD} The repo ${LIGHT_BLUE}$repo_name ${WHITE}has ${RED}no remote"
	fi
else
	echo "${BOLD} ■■▶ This won't work, you are not in a git repo !"
fi
