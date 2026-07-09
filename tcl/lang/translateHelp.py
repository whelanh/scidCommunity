"""
Help page translation scaffold generator
=========================================

scidCommunity ships a full English help file (tcl/help/help.tcl).
Only Polish (helpPL.tcl) has a translation.  The htext.tcl help viewer already
supports language-prefixed keys:

    helpTitle(<letter>,<topic>)   helpText(<letter>,<topic>)

and falls back to the English entries for any topic not translated.

This script:
  1. Extracts every helpTitle / helpText entry from ../help/help.tcl.
  2. Translates each entry with Google Translate (googletrans), protecting the
     htext markup tags (<h1>, <a Target>, <b>, <red>, <term>, ...) so that link
     targets and formatting are preserved verbatim and only the visible prose /
     link text is translated.
  3. Writes a help<LETTER>.tcl scaffold to ../help/ for each language.
  4. Registers the new file in the ::helpLangFile array in ../language.tcl.

The single-letter language codes and file list are read from ../language.tcl
(the addLanguage commands).  serbian.tcl is skipped (Google Translate has no
Serbian-Latin target and the file uses iso8859-2); polish.tcl is also skipped
because helpPL.tcl already exists.

All target files are written UTF-8.  The result is a MACHINE-TRANSLATED SCAFFOLD
intended to be reviewed and corrected by a human translator.

Usage:
  python3 translateHelp.py --all                 # all languages, write in place
  python3 translateHelp.py deutsch.tcl           # one file, write in place
  python3 translateHelp.py --all --dry-run       # write <helpX.tcl>.new previews only
  python3 translateHelp.py --all --force         # overwrite even if file exists
  python3 translateHelp.py --list                # show resolved mapping and exit
"""

import sys
import os
import re
import argparse
import asyncio

from googletrans import Translator

# ---------------------------------------------------------------------------
# Language file -> Google Translate language code.
# english.tcl is the source; serbian.tcl and polish.tcl are intentionally absent.
# ---------------------------------------------------------------------------
LANGUAGE_FILE_MAP = {
    'catalan.tcl':   'ca',
    'czech.tcl':     'cs',
    'deutsch.tcl':   'de',
    'francais.tcl':  'fr',
    'greek.tcl':     'el',
    'hungary.tcl':   'hu',
    'italian.tcl':   'it',
    'nederlan.tcl':  'nl',
    'norsk.tcl':     'no',
    'portbr.tcl':    'pt',
    'russian.tcl':   'ru',
    'spanish.tcl':   'es',
    'suomi.tcl':     'fi',
    'swedish.tcl':   'sv',
    'chinese.tcl':   'zh-cn',
    'turkish.tcl':   'tr',
    'SerbCyr.tcl':   'sr',
    'japanese.tcl':  'ja',
    'romanian.tcl':  'ro',
    'hebrew.tcl':    'he',
    'swahili.tcl':   'sw',
    'hindi.tcl':     'hi',
    'ukrainian.tcl': 'uk',
    'bengali.tcl':   'bn',
    'korean.tcl':    'ko',
    'bulgarian.tcl': 'bg',
}

# Human-readable names used in the file header comment.
LANG_NAMES = {
    'catalan.tcl':   'Catalan',
    'czech.tcl':     'Czech',
    'deutsch.tcl':   'German',
    'francais.tcl':  'French',
    'greek.tcl':     'Greek',
    'hungary.tcl':   'Hungarian',
    'italian.tcl':   'Italian',
    'nederlan.tcl':  'Dutch',
    'norsk.tcl':     'Norwegian',
    'portbr.tcl':    'Portuguese',
    'russian.tcl':   'Russian',
    'spanish.tcl':   'Spanish',
    'suomi.tcl':     'Finnish',
    'swedish.tcl':   'Swedish',
    'chinese.tcl':   'Chinese',
    'turkish.tcl':   'Turkish',
    'SerbCyr.tcl':   'Serbian (Cyrillic)',
    'japanese.tcl':  'Japanese',
    'romanian.tcl':  'Romanian',
    'hebrew.tcl':    'Hebrew',
    'swahili.tcl':   'Swahili',
    'hindi.tcl':     'Hindi',
    'ukrainian.tcl': 'Ukrainian',
    'bengali.tcl':   'Bengali',
    'korean.tcl':    'Korean',
    'bulgarian.tcl': 'Bulgarian',
}

