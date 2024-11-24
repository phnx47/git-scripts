#!/usr/bin/env bash

set -eu -o pipefail

msg=${1}

git reset "$(git commit-tree HEAD^"{tree}" -S -m "${msg}")"
