# Third-party notices

scidCommunity is free software under the GNU General Public License, version 2
or later (`COPYING`). Parts of the Game Review/coach layer are adapted from
other free-software projects; this page records which parts and under which
licence.

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

The Game Review report and the facts and prompts the coach layer uses are
adapted from David Crandall's `game-review` plugin for scid, which is
GPL-2.0-or-later like this project:

| File | Adapted from |
| --- | --- |
| `tcl/tools/review_report.tcl` | the report figures and the phase split; **`mixedness` and `_mixedScore` are ported verbatim** from `11_cr_classify.tcl` |
| `tcl/tools/review_coach.tcl` | `15_cr_llm.tcl` (summary/phase/moment prompts and facts), `17_cr_facts.tcl` (move facts) |
| `tcl/tools/review_threat.tcl` | `15_cr_llm.tcl` (the "What's the threat?" probe) |
| `tcl/tools/comment_facts.tcl` | `17_cr_facts.tcl` |

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

## Other references

The reference-coding workflow and the indexed peer projects are described in
`docs/REFERENCE_CODING.md`. Those projects are read for design, not copied;
where a passage was adapted, the file that carries it says so.
