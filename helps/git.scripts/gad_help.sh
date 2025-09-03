#!/bin/bash

# arguments for the usage
gad_arguments=(
	"$(basename "$0" .sh) [file] [commit_message]"
	"$(basename "$0" .sh) [commit_message]"
	"$(basename "$0" .sh)"
)

# Description for the usage
gad_descriptions=(
	"This script simplifies the process of adding"
	"and committing changes in a Git repository."
	""
	"It allows you to specify a file to add and provides"
	"a way to commit changes with or without a commit message"
	"directly from the command line."
	""
	"If no file is specified, all changes are added."
	"If no commit message is provided, the default git editor"
	"will open to allow for a detailed commit message."
)

# Options for the usage
gad_options=(
	"[file]            Path to a specific file to add and commit."
	"                  If omitted, all changes are added."
	""
	"[commit_message]  Commit message to use. If no commit message is provided,"
	"                  the default git editor will open."
	"                  The commit message can be enclosed in quotes"
	"                  (e.g., gad \"commit message\")"
	"                  or written without quotes (e.g., gad commit message),"
	"                  as long as it does not contain special characters."
	""
	"--help            Display this help message."
)

# Extra help
gad_extras=(
  "If no arguments are provided, all changes are added and committed"
  "with a message prompted in the editor."
)