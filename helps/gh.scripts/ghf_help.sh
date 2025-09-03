#!/bin/bash

# Arguments for the usage
ghf_arguments=(
  "$(basename "$0" .sh) [repo_owner]/[repo_name]"
)

# Description for the usage
ghf_descriptions=(
  "This script forks a GitHub repository and clones the fork to the local machine.
  The fork will appear in your GitHub account, and the cloned repository will be 
  linked to the forked version."
)

# Options for the usage
ghf_options=(
  "[repo_owner]      The owner of the GitHub repo to fork

  [repo_name]       The name of the repo to fork

  --help            Display this help message."
)

# Extra help
ghf_extras=(
  "ghf h471x/git_gh

  This will fork the repository ${BOLD}${LIGHT_BLUE}${NO_UNDERLINE}${LINK_START}https://github.com/h471x/git_gh${LINK_TEXT}h471x/git_gh${LINK_END} ${RESET}into your GitHub
  account and clone the forked repository to your local machine."
)
