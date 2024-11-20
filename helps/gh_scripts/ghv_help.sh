#!/bin/bash

# Arguments for the usage
ghv_arguments=(
  "$(basename "$0" .sh) [show|owner]"
)

# Description for the usage
ghv_descriptions=(
  "This script interacts with a GitHub repository"
	"associated with the current local Git repository."
	""
	"It can show the repository's visibility,"
	"toggle the visibility between 'public' and 'private',"
	"or display the repository's owner."
)

# Options for the usage
ghv_options=(
  "show             Display the visibility status of the repository."
	"owner            Show the owner of the repository."
	""
	"--help           Display this help message."
)

# Extra help
ghv_extras=(
  "If no arguments are provided, it checks the repository visibility"
	"and will prompt to toggle it according to its current state."
)
