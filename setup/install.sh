#!/bin/bash

# Get the binary path for linking
binary_path=$(whereis sh | grep -o '/[^ ]*/bin' | head -n 1)

# Get the source directory of the repo
repo_source=$(git rev-parse --show-toplevel)

# Define paths to script directories
git_scripts_path="$repo_source/git.scripts"
gh_scripts_path="$repo_source/gh.scripts"

# Function to extract script name without the .sh extension
function get_script_name {
	basename "$1" .sh
}

# Function to install scripts
function install_scripts {
	local script_dir="$1"
	local script_type="$2"

	for script in "$script_dir"/*; do
		if [ -x "$script" ]; then
			script_name=$(get_script_name "$script")
			symlink_path="$binary_path/$script_name"

			if [ -L "$symlink_path" ]; then
				printf " ● ${BOLD}${LIGHT_BLUE}$script_name ${RESET}${RESET}already installed."
			else
				printf " ● Installing ${BOLD}${LIGHT_BLUE}$script_name${RESET}..."
				$SUDO ln -s "$script" "$symlink_path"
				printf "${BOLD}${GREEN} ${RESET}"
			fi
		else
			printf "Skipping $script: Not executable."
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

# Install git scripts
echo "${RESET} Installing ${BOLD}Git Scripts${RESET}...${RESET}"
install_scripts "$git_scripts_path" "git"
echo

# Install gh scripts
echo "${RESET}   Installing ${BOLD}Gh Scripts${RESET}...${RESET}"
install_scripts "$gh_scripts_path" "gh"
echo