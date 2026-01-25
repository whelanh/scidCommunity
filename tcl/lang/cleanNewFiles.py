import sys
import argparse
import re

def read_file_robust(filepath):
    """Reads a file trying utf-8 then iso-8859-1. Returns (content_lines, used_encoding)."""
    encodings = ['utf-8', 'iso8859-1']
    for enc in encodings:
        try:
            with open(filepath, 'r', encoding=enc) as f:
                return f.readlines(), enc
        except UnicodeDecodeError:
            continue
    # Fallback
    with open(filepath, 'r', encoding='iso8859-1', errors='replace') as f:
        return f.readlines(), 'iso8859-1-replace'

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
        
        # Skip TODO markers and the untranslated English line that follows
        if '# ====== TODO To be translated ======' in line:
            i += 1  # Skip the TODO comment
            # Skip the next line(s) which contain the English template
            if i < len(lines):
                next_line = lines[i]
                # Skip this English translation line and any continuation lines
                if cmd_pattern.match(next_line):
                    temp_lines = [next_line]
                    # Handle multi-line entries
                    while i + 1 < len(lines):
                        total_open = sum(l.count('{') for l in temp_lines)
                        total_close = sum(l.count('}') for l in temp_lines)
                        
                        if total_open == total_close and not temp_lines[-1].rstrip().endswith('\\'):
                            break
                        
                        i += 1
                        temp_lines.append(lines[i])
                    i += 1  # Move past this entire entry
            continue
            
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
    print(f"Target encoding detected: {target_encoding}")
    print(f"Reading reference file: {reference_file}")
    ref_lines, ref_enc = read_file_robust(reference_file)
    print(f"Reference encoding used: {ref_enc}")
    
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
