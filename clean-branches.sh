#!/usr/bin/env bash

set -eu -o pipefail

source "$(dirname "$0")/echo.sh"

default_branch="$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)"
blue_echo "Default branch is '${default_branch}'"

ignore="main|master|develop|dev"

git checkout "${default_branch}"

# Update our list of remotes
git fetch
git remote prune origin
green_echo "All remote branches pruned!"

# Remove local fully merged branches
local_branches="$(git branch --merged "${default_branch}" | tr -d " *" | grep -vE "${ignore}" || true)"
if [ -z "$local_branches" ]; then
  blue_echo "No local branches to delete"
else
  blue_echo "Deleting local branches..."
  yellow_echo "${local_branches}"
  read -rp "Delete these local branches (y/n)? "
  if [ "$REPLY" == "y" ]; then
    echo "${local_branches}" | xargs git branch -d
    green_echo "All local branches deleted!"
  fi
fi

# Remove remote fully merged branches
remote_branches="$(git branch -r --merged "${default_branch}" | sed 's/ *origin\///' | grep -vE "${ignore}" || true)"
if [ -z "$remote_branches" ]; then
  blue_echo "No remote branches to delete"
else
  blue_echo "Deleting remote branches..."
  yellow_echo "${remote_branches}"
  read -rp "Delete these remote branches (y/n)? "
  if [ "$REPLY" == "y" ]; then
    echo "${remote_branches}" | xargs -I% git push origin :%
    green_echo "All remote branches deleted!"
  fi
fi

