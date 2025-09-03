#!/bin/bash

# Arguments for the usage
ghc_arguments=(
  "$(basename "$0" .sh) [repo_name] [visibility]"
)

# Description for the usage
ghc_descriptions=(
  "This script creates a new GitHub repository and optionally sets it as the remote"
	"for the current local Git repository. "
	"If the current directory is a Git repository and does not"
	"already have a remote, it will ask if you want to"
	"create a new remote repository and push local commits to it."
)

# Options for the usage
ghc_options=(
  "[repo_name]      Name of the GitHub repository to create."
	"                 If omitted, the name of the current directory is used."
	"                 (e.g., ghc or ghc private)"
	""
	"[visibility]     Repository visibility. Options are 'public' or 'private'."
	"                 If omitted, the default is 'public'."
	"                 (e.g., ghc repo_name)"
	""
	"--help           Display this help message."
)

# Extra help
ghc_extras=(
  "If no arguments are provided, the script uses the current directory name"
	"as the repository name and creates a public repository."
)
