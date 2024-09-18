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

# Get the binary path for linking
binary_path=$(whereis sh | grep -o '/[^ ]*/bin' | head -n 1)

# Define paths to script directories
git_scripts_path="$PWD/git_scripts"
gh_scripts_path="$PWD/gh_scripts"

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

			if [ -L "$link_path" ]; then
				echo "Uninstalling $script_name..."
				$SUDO rm "$link_path"
				echo "$script_name uninstalled successfully."
			else
				echo "$script_name is not installed."
			fi
		else
			echo "Skipping $script: Not executable."
		fi
	done
}

# Uninstall git scripts
echo "Uninstalling git scripts..."
uninstall_scripts "$git_scripts_path" "git"

# Uninstall gh scripts
echo "Uninstalling gh scripts..."
uninstall_scripts "$gh_scripts_path" "gh"

# Clean up temporary directory if created
if [ -n "$temp_dir" ]; then
	echo "Cleaning up..."
	$SUDO rm -rf "$temp_dir"
fi
