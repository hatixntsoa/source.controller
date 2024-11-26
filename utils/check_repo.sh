#!/bin/bash

function is_a_github_repo {
	repo_url="$1"

	# Check if username is empty
	[ -z "$repo_url" ] && return 1

	# Build the API URL
	url="https://api.github.com/repos/$repo_url"

	# Checking response from the URL
	response=$(wget -qO- --no-check-certificate "$url")

	# If we receive a response then the user exists
	[ -n "$response" ] && return 0 || return 1
}