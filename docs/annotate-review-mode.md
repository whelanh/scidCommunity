# Annotate as a review mode

The annotate menu runs the classic autoplay annotator
(`tcl/tools/analysis.tcl`: `configAnnotation`, `annotateMode`, `addAnnotation`,
`markExercise`, `bookAnnotation`). A review mode now exists beside it:
`::reviewannotate` (`tcl/tools/review_annotate.tcl`) runs the same engine pass
the engine window's **Game Review** runs — `::reviewdriver` — and writes its
result into the game with the review's writer instead of the classic loop's.

The annotate dialog's OK button now starts that pass (`::reviewannotate::run`),
so the review writer is reachable for one game, a range of games, and the opening
errors finder. The classic pipeline is still shipped and still in `analysis.tcl`;
it is retired only after the parity gate below passes, which is a separate change
and needs the maintainer's approval for any artefact that differs. Since this
wiring, nothing in the UI starts the classic loop.

## The dialog is the entry point

`configAnnotation {n}` is opened by pane `n`'s annotate button (the button is on
every pane, not only the first), and its OK turns the dialog's state into a run
with one pure decision:

    ::reviewannotate::dialogPlan <pane> <preset name> <is UCI> <settings>

That proc answers which engine, which `-bookEnd`, the batch range, the tier, and
the refusal when the pane cannot run a review. It is pure, so it is gated by
`tests/tcl/annotate_dialog.tcl` rather than by clicking a dialog.

- **The engine is the invoking pane's own preset** — `::enginecfg::get
  $::analysis(name$n)`, the entry the user chose when opening that pane. There is
  no picker and no second engine setting.
- **A non-UCI pane is refused before anything starts**, with the driver's own
  sentence (*the review needs a UCI engine*), and OK is disabled the way a
  non-UCI pane's tactical checkbox is.
- **The time spinner is `::review::movetime`**, shown in seconds: the same
  setting Review Settings shows, so the dialog and the settings cannot disagree
  about the pass's time cap. 0 means no cap of the review's own.
- **Tier 1 only.** The dialog pins the run's tier: with a provider configured,
  tier 2 (one sentence of prose per judged move) is still a separate change.
- **Every option the dialog had is kept**: all moves / blunders only, the
  blunder threshold, the book, mark tactical exercises, the Annotator tag, the
  batch range, and find opening errors. They reach the writer through the globals
  the classic loop read; nothing was dropped with the classic pipeline.
- **The White/Black filter and the variation length are read again**, the way the
  classic read them: the toggles decide which side's moves carry the engine's
  line as a variation (`::reviewannotate::variationAllowed`, on the mover's side),
  and *Variation length (moves)* clips every line to `moves * 2 - 1` plies
  (`::reviewannotate::clipLines`), the classic's own conversion. They ride in the
  plan (`white`, `black`, `varPlies`) and reach the writer with the run, so a
  second pass cannot overwrite them. What they do **not** do is suppress the
  label or the marks — the classic's side filter never did either.
- **"Annotate variations" is shown disabled**, with the reason on the dialog
  (*Variations: main line only (review mode)*). The review pass walks
  `sc_game UCI_mainLine`; entering a variation and annotating the moves inside it
  is not in the review layer, and a switch that silently did nothing would be
  worse than a switch that says why. Writing variations (the engine's line on a
  mistake, blunder or missed win) is `::review::variationWanted`'s job and has no
  switch here.

The batch is a chain of passes, one per game: the driver runs one pass at a time,
so `::reviewannotate::done` is the driver's completion hook (`-done`) and starts
the next game. Each game is borrowed with the shipped idiom (`sc_game push copy`
→ `load` → write → `save` → `pop`), so the base comes back where it was.

**Cancel is one button with a context label.** The status line shows the pass's
progress and one stop control: *Stop now* for a single game, *Stop after this
game* in a batch — flipping to *Stop now* once pressed. The annotate toolbar
button is that control while a pass is running. Stopping now writes nothing (the
driver's write phase only runs on the last reply). A pass also stops when another
game is opened, and a batch stopped that way saves nothing for the game it was
reading, leaves the base on the game that was opened and does not advance.

**Progress has no window of its own.** The pass reports `done/total` (and the
game number in a batch) on the board's status line. A read-only progress board
that walks the positions in its own window is a separate change (the review
progress board card); nothing here depends on a window being open.

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
  classic's `+-`/`+/-` quirk at the crushing threshold. It now delegates to
  `::review::scoreToNag`, because the engine window's Game Review writes the
  same assessment from its `[%eval]` (`game_review.tcl`); one table, so the two
  cannot disagree. The annotate writer follows the classic mode (all moves or
  blunders only); the engine window's review puts an assessment only on the
  moves it marks.
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

  The Game List's **Batch annotate** does not use that iterator or this writer:
  it keeps its parallel pipe search and calls `::reviewdriver::writeResults` per
  finished game, so it writes the engine-window review's annotations with Review
  Settings — label, `[%eval]`, the label's NAG, the position assessment on marked
  moves, `D` and variations — and deliberately not the classic `T`/`****D`, book
  or Annotator marks.

  A batch position can end its search with no scored line at all, which under a
  time cap is the likeliest way a move goes unjudged. Such a ply is written with
  no verdict and the game still counts as completed, so
  `::batch_annotate::unjudgedCount` counts it, per move and with the book range
  excluded, and the completion dialog reports
  `plies with no verdict: N` beside the game count; the games figure alone would
  say the batch finished cleanly.

  **Rapid annotate** (Ctrl+Shift+A) is a consumer too: it converts the scores the
  engine windows have already collected into the same results shape and calls
  `::reviewdriver::writeResults`. The graph keeps only the best line and only the
  positions it reached, so this is a quick pass rather than an exact copy of a
  depth-limited Game Review — labels and marks speak the same language, but there
  is at most one variation and no second-best comparison. `::batch_annotate::annotate_logic`
  is gone; the classic marks now live only in `analysis.tcl`/`reviewannotate`.

## Which moves get the marks

The review labels every judged move; the classic marks follow the annotate
dialog's mode, the same filter `analysis.tcl:826` applies:

- **all moves** — every judged move gets the label, its `[%eval]`, the NAG and
  the assessment; no diagram (that is a blunders-only mark);
- **blunders only** — only the moves whose drop is over `blunderThreshold`, plus
  the classic's two exemptions: a position that is already decided is left
  alone, and a mate-range position is marked even for a small drop (the classic's
  `abs(score) >= 327` clause). The `??` and `?` moves are both offered to the
  exercise gate; `?!` is only a mark.

In blunders-only mode the filter decides the **whole** write, not only the
marks: a move the mode does not annotate gets no label and no `[%eval]` either,
and one a previous all-moves pass left there is taken off. A sparse annotation
that still carried a verdict word on every move would not be sparse.

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
tclsh tests/tcl/annotate_dialog.tcl
tclsh tests/tcl/annotate_run.tcl
```

