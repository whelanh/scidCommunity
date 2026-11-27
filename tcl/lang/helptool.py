#!/usr/bin/env python3
"""helptool.py -- a CSV workbench for the translated help pages.

langtool.py does this for the interface catalogues (tcl/lang/*.tcl). The help
pages (tcl/help/help.tcl and its translations helpA.tcl ...) are prose with
markup, so the unit here is not a key but a *block*: a heading, a paragraph, a
list item or the footer line of a page. This tool exports every English block
next to its current translation as one CSV, and imports a returned CSV by
page and block.

  python3 tcl/lang/helptool.py generate francais
  python3 tcl/lang/helptool.py import francais help-francais-*.csv --dry-run
  python3 tcl/lang/helptool.py import francais help-francais-*.csv --apply
  python3 tcl/lang/helptool.py status francais
  python3 tcl/lang/helptool.py check francais

The inline markup stays in the cell: ``<a PGN>PGN</a> files`` can become
``fichiers <a PGN>PGN</a>``. A translator may move a tag to where the
sentence needs it; the importer insists only that every tag of the English
block is still there, once for each time English has it.

How a translation is matched to English. The *page structure always comes
from English*: a block is what lies between two block tags (<p>, <li>, <h1>
..., or an empty line, which htext reads as <p>). A translated page is cut
the same way and its blocks are paired with English's: by position when the
two pages have the same blocks, otherwise by a best alignment on the links,
numbers and names that survive translation (see ``align``). A block that
cannot be paired with confidence is left out of the pairing rather than
guessed: it shows as ``missing`` in the sheet, its `current` cell is empty,
and a translation entered for it is inserted as a new block next to its
neighbours. Nothing the importer cannot pair is ever overwritten.

Review state lives in tcl/lang/reviews/help-<language>.json. It follows the
*content* (the English block and its translation, both hashed), not the
position, so an English block inserted in the middle of a page does not make
every later block look unreviewed.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import os
import re
import stat
import sys
import tempfile
from collections import Counter
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path
from typing import Iterable, Optional

CSV_COLUMNS = [
    "page", "key", "kind",
    "english", "current", "new",
    "reviewed", "reviewer", "notes",
    "flags", "source_line", "english_hash",
]
TRUTHY = {"y", "yes", "true", "1", "x"}
FALSY = {"n", "no", "false", "0"}

# Tags that start or end a block. Everything else is inline and stays inside
# the cell. htext keeps no nesting, so closing tags are optional and often
# missing; they end a block but are never needed to find one.
SEG_KINDS = ("h1", "h2", "h3", "h4", "p", "li", "footer")
BLOCK_NAMES = set(SEG_KINDS) | {"ul", "ol"}
# Inline tags that point somewhere. They survive translation unchanged, which
# is what makes them good anchors when pairing a translation with English.
ANCHOR_TAGS = {"a", "button", "img", "url", "run"}

TAG_RE = re.compile(r"</?[A-Za-z][^<>]*>")
TOKEN_RE = re.compile(r"</?[A-Za-z][^<>]*>|[^<]+|<")
TAG_NAME_RE = re.compile(r"<(/?)\s*([A-Za-z][A-Za-z0-9]*)\s*([^<>]*?)\s*>")
TITLE_RE = re.compile(r'^set\s+helpTitle\(([^)]+)\)[ \t]+"', re.MULTILINE)
TEXT_RE = re.compile(r"^set\s+helpText\(([^)]+)\)[ \t]*\{", re.MULTILINE)

# A paired block must score at least this much (see ``score``).
PAIR_THRESHOLD = 0.4
WRAP_WIDTH = 88
ONE_LINE_MAX = 150


class HelpError(ValueError):
    pass


# --------------------------------------------------------------------------
# Small helpers
# --------------------------------------------------------------------------

def ws(text: str) -> str:
    """Whitespace-normalised: the form that is compared, hashed and shown."""
    return re.sub(r"\s+", " ", text).strip()


def sha1(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()


def block_hash(kind: str, text: str) -> str:
    return sha1(json.dumps([kind, ws(text)], ensure_ascii=False))


def norm_tag(tag: str) -> str:
    m = TAG_NAME_RE.fullmatch(tag)
    if not m:
        return tag
    slash, name, attrs = m.groups()
    attrs = re.sub(r"\s+", " ", attrs)
    return f"<{slash}{name.lower()}{(' ' + attrs) if attrs else ''}>"


def tag_multiset(text: str) -> Counter:
    return Counter(norm_tag(t) for t in TAG_RE.findall(text))


def plain(text: str) -> str:
    return TAG_RE.sub(" ", text)


def has_words(text: str) -> bool:
    return re.search(r"\w", plain(text)) is not None


def match_brace(text: str, open_index: int) -> int:
    """Index of the '}' closing the '{' at open_index (Tcl brace rules)."""
    depth = 0
    i = open_index
    n = len(text)
    while i < n:
        c = text[i]
        if c == "\\":
            i += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise HelpError(f"unbalanced braces from offset {open_index}")


def title_decode(raw: str) -> str:
    return re.sub(r"\\(.)", r"\1", raw)


def title_encode(value: str) -> str:
    out = []
    for ch in value:
        if ch in '\\"$[]':
            out.append("\\" + ch)
        else:
            out.append(ch)
    return "".join(out)


def find_title_end(text: str, start: int) -> int:
    """Index of the closing quote of the title string whose body starts at start."""
    i = start
    while i < len(text):
        if text[i] == "\\":
            i += 2
            continue
        if text[i] == '"':
            return i
        if text[i] == "\n":
            break
        i += 1
    raise HelpError(f"unterminated title string at offset {start}")


# --------------------------------------------------------------------------
# Pages and blocks
# --------------------------------------------------------------------------

@dataclass
class Seg:
    kind: str
    start: int              # absolute offsets in the file text
    end: int
    raw: str
    line: int = 0

    @property
    def text(self) -> str:
        return ws(self.raw)

    @property
    def hash(self) -> str:
        return block_hash(self.kind, self.raw)


@dataclass
class Page:
    key: str
    title: Optional[str] = None
    title_span: Optional[tuple[int, int]] = None
    body_start: int = 0
    body_end: int = 0
    segs: list[Seg] = field(default_factory=list)
    order: int = 0


class Doc:
    """One help file: its text, its pages in file order, its line endings."""

    def __init__(self, path: Path, prefix: str):
        raw = path.read_bytes().decode("utf-8")
        self.crlf = "\r\n" in raw
        self.text = raw.replace("\r\n", "\n")
        self.path = path
        self.prefix = prefix
        self.pages: dict[str, Page] = {}
        self._parse()

    def _key(self, full: str) -> Optional[str]:
        if self.prefix:
            if not full.startswith(self.prefix):
                return None
            return full[len(self.prefix):]
        return full

    def _parse(self) -> None:
        text = self.text
        for m in TITLE_RE.finditer(text):
            key = self._key(m.group(1))
            if key is None:
                continue
            end = find_title_end(text, m.end())
            page = self.pages.setdefault(key, Page(key, order=len(self.pages)))
            page.title = title_decode(text[m.end():end])
            page.title_span = (m.end(), end)
        for m in TEXT_RE.finditer(text):
            key = self._key(m.group(1))
            if key is None:
                continue
            open_index = m.end() - 1
            close_index = match_brace(text, open_index)
            page = self.pages.setdefault(key, Page(key, order=len(self.pages)))
            page.body_start = open_index + 1
            page.body_end = close_index
            page.segs = cut_blocks(text, page.body_start, page.body_end)
        for page in self.pages.values():
            for seg in page.segs:
                seg.line = text.count("\n", 0, seg.start) + 1

    def has_body(self, key: str) -> bool:
        return key in self.pages and self.pages[key].body_end > 0


def cut_blocks(text: str, start: int, end: int) -> list[Seg]:
    """The blocks of the page body text[start:end]."""
    body = text[start:end]
    segs: list[Seg] = []
    kind = ""
    run_kind = ""
    run_start = run_end = None

    def flush() -> None:
        nonlocal run_start, run_end
        if run_start is not None:
            raw = body[run_start:run_end]
            if has_words(raw):
                segs.append(Seg(run_kind, start + run_start, start + run_end, raw))
        run_start = run_end = None

    for m in TOKEN_RE.finditer(body):
        tok = m.group(0)
        if tok.startswith("<") and TAG_RE.fullmatch(tok):
            closing, name, _ = TAG_NAME_RE.fullmatch(tok).groups()
            name = name.lower()
            if name in BLOCK_NAMES:
                flush()
                kind = "" if closing or name not in SEG_KINDS else name
                continue
            if run_start is None:
                run_kind = kind
                run_start = m.start()
            run_end = m.end()
            continue
        # Text. An empty line is htext's <p>; a whitespace-only line is not.
        pieces = re.split(r"(\n\n)", tok)
        pos = m.start()
        for piece in pieces:
            if piece == "\n\n":
                flush()
                kind = "p"
            elif piece.strip():
                lead = len(piece) - len(piece.lstrip())
                if run_start is None:
                    run_kind = kind
                    run_start = pos + lead
                run_end = pos + len(piece.rstrip())
            pos += len(piece)
    flush()
    return segs


# --------------------------------------------------------------------------
# Pairing a translation with English
# --------------------------------------------------------------------------

_INV_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9_+:.\-/%#]*")


def invariants(text: str) -> Counter:
    """Tokens that survive translation: numbers, acronyms, key names, ids."""
    out: Counter = Counter()
    for tok in _INV_RE.findall(plain(text)):
        tok = tok.rstrip(".:-/")
        if len(tok) < 2 and not tok.isdigit():
            continue
        if (any(c.isdigit() for c in tok) or "_" in tok or "::" in tok
                or (tok.isupper() and len(tok) >= 2)
                or any(c.isupper() for c in tok[1:])):
            out[tok.lower()] += 1
    return out


def anchors(text: str) -> Counter:
    out: Counter = Counter()
    for tag in TAG_RE.findall(text):
        t = norm_tag(tag)
        m = TAG_NAME_RE.fullmatch(t)
        if m and not m.group(1) and m.group(2) in ANCHOR_TAGS:
            out[t] += 1
    return out


def _jaccard(a: Counter, b: Counter) -> float:
    union = sum((a | b).values())
    return sum((a & b).values()) / union if union else 1.0


@dataclass
class Features:
    kind: str
    length: int
    anchors: Counter
    inv: Counter


def features(seg: Seg) -> Features:
    return Features(seg.kind, len(plain(seg.text).strip()), anchors(seg.raw),
                    invariants(seg.raw))


def score(e: Features, t: Features, ratio: float) -> Optional[float]:
    """How well translated block t answers English block e; None if never."""
    if e.kind != t.kind:
        return None
    s = 1.0
    # Links and buttons survive translation, so they are strong evidence; a
    # name or number that appears on one side only is weak evidence against
    # (machine translation renders "scidCommunity" as "communaute scid").
    if e.anchors or t.anchors:
        if e.anchors == t.anchors:
            s += 3.0
        else:
            s += 3.0 * _jaccard(e.anchors, t.anchors) - 1.0
    if e.inv and t.inv:
        s += 2.0 * _jaccard(e.inv, t.inv)
    elif e.inv or t.inv:
        s -= 0.2
    r = math.log((t.length + 5) / (e.length + 5))
    s -= min(abs(r - ratio), 2.0) * 0.8
    return s


def positional(en: list[Seg], tr: list[Seg]) -> bool:
    return len(en) == len(tr) and all(a.kind == b.kind for a, b in zip(en, tr))


def length_ratio(pairs: Iterable[tuple[Seg, Seg]]) -> float:
    logs = sorted(math.log((len(plain(t.text).strip()) + 5)
                           / (len(plain(e.text).strip()) + 5)) for e, t in pairs)
    return logs[len(logs) // 2] if logs else 0.0


def align(en: list[Seg], tr: list[Seg], ratio: float) -> list[Optional[int]]:
    """For each English block, the index of its translated block or None.

    A monotone alignment that maximises the total score, taking only pairs
    that score at least PAIR_THRESHOLD, so a block with no good counterpart
    stays unpaired. Pairing equal-length pages by position is not safe: one
    block inserted and another removed leaves the counts equal and every
    block after the change paired with its neighbour's translation.
    """
    ef = [features(s) for s in en]
    tf = [features(s) for s in tr]
    n, m = len(en), len(tr)
    gain = [[0.0] * (m + 1) for _ in range(n + 1)]
    take: dict[tuple[int, int], float] = {}
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            best = max(gain[i - 1][j], gain[i][j - 1])
            s = score(ef[i - 1], tf[j - 1], ratio)
            if s is not None and s >= PAIR_THRESHOLD:
                cand = gain[i - 1][j - 1] + s
                if cand > best:
                    best = cand
                    take[(i, j)] = s
            gain[i][j] = best
    out: list[Optional[int]] = [None] * n
    i, j = n, m
    while i > 0 and j > 0:
        if (i, j) in take and gain[i][j] == gain[i - 1][j - 1] + take[(i, j)]:
            out[i - 1] = j - 1
            i -= 1
            j -= 1
        elif gain[i][j] == gain[i - 1][j]:
            i -= 1
        else:
            j -= 1
    return out


@dataclass
class PageView:
    """An English page and what the translation has for it."""
    key: str
    en: Page
    tr: Optional[Page]
    pairs: list[Optional[int]]          # English block -> translated block
    extras: list[int]                   # translated blocks nobody pairs with


def global_ratio(english: Doc, target: Doc) -> float:
    pairs = []
    for key, ep in english.pages.items():
        tp = target.pages.get(key)
        if tp and positional(ep.segs, tp.segs):
            pairs.extend(zip(ep.segs, tp.segs))
    return length_ratio(pairs)


def view_pages(english: Doc, target: Doc) -> dict[str, PageView]:
    ratio = global_ratio(english, target)
    views: dict[str, PageView] = {}
    for key, ep in english.pages.items():
        tp = target.pages.get(key)
        if tp is None or not target.has_body(key):
            views[key] = PageView(key, ep, tp, [None] * len(ep.segs), [])
            continue
        pairs = align(ep.segs, tp.segs, ratio)
        used = {p for p in pairs if p is not None}
        extras = [j for j in range(len(tp.segs)) if j not in used]
        views[key] = PageView(key, ep, tp, pairs, extras)
    return views


# --------------------------------------------------------------------------
# Languages and reviews
# --------------------------------------------------------------------------

def language_map(root: Path) -> tuple[dict[str, str], dict[str, str]]:
    """({catalogue stem: letter}, {letter: help file}) from language.tcl."""
    path = root / "tcl" / "language.tcl"
    text = path.read_text(encoding="utf-8")
    letters: dict[str, str] = {}
    for m in re.finditer(r"^addLanguage\s+(\S+)\s+\S+\s+\d+\s+\S+\s+(\S+)\.tcl\s*$",
                         text, re.MULTILINE):
        letters[m.group(2)] = m.group(1)
    files: dict[str, str] = {}
    m = re.search(r"array set ::helpLangFile\s*\{([^}]*)\}", text)
    if m:
        words = m.group(1).split()
        files = dict(zip(words[0::2], words[1::2]))
    return letters, files


def resolve(root: Path, name: str) -> tuple[str, str, Path]:
    """(stem, letter, help file path) for a catalogue stem or a help file."""
    name = Path(name).name
    if name.endswith(".tcl"):
        name = name[:-4]
    letters, files = language_map(root)
    helpdir = root / "tcl" / "help"
    if name in ("english", "help"):
        raise HelpError("help.tcl is the English source, not a translation")
    if name in letters:
        letter = letters[name]
    else:
        by_file = {Path(f).stem: (letter, f) for letter, f in files.items()}
        if name not in by_file:
            raise HelpError(f"no help translation named {name!r}")
        letter = by_file[name][0]
        name = next((s for s, lt in letters.items() if lt == letter), name)
    if letter not in files:
        raise HelpError(f"{name}: no help file is registered for letter {letter!r}")
    return name, letter, helpdir / files[letter]


def review_path(root: Path, stem: str) -> Path:
    return root / "tcl" / "lang" / "reviews" / f"help-{stem}.json"


def load_reviews(root: Path, stem: str) -> dict:
    path = review_path(root, stem)
    if not path.exists():
        return {"version": 1, "pages": {}}
    data = json.loads(path.read_text(encoding="utf-8"))
    data.setdefault("version", 1)
    data.setdefault("pages", {})
    return data


def save_reviews(root: Path, stem: str, data: dict) -> None:
    path = review_path(root, stem)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                   encoding="utf-8")
    os.replace(tmp, path)


def review_find(reviews: dict, page: str, english: str, translation: str) -> Optional[dict]:
    for rec in reviews["pages"].get(page, []):
        if rec.get("english") == english and rec.get("translation") == translation:
            return rec
    return None


# --------------------------------------------------------------------------
# Rows
# --------------------------------------------------------------------------

def title_hash(title: str) -> str:
    return block_hash("title", title)


def is_identical(english: str, current: str) -> bool:
    return (ws(english) == ws(current)
            and len(re.findall(r"[^\W\d_]", plain(english))) >= 3)


def build_rows(english: Doc, target: Doc, reviews: dict,
               views: dict[str, PageView]) -> list[dict]:
    rows: list[dict] = []
    for key, view in views.items():
        ep, tp = view.en, view.tr
        # The page title.
        cur_title = tp.title if tp is not None and tp.title is not None else ""
        rows.append(_row(key, 0, "title", ep.title or "", cur_title,
                         reviews, 0, title_hash(ep.title or ""),
                         tp is None or tp.title is None))
        for n, seg in enumerate(ep.segs, 1):
            j = view.pairs[n - 1]
            cur = tp.segs[j].text if (tp is not None and j is not None) else ""
            rows.append(_row(key, n, seg.kind, seg.text, cur, reviews,
                             seg.line, seg.hash, j is None))
    for key, view in views.items():
        if view.tr is None:
            continue
        for j in view.extras:
            seg = view.tr.segs[j]
            rows.append({
                "page": key, "key": f"{key}#extra{j + 1}", "kind": seg.kind,
                "english": "", "current": seg.text, "new": "",
                "reviewed": "N", "reviewer": "", "notes": "",
                "flags": "extra", "source_line": seg.line, "english_hash": "",
            })
    for key, tp in target.pages.items():
        if key in english.pages:
            continue
        rows.append({
            "page": key, "key": f"{key}#extra0", "kind": "title",
            "english": "", "current": tp.title or "", "new": "",
            "reviewed": "N", "reviewer": "", "notes": "",
            "flags": "unknown-page", "source_line": "", "english_hash": "",
        })
    return rows


def _row(page: str, n: int, kind: str, english: str, current: str,
         reviews: dict, line: int, ehash: str, missing: bool) -> dict:
    flags = []
    reviewed = reviewer = ""
    if missing:
        flags.append("missing")
    else:
        if is_identical(english, current):
            flags.append("identical")
        rec = review_find(reviews, page, ehash,
                          block_hash(kind, current))
        if rec:
            reviewed, reviewer = "Y", rec.get("reviewer", "")
    return {
        "page": page, "key": f"{page}#{n}", "kind": kind,
        "english": ws(english), "current": ws(current), "new": "",
        "reviewed": reviewed, "reviewer": reviewer, "notes": "",
        "flags": " ".join(flags), "source_line": line or "",
        "english_hash": ehash,
    }


def generate(root: Path, name: str, out: Path, pages: Optional[list[str]] = None,
             unreviewed: bool = False) -> None:
    stem, letter, path = resolve(root, name)
    if not path.exists():
        raise HelpError(f"no such help file: {path}")
    english = Doc(root / "tcl" / "help" / "help.tcl", "")
    target = Doc(path, letter + ",")
    reviews = load_reviews(root, stem)
    views = view_pages(english, target)
    rows = build_rows(english, target, reviews, views)
    if pages:
        unknown = [p for p in pages if p not in english.pages]
        if unknown:
            raise HelpError("no such English page(s): " + ", ".join(unknown))
        rows = [r for r in rows if r["page"] in pages]
    if unreviewed:
        rows = [r for r in rows if r["reviewed"] != "Y"]
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8-sig", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=CSV_COLUMNS, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
    count = lambda flag: sum(1 for r in rows if flag in r["flags"].split())
    print(f"{stem}: {len(rows)} rows, {count('missing')} missing, "
          f"{count('identical')} identical, {count('extra') + count('unknown-page')} "
          f"not in English, {sum(1 for r in rows if r['reviewed'] == 'Y')} reviewed")
    print(f"wrote {out}")


# --------------------------------------------------------------------------
# Validation
# --------------------------------------------------------------------------

def brace_problems(text: str) -> list[str]:
    depth = 0
    i = 0
    while i < len(text):
        c = text[i]
        if c == "\\":
            i += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth < 0:
                return ["a '}' closes no '{'"]
        i += 1
    if depth:
        return ["a '{' is never closed"]
    return []


def fmt_tags(tags: Counter) -> str:
    return " ".join(t + (f" (x{n})" if n > 1 else "") for t, n in sorted(tags.items()))


def check_block(english: str, new: str, kind: str) -> list[str]:
    """Why `new` cannot stand for the English block, or [] if it can."""
    problems: list[str] = []
    if not new.strip():
        return ["the text is empty"]
    if "\x00" in new or re.search(r"[\x01-\x08\x0b\x0c\x0e-\x1f]", new):
        problems.append("it contains a control character")
    if kind == "title":
        if "\n" in new.strip():
            problems.append("a page title is one line")
        if TAG_RE.search(new):
            problems.append("a page title carries no tags")
        return problems
    want, have = tag_multiset(english), tag_multiset(new)
    lost = want - have
    added = have - want
    if lost:
        problems.append("tags missing: " + fmt_tags(lost))
    if added:
        problems.append("tags not in English: " + fmt_tags(added))
    problems.extend(brace_problems(new))
    if ws(new).endswith("\\"):
        problems.append("it ends with a backslash")
    return problems


# --------------------------------------------------------------------------
# Writing text back
# --------------------------------------------------------------------------

def wrap_text(text: str, indent: str, first_col: int) -> str:
    """Fill `text` to WRAP_WIDTH; tags (which hold spaces) are never split."""
    protected = TAG_RE.sub(lambda m: m.group(0).replace(" ", "\x00"), ws(text))
    words = [w.replace("\x00", " ") for w in protected.split(" ") if w]
    lines: list[str] = []
    cur = ""
    col = first_col
    for w in words:
        if cur and col + len(cur) + 1 + len(w) > WRAP_WIDTH:
            lines.append(cur)
            cur = w
            col = len(indent)
        else:
            cur = f"{cur} {w}" if cur else w
    if cur:
        lines.append(cur)
    return ("\n" + indent).join(lines)


def line_indent(text: str, offset: int) -> str:
    begin = text.rfind("\n", 0, offset) + 1
    lead = re.match(r"[ \t]*", text[begin:offset]).group(0)
    return lead


def render_block(text: str, original: str, indent: str, first_col: int) -> str:
    one = ws(text)
    if "\n" not in original and first_col + len(one) <= ONE_LINE_MAX:
        return one
    return wrap_text(one, indent, first_col)


def element_span(text: str, seg: Seg) -> tuple[int, int]:
    """The block with its tags: from its opening tag to its closing tag."""
    start, end = seg.start, seg.end
    if seg.kind:
        before = text[:start]
        m = re.search(r"<%s(?:\s[^<>]*)?>\s*$" % re.escape(seg.kind), before)
        if m:
            start = m.start()
        m = re.match(r"\s*</%s\s*>" % re.escape(seg.kind), text[end:])
        if m:
            end += m.end()
    return start, end


def line_span(text: str, start: int, end: int) -> tuple[int, int]:
    """Widen [start, end) to whole lines when nothing else shares them."""
    begin = text.rfind("\n", 0, start) + 1
    if text[begin:start].strip() == "":
        start = begin
        nl = text.find("\n", end)
        if nl != -1 and text[end:nl].strip() == "":
            end = nl + 1
    return start, end


def apply_edits(text: str, edits: list[tuple[int, int, str]]) -> str:
    out = []
    pos = 0
    for start, end, repl in sorted(edits, key=lambda e: (e[0], e[1])):
        if start < pos:
            raise HelpError("two edits overlap; this is a bug in helptool")
        out.append(text[pos:start])
        out.append(repl)
        pos = end
    out.append(text[pos:])
    return "".join(out)


# --------------------------------------------------------------------------
# Import
# --------------------------------------------------------------------------

def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as fh:
        first = fh.readline()
        fh.seek(0)
        delimiter = max(",;\t", key=first.count)
        reader = csv.DictReader(fh, delimiter=delimiter)
        if reader.fieldnames is None:
            raise HelpError(f"{path}: no header row")
        missing = sorted({"key", "new"} - set(reader.fieldnames))
        if missing:
            raise HelpError(f"{path}: missing column(s): {', '.join(missing)}")
        return [dict(row) for row in reader]


def row_bool(value: Optional[str]) -> Optional[bool]:
    if value is None or not value.strip():
        return None
    v = value.strip().lower()
    if v in TRUTHY:
        return True
    if v in FALSY:
        return False
    raise HelpError(f"reviewed value {value!r} is not Y/N")


def parse_key(key: str) -> Optional[tuple[str, int]]:
    m = re.fullmatch(r"(.+)#(\d+)", key.strip())
    return (m.group(1), int(m.group(2))) if m else None


def new_page_text(ep: Page, english_text: str, news: dict[int, str],
                  new_title: Optional[str], prefix: str, crlf: bool) -> str:
    """A page the translation lacks: English's body with `news` put in."""
    edits = []
    for n, seg in enumerate(ep.segs, 1):
        if n in news:
            edits.append((seg.start, seg.end,
                          wrap_text(news[n], line_indent(english_text, seg.start),
                                    len(line_indent(english_text, seg.start)))))
    body = apply_edits(english_text, edits)[ep.body_start:
                                            ep.body_end + sum(len(e[2]) - (e[1] - e[0])
                                                              for e in edits)]
    title = new_title if new_title is not None else (ep.title or ep.key)
    return (f'\n\nset helpTitle({prefix}{ep.key}) "{title_encode(title)}"\n'
            f"set helpText({prefix}{ep.key}) {{{body}}}\n")


