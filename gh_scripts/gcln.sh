#!/bin/bash

function clone_repo {
  # Default GitHub URL prefix
  GITHUB_URL="https://github.com"
  
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

  # Check if repo has not the format owner/repo
  if [[ ! "$repo" =~ $clone_regex ]]; then
    usage
  fi

  # Check if the owner exists on GitHub
	if ! is_a_github_user "$repo_owner"; then
    echo "${BOLD} Sorry, there is no user named ${GREEN}$repo_owner ${RESET_COLOR}on ${LIGHT_BLUE}GitHub !"
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

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"
CATEGORY="gh_scripts"

HELPS_DIR="$PARENT_DIR/helps/$CATEGORY"
HELP_FILE="$(basename "$0" .sh)_help.sh"

UTILS_DIR="$PARENT_DIR/utils"

# Import necessary variables and functions
source "$UTILS_DIR/check_connection.sh"
source "$UTILS_DIR/check_git.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/check_user.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${gcln_arguments[@]}"
	show_help "Description" "${gcln_descriptions[@]}"
	show_help "Options" "${gcln_options[@]}"
  exit 0
}

# regex to match clone repo case
clone_regex='^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$'

# Display help on --help flag and insifficient argument
if [[ "$1" == "--help" || "$#" -lt 1 ]]; then
  usage
fi

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Check for internet connectivity to GitHub
check_connection

# Call the function with all arguments
clone_repo "$@"