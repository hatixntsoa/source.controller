#!/bin/bash

function has_remote {
  if git remote -v | grep -q .; then
    return 0
  fi
  return 1
}