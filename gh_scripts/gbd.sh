#!/bin/sh

# Define colors
BOLD="\033[1m"
GREEN="\033[32m"
WHITE="\033[97m"
RESET="\033[0m"

# Function to display usage
usage() {
  echo "${BOLD}Usage:${RESET}"
  echo "  $(basename "$0" .sh) [branch_to_delete]"
  echo
  echo "${BOLD}Description:${RESET}"
  echo "  This script deletes a specified Git branch or the current branch if no"
  echo "  branch name is provided. It will prompt for confirmation before deleting"
  echo "  the branch, and will also handle deletion of remote branches if they exist."
  echo "  The branch to be deleted cannot be the default branch of the repository."
  echo
  echo "${BOLD}Options:${RESET}"
  echo "  [branch_to_delete]  Name of the branch to delete."
  echo "                      If omitted, the current branch is deleted."
  echo "                      The branch cannot be the default"
  echo "                      branch of the repository."
  echo
  echo "  --help              Display this help message."
  echo
  echo " If no arguments are provided, the current branch" 
  echo " will be deleted if it's not the default branch."
  exit 0
}

# Check if GitHub CLI is installed
if ! gh --version >/dev/null 2>&1; then
  echo "gh is not installed."
  exit 1
fi

# Function to delete a branch
delete_branch() {
  branch_name="$1"
  printf "${BOLD}${WHITE}Delete branch ${GREEN}$branch_name${WHITE}? (y/n) ${RESET}"
  read delete_branch

  case "$delete_branch" in
    y|Y)
      # Switch to default branch if necessary
      if [ "$current_branch" != "$default_branch" ]; then
        git checkout "$default_branch" >/dev/null
      fi

      # Delete remote branch if exists
      if [ -n "$has_remote" ]; then
        if git branch -r | grep -q "origin/$branch_name"; then
          printf "${BOLD}${WHITE}Delete remote branch ${GREEN}$branch_name${WHITE}? (y/n) ${RESET}"
          read delete_remote_branch
          case "$delete_remote_branch" in
            y|Y)
              git push origin --delete "$branch_name"
              ;;
          esac
        fi
      fi

      # Delete local branch
      git branch -D "$branch_name"
      ;;
    n|N)
      return 0
      ;;
    *)
      delete_branch "$branch_name"
      ;;
  esac
}

# Main function
gbd() {
  is_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  has_remote=$(git remote -v 2>/dev/null)
  current_branch=$(git branch --show-current 2>/dev/null)
  default_branch=$(git symbolic-ref --short HEAD 2>/dev/null || git config --get init.defaultBranch)

  if [ "$is_git_repo" != "true" ]; then
    printf "${BOLD}■■▶ Not a Git repository!${RESET}\n"
    return 1
  fi

  if [ "$1" = "--help" ]; then
    usage
  fi

  if [ "$#" -eq 1 ]; then
    if [ "$1" = "$default_branch" ]; then
      printf "${BOLD}■■▶ Cannot delete the default branch!${RESET}\n"
      return 1
    elif ! git show-ref --verify --quiet "refs/heads/$1"; then
      printf "${BOLD}■■▶ Branch ${GREEN}$1${WHITE} does not exist!${RESET}\n"
      return 1
    else
      delete_branch "$1"
    fi
  elif [ "$#" -eq 0 ]; then
    if [ "$current_branch" = "$default_branch" ]; then
      printf "${BOLD}■■▶ Cannot delete the default branch!${RESET}\n"
      return 1
    else
      delete_branch "$current_branch"
    fi
  else
    printf "${BOLD}■■▶ Usage: gbd [branch_to_delete]${RESET}\n"
    return 1
  fi
}

# Call the gbd function with passed arguments
gbd "$@"