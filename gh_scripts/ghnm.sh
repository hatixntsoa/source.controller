#!/bin/bash

function ghnm {
  # Check if we are inside a git repo
  if ! load_and_delete \
    "${BOLD} Checking the ${GREEN}local ${RESET_COLOR}git" \
		"${LIGHT_BLUE}repo ${RESET_COLOR}" \
    "is_a_git_repo"; then
    echo "${BOLD} This won't work, you are not in a git repo !"
    return 0
  fi

  # Check if the repo has a remote
  if ! load_and_delete \
    "${BOLD} Checking the ${GREEN}remote ${RESET_COLOR}git" \
		"${LIGHT_BLUE}repo ${RESET_COLOR}on GitHub" \
    "has_remote"; then
    echo "${BOLD} This repo has no remote on GitHub !"
    return 0
  fi

  # Define the new name of the repo
  new_name="$1"
  repo_url=$(git config --get remote.origin.url)
  repo_name=$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')

  if [ "$new_name" == "$repo_name" ]; then
    echo "${BOLD} The ${GREEN}remote ${RESET_COLOR}repo name is" \
      "${LIGHT_BLUE}$repo_name ${RESET}"
    return 0
  fi

  execute_with_loading \
    "${BOLD} Renaming ${GREEN}remote ${RESET_COLOR}repo" \
    "${LIGHT_BLUE}$repo_name ${RESET_COLOR}to ${LIGHT_BLUE}$new_name ${RESET}... " \
    "gh repo rename "$new_name" --yes"
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
source "$UTILS_DIR/check_gh.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_remote.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/check_user.sh"
source "$UTILS_DIR/clean_repo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/loading.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${ghnm_arguments[@]}"
  show_help "Description" "${ghnm_descriptions[@]}"
  show_help "Options" "${ghnm_options[@]}"
  show_help "Example" "${ghnm_extras[@]}"
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

# Call ghc function
ghnm "$@"