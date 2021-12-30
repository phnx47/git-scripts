#!/usr/bin/env bash

set -eu -o pipefail

git_tags=$(git tag)

for git_tag in $git_tags; do
  git tag "${git_tag}" "${git_tag}" -f -s -m "${git_tag}"
done

# git push origin --tags -f
