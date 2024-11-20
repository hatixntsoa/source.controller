#!/bin/bash

function show_help {
  echo
  echo "${BOLD}$1:${RESET}"
  shift
  for HELP in "${@}"; do
    echo "  $HELP"
  done
}

function show_extra {
  echo
  for EXTRA in "${@}"; do
    echo "$EXTRA"
  done
}