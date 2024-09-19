#!/bin/bash

# Define colors
BOLD=$'\033[1m'
RED=$'\033[31m'
GREEN=$'\033[32m'
LIGHT_BLUE=$'\033[94m'
WHITE=$'\033[97m'
RESET=$'\033[0m'

# Function to display usage
usage() {
	echo "${BOLD}Usage:${RESET}"
	echo "  $(basename "$0" .sh)"
	echo
	echo "${BOLD}Description:${RESET}"
	echo "  This script interacts with a GitHub repository"
	echo "  associated with the current local Git repository."
	echo
	echo "  It lists the collaborators and pending invitations"
	echo "  for the repository."
	echo
	echo "${BOLD}Options:${RESET}"
	echo "  --help           Display this help message."
	echo
	echo "  If no arguments are provided, the script will"
	echo "  display the list of collaborators and pending invitations."
	exit 0
}

# Check if GitHub CLI is installed
if ! gh --version >/dev/null 2>&1; then
	echo "gh is not installed."
	exit 1
fi

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# Check if it is a git repo
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# Check if it has a remote
has_remote=$(git remote -v)

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

# ghcls functions
if [ "$is_a_git_repo" = "true" ]; then
	if [ "$has_remote" ]; then
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
		repo_url=$(git config --get remote.origin.url)
		repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')
		repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"

		# check if we are not the owner of the repo
		if [ "$repo_owner" != "$current_user" ]; then
			echo "${BOLD} ■■▶ Sorry, you are not the owner of this repo !"
		else
			printf "${BOLD} ${LIGHT_BLUE}Collaborators ${WHITE}for the ${LIGHT_BLUE}$repo_name ${WHITE}repository "

			# List collaborators using gh api
			collaborators=$(gh api "repos/$current_user/$repo_name/collaborators" --jq '.[].login')
			invitations=$(gh api "repos/$current_user/$repo_name/invitations" --jq '.[].invitee.login')

			collaborators_count=$(echo "$collaborators" | wc -l)
			invitations_count=$(echo "$invitations" | wc -l)
			collaborators_num=$((collaborators_count + invitations_count))
			echo "${WHITE}${BOLD}($collaborators_count)"

			# Iterate through each collaborator
			if [ -n "$collaborators" ]; then
				echo "$collaborators" | while IFS= read -r collaborator; do
					if [ "$collaborator" = "$current_user" ]; then
						echo " ● $collaborator (owner)"
					else
						echo " ● $collaborator"
					fi
				done
			else
				echo "No collaborators found."
			fi

			# Check if there are pending invitations
			if [ -n "$invitations" ]; then
				# Print pending invitations
				echo "$invitations" | while IFS= read -r invitee; do
					echo " ● $invitee (invitation pending)"
				done
			fi
		fi
	else
		echo "${BOLD} ■■▶ This repo has no remote on GitHub !"
	fi
else
	echo "${BOLD} ■■▶ This won't work, you are not in a git repo !"
fi
