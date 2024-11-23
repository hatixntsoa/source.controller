#!/bin/bash

function has_remote {
  git remote -v | grep -q .
  return $?
}