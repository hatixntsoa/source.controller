#!/bin/bash

# Arguments for the usage
gcln_arguments=(
  "$(basename "$0" .sh) [my_repo_name]"
  "$(basename "$0" .sh) [repo_owner]/[repo_name]"
  "$(basename "$0" .sh) [repo_owner]/[repo_name] --depth [depth_num]"
  "$(basename "$0" .sh) [repo_owner]/[repo_name] -d [depth_num]"
)

# Description for the usage
gcln_descriptions=(
  "This script clones a new GitHub repository"
  "if given the argument owner/repo."
)

# Options for the usage
gcln_options=(
  "[repo_owner]     The owner of the repo to clone."
  ""
  "[repo_name]      Name of the GitHub repository to clone."
  ""
  "[my_repo_name]   Name of our own GitHub repository to clone;"
  "                 This will work for our own private repo."
  ""
  "--help           Display this help message."
)

# Extra help
gcln_extras=(
  "extra"
)
