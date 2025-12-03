# Flathub Submission Guide for scidCommunity

## Summary of Changes

Your flatpak has been configured for scidCommunity with the following changes:

- **App ID**: `io.github.whelanh.scidCommunity`
- **Repository**: `https://github.com/whelanh/scidCommunity.git`
- **Version**: v5.1.1.12
- **Bundled Engine**: Stockfish (Lc0 removed)
- **Runtime**: org.freedesktop.Platform 24.08

All flatpak files have been renamed and updated:
- `io.github.whelanh.scidCommunity.yml` (manifest)
- `io.github.whelanh.scidCommunity.appdata.xml` (metadata)
- `io.github.whelanh.scidCommunity.desktop` (desktop entry)
- `io.github.whelanh.scidCommunity.svg` (icon)

## Before Submitting to Flathub

### 1. Update Your Email in AppData
Edit `io.github.whelanh.scidCommunity.appdata.xml` and replace:
```xml
<update_contact>your_email_AT_example.com</update_contact>
```
with your actual email address (use `_AT_` instead of `@`).

### 2. Test the Build Locally

First, install the required runtime (if not already installed):
```bash
flatpak install flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08
```

Then build and test your flatpak:
```bash
cd /home/hugh/Downloads/scidCommunity/flatpak
flatpak-builder --user --install --force-clean build-dir io.github.whelanh.scidCommunity.yml
```

Run the flatpak to test it:
```bash
flatpak run io.github.whelanh.scidCommunity
```

Verify that:
- The application launches correctly
- Stockfish engine is accessible at `/app/engines/stockfish/`
- All your enhanced features work (Header Search layouts, Engine depth/time controls)
- FICS connection works
- Files can be opened and saved

### 3. Validate the Manifest

Install flatpak-builder-lint (if not already installed):
```bash
flatpak install flathub org.flatpak.Builder
```

Run validation:
```bash
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest io.github.whelanh.scidCommunity.yml
```

Fix any issues reported by the linter.

## Flathub Submission Process

### Step 1: Create a Flathub Fork
1. Go to https://github.com/flathub/flathub
2. Click "Fork" to create your own fork

### Step 2: Prepare Your Submission
Clone your fork:
```bash
git clone git@github.com:whelanh/flathub.git
cd flathub
git checkout -b add-scidcommunity
```

Create the app directory:
```bash
mkdir io.github.whelanh.scidCommunity
```

Copy your flatpak files to the new directory:
```bash
cp /home/hugh/Downloads/scidCommunity/flatpak/io.github.whelanh.scidCommunity.yml io.github.whelanh.scidCommunity/
cp /home/hugh/Downloads/scidCommunity/flatpak/io.github.whelanh.scidCommunity.appdata.xml io.github.whelanh.scidCommunity/
cp /home/hugh/Downloads/scidCommunity/flatpak/io.github.whelanh.scidCommunity.desktop io.github.whelanh.scidCommunity/
cp /home/hugh/Downloads/scidCommunity/flatpak/io.github.whelanh.scidCommunity.svg io.github.whelanh.scidCommunity/
```

### Step 3: Commit and Push
```bash
git add io.github.whelanh.scidCommunity/
git commit -m "Add io.github.whelanh.scidCommunity"
git push origin add-scidcommunity
```

### Step 4: Create Pull Request
1. Go to your fork on GitHub
2. Click "Pull requests" → "New pull request"
3. Set base repository to `flathub/flathub` and base branch to `master`
4. Set head repository to your fork and compare branch to `add-scidcommunity`
5. Fill in the PR description with:
   - Brief description of scidCommunity
   - Link to your GitHub repository
   - Mention that this is a community-enhanced fork of SCID
   - List the enhancements (Header Search layouts, Engine controls, etc.)

### Step 5: Respond to Review
Flathub maintainers will review your submission and may:
- Ask questions about the application
- Request changes to the manifest
- Verify your ownership of the GitHub repository
- Test the build

Be responsive to their feedback and make requested changes.

## Flathub Requirements Checklist

- [ ] AppData file includes valid metadata
- [ ] Desktop file is properly formatted
- [ ] Icon is in SVG format
- [ ] Manifest builds successfully
- [ ] Application ID follows reverse-DNS format
- [ ] You own or control the GitHub repository
- [ ] License is specified (GPL-2.0)
- [ ] App works in the Flatpak sandbox
- [ ] No bundled proprietary software (except engines like Stockfish)
- [ ] Screenshots in AppData are accessible

## Additional Resources

- Flathub documentation: https://docs.flathub.org/
- Flathub submission guide: https://docs.flathub.org/docs/for-app-authors/submission/
- Flatpak manifest documentation: https://docs.flatpak.org/en/latest/manifests.html
- Flathub quality guidelines: https://docs.flathub.org/docs/for-app-authors/requirements/

## Support

If you encounter issues during submission:
- Check the Flathub Matrix channel: https://matrix.to/#/#flathub:matrix.org
- Review existing Flathub apps for examples
- Consult the Flathub wiki: https://github.com/flathub/flathub/wiki

Good luck with your submission!
