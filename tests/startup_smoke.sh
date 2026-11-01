#!/bin/sh
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# startup_smoke.sh -- boot the built app with a clean profile.
#
#   tests/startup_smoke.sh build/AppDir/usr/bin/scidCommunity
#
# A clean profile has no options.dat, so Scid restores the built-in "auto"
# layout. That layout docks .engineWin1, whose buttons bar calls into the
# review modules. v5.1.4.50 sourced end.tcl (the startup sequence) before
# those modules, so the window raised
#
#     invalid command name "::reviewui::label"
#
# and the process exited before the event loop. On Windows there is no
# console, so it looked like an instant, silent crash.
#
# The app is given a few seconds and then killed. Still running means startup
# got through the layout and the event loop; any earlier exit is a failure and
# its output is printed, so the traceback lands in the CI log.

set -u

BIN=${1:-}
if [ -z "$BIN" ] || [ ! -x "$BIN" ]; then
    echo "usage: $0 <path-to-scidCommunity>" >&2
    exit 2
fi
case $BIN in
    /*) ;;
    *) BIN="$(pwd)/$BIN" ;;
esac

SECONDS_TO_RUN=${STARTUP_SMOKE_SECONDS:-20}

TMP=$(mktemp -d "${TMPDIR:-/tmp}/scid-startup.XXXXXX") || exit 2
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

# A brand-new home: no options.dat, no saved layout, no databases, no plugins.
HOME="$TMP/home"
export HOME
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$HOME"

echo "booting $BIN with a clean profile in $HOME"
timeout "$SECONDS_TO_RUN" "$BIN" >"$TMP/out" 2>&1
rc=$?

# timeout(1) answers 124 when it had to kill the app: it was still alive.
if [ "$rc" -eq 124 ]; then
    echo "ok: still running after ${SECONDS_TO_RUN}s"
    exit 0
fi

echo "FAIL: exited with status $rc before the event loop" >&2
echo "--- output ---" >&2
cat "$TMP/out" >&2
echo "--------------" >&2
exit 1
