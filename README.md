<p align="center">
<img width="128" height="124" alt="scidCommunity" src="https://github.com/user-attachments/assets/22a930f1-3236-48aa-88a9-a75ef21dc79b" />
</p>

**scidCommunity** differs from upstream `Scid` by offering enhancements not present in the upstream repo. Enhancements include:

1. The **Header Search** dialogue has been improved with the addition of a new "Layouts" button at the lower left. This button replaces a "Save" button that has been disabled for years. The new button allows users to name, save and load sets of search parameters they use frequently.
      - The hotkey Alt + s has been added to invoke the Search button. 
2. The **Engine** windows have been enhanced with new depth and move time input windows for limiting an engine's calculations. If users choose to use Scid's **Save Options**, the inputs will be saved as the defaults for future use.
3. A new **`Download TWIC Games`** option under the **`Tools`** menu that downloads' the most recent weekly games from [TWIC](https://theweekinchess.com/twic) and brings into scidCommunity for filtering, merging with your database etc.
4. New (optional) "Sand" and "cobalt2" themes.

*Users with suggestions for further enhancements are welcome to write something in the Discussion section or submit a pull request.  Enjoy!*

New "Layouts" button with (optional) Sand theme:

<img width="500" height="450" alt="Screenshot_20251203_143244 (Edit)" src="https://github.com/user-attachments/assets/fdf27a66-5ae4-40de-8a86-28db86b29f22" />

New Engine depth and move time input windows:
<img width="638" height="303" alt="image" src="https://github.com/user-attachments/assets/0563010d-b20b-4771-8ef4-7470b8ebc9fb" />

New TWIC pgn import with (optional) cobalt2 theme:

<img width="500" height="304" alt="Screenshot_20251204_112424" src="https://github.com/user-attachments/assets/16b9879a-1a68-4cd8-84a3-ff822310359b" />

## 💽 Releases
Check latest **Releases** for a deb, rpm, exe, a MacOS and AppImage installable package.  The deb has been tested against Ubuntu 24, the rpm against Fedora Rawhide, the AppImage against Fedora Kinoite (Rawhide) and the exe file against a Windows 11 virtual machine. The Mac version has not been tested and feedback would be appreciated.

-----------------------------------------------------------------------------------------------------------------------------------------------
ScidCommunity is based on Scid (Shane's Chess Information Database), a multi-platform (Linux, Mac OS X, Windows) chess database application. It is a fork open to user ideas for further improvements.

With ScidCommunity you can maintain a database of chess games, search games by many criteria, view graphical trends, and produce printable reports on players and openings. You can also analyze games with the Xboard or UCI compatible chess program, play online on FICS, and even use ScidCommunity to study endings with endgame tablebases.

ScidCommunity is free software and is released under the GPL licence.

## Building from Source

### macOS
```bash
git clone https://github.com/whelanh/scidCommunity.git
cd scidCommunity
./build_app.sh
make install
```

The `ScidCommunity.app` bundle contains the app and can be moved to `/Applications`. You can also create a symbolic link to the executable `ScidCommunity.app/Contents/scid/scid`.

### Linux
Requires: `tcl8.6-dev`, `tk8.6-dev` (or equivalent for your distribution). It will now compile agains tk and tcl 9.0 libraries (e.g. Fedora Rawhide `tcl-devel` and `tk-devel`), but if both 8.6 and 9.0 are available, it defaults to 8.6. 

```sh
git clone https://github.com/whelanh/scidCommunity.git
cd scidCommunity
./configure
make
sudo make install
```

#### CMake Build
```sh
git clone https://github.com/whelanh/scidCommunity.git
cd scidCommunity
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
sudo make install
```

### Pre-built Packages

On Linux, you can use pre-built packages from the Releases page:

- DEB (Ubuntu/Debian): built via GitHub Actions; declares runtime deps `tk8.6, libtcl8.6, libtk8.6`.
- RPM (Fedora/openSUSE): built via GitHub Actions; version taken from the tag; bundles Tcl/Tk libraries and a wrapper script.
- AppImage: self-contained; includes Tcl/Tk 8.6 runtime.

**Notes:**
- The CMake and traditional Linux build produces an executable named `scidCommunity`.
- Versioning of release artifacts follows the git tag (e.g., `v5.1.1`).
- The macOS `Info.plist` version is injected from `SCIDCOMMUNITY_VERSION` when building with `build_app.sh`.


