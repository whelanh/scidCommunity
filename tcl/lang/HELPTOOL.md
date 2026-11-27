# Reviewing a language's help pages with one CSV

`tcl/lang/helptool.py` does for the help pages (`tcl/help/help.tcl` and its
translations `helpF.tcl`, `helpPL.tcl`, …) what
[langtool](LANGTOOL.md) does for the interface catalogues: it turns a
language's help into one spreadsheet, and imports the returned sheet. A native
speaker can open it in any spreadsheet program, translate whatever they want,
leave the rest alone, and send it back. Nothing is replaced wholesale: only the
blocks whose `new` cell is filled are written.

The tool needs Python 3.8 or later and nothing else. Run it from the
repository root or pass `--root`.

```sh
# One sheet with every page of the language's help:
python3 tcl/lang/helptool.py generate francais -o help-francais.csv

# Only some pages, or only what is not reviewed yet:
python3 tcl/lang/helptool.py generate francais --pages Moves,Searches -o moves.csv
python3 tcl/lang/helptool.py generate francais --unreviewed -o todo.csv

# See what would change, without writing:
python3 tcl/lang/helptool.py import francais help-francais.csv --dry-run

# Apply it:
python3 tcl/lang/helptool.py import francais help-francais.csv \
    --apply --reviewer "IttacusFc"

# Per-page coverage and review state, and a lint of the translated file:
python3 tcl/lang/helptool.py status francais
python3 tcl/lang/helptool.py check francais
python3 tcl/lang/helptool.py check --all
```

Use the catalogue stem (`francais`, `polish`, `deutsch`), the same one
`langtool.py` takes.

## The unit is a block

A help page is prose with markup, so there is no key to hang a translation on.
The sheet cuts every page into **blocks**: a heading, a paragraph, a list
item, the footer line. One block is one row. The page title is its own row
(`Page#0`).

```
page,key,kind,english,current,new,reviewed,…
Contents,Contents#44,li,"<a Pgnscid><b>Pgnscid</b>: converting <a PGN>PGN</a> files</a>","<a Pgnscid>…",,,
```

The page structure always comes from English: you translate the *text of a
block*, you do not add, remove or reorder blocks. The tool puts each block back
where it belongs.

## Moving links and other tags

The tags stay in the cell, because a link is part of the sentence. If the
English reads `<a PGN>PGN</a> files` and your language needs
`fichiers <a PGN>PGN</a>`, write exactly that. The importer checks that every
tag of the English block is still there, as many times as English has it,
and that nothing else was added. A tag pair may move as a whole, but each
closing tag must still come after its opening one, and every link must be
closed inside its own block: `</a>fichiers<a PGN>` is refused.

| You may | You may not |
| --- | --- |
| Move `<a PGN>PGN</a>` or `<b>…</b>` anywhere in the sentence | Delete a tag, or its closing partner, or put a closing tag before its opening one |
| Translate the text *between* tags: `<a Moves>coups</a>` | Change what is *inside* the opening tag: `<a Moves>`, `<button tb_coords>`, `<name Mistakes>` |
| Change the words of a `<menu>…</menu>` | Add a tag English does not have |
| | Use `{`, `}` or a final `\` unless English does |

Words inside `<menu>…</menu>` should be what the menu really says in your
language's interface; copy them from the program.

One cell is one block. Line breaks inside a cell are ignored and the tool
re-flows the text into the file, so write each paragraph or list item in its
own row and do not try to add a paragraph by typing an empty line.

## The sheet

| Column | Meaning |
| --- | --- |
| `page` | The help page, e.g. `Moves`. Filter on this to work on one page |
| `key` | `Page#N`, the block's place on the page (`#0` is the title); do not edit |
| `kind` | `h1`, `h3`, `p`, `li`, `footer` or `title`; informational |
| `english` | The English block |
| `current` | The translation in the file now; leave it as it is |
| `new` | **The translator writes here.** Blank means keep `current` |
| `reviewed` | `Y` means “I checked this translation”; `N` clears an earlier review; blank keeps it |
| `reviewer` | The person who reviewed the row |
| `notes` | Free text; ignored by the importer |
| `flags` | `missing`, `identical`, `extra` (and `unknown-page`); informational (below) |
| `source_line` | The line in `help.tcl`; technical |
| `english_hash` | Technical stale-basis check; keep it, do not edit |

The `flags` tell you where to look first:

- **`missing`**: the translated file has no block for this English one. The
  `current` cell is empty. Fill `new` and the block is added next to its
  neighbours. A whole page can be missing (about nine are, in the machine
  translations): translate its title and as many blocks as you like, and the
  page is created; the blocks you leave out stay in English.
