#!/usr/bin/env sh
# Generate app icons (GIF/ICO/PNG) from a source SVG.
# Requirements: rsvg-convert (or inkscape) and ImageMagick's convert.
# Usage:
#   scripts/generate_app_icons.sh [source_svg]
# Defaults to data/io.github.whelanh.scidCommunity.svg

set -eu

SRC_SVG=${1:-data/io.github.whelanh.scidCommunity.svg}

if [ ! -f "$SRC_SVG" ]; then
  echo "Source SVG not found: $SRC_SVG" >&2
  exit 1
fi

# Resolve repo root relative paths
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
IMG_DIR="$REPO_ROOT/img"
WIN_DIR="$REPO_ROOT/resources/win"
SVG_DIR="$REPO_ROOT/resources/svg"
FLATPAK_DIR="$REPO_ROOT/flatpak"
DATA_DIR="$REPO_ROOT/data"

# Ensure output directories exist
mkdir -p "$IMG_DIR" "$WIN_DIR" "$SVG_DIR"

# Check tools
have_rsvg=0
have_inkscape=0
have_convert=0
command -v rsvg-convert >/dev/null 2>&1 && have_rsvg=1 || true
command -v inkscape >/dev/null 2>&1 && have_inkscape=1 || true
command -v convert >/dev/null 2>&1 && have_convert=1 || true

if [ "$have_convert" -ne 1 ]; then
  echo "ImageMagick 'convert' is required. Install imagemagick." >&2
  exit 1
fi

render_png() {
  # $1 size, $2 outpath
  size="$1"
  out="$2"
  if [ "$have_rsvg" -eq 1 ]; then
    rsvg-convert -w "$size" -h "$size" -f png -o "$out" "$SRC_SVG"
  elif [ "$have_inkscape" -eq 1 ]; then
    inkscape "$SRC_SVG" --export-type=png --export-width="$size" --export-height="$size" --export-filename="$out" >/dev/null 2>&1
  else
    echo "Need either rsvg-convert or inkscape to render PNGs." >&2
    exit 1
  fi
}

# Temporary workspace
TMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

# Sizes to generate
SIZES="16 32 48 64 128 256"

ICON_PNGS=""
for s in $SIZES; do
  out_png="$TMP_DIR/icon_${s}.png"
  render_png "$s" "$out_png"
  ICON_PNGS="$ICON_PNGS $out_png"
  echo "Rendered $out_png"
done

# 1) Update desktop scalable SVG copies (optional)
if [ -f "$FLATPAK_DIR/io.github.whelanh.scidCommunity.svg" ]; then
  cp -f "$SRC_SVG" "$FLATPAK_DIR/io.github.whelanh.scidCommunity.svg"
  echo "Updated $FLATPAK_DIR/io.github.whelanh.scidCommunity.svg"
fi
if [ -f "$DATA_DIR/io.github.whelanh.scidCommunity.svg" ]; then
  cp -f "$SRC_SVG" "$DATA_DIR/io.github.whelanh.scidCommunity.svg"
  echo "Updated $DATA_DIR/io.github.whelanh.scidCommunity.svg"
fi

# 2) Generate Windows ICO with multiple sizes
convert $ICON_PNGS "$WIN_DIR/scid.ico"
cp -f "$WIN_DIR/scid.ico" "$SVG_DIR/scid.ico" 2>/dev/null || true
echo "Wrote Windows ICO: $WIN_DIR/scid.ico"

# 3) Generate app GIF and PNG for Tcl wm icon (64px)
if [ -f "$TMP_DIR/icon_64.png" ]; then
  cp -f "$TMP_DIR/icon_64.png" "$IMG_DIR/scid.png"
  convert -background none -alpha on "$IMG_DIR/scid.png" "$IMG_DIR/scid.gif"
  echo "Wrote Tcl icon: $IMG_DIR/scid.png (preferred) and $IMG_DIR/scid.gif (fallback)"
else
  echo "Error: icon_64.png not found in temp directory" >&2
  exit 1
fi

cat << 'EOF'

Done.
If tools are missing, install:
- Debian/Ubuntu: sudo apt-get install librsvg2-bin inkscape imagemagick
- Fedora: sudo dnf install librsvg2-tools inkscape ImageMagick

Notes:
- Desktop entries use 'Icon=io.github.whelanh.scidCommunity' which points to the installed SVG.
- Windows resources reference resources/win/scid.ico (updated above).
- Tcl app icon loads img/scid.gif; this script regenerates it.
EOF
