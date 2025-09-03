#!/bin/bash

# Function to create _help files for the scripts in a given directory
function create_help_files {
  local scripts_dir=$1
  local help_dir=$2

  # Loop over each file in the source directory
  for script in "$scripts_dir"/*; do
    if [[ -f "$script" ]]; then
      # Extract the file name without the directory path
      script_name=$(basename "$script" .sh)
      
      # Append _help to the script name and create the new file
      help_file="$help_dir/${script_name}_help.sh"

      # Check if the help file exists and has content
      if [[ -s "$help_file" ]]; then
        echo " ● ${BOLD}${LIGHT_BLUE}$(basename "$help_file") ${RESET}${RESET}already exists."
      else
        # Call the function to write content to the help file
        printf " ● Creating ${BOLD}${LIGHT_BLUE}$(basename "$help_file")${RESET}..."
        write_help_file_content "$script_name" "$help_file"
        printf "${BOLD}${GREEN} ${RESET}\n"
      fi
    fi
  done
}

# Resolve the full path to the script's directory
REAL_PATH="$(dirname "$(readlink -f "$0")")"
PARENT_DIR="$(dirname "$REAL_PATH")"

UTILS_DIR="$PARENT_DIR/utils"

# Import necessary variables and functions
source "$UTILS_DIR/check_sudo.sh"
source "$UTILS_DIR/colors.sh"

# Directories for source and target
git.scripts_DIR="$PARENT_DIR/git.scripts"
gh.scripts_DIR="$PARENT_DIR/gh.scripts"

HELP_git.scripts_DIR="$PARENT_DIR/helps/git.scripts"
HELP_gh.scripts_DIR="$PARENT_DIR/helps/gh.scripts"

# Create the directories if they don't exist
mkdir -p "$HELP_git.scripts_DIR"
mkdir -p "$HELP_gh.scripts_DIR"

# Function to write help file content
function write_help_file_content {
  local script_name="$1"
  local help_file="$2"

  cat > "$help_file" <<EOL
#!/bin/bash

# Arguments for the usage
${script_name}_arguments=(
  "\$(basename "\$0" .sh)"
)

# Description for the usage
${script_name}_descriptions=(
  "description"
)

# Options for the usage
${script_name}_options=(
  "--help            Display this help message."
)

# Extra help
${script_name}_extras=(
  "extra"
)
EOL
}

# Create help files for git.scripts
printf "\n${BOLD} Git Scripts Helps...${RESET}\n"
create_help_files "$git.scripts_DIR" "$HELP_git.scripts_DIR"

echo

# Create help files for gh.scripts
printf "${BOLD} Gh Scripts Helps...${RESET}\n"
create_help_files "$gh.scripts_DIR" "$HELP_gh.scripts_DIR"