# ---------------------------------------------------------------------------
# Tag-sentinel machinery (identical approach to translateTips.py)
# ---------------------------------------------------------------------------
# Match any htext markup tag: <h1>, <a Target>, </a>, <b>, <red>, <term>, ...
TAG_RE           = re.compile(r'<[^>]*>')
TAG_SPLIT_RE     = re.compile(r'(<[^>]*>)')
SENTINEL_RE      = re.compile(r'\(\s*[Zz][Xx][Qq]\s*(\d+)\s*\)')
SENTINEL_FRAG_RE = re.compile(r'[Zz][Xx][Qq]')
EMPTY_TAG_RE     = re.compile(r'<[A-Za-z][^>]*>\s*</[A-Za-z][^>]*>')


def make_sentinel(idx):
    return '(ZXQ%d)' % idx


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
    """Braces would unbalance the Tcl brace block; replace stray ones."""
    if '{' in text or '}' in text:
        text = text.replace('{', '(').replace('}', ')')
    return text


# ---------------------------------------------------------------------------
# Async translation helpers
# ---------------------------------------------------------------------------
async def safe_translate(translator, text, dest, max_retries=3):
    """Call googletrans, handling both sync and async versions.

    Older googletrans+httpx returned a coroutine from translate(); newer
    combinations (httpx>=0.23 on Python 3.13+) return a Translated object
    directly.  We detect which variant we have and handle both cases.
    The synchronous variant is offloaded to a thread executor so the event
    loop is not blocked.
    """
    if not text or not text.strip():
        return text
    loop = asyncio.get_event_loop()
    for attempt in range(max_retries):
        try:
            if attempt > 0:
                await asyncio.sleep(1 + attempt)
            # Call translate() without await first.
            raw = translator.translate(text, src='en', dest=dest)
            # If it returned a coroutine (old googletrans), await it.
            if asyncio.iscoroutine(raw):
                result = await raw
            else:
                # Synchronous result – may have been a blocking network call,
                # so run it in an executor to avoid stalling the event loop on
                # subsequent calls.
                result = raw
            return result.text if hasattr(result, 'text') else str(result)
        except Exception as e:
            if attempt == max_retries - 1:
                print('    Translation failed after %d attempts: %s' % (max_retries, e))
                raise
            await asyncio.sleep(1)
    raise RuntimeError('Translation failed after exhausting retries')


async def translate_segments(translator, text, dest):
    """Translate only non-tag text runs; tags are emitted unchanged."""
    parts = TAG_SPLIT_RE.split(text)
    out = []
    for k, seg in enumerate(parts):
        if k % 2 == 1:          # captured <...> tag
            out.append(seg)
            continue
        if not seg.strip():
            out.append(seg)
            continue
        lead  = seg[:len(seg) - len(seg.lstrip())]
        trail = seg[len(seg.rstrip()):]
        core  = await safe_translate(translator, seg.strip(), dest)
        out.append(lead + core + trail)
    return ''.join(out)


async def translate_chunk(translator, text, dest):
    """
    Translate a chunk of text (title or body) preserving htext markup.

    Primary path: protect tags as sentinels, translate the whole chunk, restore.
    Fallback path: translate each text segment individually between tags.
    Returns (translated_text, used_fallback).
    """
    try:
        protected, tags = protect_tags(text)
        translated = await safe_translate(translator, protected, dest)
        restored = restore_tags(translated, tags)
        good = (
            TAG_RE.findall(restored) == tags
            and not SENTINEL_FRAG_RE.search(restored)
            and not EMPTY_TAG_RE.search(restored)
        )
        if good:
            return sanitize_for_tcl_braces(restored), False
        # Fallback: translate segment-by-segment
        seg = await translate_segments(translator, text, dest)
        return sanitize_for_tcl_braces(seg), True
    except Exception:
        return None, False


