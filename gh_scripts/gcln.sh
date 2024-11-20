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
    echo "  $(basename "$0" .sh) [repo_owner]/[repo_name]"
    echo "  $(basename "$0" .sh) [repo_owner]/[repo_name] --depth=[depth_num]"
    echo "  $(basename "$0" .sh) [repo_owner]/[repo_name] -d=[depth_num]"
    echo
    echo "${BOLD}Description:${RESET}"
    echo "  This script clones a new GitHub repository"
    echo "  if given the argument owner/repo."
    echo
    echo "${BOLD}Options:${RESET}"
    echo "  [repo_owner]     The owner of the repo to clone."
    echo
    echo "  [repo_name]      Name of the GitHub repository to clone."
    echo
    echo "  --help           Display this help message."
    exit 0
}

# Display help on --help flag and insifficient argument
if [[ "$1" == "--help" || "$#" -lt 1 ]]; then
  usage
fi

# prompt for sudo
# password if required
allow_sudo

# Check for internet connectivity to GitHub
if ! $SUDO ping -c 1 github.com &>/dev/null; then
	echo "${BOLD} ■■▶ This won't work, you are offline !${RESET}"
	exit 0
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

# Default GitHub URL prefix
GITHUB_URL="https://github.com"

# Function to parse arguments and form the GitHub URL
clone_repo() {
  local depth=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --depth | -d)
        depth="$2"
        shift 2
        ;;
      *)
        # Assuming the first argument is owner/repo
        repo="$1"
        IFS="/" read -r repo_owner repo_name <<< "$repo"
        ;;
    esac
    shift
  done

  # regex to match clone repo case
  clone_regex='^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$'

  # Check if repo has not the format owner/repo
  if [[ ! "$repo" =~ $clone_regex ]]; then
    help
  fi

  # Check if the owner exists on GitHub
	if ! is_a_github_user "$repo_owner"; then
    echo "${BOLD} ■■▶ Sorry, there is no user named ${GREEN}$repo_owner ${WHITE}on ${LIGHT_BLUE}GitHub !"
    return 0
  fi

  # Construct the full GitHub clone URL
  url="$GITHUB_URL/$repo"

  # If depth is provided, use it in the git clone command
  if [[ -n "$depth" ]]; then
    git clone "$url" --depth="$depth"
  else
    git clone "$url"
  fi
}

# Call the function with all arguments
clone_repo "$@"