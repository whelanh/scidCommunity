import sys
import argparse
import re

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
        'nederlan.tcl': 'iso8859-1',
        'norsk.tcl': 'iso8859-1',
        'polish.tcl': 'iso8859-2',
        'portbr.tcl': 'iso8859-1',
        'russian.tcl': 'utf-8',
        'serbian.tcl': 'iso8859-2',
        'spanish.tcl': 'iso8859-1',
        'suomi.tcl': 'iso8859-1',
        'swedish.tcl': 'iso8859-1',
        'turkish.tcl': 'utf-8',
        'SerbCyr.tcl': 'utf-8',
        'japanese.tcl': 'utf-8',
        'romanian.tcl': 'utf-8',    
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

def main():
    parser = argparse.ArgumentParser(description='Clean and reorder translated Tcl files')
    parser.add_argument('target_file', help='The translated .new file')
    parser.add_argument('-r', '--reference', default='tcl/lang/english.tcl', 
                        help='Reference english file for order/structure')
    parser.add_argument('-c', '--code', required=True, 
                        help='Language code (e.g. S for Spanish)')
    
    args = parser.parse_args()
    clean_and_reorder(args.target_file, args.reference, args.code)

if __name__ == '__main__':
    main()
