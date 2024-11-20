#!/bin/bash

# Arguments for the usage
ghcls_arguments=(
  "$(basename "$0" .sh)"
)

# Description for the usage
ghcls_descriptions=(
  "This script interacts with a GitHub repository" 
	"associated with the current local Git repository."
	""
	"It lists the collaborators and pending invitations"
	"for the repository."
)

# Options for the usage
ghcls_options=(
  "--help            Display this help message."
)

# Extra help
ghcls_extras=(
  "If no arguments are provided, the script will"
	"display the list of collaborators and pending invitations."
)