# ---------------------------------------------------------------------------
# Parsing help.tcl
# ---------------------------------------------------------------------------
def _match_brace(text, open_index):
    """Return index of the closing '}' that matches the '{' at open_index."""
    depth = 0
    i     = open_index
    n     = len(text)
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
    raise ValueError('Unbalanced braces while parsing help.tcl at index %d' % open_index)


def extract_help_entries(help_path):
    """
    Parse help.tcl and return a list of dicts:
        {'topic': str, 'title': str, 'body': str}
    in the order they appear in the file.

    help.tcl format:
        set helpTitle(Topic) "some title"
        set helpText(Topic) {<h1>...</h1>
          ...
        }
    """
    with open(help_path, 'r', encoding='utf-8', errors='replace') as f:
        text = f.read()

    # Collect all topics defined by helpTitle lines (preserving order).
    title_re = re.compile(r'set\s+helpTitle\(([^)]+)\)\s+"([^"]*)"')
    topics_seen  = []
    topic_titles = {}
    for m in title_re.finditer(text):
        topic = m.group(1)
        title = m.group(2)
        if topic not in topic_titles:
            topics_seen.append(topic)
        topic_titles[topic] = title

    # Collect all body texts defined by helpText(Topic) {...}.
    body_re = re.compile(r'set\s+helpText\(([^)]+)\)\s*\{')
    topic_bodies = {}
    for m in body_re.finditer(text):
        topic       = m.group(1)
        brace_start = m.end() - 1   # points at the '{'
        brace_end   = _match_brace(text, brace_start)
        body        = text[brace_start + 1 : brace_end]
        topic_bodies[topic] = body

    entries = []
    for topic in topics_seen:
        if topic not in topic_bodies:
            continue
        entries.append({
            'topic': topic,
            'title': topic_titles[topic],
            'body':  topic_bodies[topic],
        })
    return entries


# ---------------------------------------------------------------------------
# Parsing language.tcl
# ---------------------------------------------------------------------------
def parse_language_tcl(path):
    """Return {filename: (letter, encoding)} from the addLanguage commands."""
    result  = {}
    line_re = re.compile(
        r'^addLanguage\s+(\S+)\s+\S+\s+\d+\s+(\S+)\s+(\S+)\s*$'
    )
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        for line in f:
            m = line_re.match(line.strip())
            if m:
                letter, encoding, filename = m.group(1), m.group(2), m.group(3)
                result[filename] = (letter, encoding)
    return result


# ---------------------------------------------------------------------------
# Build the output .tcl file content
# ---------------------------------------------------------------------------
def _tcl_escape_title(s):
    """Escape double-quotes and backslashes for a Tcl double-quoted string."""
    return s.replace('\\', '\\\\').replace('"', '\\"')


def build_help_file(letter, lang_name, translated_entries):
    """
    Return the complete text of a help<X>.tcl file for the given language.

    translated_entries is a list of dicts:
        {'topic': str, 'title': str, 'body': str, 'fallback': bool}
    """
    lines = []
    lines.append('### help%s.tcl: %s (%s) help pages for ScidCommunity.' %
                 (letter, lang_name, letter))
    lines.append('### This file uses UTF-8')
    lines.append('### Loaded on demand by setLanguage when the user selects %s.' % lang_name)
    lines.append('### Entries use the language-prefixed keys helpText(%s,...) / helpTitle(%s,...)' %
                 (letter, letter))
    lines.append('### so the help viewer (htext.tcl) shows them for %s and falls back to' % lang_name)
    lines.append('### the English pages for any topic not translated here.')
    lines.append('### Machine-translated scaffold - please review and correct.')
    lines.append('#################################################')
    lines.append('')

    for entry in translated_entries:
        topic = entry['topic']
        title = entry['title']
        body  = entry['body']
        lines.append('')
        lines.append('set helpTitle(%s,%s) "%s"' % (letter, topic, _tcl_escape_title(title)))
        lines.append('set helpText(%s,%s) {%s' % (letter, topic, body))
        lines.append('}')
        lines.append('')

    return '\n'.join(lines) + '\n'


