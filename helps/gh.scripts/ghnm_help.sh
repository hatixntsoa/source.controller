#!/bin/bash

# Arguments for the usage
ghnm_arguments=(
  "$(basename "$0" .sh) [new_repo_name]"
)

# Description for the usage
ghnm_descriptions=(
  "This script will rename the current repo name."
)

# Options for the usage
ghnm_options=(
  "[new_repo_name]   The new name for the current repo"
  ""
  "--help            Display this help message."
)

# Extra help
ghnm_extras=(
  "ghnm source.controller"
  "This will rename the current repo to ${LIGHT_BLUE}source.controller ${RESET}"
)