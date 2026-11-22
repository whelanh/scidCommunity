# Adding or maintaining an interface language

scidCommunity ships one Tcl file per interface language in `tcl/lang/`. A
catalogue translates the labels, menu text and message strings the program
asks for; anything it leaves out falls back to English, so a partial
translation is usable and can be improved over time.

This page is the checklist for a new language and for keeping an existing one
in step with `english.tcl`. The Danish catalogue (PR #538) is a worked example
of every step below.

## 1. Pick the language letter

The letter is the identifier used in the catalogue (`translate d …`,
`menuText d …`), in `addLanguage`, and in the runtime switches. It is
case-sensitive: `D` is Deutsch and `d` is Dansk, and both exist.

Look at the `addLanguage` lines at the end of `tcl/language.tcl` and choose a
letter that is not in use. Keep the line in menu order (the list is not sorted
by letter).

## 2. Create the catalogue

Copy the shape of an existing catalogue, or start from a new file:

```tcl
# <Language> interface translations. Follow the entry order in english.tcl.
proc setLanguage_<letter> {} {

# File menu:
menuText <letter> File "Fil" 0 {…}
…
translate <letter> SomeMessage {…}
}
```

Rules that matter:

- **One entry per `english.tcl` entry, in the same order.** `english.tcl` is the
  source of truth for the key names and their order; a catalogue that is out of
  order still loads, but `checklangs.tcl` will report it and the maintenance
  tools rely on the order to insert new keys.
- **Translate the text only, never the key.** Keys (`FileOpen`, `MoveLabelBlunder`,
  …) are API; changing one silently drops the translation.
- **Keep every `format` placeholder** (`%s`, `%d`, `%u`, `%02X`, …). The English
  string shows which ones a key takes. A missing or extra placeholder can make
  the window raise when the message is built.
- **`menuText` takes four or five arguments:** language, key, label, the index
  of the character to underline, and an optional tooltip. The index counts
  characters from 0 and must point at a letter in the label (not a space or
  punctuation). Leave the tooltip out only when English does.
- **Use braces for text.** `translate d Foo {text with "quotes" and (parens)}`
  is safe. A quoted value is evaluated when the language is selected, so it must
  not contain `$`, `[` or `\` unless they are meant as Tcl syntax.
- **`\n` is a newline in `translate` entries.** `translate` converts the two
  characters `\n` to a newline; a real newline inside braces works too.
  `menuText` does not convert it, so menu labels and tooltips use real text.
- **Encoding is UTF-8 without a BOM**, and the file is listed as `utf-8` in
  `addLanguage`.

`tcl/lang/propagatelang.tcl` fills in every key the catalogue is missing,
copying the English entry in the right position under a
`# ====== TODO To be translated ======` line. Register the language in its
`encodings`, `codes` and `languages` arrays first, then run:

```sh
cd tcl/lang
tclsh propagatelang.tcl <name>
```

`tcl/lang/removedeadlang.tcl` removes entries whose key is no longer in
`english.tcl`, and `tcl/lang/checklangs.tcl` reports missing or out-of-order
entries:

```sh
tclsh checklangs.tcl <name>
tclsh removedeadlang.tcl <name>
```

Add the language to both tools' arrays (`encodings`, `codes`, `languages`) so
that the default all-language runs include it too.

## 3. Register it in the program

In `tcl/language.tcl`:

```tcl
addLanguage d Dansk 1 utf-8 danish.tcl
```

The arguments are letter, the name shown in **Options → Language** (in the
language itself), underline index, encoding and filename.

If the language uses different piece letters (Dansk: `K` king, `D` queen, `T`
rook, `L` bishop, `S` knight, `B` pawn), add the two maps next to the other
`transPieces`/`untransPieces` entries:

```tcl
set transPieces(d)   { P B K K Q D R T B L N S }
set untransPieces(d) { B P K K D Q T R L B S N }
```

These are `from to` pairs for each piece. `trans` is used when displaying moves
and `untrans` when reading a move the user typed, so both are needed for local
notation to work in both directions. Then add the letter to the `sc_info
language` `switch` in **both** `setLanguage` and `setLanguageTemp`.

For a single-byte Latin alphabet the C side needs the same map, in
`src/game.cpp` (`langPieces[]`, with a new index in the comment above and a
matching `sc_info language` code in `src/tkscid.cpp`). Multi-byte scripts
(Greek, Hebrew, Chinese, Korean, Bulgarian, …) leave the C entry empty and rely
on the Tcl map.

## 4. The smaller registries

- `tcl/tools/review_coach.tcl`, `answerLanguage`: the English name of the
  language, so the AI coach writes its answer in that language.
- `tcl/tools/pinfo.tcl`, `ReplaceIDTags`: the Wikipedia language code (for
  example `da`), if the language has a Wikipedia.
- `tcl/help/help<LETTER>.tcl`: optional translated help pages. Without one the
  help window uses the English pages.

## 5. Run the checks

```sh
tclsh tests/tcl/language_catalogues.tcl   # files and addLanguage agree
tclsh tests/tcl/move_labels.tcl           # the eleven move labels
tclsh tests/tcl/review_ui.tcl             # the review window keys
tclsh tests/tcl/training_menu.tcl         # the Training menu keys
tclsh tcl/lang/checklangs.tcl <name>
tclsh tcl/lang/removedeadlang.tcl <name>
```

`tests/tcl/tactics_trainer.tcl` also reads every catalogue; it needs Tk, so run
it under `xvfb-run -a wish` on a machine without a display.

The harnesses read the language list from `addLanguage`, so a new catalogue is
covered without editing the tests. `tests/tcl/lang_registry.tcl` is the shared
reader they use.

## 6. Reviewing a new catalogue

A quick local review catches most mistakes:

```sh
# same keys, same order, no duplicates
tclsh tcl/lang/checklangs.tcl <name>

# nothing dead, nothing missing from English
tclsh tcl/lang/removedeadlang.tcl <name>

# every menu mnemonic points at a letter
grep -n '^menuText <letter> ' tcl/lang/<name>.tcl
```

Open the Language menu after switching to the new language and check a few
high-traffic windows (File, Options, a game list, the PGN window, a dialog with
buttons). A label that shows an English word is a reminder that its key is
missing, not that the catalogue failed to load.

If you are adding a new *English* key, add it to `english.tcl` in its proper
section, run `propagatelang.tcl` for every language, and translate at least the
English text in the other catalogues' TODO blocks as time allows. The review
keys in `tests/tcl/review_ui.tcl` are checked in every catalogue, so a new one
there is expected to arrive with all of them.
