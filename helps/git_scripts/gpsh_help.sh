#!/bin/bash

# Arguments for the usage
gpsh_arguments=(
  "$(basename "$0" .sh)"
)

# Description for the usage
gpsh_descriptions=(
  "This script simplifies the process of pushing"
	"local commits to its remote Git repository."
)

# Options for the usage
gpsh_options=(
  "--help            Display this help message."
)

# Extra help
gpsh_extras=(
  "No arguments are required. Just run the script to push changes."
)
