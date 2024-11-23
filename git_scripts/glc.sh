#!/bin/bash

function glc {
  if is_a_git_repo; then
    has_commits=$(git log > /dev/null 2>&1 && echo "true" || echo "false")

    if [ "$has_commits" = "true" ]; then
      repo_name=$(basename "$(git rev-parse --show-toplevel)")
      current_branch=$(git branch | awk '/\*/ {print $2}');
      commits_num=$(git log --oneline | wc -l);
      last_commit=$(git log --format="%H" -n 1);
      last_commit_message=$(git show --format=%B -s "$last_commit" | head -n 1);
      last_commit_author=$(git log --format='%an' -n 1)
      current_user=$(git config user.name)
      commits_done_today=$(git log --oneline --since="$(date +"%Y-%m-%d 00:00:00")" --author="$current_user" | wc -l)
      commits_contrib_today=$(git log --oneline --since="$(date +"%Y-%m-%d 00:00:00")" --author="$last_commit_author" | wc -l)

      [ $commits_num -le 1 ] && commit_text="commit" || commit_text="commits";
      [ $commits_done_today -le 1 ] && commit_done_text="commit" || commit_done_text="commits";
      [ $commits_contrib_today -le 1 ] && commit_contrib_text="commit" || commit_contrib_text="commits";
      [ $commits_done_today -gt 0 ] &&
        commit_done="${RESET_COLOR}Including ${LIGHT_BLUE}$commits_done_today $commit_done_text ${RESET_COLOR}by ${GREEN}$current_user ${RESET_COLOR}today" ||
        commit_done="${RESET_COLOR}Including ${LIGHT_BLUE}$commits_contrib_today $commit_contrib_text ${RESET_COLOR}by ${GREEN}$last_commit_author ${RESET_COLOR}today"

      if [ "$1" = "show" ]; then
        git log --oneline --no-decorate;
      else
        echo "${BOLD}${LIGHT_BLUE} $repo_name ${RESET_COLOR}has ${LIGHT_BLUE}$commits_num $commit_text ";
        echo " $commit_done";
        echo "${BOLD}${RESET_COLOR} Last Commit on ${GREEN}$current_branch ${RESET_COLOR}: $last_commit_message";
        echo
      fi
    else
      echo "${BOLD} ■■▶ Sorry, no commits yet inside this repo !";
    fi
  else
    echo "${BOLD} ■■▶ This won't work, you are not in a git repo !";
  fi
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"
CATEGORY="git_scripts"

HELPS_DIR="$PARENT_DIR/helps/$CATEGORY"
HELP_FILE="$(basename "$0" .sh)_help.sh"

UTILS_DIR="$PARENT_DIR/utils"

# Import necessary variables and functions
source "$UTILS_DIR/check_git.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${glc_arguments[@]}"
	show_help "Description" "${glc_descriptions[@]}"
	show_help "Options" "${glc_options[@]}"
	show_extra "${glc_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Call glc function
glc "$@"