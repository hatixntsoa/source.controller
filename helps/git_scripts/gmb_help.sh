#!/bin/bash

# Arguments for the usage
gmb_arguments=(
  "$(basename "$0" .sh) [branch]"
)

# Description for the usage
gmb_descriptions=(
  "This script merges the specified branch into the"
	"current branch in a Git repository."
  ""
	"It checks if the specified branch exists"
	"and ensures that the current branch"
	"is different from the target branch before merging."
)

# Options for the usage
gmb_options=(
  "--help            Display this help message."
)

# Extra help
gmb_extras=(
  "$(basename "$0" .sh) feature-branch"
	"    Merges 'feature-branch' into the current branch."
)
