#!/usr/bin/env python3
"""
Downloads ModernWood Staunton chess pieces from:
  https://github.com/clarkerubber/Staunton-Pieces

Resizes them proportionally (so pawns stay shorter than kings/queens)
and packs them into scidCommunity-compatible horizontal PNG strips.

Usage:
    python3 scripts/download_staunton_pieces.py

The output is written to:
    img/pieces/staunton_modern_wood/
"""

import os
import sys
import urllib.request
from io import BytesIO
from PIL import Image

# ---------------------------------------------------------------------------
# Scid piece order: wp wn wb wr wq wk bp bn bb br bq bk
#
# Black knight and bishop use the "-Flipped" variants so they face their
# white counterparts (as is conventional in chess diagrams).
# ---------------------------------------------------------------------------
PIECES = {
    'wp': 'White-Pawn.png',
    'wn': 'White-Knight.png',
    'wb': 'White-Bishop.png',
    'wr': 'White-Rook.png',
    'wq': 'White-Queen.png',
    'wk': 'White-King.png',
    'bp': 'Black-Pawn.png',
    'bn': 'Black-Knight-Flipped.png',
    'bb': 'Black-Bishop-Flipped.png',
    'br': 'Black-Rook.png',
    'bq': 'Black-Queen.png',
    'bk': 'Black-King.png',
}
ORDER = ['wp', 'wn', 'wb', 'wr', 'wq', 'wk', 'bp', 'bn', 'bb', 'br', 'bq', 'bk']

# Use the 180px renders as the source (highest quality before scaling down).
BASE_URL = (
    "https://raw.githubusercontent.com/clarkerubber/Staunton-Pieces"
    "/master/Renders/ModernWood/Scaled/180/{filename}"
)

STYLE_NAME = "staunton_modern_wood"

# Sizes supported by scidCommunity
SIZES = [25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 120]


def download_piece(filename: str) -> Image.Image:
    """Download a single PNG and return it as a Pillow Image."""
    url = BASE_URL.format(filename=filename)
    print(f"  Downloading {filename} ...", end=" ", flush=True)
    try:
        with urllib.request.urlopen(url) as response:
            data = response.read()
        img = Image.open(BytesIO(data)).convert("RGBA")
        print("OK")
        return img
    except Exception as exc:
        print(f"FAILED\nError fetching {url}: {exc}", file=sys.stderr)
        sys.exit(1)


def tight_crop(img: Image.Image) -> Image.Image:
    """Crop image to the bounding box of its non-transparent pixels."""
    bbox = img.getbbox()
    return img.crop(bbox) if bbox else img


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    output_dir = os.path.join(project_root, "img", "pieces", STYLE_NAME)
    os.makedirs(output_dir, exist_ok=True)

    print(f"Piece set : {STYLE_NAME}")
    print(f"Output    : {output_dir}\n")

    # 1. Download and tight-crop all 12 pieces
    print("Downloading pieces:")
    pieces: dict[str, Image.Image] = {}
    for key in ORDER:
        raw = download_piece(PIECES[key])
        pieces[key] = tight_crop(raw)

    # 2. Determine the shared scale reference.
    #    All pieces are scaled by the same factor (derived from the tallest
    #    piece – the king) so that their natural height ratios are preserved.
    #    This ensures pawns remain visibly smaller than back-rank pieces.
    max_height = max(img.size[1] for img in pieces.values())

    try:
        resample = Image.Resampling.LANCZOS
    except AttributeError:
        resample = Image.ANTIALIAS  # Pillow < 9

    # 3. Generate one strip per Scid board size
    print(f"\nGenerating strips (tallest source piece = {max_height}px):")
    for size in SIZES:
        shared_scale = size / max_height
        strip = Image.new("RGBA", (size * 12, size), (0, 0, 0, 0))

        for idx, key in enumerate(ORDER):
            tile = pieces[key]
            pw, ph = tile.size
            new_w = max(1, int(pw * shared_scale))
            new_h = max(1, int(ph * shared_scale))

            resized = tile.resize((new_w, new_h), resample)

            # Centre horizontally; bottom-align so piece bases sit on the
            # same baseline (shorter pieces don't float in the middle).
            x_off = (size - new_w) // 2
            y_off = size - new_h
            strip.paste(resized, (idx * size + x_off, y_off))

        out_path = os.path.join(output_dir, f"{STYLE_NAME}_{size}.png")
        strip.save(out_path)
        print(f"  {STYLE_NAME}_{size}.png")

    # 4. Write a credits file
    credits_path = os.path.join(output_dir, "CREDITS.txt")
    with open(credits_path, "w") as f:
        f.write("""\
ModernWood Staunton Chess Pieces
==================================

  Creator  : clarkerubber (Clark Rubberubber)
             https://github.com/clarkerubber

  Source   : https://github.com/clarkerubber/Staunton-Pieces
             Renders/ModernWood/Scaled/

  License  : MIT License
             Copyright (c) 2014 clarkerubber
             Permission is hereby granted, free of charge, to any person
             obtaining a copy of this software and associated documentation
             files (the "Software"), to deal in the Software without
             restriction, including without limitation the rights to use,
             copy, modify, merge, publish, distribute, sublicense, and/or
             sell copies of the Software, and to permit persons to whom the
             Software is furnished to do so, subject to the following
             conditions: The above copyright notice and this permission notice
             shall be included in all copies or substantial portions of the
             Software.

The original 180×180 px PNG renders were tight-cropped, proportionally scaled
(preserving relative piece heights), and repacked into horizontal PNG strips
compatible with the scidCommunity chess interface.
""")
    print(f"\n  CREDITS.txt written.")
    print(f"\nDone! Restart scidCommunity to see '{STYLE_NAME}' in your piece options.")


if __name__ == "__main__":
    main()
