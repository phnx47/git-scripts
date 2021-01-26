#!/bin/bash

# forked from https://gist.github.com/TBonnin/4060788

function green_echo {
    echo -e "\e[32m${1}\e[0m"
}

regex='master$'
#regex='master\|develop$'

# This has to be run from master
git checkout master

# Update our list of remotes
git fetch
git remote prune origin

# Remove local fully merged branches
git branch --merged master | grep -v $regex | xargs git branch -d

# Show remote fully merged branches
echo "The following remote branches are fully merged and will be removed:"
git branch -r --merged master | sed 's/ *origin\///' | grep -v $regex

read -p "Continue (y/n)? "
if [ "$REPLY" == "y" ]
then
   # Remove remote fully merged branches
   git branch -r --merged master | sed 's/ *origin\///' | grep -v $regex | xargs -I% git push origin :%
   green_echo "Obsolete branches are removed"
fi
