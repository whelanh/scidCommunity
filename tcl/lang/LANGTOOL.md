# Reviewing a language with one CSV

`tcl/lang/langtool.py` turns a language catalogue into one spreadsheet with
every entry and section, and imports a returned spreadsheet by
`(command, key)`. A native speaker can filter to a section, translate whatever
they want, leave the rest alone, and send the sheet back. Nothing is replaced
wholesale: only the rows whose `new` cell changed are written, in the existing
order.

The tool needs Python 3.8 or later and nothing else. Run it from the
repository root or pass `--root`.

```sh
# One file per language, all sections:
python3 tcl/lang/langtool.py generate francais -o francais-review.csv

# See what would change, without writing:
python3 tcl/lang/langtool.py import francais francais-review.csv --dry-run

# Apply it:
python3 tcl/lang/langtool.py import francais francais-review.csv \
    --apply --reviewer "IttacusFc"

# Per-section coverage and review state:
python3 tcl/lang/langtool.py status francais
```

Use the catalogue stem (`francais`, `portbr`, `deutsch`), not the menu name.
The generated file is UTF-8 with a BOM so Excel shows accents correctly, and
the importer accepts comma, semicolon or tab separated files.

## The sheet

There is one row per English entry, in English order. Sections are a filter,
not a separate file: the reviewer can sort or filter the `section` column and
work on any rows they like.

| Column | Meaning |
| --- | --- |
| `section` | The comment heading in `english.tcl` |
| `command` | `menuText`, `translate` or `helpMsg`; do not edit |
| `key` | The tag, e.g. `FileOpen`; do not edit |
| `english` | The English label or message |
| `current` | The translation in the catalogue now; keep this cell for changed rows |
| `new` | **The translator writes here.** Blank means keep `current` |
| `english_tooltip` / `current_tooltip` / `new_tooltip` | The tooltip for `menuText` entries |
| `underline` | The catalogue’s menu mnemonic index (English if the catalogue lacks the key); the importer recalculates it if the label changes |
| `reviewed` | `Y` means “I checked this translation”; `N` clears an earlier review; blank keeps it |
| `reviewer` | The person who reviewed the row |
| `notes` | Free text; ignored by the importer |
| `flags` | `missing`, `identical`, `unknown`, `bad-underline`; informational |
| `source_line` | Technical; do not edit |
| `english_hash` | Technical stale-basis check; keep it, do not edit |

The `english_hash` column is how the importer knows a row was translated
against an older English string. If English changed after the CSV was
generated, the row is refused with a clear message instead of being applied
against the wrong meaning. A row whose `current` cell no longer matches the
catalogue is refused too, so a submission cannot silently overwrite a
translation that changed while the reviewer was working. Use `--force` only
when you have checked that the old basis still applies.

The reviewer may send the whole sheet or only the rows they changed. Both work,
but a filtered copy must keep the `current` and `english_hash` cells: they are
how the importer notices that the English or the translation changed while the
reviewer was working. Row order does not matter. New keys added to `english.tcl` after the sheet was
generated are not in it and are left untouched. Keys the catalogue has but
English no longer has appear at the bottom flagged `unknown`; the importer
warns about them and never writes them.

## What the importer validates

Before writing anything it checks the result can still be parsed, the key set
is complete, no key is duplicated, and the English order is intact. For each
changed row it checks:

- the English hash still matches (stale translations are refused);
- `%s`, `%d`, `%u`, `%02X`, `%%` and positional specifiers are preserved;
- `<b>`, `<a …>`, `<red>` and the other HTML tags are preserved;
- a menu label has no newline and its underline points at a letter;
- the value contains no NUL and no unbalanced Tcl word.

If any row fails, the file is not written. Fix those rows and send the sheet
again; one bad row does not silently stop the rest from being imported, but it
does stop a half-valid write.

## Review state

`reviewed=Y` is stored in `tcl/lang/reviews/<language>.json`, keyed by
`command:key`, with a hash of the English and the translation. A review stays
valid only while both strings are unchanged. Change either one and the next
`generate` marks the row unreviewed again. That is the honest signal for an
owner taking over a catalogue: unmarked is unreviewed, no guessing whether a
line came from Google Translate or a person.

`status` sums this per section:

```
francais: 2118 entries, 0 missing, 87 identical, 142 reviewed, 7/99 sections complete
```

`identical` is useful as a first review queue, but not every hit is wrong:
`ECO`, `PGN`, `Elo`, proper names and the opening names are legitimately the
same in many languages.

## Help pages

The help pages in `tcl/help/` have their own workbench, with the same
generate / import / status flow and a `check` command:
[HELPTOOL](HELPTOOL.md), `python3 tcl/lang/helptool.py generate <name>`. Its
rows are paragraphs and list items instead of keys, and the markup (links,
bold, menu names) stays in the cell so a translator can move it.

## Portuguese

`tcl/lang/portbr.tcl` is the existing Portuguese catalogue and uses Brazilian
usage. A European Portuguese contributor may work in it; the translation will
contain a mix of both variants for now. That is accepted as an improvement over
machine translation, and the same CSV workflow applies. If the file later
needs to be split into `pt-BR` and `pt-PT`, the new-language checklist in
[ADDING_A_LANGUAGE.md](../../docs/ADDING_A_LANGUAGE.md) covers it.

## Maintainer workflow

1. Add new English keys and, if desired, a machine-translation draft.
2. `generate` the language sheet and send it to the owner.
3. The owner returns the sheet, whole or partial.
4. `import --dry-run` to review the diff; `--apply` to write. Run one import
   at a time; the catalogue is under git, so a lost run is recoverable, but
   there is no cross-process lock.
5. Commit with the owner’s credit (for example `Co-authored-by:`), run
   `tcl/lang/checklangs.tcl <language>` and the Tcl harnesses, then merge.

The language file remains the runtime source of truth; the CSV is a review
surface, not a second catalogue. `checklangs.tcl` still catches missing,
out-of-order and duplicate entries after an import.