def import_csv(root: Path, name: str, csv_path: Path, *, apply: bool,
               force: bool, reviewer: str) -> int:
    stem, letter, target_path = resolve(root, name)
    if not target_path.exists():
        raise HelpError(f"no such help file: {target_path}")
    english = Doc(root / "tcl" / "help" / "help.tcl", "")
    target = Doc(target_path, letter + ",")
    views = view_pages(english, target)
    reviews = load_reviews(root, stem)
    rows = read_rows(csv_path)
    prefix = letter + ","

    errors: list[str] = []
    warnings: list[str] = []
    edits: list[tuple[int, int, str]] = []
    # page -> list of (English block index, text) with no counterpart yet
    inserts: dict[str, list[tuple[int, str]]] = {}
    page_titles: dict[str, str] = {}
    review_updates: list[tuple[str, str, str, Optional[dict]]] = []
    changed = reviewed_count = skipped = 0
    seen: set[str] = set()
    today = date.today().isoformat()
    previews: list[str] = []

    # English blocks by hash, per page, for rows whose number has moved.
    by_hash: dict[str, dict[str, list[int]]] = {}
    for key, ep in english.pages.items():
        d: dict[str, list[int]] = {}
        for n, seg in enumerate(ep.segs, 1):
            d.setdefault(seg.hash, []).append(n)
        by_hash[key] = d
    claimed: set[tuple[str, int]] = set()

    deleted: dict[str, int] = {}
    for row in rows:
        key = (row.get("key") or "").strip()
        em = re.fullmatch(r"(.+)#extra(\d+)", key)
        if em:
            # A block English no longer has. The only thing a sheet can do
            # with it is remove it: DELETE in the new cell.
            word = (row.get("new") or "").strip()
            page, jn = em.group(1), int(em.group(2))
            view = views.get(page)
            if word.upper() == "DELETE" and jn >= 1 and view is not None \
                    and view.tr is not None and (jn - 1) in view.extras:
                seg = view.tr.segs[jn - 1]
                if not force and ws(row.get("current") or "") != seg.text:
                    errors.append(f"{key}: the current translation changed since "
                                  f"the CSV was generated; re-generate or use --force")
                    skipped += 1
                    continue
                es, ee = element_span(target.text, seg)
                a, b = line_span(target.text, es, ee)
                edits.append((a, b, ""))
                deleted[page] = deleted.get(page, 0) + 1
                changed += 1
                previews.append(f"{key}: delete {seg.text[:70]!r}")
            elif word:
                warnings.append(f"{key}: not in English; only DELETE is accepted "
                                f"here, ignored")
            continue
        parsed = parse_key(key)
        if parsed is None:
            continue
        page, n = parsed
        if key in seen:
            errors.append(f"{key}: appears more than once in the CSV")
            continue
        seen.add(key)
        ep = english.pages.get(page)
        if ep is None:
            warnings.append(f"{key}: no such English page; ignored")
            continue
        new = (row.get("new") or "")
        has_new = bool(new.strip())
        flag_reviewed = row_bool(row.get("reviewed"))
        if not has_new and flag_reviewed is None:
            continue

        # Find the English block this row was written against.
        kind = "title" if n == 0 else None
        ehash = (row.get("english_hash") or "").strip()
        if n == 0:
            actual = title_hash(ep.title or "")
            eseg = None
            etext = ep.title or ""
        else:
            eseg = None
            if 1 <= n <= len(ep.segs):
                eseg = ep.segs[n - 1]
            if eseg is None or (ehash and eseg.hash != ehash and not force):
                # The English moved. Follow the block by its hash.
                moved = [m for m in by_hash[page].get(ehash, [])
                         if (page, m) not in claimed]
                if ehash and len(moved) == 1:
                    n = moved[0]
                    eseg = ep.segs[n - 1]
                    key = f"{page}#{n}"
                else:
                    errors.append(f"{key}: English changed since the CSV was "
                                  f"generated; not applied (re-generate, or use "
                                  f"--force)")
                    skipped += 1
                    continue
            if not force and not ehash:
                errors.append(f"{key}: no english_hash value; keep the generated "
                              f"sheet's hash or use --force")
                skipped += 1
                continue
            actual = eseg.hash
            kind = eseg.kind
            etext = eseg.text
            claimed.add((page, n))
        if n == 0 and not force:
            if not ehash:
                errors.append(f"{key}: no english_hash value; keep the generated "
                              f"sheet's hash or use --force")
                skipped += 1
                continue
            if ehash != actual:
                errors.append(f"{key}: English changed since the CSV was "
                              f"generated; not applied (use --force)")
                skipped += 1
                continue

        view = views[page]
        tp = view.tr
        # What the file has for this block now.
        if n == 0:
            cur_text = tp.title if tp is not None and tp.title is not None else None
            cur_seg = None
        else:
            j = view.pairs[n - 1]
            cur_seg = tp.segs[j] if (tp is not None and j is not None) else None
            cur_text = cur_seg.raw if cur_seg is not None else None

        sheet_current = ws(row.get("current") or "")
        if not force:
            if (cur_text is None and sheet_current) or \
               (cur_text is not None and sheet_current != ws(cur_text)):
                errors.append(f"{key}: the current translation changed since "
                              f"the CSV was generated; "
                              f"{'review not recorded' if not has_new else 're-generate or use --force'}")
                skipped += 1
                continue

        label = "title" if n == 0 else kind
        applied: Optional[str] = None
        if has_new:
            problems = check_block(etext, new, label)
            if problems:
                errors.extend(f"{key}: {p}" for p in problems)
                skipped += 1
                continue
            if cur_text is not None and ws(new) == ws(cur_text):
                has_new = False       # nothing to write; the review may still count
            else:
                changed += 1
                applied = ws(new)
                if n == 0:
                    if tp is not None and tp.title_span is not None:
                        a, b = tp.title_span
                        edits.append((a, b, title_encode(ws(new))))
                    else:
                        page_titles[page] = ws(new)
                    previews.append(f"{key}: {cur_text if cur_text is not None else '(no title)'!r}"
                                    f" -> {ws(new)!r}")
                elif cur_seg is not None:
                    indent = line_indent(target.text, cur_seg.start)
                    col = cur_seg.start - (target.text.rfind("\n", 0, cur_seg.start) + 1)
                    edits.append((cur_seg.start, cur_seg.end,
                                  render_block(new, cur_seg.raw, indent, col)))
                    previews.append(f"{key}: {ws(cur_text)[:60]!r} -> {ws(new)[:60]!r}")
                else:
                    inserts.setdefault(page, []).append((n, ws(new)))
                    previews.append(f"{key}: (new block) {ws(new)[:70]!r}")

        final = applied if applied is not None else (
            ws(cur_text) if cur_text is not None else None)
        if flag_reviewed is True:
            if final is None:
                warnings.append(f"{key}: reviewed, but there is no translation "
                                f"to review; ignored")
                continue
            who = (row.get("reviewer") or reviewer).strip()
            thash = block_hash(label, final)
            review_updates.append((page, actual, thash,
                                   {"english": actual, "translation": thash,
                                    "reviewer": who, "date": today}))
            reviewed_count += 1
        elif flag_reviewed is False and cur_text is not None:
            review_updates.append((page, actual, block_hash(label, ws(cur_text)), None))

    # Blocks the translation lacks go next to their neighbours; a page it
    # lacks is built from English with the new text put in.
    text = target.text
    appended = []
    for page, items in inserts.items():
        view = views[page]
        ep, tp = view.en, view.tr
        if tp is None or not target.has_body(page):
            continue
        by_n = dict(items)
        # group by the position they land at
        landing: dict[int, list[tuple[int, str]]] = {}
        for n, new_text in sorted(by_n.items()):
            prev = None
            for k in range(n - 2, -1, -1):
                if view.pairs[k] is not None:
                    prev = k
                    break
            if prev is not None:
                seg = tp.segs[view.pairs[prev]]
                landing.setdefault(element_span(text, seg)[1], []).append((n, new_text))
                continue
            nxt = None
            for k in range(n, len(ep.segs)):
                if view.pairs[k] is not None:
                    nxt = k
                    break
            if nxt is not None:
                seg = tp.segs[view.pairs[nxt]]
                landing.setdefault(element_span(text, seg)[0], []).append((-n, new_text))
            else:
                at = len(text[:tp.body_end].rstrip(" \t"))
                landing.setdefault(at, []).append((n, new_text))
        for at, group in landing.items():
            block = []
            for n, new_text in sorted(group, key=lambda g: abs(g[0])):
                seg = ep.segs[abs(n) - 1]
                indent = line_indent(text, at) or "  "
                body = render_block(new_text, "", indent, len(indent))
                block.append(f"<{seg.kind}>{body}</{seg.kind}>" if seg.kind else body)
            before = group[0][0] < 0
            if before:
                edits.append((at, at, "\n".join(block) + "\n" + (line_indent(text, at) or "")))
            else:
                edits.append((at, at, "\n" + (line_indent(text, at) or "  ")
                              + ("\n" + (line_indent(text, at) or "  ")).join(block)))

    for page in sorted(set(inserts) | set(page_titles)):
        view = views[page]
        if view.tr is not None and target.has_body(page):
            continue
        news = {n: t for n, t in inserts.get(page, [])}
        if not news and page not in page_titles:
            continue
        appended.append(new_page_text(view.en, english.text, news,
                                      page_titles.get(page), prefix, target.crlf))

    candidate = apply_edits(text, edits) if edits else text
    if appended:
        candidate = candidate.rstrip("\n") + "\n" + "".join(appended)
    if candidate != text:
        problems = validate_candidate(candidate, target_path, letter, views, deleted)
        errors.extend(problems)

    if errors:
        print("\nErrors (rows not applied):")
        for e in errors:
            print("  " + e)
    if warnings:
        print("\nWarnings:")
        for w in warnings:
            print("  " + w)

    summary = (f"{changed} changed, {reviewed_count} marked reviewed, "
               f"{skipped} skipped")
    if not apply:
        print(f"\nDry run: {summary}, {len(errors)} error(s).")
        if previews:
            print("\nFirst changes:")
            for p in previews[:20]:
                print("  " + p)
        return 1 if errors else 0
    if errors:
        print("\nRefusing to write while rows have errors; fix them, or use "
              "--force only after checking the stale basis.")
        return 2

    if review_updates:
        for page, ehash, thash, rec in review_updates:
            lst = reviews["pages"].setdefault(page, [])
            lst[:] = [r for r in lst
                      if not (r.get("english") == ehash and r.get("translation") == thash)]
            if rec is not None:
                lst.append(rec)
            if not lst:
                reviews["pages"].pop(page, None)
        save_reviews(root, stem, reviews)
    if candidate != text:
        out = candidate.replace("\n", "\r\n") if target.crlf else candidate
        with tempfile.NamedTemporaryFile("wb", delete=False,
                                         dir=str(target_path.parent)) as fh:
            tmp_name = fh.name
            fh.write(out.encode("utf-8"))
        try:
            os.chmod(tmp_name, stat.S_IMODE(target_path.stat().st_mode))
            os.replace(tmp_name, target_path)
        except BaseException:
            if os.path.exists(tmp_name):
                os.unlink(tmp_name)
            raise
        print(f"\nApplied: {summary}.")
        print(f"wrote {target_path}")
    else:
        print(f"\nNo text changes; {reviewed_count} review state(s) updated.")
    if review_updates:
        print(f"wrote {review_path(root, stem)}")
    return 0


