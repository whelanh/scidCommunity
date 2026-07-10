"""
Translation Script for TODO-marked lines
...
Supported Language Encodings:
==================================================
The script will automatically detect encoding or you can specify it with -e flag:
  utf-8         - English, French, Greek, Italian, Russian, Chinese, Hebrew, Swahili,
                  Japanese, Romanian, Turkish, Hindi, Ukrainian, Bengali
                  Catalan, German, Dutch, Norwegian, Portuguese, Spanish, Finnish, Swedish,
                  Czech, Hungarian, Polish, Korean, Bulgarian
iso8859-2         Serbian

Supported Language Codes (use with -l flag):
==================================================
af - Afrikaans          ar - Arabic             az - Azerbaijani
be - Belarusian         bg - Bulgarian          bn - Bengali
bs - Bosnian            ca - Catalan            ceb - Cebuano
co - Corsican           cs - Czech              cy - Welsh
da - Danish             de - German             el - Greek
en - English            eo - Esperanto          es - Spanish
et - Estonian           eu - Basque             fa - Persian
fi - Finnish            fr - French             fy - Frisian
ga - Irish              gd - Scots Gaelic       gl - Galician
gu - Gujarati           ha - Hausa              haw - Hawaiian
he - Hebrew             hi - Hindi              hmn - Hmong
hr - Croatian           ht - Haitian Creole     hu - Hungarian
hy - Armenian           id - Indonesian         ig - Igbo
is - Icelandic          it - Italian            iw - Hebrew
ja - Japanese           jw - Javanese           ka - Georgian
kk - Kazakh             km - Khmer              kn - Kannada
ko - Korean             ku - Kurdish            ky - Kyrgyz
la - Latin              lb - Luxembourgish      lo - Lao
lt - Lithuanian         lv - Latvian            mg - Malagasy
mi - Maori              mk - Macedonian         ml - Malayalam
mn - Mongolian          mr - Marathi            ms - Malay
mt - Maltese            my - Myanmar (Burmese)  ne - Nepali
nl - Dutch              no - Norwegian          ny - Chichewa
or - Odia               pa - Punjabi            pl - Polish
ps - Pashto             pt - Portuguese         ro - Romanian
ru - Russian            sd - Sindhi             si - Sinhala
sk - Slovak             sl - Slovenian          sm - Samoan
sn - Shona              so - Somali             sq - Albanian
sr - Serbian            st - Sesotho            su - Sundanese
sv - Swedish            sw - Swahili            ta - Tamil
te - Telugu             tg - Tajik              th - Thai
tk - Turkmen            tl - Filipino           tr - Turkish
tt - Tatar              ug - Uyghur             uk - Ukrainian
ur - Urdu               uz - Uzbek              vi - Vietnamese
xh - Xhosa              yi - Yiddish            yo - Yoruba
zh-cn - Chinese (Simplified)    zh-tw - Chinese (Traditional)
zu - Zulu

Note: Most common codes are 2 letters, Chinese uses special codes
"""

import sys
import argparse
import googletrans
from googletrans import Translator
import re
import time
import asyncio
import inspect
import os

# googletrans changed from a synchronous API (<= 3.1.0) to an asyncio-based API
# (>= 4.0.0), where Translator.translate() became a coroutine and Translator
# became an async context manager. Detect which flavour is installed once, so
# the rest of this script can stay synchronous regardless of the version.
_IS_ASYNC = inspect.iscoroutinefunction(Translator.translate)


class TranslationSession:
    """Synchronous facade over googletrans that works with both the old
    synchronous (<= 3.1.0) and the new asyncio-based (>= 4.0.0) API.

    For the async API we keep a single persistent event loop for the whole
    run: creating a fresh loop per call (e.g. asyncio.run) would close the
    loop that the internal httpx.AsyncClient is bound to and raise
    "Event loop is closed" on the next translation.
    """

    def __init__(self):
        self._loop = None
        if _IS_ASYNC:
            self._loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self._loop)
        self._translator = Translator()

    def translate(self, text, src='auto', dest='en'):
        if _IS_ASYNC:
            res = self._loop.run_until_complete(
                self._translator.translate(text, src=src, dest=dest))
        else:
            res = self._translator.translate(text, src=src, dest=dest)
            # Belt-and-suspenders: handle a future version that returns an
            # awaitable without being flagged as a coroutine function.
            if inspect.isawaitable(res):
                loop = self._loop or asyncio.new_event_loop()
                res = loop.run_until_complete(res)
        return res.text if hasattr(res, 'text') else str(res)

    def close(self):
        try:
            client = getattr(self._translator, 'client', None)
            if _IS_ASYNC:
                if client is not None and hasattr(client, 'aclose') and self._loop is not None:
                    self._loop.run_until_complete(client.aclose())
            elif client is not None and hasattr(client, 'close'):
                client.close()
        except Exception:
            pass
        finally:
            if self._loop is not None:
                self._loop.close()
                self._loop = None

