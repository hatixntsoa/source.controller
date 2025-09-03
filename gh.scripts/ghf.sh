#!/bin/bash

function ghf {
	repo="$1"
	IFS="/" read -r repo_owner repo_name <<< "$repo"
	current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
	clone_repo="--clone"

	# regex to match clone repo case
	clone_regex='^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$'

	# Check if repo has not the format owner/repo
	if [[ ! "$repo" =~ $clone_regex ]]; then
		usage
	fi

	# Check if we have already forked it
	if load_and_delete \
		"${BOLD} Checking the forked ${GREEN}repo ${RESET_COLOR} named" \
		"${LIGHT_BLUE}$current_user/$repo_name ${RESET_COLOR}on GitHub" \
	  "is_a_github_repo $current_user/$repo_name"; then
		echo "${BOLD} You have already ${RED}forked ${RESET_COLOR}the repo named" \
			"${GREEN}$repo_name ${RESET_COLOR}on ${LIGHT_BLUE}GitHub ${RESET}"
		return 0
	fi

  # Check if the owner exists on GitHub
	if ! load_and_delete \
		"${BOLD} Checking the ${GREEN}user ${RESET_COLOR}named" \
		"${LIGHT_BLUE}$repo_owner ${RESET_COLOR}on GitHub" \
		"is_a_github_user $repo_owner"; then
		echo "${BOLD} Sorry, there is ${GREEN}no user ${RESET_COLOR}named" \
				"${LIGHT_BLUE}$repo_owner ${RESET_COLOR}on GitHub ${RESET}"
			return 0
	fi

	# Check if the repo doesn't exist
	if ! load_and_delete \
		"${BOLD} Checking the ${GREEN}repo ${RESET_COLOR}named" \
		"${LIGHT_BLUE}$repo_owner/$repo_name ${RESET_COLOR}on GitHub" \
	  "is_a_github_repo $repo_owner/$repo_name"; then
		echo "${BOLD} Sorry, there is ${GREEN}no repo ${RESET_COLOR}such" \
			"${LIGHT_BLUE}$repo_owner/$repo_name ${RESET_COLOR}on GitHub ${RESET}"
		return 0
	fi

	if load_and_delete \
    "${BOLD} Checking the ${GREEN}local ${RESET_COLOR}git" \
		"${LIGHT_BLUE}repo ${RESET_COLOR}" \
    "is_a_git_repo"; then
		printf "${BOLD}${GREEN} Local Git${RESET_COLOR} repo detected," \
		 	"skipping fork clone for ${LIGHT_BLUE}$repo_name ${RESET}\n"
		clone_repo=""
	fi

	if execute_with_loading \
		"${BOLD} Forking ${LIGHT_BLUE}$repo_name ${RESET_COLOR}on GitHub" \
		"gh repo fork $repo_owner/$repo_name"; then

		if [ "$clone_repo" == "--clone" ]; then
			execute_with_loading \
				"${BOLD} Cloning fork ${LIGHT_BLUE}$repo_name ${RESET_COLOR}locally" \
				"gh repo clone $current_user/$repo_name"
		fi
	fi
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"
CATEGORY="gh.scripts"

HELPS_DIR="$PARENT_DIR/helps/$CATEGORY"
HELP_FILE="$(basename "$0" .sh)_help.sh"

UTILS_DIR="$PARENT_DIR/utils"

# Import necessary variables and functions
source "$UTILS_DIR/check_connection.sh"
source "$UTILS_DIR/check_git.sh"
source "$UTILS_DIR/check_gh.sh"
source "$UTILS_DIR/check_repo.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/check_user.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/loading.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${ghf_arguments[@]}"
  show_help "Description" "${ghf_descriptions[@]}"
  show_help "Options" "${ghf_options[@]}"
  show_help "Example" "${ghf_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Check gh
check_gh

# Check for internet connectivity to GitHub
check_connection

# Call the function with all arguments
ghf "$@"