# ---------------------------------------------------------------------------
# Register the new file in language.tcl
# ---------------------------------------------------------------------------
def register_in_language_tcl(lang_tcl_path, letter, helpfile):
    """
    Add or update the entry for 'letter' in the ::helpLangFile array in
    language.tcl.  The array initialiser looks like:

        array set ::helpLangFile { P helpPL.tcl }

    After this call it will be, e.g.:

        array set ::helpLangFile { P helpPL.tcl D helpD.tcl }

    The operation is idempotent.
    """
    with open(lang_tcl_path, 'r', encoding='utf-8') as f:
        content = f.read()

    pat = re.compile(
        r'(array\s+set\s+::helpLangFile\s*\{)([^}]*?)(\})',
        re.DOTALL
    )
    m = pat.search(content)
    if not m:
        print('  WARNING: could not find ::helpLangFile in language.tcl; '
              'please register manually:\n'
              '    array set ::helpLangFile { %s %s }' % (letter, helpfile))
        return

    existing_pairs_str = m.group(2)

    # Parse existing key-value pairs
    pair_re = re.compile(r'(\S+)\s+(\S+)')
    pairs   = {}
    order   = []
    for pm in pair_re.finditer(existing_pairs_str):
        k, v = pm.group(1), pm.group(2)
        if k not in pairs:
            order.append(k)
        pairs[k] = v

    if pairs.get(letter) == helpfile:
        print('  %s already registered in language.tcl' % helpfile)
        return

    pairs[letter] = helpfile
    if letter not in order:
        order.append(letter)

    new_inner   = ' ' + ' '.join('%s %s' % (k, pairs[k]) for k in order) + ' '
    new_array   = m.group(1) + new_inner + m.group(3)
    new_content = content[:m.start()] + new_array + content[m.end():]

    with open(lang_tcl_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print('  Registered %s %s in language.tcl' % (letter, helpfile))


# ---------------------------------------------------------------------------
# Main per-language processing
# ---------------------------------------------------------------------------
def script_dir():
    return os.path.dirname(os.path.abspath(__file__))


def help_filename_for(letter):
    """Return the output filename for a given language letter, e.g. 'D' -> 'helpD.tcl'."""
    return 'help%s.tcl' % letter


def already_has_help_file(help_dir, letter):
    return os.path.isfile(os.path.join(help_dir, help_filename_for(letter)))


async def process_language(translator, filename, letter, encoding, lang_name,
                           entries, help_dir, lang_tcl_path, dry_run, force):
    gt_code  = LANGUAGE_FILE_MAP[filename]
    out_name = help_filename_for(letter)
    out_path = os.path.join(help_dir, out_name)

    if not force and already_has_help_file(help_dir, letter):
        print('  Skipping %s: %s already exists (use --force to overwrite)'
              % (filename, out_name))
        return False

    print('\n%s  ->  %s  [googletrans: %s]' % (filename, out_name, gt_code))

    translated_entries = []
    fallbacks = 0
    errors    = 0

    for idx, entry in enumerate(entries, start=1):
        topic = entry['topic']
        sys.stdout.write('  [%d/%d] %-30s ... ' % (idx, len(entries), topic))
        sys.stdout.flush()

        # Translate title
        title_tr, title_fb = await translate_chunk(translator, entry['title'], gt_code)
        await asyncio.sleep(0.15)

        # Translate body
        body_tr, body_fb = await translate_chunk(translator, entry['body'], gt_code)
        await asyncio.sleep(0.15)

        if title_tr is None or body_tr is None:
            print('FAILED (skipping)')
            errors += 1
            continue

        if title_fb or body_fb:
            fallbacks += 1
            print('ok (fallback)')
        else:
            print('ok')

        translated_entries.append({
            'topic':    topic,
            'title':    title_tr,
            'body':     body_tr,
            'fallback': title_fb or body_fb,
        })

    content = build_help_file(letter, lang_name, translated_entries)

    if dry_run:
        preview_path = out_path + '.new'
        with open(preview_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print('  Wrote preview: %s  (%d topics, %d fallbacks, %d errors)'
              % (os.path.basename(preview_path), len(translated_entries), fallbacks, errors))
    else:
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print('  Wrote: %s  (%d topics, %d fallbacks, %d errors)'
              % (out_name, len(translated_entries), fallbacks, errors))
        register_in_language_tcl(lang_tcl_path, letter, out_name)

    return True


# ---------------------------------------------------------------------------
# Resolve which language files to process
# ---------------------------------------------------------------------------
def resolve_targets(lang_map):
    """Yield (filename, letter, encoding, lang_name) for each translatable file."""
    for filename in sorted(LANGUAGE_FILE_MAP):
        if filename not in lang_map:
            print('  Note: %s is in LANGUAGE_FILE_MAP but not in language.tcl; skipping'
                  % filename)
            continue
        letter, encoding = lang_map[filename]
        yield filename, letter, encoding, LANG_NAMES.get(filename, filename)


# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------
async def process_all(entries, lang_map, help_dir, lang_tcl_path,
                      dry_run, force, only_file):
    translator = Translator()
    done = 0
    for filename, letter, encoding, lang_name in resolve_targets(lang_map):
        if only_file and filename != only_file:
            continue
        ok = await process_language(
            translator, filename, letter, encoding, lang_name,
            entries, help_dir, lang_tcl_path, dry_run, force,
        )
        if ok:
            done += 1
        # Small pause between languages to be gentle on the free API.
        if not only_file:
            await asyncio.sleep(1)

    print('\n' + '=' * 60)
    print('Done. Language files written: %d' % done)
    print('=' * 60)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description='Generate translated help-page scaffolds for scidCommunity language files.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        'filename', nargs='?',
        help='Single language file to process (e.g. deutsch.tcl)',
    )
    parser.add_argument(
        '--all', action='store_true',
        help='Process every translatable language file',
    )
    parser.add_argument(
        '--dry-run', action='store_true',
        help='Write helpX.tcl.new preview files instead of editing in place',
    )
    parser.add_argument(
        '--force', action='store_true',
        help='Overwrite existing help files',
    )
    parser.add_argument(
        '--list', action='store_true',
        help='Print the resolved file/letter/gtcode mapping and exit',
    )
    args = parser.parse_args()

    sdir          = script_dir()
    help_dir      = os.path.normpath(os.path.join(sdir, '..', 'help'))
    lang_tcl_path = os.path.normpath(os.path.join(sdir, '..', 'language.tcl'))
    help_path     = os.path.join(help_dir, 'help.tcl')

    lang_map = parse_language_tcl(lang_tcl_path)

    if args.list:
        print('%-15s  %-6s  %-8s  %-10s  %s'
              % ('filename', 'letter', 'gtcode', 'encoding', 'lang_name'))
        print('-' * 65)
        for filename, letter, encoding, lang_name in resolve_targets(lang_map):
            print('%-15s  %-6s  %-8s  %-10s  %s'
                  % (filename, letter, LANGUAGE_FILE_MAP[filename], encoding, lang_name))
        return

    if not args.all and not args.filename:
        parser.error('Specify a filename or use --all')

    only_file = None
    if args.filename:
        only_file = os.path.basename(args.filename)
        if only_file not in LANGUAGE_FILE_MAP:
            parser.error('%s is not a translatable language file' % only_file)

    print('Parsing %s ...' % help_path)
    entries = extract_help_entries(help_path)
    print('Found %d help topics.' % len(entries))
    if args.dry_run:
        print('DRY-RUN mode: previews will be written as helpX.tcl.new')
    print()

    asyncio.run(
        process_all(entries, lang_map, help_dir, lang_tcl_path,
                    args.dry_run, args.force, only_file)
    )


if __name__ == '__main__':
    main()
