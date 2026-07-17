#!/usr/bin/env bash
# Usage: ./new-branch.sh feature/hero-section
# Ensures you never commit on main: creates & switches to a new branch,
# carrying over any uncommitted changes.

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <type>/<short-description>"
  echo "Types: feature | fix | chore | refactor | style | docs"
  exit 1
fi

BRANCH_NAME="$1"
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "On $CURRENT_BRANCH — creating branch '$BRANCH_NAME' and moving any uncommitted work to it..."
  git checkout -b "$BRANCH_NAME"
else
  echo "Already on branch '$CURRENT_BRANCH', not main. Creating '$BRANCH_NAME' from here."
  git checkout -b "$BRANCH_NAME"
fi

echo "Now on branch: $(git branch --show-current)"
