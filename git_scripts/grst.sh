#!/bin/bash

# Define colors
BOLD=$'\033[1m'
WHITE=$'\033[97m'
RESET=$'\033[0m'
LIGHT_BLUE=$'\033[94m'

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

# Usage function to display help
usage() {
	echo "${BOLD}Usage:${RESET}"
	echo "  $(basename "$0" .sh) [option]"
	echo "  $(basename "$0" .sh) [file]"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script restores changes in a Git repository"
	echo "  based on the provided option."
	echo
	echo "  If no argument is provided, it will restore"
	echo "  all changes in the repository to the last commit."
	echo
	echo "  If 'cmt' is provided as an option, it will"
	echo "  undo the last commit (soft reset)."
	echo
	echo "  If a file is specified as an argument,"
	echo "  it will restore that file to its last committed state."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  cmt               Undo the last commit by performing a soft reset."
	echo
	echo "  [file]            Restore the specified file to its last committed state."
	echo
	echo "  --help            Display this help message."
	echo
	echo "  No arguments       Restore all changes in the repository to the last commit."
	exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# Check if the current directory is a Git repository
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

if [ "$is_a_git_repo" = "true" ]; then
	if [ $# -eq 0 ]; then
		git checkout -- .
	elif [ $1 = "cmt" ]; then
		git reset --soft HEAD~1
	else
		# Loop through each argument and check if it's a file
		for arg in "$@"; do
			if [ ! -f "$arg" ]; then
				echo "${BOLD}${WHITE} ■■▶ Sorry, only restore file(s). ${LIGHT_BLUE}'$arg'${WHITE} is not a valid file."
				exit 1
			fi
		done
		# If all arguments are valid files, restore them
		git restore "$@"
	fi
else
	echo "${BOLD}${WHITE} ■■▶ This won't work, you are not in a git repo !"
fi
