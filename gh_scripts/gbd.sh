#!/bin/bash

function gbd {
	if is_a_git_repo; then
		current_branch=$(git branch | awk '/\*/ {print $2}')
		default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)

		if [ -z "$default_branch" ]; then
			default_branch=$(git config --get init.defaultBranch)
		fi

		if [ $# -eq 1 ]; then
			if [ "$1" = "$default_branch" ]; then
				echo "${BOLD} ■■▶ Fatal ! Cannot Delete the Default Branch "
			elif ! git show-ref --verify --quiet "refs/heads/$1" &>/dev/null; then
				echo "${BOLD} ■■▶ Fatal ! Branch ${GREEN}$1 ${RESET_COLOR}doesn't exist ${RESET}"
			else
				# this to check if we want to delete the remote branch too
				check_delete_remote_branch() {
					if [ "$current_branch" = "$default_branch" ]; then
						echo "${BOLD} ■■▶ Fatal ! Cannot Delete the Default Branch "
					else
						printf "${BOLD}${RESET_COLOR}Delete remote branch${GREEN} "$current_branch"${RESET_COLOR} ? (y/n) ${RESET}"
						read delete_remote_branch
						echo ${RESET}
						if [ "$delete_remote_branch" = "y" ]; then
							git push origin --delete "$current_branch"
						elif [ "$delete_remote_branch" = "n" ]; then
							return 0
						else
							check_delete_remote_branch
						fi
					fi
				}

				check_delete_branch() {
					branch_name="$1"

					printf "${BOLD}${RESET_COLOR}Delete branch${GREEN} "$branch_name"${RESET_COLOR} ? (y/n) ${RESET}"
					read delete_branch

					if [ "$delete_branch" = "y" ]; then
						if [ "$current_branch" != "$default_branch" ]; then
							git checkout $default_branch >/dev/null 2>&1
						fi

						if has_remote; then
							repo_url=$(git config --get remote.origin.url)
							repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')

							# check if we are not the owner of the repo
							if [ "$repo_owner" == "$current_user" ]; then
								is_remote_branch=$(git branch -r | grep "origin/$1")
								if [ -n "$is_remote_branch" ]; then
									# prompt for sudo
									# password if required
									allow_sudo

									# Check for internet connectivity to GitHub
									if $SUDO ping -c 1 github.com &>/dev/null; then
										check_delete_remote_branch
									fi
								fi
							fi
						fi	
						git branch -D "$1"
					elif [ "$delete_branch" = "n" ]; then
						return 0
					else
						check_delete_branch $branch_name
					fi
				}
				check_delete_branch $1
			fi
		elif [ $# -eq 0 ]; then
			if [ "$current_branch" = "$default_branch" ]; then
				echo "${BOLD}${RESET_COLOR} ■■▶ Fatal ! Cannot Delete the Default Branch "
			else
				check_delete_branch() {
					printf "${BOLD}${RESET_COLOR}Delete branch${GREEN} "$current_branch"${RESET_COLOR} ? (y/n) ${RESET}"
					read delete_branch
					if [ "$delete_branch" = "y" ]; then
						# TODO : Remote branch Deletion
						check_delete_remote_branch() {
							if [ "$current_branch" = "$default_branch" ]; then
								echo "${BOLD}${RESET_COLOR} ■■▶ Fatal ! Cannot Delete the Default Branch "
							else
								printf "${BOLD}${RESET_COLOR}Delete remote branch${GREEN} "$current_branch"${RESET_COLOR} ? (y/n) ${RESET}"
								read delete_remote_branch
								echo ${RESET}
								if [ "$delete_remote_branch" = "y" ]; then
									git push origin --delete "$current_branch"
								elif [ "$delete_remote_branch" = "n" ]; then
									return 0
								else
									check_delete_remote_branch
								fi
							fi
						}

						git checkout "$default_branch" >/dev/null 2>&1

						if has_remote; then
							repo_url=$(git config --get remote.origin.url)
							repo_owner=$(echo "$repo_url" | awk -F '[/:]' '{print $(NF-1)}')

							# check if we are not the owner of the repo
							if [ "$repo_owner" == "$current_user" ]; then
								is_remote_branch=$(git branch -r | grep "origin/$current_branch")
								
								if [ -n "$is_remote_branch" ]; then
									# prompt for sudo
									# password if required
									allow_sudo

									# Check for internet connectivity to GitHub
									if $SUDO ping -c 1 github.com &>/dev/null; then
										check_delete_remote_branch
									fi
								fi
							fi
						fi
						git branch -D "$current_branch"
					elif [ "$delete_branch" = "n" ]; then
						return 0
					else
						check_delete_branch
					fi
				}
				check_delete_branch
			fi
		else
			echo "${BOLD}${RESET_COLOR} ■■▶ Usage : gbd branch_to_delete"
		fi
	else
		echo "${BOLD}${RESET_COLOR} ■■▶ This won't work, you are not in a git repo !"
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
source "$UTILS_DIR/check_remote.sh"
source "$UTILS_DIR/check_git.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${gbd_arguments[@]}"
	show_help "Description" "${gbd_descriptions[@]}"
	show_help "Options" "${gbd_options[@]}"
	show_extra "${gbd_extras[@]}"
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

# Call gbd function
gbd "$@"