def validate_candidate(candidate: str, path: Path, letter: str,
                       views: dict[str, PageView],
                       deleted: dict[str, int]) -> list[str]:
    """Re-read what would be written and check it still means what it should."""
    problems: list[str] = []
    tmp = Path(tempfile.mkdtemp()) / path.name
    try:
        tmp.write_bytes(candidate.encode("utf-8"))
        try:
            after = Doc(tmp, letter + ",")
        except HelpError as exc:
            return [f"the edited file no longer parses: {exc}"]
    finally:
        try:
            tmp.unlink()
            tmp.parent.rmdir()
        except OSError:
            pass
    before_keys = set(views)
    for key in before_keys:
        v = views[key]
        if v.tr is None:
            continue
        if key not in after.pages or not after.has_body(key):
            problems.append(f"page {key} vanished from the edited file")
    # Every page that was there keeps at least the blocks it had.
    for key, v in views.items():
        if v.tr is not None and key in after.pages:
            floor = len(v.tr.segs) - deleted.get(key, 0)
            if len(after.pages[key].segs) < floor:
                problems.append(f"page {key} would lose blocks "
                                f"({len(v.tr.segs)} -> {len(after.pages[key].segs)})")
    return problems


# --------------------------------------------------------------------------
# status and check
# --------------------------------------------------------------------------