- **`identical`**: the translation is the English text, i.e. it was never
  translated. Often a name or a list of keys, and then that is right.
- **`extra`**: the file has a block English no longer has, left over from an
  older version of the page. The `english` cell is empty. Write `DELETE` in
  `new` to remove it. (Any other text in `new` is ignored for these rows.)

You may send the whole sheet or only the rows you worked on. Keep `current`
and `english_hash` for the rows you send: they are how the importer notices
that the English or the translation changed while you were working. Save as
**CSV UTF-8** (in Excel: “CSV UTF-8”, not plain “CSV”).

## Two spreadsheet traps

- A cell that starts with `=`, `+`, `-` or `@` is read as a formula by Excel
  and LibreOffice (a few list items such as `= : [=][Return]` or the `- …`
  bullets of the EPD page start that way). If you type a translation that
  starts with one of these characters, put a space in front of it: the
  importer ignores leading spaces. If the program shows `#NAME?` in a
  `current` cell, **delete that row from the sheet you send back**. Leaving
  `new` blank is not enough: a row marked `reviewed` is still checked, and
  the importer refuses a row whose `current` no longer matches the file, and
  while any row is refused it writes nothing from the sheet. Nothing is
  damaged, but your other rows wait. If you would rather keep the row, clear
  `reviewed` and leave `new` blank. The maintainer can also apply such a
  row with `--force` after looking.
- Save as **CSV UTF-8**. Plain “CSV” in Excel turns accented letters into
  question marks.

## How a translation is matched to English

Some translated pages have drifted from English: a bullet was added upstream
after the machine translation was made, or a translator rearranged a page. So
the tool does not rely on position alone. It cuts the translated page into
blocks the same way, then finds the best pairing using what survives
translation: the link targets (`<a Moves>`), button names, numbers, acronyms
(`PGN`, `ECO`) and key names. A block that cannot be paired with confidence is
**left unpaired** rather than guessed: it shows as `missing` (English side) or
`extra` (translation side), and **the importer never overwrites a block it
could not pair**. After you fill a `missing` row, the next `generate` pairs it
exactly.

An English block that changes after a sheet was made is refused on import
(“English changed since the CSV was generated”), because the translation
was made against other words. If the block only moved because another block
was inserted above it, the importer finds it again by its hash and applies it.

## What the importer validates

Before writing anything it checks the result can still be read: every page
still parses, no page lost a block it had, and each changed row:

- keeps the English block's tags (see above);
- has balanced braces (the file is Tcl) and no stray control characters;
- is based on the `current` text the file still has.

If any row fails, nothing is written. Fix the rows and send the sheet again.
The file's line endings (LF or CRLF) are kept, and an edited block is written
back in the style of the file: one line if it was one line, filled to about 88
columns if it spanned several.

## Review state

`reviewed=Y` is stored in `tcl/lang/reviews/help-<language>.json`. A record is
the hash of the English block and the hash of its translation, and it holds for
that pair only: change either one and the next `generate` shows the row
unreviewed again. Records follow the *content*, not the position, so an English
paragraph inserted in the middle of a page does not make every block after it
look unreviewed.

`status` sums this per page:

```
francais: 1919 blocks in 71 pages, 242 missing, 320 identical, 10 not in English, 0 reviewed, 0/71 pages complete
```

## check

`check` lints a translated help file against English, without a sheet:
a block that lost a tag (the machine translation drops `<b>` and `<menu>`
pairs), a `</a>` with no `<a>` (the bug that once left a whole tip underlined),
a page with no title, a link to a page that does not exist, and the pages and
blocks English has but the translation lacks. It exits 1 when it finds a
problem. `check --all` prints one line per language.

## Maintainer workflow

1. Edit `tcl/help/help.tcl` as usual. Translations are not touched.
2. `generate` the language's sheet (a few `--pages` are enough for a first
   pass) and send it to the owner.
3. The owner returns the sheet, whole or partial.
4. `import --dry-run` lists every change it would make, one line per block
   (the start of the old and the new text; it is not a diff), together with
   any refused rows; `--apply` writes. Read the real diff with `git diff`
   afterwards. Run one import at a time; the file is under git, so a lost
   run is recoverable. If the help file cannot be written, the review state
   is already saved: the message says so, and running the same import again
   finishes the job.
5. Commit with the owner's credit (for example `Co-authored-by:`), run
   `python3 tcl/lang/helptool.py check <language>` and
   `tclsh tests/tcl/help_keys.tcl`, then merge.

The help file remains the runtime source of truth; the CSV is a review surface,
not a second copy. The tool's own tests run with
`python3 tcl/lang/helptool.py selftest`.