# Language file to language code mapping
# We don't do    'serbian.tcl': 'sr',      # Serbian because googletrans doesn't have serbian latinate
LANGUAGE_FILE_MAP = {
    'catalan.tcl': 'ca',      # Catalan
    'czech.tcl': 'cs',        # Czech
    'deutsch.tcl': 'de',      # German
    'francais.tcl': 'fr',     # French
    'greek.tcl': 'el',        # Greek
    'hungary.tcl': 'hu',      # Hungarian
    'italian.tcl': 'it',      # Italian
    'chinese.tcl': 'zh-cn',   # Chinese (Simplified)
    'nederlan.tcl': 'nl',     # Dutch
    'norsk.tcl': 'no',        # Norwegian
    'polish.tcl': 'pl',       # Polish
    'portbr.tcl': 'pt',       # Portuguese (Brazilian)
    'spanish.tcl': 'es',      # Spanish
    'swedish.tcl': 'sv',      # Swedish
    'russian.tcl': 'ru',      # Russian
    'suomi.tcl': 'fi',        # Finnish
    'SerbCyr.tcl': 'sr',      # Serbian Cyrillic
    'romanian.tcl': 'ro',     # Romanian
    'japanese.tcl': 'ja',     # Japanese
    'turkish.tcl': 'tr',      # Turkish
    'hebrew.tcl': 'he',       # Hebrew
    'swahili.tcl': 'sw',      # Swahili
    'hindi.tcl': 'hi',        # Hindi
    'ukrainian.tcl': 'uk',    # Ukrainian
    'bengali.tcl': 'bn',      # Bengali
    'korean.tcl': 'ko',       # Korean
    'bulgarian.tcl': 'bg',    # Bulgarian
}

def get_encoding_for_file(input_file):
    """Get the encoding for a language file based on hard-coded lookup table.
    This matches the encoding specified in language.tcl addLanguage commands."""
    
    # Hard-coded encoding lookup based on language.tcl
    encoding_map = {
        'english.tcl': 'utf-8',
        'catalan.tcl': 'utf-8',
        'czech.tcl': 'utf-8',
        'deutsch.tcl': 'utf-8',
        'francais.tcl': 'utf-8',
        'greek.tcl': 'utf-8',
        'hungary.tcl': 'utf-8',
        'italian.tcl': 'utf-8',
        'nederlan.tcl': 'utf-8',
        'norsk.tcl': 'utf-8',
        'polish.tcl': 'utf-8',
        'portbr.tcl': 'utf-8',
        'russian.tcl': 'utf-8',
        'serbian.tcl': 'iso8859-2',
        'spanish.tcl': 'utf-8',
        'suomi.tcl': 'utf-8',
        'swedish.tcl': 'utf-8',
        'turkish.tcl': 'utf-8',
        'SerbCyr.tcl': 'utf-8',
        'japanese.tcl': 'utf-8',
        'romanian.tcl': 'utf-8',
        'chinese.tcl': 'utf-8', 
        'hebrew.tcl': 'utf-8',
        'swahili.tcl': 'utf-8',
        'hindi.tcl': 'utf-8',
        'ukrainian.tcl': 'utf-8',
        'bengali.tcl': 'utf-8',
        'korean.tcl': 'utf-8',
        'bulgarian.tcl': 'utf-8',
    }
    
    # Extract filename from path
    filename = os.path.basename(input_file)
    
    # Return encoding from map, default to utf-8 if not found
    return encoding_map.get(filename, 'utf-8')

def to_tcl_unicode(text):
    return text

