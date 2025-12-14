#!/usr/bin/env sh
# Generate a single 64x64 PNG icon from SVG for use in img/scid.png
# This is a simple wrapper; run inside distrobox if needed.
# Usage: distrobox enter ubuntu24 -- ./scripts/gen_png_icon.sh

set -eu

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC_SVG="${REPO_ROOT}/data/io.github.whelanh.scidCommunity.svg"
OUT_PNG="${REPO_ROOT}/img/scid.png"

if [ ! -f "$SRC_SVG" ]; then
  echo "Source SVG not found: $SRC_SVG" >&2
  exit 1
fi

# Try rsvg-convert first, then inkscape
if command -v rsvg-convert >/dev/null 2>&1; then
  echo "Rendering PNG with rsvg-convert..."
  rsvg-convert -w 64 -h 64 -f png -o "$OUT_PNG" "$SRC_SVG"
elif command -v inkscape >/dev/null 2>&1; then
  echo "Rendering PNG with inkscape..."
  inkscape "$SRC_SVG" --export-type=png --export-width=64 --export-height=64 --export-filename="$OUT_PNG" >/dev/null 2>&1
else
  echo "Error: need rsvg-convert or inkscape" >&2
  exit 1
fi

if [ -f "$OUT_PNG" ]; then
  echo "Successfully created: $OUT_PNG"
else
  echo "Error: failed to create PNG" >&2
  exit 1
fi
