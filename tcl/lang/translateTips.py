"""
Tip of the Day translation scaffold generator
==============================================

scidCommunity only ships an English "Tip of the Day" list, defined as
    set tips(E) { ... }
in tcl/help/tips.tcl.  The ::tip::show proc (same file) already looks up
tips($language) and falls back to tips(E), so all that is missing for a
translated Tip of the Day is a top-level "set tips(<letter>) { ... }" block
in each language file.

This script:
  1. Extracts the English tips(E) entries from ../help/tips.tcl
  2. Translates each entry with Google Translate (googletrans), protecting the
     htext markup tags (<a Target>, </a>, <b>, </b>, <red>, ...) so link
     targets and formatting are preserved verbatim and only the visible
     prose / link text is translated.
  3. Appends a "set tips(<letter>) { ... }" scaffold to the END (top level,
     outside setLanguage_X) of each language file.

The single-letter language code and the file list are read from
../language.tcl (the addLanguage commands).  serbian.tcl is skipped (Google
Translate has no Serbian-Latin target and the file is iso8859-2); the Serbian
Cyrillic file (SerbCyr.tcl, code J) is handled normally.

All target files are UTF-8 and are read/written as UTF-8 to preserve
diacritics.

The result is a MACHINE-TRANSLATED SCAFFOLD intended to be reviewed and
corrected by a human translator.

Usage:
  python3 translateTips.py --all                 # all languages, append in place
  python3 translateTips.py polish.tcl            # one file, append in place
  python3 translateTips.py --all --dry-run       # write <file>.tips.new previews only
  python3 translateTips.py --all --force         # overwrite/duplicate even if tips(X) exists
  python3 translateTips.py --list                # just show the resolved mapping
"""

import sys
import os
import re
import argparse
import asyncio

from googletrans import Translator

# Map language file -> Google Translate language code.
# (english.tcl is the source; serbian.tcl is intentionally absent.)
LANGUAGE_FILE_MAP = {
    'catalan.tcl': 'ca',
    'czech.tcl': 'cs',
    'deutsch.tcl': 'de',
    'francais.tcl': 'fr',
    'greek.tcl': 'el',
    'hungary.tcl': 'hu',
    'italian.tcl': 'it',
    'nederlan.tcl': 'nl',
    'norsk.tcl': 'no',
    'polish.tcl': 'pl',
    'portbr.tcl': 'pt',
    'russian.tcl': 'ru',
    'spanish.tcl': 'es',
    'suomi.tcl': 'fi',
    'swedish.tcl': 'sv',
    'chinese.tcl': 'zh-cn',
    'turkish.tcl': 'tr',
    'SerbCyr.tcl': 'sr',
    'japanese.tcl': 'ja',
    'romanian.tcl': 'ro',
    'hebrew.tcl': 'he',
    'swahili.tcl': 'sw',
    'hindi.tcl': 'hi',
    'ukrainian.tcl': 'uk',
    'bengali.tcl': 'bn',
    'korean.tcl': 'ko',
    'bulgarian.tcl': 'bg',
}

# Each markup tag is replaced by an ASCII sentinel of the form (ZXQ<n>) while
# the surrounding prose is translated, then restored afterwards.  "ZXQ" is not
# a word in any target language and the parentheses help Google Translate treat
# the whole token as an untranslatable unit.  If the sentinels don't survive a
# translation intact, the tip is re-translated with a segmented method that
# never sends the tags to Google at all (see translate_tip).
TAG_RE = re.compile(r'<[^>]*>')
TAG_SPLIT_RE = re.compile(r'(<[^>]*>)')
SENTINEL_RE = re.compile(r'\(\s*[Zz][Xx][Qq]\s*(\d+)\s*\)')
SENTINEL_FRAGMENT_RE = re.compile(r'[Zz][Xx][Qq]')
# An opening tag immediately followed by a closing tag (only whitespace
# between) means a translated link/emphasis lost its text - the placeholders
# were reordered away from the words they should wrap.
EMPTY_TAG_RE = re.compile(r'<[A-Za-z][^>]*>\s*</[A-Za-z][^>]*>')


def make_sentinel(idx):
    return '(ZXQ%d)' % idx


def script_dir():
    return os.path.dirname(os.path.abspath(__file__))


def parse_language_tcl(path):
    """Return {filename: (letter, encoding)} from the addLanguage commands."""
    result = {}
    line_re = re.compile(r'^addLanguage\s+(\S+)\s+\S+\s+\d+\s+(\S+)\s+(\S+)\s*$')
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            m = line_re.match(line.strip())
            if m:
                letter, encoding, filename = m.group(1), m.group(2), m.group(3)
                result[filename] = (letter, encoding)
    return result


def _match_brace(text, open_index):
    """Given index of a '{' in text, return index of the matching '}'."""
    depth = 0
    i = open_index
    n = len(text)
    while i < n:
        c = text[i]
        if c == '\\':
            i += 2
            continue
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("Unbalanced braces while parsing tips(E)")


