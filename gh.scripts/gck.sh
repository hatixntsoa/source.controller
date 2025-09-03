#!/bin/bash

# WARNING : 03-30-2025 02:18
# Specify the base branch
# when trying to create feature
# branches with the following commands
# git switch -c new-branch old-branch
# git push -u origin new-branch

function gck {
	if ! is_a_git_repo; then
		echo "${BOLD} This won't work, you are not in a git repo !"
		return 0
	fi

	current_branch=$(git branch | awk '/\*/ {print $2}')

	if has_remote; then
		default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
		repo_url=$(git config --get remote.origin.url)
		repo_name="$(echo "$repo_url" | awk -F '/' '{print $NF}' | sed 's/.git$//')"
		repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)
	else
		default_branch=$(git config --get init.defaultBranch)
		repo_name=$(basename "$(git rev-parse --show-toplevel)")
	fi

	if [ -z "$default_branch" ]; then
		default_branch=$(git config --get init.defaultBranch)
	fi

	if [ $# -eq 0 ]; then
		if [ "$current_branch" != "$default_branch" ]; then
			git checkout "$default_branch"
		else
			user="$(whoami)"
			if ! is_a_git_branch "$user"; then
				check_new_branch() {
					printf "${BOLD}${RESET_COLOR}New branch${GREEN} "$user"${RESET_COLOR} ? (y/n) "
					read branch
					if [ "$branch" = "y" ]; then
						git checkout -b "$user" >/dev/null 2>&1

						# check for remote
						if has_remote && gh_installed; then
							check_new_remote_branch() {
								printf "${BOLD}${RESET_COLOR}Add${GREEN} "$user"${RESET_COLOR} branch to ${LIGHT_BLUE}$repo_name ${RESET_COLOR}on GitHub ? (y/n) "
								read remote_branch
								if [ "$remote_branch" = "y" ]; then
									git push origin "$user"
								elif [ "$remote_branch" = "n" ]; then
									return 0
								else
									check_new_remote_branch
								fi
							}

							# check if we are not the owner of the repo
							if [ "$repo_owner" == "$current_user" ]; then
								# Check for internet connectivity to GitHub
								if $SUDO ping -c 1 github.com &>/dev/null; then
									check_new_remote_branch
								else
									echo "${BOLD} Cannot push to remote branch, you are offline !${RESET}"
								fi
							fi
						fi
					elif [ "$branch" = "n" ]; then
						return 0
					else
						check_new_branch
					fi
				}
				check_new_branch
			else
				git checkout "$user"
			fi
		fi
	elif [ $# -eq 1 ]; then
		# check if the branch doesn't exist yet
		if ! is_a_git_branch "$1" >/dev/null 2>&1; then
			new_branch="$1"
			check_new_branch() {
				printf "${BOLD}${RESET_COLOR}New branch${GREEN} "$new_branch"${RESET_COLOR} ? (y/n) "
				read branch
				if [ "$branch" = "y" ]; then
					git checkout -b "$new_branch" >/dev/null 2>&1

					# check for remote
					if has_remote; then
						check_new_remote_branch() {
							printf "${BOLD}${RESET_COLOR}Add${GREEN} "$new_branch"${RESET_COLOR} branch to ${LIGHT_BLUE}$repo_name ${RESET_COLOR} on GitHub ? (y/n) "
							read remote_branch
							echo ${RESET}
							if [ "$remote_branch" = "y" ]; then
								git push origin "$new_branch"
							elif [ "$remote_branch" = "n" ]; then
								return 0
							else
								check_new_remote_branch
							fi
						}

						# check if we are not the owner of the repo
						if [ "$repo_owner" == "$current_user" ]; then
							# Check for internet connectivity to GitHub
							if $SUDO ping -c 1 github.com &>/dev/null; then
								check_new_remote_branch
							else
								echo "${BOLD} Cannot push to remote branch, you are offline !${RESET}"
							fi
						fi
					fi
				elif [ "$branch" = "n" ]; then
					return 0
				else
					check_new_branch
				fi
			}
			check_new_branch
		else
			git checkout "$1"
		fi
	else
		echo "${BOLD} Usage : gck branch or gck (switch default branch)"
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
source "$UTILS_DIR/check_remote.sh"
source "$UTILS_DIR/check_git.sh"
source "$UTILS_DIR/check_gh.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_branch.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${gck_arguments[@]}"
  show_help "Description" "${gck_descriptions[@]}"
  show_help "Options" "${gck_options[@]}"
  show_extra "${gck_extras[@]}"
  exit 0
}

# Check if --help is the first argument
[ "$1" = "--help" ] && usage

# prompt for sudo
# password if required
allow_sudo

# Setting up git
setup_git

# Check for internet connectivity to GitHub
check_connection

# Call gck function
gck "$@"
