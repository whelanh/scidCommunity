# scidCommunity [![GitHub license](https://img.shields.io/badge/license-GPL-blue.svg)](https://github.com/whelanh/scidCommunity/blob/github/COPYING) [![Build Status](https://github.com/whelanh/scidCommunity/actions/workflows/release.yml/badge.svg)](https://github.com/whelanh/scidCommunity/actions/workflows/release.yml) [![CodeQL](https://github.com/whelanh/scidCommunity/actions/workflows/dynamic/github-code-scanning/codeql/badge.svg)](https://github.com/whelanh/scidCommunity/actions/workflows/dynamic/github-code-scanning/codeql) [![codecov](https://codecov.io/gh/whelanh/scidCommunity/branch/github/graph/badge.svg)](https://codecov.io/gh/whelanh/scidCommunity) [![Flathub](https://img.shields.io/flathub/v/io.github.whelanh.scidCommunity)](https://flathub.org/apps/io.github.whelanh.scidCommunity)

<p align="center">
<img width="256" height="256" alt="io github whelanh scidCommunity" src="https://github.com/user-attachments/assets/26277294-00cb-4660-964d-f88f4364e9c8" />
</p>

**scidCommunity** is a powerful chess analysis and database program. Originally derived from `Scid` (Shane's Chess Information Database), it has evolved into a distinct tool with numerous enhancements and a growing community of over 4,400 users around the world.

While it maintains compatibility with the original Scid database formats, **scidCommunity** focuses on modern features like integrations with Lichess and Chess.com, user-requested improvements, and a streamlined experience for analysis and database management. **scidCommunity** is free software and is released under the GPL licence. Third-party notices are in [`docs/third-party-notices.md`](docs/third-party-notices.md).

### Key Enhancements & Features

*Most recent changes:*

1. A user requested the ability to search for a specific word in any game comments in a database (including comments in variations). This has now been implemented and is available under the **Search** menu. [See Discussions](https://github.com/whelanh/scidCommunity/discussions/358)
2. Ctrl + Shift + A from an **Engine Window** instantly adds all the scores and annotations that were already generated from the score graph to the PGN.  Ctrl + Z undoes the same action. [See Discussions](https://github.com/whelanh/scidCommunity/discussions/357)
3. The **marker palette** colour and type are now remembered across restarts instead of reverting to green.
4. Lichess-style hot keys have been implemented that allow users to quickly change arrow colors and square marker colors on the chessboard. This was an excellent user suggestion. [See Discussions](https://github.com/whelanh/scidCommunity/discussions/312) In the same spirit, pressing the **spacebar** now plays the engine's best move (the first line when MultiPV is active) in the **Engine** and **Analysis** windows, and on the main board when an engine is running.
5. "Color picker" buttons have been added to **Options/Preferences/Chessboard** Light and Dark Squares so users can easily replicate chessboard colors they find on-line or in other programs. This user-requested feature is described in  [Discussions/Announcements](https://github.com/whelanh/scidCommunity/discussions/304)

<details>
<summary><b>Show more (older changes) — click to expand</b></summary>

<br>

6. A [user requested](https://github.com/whelanh/scidCommunity/discussions/283) the ability to change comment colors, font, size etc. This is now possible with a new *Format* button in the **Comment Editor** window. Along with that, users can now export formatted PGNs to .rtf files (and import them as well).
7. Based on a [user requst](https://github.com/whelanh/scidCommunity/discussions/282), the **Player Name** setup from Scid vs. PC has been adopted and is available under the **Options** menu.
8. Thanks to a [user request](https://github.com/whelanh/scidCommunity/discussions/264), you can now choose to view multiple opening books (up to 3) in the Book Window.
9. New [feature](https://github.com/whelanh/scidCommunity/discussions/231)  added under the Play menu that integrates playing on the Lechenicher SchachServer (LSS) and on the ICCF server.
10. Based on a [user request](https://github.com/whelanh/scidCommunity/discussions/225), NAG annotations present in your database can be shown in the Tree View if you click the "Annotations" check box. If you right-click a move in the Tree View with an annotation symbol, you can populate a new Game List with just games with a NAG symbol for that move.
11. Drag and drop of database, PGN, and .epd files is [now available](https://github.com/whelanh/scidCommunity/discussions/209). Drag files to either the Board display window or the PGN Window.
12. A long list of chess engines provided by [Lucas Chess](https://github.com/lukasmonk/lucaschessR6) can now be installed with a button click in the **Tools/Configure Engines** window by pressing the new "Lucas Chess" button.
13. Based on a [user request](https://github.com/whelanh/scidCommunity/discussions/188), a dedicated **.epd analysis window** is now [available](https://github.com/whelanh/scidCommunity/discussions/192) (and opens automatically when you open an .epd file).
14. Based on a [user request](https://github.com/whelanh/scidCommunity/discussions/176), it is now possible to open an arbitrarily large number of **Analysis Windows** by double clicking the engines in the **Configure Engines** or **Analysis Window..** pop up dialogs.
15. Daily chess puzzle and more puzzles from Lichess with the new [**Lichess Puzzles**](https://github.com/whelanh/scidCommunity/discussions/167) feature under the **Play** menu.
16. New [engine vs. engine tournament feature](https://github.com/whelanh/scidCommunity/discussions/162) and [PGN Viewer](https://github.com/whelanh/scidCommunity/discussions/161) adopted from [Uwe Klimmek](https://codeberg.org/scid/scid) 
17. Thanks to a [user suggestion](https://github.com/whelanh/scidCommunity/discussions/123), a new **Lichess OpenExplorer** button has been added to the **PGN Window** that provides access to the Lichess Opening Explorer data from the Masters, Lichess, and Player databases.
18. For games with `[%clk ]` time comments, a new **Tools/Time Analysis** [feature](https://github.com/whelanh/scidCommunity/discussions/59) charts clock time remaining and time used per move.
19. Lichess-based calculation of White and Black's "Game Accuracy" [included](https://github.com/whelanh/scidCommunity/discussions/49) in the upper left of the engine score graph in the **Engine Window**.
20. Thanks to a well thought out and detailed [user proposal](https://github.com/whelanh/scidCommunity/discussions/32), developers can now access Scid databases directly in their code using scidCommunity's new headless API.  More documentation can be found in the /docs folder.
21. Users can now see up to 4 half-move sequences in the **Tree Window**   The user's preferred Tree Window move depth can be saved under **Options/Preferences/Moves**
22. Updated language translations in **Options/Language** and added Chinese, Turkish, Serbian Cyrillic, Japanese and Romanian translation files.
23. Based on [user request](https://github.com/whelanh/scidCommunity/discussions/26), now down-arrow enters a variation in the PGN Window, up-arrow returns to main line.  Right-arrow moves forward in both main line and variation.
24. Based on user request, adopted Lichess/ChessBase format for arrows and symbols as the default. User can revert to old Scid format in Options/Preferences/Moves if they want.
25. Add multi-colored arrows for engine analysis in Engine and Analysis windows. Top 3+ engine moves with color-coded arrows: green (Best), yellow (2nd), red (3rd+)
26. Add 2 fold and 3 fold repetition detection to the PGN Window (including when new moves are added).
27. Eliminated the dependence on the old Phalanx/Toga engines formerly needed to use the "Play/Tactical Game" feature.
28. Improved "Best Games" button in the Tree View to honor the state of the all_games checkbox
29. Connected the new Lichess 7-man table base lookup to the **Finish Game** feature in the **Analysis Engine** window so auto-play doesn't go on longer than necessary. Also **Finish Game** now allows simultaneous time and depth limits on the engines used.
30. Implemented [user request](https://github.com/whelanh/scidCommunity/discussions/9) to allow opening Lichess broadcast tournament games.  If a game is ongoing, it will be updated every minute.
31. Based on [user request](https://github.com/whelanh/scidCommunity/discussions/12), user can now limit the length of variations in the Analysis Engine annotation function.
32. Implemented [user request](https://github.com/whelanh/scidCommunity/discussions/13) to allow users to easily import their Lichess and chess.com games.
33. Implemented [user request](https://github.com/whelanh/scidCommunity/discussions/10) for better handling of long comments in the Game Info window.
34. New light colored buttons added for use in the Engine and Analysis windows when using "dark" and "cobalt2" themes. 
35. New (optional) "Sand" and "cobalt2" themes. Additionally, 13 polished TTK themes (6 dark, 7 light) with custom widget styling by [Uwe Klimmek](https://codeberg.org/scid/ttk-themes) are bundled, along with matching dark toolbar icons.
36. New buttons in the **PGN Window**:
      - *Table Base* looks up current position in the Lichess endgame table base
      - *chess.com* uploads the current game to Chess.com
      - *lichess.org* uploads the current game to Lichess.org
      - *chessdb Engine Tree* opens the current position in chessdb.cn's tree of engine evaluaitons
      - *Lichess Eval* gets any engine evaluations stored on Lichess for the current position (see the Lichess API for more detail)
      - *Lichess OpenExplore* retrieves data from Lichess's Opening Explorer for the current position  
37. A new **`Download TWIC Games`** option under the **`Tools`** menu that downloads' the most recent weekly games from [TWIC](https://theweekinchess.com/twic) and brings them into scidCommunity for filtering, merging with your database etc.
38. The **Engine** windows have been enhanced:
      - New depth and move time input windows for limiting an engine's calculations. If users choose to use Scid's **Save Options**, the inputs will be saved as the defaults for future use.
      - Thanks to a [user suggestion](https://github.com/whelanh/scidCommunity/discussions/38), the Engine Window upper panel now pre-populates with stored evaluations from Lichess if they are available and it caches local engine results if they get to a deeper level than the pre-populated PVs.
      - New *Auto Comment* button attempts to inject a meaningful comment for the current move from AI, while *Game Comment* button will provide comments for moves that have annotations and a game summary. Game Comment needs an AI provider and a model first: choose Gemini, DeepSeek, Ollama Cloud, any OpenAI-compatible endpoint, a local server or OpenCode Console once in its Settings dialog. With none selected it writes no prose, and no commentary request leaves the machine until one is chosen. Ollama Cloud is a named channel because its hosted service keeps the native API at `https://ollama.com/api` and the OpenAI-compatible one at `https://ollama.com/v1` — and `/api` is the root people paste, which answers 404 on every `/v1` path — so the settings ask for a key and a model, never for that URL. The channel itself speaks the native API (`api/chat`, `api/tags`): the compatibility layers are documented subsets of it, the answer arrives in `message.content` with any thinking kept in its own field, and `api/tags` says which models can chat at all, so a decision-only model is never offered. A request that fails now reports the HTTP status and the endpoint's own message (a redirect, a 401 with no key sent, a body that is not a chat reply), so a wrong URL no longer looks like a wrong model name.
39. The **Header Search** dialogue has been improved with the addition of a new "Layouts" button at the lower left. This button replaces a "Save" button that has been disabled for years. The new button allows users to name, save and load sets of search parameters they use frequently.
      - The hotkey Alt + s has been added to invoke the Search button.
      - An "Invert Search" button has been added that allows you to filter OUT all games that DO meet the criteria entered (see more [here](https://github.com/whelanh/scidCommunity/discussions/67)).

</details>

*Users with suggestions for further enhancements are welcome to write something in the Discussion section or submit a pull request.  Enjoy!*

### 📸 scidCommunity in Action

| New "Layouts" Button | Engine Depth/Time Inputs |
| :---: | :---: |
| <img width="400" alt="Layouts button" src="https://github.com/user-attachments/assets/fdf27a66-5ae4-40de-8a86-28db86b29f22" /> | <img width="400" alt="Engine inputs" src="https://github.com/user-attachments/assets/0563010d-b20b-4771-8ef4-7470b8ebc9fb" /> |
| **TWIC PGN Import** | **Lichess & Chess.com Buttons** |
| <img width="400" alt="TWIC import" src="https://github.com/user-attachments/assets/16b9879a-1a68-4cd8-84a3-ff822310359b" /> | <img width="400" alt="Service buttons" src="https://github.com/user-attachments/assets/64a3c452-4ffb-4ff9-a39a-eac82b066118" /> |
| **Table Base Lookup** | **Direct Game Download** |
| <img width="400" alt="Table base" src="https://github.com/user-attachments/assets/b8becb46-a146-46cd-a8e5-1be7233151fd" /> | <img width="400" alt="Direct download" src="https://github.com/user-attachments/assets/1139c2ff-cfd1-4245-84de-fe0d6a3e30c6" /> |
| **Lichess Broadcasts** |  **Move Sequences In Tree Window** |
| <img width="400" alt="Broadcasts" src="https://github.com/user-attachments/assets/4505355c-6247-45bb-af21-b0f64270fb24" /> | <img width="994" height="451" alt="Screenshot_20260203_170414" src="https://github.com/user-attachments/assets/9e16b955-5660-47dc-8cdd-a4684e1979b6" />
 |



## 💽 Releases
Check latest **[Releases](https://github.com/whelanh/scidCommunity/releases)** for a deb, rpm, a Windows exe, a MacOS and AppImage installable package.  The deb has been tested against Ubuntu 24, the rpm against Fedora Rawhide, the AppImage against Fedora Kinoite (Rawhide) and the exe file against a Windows 11 virtual machine. The Mac version appears to be blocked by Apple's security protocols.  However if you build it yourself on a Mac (see below), you can run it by invoking it from the terminal. 

Linux users can install scidCommunity from [Flathub](https://flathub.org/en/apps/io.github.whelanh.scidCommunity), however the Flathub update process is slower. The Flatpak is installed with limited access to your file system.  You will probably want to grant it access to your home directories for storing preferences and accessing your stored database.  You can do that with the **Flatseal** flatpak, or with the terminal command `flatpak override --user io.github.whelanh.scidCommunity --filesystem=home` or `flatpak override --user io.github.whelanh.scidcommunity --filesystem=/path/to/directory`

For the most recent developments, see the **[Releases](https://github.com/whelanh/scidCommunity/releases)** section or:
* For rpm based Linux systems, ScidCommunity is also available through the [Fedora Copr Repo](https://copr.fedorainfracloud.org/coprs/whelanh/scidcommunity/)
* For Arch-based systems, it is available on the [AUR](https://aur.archlinux.org/packages/scidcommunity) 
* **scidCommunity** is also available from the [Snap Store](https://snapcraft.io/scidcommunity).  See the section below if you are an Ubuntu or Kubuntu user.

**Windows Users** are advised to use the "setup.exe" in the **Releases** section.  You may need to use a browser other than Edge (e.g., Chrome or Firefox) to succesfully download the .exe file.

**Ubuntu/Kubuntu Users**  If you try and install the .deb pacakage from **Releases** using the Kubuntu App Center (Discover) or Ubuntu App Center, recent Ubuntu/Kubuntu versions frequently intercepts local .deb files, searches its store, and installs the sandboxed Snap version instead.  The Snap version is sandboxed with limited permissions.  scidCommunity's file chooser in the Snap version, for example, can't see your home directory unless you run `sudo snap connect scidcommunity:home` in a terminal. To actually install the .deb file from **Releases**, open a terminal and run `sudo snap remove scidcommunity --purge` (if you used the App Center before) and then run `sudo apt install ./scidcommunity-5.1.3.97-Linux.deb` (using the correct version number) from the directory where you downloaded the .deb file (most likely `~/Downloads`). 

## Building from Source

### macOS
The `ScidCommunity.app` bundle in **Releases** contains the app and it can be moved to `/Applications`. You can also create a symbolic link to the executable `ScidCommunity.app/Contents/scid/scid`.  **However Apple security protocols may prevent this or make it difficult to do.**

You are probably going to have better luck if you build it from source using these commands:
```bash
git clone https://github.com/whelanh/scidCommunity.git
cd scidCommunity
./build_app.sh
make install
```

You can then invoke it from the scidCommunity folder using the terminal command `./scidCommunity`   You may need to run `./build_app.sh` several times for Apple to download the needed tcl/tk libraries.

### Linux
Requires: `tcl8.6-dev`, `tk8.6-dev` (or equivalent for your distribution). It will now compile against tk and tcl 9.0 libraries (e.g. Fedora Rawhide `tcl-devel` and `tk-devel`).

**Sound Support**: scidCommunity uses a multi-backend audio system that attempts to find the best available player on your system.
- **Linux**: Works with `pw-play` (PipeWire), `paplay` (PulseAudio), `aplay` (ALSA), or the `tcl-snack` package.
- **Windows**: Uses `powershell` or the included `scidsnd.exe`.
- **macOS**: Uses `afplay`.

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

## Contributors

- **[Hugh Whelan](https://github.com/whelanh)** — maintainer
- **[Venkat Krishnamurthy](https://github.com/kayvee42)** — focuses on the macOS version (build, packaging and platform fixes) and redesigned the PGN Window buttons
- **[David Crandall](https://github.com/Triquetra)** — AI provider channels for Game Comment (local, OpenAI-compatible and OpenCode models) and the game review feature in progress


### Acknowledgements

Thanks to [Uwe Klimmek](https://codeberg.org/scid/scid) for the [scid](https://codeberg.org/scid/scid) source code from his fork which is responsible for the enhanced look of the buttons below the Chessboard, the engine settings dialog, and PGN Viewer.  Thanks also to [@steveannus](https://github.com/steveannus) and the *Scid vs. PC* codebase for features adopted like *My Player Names* and the ability to view multiple books in the **Book Window**.




