#!/bin/bash

# Function to animate loading with a command and wait
function animate_loading {
  loading_pid="$1"
  loading_text="$2"
  animation_chars="/-\|"
  i=0

  # Keep spinning until the background process finishes
  while kill -0 $loading_pid 2>/dev/null; do
    printf "\r$loading_text${animation_chars:i:1} ${RESET}"
    i=$(((i + 1) % ${#animation_chars}))
    sleep 0.1
  done

  # Wait for the background process to finish and
  # then clear the loading character
  wait $loading_pid
  printf "\r$loading_text"
}

# Function to execute any command with a loading animation
function execute_with_loading {
  loading_message="$1"
  command_to_run="$2"

  # Run the command in the background and capture its PID
  $command_to_run > /dev/null 2>&1 &
  command_pid=$!

  # Run the animation while the command is executing
  animate_loading $command_pid "$loading_message"

  # Capture the exit status of the command
  wait $command_pid
  exit_status=$?

  # Assign the status symbol based on the exit status
  status=$([ $exit_status -eq 0 ] && echo "${GREEN} " || echo "${RED}✘")

  echo -e "${BOLD}$status ${RESET}" 

  return $exit_status
}