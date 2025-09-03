#!/bin/bash

# Arguments for the usage
glc_arguments=(
  "$(basename "$0" .sh) [option]"
)

# Description for the usage
glc_descriptions=(
  "This script provides information about the current Git repository."
  "It displays details such as the number of commits, recent commit"
  "messages, and the number of commits made today by the current user."
)

# Options for the usage
glc_options=(
  "show              Display the git log in a simplified format."
  ""
  "--help            Display this help message."
)

# Extra help
glc_extras=(
  "No arguments are required to display repository statistics."
)
