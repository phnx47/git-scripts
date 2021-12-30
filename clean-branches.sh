#!/usr/bin/env bash

set -e

source $(dirname "$0")/echo.sh

branch=${1}

if [ -z "$branch" ]; then
    red_echo "Please provide default branch!"
    exit 1
fi

yellow_echo "Branches: '${branch}', 'develop' and 'dev' will not be deleted"

ignore="$branch\|develop\|dev$"

# This has to be run from $branch
git checkout $branch

# Update our list of remotes
git fetch
git remote prune origin

# Remove local fully merged branches
git branch --merged $branch | grep -v $ignore | xargs git branch -d

# Show remote fully merged branches
yellow_echo "The following remote branches are fully merged and will be removed:"
git branch -r --merged $branch | sed 's/ *origin\///' | grep -v $ignore

read -p "Continue (y/n)? "
if [ "$REPLY" == "y" ]; then
    # Remove remote fully merged branches
    git branch -r --merged $branch | sed 's/ *origin\///' | grep -v $ignore | xargs -I% git push origin :%
    green_echo "Obsolete branches are removed"
fi
