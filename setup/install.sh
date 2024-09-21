#!/bin/bash

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

# this will check for sudo permission
allow_sudo() {
	if [ -n "$SUDO" ]; then
		$SUDO -n true 2>/dev/null
		if [ $? -ne 0 ]; then
			$SUDO -v
		fi
	fi
}

# Get the binary path for linking
binary_path=$(whereis sh | grep -o '/[^ ]*/bin' | head -n 1)

# Get the source directory of the repo
repo_source=$(git rev-parse --show-toplevel)

# Define paths to script directories
git_scripts_path="$repo_source/git_scripts"
gh_scripts_path="$repo_source/gh_scripts"

# Define color codes
BOLD=$'\033[1m'
GREEN=$'\033[32m'
WHITE=$'\033[97m'
RESET=$'\033[0m'
LIGHT_BLUE=$'\033[34m'

# Function to extract script name without the .sh extension
get_script_name() {
	basename "$1" .sh
}

# Function to install scripts
install_scripts() {
	local script_dir="$1"
	local script_type="$2"

	for script in "$script_dir"/*; do
		if [ -x "$script" ]; then
			script_name=$(get_script_name "$script")
			symlink_path="$binary_path/$script_name"

			if [ -L "$symlink_path" ]; then
				printf "${BOLD}${LIGHT_BLUE}$script_name ${RESET}${WHITE}already installed."
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

# prompt for sudo
# password if required
allow_sudo
echo

# Install git scripts
echo "${WHITE}   Installing ${BOLD}Git Scripts${WHITE}...${RESET}"
install_scripts "$git_scripts_path" "git"
echo

# Install gh scripts
echo "${WHITE}   Installing ${BOLD}Gh Scripts${WHITE}...${RESET}"
install_scripts "$gh_scripts_path" "gh"
echo
