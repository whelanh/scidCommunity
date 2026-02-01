# How to Export Games to PDF

ScidCommunity provides several export options for saving your chess games.

## Recommended Method: Export to HTML+JavaScript, then Print to PDF

This method works on all platforms (Windows, Mac, Linux) with no additional software needed.

### Steps:

1. In ScidCommunity, go to **Game → Export Current Game → Export to HTML and JavaScript**
   - Or for multiple games: **Database → Export Filter → Export to HTML and JavaScript**

2. Choose a location and filename, then click Save

3. Open the generated HTML file in your web browser
   - Windows: Double-click the .html file
   - Mac: Double-click the .html file  
   - Linux: `xdg-open filename.html`

4. In your browser, use **Print to PDF**:
   - **Chrome/Chromium**: Ctrl+P (Cmd+P on Mac) → Destination: "Save as PDF"
   - **Firefox**: Ctrl+P (Cmd+P on Mac) → Print to File → Save as PDF
   - **Edge**: Ctrl+P (Cmd+P on Mac) → Printer: "Microsoft Print to PDF"
   - **Safari**: Cmd+P → PDF button (bottom left) → "Save as PDF"

5. Choose your PDF filename and location, then save

### Result:

You'll get a nicely formatted PDF with:
- Player names, ratings, event, and date
- Interactive chess board diagrams
- Full game notation with move numbers
- Variations and comments (if included)

## Other Export Formats

### PGN Format
Standard chess notation format, compatible with all chess software:
- **Game → Export Current Game → Export to PGN**

### HTML Format  
Simple HTML with text-based notation:
- **Game → Export Current Game → Export to HTML**
- Note: This format does not include visual chess board diagrams

## Note on LaTeX Export

The LaTeX export option has been removed due to complex font dependencies that vary across systems. The HTML+JavaScript export with browser "Print to PDF" provides better cross-platform compatibility and produces high-quality PDF output.
