#!/bin/sh

# Define colors
BOLD="\e[1m"
GREEN="\e[32m"
LIGHT_BLUE="\e[94m"
WHITE="\e[97m"
RESET="\e[0m"

# Check if GitHub CLI is installed
if ! gh --version >/dev/null 2>&1; then
  echo "gh is not installed."
  exit 1
fi

# Function to sanitize the repository name
clean_repo() {
  repo_name="$1"
  # Replace any characters that are not alphanumeric or hyphen with underscore
  printf "%s" "$repo_name" | sed -E 's/[^a-zA-Z0-9-]/_/g'
}

# check if it is a git repo
is_a_git_repo=$(git rev-parse --is-inside-work-tree 2>/dev/null)

# check if it has remote
has_remote=$(git remote -v)

# get the repo name
if [ $# -eq 0 ]; then
  repo="$(basename "$PWD")"
elif [ $# -eq 1 ]; then
  if [ "$1" != "private" ]; then
    repo="$1"
  else
    repo="$(basename "$PWD")"
    isPrivate="$1"
  fi
else
  repo="$1"
  shift
  isPrivate="$1"
fi

# clean the repo name
repo_name=$(clean_repo "$repo")
repo_visibility="public"

if [ "$isPrivate" = "private" ]; then
  repo_visibility="private"
fi

if [ "$is_a_git_repo" = "true" ]; then
  if [ -n "$has_remote" ]; then
    printf "${BOLD}■■▶ This repo already has a remote on GitHub!${RESET}\n"
  else
    current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)

    check_set_repo() {
      printf "${BOLD}${WHITE} Create ${GREEN}$repo_visibility ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
      read set_repo
      if [ "$set_repo" = "y" ]; then
        # Create the repo & set it as remote of the local one
        printf "${BOLD} New repository ${LIGHT_BLUE}$repo_name ${WHITE}on GitHub ... ${RESET}"
        gh repo create "$repo_name" --"$repo_visibility" &>/dev/null
        git remote add origin "git@github.com:$current_user/$repo_name.git"
        printf "${BOLD}${GREEN} ${RESET}\n"

        check_push() {
          printf "${BOLD}${WHITE} Push local commits to ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
          read check_push_commit

          if [ "$check_push_commit" = "y" ]; then
            current_branch=$(git branch | awk '/\*/ {print $2}')
            git push origin "$current_branch"
          elif [ "$check_push_commit" = "n" ]; then
            return 0
          else
            check_push
          fi
        }

        current_branch=$(git branch | awk '/\*/ {print $2}')

        if git rev-list --count "$current_branch" 2>/dev/null | grep -q '^[1-9]'; then
          check_push
        fi
      elif [ "$set_repo" = "n" ]; then
        return 0
      else
        check_set_repo
      fi
    }
    check_set_repo
  fi
else
  check_create_repo() {
    printf "${BOLD}${WHITE} Create ${GREEN}$repo_visibility ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
    read create_repo
    if [ "$create_repo" = "y" ]; then
      # Create the repo & clone it locally
      printf "${BOLD} New repository ${LIGHT_BLUE}$repo_name ${WHITE}on GitHub ... ${RESET}"
      gh repo create "$repo_name" --"$repo_visibility" -c &>/dev/null
      mv "$repo_name/.git" . && rm -rf "$repo_name"
      printf "${BOLD}${GREEN} ${RESET}\n"
    elif [ "$create_repo" = "n" ]; then
      check_local() {
        printf "${BOLD}${WHITE} Create ${GREEN}local ${WHITE}repo ${LIGHT_BLUE}$repo_name ${WHITE}? (y/n) ${RESET}"
        read create_local

        if [ "$create_local" = "y" ]; then
          git init &>/dev/null
        elif [ "$create_local" = "n" ]; then
          return 0
        else
          check_local
        fi
      }
      check_local
    else
      check_create_repo
    fi
  }
  check_create_repo
fi