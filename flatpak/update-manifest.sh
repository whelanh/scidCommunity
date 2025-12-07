#!/bin/bash

set -e

REPO_URL="https://github.com/whelanh/scidCommunity.git"
MANIFEST_FILE="io.github.whelanh.scidCommunity.yml"

echo "Fetching latest release tag from $REPO_URL..."

# Get the latest tag by commit date (most recently created tag)
# Prefer 4-part versions (v5.1.1.499) over 3-part versions (v5.1.04)
echo "Cloning repository to determine latest tag by date..."
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

git clone --bare "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1

LATEST_TAG=$(cd "$TMP_DIR" && \
             git tag -l 'v*' | \
             grep -E '^v[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | \
             xargs -I {} git log -1 --format="%at {}" {} 2>/dev/null | \
             sort -rn | \
             head -n1 | \
             awk '{print $2}')

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not find any tags in the repository"
    exit 1
fi

echo "Latest tag: $LATEST_TAG"

# Get the commit hash for that tag
COMMIT_HASH=$(git ls-remote "$REPO_URL" "refs/tags/$LATEST_TAG" | awk '{print $1}')

if [ -z "$COMMIT_HASH" ]; then
    echo "Error: Could not find commit hash for tag $LATEST_TAG"
    exit 1
fi

echo "Commit hash: $COMMIT_HASH"

# Check if manifest file exists
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "Error: Manifest file $MANIFEST_FILE not found"
    exit 1
fi

# Update the manifest file
echo "Updating $MANIFEST_FILE..."
sed -i "s/tag: .*/tag: $LATEST_TAG/" "$MANIFEST_FILE"
sed -i "s/commit: .*/commit: $COMMIT_HASH/" "$MANIFEST_FILE"

echo "Successfully updated manifest:"
echo "  Tag: $LATEST_TAG"
echo "  Commit: $COMMIT_HASH"
