#!/bin/sh

# Define colors
BOLD="\e[1m"
RESET="\e[0m"
LIGHT_BLUE="\e[34m"
WHITE="\e[37m"
GREEN="\e[32m"

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
  echo
  echo "${BOLD}Description:${RESET}"
  echo "  This script provides information about the current Git repository."
  echo "  It displays details such as the number of commits, recent commit"
  echo "  messages, and the number of commits made today by the current user."
  echo
  echo "${BOLD}Options:${RESET}"
  echo "  show              Display the git log in a simplified format."
  echo
  echo "  --help            Display this help message."
  echo
  echo "  No arguments are required to display repository statistics."
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# Check if the current directory is a Git repository
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

if [ "$is_a_git_repo" = "true" ]; then
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
      commit_done="${WHITE}Including ${LIGHT_BLUE}$commits_done_today $commit_done_text ${WHITE}by ${GREEN}$current_user ${WHITE}today" ||
      commit_done="${WHITE}Including ${LIGHT_BLUE}$commits_contrib_today $commit_contrib_text ${WHITE}by ${GREEN}$last_commit_author ${WHITE}today"

    if [ "$1" = "show" ]; then
      git log --oneline --no-decorate;
    else
      echo "${BOLD}${LIGHT_BLUE} $repo_name ${WHITE}has ${LIGHT_BLUE}$commits_num $commit_text ";
      echo " $commit_done";
      echo "${BOLD}${WHITE} Last Commit on ${GREEN}$current_branch ${WHITE}: $last_commit_message";
      echo
    fi
  else
    echo "${BOLD} ■■▶ Sorry, no commits yet inside this repo !";
  fi
else
  echo "${BOLD} ■■▶ This won't work, you are not in a git repo !";
fi