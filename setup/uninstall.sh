#!/bin/bash

# Get the binary path for linking
binary_path=$(whereis sh | grep -o '/[^ ]*/bin' | head -n 1)

# Get the source directory of the repo
repo_source=$(git rev-parse --show-toplevel)

# Define paths to script directories
git_scripts_path="$repo_source/git_scripts"
gh_scripts_path="$repo_source/gh_scripts"

# Function to extract script name without the .sh extension
function get_script_name {
	basename "$1" .sh
}

# Function to uninstall scripts
function uninstall_scripts {
	local script_dir="$1"
	local script_type="$2"

	for script in "$script_dir"/*; do
		if [ -x "$script" ]; then
			script_name=$(get_script_name "$script")
			link_path="$binary_path/$script_name"

			printf " ● Uninstalling ${BOLD}${LIGHT_BLUE}$script_name${RESET}..."

			if [ -L "$link_path" ]; then
				$SUDO rm "$link_path"
				printf "${BOLD}${RED} ${RESET}"
			else
				printf " ● ${BOLD}${RED}Not Installed ${RESET}"
			fi
		else
			printf " ● ${RESET}Skipping ${LIGHT_BLUE}${BOLD}$script ${RESET}${RESET}: Not executable."
		fi
		echo
	done
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"

UTILS_DIR="$PARENT_DIR/utils"

# Import necessary variables and functions
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/colors.sh"

# prompt for sudo
# password if required
allow_sudo
echo

# Uninstall git scripts
echo "${RESET}   Uninstalling ${BOLD}Git Scripts${RESET}...${RESET}"
uninstall_scripts "$git_scripts_path" "git"
echo

# Uninstall gh scripts
echo "${RESET}   Uninstalling ${BOLD}Gh Scripts${RESET}...${RESET}"
uninstall_scripts "$gh_scripts_path" "gh"
echo