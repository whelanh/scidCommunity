import sys
import argparse
import re
import os
import glob

# Language file to language code mapping
LANGUAGE_CODE_MAP = {
    'czech.tcl': 'C',
    'deutsch.tcl': 'D',
    'francais.tcl': 'F',
    'greek.tcl': 'G',
    'hungary.tcl': 'H',
    'italian.tcl': 'I',
    'chinese.tcl': 'M',
    'nederlan.tcl': 'N',
    'norsk.tcl': 'O',
    'polish.tcl': 'P',
    'portbr.tcl': 'B',
    'russian.tcl': 'R',
    'serbian.tcl': 'Y',
    'spanish.tcl': 'S',
    'swedish.tcl': 'W',
    'catalan.tcl': 'K',
    'suomi.tcl': 'U',
    'SerbCyr.tcl': 'J',
    'romanian.tcl': 'L',
    'japanese.tcl': 'A',
    'arabic.tcl': 'Q',
    'hebrew.tcl': 'V',
}

def get_encoding_for_file(filepath):
    """Get the encoding for a language file based on hard-coded lookup table.
    This matches the encoding specified in language.tcl addLanguage commands."""
    import os
    
    # Hard-coded encoding lookup based on language.tcl
    encoding_map = {
        'english.tcl': 'utf-8',
        'catalan.tcl': 'iso8859-1',
        'czech.tcl': 'iso8859-2',
        'deutsch.tcl': 'iso8859-1',
        'francais.tcl': 'utf-8',
        'greek.tcl': 'utf-8',
        'hungary.tcl': 'iso8859-2',
        'italian.tcl': 'utf-8',
        'chinese.tcl': 'utf-8',
        'nederlan.tcl': 'iso8859-1',
        'norsk.tcl': 'iso8859-1',
        'polish.tcl': 'iso8859-2',
        'portbr.tcl': 'iso8859-1',
        'russian.tcl': 'utf-8',
        'serbian.tcl': 'iso8859-2',
        'spanish.tcl': 'utf-8',
        'suomi.tcl': 'iso8859-1',
        'swedish.tcl': 'iso8859-1',
        'turkish.tcl': 'utf-8',
        'SerbCyr.tcl': 'utf-8',
        'japanese.tcl': 'utf-8',
        'romanian.tcl': 'utf-8',    
        'arabic.tcl': 'utf-8',    
        'hebrew.tcl': 'utf-8',    
    }
    
    # Extract base filename from path (handle .new extensions)
    filename = os.path.basename(filepath)
    # Remove .new extension if present
    if filename.endswith('.new'):
        filename = filename[:-4]
    
    # Return encoding from map, default to utf-8 if not found
    return encoding_map.get(filename, 'utf-8')

def read_file_robust(filepath):
    """Reads a file using the hard-coded encoding lookup. Returns (content_lines, used_encoding)."""
    encoding = get_encoding_for_file(filepath)
    try:
        with open(filepath, 'r', encoding=encoding) as f:
            return f.readlines(), encoding
    except UnicodeDecodeError:
        # Fallback to reading with error replacement
        with open(filepath, 'r', encoding=encoding, errors='replace') as f:
            return f.readlines(), f'{encoding}-replace'

def parse_target_file(filepath):
    """
    Parses the target file into a dictionary of {key: lines_list}.
    Handles multi-line translations that span multiple lines.
    Returns: (header_lines, translations, encoding)
    """
    translations = {}
    header_lines = []
    
    cmd_pattern = re.compile(r'^\s*(menuText|translate)\s+\S+\s+(\S+)')
    
    lines, encoding = read_file_robust(filepath)
    in_header = True
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        if in_header:
            if line.strip().startswith('proc setLanguage_'):
                in_header = False
            else:
                header_lines.append(line)
            i += 1
            continue
        
        # Skip TODO markers but process the translation that follows
        if '# ====== TODO To be translated ======' in line:
            i += 1  # Move to next line
            if i < len(lines):
                line = lines[i]  # Get the next line to process
            else:
                break  # End of file
            
        match = cmd_pattern.match(line)
        if match:
            cmd_type = match.group(1)
            tag = match.group(2)
            
            # Collect all lines for this translation (including multi-line continuations)
            translation_lines = [line]
            
            # Check if this line ends with a backslash OR has unbalanced braces
            while i + 1 < len(lines):
                # Count braces to detect multi-line translations
                total_open = sum(l.count('{') for l in translation_lines)
                total_close = sum(l.count('}') for l in translation_lines)
                
                # If braces are balanced and no trailing backslash, we're done
                if total_open == total_close and not translation_lines[-1].rstrip().endswith('\\'):
                    break
                
                i += 1
                translation_lines.append(lines[i])
            
            translations[(cmd_type, tag)] = translation_lines
        
        i += 1

    return header_lines, translations, encoding

