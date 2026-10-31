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

The Game Review coach layer is adapted from David Crandall's `game-review`
plugin for scid, which is GPL-2.0-or-later like this project:

| File | Adapted from |
| --- | --- |
| `tcl/tools/review_coach.tcl` | `15_cr_llm.tcl` (summary/phase/moment prompts and facts), `17_cr_facts.tcl` (move facts) |
| `tcl/tools/review_threat.tcl` | `15_cr_llm.tcl` (the "What's the threat?" probe) |
| `tcl/tools/review_report.tcl` | the report figures and phase split |
| `tcl/tools/comment_facts.tcl` | `17_cr_facts.tcl` |

The plugin is the reference for the facts-first design, not a runtime
dependency. The phase-boundary rule is deliberately this project's own; see the
note in `review_coach.tcl` about the plugin's initial-position case.

## Other references

The reference-coding workflow and the indexed peer projects are described in
`docs/REFERENCE_CODING.md`. Those projects are read for design, not copied;
where a passage was adapted, the file that carries it says so.
