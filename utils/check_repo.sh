#!/bin/bash

function is_a_github_repo {
  gh repo view "$1" >/dev/null 2>&1
  return $?
}