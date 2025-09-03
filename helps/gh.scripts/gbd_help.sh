#!/bin/bash

# Arguments for the usage
gbd_arguments=(
  "$(basename "$0" .sh) [branch_to_delete]"
)

# Description for the usage
gbd_descriptions=(
  "This script deletes a specified Git branch or the current branch if no"
	"branch name is provided. It will prompt for confirmation before deleting"
	"the branch, and will also handle deletion of remote branches if they exist."
	"The branch to be deleted cannot be the default branch of the repository."
)

# Options for the usage
gbd_options=(
  "[branch_to_delete]  Name of the branch to delete."
	"                    If omitted, the current branch is deleted."
	"                    The branch cannot be the default"
	"                    branch of the repository."
	""
	"--help              Display this help message."
)

# Extra help
gbd_extras=(
  "If no arguments are provided, the current branch"
	"will be deleted if it's not the default branch."
)
