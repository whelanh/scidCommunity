#!/usr/bin/env python3
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Regenerate the engine window's review icons (24x24, light and _white).
#
#   python3 scripts/generate_review_icons.py
#
# The icons are thin-line drawings at 8x, downsampled to 24 px, so they match
# the engine toolbar's other icons. Pillow is the only dependency; the font is
# whichever of the usual Liberation/DejaVu bold faces is installed.
#
# Game Review: a 2x2 board with a star (evaluate the game)
# Move Comment: a pawn with a speech bubble
# What's the Threat?: a warning triangle with ?
# Review Settings: three sliders (not a second gear)
# Cancel: a stop sign, shown only while a pass runs

import math
import os
import sys

from PIL import Image, ImageDraw, ImageFont

S = 8
N = 24 * S

FONTS_BOLD = [
    "/usr/share/fonts/liberation/LiberationSans-Bold.ttf",
    "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
]
FONTS_REGULAR = [
    "/usr/share/fonts/liberation/LiberationSans-Regular.ttf",
    "/usr/share/fonts/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/TTF/DejaVuSans.ttf",
]


def font(paths, size):
    for path in paths:
        if os.path.exists(path):
            return ImageFont.truetype(path, int(size * S))
    raise SystemExit("no usable font found: " + ", ".join(paths))


def canvas():
    return Image.new("RGBA", (N, N), (0, 0, 0, 0))


def sc(*v):
    return tuple(int(round(x * S)) for x in v)


def line(d, xy, color, width=1.8):
    d.line([sc(*p) for p in xy], fill=color,
           width=max(1, int(round(width * S))), joint="curve")


def ellipse(d, box, color, width=1.8, fill=None):
    d.ellipse(sc(*box), outline=color, fill=fill,
              width=max(1, int(round(width * S))))


def rounded(d, box, color, width=1.8, radius=1.2, fill=None):
    d.rounded_rectangle(sc(*box), radius=int(radius * S), outline=color,
                        fill=fill, width=max(1, int(round(width * S))))


def polygon(d, pts, color, width=1.8, fill=None):
    d.polygon([sc(*p) for p in pts], outline=color, fill=fill,
              width=max(1, int(round(width * S))))


def star(d, cx, cy, r, color, width=1.5, fill=None):
    pts = []
    for k in range(10):
        angle = math.radians(-90 + 36 * k)
        radius = r if k % 2 == 0 else r * 0.45
        pts.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))
    d.polygon([sc(*p) for p in pts], outline=color, fill=fill,
              width=max(1, int(round(width * S))))


def board(d, color, x0, y0, cell, squares=2):
    rounded(d, (x0, y0, x0 + squares * cell, y0 + squares * cell), color, 1.6, 1.0)
    for i in range(1, squares):
        line(d, [(x0 + i * cell, y0), (x0 + i * cell, y0 + squares * cell)], color, 1.1)
    for j in range(1, squares):
        line(d, [(x0, y0 + j * cell), (x0 + squares * cell, y0 + j * cell)], color, 1.1)
    for i in range(squares):
        for j in range(squares):
            if (i + j) % 2 == 0:
                d.rectangle(sc(x0 + i * cell + 0.7, y0 + j * cell + 0.7,
                               x0 + (i + 1) * cell - 0.7, y0 + (j + 1) * cell - 0.7),
                            fill=color)


def game_review(color):
    im = canvas()
    d = ImageDraw.Draw(im)
    board(d, color, 1.5, 2.0, 5.0)
    star(d, 17.5, 17.5, 5.6, color, 1.5, fill=color)
    return im


def move_comment(color):
    # A solid pawn, so the icon carries the same weight as the board and the
    # sliders even at 24 px; the bubble stays an outline so the dots read.
    im = canvas()
    d = ImageDraw.Draw(im)
    ellipse(d, (4.0, 3.0, 10.0, 9.0), color, 1.8, fill=color)
    polygon(d, [(5.0, 9.0), (9.0, 9.0), (10.0, 16.5), (4.0, 16.5)], color, 1.8, fill=color)
    line(d, [(3.2, 19.0), (10.8, 19.0)], color, 2.4)
    rounded(d, (12.0, 3.0, 23.0, 11.5), color, 2.2, 1.6)
    polygon(d, [(14.0, 11.0), (18.0, 11.0), (15.0, 14.5)], color, 2.2)
    for cx in (15.4, 17.6, 19.8):
        d.ellipse(sc(cx - 0.8, 6.8, cx + 0.8, 8.4), fill=color)
    return im


def threat(color):
    im = canvas()
    d = ImageDraw.Draw(im)
    polygon(d, [(12, 2.8), (21.8, 20.5), (2.2, 20.5)], color, 2.0)
    d.text(sc(12, 14.8), "?", font=font(FONTS_REGULAR, 9.5), fill=color, anchor="mm")
    return im


def review_settings(color):
    im = canvas()
    d = ImageDraw.Draw(im)
    for y, x in ((6.5, 8.0), (12.0, 16.0), (17.5, 11.0)):
        line(d, [(2.2, y), (21.8, y)], color, 1.8)
        d.ellipse(sc(x - 2.2, y - 2.2, x + 2.2, y + 2.2), fill=color)
    return im


def cancel(color):
    im = canvas()
    d = ImageDraw.Draw(im)
    cx = cy = 12.0
    r = 9.4
    pts = []
    for k in range(8):
        angle = math.radians(22.5 + 45 * k)
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    polygon(d, pts, color, 2.0)
    line(d, [(6.4, 12), (17.6, 12)], color, 2.6)
    return im


ICONS = {
    "game": game_review,
    "move": move_comment,
    "threat": threat,
    "settings": review_settings,
    "stop": cancel,
}

DARK = (25, 25, 25, 255)
WHITE = (245, 245, 245, 255)


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    # The buttons reference ::icon::tb_review_* like the PGN window's toolbar;
    # configure_style recreates these images on a theme change, so an open
    # window changes with the theme.
    for name, draw in ICONS.items():
        for folder, color in (("icons_light", DARK), ("icons_dark", WHITE)):
            path = os.path.join(root, "img", folder, "tb_review_%s.png" % name)
            draw(color).resize((24, 24), Image.LANCZOS).save(path)
            print(path)


if __name__ == "__main__":
    sys.exit(main())