def safe_translate(session, text, src='en', dest='es', max_retries=3):
    """
    Safely translate text with retry logic and error handling.
    Returns the translated text on success, or None on failure.
    """
    if not text or not text.strip():
        return text

    for attempt in range(max_retries):
        try:
            # Add a small delay to avoid rate limiting
            if attempt > 0:
                time.sleep(1 + attempt)

            return session.translate(text, src=src, dest=dest)

        except Exception as e:
            if attempt == max_retries - 1:
                print(f"    Translation failed after {max_retries} attempts: {e}")
                return None
            time.sleep(1)

    return None

def process_all_files(script_dir):
    """
    Process all language files in the current directory.
    Uses the LANGUAGE_FILE_MAP to determine the appropriate language code for each file.
    """
    print("="*70)
    print("Processing all language files...")
    print("="*70)
    
    total_files = 0
    total_translations = 0
    skipped_files = []
    processed_files = []
    
    for filename, lang_code in sorted(LANGUAGE_FILE_MAP.items()):
        file_path = os.path.join(script_dir, filename)
        
        if not os.path.exists(file_path):
            print(f"\nSkipping {filename}: File not found")
            skipped_files.append(filename)
            continue
        
        print(f"\n{'='*70}")
        print(f"Processing: {filename} -> Language: {lang_code}")
        print(f"{'='*70}")
        
        try:
            # Get encoding for this file
            encoding = get_encoding_for_file(file_path)
            
            # Process the file
            result = process_file(file_path, lang_code, encoding, return_stats=True)
            
            if result:
                total_files += 1
                total_translations += result.get('translation_count', 0)
                processed_files.append((filename, result.get('translation_count', 0)))
        
        except Exception as e:
            print(f"\nError processing {filename}: {e}")
            skipped_files.append(filename)
    
    # Summary
    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print(f"Files processed: {total_files}")
    print(f"Total translations: {total_translations}")
    
    if processed_files:
        print("\nFiles with translations:")
        for fname, count in processed_files:
            if count > 0:
                print(f"  {fname}: {count} translations")
    
    if skipped_files:
        print(f"\nSkipped files: {', '.join(skipped_files)}")
    
    print("\nNote: Check the .new files for each language file.")
    print("="*70)

