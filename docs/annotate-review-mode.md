# Annotate as a review mode — a historical note

> **Status: historical (2026-11-14).** The legacy Annotate dialog is **gone**.
> The Analysis window that held it was retired by
> [#436](https://github.com/whelanh/scidCommunity/issues/436) item 3, and
> [#437](https://github.com/whelanh/scidCommunity/issues/437) §5 deleted the
> module behind it (`tcl/tools/analysis.tcl`) and the review-annotate run it
> started — `::reviewannotate::run`, its dialog plan, its batch chain and its
> Cancel state. Nothing in the UI opens `configAnnotation`.
>
> The live annotation paths are **Game Review**, the Game List's **Batch
> annotate** and **Rapid annotate**, all writing through
> `::reviewdriver::writeResults` with **Review Settings** (including *Find
> opening errors* and *Mark tactical exercises*). `docs/review-ui.md` is the
> description of that surface; this file is the record of the pipeline that was
> replaced, kept because the marks it wrote are still written and their
> provenance matters.
>
> **What survives of the module.** `tcl/tools/review_annotate.tcl` is no longer
> a run; it is two writers and their helpers — `::reviewannotate::writeTactical`
> (`tcl/tools/review_annotate.tcl:139`, the `T` flag and `****D<difficulty>`) and
> `::reviewannotate::openingMark` (`:236`, the `opBlunder` entry of the Annotator
> tag). They are reached only from `::reviewdriver::writeResults`, behind
> `info commands` guards (`tcl/tools/review_driver.tcl:1425`, `:1469`), which is
> exactly what Review Settings' two switches turn on. `tests/tcl/review_marks.tcl`
> pins them.
>
> The harnesses that gated the old pipeline — `annotate_dialog`,
> `annotate_dialog_syntax`, `annotate_run`, `annotate_cancel`,
> `annotate_writers`, `annotate_parity` — were deleted in #437 §5 with their
> subject. The commands below are history, not instructions.

## The two paths, before the retirement

Before #436, the annotate menu ran the classic autoplay annotator
(`tcl/tools/analysis.tcl`: `configAnnotation`, `annotateMode`, `addAnnotation`,
`markExercise`, `bookAnnotation`) — a loop that searched each position, waited
on the shared engine array, and wrote marks as it went. A review mode existed
beside it: `::reviewannotate` (`tcl/tools/review_annotate.tcl`) ran the same
engine pass the engine window's **Game Review** runs — `::reviewdriver` — and
wrote the result into the game with the review's writer instead of the classic
loop's.

The annotate dialog's OK started that pass (`::reviewannotate::run`), so the
review writer was reachable for one game, a range of games, and the opening
errors finder. Both paths read the same Review Settings from #436 item 2
onwards, which is why retiring the dialog cost no feature: the switches stayed,
the dialog did not.

## The retired dialog

`configAnnotation {n}` was opened by pane `n`'s annotate button, and its OK
turned the dialog's state into a run with one pure decision:

    ::reviewannotate::dialogPlan <pane> <preset name> <is UCI> <settings>

That proc answered which engine, which `-bookEnd`, the batch range, the tier, and
the refusal when the pane could not run a review. It was pure, which is why it was
gated by a harness (`tests/tcl/annotate_dialog.tcl`) rather than by clicking a
dialog.

- **The engine was the invoking pane's own preset** — `::enginecfg::get
  $::analysis(name$n)`, the entry the user chose when opening that pane. No
  picker, no second engine setting.
- **A non-UCI pane was refused before anything started**, with the driver's own
  sentence (*the review needs a UCI engine*), and OK was disabled the way a
  non-UCI pane's tactical checkbox is.
- **The time spinner was `::review::movetime`**, shown in seconds: the same
  setting Review Settings shows, so the dialog and the settings could not
  disagree about the pass's time cap. 0 meant no cap of the review's own.
- **Every option the dialog had was kept**: all moves / blunders only, the
  blunder threshold, the book, mark tactical exercises, the Annotator tag, the
  batch range, and find opening errors.
- **The White/Black filter and the variation length were read again**, the way
  the classic read them: the toggles decided which side's moves carried the
  engine's line as a variation (`::reviewannotate::variationAllowed`), and
  *Variation length (moves)* clipped every line to `moves * 2 - 1` plies
  (`::reviewannotate::clipLines`). They rode in the plan (`white`, `black`,
  `varPlies`) and reached the writer with the run.
- **"Annotate variations" was shown disabled**, with the reason on the dialog
  (*Variations: main line only (review mode)*): the pass walked
  `sc_game UCI_mainLine`, and a switch that silently did nothing would have been
  worse than a switch that said why.

The batch was a chain of passes, one per game: the driver runs one pass at a time,
so `::reviewannotate::done` was the driver's completion hook (`-done`) and started
the next game. Each game was borrowed with the shipped idiom (`sc_game push copy`
→ `load` → write → `save` → `pop`), so the base came back where it was.

**Cancel was one button with a context label.** The status line showed the pass's
progress and one stop control: *Stop now* for a single game, *Stop after this
game* in a batch — flipping to *Stop now* once pressed. Stopping now wrote
nothing (the driver's write phase only runs on the last reply). A pass also
stopped when another game was opened, and a batch stopped that way saved nothing
for the game it was reading, left the base on the game that was opened, and did
not advance.

## What the writer wrote that a label does not

A review writes a verdict word and a `[%eval]` token
(`::review::writeMove`). The classic annotator wrote marks, and those are the
part other tools read, so the review writer writes them too — the two that need
no dialog are the ones that survive in `review_annotate.tcl`:

- **NAGs** — a drop ladder in centipawns using the Informant thresholds
  (`tcl/options.tcl`, `informantDefaults`): `??`, `?`, `?!` for a drop, `!?` for a
  move better than the engine's line.
- **The position assessment** — `=`, `+/-`, `+-` … beside the verdict, including
  the classic's `+-`/`+/-` quirk at the crushing threshold. It now delegates to
  `::review::scoreToNag`, because the engine window's Game Review writes the same
  assessment from its `[%eval]` (`tcl/tools/game_review.tcl`); one table, so the
  two cannot disagree.
- **The diagram tag** — `D`, in blunders-only mode, on the move *before* the
  annotated one. The RTF exporter renders the position after the NAG's own move
  (`tcl/file/rtf.tcl`, `collectLine_`), so that is the position the blunder was
  played in.
- **The exercise** — `::reviewannotate::writeTactical` (`:139`): the game gets the
  `T` flag, the move gets `****D<difficulty> <before>-><after>`, and the
  difficulty comes from the same timing ladder. `::reviewannotate::writeTactical`
  is a port of `analysis.tcl`'s `markExercise` — the classic is deleted, so this
  is now the only implementation.
- **The opening tag** — `::reviewannotate::openingMark` (`:236`) adds the
  `opBlunder` entry of the Annotator tag at the ply the book ended, when Review
  Settings' *Find opening errors* is on and the pass found a real book boundary
  (`bookEnd`), not the pass's "no book" default.
- **Book comments are not reproduced.** The classic annotator's
  `bookAnnotation` wrote "Out of book …" / "Last book move" into the game as
  comments. Nothing writes them now: the review path has no book-comment writer,
  and the `MoveOutOfBook` / `LastBookMove` keys were removed from the catalogues
  in #437 §5. That is a retired feature, named here and in the PR that deleted
  it.

**Batch games and opening errors.** The Game List's **Batch annotate** keeps its
parallel pipe search and calls `::reviewdriver::writeResults` per finished game,
so it writes the engine-window review's annotations with Review Settings —
label, `[%eval]`, the label's NAG, the position assessment on marked moves, `D`
and variations — and, when those switches are saved on, the same `opBlunder`
entry and `T`/`****D` exercise marks. There are no separate batch checkboxes:
both paths read `opening_errors`, `opening_window` and `tactical_exercises` from
Review Settings.

A batch position can end its search with no scored line at all, which under a
time cap is the likeliest way a move goes unjudged. Such a ply is written with no
verdict and the game still counts as completed, so
`::batch_annotate::unjudgedCount` counts it, per move and with the book range
excluded, and the completion dialog reports `plies with no verdict: N` beside the
game count; the games figure alone would say the batch finished cleanly.

**Rapid annotate** (Ctrl+Shift+A) is a consumer too: it converts the scores the
engine windows have already collected into the same results shape and calls
`::reviewdriver::writeResults`. The graph keeps only the best line and only the
positions it reached, so this is a quick pass rather than an exact copy of a
depth-limited Game Review — labels and marks speak the same language, but there is
at most one variation and no second-best comparison.

## Which moves got the marks

The review labels every judged move; the classic marks followed the annotate
dialog's mode:

- **all moves** — every judged move got the label, its `[%eval]`, the NAG and the
  assessment; no diagram (that is a blunders-only mark);
- **blunders only** — only the moves whose drop is over `blunderThreshold`, plus
  the classic's two exemptions: a position that is already decided is left alone,
  and a mate-range position is marked even for a small drop (the classic's
  `abs(score) >= 327` clause). The `??` and `?` moves are both offered to the
  exercise gate; `?!` is only a mark.

In blunders-only mode the filter decided the **whole** write, not only the marks:
a move the mode did not annotate got no label and no `[%eval]` either, and one a
previous all-moves pass had left there was taken off. A sparse annotation that
still carried a verdict word on every move would not be sparse. A move that was
not annotated in blunders-only mode could still carry `!?` when it was better
than the engine's line, as the classic branch did.

## Tier 2 (AI prose) left this file

The dialog pinned tier 1, and tier 2 — one sentence of prose per judged move —
was described here as "not wired yet, and synchronous when it is", because
`::auto_comment::query` ran `exec curl` on the Tk event loop: one request per
judged move, each blocking for the provider's own timeout.

That problem was solved elsewhere, and **not** by this dialog:
`tcl/tools/review_prose.tcl` is a non-blocking queue over the same provider, with
progress, cancel and an in-session cache, and `::reviewdriver` runs it as the
review's last layer (`proseProgress`, `tcl/tools/review_driver.tcl:957`). Prose is
written by the review surface, so the annotate dialog never needed it. The prompt
text lives in `tcl/tools/review_coach.tcl`; the AI prompt is English by design —
it is sent to a model, not shown to a reader.

## The parity gate, and why it was never satisfied

`tests/tcl/annotate_parity.tcl` was the retirement gate: one fixture game
annotated twice, once by the classic pipeline and once by the review writer, with
both runs read back through the exporters that consume them (the RTF exporter's
own walk, the `T` flag, the `****D<difficulty>` comment), asserting the
artefacts were equal and that the one intended difference — the review also
writes its label and `[%eval]` — was exactly that.

It never had to pass. The classic pipeline was deleted in #437 §5 for a
different reason: the Analysis window was its only caller, and the marks that
still matter (the exercise, the opening entry, the diagram) had already been
ported into `review_annotate.tcl` and were being written by the review path. The
gate's subject went with the subject it compared against, and the surviving
behaviour is pinned by `tests/tcl/review_marks.tcl` instead.

## Not in this change

- **The classic annotator is gone**, not parked: #437 §5 deleted it with the
  window. There is no parity gate left to pass and no artefact left to approve.
- **The progress board is not an annotate window.** The pass reports
  `done/total` on the app's docked review progress pane (A4); there is no window
  of the annotate path's own.
- **No new translatable strings.** The two Cancel labels and the disabled
  switch's note (`StopNow`, `StopAfterThisGame`, `AnnotateVariationsMainLineOnly`)
  were this pipeline's last strings; the run that used them is deleted, and the
  keys went with the other dead annotate keys in #437 §5.
