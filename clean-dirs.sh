#!/usr/bin/env bash

set -eu -o pipefail

while read -r dir; do
  cd "${dir}"
  if [ -d .git ] || [ -f .git ]; then
    echo "${dir}"
    git clean -xdf
  fi
  cd ..
done <<<"$(find . -mindepth 1 -maxdepth 1 -type d -not -name ".*")"
