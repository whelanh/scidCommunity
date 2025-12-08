#!/bin/bash

set -e

REPO_URL="https://github.com/whelanh/scidCommunity.git"
MANIFEST_FILE="io.github.whelanh.scidCommunity.yml"
APPDATA_FILE="io.github.whelanh.scidCommunity.appdata.xml"
BRANCH="github"

echo "Fetching latest commit from $REPO_URL (branch: $BRANCH)..."

# Get the latest commit hash from the specified branch
COMMIT_HASH=$(git ls-remote "$REPO_URL" "refs/heads/$BRANCH" | awk '{print $1}')

if [ -z "$COMMIT_HASH" ]; then
    echo "Error: Could not find commit hash for branch $BRANCH"
    exit 1
fi

echo "Latest commit: $COMMIT_HASH"

# Check if manifest file exists
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "Error: Manifest file $MANIFEST_FILE not found"
    exit 1
fi

# Update the manifest file - replace tag and commit lines
echo "Updating $MANIFEST_FILE..."
sed -i "s/branch: .*/branch: $BRANCH/" "$MANIFEST_FILE"
sed -i "s/commit: .*/commit: $COMMIT_HASH/" "$MANIFEST_FILE"

echo "Successfully updated:"
echo "  Branch: $BRANCH"
echo "  Commit: $COMMIT_HASH"
