#!/bin/bash

# Function to sanitize the repository name
function clean_repo {
	repo_name="$1"
	# Replace spaces with underscores
  printf "%s" "$repo_name" | sed -E 's/ /_/g'
}