#!/bin/bash

# check if the collaborator is a GitHub user
function is_a_github_user {
	username="$1"

	# Check if username is empty
	[ -z "$username" ] && return 1

	# Build the API URL
	url="https://api.github.com/users/$username"

	# Checking response from the URL
	response=$(wget -qO- --no-check-certificate "$url")

	# If we receive a response then the user exists
	[ -n "$response" ] && return 0 || return 1
}