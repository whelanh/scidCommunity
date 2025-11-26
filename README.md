[![Build Status](https://dev.azure.com/beninifulvio/beninifulvio/_apis/build/status/benini.scid?branchName=github)](https://dev.azure.com/beninifulvio/beninifulvio/_build/latest?definitionId=1&branchName=github)
[![codecov](https://codecov.io/gh/benini/scid/branch/github/graph/badge.svg)](https://codecov.io/gh/benini/scid)
[![coverity](https://scan.coverity.com/projects/14455/badge.svg)](https://scan.coverity.com/projects/benini-scid)
[![Documentation](https://img.shields.io/badge/docs-doxygen-blue.svg)](http://scid.sourceforge.net/doxygen/html/files.html)
[![GitHub license](https://img.shields.io/badge/license-GPL-blue.svg)](https://sourceforge.net/p/scid/code/ci/master/tree/COPYING)

**My main "github" fork differs from upstream as it incorporates https://github.com/benini/scid/pull/212 and https://github.com/benini/scid/pull/213. If you like one change and not the other, you can build from their respective branches on this repo.**

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

Please report issues and bugs here:
https://sourceforge.net/projects/scid/  
For other problems or support, try reaching out to the mailing list:
https://sourceforge.net/p/scid/mailman/
