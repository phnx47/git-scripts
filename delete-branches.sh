#!/usr/bin/env bash

set -eu -o pipefail

source "$(dirname "$0")/echo.sh"

# Default options
DELETE_LOCAL=true
DELETE_REMOTE=false
MERGED_ONLY=true

# Parse command line arguments
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Delete git branches with various options.

OPTIONS:
    -r, --remote         Also delete remote branches (in addition to local)
    -f, --force-local    Force delete all local branches (including unmerged)
    -h, --help           Show this help message

Default behavior: Delete only merged local branches (safe)
Note: Remote branches are always merged-only for safety

Examples:
    $0                   # Delete merged local branches only
    $0 --remote          # Delete merged local and remote branches
    $0 --force-local     # Force delete all local branches (merged or unmerged)
    $0 -r -f             # Force delete all local branches + merged remote branches
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--remote)
            DELETE_REMOTE=true
            shift
            ;;
        -f|--force-local)
            MERGED_ONLY=false
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Get default branch and checkout
default_branch="$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)"
blue_echo "Default branch is '${default_branch}'"

# Ignore patterns for important branches
ignore="main|master|develop|dev|${default_branch}"

git checkout "${default_branch}"

# Update remotes and prune stale references
git fetch
git remote prune origin
green_echo "Remote references updated and pruned!"

# Function to delete local branches
delete_local_branches() {
    local branches
    if [[ "$MERGED_ONLY" == "true" ]]; then
        branches="$(git branch --merged "${default_branch}" | tr -d " *" | grep -vE "${ignore}" || true)"
        blue_echo "Finding local merged branches..."
    else
        branches="$(git branch | tr -d " *" | grep -vE "${ignore}" || true)"
        yellow_echo "Warning: Deleting ALL local branches (including unmerged)!"
    fi
    
    if [ -z "$branches" ]; then
        blue_echo "No local branches to delete"
        return
    fi
    
    blue_echo "Local branches to delete:"
    yellow_echo "${branches}"
    read -rp "Delete these local branches (y/n)? "
    if [ "$REPLY" == "y" ]; then
        if [[ "$MERGED_ONLY" == "true" ]]; then
            echo "${branches}" | xargs git branch -d
        else
            echo "${branches}" | xargs git branch -D
        fi
        green_echo "Local branches deleted!"
    fi
}

# Function to delete remote branches
delete_remote_branches() {
    local branches
    # Remote branches are always merged-only for safety
    branches="$(git branch -r --merged "${default_branch}" | sed 's/ *origin\///' | grep -vE "${ignore}" || true)"
    blue_echo "Finding remote merged branches..."
    
    if [ -z "$branches" ]; then
        blue_echo "No remote branches to delete"
        return
    fi
    
    blue_echo "Remote branches to delete:"
    yellow_echo "${branches}"
    read -rp "Delete these remote branches (y/n)? "
    if [ "$REPLY" == "y" ]; then
        echo "${branches}" | xargs -I% git push origin :%
        green_echo "Remote branches deleted!"
    fi
}

# Execute based on options
if [[ "$DELETE_LOCAL" == "true" ]]; then
    delete_local_branches
fi

if [[ "$DELETE_REMOTE" == "true" ]]; then
    delete_remote_branches
fi

green_echo "Branch cleanup completed!"