The writer tests are the per-writer red-first tests: NAG from a label, the
diagram in blunders-only mode, the T flag and the difficulty comment, the book's
two comments, and the blunders-only filter (a decided position is left alone, a
mate-range position is marked, and a `?` move is offered to the exercise gate).
`annotate_dialog.tcl` gates the dialog's decision and the sparse filter's effect
on the label, and `annotate_run.tcl` drives the whole run — plan, pass, write,
batch chain, Cancel — against a stub engine.

### Tier 2 is synchronous

`::auto_comment::query` runs `exec curl` on the calling thread, and the write
phase runs on the Tk event loop: one request per judged move, each blocking for
the provider's own timeout. Tier 2 is not wired to the dialog yet, and wiring it
needs batching (or a background worker and a progress dialog) before it is
offered — otherwise a slow provider freezes the window for the whole run.

## Not in this change

- **The classic pipeline is not deleted.** It goes only after the gate above
  passes on the merged tree, with any remaining difference approved. Since the
  dialog's OK was rewired, nothing in the UI reaches it.
- **Variations are not compared by the gate.** The fixture's two runs write no
  variations (the classic side has white/black annotations off, the review side
  has no blunder worth a line in the artefact the gate reads), because the
  artefacts the gate names — the diagram, the NAGs, the exercise — do not include
  them; variation insertion is covered by `tests/tcl/game_review.tcl`, and the
  dialog's side filter and length by `tests/tcl/annotate_run.tcl` (what the
  writer is handed, through the real plan and pass).
- **The progress board is a separate change.** The annotate run reports on the
  status line; a read-only board window that walks the pass's positions in its
  own window belongs to the review progress board card, and the run does not
  depend on it.
- **Tier 2 (AI prose) is a separate change.** The dialog pins tier 1, so a
  configured provider cannot put prose into a game from this button until the
  batching/worker problem in "Tier 2 is synchronous" is solved.
- **The dialog's short-annotation options are kept but do nothing new.**
  `::review::writeMove` writes the verdict word and the token whatever the
  side; the review's own write is the token, so "short annotations" and "add
  score" describe a classic comment format the review does not produce. Anything
  that has to change there is a separate change to `::review`, not to this
  wiring.
- **The White/Black filter and the variation length are wired** (above), so the
  only dialog control that is not is the disabled "Annotate variations" switch.
- **No new translatable strings beyond the two Cancel labels and the disabled
  switch's note.** `StopNow`, `StopAfterThisGame` and
  `AnnotateVariationsMainLineOnly` are in all 29 language files; the non-English
  files carry the English text, because a mistranslated label is worse than an
  untranslated one. The rest of what this writes is a mark or a token (`??`, `D`,
  `****D<n>`, `[%eval]`), not prose. The AI prompt is English by design — it is
  sent to a model, not shown to a reader.
