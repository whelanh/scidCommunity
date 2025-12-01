[![Build Status](https://dev.azure.com/beninifulvio/beninifulvio/_apis/build/status/benini.scid?branchName=github)](https://dev.azure.com/beninifulvio/beninifulvio/_build/latest?definitionId=1&branchName=github)
[![codecov](https://codecov.io/gh/benini/scid/branch/github/graph/badge.svg)](https://codecov.io/gh/benini/scid)
[![coverity](https://scan.coverity.com/projects/14455/badge.svg)](https://scan.coverity.com/projects/benini-scid)
[![Documentation](https://img.shields.io/badge/docs-doxygen-blue.svg)](http://scid.sourceforge.net/doxygen/html/files.html)
[![GitHub license](https://img.shields.io/badge/license-GPL-blue.svg)](https://sourceforge.net/p/scid/code/ci/master/tree/COPYING)

**scidCommunity** differs from upstream `Scid` by offering enhancements not present in the upstream repo. Enhancements include:

1. The **Header Search** dialogue has been improved with the addition of a new "Layouts" button at the lower left. This button replaces a "Save" button that has been disabled for years. The new button allows users to name, save and load sets of search parameters they use frequently.
      - The hotkey Alt + s has been added to invoke the search key. 
3. The **Engine** windows have been enhanced with new depth and move time input windows for limiting an engine's calculations. If users choose to use Scid's **Save Options**, the inputs will be saved as the defaults for future use.

Users with suggestions for further enhancements are welcome to file an issue or a pull request.  Enjoy!

New "Layouts" button:
<img width="1308" height="1219" alt="Screenshot_20251201_131517 (Edit)" src="https://github.com/user-attachments/assets/848be802-86f4-4b6f-9938-ef047f2dc6bc" />

New Engine depth and move time input windows:
<img width="1918" height="911" alt="image" src="https://github.com/user-attachments/assets/0563010d-b20b-4771-8ef4-7470b8ebc9fb" />

-----------------------------------------------------------------------------------------------------------------------------------------------
Scid (Shane's Chess Information Database) is a multi-platform (Linux, Mac OS X, Windows) chess database application.

With Scid you can maintain a database of chess games, search games by many criteria, view graphical trends, and produce printable reports on players and openings. You can also analyze games with the Xboard or UCI compatible chess program, play online on FICS, and even use Scid to study endings with endgame tablebases.

Scid is free software and is released under the GPL licence.
In Linux and macOS, the build process is straightforward:

```bash
git clone --depth=1 https://git.code.sf.net/p/scid/code scid-code
cd scid-code
./build_app.sh
make install
```

The `Scid.app` folder contains the app, which can be moved to other directories, such as `/Applications`. It is also possible to create a symbolic link to the executable `Scid.app/Contents/scid/scid`.


