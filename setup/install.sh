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
		$SUDO -n true &>/dev/null
		if [ $? -eq 1 ]; then
			$SUDO echo && return 0 || return 1
		else
			return 0
		fi
	fi
}

# Get the binary path for linking
binary_path=$(whereis sh | grep -o '/[^ ]*/bin' | head -n 1)

# Define paths to script directories
git_scripts_path="$PWD/git_scripts"
gh_scripts_path="$PWD/gh_scripts"

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
				echo "$script_name is already installed."
			else
				echo "Installing $script_name..."
				$SUDO ln -s "$script" "$symlink_path"
				echo "$script_name installed successfully."
			fi
		else
			echo "Skipping $script: Not executable."
		fi
	done
}

# Install git scripts
echo "Installing git scripts..."
allow_sudo && install_scripts "$git_scripts_path" "git"

# Install gh scripts
echo "Installing gh scripts..."
allow_sudo && install_scripts "$gh_scripts_path" "gh"
