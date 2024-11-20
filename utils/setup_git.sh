#!/bin/bash

# Setup git if not installed
function setup_git {
  if ! git --version >/dev/null 2>&1; then
    echo "Git is not installed."

    # Setup git
    install_git() {
      echo "${BOLD}Installing Git...${RESET}"

      if command -v apt-get &>/dev/null; then
        $SUDO apt-get update -y >/dev/null 2>&1
        $SUDO apt-get install -y git >/dev/null 2>&1
      elif command -v yum &>/dev/null; then
        $SUDO yum update -y >/dev/null 2>&1
        $SUDO yum install -y git >/dev/null 2>&1
      elif command -v dnf &>/dev/null; then
        $SUDO dnf update -y >/dev/null 2>&1
        $SUDO dnf install -y git >/dev/null 2>&1
      elif command -v pacman &>/dev/null; then
        $SUDO pacman -Syu --noconfirm git >/dev/null 2>&1
      elif command -v zypper &>/dev/null; then
        $SUDO zypper update >/dev/null 2>&1
        $SUDO zypper install -y git >/dev/null 2>&1
      else
        echo "No supported package manager found. Please install Git manually."
        exit 1
      fi
    }
  fi
}