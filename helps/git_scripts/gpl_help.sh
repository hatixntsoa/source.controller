#!/bin/bash

# Arguments for the usage
gpl_arguments=(
  "$(basename "$0" .sh)"
)

# Description for the usage
gpl_descriptions=(
  "This script simplifies the process of pulling"
	"remote commits to local Git repository."
)

# Options for the usage
gpl_options=(
  "--help            Display this help message."
)

# Extra help
gpl_extras=(
  "No arguments are required. Just run the script to pull changes."
)
