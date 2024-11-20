#!/bin/bash

# Arguments for the usage
gck_arguments=(
  "$(basename "$0" .sh) [branch_name]"
)

# Description for the usage
gck_descriptions=(
  "This script helps manage Git branches"
	"by switching to the default branch,"
	"or creating new branches"
	"locally and remotely if needed."
)

# Options for the usage
gck_options=(
  "[branch_name]      Switch to the specified branch"
	"                   or create it if it doesn't exist."
	""
	"--help             Display this help message."
)

# Extra help
gck_extras=(
  "No arguments means to switch to the default branch,"
	"or prompt to create a new branch named after the current unix user."
)
