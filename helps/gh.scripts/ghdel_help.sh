#!/bin/bash

# Arguments for the usage
ghdel_arguments=(
  "$(basename "$0" .sh) [collaborator_username...]"
)

# Description for the usage
ghdel_descriptions=(
  "This script interacts with a GitHub repository"
	"associated with the current local Git repository." 
	""
	"It allows you to remove collaborators from the repository."
)

# Options for the usage
ghdel_options=(
  "[collaborator_username]  GitHub username(s) of the collaborators to remove."
	"                         Multiple usernames can be provided, separated by spaces."
	""
	"--help                   Display this help message."
)

# Extra help
ghdel_extras=(
  "If no usernames are provided, the script will"
	"prompt you to specify at least one."
)
