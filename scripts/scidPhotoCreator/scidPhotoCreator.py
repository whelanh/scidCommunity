#!/usr/bin/env python3
"""
scidCommunity Player Photo Creator
Creates .spf and .spi files for player photos in scidCommunity chess database.

Cross-platform (Linux, Windows, macOS)
Requires: Python 3.6+, Pillow (PIL) for image processing

Usage:
    python scidPhotoCreator.py "Player Name" photo.jpg [output_dir]
    
Or run without arguments for interactive mode.
"""

import os
import sys
import base64
import argparse
import subprocess
from pathlib import Path

# Try to import Pillow for image processing
try:
    from PIL import Image, ImageOps
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False


def get_default_scid_photo_dir():
    """Find the default scidCommunity photo directory based on OS."""
    home = Path.home()
    
    # Common scidCommunity photo directories
    possible_dirs = [
        home / ".scidcommunity",
        home / "scidCommunity" / "photos",
        home / "Documents" / "scidCommunity" / "photos",
    ]
    
    # On Windows, also check AppData
    if sys.platform == 'win32':
        appdata = os.environ.get('APPDATA', '')
        if appdata:
            possible_dirs.append(Path(appdata) / "scidCommunity" / "photos")
    
    # Return first existing directory, or the first default
    for d in possible_dirs:
        if d.exists():
            return d
    
    # Return a sensible default
    return possible_dirs[0]


def convert_image_to_base64(image_path, max_width=200, max_height=250):
    """
    Convert an image file to base64 encoded string.
    Resizes if necessary to keep file size reasonable.
    Applies EXIF orientation to fix rotation issues.
    Returns the base64 string.
    
    Default size (200x250) matches existing Player.spf photos.
    """
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Image file not found: {image_path}")

    # If Pillow is available, process the image
    if PIL_AVAILABLE:
        with Image.open(image_path) as img:
            # Fix EXIF orientation (handles rotation from camera phones, etc.)
            try:
                img = ImageOps.exif_transpose(img)
            except Exception:
                pass  # Ignore if no EXIF data or error
            
            # Convert to RGB if necessary (handles PNG with transparency, etc.)
            if img.mode in ('RGBA', 'P'):
                img = img.convert('RGB')
            elif img.mode != 'RGB':
                img = img.convert('RGB')

            # Resize if too large (maintain aspect ratio)
            width, height = img.size
            if width > max_width or height > max_height:
                ratio = min(max_width / width, max_height / height)
                new_size = (int(width * ratio), int(height * ratio))
                img = img.resize(new_size, Image.Resampling.LANCZOS)

            # Save to bytes buffer as GIF (scidCommunity's preferred format)
            from io import BytesIO
            buffer = BytesIO()
            img.save(buffer, format='GIF', optimize=True)
            image_bytes = buffer.getvalue()
    else:
        # No Pillow - read file as-is (may not work for all formats)
        print("  Warning: Pillow not installed. Using raw file data.")
        print("  Install with: pip install Pillow")
        with open(image_path, 'rb') as f:
            image_bytes = f.read()

    # Encode to base64
    return base64.b64encode(image_bytes).decode('ascii')


def normalize_player_name(name):
    """
    Normalize player name as scidCommunity does:
    - Convert to lowercase
    - Strip first two spaces (for "Last, First" format)
    """
    name = name.lower()
    # Remove first two spaces
    count = 0
    result = []
    for char in name:
        if char == ' ' and count < 2:
            count += 1
            continue
        result.append(char)
    return ''.join(result)


def create_spf_entry(player_name, base64_data):
    """Create a single SPF file entry."""
    return f'photo "{player_name}" {{\n{base64_data}\n}}\n\n'


def create_spf_file(entries, output_path):
    """
    Create an SPF file with multiple player entries.
    entries: list of (player_name, base64_data) tuples
    
    Note: Uses Unix line endings (LF) for cross-platform compatibility.
    """
    # Use newline='\n' to force Unix line endings even on Windows
    with open(output_path, 'w', encoding='utf-8', newline='\n') as f:
        for name, data in entries:
            f.write(create_spf_entry(name, data))

    print(f"  Created: {output_path}")


