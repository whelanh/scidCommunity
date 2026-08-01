#!/bin/bash

set -e

if [ -z "$Build_SourcesDirectory" ]; then
  Build_SourcesDirectory=$(pwd)
fi

cd $Build_SourcesDirectory
mkdir -p tcltk && cd tcltk
git clone --depth=1 --branch core-8-6-15 https://github.com/tcltk/tcl.git
cd tcl/unix
./configure --prefix=$Build_SourcesDirectory/tcltk --enable-64bit --disable-shared
make -j
make install

cd $Build_SourcesDirectory
mkdir -p tcltk && cd tcltk
git clone --depth=1 --branch core-8-6-15 https://github.com/tcltk/tk.git
cd tk/unix
./configure --prefix=$Build_SourcesDirectory/tcltk --enable-64bit --enable-aqua
make -j
make install

# Workaround: on newer macOS/Xcode, the SDK may ship a system tk.h (8.5, X11-based)
# that can shadow the built 8.6 Aqua tk.h during compilation. Ensure the built
# Tk headers are explicitly copied to the include directory.
cd $Build_SourcesDirectory/tcltk/tk
for h in generic/tk.h generic/tkDecls.h generic/tkPlatDecls.h macosx/tkMacOSX.h \
         macosx/tkMacOSXDefault.h macosx/tkMacOSXInt.h macosx/tkMacOSXPort.h \
         generic/tkText.h; do
    if [ -f "$h" ] && [ ! -f "$Build_SourcesDirectory/tcltk/include/$(basename "$h")" ]; then
        cp "$h" "$Build_SourcesDirectory/tcltk/include/"
    fi
done

cd $Build_SourcesDirectory
mkdir -p ScidCommunity.app/Contents
cp -R $Build_SourcesDirectory/resources/macos ScidCommunity.app/Contents/Resources
mv ScidCommunity.app/Contents/Resources/Info.plist ScidCommunity.app/Contents
cp -R $Build_SourcesDirectory/tcltk/lib ScidCommunity.app/Contents
rm -f ScidCommunity.app/Contents/lib/*.a
rm -f ScidCommunity.app/Contents/lib/*.sh
rm -Rf ScidCommunity.app/Contents/lib/pkgconfig

# Inject dynamic version into Info.plist if SCIDCOMMUNITY_VERSION is set
if [ -n "$SCIDCOMMUNITY_VERSION" ]; then
  PLIST="ScidCommunity.app/Contents/Info.plist"
  # Update CFBundleGetInfoString ("ScidCommunity X")
  sed -i'' -e "s|<key>CFBundleGetInfoString</key>[[:space:]]*<string>[^<]*</string>|<key>CFBundleGetInfoString</key>\n    <string>ScidCommunity $SCIDCOMMUNITY_VERSION</string>|" "$PLIST"
  # Update CFBundleShortVersionString
  sed -i'' -e "s|<key>CFBundleShortVersionString</key>[[:space:]]*<string>[^<]*</string>|<key>CFBundleShortVersionString</key>\n    <string>$SCIDCOMMUNITY_VERSION</string>|" "$PLIST"
fi

cd $Build_SourcesDirectory
if [[ "$(uname)" == "Darwin" ]]; then
  EXTRA_TCL_LIBS="-lz -framework CoreFoundation"
else
  EXTRA_TCL_LIBS="-lz -ldl"
fi

tcltk/bin/tclsh8.6 configure \
  TCL_VERSION=8.6 \
  LIBS="$EXTRA_TCL_LIBS" \
  TCL_INCLUDE="-I$Build_SourcesDirectory/tcltk/include" \
  TCL_LIBRARY="-L$Build_SourcesDirectory/tcltk/lib -ltcl8.6 -ltk8.6" \
  SHAREDIR="$Build_SourcesDirectory/ScidCommunity.app/Contents/scid" \
  BINDIR="$Build_SourcesDirectory/ScidCommunity.app/Contents/MacOS"

echo "Type \"make install\" to build the ScidCommunity.app."
