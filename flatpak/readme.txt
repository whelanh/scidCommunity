Originally contributed by Roland Lötscher, adapted for scidCommunity

This flatpak manifest creates a flatpak for scidCommunity, a community-enhanced
fork of SCID with additional features like Header Search layouts and Engine depth/time
controls. The Stockfish chess engine is bundled in the package.
When running the flatpak, Stockfish is found in /app/engines/stockfish/

Here is how to build the flatpak (c.f. https://docs.flatpak.org/en/latest/first-build.html):
First install flatpak and add the flathub repo as described in https://flatpak.org/setup/
(if you do not use flatpaks yet) and then install the freedesktop runtime (which
contains all the build tools among other things)

    flatpak install flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08

This has to be done only once.
Then in order to build the flatpak and create a user installation of it run

    flatpak-builder --user --install --force-clean build-dir io.github.whelanh.scidCommunity.yml

from inside the repository flatpak folder (containing the flatpak manifest).
Here build-dir is the name of a temporary build folder and can be changed if wanted.
This will take a while, but should run without issues.

If everything goes well, you can run the flatpak via

    flatpak run io.github.whelanh.scidCommunity

According to tests, Stockfish runs fine and using FICS works fine as well.

---

FLATHUB SUBMISSION:

To submit this flatpak to Flathub:

1. Ensure you have tested the flatpak build locally and it works correctly

2. Visit https://github.com/flathub/flathub and click "New app submission"

3. Follow the Flathub submission guidelines at:
   https://docs.flathub.org/docs/for-app-authors/submission/

4. You'll need to:
   - Fork the flathub/flathub repository
   - Create a new branch for your submission
   - Add your manifest files (yml, appdata.xml, desktop, svg)
   - Submit a pull request
   - Respond to any review feedback from Flathub maintainers

5. Flathub will verify:
   - Your ownership of the GitHub repository
   - Manifest quality and compliance with Flathub guidelines
   - That the app builds successfully
   - AppData quality and completeness

For more information, see: https://github.com/flathub/flathub/wiki