def status(root: Path, name: str) -> int:
    stem, letter, path = resolve(root, name)
    english = Doc(root / "tcl" / "help" / "help.tcl", "")
    target = Doc(path, letter + ",")
    reviews = load_reviews(root, stem)
    views = view_pages(english, target)
    rows = build_rows(english, target, reviews, views)
    per: dict[str, dict[str, int]] = {}
    for r in rows:
        p = per.setdefault(r["page"], {"blocks": 0, "missing": 0, "identical": 0,
                                       "reviewed": 0, "extra": 0})
        flags = r["flags"].split()
        if "extra" in flags or "unknown-page" in flags:
            p["extra"] += 1
            continue
        p["blocks"] += 1
        p["missing"] += "missing" in flags
        p["identical"] += "identical" in flags
        p["reviewed"] += r["reviewed"] == "Y"
    tot = {k: sum(p[k] for p in per.values()) for k in
           ("blocks", "missing", "identical", "reviewed", "extra")}
    full = sum(1 for p in per.values() if p["blocks"] and p["blocks"] == p["reviewed"])
    print(f"{stem}: {tot['blocks']} blocks in {len(english.pages)} pages, "
          f"{tot['missing']} missing, {tot['identical']} identical, "
          f"{tot['extra']} not in English, {tot['reviewed']} reviewed, "
          f"{full}/{len(per)} pages complete")
    print()
    print(f"{'page':28} {'blocks':>6} {'missing':>7} {'same':>5} {'extra':>5} {'reviewed':>8}")
    for key, p in per.items():
        if key not in english.pages and not p["extra"]:
            continue
        print(f"{key[:28]:28} {p['blocks']:6d} {p['missing']:7d} {p['identical']:5d} "
              f"{p['extra']:5d} {p['reviewed']:8d}")
    return 0


