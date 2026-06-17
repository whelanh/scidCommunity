from PIL import Image
import os

# SIZES supported by Scid
SIZES = [25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 120]

# Mapping of Scid piece order to tileset index (0-15)
# White piece mapping
WHITE_MAP = {
    'wp': 12, # Pawn
    'wn': 4,  # Knight (facing left)
    'wb': 0,  # Bishop (facing left)
    'wr': 11, # Rook
    'wq': 8,  # Queen
    'wk': 10  # King
}

# Black piece mapping
BLACK_MAP = {
    'bp': 12, # Pawn
    'bn': 7,  # Knight (facing right)
    'bb': 3,  # Bishop (facing right)
    'br': 11, # Rook
    'bq': 8,  # Queen
    'bk': 10  # King
}

# Piece order for Scid: wp wn wb wr wq wk bp bn bb br bq bk
ORDER = ['wp', 'wn', 'wb', 'wr', 'wq', 'wk', 'bp', 'bn', 'bb', 'br', 'bq', 'bk']

def color_distance(c1, c2):
    """Euclidean distance between two RGB colours."""
    return ((c1[0]-c2[0])**2 + (c1[1]-c2[1])**2 + (c1[2]-c2[2])**2) ** 0.5

def make_transparent(tile):
    """
    Flood-fills from all four corners to remove the background colour,
    making it transparent. Works for any solid background (black, teal, etc.).
    """
    img = tile.convert("RGBA")
    width, height = img.size
    pixels = img.load()

    # Sample the background colour from the top-left corner
    bg_color = pixels[0, 0][:3]  # RGB only
    tolerance = 30

    # BFS flood fill from all 4 corners
    from collections import deque
    visited = [[False] * height for _ in range(width)]
    queue = deque()
    corners = [(0, 0), (width-1, 0), (0, height-1), (width-1, height-1)]
    for cx, cy in corners:
        if not visited[cx][cy]:
            visited[cx][cy] = True
            queue.append((cx, cy))

    while queue:
        x, y = queue.popleft()
        r, g, b, a = pixels[x, y]
        if color_distance((r, g, b), bg_color) <= tolerance:
            pixels[x, y] = (0, 0, 0, 0)
            for nx, ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
                if 0 <= nx < width and 0 <= ny < height and not visited[nx][ny]:
                    visited[nx][ny] = True
                    queue.append((nx, ny))
    return img

def process_style(style_name, white_path, black_path, output_dir):
    print(f"Processing style: {style_name}")

    os.makedirs(output_dir, exist_ok=True)

    white_img = Image.open(white_path).convert("RGBA")
    black_img = Image.open(black_path).convert("RGBA")

    tile_w, tile_h = 128, 128

    # 1. Crop all 12 pieces, remove background, then tight-crop to content
    pieces = {}
    for p in ORDER:
        if p.startswith('w'):
            tile_idx = WHITE_MAP[p]
            src = white_img
        else:
            tile_idx = BLACK_MAP[p]
            src = black_img

        r = tile_idx // 4
        c = tile_idx % 4
        box = (c * tile_w, r * tile_h, (c + 1) * tile_w, (r + 1) * tile_h)
        tile = src.crop(box)
        tile = make_transparent(tile)

        # Tight-crop: find the bounding box of non-transparent pixels
        bbox = tile.getbbox()  # returns (left, upper, right, lower) or None
        if bbox:
            tile = tile.crop(bbox)

        pieces[p] = tile

    # 2. Find the tallest piece height to use as a shared scale reference.
    #    This preserves the natural size ratios between pieces (pawn stays
    #    shorter than king/queen rather than being blown up to fill the tile).
    max_height = max(tile.size[1] for tile in pieces.values())

    # 3. Generate combined strips for each size
    for size in SIZES:
        # Scale factor is derived from the tallest piece filling the slot,
        # then boosted by 10% so pieces feel larger and more imposing.
        # Pieces taller than the slot are clipped at the top; the bottom-align
        # below ensures all bases remain on the board surface.
        shared_scale = (size / max_height) * 1.15

        strip = Image.new("RGBA", (size * 12, size), (0, 0, 0, 0))

        for idx, p in enumerate(ORDER):
            tile = pieces[p]
            pw, ph = tile.size

            new_w = max(1, int(pw * shared_scale))
            new_h = max(1, int(ph * shared_scale))

            try:
                resample_method = Image.Resampling.LANCZOS
            except AttributeError:
                resample_method = Image.ANTIALIAS

            resized_tile = tile.resize((new_w, new_h), resample_method)

            # Align piece to the bottom of the slot, centred horizontally.
            # This means shorter pieces (pawns) sit at the bottom like taller
            # ones, rather than floating in the middle.
            x_offset = (size - new_w) // 2
            y_offset = size - new_h   # bottom-align
            strip.paste(resized_tile, (idx * size + x_offset, y_offset))

        output_path = os.path.join(output_dir, f"{style_name}_{size}.png")
        strip.save(output_path)
        print(f"  Created {output_path}")


def main():
    base_src = "/var/home/hugh/Downloads/sbs_-_2d_chess_pack/Isometric/Pieces"
    base_dest = "/var/home/hugh/Downloads/scidCommunity/img/pieces"
    
    # Process Wood style
    process_style(
        "isometric_wood",
        os.path.join(base_src, "White", "White - Wood 1.png"),
        os.path.join(base_src, "Black", "Black - Wood 1.png"),
        os.path.join(base_dest, "isometric_wood")
    )
    
    # Process Plastic style
    process_style(
        "isometric_plastic",
        os.path.join(base_src, "White", "White - Plastic 1.png"),
        os.path.join(base_src, "Black", "Black - Plastic 1.png"),
        os.path.join(base_dest, "isometric_plastic")
    )
    
    print("\nConversion successfully completed!")

if __name__ == "__main__":
    main()
