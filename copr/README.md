# COPR Submission for scidCommunity

This directory contains files needed to submit scidCommunity to Fedora COPR.

## Files

- `scidcommunity.spec` - RPM spec file for building the package

## COPR Setup Instructions

### 1. Create COPR Account
- Go to https://copr.fedorainfra.org/
- Sign in with your Fedora Account System (FAS) credentials

### 2. Create New COPR Project
- Click "New Project"
- **Project Name**: `scidcommunity`
- **Description**: Chess database application with play and training functionality
- **Instructions**: Enable with: `sudo dnf copr enable <your-username>/scidcommunity`
- **Chroots**: Select Fedora 43 and Fedora Rawhide, architectures x86_64 and aarch64
- Click "Create"

### 3. Add Package Using SCM Method
- In your project, go to "Packages" → "New Package"
- **Package name**: `scidcommunity`
- **Build source**: Select "SCM"

#### SCM Configuration
- **Clone URL**: `https://github.com/whelanh/scidCommunity.git`
- **Committish**: `github` (or use specific tags like `v5.1.1` for stable releases)
- **Subdirectory**: Leave empty (spec file is in `/copr` subdirectory)
- **Spec File**: `copr/scidcommunity.spec`
- **Type**: `git`

### 4. Build Settings
- **Auto-rebuild**: Enable if you want automatic rebuilds on new commits/tags
- **Webhook**: Optionally set up GitHub webhooks for automatic builds

### 5. Trigger Build
- Click "Build" to start the initial build
- Monitor build logs for any errors
- Builds typically complete in 10-20 minutes

## Local Testing Before COPR Submission

### Install Build Tools
```bash
sudo dnf install fedora-packager fedora-review rpmlint mock
sudo usermod -a -G mock $USER
# Log out and back in for group membership to take effect
```

### Build Locally with Mock
```bash
# From the repository root
cd copr

# Create source tarball (COPR will do this automatically)
spectool -g scidcommunity.spec

# Build for Fedora Rawhide
mock -r fedora-rawhide-x86_64 --spec scidcommunity.spec --sources=.

# Build for Fedora 43
mock -r fedora-43-x86_64 --spec scidcommunity.spec --sources=.
```

### Alternative: Build with rpmbuild
```bash
# Setup rpmbuild directories
rpmdev-setuptree

# Copy spec file
cp copr/scidcommunity.spec ~/rpmbuild/SPECS/

# Create source tarball
cd ~/rpmbuild/SOURCES
wget https://github.com/whelanh/scidCommunity/archive/v5.1.1/scidcommunity-5.1.1.tar.gz

# Build
cd ~/rpmbuild/SPECS
rpmbuild -ba scidcommunity.spec
```

### Check for Issues
```bash
# Lint the spec file
rpmlint copr/scidcommunity.spec

# Lint the built RPM (after building)
rpmlint ~/rpmbuild/RPMS/x86_64/scidcommunity-*.rpm
```

### Test Installation
```bash
# Install the built RPM
sudo dnf install ~/rpmbuild/RPMS/x86_64/scidcommunity-*.rpm

# Run the application
scidCommunity

# Uninstall
sudo dnf remove scidcommunity
```

## Updating the Package

### For New Releases
1. Make your code changes
2. Commit and push to the github branch
3. Update line 7 in copr/scidcommunity.spec with the new commit hash
4. Commit and push the spec file update
5. Run the build command
`distrobox enter fedoraRawhide -- copr-cli build-package whelanh/scidcommunity --name scidcommunity`

### For Development Builds
- Keep the Committish as `github` (or your development branch)
- COPR will build from the latest commit
- Consider using a development version number like `5.1.1-dev`

## Key Differences from GitHub Actions RPM

The COPR package differs from the RPM built in GitHub Actions:

| Aspect | GitHub Actions | COPR |
|--------|---------------|------|
| Tcl/Tk | Bundled 8.6 | System package (>= 8.6) |
| Install prefix | `/opt/scidcommunity` | `/usr` |
| Wrapper script | Yes | No |
| Symlinks | Custom setup | Standard |

The COPR package follows Fedora packaging guidelines more closely by using system dependencies rather than bundling libraries.

## Resources

- COPR Documentation: https://docs.pagure.org/copr.copr/
- Fedora Packaging Guidelines: https://docs.fedoraproject.org/en-US/packaging-guidelines/
- RPM Packaging Guide: https://rpm-packaging-guide.github.io/
