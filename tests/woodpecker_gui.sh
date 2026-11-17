#!/bin/sh
# Copyright (C) 2026 Tommaso Bergamasco
# SPDX-License-Identifier: GPL-2.0-or-later
#
# woodpecker_gui.sh -- run tests/woodpecker_gui.tcl inside the real GUI, with
# a clean profile. Needs a display (xvfb-run on a headless machine):
#
#   xvfb-run -a tests/woodpecker_gui.sh build/scidCommunity
#
# The binary must find tcl/start.tcl (an installed build, or the repository's
# tcl/ next to it) and report the version start.tcl expects.

set -u
BIN=${1:-}
if [ -z "$BIN" ] || [ ! -x "$BIN" ]; then
    echo "usage: $0 <path-to-scidCommunity>" >&2
    exit 2
fi
HERE=$(cd "$(dirname "$0")" && pwd)
TMP=$(mktemp -d "${TMPDIR:-/tmp}/woodpecker-gui.XXXXXX") || exit 2
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
HOME="$TMP/home"
export HOME
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$HOME"
# A first start creates the user folder; its name carries the version.
timeout 20 "$BIN" >/dev/null 2>&1
USERDIR=$(find "$HOME" -maxdepth 3 -type d \( -name ".scid*" -o -name scidCommunity \) | head -n 1)
if [ -z "$USERDIR" ]; then
    echo "FAIL: no user folder after a first start" >&2
    exit 1
fi
mkdir -p "$USERDIR/plugins"
cp "$HERE/woodpecker_gui.tcl" "$USERDIR/plugins/zz_woodpecker_gui.tcl"
WOODPECKER_GUI_RESULT="$TMP/result.txt"
export WOODPECKER_GUI_RESULT
timeout 120 "$BIN" >"$TMP/out" 2>&1
if [ ! -s "$WOODPECKER_GUI_RESULT" ]; then
    echo "FAIL: the GUI test wrote no result" >&2
    cat "$TMP/out" >&2
    exit 1
fi
cat "$WOODPECKER_GUI_RESULT"
grep -q " 0 failures" "$WOODPECKER_GUI_RESULT"