def extract_english_tips(tips_path):
    """Extract the English tip entries from tips(E) as a list of strings."""
    with open(tips_path, 'r', encoding='utf-8', errors='replace') as f:
        text = f.read()

    m = re.search(r'set\s+tips\(E\)', text)
    if not m:
        raise ValueError("Could not find 'set tips(E)' in " + tips_path)
    open_brace = text.index('{', m.end())
    close_brace = _match_brace(text, open_brace)
    body = text[open_brace + 1:close_brace]

    tips = []
    i = 0
    n = len(body)
    while i < n:
        if body[i] == '{':
            end = _match_brace(body, i)
            raw = body[i + 1:end]
            # Collapse the source's hand-wrapped indentation into one line.
            collapsed = ' '.join(raw.split())
            if collapsed:
                tips.append(collapsed)
            i = end + 1
        else:
            i += 1
    return tips


def protect_tags(text):
    tags = []

    def repl(match):
        idx = len(tags)
        tags.append(match.group(0))
        return make_sentinel(idx)

    return TAG_RE.sub(repl, text), tags


def restore_tags(text, tags):
    def repl(match):
        idx = int(match.group(1))
        return tags[idx] if 0 <= idx < len(tags) else match.group(0)

    return SENTINEL_RE.sub(repl, text)


def sanitize_for_tcl_braces(text):
    """Braces would unbalance the Tcl list; replace any stray ones."""
    if '{' in text or '}' in text:
        text = text.replace('{', '(').replace('}', ')')
    return text


async def safe_translate(translator, text, dest, max_retries=3):
    if not text or not text.strip():
        return text
    for attempt in range(max_retries):
        try:
            if attempt > 0:
                await asyncio.sleep(1 + attempt)
            result = await translator.translate(text, src='en', dest=dest)
            return result.text if hasattr(result, 'text') else str(result)
        except Exception as e:
            if attempt == max_retries - 1:
                print("    Translation failed after %d attempts: %s" % (max_retries, e))
                raise
            await asyncio.sleep(1)
    raise RuntimeError("Translation failed after exhausting retries")


async def translate_segments(translator, tip, dest):
    """Translate only the non-tag text runs; tags are emitted unchanged."""
    parts = TAG_SPLIT_RE.split(tip)
    out = []
    for k, seg in enumerate(parts):
        if k % 2 == 1:            # a captured <...> tag
            out.append(seg)
            continue
        if not seg.strip():
            out.append(seg)
            continue
        lead = seg[:len(seg) - len(seg.lstrip())]
        trail = seg[len(seg.rstrip()):]
        core = await safe_translate(translator, seg.strip(), dest)
        out.append(lead + core + trail)
    return ''.join(out)


async def translate_tip(translator, tip, dest):
    # Primary: translate the whole tip with the tags protected as sentinels.
    try:
        protected, tags = protect_tags(tip)
        translated = await safe_translate(translator, protected, dest)
        restored = restore_tags(translated, tags)
        # Accept the result only if every tag came back, in the original order,
        # with no leftover sentinel debris and no link left wrapping empty text.
        good = (TAG_RE.findall(restored) == tags
                and not SENTINEL_FRAGMENT_RE.search(restored)
                and not EMPTY_TAG_RE.search(restored))
        if good:
            return sanitize_for_tcl_braces(restored.strip()), True
        # Otherwise re-translate without ever sending the tags to Google, which
        # keeps every tag exactly where it belongs (at some cost to fluency).
        seg = await translate_segments(translator, tip, dest)
        return sanitize_for_tcl_braces(seg.strip()), False
    except Exception:
        return None, False


def build_tips_block(letter, lang_name, translated_tips):
    lines = []
    lines.append("")
    lines.append("")
    lines.append("############################################################")
    lines.append("#")
    lines.append("# %s tip of the day" % lang_name)
    lines.append("# Machine-translated scaffold - please review and correct.")
    lines.append("")
    lines.append("set tips(%s) {" % letter)
    for tip in translated_tips:
        lines.append("  {")
        lines.append("    " + tip)
        lines.append("  }")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def already_has_tips(path, letter, encoding):
    pat = re.compile(r'set\s+tips\(' + re.escape(letter) + r'\)')
    with open(path, 'r', encoding=encoding, errors='replace') as f:
        return bool(pat.search(f.read()))


