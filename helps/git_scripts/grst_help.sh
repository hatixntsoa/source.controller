#!/bin/bash

# Arguments for the usage
grst_arguments=(
  "$(basename "$0" .sh) [option]"
	"$(basename "$0" .sh) [file]"
)

# Description for the usage
grst_descriptions=(
  "This script restores changes in a Git repository"
	"based on the provided option."
	""
	"If no argument is provided, it will restore"
	"all changes in the repository to the last commit."
	""
	"If 'cmt' is provided as an option, it will"
	"undo the last commit (soft reset)."
	""
	"If a file is specified as an argument,"
	"it will restore that file to its last committed state."
)

# Options for the usage
grst_options=(
  "cmt               Undo the last commit by performing a soft reset."
	""
	"[file]            Restore the specified file to its last committed state."
	""
	"--help            Display this help message."
)

# Extra help
grst_extras=(
  "When no argument is given, it will restore all changes"
  "in the repository to the last commit."
)
