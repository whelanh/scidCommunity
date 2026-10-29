# Annotate as a review mode

The annotate menu runs the classic autoplay annotator
(`tcl/tools/analysis.tcl`: `configAnnotation`, `annotateMode`, `addAnnotation`,
`markExercise`, `bookAnnotation`). A review mode now exists beside it:
`::reviewannotate` (`tcl/tools/review_annotate.tcl`) runs the same engine pass
the engine window's **Game Review** runs — `::reviewdriver` — and writes its
result into the game with the review's writer instead of the classic loop's.

Nothing calls it yet: the annotate dialog still starts the classic autoplay, and
pointing its OK button at `::reviewannotate::start` is a separate change (see
"Not in this change"). The classic pipeline is still shipped and still reachable
too; it is retired only after the parity gate below passes, which is a separate
change and needs the maintainer's approval for any artefact that differs.

## Two tiers, one difference

| | tier 1 | tier 2 |
|---|---|---|
| label + `[%eval]` on every judged move | yes | yes |
| engine variations | yes | yes |
| NAGs, diagram tag, exercise, book comments | yes | yes |
| one sentence of AI prose per judged move | no | yes |

Tier 2 is chosen at run time: `::reviewannotate::tier` returns 2 when
`::auto_comment::providerReady` answers true, and 1 otherwise. Nothing else
changes between the tiers, and a failed prose request is dropped rather than
failing the run — prose is an extra, not part of the annotation.

## What the review writes that a label does not

A review writes a verdict word and a `[%eval]` token
(`::review::writeMove`). The classic annotator wrote marks, and those are the
part that other tools read, so they are written here too:

- **NAGs** — `::reviewannotate::nagForDrop` is the classic drop ladder, in
  centipawns, using the Informant thresholds (`tcl/options.tcl`,
  `informantDefaults`). `??`, `?`, `?!` for a drop, `!?` for a move better than
  the engine's line. `::reviewannotate::nagForLabel` is the other direction,
  from a verdict word, for callers that have no evaluation pair.
- **The position assessment** — `::reviewannotate::scoreToNag` writes `=`,
  `+/-`, `+-` … beside the verdict, as `analysis.tcl:942` did, including the
  classic's `+-`/`+/-` quirk at the crushing threshold.
- **The diagram tag** — `D`, in blunders-only mode, on the move *before* the
  annotated one (`::reviewannotate::markDiagram`). The RTF exporter renders the
  position after the NAG's own move (`tcl/file/rtf.tcl`, `collectLine_`), so
  that is the position the blunder was played in.
- **The exercise** — `::reviewannotate::markExercise` is a port of
  `analysis.tcl:536`: the game gets the `T` flag, the move gets
  `****D<difficulty> <before>-><after>`, and the difficulty comes from the same
  timing ladder (`::reviewannotate::difficulty`). `::reviewannotate::exerciseGames`
  is the T-flag filter that selects them.
- **The opening book** — `::reviewannotate::bookPass` writes "Out of book …" or
  "Last book move", and `::reviewannotate::findBookEnd` tells the pass where to
  stop skipping the opening. Both read the book the annotate dialog selected, so
  the existing book choice still applies.
- **Batch games and opening errors** — `::reviewannotate::games` is the game
  iterator the autoplay loop used to be, and
  `::reviewannotate::openingTag`/`appendAnnotator` write the `opBlunder` entry
  into the Annotator tag.

## Which moves get the marks

The review labels every judged move; the classic marks follow the annotate
dialog's mode, the same filter `analysis.tcl:826` applies:

- **all moves** — every judged move gets the NAG and the assessment; no diagram
  (that is a blunders-only mark);
- **blunders only** — only the moves whose drop is over `blunderThreshold`, plus
  the classic's two exemptions: a position that is already decided is left
  alone, and a mate-range position is marked even for a small drop (the classic's
  `abs(score) >= 327` clause). The `??` and `?` moves are both offered to the
  exercise gate; `?!` is only a mark.

A move that is not annotated in blunders-only mode can still carry `!?` when it
was better than the engine's line, as the classic branch did.

## The parity gate

`tests/tcl/annotate_parity.tcl` is the gate, and it is a test rather than a
judgement. One fixture game (a six-move Ruy Lopez with one two-pawn blunder) is
annotated twice, from the same engine evaluations:

1. by the classic pipeline — the real `addAnnotation`, driven one move at a time
   with the `$analysis(...)` figures the analysis window would have given it;
2. by the review — `::reviewannotate::writeResults`, from a `results` dict in
   the shape `::reviewdriver` collects.

Both runs write into the same stub game (`tests/tcl/game_stub.tcl`), and the
artefacts are read back through the exporters that consume them: the RTF
exporter's own walk (`::rtf::collectGame`) with its NAG rendering and its
diagram gate, the T flag, and the `****D<difficulty>` comment. The test asserts
they are equal, and asserts the one intended difference — the review also writes
its label and `[%eval]`, which the classic never did — so a reader does not have
to diff two artefacts to find it.

Run it with:

```
tclsh tests/tcl/annotate_parity.tcl
tclsh tests/tcl/annotate_writers.tcl
```

The writer tests are the per-writer red-first tests: NAG from a label, the
diagram in blunders-only mode, the T flag and the difficulty comment, the book's
two comments, and the blunders-only filter (a decided position is left alone, a
mate-range position is marked, and a `?` move is offered to the exercise gate).

### Tier 2 is synchronous

`::auto_comment::query` runs `exec curl` on the calling thread, and the write
phase runs on the Tk event loop: one request per judged move, each blocking for
the provider's own timeout. Tier 2 is not wired to the dialog yet, and wiring it
needs batching (or a background worker and a progress dialog) before it is
offered — otherwise a slow provider freezes the window for the whole run.

## Not in this change

- **The annotate dialog still starts the classic autoplay.** Pointing its OK
  button at `::reviewannotate::start` needs a decision the code cannot make: the
  dialog collects a per-move delay, an all-moves/blunders-only mode, a variation
  length and a book, and a review pass has no per-move delay. Which of those the
  dialog keeps, and which engine preset the pass uses, is the maintainer's call.
- **The classic pipeline is not deleted.** It goes only after the gate above
  passes on the merged tree, with any remaining difference approved.
- **Variations are not compared by the gate.** The fixture's two runs write no
  variations (the classic side has white/black annotations off, the review side
  has `var_lines 0`), because the artefacts the gate names — the diagram, the
  NAGs, the exercise — do not include them; variation insertion is covered by
  `tests/tcl/game_review.tcl`.
- **No new translatable strings.** The two comments the book writes reuse
  `MoveOutOfBook` and `LastBookMove`, which every language file already carries;
  the rest of what this writes is a mark or a token (`??`, `D`, `****D<n>`,
  `[%eval]`), not prose. The AI prompt is English by design — it is sent to a
  model, not shown to a reader.
