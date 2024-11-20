#!/bin/bash

# Arguments for the usage
gcb_arguments=(
  "$(basename "$0" .sh)"
)

# Description for the usage
gcb_descriptions=(
  "This script switches to the previously"
	"checked-out branch in a Git repository."
	"It checks if the current directory"
	"is a Git repository, and performs the branch switch."
)

# Options for the usage
gcb_options=(
  "--help            Display this help message."
)

# Extra help
gcb_extras=(
  "No arguments means to switch to the last checked-out branch."
)