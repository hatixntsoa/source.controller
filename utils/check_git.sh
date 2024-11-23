#!/bin/bash

# Check if inside a git repo
function is_a_git_repo {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
  return $?
}