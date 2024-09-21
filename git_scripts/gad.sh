#!/bin/bash

# Define colors
BOLD=$'\033[1m'
RED=$'\033[31m'
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

# Check if Git is installed
if ! git --version >/dev/null 2>&1; then
	echo "Git is not installed."
	setup_git
fi

# Usage function to display help
usage() {
	echo "${BOLD}Usage:${RESET}"
	echo "  $(basename "$0" .sh) [file] [commit_message]"
	echo "  $(basename "$0" .sh) [commit_message]"
	echo "  $(basename "$0" .sh)"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script simplifies the process of adding"
	echo "  and committing changes in a Git repository."
	echo
	echo "  It allows you to specify a file to add and provides"
	echo "  a way to commit changes with or without a commit message "
	echo "  directly from the command line. "
	echo
	echo "  If no file is specified, all changes are added."
	echo "  If no commit message is provided, the default git editor"
	echo "  will open to allow for a detailed commit message."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  [file]            Path to a specific file to add and commit."
	echo "                    If omitted, all changes are added."
	echo
	echo "  [commit_message]  Commit message to use. If no commit message is provided, "
	echo "                    the default git editor will open."
	echo "                    The commit message can be enclosed in quotes "
	echo "                    (e.g., gad \"commit message\")"
	echo "                    or written without quotes (e.g., gad commit message),"
	echo "                    as long as it does not contain special characters."
	echo
	echo "  --help            Display this help message."
	echo
	echo " If no arguments are provided, all changes are added and committed"
	echo " with a message prompted in the editor."
	exit 0
}

# Check if the current directory is a Git repository
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

if [ "$is_a_git_repo" = "true" ]; then
	if [ $# -eq 0 ]; then
		# If no arguments, add all changes and commit (opens editor for commit message)
		git add --all && git commit
	elif [ $# -ge 1 ]; then
		if [ -f "$1" ]; then
			if [ $# -eq 1 ]; then
				# File is specified but no commit message
				echo "${BOLD}${RED}Error: no commit message!${RESET}"
			else
				# Add the file and commit with message from arguments 2 onwards
				git add "$1" && git commit "$1" -m "${*:2}"
			fi
		elif [ "$1" = "--help" ]; then
			# Check if the first argument is --help
			usage
		else
			# Add all changes and commit with the provided message
			git add --all && git commit -m "$*"
		fi
	fi
else
	# Check if the first argument is --help
	if [ "$1" = "--help" ]; then
		usage
	else
		echo "${BOLD} ■■▶ This won't work, you are not in a git repo!${RESET}"
	fi
fi
