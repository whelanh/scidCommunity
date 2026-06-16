#!/usr/bin/env python3
"""
Chess Piece Downloader and Packager for scidCommunity.
Downloads SVG pieces from the Lichess GitHub repository,
converts them to transparent PNGs at various board sizes,
and combines them horizontally in Scid's required layout.

Usage:
    python3 scripts/download_lichess_pieces.py <piece_set_name>

Example:
    python3 scripts/download_lichess_pieces.py cburnett
"""

import sys
import os
import urllib.request
import subprocess
import shutil

# Scid piece order:
# wp wn wb wr wq wk bp bn bb br bq bk
# Corresponding Lichess files:
# wP wN wB wR wQ wK bP bN bB bR bQ bK
PIECES = ['wP', 'wN', 'wB', 'wR', 'wQ', 'wK', 'bP', 'bN', 'bB', 'bR', 'bQ', 'bK']
LICHESS_BASE_URL = "https://raw.githubusercontent.com/lichess-org/lila/master/public/piece/{}/{}.svg"

# Target sizes supported by Scid
SIZES = [25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 120]

def check_convert_installed():
    """Verify ImageMagick's convert tool is available."""
    if shutil.which("convert") is None:
        print("Error: ImageMagick 'convert' tool is not installed or not in PATH.", file=sys.stderr)
        print("Please install ImageMagick to run this script.", file=sys.stderr)
        sys.exit(1)

def main():
    if len(sys.argv) < 2:
        print("Error: Missing piece set name.", file=sys.stderr)
        print("Usage: python3 download_lichess_pieces.py <piece_set_name>", file=sys.stderr)
        print("Example: python3 download_lichess_pieces.py merida", file=sys.stderr)
        sys.exit(1)

    piece_set = sys.argv[1].strip()
    check_convert_installed()

    # Determine paths relative to this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    output_dir = os.path.join(project_root, "img", "pieces", piece_set)
    temp_dir = os.path.join(script_dir, f"temp_{piece_set}")

    print(f"Targeting piece set: {piece_set}")
    print(f"Output directory: {output_dir}")

    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(temp_dir, exist_ok=True)

    # 1. Download all SVGs
    svg_files = {}
    for p in PIECES:
        url = LICHESS_BASE_URL.format(piece_set, p)
        svg_path = os.path.join(temp_dir, f"{p}.svg")
        print(f"Downloading {p}.svg...")
        try:
            urllib.request.urlretrieve(url, svg_path)
            svg_files[p] = svg_path
        except Exception as e:
            print(f"Error downloading {p} from {url}: {e}", file=sys.stderr)
            # Cleanup and exit
            shutil.rmtree(temp_dir, ignore_errors=True)
            sys.exit(1)

    # 2. Render and combine for each target size
    for size in SIZES:
        print(f"Processing size {size}...")
        temp_pngs = []
        
        # Render individual PNGs
        for p in PIECES:
            svg_path = svg_files[p]
            png_path = os.path.join(temp_dir, f"{p}_{size}.png")
            
            # Convert SVG to PNG at target size preserving transparency
            cmd = ["convert", "-background", "none", svg_path, "-resize", f"{size}x{size}", png_path]
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"Error converting {p} to size {size}:", file=sys.stderr)
                print(result.stderr, file=sys.stderr)
                shutil.rmtree(temp_dir, ignore_errors=True)
                sys.exit(1)
            temp_pngs.append(png_path)
        
        # Combine pieces horizontally into a single strip
        output_strip = os.path.join(output_dir, f"{piece_set}_{size}.png")
        cmd = ["convert"] + temp_pngs + ["+append", output_strip]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error appending images for size {size}:", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            shutil.rmtree(temp_dir, ignore_errors=True)
            sys.exit(1)
            
        print(f"Created {output_strip}")

    # Cleanup temp directory
    shutil.rmtree(temp_dir)
    print(f"\nSuccessfully downloaded and generated '{piece_set}' pieces!")
    print(f"Restart scidCommunity to see the new set in your options.")

if __name__ == "__main__":
    main()
