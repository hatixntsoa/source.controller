#!/bin/bash

function ghc {
	# Get the repo name and visibility
	if [ $# -eq 0 ]; then
		repo="$(basename "$PWD")"
		repo_visibility="public"
	elif [ $# -eq 1 ]; then
		if [ "$1" = "private" ]; then
			repo="$(basename "$PWD")"
			repo_visibility="private"
		else
			repo="$1"
			repo_visibility="public"
		fi
	elif [ $# -eq 2 ]; then
		repo="$1"
		repo_visibility="$2"
	else
		echo "${BOLD}${RED}Error: Too many arguments.${RESET}"
		usage
	fi

	# Clean the repo name
	repo_name=$(clean_repo "$repo")

	if is_a_git_repo; then
		if has_remote; then
			printf "${BOLD} This repo already has a remote on GitHub!${RESET}\n"
			return 0
		fi
		
		current_user=$(awk '/user:/ {print $2; exit}' ~/.config/gh/hosts.yml)

		check_set_repo() {
			printf "${BOLD}${RESET_COLOR} Create ${GREEN}$repo_visibility ${RESET_COLOR}repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}? (y/n) ${RESET}"
			read set_repo
			if [ "$set_repo" = "y" ]; then
				# Create the repo & set it as remote of the local one
				printf "${BOLD} New repository ${LIGHT_BLUE}$repo_name ${RESET_COLOR}on GitHub ... ${RESET}"
				gh repo create "$repo_name" --"$repo_visibility" &>/dev/null
				git remote add origin "git@github.com:$current_user/$repo_name.git"
				printf "${BOLD}${GREEN} ${RESET}\n"

				check_push() {
					printf "${BOLD}${RESET_COLOR} Push local commits to ${LIGHT_BLUE}$repo_name ${RESET_COLOR}? (y/n) ${RESET}"
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
	else
		# Check for internet connectivity to GitHub
		if ! connected; then
			echo "${BOLD} Sorry, you are offline !${RESET}"
			check_local() {
				printf "${BOLD}${RESET_COLOR} Create ${GREEN}local ${RESET_COLOR}repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}? (y/n) ${RESET}"
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
			check_create_repo() {
				printf "${BOLD}${RESET_COLOR} Create ${GREEN}$repo_visibility ${RESET_COLOR}repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}? (y/n) ${RESET}"
				read create_repo
				if [ "$create_repo" = "y" ]; then
					# Create the repo & clone it locally
					printf "${BOLD} New repository ${LIGHT_BLUE}$repo_name ${RESET_COLOR}on GitHub ... ${RESET}"
					gh repo create "$repo_name" --"$repo_visibility" -c &>/dev/null
					mv "$repo_name/.git" . && rm -rf "$repo_name"
					printf "${BOLD}${GREEN} ${RESET}\n"
				elif [ "$create_repo" = "n" ]; then
					check_local() {
						printf "${BOLD}${RESET_COLOR} Create ${GREEN}local ${RESET_COLOR}repo ${LIGHT_BLUE}$repo_name ${RESET_COLOR}? (y/n) ${RESET}"
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
source "$UTILS_DIR/check_gh.sh"
source "$UTILS_DIR/setup_git.sh"
source "$UTILS_DIR/check_remote.sh"
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/check_user.sh"
source "$UTILS_DIR/clean_repo.sh"
source "$UTILS_DIR/colors.sh"
source "$UTILS_DIR/usage.sh"

# Import help file
source "$HELPS_DIR/$HELP_FILE"

# Usage function to display help
function usage {
  show_help "Usage" "${ghc_arguments[@]}"
  show_help "Description" "${ghc_descriptions[@]}"
  show_help "Options" "${ghc_options[@]}"
  show_extra "${ghc_extras[@]}"
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
ghc "$@"