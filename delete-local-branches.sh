#!/usr/bin/env bash

set -eu -o pipefail

source "$(dirname "$0")/echo.sh"

default_branch="$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)"
blue_echo "Default branch is '${default_branch}'"

git checkout "${default_branch}"
local_branches="$(git branch | tr -d " *" | grep -vE "${default_branch}" || true)"

if [ -z "$local_branches" ]; then
  yellow_echo "No local branches to delete"
else
  blue_echo "Deleting local branches..."
  yellow_echo "${local_branches[*]}"
  read -rp "Delete these local branches (y/n)? "
  if [ "$REPLY" == "y" ]; then
    echo "${local_branches}" | xargs git branch -D
    green_echo "Local branches deleted!"
  fi
fi