def check_one(root: Path, name: str, verbose: bool = True) -> int:
    stem, letter, path = resolve(root, name)
    english = Doc(root / "tcl" / "help" / "help.tcl", "")
    target = Doc(path, letter + ",")
    views = view_pages(english, target)
    problems: list[str] = []
    notes: list[str] = []
    for key, v in views.items():
        if v.tr is None or not target.has_body(key):
            notes.append(f"{key}: page missing (the viewer shows English)")
            continue
        if v.tr.title is None:
            problems.append(f"{key}: no title; the viewer needs both")
        for n, seg in enumerate(v.en.segs, 1):
            j = v.pairs[n - 1]
            if j is None:
                notes.append(f"{key}#{n}: no translated block")
                continue
            tseg = v.tr.segs[j]
            want, have = tag_multiset(seg.raw), tag_multiset(tseg.raw)
            if want - have:
                problems.append(f"{key}#{n} (line {tseg.line}): tags missing: "
                                f"{fmt_tags(want - have)}")
            if have - want:
                problems.append(f"{key}#{n} (line {tseg.line}): tags not in English: "
                                f"{fmt_tags(have - want)}")
            opens = sum(1 for t in TAG_RE.findall(tseg.raw) if re.match(r"<a(\s|>)", t))
            closes = tseg.raw.count("</a>")
            if opens != closes:
                problems.append(f"{key}#{n} (line {tseg.line}): {opens} <a> and {closes} </a>")
            if re.search(r"<a(?:\s[^<>]*)?>\s*</a>", tseg.raw):
                problems.append(f"{key}#{n} (line {tseg.line}): a link with no text")
        for j in v.extras:
            notes.append(f"{key}: line {v.tr.segs[j].line} has a block English does not")
    for key in target.pages:
        if key not in english.pages:
            notes.append(f"{key}: page is not in English")
    names = set(english.pages)
    for key, tp in target.pages.items():
        for seg in tp.segs:
            for m in re.finditer(r"<a\s+(\S+?)[\s>]", seg.raw):
                if m.group(1) not in names:
                    problems.append(f"{key} (line {seg.line}): link to unknown page {m.group(1)}")
    print(f"{stem}: {len(problems)} problem(s), {len(notes)} note(s)")
    if verbose:
        for p in problems[:200]:
            print("  PROBLEM " + p)
        if len(problems) > 200:
            print(f"  ... and {len(problems) - 200} more")
        for n in notes[:60]:
            print("  note    " + n)
        if len(notes) > 60:
            print(f"  ... and {len(notes) - 60} more")
    return 1 if problems else 0


