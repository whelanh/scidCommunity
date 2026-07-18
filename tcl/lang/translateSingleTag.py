#!/usr/bin/env python3
"""
Targeted script to translate a single translate tag across all language files.
Reads the English placeholder for the tag, machine‑translates it into each
target language, and writes the translation back in place.

Usage:
    python3 translateSingleTag.py AddScoreToAllMoves   # process all languages
    python3 translateSingleTag.py AddScoreToAllMoves -f deutsch.tcl  # single file
    python3 translateSingleTag.py MyTag -e "English text"  # custom English source
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

_IS_ASYNC = inspect.iscoroutinefunction(Translator.translate)


class TranslationSession:
    """Synchronous facade over googletrans (same as machineTranslate.py)."""

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


LANGUAGE_FILE_MAP = {
    'catalan.tcl': 'ca',
    'czech.tcl': 'cs',
    'deutsch.tcl': 'de',
    'francais.tcl': 'fr',
    'greek.tcl': 'el',
    'hungary.tcl': 'hu',
    'italian.tcl': 'it',
    'chinese.tcl': 'zh-cn',
    'nederlan.tcl': 'nl',
    'norsk.tcl': 'no',
    'polish.tcl': 'pl',
    'portbr.tcl': 'pt',
    'spanish.tcl': 'es',
    'swedish.tcl': 'sv',
    'russian.tcl': 'ru',
    'suomi.tcl': 'fi',
    'SerbCyr.tcl': 'sr',
    'romanian.tcl': 'ro',
    'japanese.tcl': 'ja',
    'turkish.tcl': 'tr',
    'hebrew.tcl': 'he',
    'swahili.tcl': 'sw',
    'hindi.tcl': 'hi',
    'ukrainian.tcl': 'uk',
    'bengali.tcl': 'bn',
    'korean.tcl': 'ko',
    'bulgarian.tcl': 'bg',
}

SKIP_FILES = {'ukrainian.tcl'}

# Default English text for known tags. Falls back to the tag name itself.
DEFAULT_ENGLISH_TEXTS = {
    'AddScoreToAllMoves': "Add score to all moves",
}


def get_encoding_for_file(filepath):
    filename = os.path.basename(filepath)
    if filename == 'serbian.tcl':
        return 'iso8859-2'
    return 'utf-8'


def safe_translate(session, text, dest, max_retries=3):
    if not text or not text.strip():
        return text
    for attempt in range(max_retries):
        try:
            if attempt > 0:
                time.sleep(1 + attempt)
            return session.translate(text, src='en', dest=dest)
        except Exception as e:
            if attempt == max_retries - 1:
                print(f"    Translation failed after {max_retries} attempts: {e}")
                return None
            time.sleep(1)
    return None


def process_file(filepath, lang_code, encoding, tag, english_text):
    session = TranslationSession()

    target_re = re.compile(
        r'^(translate\s+\S+\s+' + re.escape(tag) + r'\s+)\{.*\}(\s*)$'
    )

    try:
        with open(filepath, 'r', encoding=encoding, errors='replace') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Skipping {filepath}: not found")
        session.close()
        return None

    found = False
    new_lines = []
    for i, line in enumerate(lines):
        m = target_re.match(line)
        if m:
            prefix = m.group(1)
            suffix = m.group(2)
            print(f"  Translating line {i+1} ({lang_code})...", end=' ', flush=True)
            translated = safe_translate(session, english_text, dest=lang_code)
            if translated is not None:
                new_lines.append(f'{prefix}{{{translated}}}{suffix}')
                print(f'-> "{translated}"')
                found = True
            else:
                new_lines.append(line)
                print('FAILED (keeping original)')
        else:
            new_lines.append(line)

    session.close()

    if not found:
        print(f'No {tag} line found in {filepath}')
        return None

    with open(filepath, 'w', encoding=encoding) as f:
        f.writelines(new_lines)

    print(f'  Wrote {filepath}')
    return filepath


def process_all(script_dir, tag, english_text):
    print('=' * 70)
    print(f'Translating {tag} for all language files')
    print('=' * 70)

    processed = 0
    skipped = []

    for filename, lang_code in sorted(LANGUAGE_FILE_MAP.items()):
        filepath = os.path.join(script_dir, filename)
        if not os.path.exists(filepath):
            skipped.append(filename)
            continue
        if filename in SKIP_FILES:
            print(f'\n{filename} ({lang_code}): SKIPPED (excluded)')
            continue
        print(f'\n{filename} ({lang_code}):')
        result = process_file(filepath, lang_code, get_encoding_for_file(filepath),
                              tag, english_text)
        if result:
            processed += 1

    print('\n' + '=' * 70)
    print(f'Processed: {processed}  |  Skipped (missing): {len(skipped)}')
    if skipped:
        print(f'Skipped files: {", ".join(skipped)}')
    print('\nNote: Files were modified in place. Verify with git diff.')
    print('=' * 70)


def main():
    parser = argparse.ArgumentParser(
        description='Translate a single translate tag in language files')
    parser.add_argument('tag', help='The translate tag to translate (e.g. AddScoreToAllMoves)')
    parser.add_argument('-e', '--english',
                        help='English source text for the tag (defaults to a known '
                             'mapping or the tag name itself)')
    parser.add_argument('-f', '--file',
                        help='Process a single language file (optional)')
    args = parser.parse_args()

    tag = args.tag
    english_text = args.english or DEFAULT_ENGLISH_TEXTS.get(tag, tag)

    print(f'googletrans {googletrans.__version__} - '
          f'{"async" if _IS_ASYNC else "sync"} mode')

    script_dir = os.path.dirname(os.path.abspath(__file__))

    if args.file:
        filepath = os.path.join(script_dir, args.file)
        filename = os.path.basename(filepath)
        if not os.path.exists(filepath):
            print(f'Error: {filepath} not found')
            sys.exit(1)
        if filename in SKIP_FILES:
            print(f'Skipping {filename}: excluded')
            sys.exit(0)
        lang_code = LANGUAGE_FILE_MAP.get(filename)
        if lang_code is None:
            print(f'Warning: no language code mapping for {args.file}, '
                  f'defaulting to "es"')
            lang_code = 'es'
        encoding = get_encoding_for_file(filepath)
        process_file(filepath, lang_code, encoding, tag, english_text)
    else:
        process_all(script_dir, tag, english_text)


if __name__ == '__main__':
    main()
