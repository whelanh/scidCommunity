#!/bin/bash

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
# LAYOUT_WITH_BASE_CHUNKS is not thread safe
sed -i'' -e '/define TK_LAYOUT_WITH_BASE_CHUNKS/d' tk/macosx/tkMacOSXInt.h
sed -i'' -e '/define TK_DRAW_IN_CONTEXT/d' tk/macosx/tkMacOSXInt.h
cd tk/unix
./configure --prefix=$Build_SourcesDirectory/tcltk --enable-64bit --enable-aqua
make -j
make install

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
  STATIC_FLAGS="-lz -framework CoreFoundation"
else
  STATIC_FLAGS="-lz -ldl"
fi

tcltk/bin/tclsh8.6 configure \
  LINK="g++ $STATIC_FLAGS" \
  TCL_INCLUDE="-I$Build_SourcesDirectory/tcltk/include" \
  TCL_LIBRARY="-L$Build_SourcesDirectory/tcltk/lib -ltcl8.6 -ltk8.6" \
  SHAREDIR="$Build_SourcesDirectory/ScidCommunity.app/Contents/scid" \
  BINDIR="$Build_SourcesDirectory/ScidCommunity.app/Contents/MacOS"

echo "Type \"make install\" to build the ScidCommunity.app."