def check(root: Path, name: Optional[str], all_languages: bool) -> int:
    if all_languages:
        letters, files = language_map(root)
        rc = 0
        for stem, letter in sorted(letters.items()):
            if letter == "E" or letter not in files:
                continue
            rc |= check_one(root, stem, verbose=False)
        return rc
    if not name:
        raise HelpError("name a language, or use --all")
    return check_one(root, name)


# --------------------------------------------------------------------------
# Self-test
# --------------------------------------------------------------------------

ENGLISH_HELP = '''### help.tcl
set helpTitle(Alpha) "Alpha page"
set helpText(Alpha) {<h1>Alpha page</h1>
  <p>
  Open <a PGN>PGN</a> files with the <menu>File</menu> menu, then press
  <b>Enter</b>.
  </p>
  <ul>
  <li>First item, see <a Beta>Beta</a></li>
  <li>Second item has 2 parts</li>
  <li>Third item
  </ul>

  <p><footer>(Updated: scidCommunity, November 2026)</footer></p>
}

set helpTitle(Beta) "Beta page"
set helpText(Beta) {<h1>Beta page</h1>
  <p>Only a paragraph here.</p>
}

set helpTitle(Gamma) "Gamma page"
set helpText(Gamma) {<h1>Gamma page</h1>
  <p>Gamma has a <a Alpha>link</a> and the key F1.</p>
  <p>And a second paragraph.</p>
}
'''

TARGET_HELP = '''### helpX.tcl
set helpTitle(X,Alpha) "Page alpha"
set helpText(X,Alpha) {<h1>Page alpha</h1>
  <p>
  Ouvrir les fichiers <a PGN>PGN</a> avec le menu <menu>Fichier</menu>, puis
  appuyer sur <b>Entree</b>.
  </p>
  <ul>
  <li>Premier element, voir <a Beta>Beta</a></li>
  <li>Troisieme element
  </ul>

  <p><footer>(Mis a jour: scidCommunity, novembre 2026)</footer></p>
}

set helpTitle(X,Beta) "Page beta"
set helpText(X,Beta) {<h1>Page beta</h1>
  <p>Seulement un paragraphe ici.</p>
}
'''