def clean_and_reorder(target_file, reference_file, lang_code):
    header, translations, target_encoding = parse_target_file(target_file)
    output_file = target_file + '.clean'
    
    print(f"Reading target file: {target_file}")
    print(f"Target encoding: {target_encoding}")
    print(f"Reading reference file: {reference_file}")
    ref_lines, ref_enc = read_file_robust(reference_file)
    print(f"Reference encoding: {ref_enc}")
    
    try:
        # Write using the same encoding as the input target file
        with open(output_file, 'w', encoding=target_encoding) as out:
            
            # Write Header
            for line in header:
                out.write(line)
            
            ref_in_header = True
            cmd_pattern = re.compile(r'^\s*(menuText|translate)\s+\S+\s+(\S+)')
            
            i = 0
            while i < len(ref_lines):
                line = ref_lines[i]
                
                if ref_in_header:
                    if line.strip().startswith('proc setLanguage_'):
                        ref_in_header = False
                        out.write(f"proc setLanguage_{lang_code} {{}} {{\n")
                    i += 1
                    continue
                
                match = cmd_pattern.match(line)
                if match:
                    cmd_type = match.group(1)
                    tag = match.group(2)
                    
                    key = (cmd_type, tag)
                    if key in translations:
                        # Write all lines from the translation (handles multi-line entries)
                        for trans_line in translations[key]:
                            out.write(trans_line)
                    else:
                        out.write(f"# MISSING TRANSLATION for {tag}:\n")
                        out.write(f"# {line}")
                        # Handle multi-line reference entries that are missing
                        ref_lines_collected = [line]
                        while i + 1 < len(ref_lines):
                            # Count braces across all collected lines
                            total_open = sum(l.count('{') for l in ref_lines_collected)
                            total_close = sum(l.count('}') for l in ref_lines_collected)
                            
                            if total_open == total_close and not ref_lines_collected[-1].rstrip().endswith('\\'):
                                break
                            
                            i += 1
                            line = ref_lines[i]
                            ref_lines_collected.append(line)
                            out.write(f"# {line}")
                    
                    # Skip multi-line blocks in reference file
                    # We need to advance 'i' past any continuation lines
                    if key in translations:
                        ref_lines_to_skip = [line]
                        while i + 1 < len(ref_lines):
                            total_open = sum(l.count('{') for l in ref_lines_to_skip)
                            total_close = sum(l.count('}') for l in ref_lines_to_skip)
                            
                            if total_open == total_close and not ref_lines_to_skip[-1].rstrip().endswith('\\'):
                                break
                            
                            i += 1
                            line = ref_lines[i]
                            ref_lines_to_skip.append(line)

                else:
                    out.write(line)
                
                i += 1
                    
        print(f"Successfully cleaned file saved to: {output_file} ({target_encoding})")
                    
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def process_all_new_files(reference_file):
    """
    Process all .tcl.new files in the current directory.
    Uses LANGUAGE_CODE_MAP to determine the appropriate language code for each file.
    """
    print("="*70)
    print("Processing all .tcl.new files...")
    print("="*70)
    
    # Find all .tcl.new files in the current directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    new_files = glob.glob(os.path.join(script_dir, '*.tcl.new'))
    
    if not new_files:
        print("No .tcl.new files found in the directory.")
        return
    
    print(f"\nFound {len(new_files)} .tcl.new file(s)")
    
    processed_files = []
    skipped_files = []
    
    for new_file in sorted(new_files):
        # Extract base filename (remove .new extension)
        base_filename = os.path.basename(new_file)[:-4]  # Remove '.new'
        
        # Look up language code
        lang_code = LANGUAGE_CODE_MAP.get(base_filename)
        
        if not lang_code:
            print(f"\nSkipping {os.path.basename(new_file)}: Unknown language file")
            skipped_files.append(os.path.basename(new_file))
            continue
        
        print(f"\n{'='*70}")
        print(f"Processing: {os.path.basename(new_file)} (Language code: {lang_code})")
        print(f"{'='*70}")
        
        try:
            clean_and_reorder(new_file, reference_file, lang_code)
            processed_files.append(os.path.basename(new_file))
        except Exception as e:
            print(f"Error processing {os.path.basename(new_file)}: {e}")
            skipped_files.append(os.path.basename(new_file))
    
    # Summary
    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print(f"Files processed: {len(processed_files)}")
    
    if processed_files:
        print("\nSuccessfully processed:")
        for fname in processed_files:
            print(f"  {fname} -> {fname}.clean")
    
    if skipped_files:
        print(f"\nSkipped files: {', '.join(skipped_files)}")
    
    print("\nNote: Check the .new.clean files for cleaned versions.")
    print("="*70)

def main():
    parser = argparse.ArgumentParser(
        description='Clean and reorder translated Tcl files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Process a single file:
    python3 cleanNewFiles.py spanish.tcl.new -r english.tcl -c S
  
  Process all .tcl.new files:
    python3 cleanNewFiles.py --all
        """)
    
    parser.add_argument('target_file', nargs='?', help='The translated .new file (not needed with --all)')
    parser.add_argument('-r', '--reference', default='english.tcl', 
                        help='Reference english file for order/structure (default: english.tcl)')
    parser.add_argument('-c', '--code', 
                        help='Language code (e.g. S for Spanish)')
    parser.add_argument('--all', action='store_true',
                        help='Process all .tcl.new files in the directory')
    
    args = parser.parse_args()
    
    if args.all:
        # Process all .tcl.new files
        process_all_new_files(args.reference)
    else:
        # Process single file
        if not args.target_file:
            parser.error('target_file is required when not using --all')
        if not args.code:
            parser.error('-c/--code is required when not using --all')
        
        clean_and_reorder(args.target_file, args.reference, args.code)

if __name__ == '__main__':
    main()
