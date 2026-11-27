---
name: lang-import
description: Import a translator's returned CSV worksheet into a tcl/lang/<language>.tcl catalogue with tcl/lang/langtool.py (the CSV workbench from PR #540), checking the submitted text before applying it. Use when the maintainer receives a translations-*.csv from a native speaker.
---

# Importing a returned translation sheet

The documented process is `tcl/lang/LANGTOOL.md` ("Maintainer workflow").
This skill adds what the first real import (French, 2026-11) taught.

## Steps

1. Branch from `github` (e.g. `lang-<stem>-review`). Copy the CSV into the
   scratchpad; never edit the user's original.
2. Dry run:
   `python3 -I tcl/lang/langtool.py import <stem> <sheet.csv> --dry-run`
   Use the catalogue stem (`francais`, `portbr`, `deutsch`).
3. For each refused row, compare the sheet's `current` cell, the catalogue's
   value and the `new` cell (load both with `langtool.load_catalogue` /
   `langtool.read_rows`). Known causes:
   - **The translator typed into `current` instead of `new`.** Check with
     `git log -S"<their text>" -- tcl/lang/<stem>.tcl`: if the text was never
     in the catalogue, it is their translation. Move it to `new`, put the
     catalogue's value back in `current`, keep their review.
   - **The catalogue really changed since the sheet was generated.** Decide
     per row; do not `--force` blindly.
   - (Trailing newlines dropped by the spreadsheet app are handled by the
     importer since commit a4902bf2.)
4. **Read every changed cell** (EN / old / new), not just the dry run's
   first entries. Correct only clear errors: truncation, copy-paste shifts
   between neighbouring rows, inverted meaning, typos, agreement, a button
   name quoted differently from the button itself, technical identifiers
   (API scopes like `puzzle:read`, `%s` and the like) that must stay untranslated.
   Leave style and wording choices to the native speaker.
   Rows you change: clear `reviewed`/`reviewer`, so the review record
   never claims the translator approved your text.
5. Write the corrections as a script that produces a corrected copy of the
   sheet (scratchpad), dry-run it to 0 errors, then
   `--apply --reviewer "<translator>"`.
6. Check: `tclsh tcl/lang/checklangs.tcl <stem>`: compare with its output
   before the import (missing keys from new English strings are expected
   and pre-existing). Run `python3 tcl/lang/langtool.py selftest` and the
   `tclsh` harnesses in `.github/workflows/tcl-tests.yml`. The importer
   rewrites multi-line values onto one line with `\n`; `translate` expands
   `\n` at runtime (`tcl/language.tcl`), so that is expected.
7. Commit the catalogue and `tcl/lang/reviews/<stem>.json` together, with the
   translator credited, and list your corrections in the message. A fix to
   langtool itself goes in its own commit.
8. Report: counts, refused rows and how each was resolved, every correction
   you made, test results. Push or open a PR only when the maintainer asks.
