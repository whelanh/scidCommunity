# scidCommunity Player Photo Creator

Create custom player photo files (.spf and .spi) for the scidCommunity chess database application.

## Features

- ✅ Cross-platform (Linux, Windows, macOS)
- ✅ Interactive mode for adding players one-by-one
- ✅ Command-line mode for scripting
- ✅ Batch mode for adding multiple players from a file
- ✅ Automatic image resizing and optimization
- ✅ Automatic SPI index file generation

## Requirements

- **Python 3.6+** (available from [python.org](https://www.python.org/downloads/))
- **Pillow** (image processing library) - auto-installed if missing

## Installation

### Windows

**Step 1: Install Python**

Choose one of these methods:

**Option A: Microsoft Store (Easiest)**
1. Open the Microsoft Store
2. Search for "Python 3.11" (or the latest version)
3. Click "Get" or "Install"
4. Wait for installation to complete

**Option B: Python.org (Recommended for full features)**
1. Go to https://www.python.org/downloads/
2. Click the yellow "Download Python" button
3. Run the installer
4. **IMPORTANT:** Check the box "Add Python to PATH" on the first screen
5. Click "Install Now"

**Step 2: Verify Installation**

Open Command Prompt (press `Win+R`, type `cmd`, press Enter) and run:
```cmd
python --version
```
You should see something like `Python 3.11.5`


---

### Linux

**Step 1: Install Python and Pillow**

On Ubuntu/Debian:
```bash
sudo apt install python3 python3-pip
pip3 install Pillow --user
```

On Fedora:
```bash
sudo dnf install python3 python3-pillow
```

On Arch Linux:
```bash
sudo pacman -S python python-pillow
```


---

### macOS

**Step 1: Install Python**

If not already installed:
```bash
brew install python3
```

Or download from https://www.python.org/downloads/macos/

**Step 2: Install Pillow**

```bash
pip3 install Pillow --user
```

## Usage

### Method 1: Interactive Mode (Easiest)

```
python scidPhotoCreator.py

The program will prompt you for:
- Player name (exactly as it appears in your chess database)
- Image file path
- Whether to add more players
- Output directory

### Method 2: Single Player (Command Line)

With custom output directory:
```bash
python scidPhotoCreator.py "Carlsen,Magnus" carlsen.png ./my_scid_photos/
```

### Method 3: Batch Mode (Multiple Players)

Create a text file (e.g., `players.txt`) with one player per line:
```
Magnus Carlsen,photos/magnus.jpg
Carlsen,Magnus,photos/carlsen.png
Hou Yifan,photos/hou_yifan.jpg
```

Then run:
```bash
python scidPhotoCreator.py --batch players.txt ./output/
```

## Options

| Option | Description |
|--------|-------------|
| `--batch FILE`, `-b FILE` | Batch mode: file with "name,image_path" per line |
| `--name NAME`, `-n NAME` | Base name for output files (default: `my_photos`) |
| `--max-width PX` | Max image width (default: 200) |
| `--max-height PX` | Max image height (default: 250) |
| `--help`, `-h` | Show help message |

**Note:** The default size (200x250 pixels) matches the existing player photos in Player.spf.
Images are automatically rotated correctly using EXIF orientation data.

## Output Files

The script creates two files:
- **`<name>.spf`** - Contains the actual photo data (base64 encoded)
- **`<name>.spi`** - Index file for fast lookup

## Installing Photos in scidCommunity

1. **Copy the .spf and .spi files** to a photo directory:
   - Default: `~/.scidcommunity/` (Linux) or `%APPDATA%\scidCommunity\photos\` (Windows)
   - Or any directory of your choice

2. **In scidCommunity:**
   - Go to **Options → Preferences → Photos directory**
   - Set it to the directory containing your .spf/.spi files
   - Click OK

3. **Restart scidCommunity**

4. **View photos:**
   - Load a game with the player
   - Photos appear automatically in the game info area
   - Right-click game info → "Show Photos" to toggle visibility

## Player Name Format

**Important:** Player names must match **exactly** as they appear in your chess database.

Common formats:
- `"Carlsen,Magnus"` - Last, First format (common in databases)
- `"carlsen,magnus"` - Names are normalized to lowercase

The script normalizes names the same way scidCommunity does:
- Converts to lowercase
- Removes the first two spaces (for "Last, First" format)

## Supported Image Formats

With Pillow installed:
- ✅ JPEG/JPG
- ✅ PNG
- ✅ GIF
- ✅ BMP
- ✅ TIFF

Images are automatically:
- **Rotated correctly** using EXIF orientation data (fixes phone camera rotation issues)
- **Converted to GIF format** (scidCommunity's preferred format)
- **Resized** to fit within 200x250 pixels (default, configurable)

## Examples

### Add a photo of yourself:
```bash
python scidPhotoCreator.py "smith,john" my_photo.jpg
```

### Add multiple local club players:
```bash
python scidPhotoCreator.py --batch club_players.txt -n club_photos ./scid_photos/
```

### Add with custom image size:
```bash
python scidPhotoCreator.py "Nakamura,Hikaru" nakamura.png --max-width 400 --max-height 500
```

**Note:** The default size (200x250) matches existing scidCommunity player photos.
Larger images are automatically resized while maintaining aspect ratio.

## Troubleshooting

### "Python not found"
- Install Python from [python.org](https://www.python.org/downloads/)
- **Windows:** Make sure to check "Add Python to PATH" during installation
- After installing, restart your terminal/command prompt

### "Pillow not found"
- Run: `pip install Pillow`
- Or: `python -m pip install Pillow`

### Photos not showing in scidCommunity
1. Check player name matches exactly (including punctuation, capitalization)
2. Verify .spf and .spi files are in the same directory
3. Check the Photos directory is set correctly in scidCommunity Preferences
4. Restart scidCommunity after adding new photo files
5. Make sure "Show Photos" is enabled (right-click game info area)


## File Format Details

**SPF file format:**
```
photo "Player Name" {
<base64-encoded GIF image data>
}
```

**SPI file format:**
```tcl
set "photobegin(playername)" <byte_offset>
set "photosize(playername)" <size_in_bytes>
set "spffile(playername)" "$fname"
```

## License

This tool is provided as-is for use with the scidCommunity chess database application.

## Credits

Created for the scidCommunity chess community.
SPF/SPI format reverse-engineered from SCID source code.