LANGUAGE_TCL = '''addLanguage E English 0 utf-8 english.tcl
addLanguage X Xish 0 utf-8 xish.tcl
array set ::helpLangFile { X helpX.tcl }
'''


def _write_rows(path: Path, rows: list[dict]) -> None:
    with path.open("w", encoding="utf-8-sig", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=CSV_COLUMNS)
        w.writeheader()
        w.writerows(rows)


def selftest() -> int:
    import contextlib
    import io

    def run(root, csvp, apply=True, force=False):
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = import_csv(root, "xish", csvp, apply=apply, force=force,
                            reviewer="Tester")
        return rc, buf.getvalue()

    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "tcl" / "help").mkdir(parents=True)
        (root / "tcl" / "lang").mkdir(parents=True)
        (root / "tcl" / "help" / "help.tcl").write_text(ENGLISH_HELP, encoding="utf-8")
        (root / "tcl" / "help" / "helpX.tcl").write_bytes(
            TARGET_HELP.replace("\n", "\r\n").encode("utf-8"))
        (root / "tcl" / "language.tcl").write_text(LANGUAGE_TCL, encoding="utf-8")

        # --- blocks -------------------------------------------------------
        eng = Doc(root / "tcl" / "help" / "help.tcl", "")
        alpha = eng.pages["Alpha"]
        kinds = [s.kind for s in alpha.segs]
        assert kinds == ["h1", "p", "li", "li", "li", "footer"], kinds
        assert alpha.segs[1].text.startswith("Open <a PGN>PGN</a> files"), alpha.segs[1].text
        assert "\n" not in alpha.segs[1].text
        # an empty line is htext's <p>; a whitespace-only line is not
        segs = cut_blocks("one\n\ntwo\n  \nthree", 0, 17)
        assert [s.text for s in segs] == ["one", "two three"], [s.text for s in segs]

        # --- pairing: the French-like page lacks the second item -----------
        tgt = Doc(root / "tcl" / "help" / "helpX.tcl", "X,")
        assert tgt.crlf
        views = view_pages(eng, tgt)
        v = views["Alpha"]
        assert v.pairs == [0, 1, 2, None, 3, 4], v.pairs
        assert views["Beta"].pairs == [0, 1]
        assert views["Gamma"].tr is None

        # --- generate -------------------------------------------------------
        out = root / "sheet.csv"
        with contextlib.redirect_stdout(io.StringIO()):
            generate(root, "xish", out)
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        assert by["Alpha#3"]["current"].startswith("Premier element"), by["Alpha#3"]
        assert by["Alpha#4"]["current"] == "" and "missing" in by["Alpha#4"]["flags"]
        assert by["Gamma#1"]["flags"].split() == ["missing"]
        assert by["Alpha#0"]["kind"] == "title" and by["Alpha#0"]["current"] == "Page alpha"

        # --- import: reorder a link, translate a missing block, a title -------
        by["Alpha#2"]["new"] = ("Ouvrir les fichiers <a PGN>PGN</a> avec le menu "
                                "<menu>Fichier</menu>, puis appuyer sur <b>Entree</b>.")
        by["Alpha#2"]["new"] = by["Alpha#2"]["new"].replace(
            "les fichiers <a PGN>PGN</a>", "les <a PGN>PGN</a> fichiers")
        by["Alpha#2"]["reviewed"] = "Y"
        by["Alpha#2"]["reviewer"] = "Tester"
        by["Alpha#4"]["new"] = "Deuxieme element avec 2 parties"
        by["Alpha#0"]["new"] = 'Page "alpha" $x'
        _write_rows(out, rows)
        rc, text = run(root, out, apply=False)
        assert rc == 0, text
        assert (root / "tcl" / "help" / "helpX.tcl").read_bytes().decode() == \
            TARGET_HELP.replace("\n", "\r\n"), "a dry run must not write"
        rc, text = run(root, out)
        assert rc == 0, text
        raw = (root / "tcl" / "help" / "helpX.tcl").read_bytes().decode("utf-8")
        assert "\r\n" in raw and "\r\n" * 2 not in raw.replace("\r\n\r\n", ""), "CRLF kept"
        assert raw.count("\n") == raw.count("\r\n"), "every line ending is CRLF"
        flat = raw.replace("\r\n", "\n")
        assert "les <a PGN>PGN</a> fichiers" in flat, flat
        assert "<li>Deuxieme element avec 2 parties</li>" in flat, flat
        assert flat.index("Premier element") < flat.index("Deuxieme") < flat.index("Troisieme")
        assert 'set helpTitle(X,Alpha) "Page \\"alpha\\" \\$x"' in flat, flat
        tgt = Doc(root / "tcl" / "help" / "helpX.tcl", "X,")
        views = view_pages(eng, tgt)
        assert views["Alpha"].pairs == [0, 1, 2, 3, 4, 5], views["Alpha"].pairs
        assert tgt.pages["Alpha"].title == 'Page "alpha" $x'

        # --- reviews follow content ------------------------------------------
        with contextlib.redirect_stdout(io.StringIO()):
            generate(root, "xish", out)
        by = {r["key"]: r for r in read_rows(out)}
        assert by["Alpha#2"]["reviewed"] == "Y" and by["Alpha#2"]["reviewer"] == "Tester"
        assert by["Alpha#3"]["reviewed"] == ""

        # --- refusals ---------------------------------------------------------
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        by["Beta#2"]["new"] = "Un paragraphe sans lien"
        by["Beta#2"]["new"] = "<b>Gras</b> paragraphe"
        by["Alpha#3"]["new"] = "Premier sans le lien"            # loses <a Beta>
        by["Alpha#5"]["new"] = "Troisieme { element"              # brace
        _write_rows(out, rows)
        rc, text = run(root, out)
        assert rc == 2, (rc, text)
        assert "tags not in English: </b> <b>" in text and "tags missing: </a> <a Beta>" in text, text
        assert "'{' is never closed" in text, text
        assert "Premier element" in (root / "tcl" / "help" / "helpX.tcl").read_text(
            encoding="utf-8"), "nothing is written when a row is refused"

        # a stale basis: someone changed the translation under the sheet
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        for r in rows:
            r["new"] = ""
        by["Alpha#3"]["new"] = "Premier element, voir <a Beta>Beta</a> (corrige)"
        by["Alpha#3"]["current"] = "Something else entirely"
        _write_rows(out, rows)
        rc, text = run(root, out)
        assert rc == 2 and "current translation changed" in text, text

        # --- English changes under a sheet ------------------------------------
        with contextlib.redirect_stdout(io.StringIO()):
            generate(root, "xish", out)
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        by["Alpha#3"]["new"] = "Premier element, voir <a Beta>Beta</a> (corrige)"
        _write_rows(out, rows)
        eng_text = (root / "tcl" / "help" / "help.tcl").read_text(encoding="utf-8")
        (root / "tcl" / "help" / "help.tcl").write_text(
            eng_text.replace("  <ul>\n", "  <ul>\n  <li>Brand new first item</li>\n", 1),
            encoding="utf-8")
        rc, text = run(root, out)                       # the block moved down by one
        assert rc == 0 and "corrige" in (root / "tcl" / "help" / "helpX.tcl").read_text(
            encoding="utf-8"), text
        (root / "tcl" / "help" / "help.tcl").write_text(
            eng_text.replace("<li>First item, see", "<li>Changed item, see", 1),
            encoding="utf-8")
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        by["Alpha#3"]["new"] = "encore un changement <a Beta>Beta</a>"
        _write_rows(out, rows)
        rc, text = run(root, out)
        assert rc == 2 and "English changed since the CSV" in text, text
        (root / "tcl" / "help" / "help.tcl").write_text(eng_text, encoding="utf-8")

        # --- a page the translation lacks ---------------------------------------
        with contextlib.redirect_stdout(io.StringIO()):
            generate(root, "xish", out)
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        by["Gamma#0"]["new"] = "Page gamma"
        by["Gamma#2"]["new"] = "Gamma a un <a Alpha>lien</a> et la touche F1."
        _write_rows(out, rows)
        rc, text = run(root, out)
        assert rc == 0, text
        flat = (root / "tcl" / "help" / "helpX.tcl").read_bytes().decode().replace("\r\n", "\n")
        assert 'set helpTitle(X,Gamma) "Page gamma"' in flat, flat
        assert "Gamma a un <a Alpha>lien</a> et la touche F1." in flat
        assert "And a second paragraph." in flat, "an untranslated block falls back to English"
        tgt = Doc(root / "tcl" / "help" / "helpX.tcl", "X,")
        assert view_pages(eng, tgt)["Gamma"].pairs == [0, 1, 2]

        # --- check ----------------------------------------------------------------
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            check(root, "xish", False)
        assert "problem(s)" in buf.getvalue()

        # a link that never closes is what check exists to find
        p = root / "tcl" / "help" / "helpX.tcl"
        p.write_bytes(p.read_bytes().replace(b"<a Beta>Beta</a>", b"<a Beta>Beta"))
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = check(root, "xish", False)
        assert rc == 1 and "tags missing: </a>" in buf.getvalue(), buf.getvalue()

    # --- a drifted page: stale blocks, new blocks, tags on their own lines -----
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        (root / "tcl" / "help").mkdir(parents=True)
        (root / "tcl" / "lang").mkdir(parents=True)
        (root / "tcl" / "help" / "help.tcl").write_text('''set helpTitle(Delta) "Delta page"
set helpText(Delta) {<h1>Delta page</h1>
  <p>
  First paragraph about <a Alpha>Alpha</a> with 3 items.
  </p>
  <p>
  Second paragraph about PGN and ECO.
  </p>
  <p>
  Brand new paragraph.
  </p>
  <h3>Closing words</h3>
  <p>The end.</p>
}
''', encoding="utf-8")
        (root / "tcl" / "help" / "helpX.tcl").write_text('''set helpTitle(X,Delta) "Page delta"
set helpText(X,Delta) {<h1>Page delta</h1>
  <p>
  Premier paragraphe sur <a Alpha>Alpha</a> avec 3 elements.
  </p>
  <p>
  Ancien paragraphe qui n'existe plus en anglais.
  </p>
  <p>
  Deuxieme paragraphe sur PGN et ECO.
  </p>
  <h3>Mots de la fin</h3>
  <p>La fin.</p>
}
''', encoding="utf-8")
        (root / "tcl" / "language.tcl").write_text(LANGUAGE_TCL, encoding="utf-8")
        eng = Doc(root / "tcl" / "help" / "help.tcl", "")
        tgt = Doc(root / "tcl" / "help" / "helpX.tcl", "X,")
        v = view_pages(eng, tgt)["Delta"]
        # the PGN/ECO paragraph pairs with its own translation, not with the
        # stale block before it; the new paragraph stays unpaired
        assert v.pairs == [0, 1, 3, None, 4, 5], v.pairs
        assert v.extras == [2], v.extras
        out = root / "d.csv"
        with contextlib.redirect_stdout(io.StringIO()):
            generate(root, "xish", out)
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        assert by["Delta#4"]["flags"] == "missing" and by["Delta#4"]["current"] == ""
        assert by["Delta#extra3"]["flags"] == "extra"
        assert "Ancien paragraphe" in by["Delta#extra3"]["current"]
        # the new block lands after the paragraph whose </p> is on the next line
        by["Delta#4"]["new"] = "Tout nouveau paragraphe."
        by["Delta#extra3"]["new"] = "DELETE"
        _write_rows(out, rows)
        rc, text = run(root, out)
        assert rc == 0, text
        flat = (root / "tcl" / "help" / "helpX.tcl").read_text(encoding="utf-8")
        assert "Ancien paragraphe" not in flat, flat
        assert "<p>\n  </p>" not in flat and "<p>\n  <p>" not in flat, flat
        i2 = flat.index("Deuxieme paragraphe")
        i3 = flat.index("Tout nouveau")
        assert i2 < flat.index("</p>", i2) < i3 < flat.index("Mots de la fin"), flat
        tgt = Doc(root / "tcl" / "help" / "helpX.tcl", "X,")
        v = view_pages(eng, tgt)["Delta"]
        assert v.pairs == [0, 1, 2, 3, 4, 5] and v.extras == [], (v.pairs, v.extras)
        # DELETE is only for extra blocks
        with contextlib.redirect_stdout(io.StringIO()):
            generate(root, "xish", out)
        rows = read_rows(out)
        by = {r["key"]: r for r in rows}
        by["Delta#2"]["new"] = "DELETE"
        _write_rows(out, rows)
        rc, text = run(root, out)
        assert rc == 2 and "tags missing" in text, text
        assert "Premier paragraphe" in (root / "tcl" / "help" / "helpX.tcl").read_text(
            encoding="utf-8"), "an ordinary block is never deleted"
        # the sheet filters
        with contextlib.redirect_stdout(io.StringIO()):
            generate(root, "xish", out, pages=["Delta"], unreviewed=True)
        assert all(r["page"] == "Delta" for r in read_rows(out))
        with contextlib.redirect_stdout(io.StringIO()):
            status(root, "xish")
    print("selftest: ok")
    return 0


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", default=None, help="repository root")
    sub = parser.add_subparsers(dest="command", required=True)

    gen = sub.add_parser("generate", help="write a CSV for a language's help pages")
    gen.add_argument("language", help="catalogue stem, e.g. francais")
    gen.add_argument("-o", "--out", default=None)
    gen.add_argument("--pages", default="",
                     help="comma-separated page keys to include (default: all)")
    gen.add_argument("--unreviewed", action="store_true",
                     help="only the rows not yet marked reviewed")

    imp = sub.add_parser("import", help="apply a returned CSV")
    imp.add_argument("language")
    imp.add_argument("csv")
    mode = imp.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true")
    mode.add_argument("--apply", action="store_true")
    imp.add_argument("--force", action="store_true",
                     help="apply rows whose English or current basis has changed")
    imp.add_argument("--reviewer", default="", help="default reviewer name")

    stat_p = sub.add_parser("status", help="coverage and review progress")
    stat_p.add_argument("language")

    chk = sub.add_parser("check", help="lint a translated help file")
    chk.add_argument("language", nargs="?")
    chk.add_argument("--all", action="store_true", help="every language, summary only")

    sub.add_parser("selftest", help="run the built-in tests")
    args = parser.parse_args(argv)
    root = Path(args.root) if args.root else Path(__file__).resolve().parents[2]

    try:
        if args.command == "selftest":
            return selftest()
        if args.command == "generate":
            out = Path(args.out) if args.out else Path(
                f"help-{args.language}-{date.today().isoformat()}.csv")
            pages = [p for p in args.pages.split(",") if p]
            generate(root, args.language, out, pages or None, args.unreviewed)
            return 0
        if args.command == "status":
            return status(root, args.language)
        if args.command == "check":
            return check(root, args.language, args.all)
        if args.command == "import":
            return import_csv(root, args.language, Path(args.csv),
                              apply=args.apply, force=args.force,
                              reviewer=args.reviewer)
    except HelpError as exc:
        print(f"helptool: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
