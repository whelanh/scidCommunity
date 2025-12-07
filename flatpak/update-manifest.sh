#!/bin/bash

set -e

REPO_URL="https://github.com/whelanh/scidCommunity.git"
MANIFEST_FILE="io.github.whelanh.scidCommunity.yml"

echo "Fetching latest release tag from $REPO_URL..."

# Get the latest tag (sorted by version)
# Prefer 4-part versions (v5.1.1.499) over 3-part versions (v5.1.04)
LATEST_TAG=$(git ls-remote --tags "$REPO_URL" | \
             grep -v '\^{}' | \
             awk '{print $2}' | \
             sed 's|refs/tags/||' | \
             grep '^v[0-9]' | \
             grep -E '^v[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | \
             sort -t. -k1,1V -k2,2n -k3,3n -k4,4n | \
             tail -n1)

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
