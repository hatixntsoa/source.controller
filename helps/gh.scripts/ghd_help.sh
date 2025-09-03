#!/bin/bash

# Arguments for the usage
ghd_arguments=(
  "$(basename "$0" .sh) [owned_repo]"
  "$(basename "$0" .sh)"
)

# Description for the usage
ghd_descriptions=(
  "Deletes a local and/or remote GitHub repository."
)

# Options for the usage
ghd_options=(
  "[owned_repo]      The name of an owned repo to delete,"
  "                  or fork name will work too"
  ""
  "--help            Display this help message."
)

# Extra help
ghd_extras=(
  "extra"
)
