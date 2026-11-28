# Third-party notices

scidCommunity is free software under the GNU General Public License, version 2
or later (`COPYING`). Parts of it are adapted from other free-software projects;
this page records which parts and under which licence.

## Patzer — MIT

The deterministic move facts and the label/accuracy rules are adapted from
Patzer's `coach/tactics.ts`, `server/src/chess/classifier.ts`, `keyMoments.ts`
and `accuracy.ts`:

| File | Adapted from |
| --- | --- |
| `tcl/tools/comment_facts.tcl` | Patzer `coach/tactics.ts` (move motifs, facts) |
| `tcl/tools/move_labels.tcl` | Patzer `classifier.ts` (label ladder) |
| `tcl/tools/review_report.tcl` | Patzer `classifier.ts`, `accuracy.ts`, `keyMoments.ts` (through the two files above) |

Patzer is MIT-licensed, © Arsen Apostolov and contributors. The full MIT
permission notice is reproduced at the top of `tcl/tools/comment_facts.tcl` and
`tcl/tools/move_labels.tcl`.

## Lichess accuracy method

The win-percentage and move-accuracy formulas in `tcl/tools/accuracy.tcl`
follow the method Lichess publishes for its accuracy figures. No Lichess source
code is included; only the published formula is implemented.

## David Crandall's game-review plugin — GPL-2.0-or-later

The Game Review report and the facts the coach layer uses are adapted from David
Crandall's `game-review` plugin for scid, which is GPL-2.0-or-later like this
project:

| File | Adapted from |
| --- | --- |
| `tcl/tools/review_report.tcl` | the report figures and the phase split; **`mixedness` and `_mixedScore` are ported verbatim** from `11_cr_classify.tcl` |
| `tcl/tools/review_coach.tcl` | `15_cr_llm.tcl` and `17_cr_facts.tcl` (the game-level facts, the phase facts and the prompt texts) |
| `tcl/tools/comment_facts.tcl` | `17_cr_facts.tcl` |
| `tcl/tools/review_threat.tcl` | the threat probe: `review-coach-prototype` (5556eb44), itself from `15_cr_llm.tcl` |

