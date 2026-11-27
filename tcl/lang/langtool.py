#!/usr/bin/env python3
"""langtool.py -- a CSV workbench for the interface catalogues.

A native speaker should not have to read a 2,500-line Tcl file, learn Tcl
syntax, or replace the whole file to contribute. This tool exports one
catalogue next to English as a CSV, and imports a returned CSV by
``(command, key)``: only the rows whose ``new`` cell changed are written, in
the existing order, after validating the Tcl and the format placeholders.

  python3 tcl/lang/langtool.py generate francais
  python3 tcl/lang/langtool.py import francais translations-francais-*.csv --dry-run
  python3 tcl/lang/langtool.py import francais translations-francais-*.csv --apply

The generated CSV has one row per English entry and all sections, so the
reviewer can filter by section and work on whatever they want. A row with an
empty ``new`` cell is a no-op. A row with ``reviewed=Y`` records that the
existing translation was checked, even when the text did not change.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import re
import stat
import sys
import tempfile
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Iterable, Optional

COMMANDS = ("menuText", "translate", "helpMsg")

# Tcl format specifiers, with the space flag deliberately left out: "% games"
# and "% de victoire" are prose with a literal percent sign, not "%g"/"%d".
PLACEHOLDER_RE = re.compile(
    r"%(?:%|(?:\d+\$)?[-+0#]*(?:\d+|\*)?(?:\.\d+)?(?:hh|h|ll|l|L)?"
    r"[bcdiouxXeEfFgGs])"
)
HTML_TAG_RE = re.compile(r"<[^>]+>")
ENTRY_RE = re.compile(r"^(menuText|translate|helpMsg)\b")
PROC_RE = re.compile(r"^[ \t]*proc\s+setLanguage_(\S+)\s*\{\}\s*\{", re.MULTILINE)
CSV_COLUMNS = [
    "section", "command", "key",
    "english", "english_tooltip",
    "current", "current_tooltip",
    "new", "new_tooltip",
    "underline", "reviewed", "reviewer", "notes",
    "flags", "source_line", "english_hash",
]
TRUTHY = {"y", "yes", "true", "1", "x"}
FALSY = {"n", "no", "false", "0"}


class LangError(ValueError):
    pass


@dataclass
class Word:
    start: int
    end: int
    value: str
    raw: str


@dataclass
class Entry:
    command: str
    code: str
    key: str
    label: Optional[Word] = None       # menuText label
    value: Optional[Word] = None       # translate / helpMsg text
    tooltip: Optional[Word] = None     # menuText tooltip
    underline_word: Optional[Word] = None
    underline: Optional[int] = None
    start: int = 0
    end: int = 0
    section: str = "(top)"
    source_line: int = 0

    @property
    def ident(self) -> str:
        return f"{self.command}:{self.key}"

    def english_text(self) -> str:
        """The string a translator sees, in runtime form."""
        if self.command == "menuText":
            return self.label.value if self.label else ""
        return runtime_text(self.value.value if self.value else "", self.command)

    def english_tooltip(self) -> str:
        return self.tooltip.value if self.tooltip else ""

    def current_text(self) -> str:
        return self.english_text()

    def current_tooltip(self) -> str:
        return self.english_tooltip()


# --------------------------------------------------------------------------
# Tcl words
# --------------------------------------------------------------------------

def _decode_backslash(text: str, i: int, out: list[str]) -> int:
    """Decode one Tcl backslash escape at text[i]; return the next index."""
    n = len(text)
    if i + 1 >= n:
        out.append("\\")
        return i + 1
    c = text[i + 1]
    if c == "\n":
        out.append(" ")
        return i + 2
    if c == "\r" and i + 2 < n and text[i + 2] == "\n":
        out.append(" ")
        return i + 3
    simple = {"n": "\n", "t": "\t", "r": "\r", "\\": "\\", '"': '"',
              "$": "$", "[": "[", "]": "]", "{": "{", "}": "}", ";": ";",
              " ": " "}
    if c in simple:
        out.append(simple[c])
        return i + 2
    if c == "x" and i + 3 < n:
        try:
            out.append(chr(int(text[i + 2:i + 4], 16)))
            return i + 4
        except ValueError:
            pass
    if c == "u" and i + 5 < n:
        try:
            out.append(chr(int(text[i + 2:i + 6], 16)))
            return i + 6
        except ValueError:
            pass
    # Tcl drops the backslash for an unrecognised escape.
    out.append(c)
    return i + 2


def parse_word(text: str, i: int) -> Optional[Word]:
    """Read one Tcl word starting at or after i. None at end of command."""
    n = len(text)
    while i < n:
        c = text[i]
        if c in " \t":
            i += 1
        elif c == "\\" and i + 1 < n and text[i + 1] == "\n":
            i += 2
        elif c == "\\" and i + 2 < n and text[i + 1] == "\r" and text[i + 2] == "\n":
            i += 3
        else:
            break
    if i >= n or text[i] in "\n;":
        return None

    start = i
    if text[i] == "{":
        i += 1
        depth = 1
        out: list[str] = []
        while i < n:
            c = text[i]
            if c == "\\" and i + 1 < n:
                if text[i + 1] == "\n":
                    out.append(" ")
                    i += 2
                    continue
                if text[i + 1] == "\r" and i + 2 < n and text[i + 2] == "\n":
                    out.append(" ")
                    i += 3
                    continue
                # Keep the backslash and the escaped character, but do not let
                # an escaped brace affect the nesting count.
                out.append(c)
                out.append(text[i + 1])
                i += 2
                continue
            if c == "{":
                depth += 1
                out.append(c)
                i += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    i += 1
                    return Word(start, i, "".join(out), text[start:i])
                out.append(c)
                i += 1
            else:
                out.append(c)
                i += 1
        raise LangError(f"unclosed braced word at offset {start}")

    if text[i] == '"':
        i += 1
        out = []
        while i < n:
            c = text[i]
            if c == "\\":
                i = _decode_backslash(text, i, out)
            elif c == '"':
                i += 1
                return Word(start, i, "".join(out), text[start:i])
            else:
                out.append(c)
                i += 1
        raise LangError(f"unclosed quoted word at offset {start}")

    # Bare word.
    j = i
    while j < n and text[j] not in " \t\n;":
        if text[j] == "\\" and j + 1 < n:
            if text[j + 1] == "\n":
                break
            if text[j + 1] == "\r" and j + 2 < n and text[j + 2] == "\n":
                break
            j += 2
        else:
            j += 1
    return Word(i, j, text[i:j], text[i:j])


def parse_command(text: str, start: int) -> tuple[list[Word], int]:
    words: list[Word] = []
    i = start
    while True:
        word = parse_word(text, i)
        if word is None:
            break
        words.append(word)
        i = word.end
    # Consume trailing spaces, an optional semicolon, and one newline.
    while i < len(text) and text[i] in " \t":
        i += 1
    if i < len(text) and text[i] == ";":
        i += 1
        # A trailing ";# ..." comment belongs to this line, not to the next
        # entry's section block.
        while i < len(text) and text[i] in " \t":
            i += 1
        if i < len(text) and text[i] == "#":
            end = text.find("\n", i)
            i = len(text) if end < 0 else end
    if i < len(text) and text[i] == "\n":
        i += 1
    return words, i


def runtime_text(text: str, command: str) -> str:
    """What the proc stores: translate() turns \\n into a real newline."""
    if command == "translate":
        return text.replace("\\n", "\n")
    return text


# --------------------------------------------------------------------------
# Catalogue parsing
# --------------------------------------------------------------------------

NOTE_PREFIXES = ("note:", "designed by", "keep ", "the ", "copyright",
                 "machine-translated", "=====", "-----")


def _is_note(title: str) -> bool:
    low = title.lower().strip()
    if not low or all(ch in "=-#* " for ch in low):
        return True
    return low.startswith(NOTE_PREFIXES)


def parse_catalogue(path: Path, warnings: Optional[list[str]] = None) -> tuple[str, list[Entry]]:
    if warnings is None:
        warnings = []
    text = path.read_text(encoding="utf-8-sig")
    entries: list[Entry] = []
    section = "(top)"
    comment_block: list[str] = []
    proc_match = PROC_RE.search(text)
    expected_code = proc_match.group(1) if proc_match else None
    if proc_match:
        nl = text.find("\n", proc_match.end())
        i = len(text) if nl < 0 else nl + 1
        line = text.count("\n", 0, i) + 1
    else:
        i = 0
        line = 1
    n = len(text)

    while i < n:
        line_start = i
        j = i
        while j < n and text[j] in " \t":
            j += 1
        if j >= n:
            break
        if text[j] == "}":
            # The proc body ends at a closing brace at the start of a line.
            rest = text[j:].split("\n", 1)[0].strip()
            if rest == "}":
                break
        if text[j] == "\n":
            comment_block = []
            i = j + 1
            line += 1
            continue
        if text[j] == "#":
            end = text.find("\n", j)
            if end < 0:
                end = n
            content = text[j + 1:end].strip()
            if content:
                comment_block.append(content)
            i = end + 1
            line += 1
            continue

        match = ENTRY_RE.match(text[j:])
        if not match:
            # proc opening, closing brace, prose; skip the line
            end = text.find("\n", j)
            if end < 0:
                break
            comment_block = []
            i = end + 1
            line += 1
            continue

        words, end = parse_command(text, j)
        command = words[0].value
        title = comment_block[0] if comment_block else ""
        if title and not _is_note(title):
            section = title.strip(" -=")
        comment_block = []

        if expected_code and words[1].value != expected_code:
            warnings.append(
                f"{path}:{line}: skipped {command} {words[2].value}: "
                f"language code {words[1].value!r} does not match "
                f"setLanguage_{expected_code}")
            line += text.count("\n", line_start, end)
            i = end
            continue

        if command == "menuText":
            if len(words) not in (5, 6):
                raise LangError(
                    f"{path}:{line}: menuText {words[2].value} has "
                    f"{len(words)} words, expected 5 or 6")
            if len(words[1].value) != 1:
                warnings.append(
                    f"{path}:{line}: skipped menuText {words[2].value}: "
                    f"language code {words[1].value!r} is not one letter")
                line += text.count("\n", line_start, end)
                i = end
                continue
            try:
                underline = int(words[4].value)
            except ValueError as exc:
                raise LangError(
                    f"{path}:{line}: underline {words[4].value!r} is not an int") from exc
            entry = Entry(
                command=command, code=words[1].value, key=words[2].value,
                label=words[3], underline_word=words[4], underline=underline,
                tooltip=words[5] if len(words) == 6 else None,
            )
        elif command in ("translate", "helpMsg"):
            if len(words) != 4:
                raise LangError(
                    f"{path}:{line}: {command} {words[2].value} has "
                    f"{len(words)} words, expected 4")
            if len(words[1].value) != 1:
                warnings.append(
                    f"{path}:{line}: skipped {command} {words[2].value}: "
                    f"language code {words[1].value!r} is not one letter")
                line += text.count("\n", line_start, end)
                i = end
                continue
            entry = Entry(command=command, code=words[1].value,
                          key=words[2].value, value=words[3])
        else:
            raise LangError(f"{path}:{line}: unexpected command {command}")

        entry.start = words[0].start
        entry.end = words[-1].end
        entry.section = section
        entry.source_line = line
        entries.append(entry)

        line += text.count("\n", line_start, end)
        i = end

    return text, entries


def load_catalogue(path: Path, warnings: Optional[list[str]] = None) -> list[Entry]:
    _, entries = parse_catalogue(path, warnings)
    return entries


def code_of(entries: Iterable[Entry]) -> str:
    for entry in entries:
        return entry.code
    raise LangError("catalogue has no entries")


# --------------------------------------------------------------------------
# Values, hashes, review state
# --------------------------------------------------------------------------

def sha1(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()


def norm(value: str) -> str:
    return value.replace("\r\n", "\n").replace("\r", "\n")


def entry_hash(command: str, key: str, text: str, tooltip: str = "") -> str:
    return sha1(json.dumps([command, key, norm(text), norm(tooltip)],
                           ensure_ascii=False))


def review_path(root: Path, stem: str) -> Path:
    return root / "tcl" / "lang" / "reviews" / f"{stem}.json"


def load_reviews(root: Path, stem: str) -> dict:
    path = review_path(root, stem)
    if not path.exists():
        return {"version": 1, "entries": {}}
    data = json.loads(path.read_text(encoding="utf-8"))
    data.setdefault("version", 1)
    data.setdefault("entries", {})
    return data


def save_reviews(root: Path, stem: str, data: dict) -> None:
    path = review_path(root, stem)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                   encoding="utf-8")
    os.replace(tmp, path)


def review_ok(reviews: dict, entry: Entry, translation: str, tooltip: str) -> bool:
    state = reviews["entries"].get(entry.ident)
    if not state:
        return False
    return (state.get("english") == entry_hash(entry.command, entry.key,
                                               entry.english_text(),
                                               entry.english_tooltip())
            and state.get("translation") == entry_hash(entry.command, entry.key,
                                                       translation, tooltip))


# --------------------------------------------------------------------------
# CSV generation
# --------------------------------------------------------------------------

def _stem(stem: str) -> str:
    stem = Path(stem).name
    if stem.endswith(".tcl"):
        stem = stem[:-4]
    if stem == "english":
        raise LangError("english.tcl is the source of the keys, not a translation")
    return stem


def _tooltip(entry: Entry) -> str:
    return entry.english_tooltip()


def entry_flags(entry: Entry, current: Optional[Entry]) -> str:
    flags = []
    if current is None:
        flags.append("missing")
    else:
        if entry.english_text() == current.current_text() and \
                entry.english_tooltip() == current.current_tooltip():
            flags.append("identical")
    if entry.command == "menuText" and entry.underline is not None:
        label = entry.label.value if entry.label else ""
        if not (0 <= entry.underline < len(label)) or label[entry.underline].isspace():
            flags.append("bad-underline")
    return " ".join(flags)


def generate(root: Path, stem: str, out: Path) -> None:
    stem = _stem(stem)
    english_path = root / "tcl" / "lang" / "english.tcl"
    target_path = root / "tcl" / "lang" / f"{stem}.tcl"
    if not target_path.exists():
        raise LangError(f"no such catalogue: {target_path}")
    warnings: list[str] = []
    english = load_catalogue(english_path, warnings)
    current = load_catalogue(target_path, warnings)
    for warning in warnings:
        print("warning: " + warning, file=sys.stderr)
    current_by_id = {e.ident: e for e in current}
    reviews = load_reviews(root, stem)

    rows = []
    seen = set()
    for entry in english:
        target = current_by_id.get(entry.ident)
        seen.add(entry.ident)
        reviewed = ""
        if target is not None and review_ok(reviews, entry,
                                           target.current_text(),
                                           target.current_tooltip()):
            reviewed = "Y"
        rows.append({
            "section": entry.section,
            "command": entry.command,
            "key": entry.key,
            "english": entry.english_text(),
            "english_tooltip": _tooltip(entry),
            "current": target.current_text() if target else "",
            "current_tooltip": target.current_tooltip() if target else "",
            "new": "",
            "new_tooltip": "",
            "underline": (target.underline
                          if target is not None and target.underline is not None
                          else entry.underline if entry.underline is not None else ""),
            "reviewed": reviewed,
            "reviewer": reviews["entries"].get(entry.ident, {}).get("reviewer", ""),
            "notes": "",
            "flags": entry_flags(entry, target),
            "source_line": entry.source_line,
            "english_hash": entry_hash(entry.command, entry.key,
                                       entry.english_text(),
                                       entry.english_tooltip()),
        })

    # A catalogue may carry keys English no longer has. Include them so the
    # reviewer can see the drift, but never import them.
    for target in current:
        if target.ident in seen:
            continue
        rows.append({
            "section": "(not in English)",
            "command": target.command,
            "key": target.key,
            "english": "",
            "english_tooltip": "",
            "current": target.current_text(),
            "current_tooltip": target.current_tooltip(),
            "new": "",
            "new_tooltip": "",
            "underline": target.underline if target.underline is not None else "",
            "reviewed": "N",
            "reviewer": "",
            "notes": "",
            "flags": "unknown",
            "source_line": "",
            "english_hash": "",
        })

    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8-sig", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=CSV_COLUMNS, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)

    missing = sum(1 for r in rows if "missing" in r["flags"])
    identical = sum(1 for r in rows if "identical" in r["flags"])
    unknown = sum(1 for r in rows if r["flags"] == "unknown")
    reviewed = sum(1 for r in rows if r["reviewed"] == "Y")
    print(f"{stem}: {len(rows)} rows, {missing} missing, {identical} identical, "
          f"{unknown} not in English, {reviewed} reviewed")
    print(f"wrote {out}")


# --------------------------------------------------------------------------
# Serialisation and replacement
# --------------------------------------------------------------------------

def quote_word(text: str, preserve: Iterable[str] = ()) -> str:
    """Quote a Tcl word, escaping substitutions except named ones."""
    tokens: dict[str, str] = {}
    for index, token in enumerate(sorted(set(preserve), key=len, reverse=True)):
        if token and token in text:
            key = f"\ue000{index}\ue001"
            text = text.replace(token, key)
            tokens[key] = token
    out = ['"']
    for ch in text:
        if ch == "\\":
            out.append("\\\\")
        elif ch == '"':
            out.append('\\"')
        elif ch == "$":
            out.append("\\$")
        elif ch == "[":
            out.append("\\[")
        elif ch == "]":
            out.append("\\]")
        elif ch == "\n":
            out.append("\\n")
        elif ch == "\r":
            out.append("\\r")
        elif ch == "\t":
            out.append("\\t")
        elif ch in "{};":
            out.append("\\" + ch)
        else:
            out.append(ch)
    out.append('"')
    quoted = "".join(out)
    for key, token in tokens.items():
        quoted = quoted.replace(key, token)
    return quoted

def brace_word(text: str, command: str) -> str:
    """Serialise a translate/helpMsg value.

    translate() converts the two characters \\n to a newline, so newlines are
    written as escapes and the entry stays one line. helpMsg() does not, so a
    help message is serialised with a real newline inside braces.
    """
    text = norm(text)
    if command == "translate":
        text = text.replace("\n", "\\n")
    if "{" in text or "}" in text or text.endswith("\\"):
        if command == "translate":
            return quote_word(text.replace("\\n", "\n"))
        return quote_word(text)
    return "{" + text + "}"


def menu_label(text: str) -> str:
    if "\n" in text or "\r" in text:
        raise LangError("a menu label cannot contain a newline")
    return quote_word(text)


def menu_tooltip(text: str, preserve: Iterable[str] = ()) -> str:
    text = norm(text)
    if preserve or "{" in text or "}" in text or text.endswith("\\"):
        return quote_word(text, preserve)
    return "{" + text + "}"


def choose_underline(label: str, old_label: str, old_underline: Optional[int]) -> int:
    if not label:
        return 0
    if old_underline is not None and 0 <= old_underline < len(old_label):
        wanted = old_label[old_underline]
        if wanted.isalpha():
            found = label.find(wanted)
            if found >= 0:
                return found
    for index, ch in enumerate(label):
        if ch.isalpha():
            return index
    return 0


def apply_edits(text: str, edits: list[tuple[int, int, str]]) -> str:
    for start, end, replacement in sorted(edits, key=lambda e: e[0], reverse=True):
        text = text[:start] + replacement + text[end:]
    return text


# --------------------------------------------------------------------------
# Validation
# --------------------------------------------------------------------------

DOLLAR_RE = re.compile(r'\$(?:::[A-Za-z_][A-Za-z0-9_]*|[A-Za-z_][A-Za-z0-9_]*)')


def specs(text: str) -> list[str]:
    return PLACEHOLDER_RE.findall(text)


def subst_tokens(text: str) -> set[str]:
    return set(DOLLAR_RE.findall(text))


def dollar_markers(text: str) -> set[str]:
    return subst_tokens(text)


def check_value(entry: Entry, new_text: str, new_tooltip: str) -> list[str]:
    errors: list[str] = []
    if not new_text.strip():
        errors.append("empty translation")
    english = entry.english_text()
    if entry.command == "translate":
        if specs(english) and specs(english) != specs(new_text):
            errors.append(
                f"placeholders differ: English {specs(english)!r}, "
                f"new {specs(new_text)!r}")
        if specs(english):
            leftover = PLACEHOLDER_RE.sub("", new_text)
            if "%" in leftover:
                errors.append("stray % in a format string")
        missing_markers = dollar_markers(english) - dollar_markers(new_text)
        if missing_markers:
            errors.append("missing substitution(s): " + ", ".join(sorted(missing_markers)))
    if entry.command == "menuText":
        if "\n" in new_text or "\r" in new_text:
            errors.append("menu label contains a newline")
        if not any(ch.isalpha() for ch in new_text):
            errors.append("menu label has no letter for an underline")
        if specs(english) and specs(english) != specs(new_text):
            errors.append(
                f"label placeholders differ: English {specs(english)!r}, "
                f"new {specs(new_text)!r}")
        eng_tags = HTML_TAG_RE.findall(entry.english_tooltip())
        new_tags = HTML_TAG_RE.findall(new_tooltip)
        if eng_tags and sorted(eng_tags) != sorted(new_tags):
            errors.append(
                f"tooltip HTML tags differ: English {eng_tags!r}, new {new_tags!r}")
        missing_markers = (dollar_markers(entry.english_tooltip()) -
                           dollar_markers(new_tooltip))
        if missing_markers:
            errors.append("tooltip is missing substitution(s): " +
                          ", ".join(sorted(missing_markers)))
    else:
        eng_tags = HTML_TAG_RE.findall(english)
        new_tags = HTML_TAG_RE.findall(new_text)
        if eng_tags and sorted(eng_tags) != sorted(new_tags):
            errors.append(
                f"HTML tags differ: English {eng_tags!r}, new {new_tags!r}")
    if "\x00" in new_text or "\x00" in new_tooltip:
        errors.append("value contains NUL")
    return errors


# --------------------------------------------------------------------------
# CSV import
# --------------------------------------------------------------------------

def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as fh:
        first = fh.readline()
        fh.seek(0)
        # Sniff only the delimiter from the header. csv.Sniffer on a whole
        # sample can mistake text inside a quoted multiline value for the
        # delimiter or quote character.
        delimiter = max(",;\t", key=first.count)
        reader = csv.DictReader(fh, delimiter=delimiter)
        if reader.fieldnames is None:
            raise LangError(f"{path}: no header row")
        required = {"command", "key", "new"}
        missing = sorted(required - set(reader.fieldnames))
        if missing:
            raise LangError(f"{path}: missing column(s): {', '.join(missing)}")
        return [dict(row) for row in reader]


def row_bool(value: Optional[str]) -> Optional[bool]:
    if value is None:
        return None
    value = value.strip().lower()
    if value == "":
        return None
    if value in TRUTHY:
        return True
    if value in FALSY:
        return False
    raise LangError(f"reviewed value {value!r} is not Y/N")


def insert_text(entry: Entry, code: str, new_text: str, new_tooltip: str,
                underline: int) -> str:
    if entry.command == "menuText":
        return (f'menuText {code} {entry.key} {menu_label(new_text)} '
                f'{underline} {menu_tooltip(new_tooltip, subst_tokens(entry.english_tooltip()))}')
    return f"{entry.command} {code} {entry.key} {brace_word(new_text, entry.command)}"


def find_insert_offset(text: str, english: list[Entry], target_by_id: dict[str, Entry],
                       missing: Entry) -> int:
    idx = next(i for i, e in enumerate(english) if e.ident == missing.ident)
    for prev in reversed(english[:idx]):
        hit = target_by_id.get(prev.ident)
        if hit is not None:
            nl = text.find("\n", hit.end)
            return len(text) if nl < 0 else nl + 1
    if target_by_id:
        first = min(target_by_id.values(), key=lambda entry: entry.start)
        return text.rfind("\n", 0, first.start) + 1
    match = PROC_RE.search(text)
    if match:
        nl = text.find("\n", match.end())
        return len(text) if nl < 0 else nl + 1
    return len(text)


def import_csv(root: Path, stem: str, csv_path: Path, *, apply: bool,
               force: bool, reviewer: str) -> int:
    stem = _stem(stem)
    english_path = root / "tcl" / "lang" / "english.tcl"
    target_path = root / "tcl" / "lang" / f"{stem}.tcl"
    warnings: list[str] = []
    text, target_entries = parse_catalogue(target_path, warnings)
    english = load_catalogue(english_path, warnings)
    for warning in warnings:
        print("warning: " + warning, file=sys.stderr)
    english_by_id = {e.ident: e for e in english}
    english_order = {e.ident: i for i, e in enumerate(english)}
    target_by_id = {e.ident: e for e in target_entries}
    before_ids = [e.ident for e in target_entries]
    inserted_ids: set[str] = set()
    target_code = code_of(target_entries)
    reviews = load_reviews(root, stem)
    rows = read_rows(csv_path)

    edits: list[tuple[int, int, str]] = []
    inserts: dict[int, list[tuple[int, str]]] = {}
    errors: list[str] = []
    warnings: list[str] = []
    changed = reviewed_count = skipped = 0
    today = date.today().isoformat()
    review_updates: dict[str, Optional[dict]] = {}
    seen_rows: set[str] = set()

    for row in rows:
        command = (row.get("command") or "").strip()
        key = (row.get("key") or "").strip()
        if not command or not key:
            continue
        if command not in COMMANDS:
            errors.append(f"{command}:{key}: unknown command; ignored")
            continue
        ident = f"{command}:{key}"
        if ident in seen_rows:
            errors.append(f"{ident}: appears more than once in the CSV")
            continue
        seen_rows.add(ident)
        english_entry = english_by_id.get(ident)
        target_entry = target_by_id.get(ident)
        if english_entry is None:
            warnings.append(f"{ident}: not in english.tcl; ignored")
            continue

        new_text = row.get("new") or ""
        new_tooltip = row.get("new_tooltip") or ""
        has_new = new_text != ""
        has_tooltip = new_tooltip != "" and command == "menuText"
        if not has_new and not has_tooltip and not (row.get("reviewed") or "").strip():
            continue

        if target_entry is None:
            if not has_new and not has_tooltip:
                continue
            expected = row.get("english_hash") or ""
            actual = entry_hash(command, key, english_entry.english_text(),
                                english_entry.english_tooltip())
            if not force:
                if not expected:
                    errors.append(
                        f"{ident}: no english_hash column value; keep the "
                        f"generated sheet's hash or use --force")
                    skipped += 1
                    continue
                if expected != actual:
                    errors.append(
                        f"{ident}: English changed since the CSV was generated; "
                        f"not applied (use --force to override)")
                    skipped += 1
                    continue
            # A key English has but the catalogue lacks: insert it, in the
            # English order, using the supplied translation (or English).
            if new_text == "":
                new_text = english_entry.english_text()
            if command == "menuText" and new_tooltip == "":
                new_tooltip = english_entry.english_tooltip()
            problems = check_value(english_entry, new_text, new_tooltip)
            if problems:
                errors.extend(f"{ident}: {p}" for p in problems)
                skipped += 1
                continue
            underline = choose_underline(new_text,
                                         english_entry.label.value if english_entry.label else "",
                                         english_entry.underline)
            text_to_insert = insert_text(english_entry, target_code, new_text,
                                         new_tooltip, underline)
            offset = find_insert_offset(text, english, target_by_id, english_entry)
            inserts.setdefault(offset, []).append(
                (english_order[english_entry.ident], text_to_insert))
            inserted_ids.add(ident)
            changed += 1
            reviewed_flag = row_bool(row.get("reviewed"))
            if reviewed_flag:
                review_updates[ident] = {
                    "english": entry_hash(command, key,
                                          english_entry.english_text(),
                                          english_entry.english_tooltip()),
                    "translation": entry_hash(command, key, new_text,
                                              new_tooltip),
                    "reviewer": (row.get("reviewer") or reviewer).strip(),
                    "date": today,
                }
            continue

        current_text = target_entry.current_text()
        current_tooltip = target_entry.current_tooltip()
        # Spreadsheets (Excel, LibreOffice) drop a cell's trailing newlines,
        # so a returned sheet loses them in `current` and `new` alike. They
        # are layout, not wording: give the catalogue's back.
        tail = current_text[len(current_text.rstrip("\n")):]
        if tail:
            if has_new and not new_text.endswith("\n"):
                new_text += tail
            if (row.get("current") or "") == current_text.rstrip("\n"):
                row["current"] = current_text
        text_changed =(has_new and new_text != current_text) or \
                       (has_tooltip and new_tooltip != current_tooltip)

        if text_changed:
            expected = row.get("english_hash") or ""
            actual = entry_hash(command, key, english_entry.english_text(),
                                english_entry.english_tooltip())
            if not force:
                if not expected:
                    errors.append(
                        f"{ident}: no english_hash column value; keep the "
                        f"generated sheet's hash or use --force")
                    skipped += 1
                    continue
                if expected != actual:
                    errors.append(
                        f"{ident}: English changed since the CSV was generated; "
                        f"not applied (use --force to override)")
                    skipped += 1
                    continue
            current_cell = row.get("current") or ""
            if not force:
                if not current_cell:
                    where = ("the key was added to the catalogue"
                             if "missing" in (row.get("flags") or "").split()
                             else "the current translation cell is empty")
                    errors.append(
                        f"{ident}: {where} since the CSV was generated; "
                        f"re-generate or use --force")
                    skipped += 1
                    continue
                if current_cell != current_text:
                    errors.append(
                        f"{ident}: the current translation changed since the "
                        f"CSV was generated; re-generate or use --force")
                    skipped += 1
                    continue
                tooltip_cell = row.get("current_tooltip") or ""
                if target_entry.tooltip is not None and not tooltip_cell:
                    errors.append(
                        f"{ident}: the current tooltip cell is empty; "
                        f"re-generate or use --force")
                    skipped += 1
                    continue
                if tooltip_cell and tooltip_cell != current_tooltip:
                    errors.append(
                        f"{ident}: the current tooltip changed since the CSV "
                        f"was generated; re-generate or use --force")
                    skipped += 1
                    continue
            problems = check_value(
                english_entry,
                new_text if has_new else current_text,
                new_tooltip if has_tooltip else current_tooltip)
            if problems:
                errors.extend(f"{ident}: {p}" for p in problems)
                skipped += 1
                continue

            if command == "menuText":
                label = new_text if has_new else current_text
                tooltip = new_tooltip if has_tooltip else current_tooltip
                if label != current_text:
                    edits.append((target_entry.label.start, target_entry.label.end,
                                  menu_label(label)))
                    underline = choose_underline(
                        label, current_text, target_entry.underline)
                    if target_entry.underline_word and underline != target_entry.underline:
                        edits.append((target_entry.underline_word.start,
                                      target_entry.underline_word.end,
                                      str(underline)))
                if has_tooltip and tooltip != current_tooltip:
                    if target_entry.tooltip is not None:
                        preserve = (subst_tokens(current_tooltip) |
                                    subst_tokens(english_entry.english_tooltip()))
                        edits.append((target_entry.tooltip.start,
                                      target_entry.tooltip.end,
                                      menu_tooltip(tooltip, preserve)))
                    elif target_entry.underline_word is not None:
                        insert_at = target_entry.underline_word.end
                        edits.append((insert_at, insert_at,
                                      " " + menu_tooltip(tooltip)))
            else:
                value = new_text if has_new else current_text
                edits.append((target_entry.value.start, target_entry.value.end,
                              brace_word(value, command)))
            changed += 1

        reviewed_flag = row_bool(row.get("reviewed"))
        if reviewed_flag is True and not text_changed:
            # A review-only row must describe the translation that is in the
            # file now. The exception is a retry after a catalogue write that
            # succeeded before the review sidecar: the submitted `new` already
            # equals the file, so the review can still be recorded.
            already_applied = (has_new or has_tooltip) and \
                (not has_new or new_text == current_text) and \
                (not has_tooltip or new_tooltip == current_tooltip)
            expected = row.get("english_hash") or ""
            actual = entry_hash(command, key, english_entry.english_text(),
                                english_entry.english_tooltip())
            if not force and not expected:
                errors.append(
                    f"{ident}: no english_hash column value; keep the generated "
                    f"sheet's hash or use --force")
                skipped += 1
                continue
            if not force and expected != actual:
                errors.append(
                    f"{ident}: English changed since the CSV was generated; "
                    f"review not recorded (use --force to override)")
                skipped += 1
                continue
            if not force and not already_applied and (
                    (row.get("current") or "") != current_text or
                    (row.get("current_tooltip") or "") != current_tooltip):
                errors.append(
                    f"{ident}: the current translation changed since the CSV "
                    f"was generated; review not recorded")
                skipped += 1
                continue
        if reviewed_flag is True:
            text_now = new_text if text_changed and has_new else current_text
            tooltip_now = (new_tooltip if text_changed and has_tooltip
                           else current_tooltip)
            english_hash = entry_hash(command, key,
                                      english_entry.english_text(),
                                      english_entry.english_tooltip())
            translation_hash = entry_hash(command, key, text_now, tooltip_now)
            who = (row.get("reviewer") or reviewer).strip()
            old = reviews["entries"].get(ident)
            if not (old and old.get("english") == english_hash and
                    old.get("translation") == translation_hash and
                    old.get("reviewer") == who):
                review_updates[ident] = {
                    "english": english_hash,
                    "translation": translation_hash,
                    "reviewer": who,
                    "date": today,
                }
                reviewed_count += 1
        elif reviewed_flag is False and ident in reviews["entries"]:
            review_updates[ident] = None

    # Build the candidate once, so a dry run validates exactly what an apply
    # would write. Replacements and insertions share one coordinate space.
    operations = list(edits)
    for offset, block in inserts.items():
        ordered = [entry for _, entry in sorted(block)]
        operations.append((offset, offset, "\n".join(ordered) + "\n"))
    candidate = apply_edits(text, operations) if operations else text
    if operations:
        try:
            validate_candidate(candidate, target_path, before_ids, inserted_ids)
        except LangError as exc:
            errors.append(str(exc))

    if errors:
        print("\nErrors (rows not applied):")
        for error in errors:
            print("  " + error)
    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print("  " + warning)

    if not apply:
        print(f"\nDry run: {changed} changed, {reviewed_count} marked reviewed, "
              f"{skipped} skipped, {len(errors)} error(s).")
        if edits:
            print("\nFirst changed entries:")
            for entry in _preview_edits(edits, text)[:20]:
                print("  " + entry)
        if inserts:
            print("\nEntries to insert:")
            for offset in sorted(inserts):
                for _, entry in sorted(inserts[offset]):
                    print("  " + entry.splitlines()[0])
        return 1 if errors else 0

    if errors:
        print("\nRefusing to write while rows have errors; fix them, or re-run "
              "with --force only after checking the stale basis.")
        return 2

    if not operations:
        if review_updates:
            apply_reviews(reviews, review_updates)
            save_reviews(root, stem, reviews)
            print(f"\nNo text changes; {reviewed_count} review state(s) updated.")
            print(f"wrote {review_path(root, stem)}")
        else:
            print("\nNo changes.")
        return 0

    # Save the review state before the catalogue, so a failure leaves the text
    # unchanged and a retry can still record the review. If the catalogue write
    # then fails, the hashes do not match and generate will mark the rows
    # unreviewed again.
    if review_updates:
        apply_reviews(reviews, review_updates)
        save_reviews(root, stem, reviews)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", delete=False,
                                     dir=str(target_path.parent)) as fh:
        tmp_name = fh.name
        fh.write(candidate)
    try:
        os.chmod(tmp_name, stat.S_IMODE(target_path.stat().st_mode))
        os.replace(tmp_name, target_path)
    except BaseException:
        if os.path.exists(tmp_name):
            os.unlink(tmp_name)
        raise

    print(f"\nApplied: {changed} changed, {reviewed_count} marked reviewed, "
          f"{skipped} skipped.")
    if review_updates:
        print(f"wrote {review_path(root, stem)}")
    print(f"wrote {target_path}")
    return 0


def apply_reviews(reviews: dict, updates: dict[str, Optional[dict]]) -> None:
    for ident, state in updates.items():
        if state is None:
            reviews["entries"].pop(ident, None)
        else:
            reviews["entries"][ident] = state


def validate_candidate(text: str, target_path: Path, before_ids: list[str],
                       inserted_ids: set[str]) -> None:
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", delete=False,
                                     dir=str(target_path.parent)) as fh:
        tmp_name = fh.name
        fh.write(text)
    try:
        _, after = parse_catalogue(Path(tmp_name))
    finally:
        if os.path.exists(tmp_name):
            os.unlink(tmp_name)
    ids = [e.ident for e in after]
    if len(ids) != len(set(ids)):
        raise LangError("the result would contain duplicate keys")
    before_set = set(before_ids)
    after_set = set(ids)
    lost = [ident for ident in before_ids if ident not in after_set]
    if lost:
        raise LangError("the result would lose keys: " + ", ".join(lost[:5]))
    kept = [ident for ident in ids if ident in before_set]
    if kept != before_ids:
        raise LangError("the result would reorder existing keys")
    missing_inserts = sorted(inserted_ids - after_set)
    if missing_inserts:
        raise LangError("the result would lose inserted keys: " +
                        ", ".join(missing_inserts[:5]))


def _preview_edits(edits: list[tuple[int, int, str]], text: str) -> list[str]:
    out = []
    for start, end, replacement in sorted(edits, key=lambda e: e[0]):
        line = text.count("\n", 0, start) + 1
        old = text[start:end]
        out.append(f"line {line}: {old!r} -> {replacement!r}")
    return out


# --------------------------------------------------------------------------
# Status
# --------------------------------------------------------------------------

def status(root: Path, stem: str) -> int:
    stem = _stem(stem)
    warnings: list[str] = []
    english = load_catalogue(root / "tcl" / "lang" / "english.tcl", warnings)
    target = load_catalogue(root / "tcl" / "lang" / f"{stem}.tcl", warnings)
    for warning in warnings:
        print("warning: " + warning, file=sys.stderr)
    target_by_id = {e.ident: e for e in target}
    reviews = load_reviews(root, stem)
    sections: dict[str, dict[str, int]] = {}
    for entry in english:
        sec = sections.setdefault(entry.section, {"entries": 0, "missing": 0,
                                                  "identical": 0, "reviewed": 0})
        sec["entries"] += 1
        hit = target_by_id.get(entry.ident)
        if hit is None:
            sec["missing"] += 1
        else:
            if entry.english_text() == hit.current_text() and \
                    entry.english_tooltip() == hit.current_tooltip():
                sec["identical"] += 1
            if review_ok(reviews, entry, hit.current_text(),
                         hit.current_tooltip()):
                sec["reviewed"] += 1

    total = {"entries": len(english),
             "missing": sum(s["missing"] for s in sections.values()),
             "identical": sum(s["identical"] for s in sections.values()),
             "reviewed": sum(s["reviewed"] for s in sections.values())}
    full = sum(1 for s in sections.values() if s["entries"] == s["reviewed"])
    print(f"{stem}: {total['entries']} entries, {total['missing']} missing, "
          f"{total['identical']} identical, {total['reviewed']} reviewed, "
          f"{full}/{len(sections)} sections complete")
    print()
    print(f"{'section':48} {'entries':>7} {'missing':>7} {'same':>5} {'reviewed':>8}")
    for name, sec in sections.items():
        print(f"{name[:48]:48} {sec['entries']:7d} {sec['missing']:7d} "
              f"{sec['identical']:5d} {sec['reviewed']:8d}")
    return 0


# --------------------------------------------------------------------------
# Self-test
# --------------------------------------------------------------------------

def selftest() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "tcl" / "lang").mkdir(parents=True)
        english = '''# File menu:
menuText E File "File" 0 {The game file}
menuText E TipNoTooltip "Tip" 0 {A tip}
translate E Greeting {Hello %s\\nWelcome}
translate E Quote {A "quote" and a [bracket] and $dollar}

# Other:
translate E Tip {One % de 100 and % games}
'''
        target = '''proc setLanguage_X {} {

# File menu:
menuText X File "Fichier" 2 {Le fichier}
menuText X TipNoTooltip "Astuce" 0
translate X Greeting {Bonjour %s\\nBienvenue}
translate X Quote {Un "guillemet" et un [crochet] et $dollar}

# Other:
translate X Tip {Un % de 100 et % parties}
}
'''
        (root / "tcl" / "lang" / "english.tcl").write_text(english, encoding="utf-8")
        (root / "tcl" / "lang" / "testlang.tcl").write_text(target, encoding="utf-8")
        out = root / "test.csv"
        generate(root, "testlang", out)
        rows = read_rows(out)
        by_id = {f"{r['command']}:{r['key']}": r for r in rows}
        assert by_id["translate:Greeting"]["current"] == "Bonjour %s\nBienvenue"
        assert by_id["menuText:File"]["current"] == "Fichier"
        assert by_id["menuText:File"]["underline"] == "2"
        # Change a translation, review another, leave one blank.
        by_id["translate:Greeting"]["new"] = "Salut %s\nBienvenue"
        by_id["translate:Greeting"]["reviewed"] = "Y"
        by_id["translate:Greeting"]["reviewer"] = "Tester"
        by_id["translate:Tip"]["reviewed"] = "Y"
        by_id["translate:Tip"]["reviewer"] = "Tester"
        with out.open("w", encoding="utf-8-sig", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=CSV_COLUMNS)
            writer.writeheader()
            writer.writerows(rows)
        rc = import_csv(root, "testlang", out, apply=True, force=False,
                        reviewer="Tester")
        assert rc == 0, rc
        text = (root / "tcl" / "lang" / "testlang.tcl").read_text(encoding="utf-8")
        assert "Salut %s\\nBienvenue" in text
        # A tooltip added to a 5-word menuText entry goes in through an edit,
        # not an entry block.
        by_id["menuText:TipNoTooltip"]["new_tooltip"] = "Un conseil"
        with out.open("w", encoding="utf-8-sig", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=CSV_COLUMNS)
            writer.writeheader()
            writer.writerows(rows)
        rc = import_csv(root, "testlang", out, apply=True, force=False,
                        reviewer="Tester")
        assert rc == 0, rc
        text = (root / "tcl" / "lang" / "testlang.tcl").read_text(encoding="utf-8")
        assert 'menuText X TipNoTooltip "Astuce" 0 {Un conseil}' in text
        reviews = load_reviews(root, "testlang")
        assert "translate:Greeting" in reviews["entries"]
        assert "translate:Tip" in reviews["entries"]
        # A placeholder loss is refused. Refresh the row's current cell first,
        # or the stale-basis check would stop it before the placeholder check.
        by_id["translate:Greeting"]["new"] = "Salut"
        by_id["translate:Greeting"]["current"] = "Salut %s\nBienvenue"
        by_id["translate:Greeting"]["reviewed"] = ""
        with out.open("w", encoding="utf-8-sig", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=CSV_COLUMNS)
            writer.writeheader()
            writer.writerows(rows)
        import contextlib
        import io
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = import_csv(root, "testlang", out, apply=True, force=False,
                            reviewer="Tester")
        assert rc == 2, rc
        assert "placeholders differ" in buf.getvalue(), buf.getvalue()
        # A missing key is inserted in English order and can be translated.
        (root / "tcl" / "lang" / "english.tcl").write_text(
            english + "translate E Extra {Extra}\n", encoding="utf-8")
        out2 = root / "test2.csv"
        generate(root, "testlang", out2)
        rows2 = read_rows(out2)
        by_id2 = {f"{r['command']}:{r['key']}": r for r in rows2}
        assert "translate:Extra" in by_id2
        by_id2["translate:Extra"]["new"] = "Supplément"
        by_id2["translate:Extra"]["reviewed"] = "Y"
        by_id2["translate:Extra"]["reviewer"] = "Tester"
        with out2.open("w", encoding="utf-8-sig", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=CSV_COLUMNS)
            writer.writeheader()
            writer.writerows(rows2)
        rc = import_csv(root, "testlang", out2, apply=True, force=False,
                        reviewer="Tester")
        assert rc == 0, rc
        text = (root / "tcl" / "lang" / "testlang.tcl").read_text(encoding="utf-8")
        assert "translate X Extra {Supplément}" in text
        assert text.index("translate X Quote") < text.index("translate X Tip") < \
            text.index("translate X Extra")
        # A spreadsheet drops trailing newlines from `current` and `new`: the
        # row still matches the catalogue, and the newline is kept.
        (root / "tcl" / "lang" / "english.tcl").write_text(
            english + "translate E Extra {Extra}\ntranslate E Trail {Line\n}\n",
            encoding="utf-8")
        (root / "tcl" / "lang" / "testlang.tcl").write_text(
            text.replace("translate X Extra {Supplément}\n",
                         "translate X Extra {Supplément}\ntranslate X Trail {Ligne\n}\n"),
            encoding="utf-8")
        out3 = root / "test3.csv"
        generate(root, "testlang", out3)
        rows3 = read_rows(out3)
        trail = next(r for r in rows3 if r["key"] == "Trail")
        assert trail["current"] == "Ligne\n", trail["current"]
        trail["current"] = "Ligne"
        trail["new"] = "Une ligne"
        with out3.open("w", encoding="utf-8-sig", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=CSV_COLUMNS)
            writer.writeheader()
            writer.writerows(rows3)
        rc = import_csv(root, "testlang", out3, apply=True, force=False,
                        reviewer="Tester")
        assert rc == 0, rc
        text = (root / "tcl" / "lang" / "testlang.tcl").read_text(encoding="utf-8")
        assert "translate X Trail {Une ligne\\n}" in text, text
    print("selftest: ok")
    return 0


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=None,
                        help="repository root (default: two levels above this file)")
    sub = parser.add_subparsers(dest="command", required=True)

    gen = sub.add_parser("generate", help="write the CSV workbench")
    gen.add_argument("language", help="catalogue stem, e.g. francais or portbr")
    gen.add_argument("-o", "--out", default=None)

    imp = sub.add_parser("import", help="apply a returned CSV by key")
    imp.add_argument("language")
    imp.add_argument("csv")
    imp.add_argument("--dry-run", action="store_true", default=False)
    imp.add_argument("--apply", action="store_true", default=False)
    imp.add_argument("--force", action="store_true", default=False,
                     help="apply rows whose English changed since export")
    imp.add_argument("--reviewer", default="", help="default reviewer name")

    stat = sub.add_parser("status", help="show coverage and review progress")
    stat.add_argument("language")

    sub.add_parser("selftest", help="run the built-in tests")

    args = parser.parse_args(argv)
    root = Path(args.root) if args.root else Path(__file__).resolve().parents[2]

    try:
        if args.command == "selftest":
            return selftest()
        if args.command == "generate":
            out = Path(args.out) if args.out else \
                Path(f"translations-{args.language}-{date.today().isoformat()}.csv")
            generate(root, args.language, out)
            return 0
        if args.command == "status":
            return status(root, args.language)
        if args.command == "import":
            if args.apply and args.dry_run:
                parser.error("choose --dry-run or --apply, not both")
            return import_csv(root, args.language, Path(args.csv),
                              apply=args.apply, force=args.force,
                              reviewer=args.reviewer)
    except LangError as exc:
        print(f"langtool: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
