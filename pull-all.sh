#!/usr/bin/env bash

set -eu -o pipefail

remote_branches=$(git branch -r | grep -v '\->')

for remote_branch in $remote_branches; do
  name=${remote_branch#origin/}
  git branch --track "$name" "$remote_branch" || true
done

git fetch --all
git pull --all
