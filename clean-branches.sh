#!/bin/bash

# forked from https://gist.github.com/TBonnin/4060788

function green_echo {
    echo -e "\e[32m${1}\e[0m"
}

branch=master
ignore="master\|develop$"

# This has to be run from $branch
git checkout $branch

# Update our list of remotes
git fetch
git remote prune origin

# Remove local fully merged branches
git branch --merged $branch | grep -v $ignore | xargs git branch -d

# Show remote fully merged branches
echo "The following remote branches are fully merged and will be removed:"
git branch -r --merged $branch | sed 's/ *origin\///' | grep -v $ignore

read -p "Continue (y/n)? "
if [ "$REPLY" == "y" ]
then
   # Remove remote fully merged branches
   git branch -r --merged $branch | sed 's/ *origin\///' | grep -v $ignore | xargs -I% git push origin :%
   green_echo "Obsolete branches are removed"
fi
