#!/usr/bin/env sh
# Generate Windows ICO from existing PNG (new app icon)
# Uses ImageMagick `convert`. Run inside an environment that has it (e.g., distrobox ubuntu).
# Source PNG defaults to img/scid.png; output written to resources/win/scid.ico and resources/svg/scid.ico.

set -eu

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC_PNG="${1:-${REPO_ROOT}/img/scid.png}"
WIN_ICO="${REPO_ROOT}/resources/win/scid.ico"
SVG_ICO="${REPO_ROOT}/resources/svg/scid.ico"

if [ ! -f "$SRC_PNG" ]; then
  echo "Source PNG not found: $SRC_PNG" >&2
  exit 1
fi

if ! command -v convert >/dev/null 2>&1; then
  echo "ImageMagick 'convert' is required. Install imagemagick." >&2
  exit 1
fi

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

# Prepare multiple sizes for a proper multi-resolution ICO
for s in 16 32 48 64 128 256; do
  convert "$SRC_PNG" -resize ${s}x${s} "$TMP_DIR/icon_${s}.png"
done

# Write ICO with all sizes
convert "$TMP_DIR"/icon_*.png "$WIN_ICO"
cp -f "$WIN_ICO" "$SVG_ICO" 2>/dev/null || true

echo "Wrote ICO: $WIN_ICO"
echo "Copied ICO to: $SVG_ICO (optional copy)"