def process_file(input_file, target_language, encoding, return_stats=False):
    session = TranslationSession()
    output_file = input_file + '.new'

    if encoding is None:
        encoding = get_encoding_for_file(input_file)
        print(f"Using encoding: {encoding}")

    try:
        with open(input_file, 'r', encoding=encoding, errors='replace') as infile:
            lines = infile.readlines()

        with open(output_file, 'w', encoding=encoding, errors='replace') as outfile:
            
            i = 0
            translation_count = 0
            
            while i < len(lines):
                line = lines[i]
                outfile.write(line)
                
                if '# ====== TODO To be translated ======' in line:
                    if i + 1 < len(lines):
                        next_line = lines[i+1]
                        
                        # Collect all lines for this entry (handle multi-line)
                        entry_lines = [next_line]
                        brace_count = next_line.count('{') - next_line.count('}')
                        has_backslash = next_line.rstrip().endswith('\\')
                        
                        # Continue collecting lines if braces aren't balanced or there's a backslash
                        j = i + 2
                        while (brace_count > 0 or has_backslash) and j < len(lines):
                            entry_lines.append(lines[j])
                            brace_count += lines[j].count('{') - lines[j].count('}')
                            has_backslash = lines[j].rstrip().endswith('\\')
                            j += 1
                        
                        # Join all lines for analysis
                        full_entry = ''.join(entry_lines)
                        first_line = entry_lines[0]
                        
                        translated_lines = None
                        
                        # Regex 1: menuText with text in quotes AND braces (The full format)
                        match_full = re.search(r'^(menuText\s+.*?)"(.*?)"(.*?)\{(.*)\}(\s*)$', full_entry, re.DOTALL)
                        
                        # Regex 2: menuText with JUST quotes
                        match_quotes = re.search(r'^(menuText\s+.*?)"(.*?)"(.*?)$', first_line)
                        
                        # Regex 3: translate command with braces (single or multi-line)
                        match_trans_braces = re.search(r'^(translate\s+.*?)\{(.*)\}(\s*)$', full_entry, re.DOTALL)
                        
                        # Regex 4: translate command with quotes
                        match_trans_quotes = re.search(r'^(translate\s+.*?)"(.*)"(\s*)$', first_line)

                        if match_full:
                            print(f"Translating Line {i+2} (menuText full, {len(entry_lines)} lines)...")
                            text1_tr = safe_translate(session, match_full.group(2), src='en', dest=target_language)
                            text2_tr = safe_translate(session, match_full.group(4), src='en', dest=target_language)
                            if text1_tr is not None and text2_tr is not None:
                                translated_lines = f'{match_full.group(1)}"{text1_tr}"{match_full.group(3)}{{{text2_tr}}}{match_full.group(5)}'

                        elif match_quotes:
                            print(f"Translating Line {i+2} (menuText quotes)...")
                            text1_tr = safe_translate(session, match_quotes.group(2), src='en', dest=target_language)
                            if text1_tr is not None:
                                translated_lines = f'{match_quotes.group(1)}"{text1_tr}"{match_quotes.group(3)}\n'

                        elif match_trans_braces:
                            print(f"Translating Line {i+2} (translate braces, {len(entry_lines)} lines)...")
                            text_tr = safe_translate(session, match_trans_braces.group(2), src='en', dest=target_language)
                            if text_tr is not None:
                                translated_lines = f'{match_trans_braces.group(1)}{{{text_tr}}}{match_trans_braces.group(3)}'

                        elif match_trans_quotes:
                            print(f"Translating Line {i+2} (translate quotes)...")
                            text_tr = safe_translate(session, match_trans_quotes.group(2), src='en', dest=target_language)
                            if text_tr is not None:
                                translated_lines = f'{match_trans_quotes.group(1)}"{text_tr}"{match_trans_quotes.group(3)}\n'

                        if translated_lines:
                            outfile.write(translated_lines)
                            translation_count += 1
                            i += len(entry_lines)  # Skip all the lines we've processed
                        else:
                            if match_full or match_quotes or match_trans_braces or match_trans_quotes:
                                print(f"Warning: Translation failed for line {i+2}, preserving TODO marker.")
                            else:
                                print(f"Warning: Line {i+2} follows TODO but doesn't match any expected format.")
                                print(f"  Content: {first_line.strip()}")
                
                i += 1

        print(f"\n{'='*50}")
        print(f"Translation complete!")
        print(f"Lines translated: {translation_count}")
        print(f"Output saved to: {output_file}")
        
        if return_stats:
            return {
                'translation_count': translation_count,
                'output_file': output_file
            }
        
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found")
        if return_stats:
            return None
        sys.exit(1)
    except Exception as e:
        print(f"Error processing file: {e}")
        import traceback
        traceback.print_exc()
        if return_stats:
            return None
        sys.exit(1)
    finally:
        session.close()

def main():
    # Translate all TODO comments in spanish.tcl to Spanish
    #     python3 machineTranslate.py spanish.tcl -l es
    # Or explicitly specify encoding (though auto-detection works)
    #     python3 machineTranslate.py spanish.tcl -l es -e utf-8
    # Process all language files
    #     python3 machineTranslate.py --all
    parser = argparse.ArgumentParser(
        description='Translate TODO-marked lines in language files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Process a single file:
    python3 machineTranslate.py spanish.tcl -l es
  
  Process all language files:
    python3 machineTranslate.py --all
        """)
    
    parser.add_argument('filename', nargs='?', help='Input file to process (not needed with --all)')
    parser.add_argument('-l', '--language', default='es',
                       help='Target language code (default: es for Spanish)')
    parser.add_argument('-e', '--encoding', default=None,
                       help='File encoding to force')
    parser.add_argument('--all', action='store_true',
                       help='Process all language files in the current directory')

    args = parser.parse_args()

    print(f"googletrans {googletrans.__version__} - {'async' if _IS_ASYNC else 'sync'} mode")

    if args.all:
        # Process all language files
        script_dir = os.path.dirname(os.path.abspath(__file__))
        process_all_files(script_dir)
    else:
        # Process single file
        if not args.filename:
            parser.error('filename is required when not using --all')
        
        print(f"Processing file: {args.filename}")
        print(f"Target language: {args.language}")
        print("-" * 50)

        process_file(args.filename, args.language, args.encoding)

if __name__ == '__main__':
    main()