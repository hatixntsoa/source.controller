#!/bin/bash

function check_gh {
  # Check if GitHub CLI is installed
  if ! gh --version >/dev/null 2>&1; then
    echo "gh is not installed."
    exit 1
  fi
}

function gh_installed {
  # Check if GitHub CLI is installed
  if gh --version >/dev/null 2>&1; then
    return 0
  fi
  return 1
}