#!/bin/bash

# function for connection check
function connected {
  if $SUDO ping -c 1 github.com &>/dev/null; then
    return 0
  fi
  return 1
}

# Check for internet connectivity to GitHub
function check_connection {
  if ! connected; then
    echo "${BOLD} ■■▶ This won't work, you are offline !${RESET}"
    exit 0
  fi
}