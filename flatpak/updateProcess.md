Here are the instructions for updating your Flathub application:

1. In your Flathub Repository (io.github.whelanh.scidCommunity.yml):

Line 64 (commit: ...): You MUST change this line. Replace the existing hash with the full commit hash of the new version from your development repository (whelanh/scidCommunity).
Line 3 (runtime-version: '25.08'): You generally do not need to change this unless you specifically want to target a different Freedesktop SDK version. Since 25.08 appears to be the valid current/target version for your app, leaving it as is correct.
2. In your Development Repository (whelanh/scidCommunity):

flatpak/io.github.whelanh.scidCommunity.appdata.xml:
You MUST add a new <release> entry inside the <releases> tag.
This entry should include the version attribute (e.g., version="X.Y.Z") and the date attribute (e.g., date="2025-12-23").
Add a <description> with list items (<li>) describing the changes.
Why? Flathub uses this file to display "What's New" in software centers.
flatpak/io.github.whelanh.scidCommunity.yml:
This file in your dev repo is typically used for local testing or CI. It is good practice to keep it in sync with your Flathub manifest (especially shared modules and build options), but Flathub itself ignores this file during the build process (it uses the one in the Flathub repo).
Summary of Steps:

Make your code changes in your development repo.
Update the .appdata.xml in your development repo with the new version info.
    The CMakeLists.txt in your upstream repository installs the appdata file from the data/ directory (data/io.github.whelanh.scidCommunity.appdata.xml), not the one in the flatpak/ directory (flatpak/io.github.whelanh.scidCommunity.appdata.xml).

To fix this:

Apply your image changes to /home/hugh/Downloads/scidCommunity/data/io.github.whelanh.scidCommunity.appdata.xml.
Commit and push those changes to your upstream repository.
Update the commit hash in your Flathub manifest (io.github.whelanh.scidCommunity.yml) to match this new commit.
Submit the PR to Flathub.
Commit and push these changes to GitHub.
Copy the full commit hash of that new commit.
Go to your Flathub repo, edit io.github.whelanh.scidCommunity.yml, and paste the new hash on Line 64.
It is strongly recommended to create a Pull Request (PR).

Here is why a PR is better, even if you are the only maintainer (git checkout -b "xxxxxxx"):

The Flathub Build Bot: When you open a PR, Flathub's automated build system will pick it up and try to build your application.
If you made a typo (e.g., incorrect hash, indentation error), the bot will fail and let you know before you break the main branch.
If the build succeeds, you get confidence that the update will go smoothly for users.
Test Builds: The bot will often provide a command to install the test build locally. This allows you to verify that the new version actually runs and behaves correctly before releasing it to the public.
Safety: Pushing directly to the master (or main) branch bypasses these checks. If you push a broken build, you have to submit another commit to fix it, whereas with a PR, you can just update the branch until it's green.
Recommendation: Create a new branch for your update (e.g., update-to-1.2), make your changes, and open a PR against the default branch. Wait for the checks to pass, then merge.
