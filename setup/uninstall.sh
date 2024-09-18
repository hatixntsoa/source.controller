#!/bin/sh

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
allow_sudo(){
	if [ -n "$SUDO" ]; then
		$SUDO -n true 2>/dev/null
		if [ $? -ne 0 ]; then
			$SUDO -v
		fi
	fi
}

# Get the binary path for linking
binary_path=$(whereis sh | grep -o '/[^ ]*/bin' | head -n 1)

# Define paths to script directories
git_scripts_path="$PWD/git_scripts"
gh_scripts_path="$PWD/gh_scripts"

# Define color codes
BOLD="\e[1m"
RED="\e[31m"
WHITE="\e[97m"
RESET="\e[0m"
GREEN="\e[32m"
LIGHT_BLUE="\e[34m"

# Function to extract script name without the .sh extension
get_script_name() {
	basename "$1" .sh
}

# Function to uninstall scripts
uninstall_scripts() {
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
				printf "${BOLD}${RED}Not Installed ${RESET}"
			fi
		else
			printf "${WHITE}Skipping ${LIGHT_BLUE}${BOLD}$script ${RESET}${WHITE}: Not executable."
		fi
		echo
	done
}

# prompt for sudo
# password if required
allow_sudo
echo

# Uninstall git scripts
echo "${WHITE}   Uninstalling ${BOLD}Git Scripts${WHITE}...${RESET}"
uninstall_scripts "$git_scripts_path" "git"
echo

# Uninstall gh scripts
echo "${WHITE}   Uninstalling ${BOLD}Gh Scripts${WHITE}...${RESET}"
uninstall_scripts "$gh_scripts_path" "gh"
echo