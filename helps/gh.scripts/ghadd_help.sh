#!/bin/bash

# Arguments for the usage
ghadd_arguments=(
  "$(basename "$0" .sh) [collaborator_username...]"
)

# Description for the usage
ghadd_descriptions=(
  "This script interacts with a GitHub repository"
	"associated with the current local Git repository."
	""
	"It allows you to invite new collaborators to the repository."
)

# Options for the usage
ghadd_options=(
  "[collaborator_username]  GitHub username(s) of the collaborators to invite."
	"                         Multiple usernames can be provided, separated by spaces."
	""
	"--help                   Display this help message."
)

# Extra help
ghadd_extras=(
  "If no usernames are provided, the script will"
	"prompt you to specify at least one."
)
