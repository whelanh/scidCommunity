# Cherry-Picking Individual Commits from Upstream

This guide explains how to apply a single commit from an upstream repository to your fork without merging all the intervening changes.

## Why Use Cherry-Pick Instead of Merge?

When you want to incorporate a specific feature or fix from upstream without bringing in all the other changes between your branch and that commit, cherry-picking is the right approach. A regular `git merge` will attempt to merge the entire history, including all parent commits, which can create many conflicts.

## Step-by-Step Process

### 1. Fetch the Latest Changes from Upstream

First, ensure you have the latest commits from the upstream repository:

```bash
git remote -v
git remote add upstream git@github.com:benini/scid.git
git fetch upstream
```

Or if you're fetching from a specific remote:

```bash
git fetch origin
```

### 2. Identify the Commit

Find the commit hash you want to apply. You can do this by:

```bash
# View recent commits from upstream
git log upstream/main --oneline -10

# Or view a specific commit
git show <commit-hash>

# Check what files were changed in that commit
git show --stat <commit-hash>
```

### 3. Cherry-Pick the Commit

Apply the specific commit to your current branch:

```bash
git cherry-pick <commit-hash>
```

For example:
```bash
git cherry-pick 711116be5fb3934fe5306247b60d288e5a81740f
```

### 4. Resolve Conflicts (if any)

If there are conflicts:

1. Git will pause and show which files have conflicts
2. Edit the conflicted files to resolve the conflicts (look for `<<<<<<<`, `=======`, and `>>>>>>>` markers)
3. Stage the resolved files:
   ```bash
   git add <file-path>
   ```
4. Continue the cherry-pick:
   ```bash
   git cherry-pick --continue
   ```

### 5. Abort if Needed

If you want to cancel the cherry-pick operation:

```bash
git cherry-pick --abort
```

## Example: What We Did

```bash
# 1. Check what the commit contains
git show --stat 711116be5fb3934fe5306247b60d288e5a81740f
# Output showed: only tcl/tools/pinfo.tcl was changed

# 2. Apply the commit
git cherry-pick 711116be5fb3934fe5306247b60d288e5a81740f
# Conflict occurred in tcl/tools/pinfo.tcl

# 3. Resolve the conflict
# Edited tcl/tools/pinfo.tcl to accept the incoming changes

# 4. Stage the resolved file
git add tcl/tools/pinfo.tcl

# 5. Complete the cherry-pick
git cherry-pick --continue
```

## Verifying Success

After cherry-picking, verify the commit was applied:

```bash
# View recent commits
git log --oneline -3

# Check the specific changes
git show HEAD
```

## Tips

- **Always check what files a commit changes** before cherry-picking using `git show --stat <commit-hash>`
- **Cherry-pick creates a new commit** with a different hash, even though it contains the same changes
- **Order matters**: If cherry-picking multiple commits, apply them in chronological order
- **Test your code** after cherry-picking to ensure everything works correctly

## Common Issues

### "Why did `git merge` try to merge so many files?"

When you merge a commit, Git merges the entire branch history up to that commit. If the upstream branch has diverged significantly from yours, this brings in many unrelated changes.

### "Can I cherry-pick multiple commits at once?"

Yes:
```bash
git cherry-pick <commit1> <commit2> <commit3>
```

Or a range:
```bash
git cherry-pick <start-commit>^..<end-commit>
```

## Alternative: Creating a Patch

If cherry-picking doesn't work well, you can create and apply a patch:

```bash
# Create a patch from upstream
git format-patch -1 <commit-hash> --stdout > feature.patch

# Apply the patch
git apply feature.patch
```