async def process_language_file(translator, filename, letter, encoding, lang_name,
                                english_tips, dry_run, force):
    path = os.path.join(script_dir(), filename)
    if not os.path.exists(path):
        print("  Skipping %s: file not found" % filename)
        return False

    if not force and already_has_tips(path, letter, encoding):
        print("  Skipping %s: set tips(%s) already present (use --force)"
              % (filename, letter))
        return False

    dest = LANGUAGE_FILE_MAP[filename]
    print("\n%s  ->  tips(%s)  [%s]" % (filename, letter, dest))
    translated = []
    fallbacks = 0
    for n, tip in enumerate(english_tips, start=1):
        out, ok = await translate_tip(translator, tip, dest)
        if out is None:
            fallbacks += 1
            print("    tip %d: translation failed, skipping" % n)
            continue
        if not ok:
            fallbacks += 1
            print("    tip %d: used tag-safe segmented fallback (review wording)" % n)
        translated.append(out)
        await asyncio.sleep(0.2)

    block = build_tips_block(letter, lang_name, translated)

    if dry_run:
        out_path = path + '.tips.new'
        with open(out_path, 'w', encoding=encoding) as f:
            f.write(block)
        print("  Wrote preview: %s (%d tips, %d fallbacks)"
              % (out_path, len(translated), fallbacks))
    else:
        with open(path, 'r', encoding=encoding, errors='replace') as f:
            content = f.read()
        if not content.endswith('\n'):
            content += '\n'
        with open(path, 'w', encoding=encoding) as f:
            f.write(content)
            f.write(block)
        print("  Appended to %s (%d tips, %d fallbacks)"
              % (filename, len(translated), fallbacks))
    return True


def resolve_targets(lang_map):
    """Yield (filename, letter, encoding, lang_name) for translatable files."""
    lang_names = {
        'catalan.tcl': 'Catalan', 'czech.tcl': 'Czech', 'deutsch.tcl': 'German',
        'francais.tcl': 'French', 'greek.tcl': 'Greek', 'hungary.tcl': 'Hungarian',
        'italian.tcl': 'Italian', 'nederlan.tcl': 'Dutch', 'norsk.tcl': 'Norwegian',
        'polish.tcl': 'Polish', 'portbr.tcl': 'Portuguese', 'russian.tcl': 'Russian',
        'spanish.tcl': 'Spanish', 'suomi.tcl': 'Finnish', 'swedish.tcl': 'Swedish',
        'chinese.tcl': 'Chinese', 'turkish.tcl': 'Turkish', 'SerbCyr.tcl': 'Serbian (Cyrillic)',
        'japanese.tcl': 'Japanese', 'romanian.tcl': 'Romanian', 'hebrew.tcl': 'Hebrew',
        'swahili.tcl': 'Swahili', 'hindi.tcl': 'Hindi', 'ukrainian.tcl': 'Ukrainian',
        'bengali.tcl': 'Bengali', 'korean.tcl': 'Korean', 'bulgarian.tcl': 'Bulgarian',
    }
    for filename in sorted(LANGUAGE_FILE_MAP):
        if filename not in lang_map:
            print("  Note: %s is in LANGUAGE_FILE_MAP but not in language.tcl; skipping"
                  % filename)
            continue
        letter, encoding = lang_map[filename]
        yield filename, letter, encoding, lang_names.get(filename, filename)


async def process_all(english_tips, lang_map, dry_run, force, only_file):
    translator = Translator()
    done = 0
    for filename, letter, encoding, lang_name in resolve_targets(lang_map):
        if only_file and filename != only_file:
            continue
        if await process_language_file(translator, filename, letter, encoding,
                                       lang_name, english_tips, dry_run, force):
            done += 1
    print("\n" + "=" * 60)
    print("Done. Language files updated: %d" % done)
    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description='Generate translated Tip of the Day scaffolds for language files.',
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('filename', nargs='?',
                        help='Single language file to process (e.g. polish.tcl)')
    parser.add_argument('--all', action='store_true',
                        help='Process every translatable language file')
    parser.add_argument('--dry-run', action='store_true',
                        help='Write <file>.tips.new previews instead of editing files')
    parser.add_argument('--force', action='store_true',
                        help='Append even if a set tips(<letter>) block already exists')
    parser.add_argument('--list', action='store_true',
                        help='Print the resolved file/letter/code mapping and exit')
    args = parser.parse_args()

    tips_path = os.path.normpath(os.path.join(script_dir(), '..', 'help', 'tips.tcl'))
    lang_tcl_path = os.path.normpath(os.path.join(script_dir(), '..', 'language.tcl'))

    lang_map = parse_language_tcl(lang_tcl_path)

    if args.list:
        for filename, letter, encoding, lang_name in resolve_targets(lang_map):
            print("%-15s letter=%-2s gtcode=%-6s %s"
                  % (filename, letter, LANGUAGE_FILE_MAP[filename], lang_name))
        return

    if not args.all and not args.filename:
        parser.error('Specify a filename, or use --all')

    english_tips = extract_english_tips(tips_path)
    print("Extracted %d English tips from %s" % (len(english_tips), tips_path))

    only_file = None
    if args.filename:
        only_file = os.path.basename(args.filename)
        if only_file not in LANGUAGE_FILE_MAP:
            parser.error('%s is not a translatable language file' % only_file)

    asyncio.run(process_all(english_tips, lang_map, args.dry_run, args.force, only_file))


if __name__ == '__main__':
    main()
