# Flathub Update Process

This document describes how to update the scidCommunity application on Flathub when a new version is released.

## Prerequisites

- Your flathub fork with the `add-scidcommunity` branch
- The scidCommunity repository with the `/flatpak` directory

## Update Steps

### 1. Update the Manifest in scidCommunity Repo

In the scidCommunity repository's `/flatpak` directory:

```bash
cd /home/hugh/Downloads/scidCommunity/flatpak
./update-manifest.sh
```

This script automatically fetches the latest release tag and updates `io.github.whelanh.scidCommunity.yml`.

### 2. Copy to Flathub Fork

Copy the updated manifest to your flathub fork:

```bash
cp io.github.whelanh.scidCommunity.yml /path/to/flathub-fork/com.scidvspc.community.yml
```

**Note**: Verify the exact filename in your flathub fork (it may be `com.scidvspc.community.yml` or similar).

### 3a. If Initial PR Not Yet Merged

If your original PR is still open:

```bash
cd /path/to/flathub-fork
git checkout add-scidcommunity
git add com.scidvspc.community.yml
git commit -m "Update scidCommunity to version X.Y.Z"
git push origin add-scidcommunity
```

The existing PR will automatically update with the new commit.

### 3b. If Initial PR Already Merged

If your application is already published on Flathub:

```bash
cd /path/to/flathub-fork
git checkout main
git pull upstream main  # Sync with flathub main
git checkout -b update-to-vX.Y.Z  # Create new branch for the update
git add com.scidvspc.community.yml
git commit -m "Update scidCommunity to version X.Y.Z"
git push origin update-to-vX.Y.Z
```

Then create a new PR on the flathub repository from your new branch.

## Notes

- Each scidCommunity release should have a corresponding update to Flathub
- The `update-manifest.sh` script handles version detection automatically
- Always test the updated manifest locally before pushing to flathub if possible
- The flathub repository only needs the yml manifest file
