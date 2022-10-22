#!/usr/bin/env bash

set -e

source "$(dirname "$0")/echo.sh"

green_echo "Clean branches started"

default_branch="$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)"
blue_echo "Default branch is '${default_branch}'"

ignore="main|master|develop|dev"

git checkout "${default_branch}"

# Update our list of remotes
git fetch
git remote prune origin

# Remove local fully merged branches
light_green_echo "Removing local branches..."
git branch --merged "${default_branch}" | grep -vE "${ignore}" |  xargs git branch -d || true

# Remove remote fully merged branches
light_green_echo "Removing remote branches..."
git branch -r --merged "${default_branch}" | sed 's/ *origin\///' | grep -vE "${ignore}" || true

read -rp "Continue (y/n)? "
if [ "$REPLY" == "y" ]; then
  git branch -r --merged "${default_branch}" | sed 's/ *origin\///' | grep -vE "${ignore}" | xargs -I% git push origin :%
fi

green_echo "Clean branches finished!"
