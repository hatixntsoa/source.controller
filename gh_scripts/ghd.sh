#!/bin/sh

# Define colors
BOLD="\e[1m"
GREEN="\e[32m"
LIGHT_BLUE="\e[94m"
WHITE="\e[97m"
RESET="\e[0m"

# Function to display usage
usage() {
  echo "${BOLD}Usage:${RESET}"
  echo "  $(basename "$0" .sh)"
  echo
  echo "${BOLD}Description:${RESET}"
  echo "  Deletes a local and/or remote GitHub repository."
  echo
  echo "${BOLD}Options:${RESET}"
  echo "  --help           Display this help message."
  echo
  exit 0
}

# Function to sanitize the repository name
clean_repo() {
  repo_name="$1"
  # Replace any characters that are not alphanumeric or hyphen with underscore
  printf "%s" "$repo_name" | sed -E 's/[^a-zA-Z0-9-]/_/g'
}

# Check if GitHub CLI is installed
if ! gh --version >/dev/null 2>&1; then
  echo "gh is not installed."
  exit 1
fi

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# Function to delete local repo
delete_local_repo() {
  printf "${BOLD}${WHITE} Delete ${GREEN}local ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
  read delete_local_repo
  if [ "$delete_local_repo" = "y" ]; then
    local repo_source=$(git rev-parse --show-toplevel)
    printf "${BOLD} Deleting ${GREEN}local ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}... ${RESET}"
    rm -rf "$repo_source/.git"
    echo "${BOLD}${GREEN}✓${RESET}"
  elif [ "$delete_local_repo" = "n" ]; then
    return 0
  else
    delete_local_repo
  fi
}

# Function to delete GitHub repo
delete_repo() {
  printf "${BOLD}${WHITE} Delete ${GREEN}$repo_visibility ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
  read delete_repo
  if [ "$delete_repo" = "y" ]; then
    printf "${BOLD} Deleting repository ${LIGHT_BLUE}$repo_name ${WHITE}on GitHub ... ${RESET}"
    gh repo delete "$repo_name" --yes &>/dev/null
    git remote remove origin
    echo "${BOLD}${GREEN}✓${RESET}"
    delete_local_repo
  elif [ "$delete_repo" = "n" ]; then
    return 0
  else
    delete_repo
  fi
}

# Check if it is a git repo
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

if [ "$is_a_git_repo" = "true" ]; then
  has_remote=$(git remote -v)

  if [ -n "$has_remote" ]; then
    repo_url=$(git config --get remote.origin.url)
    current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
    repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')

    if [ "$repo_owner" != "$current_user" ]; then
      echo "${BOLD} ■■▶ Sorry, you are not the owner of this repo!${RESET}"
    else
      repo_name=$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')
      isPrivate=$(gh repo view "$repo_name" --json isPrivate --jq '.isPrivate')
      repo_visibility=$( [ "$isPrivate" = "true" ] && echo "private" || echo "public" )

      delete_repo
    fi
  else
    repo_name=$(basename "$(git rev-parse --show-toplevel)")
    delete_local_repo
  fi
else
  echo "${BOLD} ■■▶ This won't work, you are not in a git repo!${RESET}"
fi