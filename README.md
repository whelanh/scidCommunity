<p align="center">
<img width="256" height="256" alt="io github whelanh scidCommunity" src="https://github.com/user-attachments/assets/26277294-00cb-4660-964d-f88f4364e9c8" />
</p>

**scidCommunity** differs from upstream `Scid` by offering enhancements not present in the upstream repo. Enhancements include:

1. The **Header Search** dialogue has been improved with the addition of a new "Layouts" button at the lower left. This button replaces a "Save" button that has been disabled for years. The new button allows users to name, save and load sets of search parameters they use frequently.
      - The hotkey Alt + s has been added to invoke the Search button. 
2. The **Engine** windows have been enhanced with new depth and move time input windows for limiting an engine's calculations. If users choose to use Scid's **Save Options**, the inputs will be saved as the defaults for future use.
3. A new **`Download TWIC Games`** option under the **`Tools`** menu that downloads' the most recent weekly games from [TWIC](https://theweekinchess.com/twic) and brings them into scidCommunity for filtering, merging with your database etc.
4. New buttons in the **PGN Window**:
      - *Table Base* looks up current position in the Lichess 7-man endgame table base
      - *chess.com* uploads the current game to Chess.com
      - *lichess.org* uploads the current game to Lichess.org
      - *chessdb Engine Tree* opens the current position in chessdb.cn's tree of engine evaluaitons
6. New (optional) "Sand" and "cobalt2" themes.
7. New light colored buttons added for use in the Engine and Analysis windows when using "dark" and "cobalt2" themes. 
8. Implemented [user request](https://github.com/whelanh/scidCommunity/discussions/10) for better handling of long comments in the Game Info window.
9. Implemented [user request](https://github.com/whelanh/scidCommunity/discussions/13) to allow users to easily import their Lichess and chess.com games.
10. Based on [user request](https://github.com/whelanh/scidCommunity/discussions/12), user can now limit the length of variations in the Analysis Engine annotation function.
11. Implemented [user request](https://github.com/whelanh/scidCommunity/discussions/9) to allow opening Lichess broadcast tournament games.  If a game is ongoing, it will be updated every minute.
12. Connected the new Lichess 7-man table base lookup to the **Finish Game** feature in the **Analysis Engine** window so auto-play doesn't go on longer than necessary. Also **Finish Game** now allows simultaneous time and depth limits on the engines used.
13. Improved "Best Games" button in the Tree View to honor the state of the all_games checkbox
14. Eliminated the dependence on the old Phalanx/Toga engines formerly needed to use the "Play/Tactical Game" feature.

*Users with suggestions for further enhancements are welcome to write something in the Discussion section or submit a pull request.  Enjoy!*

New "Layouts" button with (optional) Sand theme:

<img width="500" height="450" alt="Screenshot_20251203_143244 (Edit)" src="https://github.com/user-attachments/assets/fdf27a66-5ae4-40de-8a86-28db86b29f22" />


New Engine depth and move time input windows:
<img width="638" height="303" alt="image" src="https://github.com/user-attachments/assets/0563010d-b20b-4771-8ef4-7470b8ebc9fb" />


New TWIC pgn import with (optional) cobalt2 theme:

<img width="500" height="304" alt="Screenshot_20251204_112424" src="https://github.com/user-attachments/assets/16b9879a-1a68-4cd8-84a3-ff822310359b" />

New *chess.com* and *lichess.org* buttons:

<img width="500" height="216" alt="Screenshot_2025-12-06_07-27-58 (Edit)" src="https://github.com/user-attachments/assets/64a3c452-4ffb-4ff9-a39a-eac82b066118" />


New *Table Base* button:

<img width="500" height="580" alt="Screenshot_2025-12-06_07-32-02 (Edit)" src="https://github.com/user-attachments/assets/b8becb46-a146-46cd-a8e5-1be7233151fd" />

New functions allowing users to directly download and open up their Lichess and chess.com games

<img width="500" height="370" alt="Screenshot_20251215_081733 (Edit)" src="https://github.com/user-attachments/assets/1139c2ff-cfd1-4245-84de-fe0d6a3e30c6" />

New feature under the "File" menu to open Lichess broadcast tournament games. Opening an ongoing game in the PGN Window triggers automatic game updates every minute.

<img width="500" height="270" alt="Screenshot_20251225_063003" src="https://github.com/user-attachments/assets/4505355c-6247-45bb-af21-b0f64270fb24" />

## 💽 Releases
Check latest **[Releases](https://github.com/whelanh/scidCommunity/releases)** for a deb, rpm, exe, a MacOS and AppImage installable package.  The deb has been tested against Ubuntu 24, the rpm against Fedora Rawhide, the AppImage against Fedora Kinoite (Rawhide) and the exe file against a Windows 11 virtual machine. The Mac version has not been tested and feedback would be appreciated. 

Linux users can install scidCommunity from [Flathub](https://flathub.org/en/apps/io.github.whelanh.scidCommunity), however the Flathub update process is slower. For the most recent developments, see the **[Releases](https://github.com/whelanh/scidCommunity/releases)** section or:
* For rpm based Linux systems, ScidCommunity is also available through the [Fedora Copr Repo](https://copr.fedorainfracloud.org/coprs/whelanh/scidcommunity/)
* For Arch-based systems, it is available on the [AUR](https://aur.archlinux.org/packages/scidcommunity)

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
Requires: `tcl8.6-dev`, `tk8.6-dev` (or equivalent for your distribution). It will now compile against tk and tcl 9.0 libraries (e.g. Fedora Rawhide `tcl-devel` and `tk-devel`), but if both 8.6 and 9.0 are available, it defaults to 8.6. 

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







