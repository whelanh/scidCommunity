"""
Translation Script for TODO-marked lines
...
Supported Language Encodings:
==================================================
The script will automatically detect encoding or you can specify it with -e flag:
  utf-8         - English, French, Greek, Italian, Russian, Chinese
  iso8859-1     - Catalan, German, Dutch, Norwegian, Portuguese, Spanish, Finnish, Swedish
  iso8859-2     - Czech, Hungarian, Polish, Serbian

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
# from googletrans import Translator # We will import inside main/async to avoiding global side effects if possible, but global is fine.
from googletrans import Translator
import re
import time
import asyncio

def detect_encoding(input_file):
    """Try to detect the file encoding by attempting to read with common encodings."""
    encodings = ['utf-8', 'iso8859-1', 'iso8859-2', 'cp1252', 'latin-1']
    for encoding in encodings:
        try:
            with open(input_file, 'r', encoding=encoding) as f:
                f.read()
            return encoding
        except (UnicodeDecodeError, LookupError):
            continue
    return 'iso8859-1'

def to_tcl_unicode(text):
    return text

async def safe_translate(translator, text, src='en', dest='es', max_retries=3):
    """
    Safely translate text with retry logic and error handling.
    """
    if not text or not text.strip():
        return text

    for attempt in range(max_retries):
        try:
            # Add a small delay to avoid rate limiting
            if attempt > 0:
                await asyncio.sleep(1 + attempt)

            result = await translator.translate(text, src=src, dest=dest)

            if hasattr(result, 'text'):
                return result.text
            else:
                return str(result)

        except Exception as e:
            if attempt == max_retries - 1:
                print(f"    Translation failed after {max_retries} attempts: {e}")
                return text
            await asyncio.sleep(1)

    return text

async def process_file(input_file, target_language, encoding):
    translator = Translator()
    output_file = input_file + '.new'

    if encoding is None:
        encoding = detect_encoding(input_file)
        print(f"Detected encoding: {encoding}")

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
                        # We need to skip writing the *original* next_line in the loop,
                        # because we will write a translated replacement (or the original if no match).
                        # But wait, my logic before was: write line (TODO), then inspect next_line.
                        # If matches, write REPLACEMENT and skip next_line.
                        # If NO match, write nothing (let next loop iteration handle it).
                        
                        translated_line = None
                        
                        # Regex 1: menuText with text in quotes AND braces (The full format)
                        # menuText .mbar.tools "Analysis engine..." 0 {Open an analysis window}
                        match_full = re.search(r'^(menuText\s+.*?)"(.*?)"(.*?)\{(.*)\}(\s*)$', next_line)
                        
                        # Regex 2: menuText with JUST quotes
                        # menuText S GraphOptionsEloFile "Elo from rating file" 0
                        match_quotes = re.search(r'^(menuText\s+.*?)"(.*?)"(.*?)$', next_line)
                        
                        # Regex 3: translate command with braces
                        # translate S Hide {Hide}
                        match_trans_braces = re.search(r'^(translate\s+.*?)\{(.*)\}(\s*)$', next_line)
                        
                        # Regex 4: translate command with quotes
                        # translate S OptionsInternationalization "Internationalization"
                        match_trans_quotes = re.search(r'^(translate\s+.*?)"(.*)"(\s*)$', next_line)

                        if match_full:
                            print(f"Translating Line {i+2} (menuText full)...")
                            text1_tr = await safe_translate(translator, match_full.group(2), src='en', dest=target_language)
                            text2_tr = await safe_translate(translator, match_full.group(4), src='en', dest=target_language)
                            translated_line = f'{match_full.group(1)}"{text1_tr}"{match_full.group(3)}{{{text2_tr}}}{match_full.group(5)}\n'
                            
                        elif match_quotes:
                            print(f"Translating Line {i+2} (menuText quotes)...")
                            text1_tr = await safe_translate(translator, match_quotes.group(2), src='en', dest=target_language)
                            translated_line = f'{match_quotes.group(1)}"{text1_tr}"{match_quotes.group(3)}\n'

                        elif match_trans_braces:
                            print(f"Translating Line {i+2} (translate braces)...")
                            text_tr = await safe_translate(translator, match_trans_braces.group(2), src='en', dest=target_language)
                            translated_line = f'{match_trans_braces.group(1)}{{{text_tr}}}{match_trans_braces.group(3)}\n'

                        elif match_trans_quotes:
                            print(f"Translating Line {i+2} (translate quotes)...")
                            text_tr = await safe_translate(translator, match_trans_quotes.group(2), src='en', dest=target_language)
                            translated_line = f'{match_trans_quotes.group(1)}"{text_tr}"{match_trans_quotes.group(3)}\n'

                        if translated_line:
                            outfile.write(translated_line)
                            translation_count += 1
                            i += 1 # Skip the next line as we've handled it
                        else:
                            print(f"Warning: Line {i+2} follows TODO but doesn't match any expected format.")
                            print(f"  Content: {next_line.strip()}")
                
                i += 1

        print(f"\n{'='*50}")
        print(f"Translation complete!")
        print(f"Lines translated: {translation_count}")
        print(f"Output saved to: {output_file}")
        
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error processing file: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Translate TODO-marked lines in a file')
    parser.add_argument('filename', help='Input file to process')
    parser.add_argument('-l', '--language', default='es',
                       help='Target language code (default: es for Spanish)')
    parser.add_argument('-e', '--encoding', default=None,
                       help='File encoding to force')

    args = parser.parse_args()

    print(f"Processing file: {args.filename}")
    print(f"Target language: {args.language}")
    print("-" * 50)

    asyncio.run(process_file(args.filename, args.language, args.encoding))

if __name__ == '__main__':
    main()
