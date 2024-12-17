#!/bin/bash

# Check if the branch exists
function is_a_git_branch {
  git rev-parse --verify "$1" >/dev/null 2>&1
}