def generate_spi_from_spf(spf_path, spi_path):
    """
    Generate SPI index file from SPF file.
    Uses the spf2spi.tcl script if available, otherwise implements basic version.
    """
    spf_path = Path(spf_path)
    spi_path = Path(spi_path)

    # Try to find spf2spi.tcl script (check current directory first for scidCommunity integration)
    script_locations = [
        Path(__file__).parent / "spf2spi.tcl",  # Same directory as this script
        spf_path.parent / "spf2spi.tcl",        # Same directory as SPF output
    ]

    # On Windows, check scidCommunity installation
    if sys.platform == 'win32':
        program_files = os.environ.get('PROGRAMFILES', 'C:\\Program Files')
        script_locations.append(Path(program_files) / "scidCommunity" / "scripts" / "spf2spi.tcl")
    
    # Linux standard paths
    elif sys.platform == 'linux':
        script_locations.extend([
            Path("/usr/share/scidcommunity/scripts/spf2spi.tcl"),
            Path("/usr/share/scid/scripts/spf2spi.tcl"),
        ])
    
    for script in script_locations:
        if script.exists():
            try:
                print(f"  Using spf2spi.tcl from: {script}")
                result = subprocess.run(
                    ['tclsh', str(script), str(spf_path)],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                if result.returncode == 0:
                    with open(spi_path, 'w') as f:
                        f.write(result.stdout)
                    print(f"  Created: {spi_path}")
                    return True
                else:
                    print(f"  Warning: spf2spi.tcl failed: {result.stderr}")
            except FileNotFoundError:
                print("  Warning: tclsh not found. Using built-in SPI generator.")
            except Exception as e:
                print(f"  Warning: Error running spf2spi.tcl: {e}")
            break
    
    # Fallback: basic SPI generator
    print("  Generating SPI with built-in method...")
    result = generate_spi_builtin(spf_path, spi_path)
    if result:
        print(f"  SPI file size: {os.path.getsize(spi_path)} bytes")
    return result


def generate_spi_builtin(spf_path, spi_path):
    """
    Built-in SPI generator (fallback when tclsh unavailable).
    Parses SPF file and calculates offsets.
    Handles both Unix (LF) and Windows (CRLF) line endings.
    """
    fname = os.path.basename(spf_path)

    with open(spf_path, 'rb') as f:
        content = f.read()

    entries = []
    pos = 0

    while True:
        # Find next photo entry
        photo_marker = content.find(b'photo "', pos)
        if photo_marker == -1:
            break

        # Find the player name
        name_start = photo_marker + len(b'photo "')
        name_end = content.find(b'" {', name_start)
        if name_end == -1:
            break

        player_name = content[name_start:name_end].decode('utf-8')
        normalized_name = normalize_player_name(player_name)

        # Find the opening brace and move past it
        brace_start = name_end + len(b'" {')
        
        # Find the first line ending after the opening brace
        # Handle both \r\n (Windows) and \n (Unix)
        newline_pos = content.find(b'\n', brace_start)
        if newline_pos == -1:
            break
        
        # Data starts after the newline
        data_start = newline_pos + 1

        # Find closing brace - look for "}\n" or "}\r\n" pattern
        # First try to find "}\n"
        close_brace = content.find(b'}\n', data_start)
        if close_brace == -1:
            # Try just "}" at end of file
            close_brace = content.find(b'}', data_start)
        
        if close_brace == -1:
            break

        # Calculate size (from data_start to just before the closing brace)
        # But we need to account for the newline before }
        # Check if there's a newline before the }
        if close_brace > data_start and content[close_brace-1:close_brace] == b'\n':
            data_end = close_brace - 1
            # Also check for \r\n
            if data_end > data_start and content[data_end-1:data_end] == b'\r':
                data_end = data_end - 1
        else:
            data_end = close_brace
        
        photo_size = data_end - data_start

        entries.append((normalized_name, data_start, photo_size))
        pos = close_brace + 1

    # Write SPI file
    with open(spi_path, 'w', encoding='utf-8') as f:
        for name, begin, size in entries:
            f.write(f'set "photobegin({name})" {begin}\n')
            f.write(f'set "photosize({name})" {size}\n')
            f.write(f'set "spffile({name})" "$fname"\n')
    
    print(f"  Created: {spi_path}")
    
    if len(entries) == 0:
        print("  WARNING: No photo entries found in SPF file!")
        return False

    return True


def interactive_mode():
    """Run in interactive mode, prompting for inputs."""
    print("\n=== scidCommunity Player Photo Creator ===\n")
    
    entries = []
    
    while True:
        print(f"\n--- Adding Player {len(entries) + 1} ---")
        
        # Get player name
        while True:
            name = input("Player name (exactly as in database): ").strip()
            if name:
                break
            print("  Please enter a name.")
        
        # Get image path
        while True:
            image_path = input("Image file path: ").strip()
            image_path = os.path.expanduser(image_path)
            if os.path.exists(image_path):
                break
            print("  File not found. Please try again.")
        
        # Convert image
        try:
            print("  Converting image...")
            base64_data = convert_image_to_base64(image_path)
            entries.append((name, base64_data))
            print(f"  ✓ Added: {name}")
        except Exception as e:
            print(f"  ✗ Error: {e}")
        
        # Ask if more players
        if len(entries) > 0:
            while True:
                more = input("\nAdd another player? (y/n): ").strip().lower()
                if more in ('y', 'yes'):
                    break
                elif more in ('n', 'no'):
                    break
            if more in ('n', 'no'):
                break
    
    if not entries:
        print("\nNo players added. Exiting.")
        return
    
    # Get output directory
    default_dir = get_default_scid_photo_dir()
    output_dir = input(f"\nOutput directory [{default_dir}]: ").strip()
    if not output_dir:
        output_dir = default_dir
    
    # Create directory if needed
    os.makedirs(output_dir, exist_ok=True)
    
    # Create files
    base_name = "my_photos"
    spf_path = os.path.join(output_dir, f"{base_name}.spf")
    spi_path = os.path.join(output_dir, f"{base_name}.spi")
    
    # Handle existing files
    counter = 1
    while os.path.exists(spf_path):
        counter += 1
        spf_path = os.path.join(output_dir, f"my_photos_{counter}.spf")
        spi_path = os.path.join(output_dir, f"my_photos_{counter}.spi")
    
    print(f"\nCreating files in: {output_dir}")
    create_spf_file(entries, spf_path)
    generate_spi_from_spf(spf_path, spi_path)

    print("\n=== Complete! ===")
    print(f"\nTo use these photos:")
    print(f"1. In scidCommunity: Options → Preferences → Photos directory")
    print(f"   Set to: {output_dir}")
    print(f"2. Restart scidCommunity")
    print(f"3. Photos will appear when viewing games with these players")


def main():
    parser = argparse.ArgumentParser(
        description='Create scidCommunity player photo files (.spf and .spi)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scidPhotoCreator.py
      Run in interactive mode

  python scidPhotoCreator.py "Carlsen,Magnus" carlsen.png ./scid_photos/
      Specify output directory

  python scidPhotoCreator.py --batch players.txt ./output/
      Batch mode: players.txt contains lines of "name,image_path"
        """
    )
    
    parser.add_argument('player_name', nargs='?', help='Player name (exactly as in database)')
    parser.add_argument('image_file', nargs='?', help='Image file path')
    parser.add_argument('output_dir', nargs='?', help='Output directory (optional)')
    parser.add_argument('--batch', '-b', metavar='FILE',
                       help='Batch mode: file with "name,image_path" per line')
    parser.add_argument('--name', '-n', default='my_photos',
                       help='Base name for output files (default: my_photos)')
    parser.add_argument('--max-width', type=int, default=200,
                       help='Max image width (default: 200)')
    parser.add_argument('--max-height', type=int, default=250,
                       help='Max image height (default: 250)')
    
    args = parser.parse_args()
    
    # Interactive mode if no arguments
    if not args.player_name and not args.batch:
        interactive_mode()
        return
    
    # Batch mode
    if args.batch:
        if not os.path.exists(args.batch):
            print(f"Error: Batch file not found: {args.batch}")
            sys.exit(1)
        
        entries = []
        with open(args.batch, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                
                parts = line.rsplit(',', 1)
                if len(parts) != 2:
                    print(f"  Warning: Line {line_num} invalid format, skipping: {line}")
                    continue
                
                name, image_path = parts
                name = name.strip()
                image_path = image_path.strip()
                
                if not os.path.exists(image_path):
                    print(f"  Warning: Image not found (line {line_num}): {image_path}")
                    continue
                
                try:
                    base64_data = convert_image_to_base64(
                        image_path, args.max_width, args.max_height
                    )
                    entries.append((name, base64_data))
                    print(f"  ✓ Added: {name}")
                except Exception as e:
                    print(f"  ✗ Error with {name}: {e}")
        
        if not entries:
            print("\nNo players added. Exiting.")
            return
    
    # Single player mode
    else:
        if not args.image_file:
            print("Error: Image file required when specifying player name")
            print("Run without arguments for interactive mode")
            sys.exit(1)
        
        if not os.path.exists(args.image_file):
            print(f"Error: Image file not found: {args.image_file}")
            sys.exit(1)
        
        try:
            base64_data = convert_image_to_base64(
                args.image_file, args.max_width, args.max_height
            )
            entries = [(args.player_name, base64_data)]
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)
    
    # Determine output directory
    output_dir = args.output_dir
    if not output_dir:
        output_dir = get_default_scid_photo_dir()
    
    os.makedirs(output_dir, exist_ok=True)
    
    # Create files
    spf_path = os.path.join(output_dir, f"{args.name}.spf")
    spi_path = os.path.join(output_dir, f"{args.name}.spi")
    
    # Handle existing files
    counter = 1
    original_name = args.name
    while os.path.exists(spf_path):
        counter += 1
        new_name = f"{original_name}_{counter}"
        spf_path = os.path.join(output_dir, f"{new_name}.spf")
        spi_path = os.path.join(output_dir, f"{new_name}.spi")
    
    print(f"\nCreating files in: {output_dir}")
    create_spf_file(entries, spf_path)
    generate_spi_from_spf(spf_path, spi_path)
    
    print("\n=== Complete! ===")
    print(f"\nTo use these photos:")
    print(f"1. In scidCommunity: Options → Preferences → Photos directory")
    print(f"   Set to: {output_dir}")
    print(f"2. Restart scidCommunity")
    print(f"3. Photos will appear when viewing games with these players")


if __name__ == '__main__':
    main()