`review_threat.tcl` is a port, not a copy: the prototype branch is a design
reference and is not a merge candidate (#404), so the probe was re-derived
against this tree's own `::facts` vocabulary, `::engineNoWin` and the reply
guard from #423. The one-shot shape - open, one `Go`, close in the reply - is
the prototype's, and the provenance is recorded here because the shape is what
was taken.

`mixedness` is the one verbatim copy: `::reviewreport::mixedness` and
`::reviewreport::_mixedScore` reproduce `::crclass::mixedness` and
`::crclass::_mixedScore` from `plugins/game-review/11_cr_classify.tcl` line for
line, so that a position scores the same here as it does there. The board is
read through this project's own `chessboard.tcl`, and the file header of
`review_report.tcl` says so.

The plugin is the reference for the facts-first design, not a runtime
dependency. The phase rule is deliberately this project's own: the plugin's
back-rank count and its material cut are not how this report decides that an
opening has ended. See `docs/review-ui.md`.

## `review-coach-prototype` branch — same licence (GPL-2.0-or-later)

`tcl/tools/review_verify.tcl` was re-derived from the prototype on the upstream
`review-coach-prototype` branch (`5556eb44`, tcl/tools/review_verify.tcl), which
is part of this project and carries this project's licence — no new licence
obligation arises, but the debt is recorded rather than left implicit:

| File | Taken from the prototype |
| --- | --- |
| `tcl/tools/review_verify.tcl` | `::reviewverify::topMove` reproduces the prototype's function verbatim (the first move of a MultiPV line dict); `jobs`/`corrections` keep the prototype's two-step shape and its names |

Everything else is this tree's own: the prototype opens a private connection
through `::engineNoWin` and downgrades a label when the second engine answers
nothing, while this file searches through `::reviewdriver::start` (connection 20,
the pass's own queue), gates on the book, reads the Great gap from
`::movelabels::GREAT_GAP` instead of a copied 200 cp, and leaves the label alone
when the second engine has no usable answer. The prototype is a design reference
and not a merge candidate (#404).

## CQL engine — GPL-2.0-or-later

`src/cql/` is the CQL (Chess Query Language) engine of Lewis Stiller and Gady
Costeff, imported from Scid vs. PC (r3777) and modernised for C++20 here. CQL is
GPL, as its own notice states, so adapting it into this tree adds no new licence
condition; it is recorded here because its copyright holders are not this
project's:

| File | Adapted from |
| --- | --- |
| `src/cql/README.md` | provenance of the whole directory: the source revision, what was not imported, the deviations made here, and the re-sync recipe |
| `src/cql/COPYING` | CQL's own notice, reproduced verbatim (Stiller and Costeff; Lionel Hampton's porting changes) |
| `tcl/search/cql_kit.tcl` | the CQL window's building blocks - the tabs, the block names, their queries and their value ranges - from Scid vs. PC's `tcl/search/board.tcl` |

Every file in `src/cql/` carries `SPDX-License-Identifier: GPL-2.0-or-later`,
and every imported file names Scid vs. PC as its origin.

## oschess-cb-bridge v1.0.3 — MIT

The ChessBase 2CBH reader (`src/cb2_*.h`, `src/cb2_*.cpp`, `src/codec_cb2.h`,
`src/codec_cb2.cpp`) ports the 2CBH layout from oschess-cb-bridge
(<https://github.com/asavis/oschess-cb-bridge>), **release v1.0.3 only**: tag
object `b5c18be3781e8cbb304f6d08753a8cb10efd6f80`, commit
`bffebfc498d52b4e4631aed32b2f8e8194d125ff`. That release is MIT-licensed, as
its `LICENSE` and `Cargo.toml` state; later releases of that project are under
another licence, and nothing from them is used here.

| Part of the reader | Ported from (v1.0.3, `crates/cbformat/src/`) |
| --- | --- |
| record frames and their checksum | `v2/frame.rs` |
| header record fields, result, ECO, date | `v2/record.rs`, `game/fields.rs` |
| `.2lid` entity table | `v2/entities.rs` |
| move words, set-up piece words, start section | `movetable/`, `v2/moves.rs` |
| move-tree walk and its checks | `replay/mod.rs` |
| annotation types and their sizes | `v2/annotations/`, `game/annotations/` |
| quotation text, as ChessBase writes it | `game/annotations/quote.rs` |
| Windows-1252 decoding of non-UTF-8 text | `codepage.rs` |

Not taken from it: the variable header-record size (192 or 208 bytes) and the
game-quotation strings that ChessBase 2027 databases fill. Those come from our
own measurements of real databases and are written as format facts in the code.

The classic CBH reader (`src/cbh_*.h`, `src/cbh_*.cpp`, and the part of
`src/codec_cb2.cpp` that walks a classic game) ports the CBH layout of the same
release:

| Part of the reader | Ported from (v1.0.3, `crates/cbformat/src/`) |
| --- | --- |
| database files and header records | `cbh/mod.rs`, `cbh/record.rs` |
| 64-bit offsets of `.cbj` | `cbh/wide.rs` |
| player, tournament and annotator files, their text fields | `cbh/entities.rs`, `cbh/bytes.rs` |
| move record and start position | `cbh/moves.rs` |
| move decoding tables | `cbh/tables.rs` (copied byte for byte) |
| piece lists | `cbh/pieces.rs` |
| move decoding, tree walk and missing castling rights | `cbh/decode.rs` |
| annotation records | `cbh/annotations.rs` |

Every ported file carries `SPDX-License-Identifier: GPL-2.0-or-later` and the
line "2CBH layout" or "CBH layout derived from oschess-cb-bridge v1.0.3 (MIT),
commit bffebfc4". The MIT notice of v1.0.3, reproduced as its `LICENSE` file
states it:

```text
MIT License

Copyright (c) 2026 the oschess-cb-bridge contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Neither this project nor oschess-cb-bridge is affiliated with ChessBase GmbH.

## Other references

The reference-coding workflow and the indexed peer projects are described in
`docs/REFERENCE_CODING.md`. Those projects are read for design, not copied;
where a passage was adapted, the file that carries it says so.
