#!/usr/bin/env python3
"""Add the review-progress keys to every language data file that lacks them.

Idempotent: a key already present is left alone. The value is English, which is
what an untranslated tag falls back to anyway; the translation pipeline picks
the keys up from here (the same route AnnotateVariationsMainLineOnly took).
"""
import glob
import os
import re
import sys

KEYS = [
    ("ReviewProgressTitle", "Review progress"),
    ("ReviewProgressIdle", "No review is running"),
    ("ReviewProgressGameOf", "game %s of %s"),
    ("ReviewProgressEngineWindow", "Engine window %s"),
    ("ReviewProgressAnalysisPane", "Analysis pane %s"),
    ("ReviewProgressRapid", "Rapid annotate"),
]

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lang_dir = os.path.join(root, "tcl", "lang")

# Tooling scripts in the same directory are not catalogs.
skip = {"checklangs.tcl", "propagatelang.tcl", "removedeadlang.tcl",
        "removetoken.tcl"}

added = {}
for path in sorted(glob.glob(os.path.join(lang_dir, "*.tcl"))):
    name = os.path.basename(path)
    if name in skip:
        continue
    text = open(path, encoding="utf-8", errors="replace").read()
    m = re.search(r"^translate\s+(\S+)", text, re.M)
    if not m:
        continue
    letter = m.group(1)
    missing = [(k, v) for k, v in KEYS
               if not re.search(r"^translate\s+\S+\s+%s\b" % re.escape(k), text, re.M)]
    if not missing:
        continue
    lines = ["", "# Review progress popup (#422 item 3)."]
    for key, value in missing:
        lines.append("translate %s %s {%s}" % (letter, key, value))
    with open(path, "a", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    added[name] = [k for k, _ in missing]

for name in sorted(added):
    print(name, ",".join(added[name]))
print("files changed:", len(added))
