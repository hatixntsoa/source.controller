#!/bin/bash

# Arguments for the usage
gnm_arguments=(
  "$(basename "$0" .sh) [new_branch_name]"
)

# Description for the usage
gnm_descriptions=(
  "This script renames the current branch"
	"to the specified new branch name in a Git repository."
)

# Options for the usage
gnm_options=(
  "--help            Display this help message."
)

# Extra help
gnm_extras=(
  "$(basename "$0" .sh) new_branch_name"
	"    Renames the current branch to 'new_branch_name'."
)
