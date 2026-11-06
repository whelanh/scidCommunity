# The engine window's review buttons

The engine window used to carry one **Game Comment** button that opened the
batch annotator. It now carries two review icons over one engine pass, a settings
icon, and a stop icon that appears only while a pass runs. The pass itself is
`::reviewdriver` (`tcl/tools/review_driver.tcl`),
the decisions behind the buttons are `::reviewui` (`tcl/tools/review_ui.tcl`),
and a review writes into the open game: `::reviewdriver::run` searches the
positions, turns the replies into verdicts and calls `::review::writeMove`, so the
moves come back labelled with `[%eval]` and variations.

```
[review]  [comment]  [settings]   Reviewing position 3 of 42   [stop while running]
```

The review controls are icon-only, like the rest of the engine toolbar; hovering
one shows its label. Both action buttons are disabled unless there is a game with
moves and an engine; Move Comment additionally needs a move under the cursor (the
start position has none, the last move does), and both are disabled while a pass
runs, which is what the stop icon is for.

## Game Review — the whole main line

The Game List's **Batch annotate** uses this same writer over its parallel
engine pool, with these settings, so a batch of games gets what pressing Game
Review on each would have written. Its dialog only chooses the engine and the
number of instances. **Rapid annotate** (Ctrl+Shift+A) uses the writer too, from
the best line the score graph has already collected.

Press **Game Review** and the pass searches every position of the main line at
the review's depth, showing `Reviewing position n of m` in the button bar, and
then writes the verdicts into the game: a label and a `[%eval]` on each move's
comment, the NAG the label implies (`??`, `?`, `?!`, `!`, `!!`, or none for
best/excellent/good/book), a position assessment from the same score on the
moves the review marks (`=`, `+=`, `+/-`, `+-`, `+--` and the Black half `=+`,
`-/+`, `-+`, `--+`), a `D` diagram marker on the move before each mistake and
blunder when the Diagram setting is on (a verdict on the first move has no move
before it, so no diagram), and at each mistake, blunder and missed win the
engine's preferred move as a variation, up to `var_lines` of them. A best,
excellent or good move gets no variation: the only line left to show would be
the second-best move, which is not an improvement. Running it again replaces the
review's own marks — `writeMove` strips its comment tokens, and the NAG matching
the previous label and its diagram are replaced — while the user's prose and any
mark the user put there are left alone (Scid keeps one move mark per move, so a
move that already carries one keeps it and the review's label goes without). The
one case that cannot be told apart is a user mark that is the *same symbol* the
label implies - `??` on a move the review also calls a blunder. It is then
treated as the review's mark and replaced on a later run. The position
assessment is the review's own slot and comes only with a mark: on a move the
review marks, its assessment is replaced by the one the current score implies,
including one the classic annotator or the user put there, because it has to
agree with the `[%eval]` beside it. A quiet move gets no assessment, and any
assessment already on it is taken off, so a first and a second pass agree and the
symbols point at the moves worth looking at. The same holds for a
`D` on the move before a mistake or blunder: it is treated as the review's
whether or not the review wrote it, because a NAG carries no owner.
The board is back where the user left it when the pass ends.

The positions come from `::reviewdriver::planPositions` over the snapshot
`::review::mainLineMap` takes of the line, so:

- the board is never moved to build a position, and the pass is unaffected by
  where the user has scrolled to;
- the reference position for each judged move is searched, plus the position
  after it, so a move can still be judged when it is not one of the engine's
  lines;
- a null move appears as a fresh `position … moves` header in that snapshot and
  does not shift the plies after it;
- a position the snapshot cannot name is dropped rather than sent as an empty
  `position`.

**The opening book.** Game Review reads book #1 — the book loaded in the Book
window's first slot, or the book configured as #1 when none is open — and asks
`::review::bookEnd` how many moves of the game followed it. Those moves are
written `[Book]`, with no `[%eval]` and no variation, because there was no search
behind either; the early book positions are not searched either. The move that
leaves the book and everything after it is judged normally.
`::review::skip_book` (default on) turns this off; it has no row in Review
Settings yet. Move Comment ignores the book: it judges the move it was asked
about, whichever opening it belongs to.

Depth and MultiPV are **not** settings of the review dialog: they come from
`::review::effective`, where the engine preset wins `Threads`, `Hash` and a
higher `MultiPV`, and the review's own depth is a floor a shallower preset cannot
lower.

**The time cap** is the other way round. `::review::movetime` (milliseconds, 0 =
none) is a ceiling on one position's search, and `::review::passLimits` decides
which cap a pass runs under: the review's own value when it has one, otherwise
the preset's `Limits.movetime`, otherwise none — never the smaller of the two.
So a preset's cap reaches every pass, and setting one in Review Settings replaces
it rather than tightening or loosening it by arithmetic nobody can predict. Both
numbers go to the engine in one `go depth N movetime M` built by
`::enginelimits::goLimits`, the same helper the engine window's own search uses.

**Under a time cap the depth is not a floor.** The engine stops at whichever
comes first, so a capped pass can finish shallower than `::review::depth`, and a
verdict then rests on a shallower search than the setting promised. That is the
trade the cap asks for, and it is why the cap is off by default.

**One setting, two surfaces.** The Analysis window's annotate dialog shows the
same `::review::movetime` as a time-per-move spinner, in seconds, labelled with
the Review Settings row it writes. Editing either surface changes the other, and
a cap typed there reaches every pass this session runs — the annotate pass, Game
Review and Move Comment — because `::review::passLimits` is the only place the
number is read.

**A bound never displaces a verdict.** A capped search can report a MultiPV slot
as `lowerbound`/`upperbound` at the depth it had reached and only then finish the
line. `::reviewdriver::collect` keeps one line per slot by ranking a `cp`/`mate`
score above a bound before depth, because `::reviewdriver::lineScore` refuses a
bound: the deepest-line rule would have let the bound hold the slot (the exact line
at the same depth is "not deeper") or overwrite an exact line already in hand, and
the ply would have been written with no verdict at all.

The pass runs on its own engine connection (id 20), so it never restarts the
search the user is watching in the analysis pane.

**Cancel** stops the pass: no further position is started, the engine is closed
and nothing is written.

## Move Comment — the move you are on

Press **Move Comment** to judge the move highlighted in the game: the one that
led to the position on the board, not the next move. The label and `[%eval]` are
written after that move; a diagram (`D`), when the move earns one, is placed
before it. It searches two positions, the one before the move and the one after
it, because a verdict needs both scores: what the move was worth, and what it
brought.

When it may start is `::review::moveCommentPlan`:

- with `move_comment_wait` on (the default) the comment has to be the one a
  review would have written, so a shallower analysis is not good enough: the pass
  searches at the review's depth instead. That depth is the *effective* one
  (`::review::effective`): an engine preset with its own deeper limit raises it, so
  a review and a one-move comment of the same position cannot disagree at two
  depths;
- with `move_comment_wait` off, whatever the window's own analysis has already
  reached is good enough and is the depth searched — the depth shown in the bar's
  depth box is the depth used.

The analysis depth is read for the position before the move — ply `here - 1` in
the window's depth map, the one the Autorun pass fills in — because that is the
position the pass searches first. A position that has not been analysed yet has
no entry, and that is "nothing yet", not "depth 0".

The wait is **depth-based even when the pass is capped**: `movetime` bounds the
pass, not what a comment has to reach. A capped comment therefore writes the
verdict the capped search actually produced — shallower than `::review::depth` if
the cap bit — instead of waiting for a depth the cap will never allow.

## Review Settings

**Review Settings** opens seven rows:

| Row | Setting | Range |
| --- | --- | --- |
| Lines | `mpv` | 1–5 |
| Depth | `depth` | 6–60 |
| Time cap (ms) | `movetime` | 0–3600000 (0 = no cap of the review's own) |
| Variations to write | `var_lines` | 0–`mpv` (default 1) |
| Variation margin (cp) | `var_cp` | 0–500 |
| Wait for the review depth | `move_comment_wait` | 0–1 |
| Diagram | `diagram` | 0–1 |

The time cap sits beside Depth because it bounds the same thing. A value of 0
means the review sets no cap of its own, and the row then shows the preset's, as
`1500 ms (from engine preset)`. The note reads the preset's own
`Limits.movetime` — never `::review::effective`, which keeps a review cap that is
still saved: with 200 ms saved beside a preset's 900, a box at 0 is the edit that
clears the saved cap, so the note says 900. The note disappears the moment a value
of its own is typed.

A variation is written only where the verdict says a better move existed —
`mistake`, `blunder` and `miss` — so the default of 1 gives a game a handful of
lines at exactly the moves the review complains about, not one after every move.
An inaccuracy is deliberately excluded: the gain is small and the lines would
outnumber the interesting ones. The variation is the engine's best line, so it
is the move that should have been played.

A variation already in the game is never removed by a later pass: it cannot be
told from one the user inserted, so the write phase dedupes by first move and
adds what its current verdict wants. A move that was a mistake last run and is
best now therefore keeps the line it had.

`var_cp` is a noise filter, not a quality floor: a line is written when it is
strictly less than `var_cp` centipawns behind the best line, and **0 means no
filter at all**. A margin of 2 therefore keeps only lines less than 2 cp behind
the best — usually none, because MultiPV's alternatives are further behind than
that. To see variations, leave the margin at 0 or set it well above the gap the
engine reports between its lines.

Every row is stored through `::review::setValue`, which owns the rules. A value
it refuses is reported in the dialog and the dialog stays open, so the rest of
the edit is not lost; nothing is clamped behind the user's back. `var_lines` is
capped by `mpv`, so its box follows `mpv` rather than offering a number the
setter would reject.

The seven rows are ordinary options (`::reviewopt(mpv)` and so on, registered
with `options.store`), so they are written to the options file with the rest of
the user's preferences and read back at the next start. A value in a hand-edited
options file is clamped to the same range before it is used: the file must not be
able to decide that a pass searches at depth 0, or never gets a search at all.

**Threads and Hash are not in this dialog.** They are properties of the engine
preset — the whole point of the preset work in #382 — and are set from the
window's own controls. The dialog shows what the pass will take from them,
read-only, under the six rows, as `Threads 8, Hash 256 MB (from engine preset)`.
A second place to set them is a second place to get them wrong, and the window's
own controls already write the preset.

The pass is bounded to at most 8 threads and 512 MB of hash
(`::review::MAX_PASS_THREADS`, `MAX_PASS_HASH`), and a preset asking for less
keeps what it asks for. The reason is that the pass is a *second* engine process:
the preset's reservation is allocated a second time beside the window's own
engine. A preset of Threads 64 / Hash 110000 MB on a 128 GB machine therefore
means two ~107 GB searches, the kernel swaps for its life, and systemd-oomd kills
the whole application when the second engine's table fills in. A batch of
short, fixed-depth searches cannot use a table that size anyway.

## How a review is written, and what Cancel does

`::reviewdriver::run` is plan → search → verdicts → write, and the write phase
runs only after the whole search has finished: `::review::writeMove` is called per
move with the label, the `[%eval]` and the engine's lines, and the game's own move
is never inserted as a variation of itself. The status line is `::reviewdriver`'s
own state read through `::reviewui::statusText` — the window keeps no token of its
own.

**Cancel** stops the pass before the write phase, so nothing is written at all.
That keeps the search and the write apart for the reason they always were:
writing mid-pass re-enters the engine window from an open engine, which makes the
main-line snapshot non-authoritative.

An engine variation carries the engine's name as a plain comment on its **first
move** (`Stockfish 16`), so a variation the reader adds later can be told from
the engine's. The engine window's **Add all variations** does the same for every
PV line it exports. A whole-game review also appends that name to the game's
`Annotator` tag; when coach prose is on and a provider is configured, the tag
names the provider and model too (`Stockfish 16; Google Gemini
gemini-3.6-flash`). A re-review with the same record does not append it twice.
Move Comment writes no Annotator tag, and the classic Annotate pass keeps its
own annotator handling.

## The progress pane

A review runs on its own engine connection and never takes the board. The
progress pane is the surface onto that work (#422 item 3): the header names the
run's source and the engine it was started with, a read-only board shows the
position being searched, a determinate bar shows how far the pass has got, and
the button stops it.

- **A docked pane, not a window.** It is registered with the app's docking layer
  (`::docking::create_window` in `tcl/utils/win.tcl`) and built into the frame
  the dock creates, the way `.commentWin` is; it appears in a notebook tab and
  joins the saved layouts. There is no `toplevel`, no `wm` call and no transient:
  the dock owns its visibility, its position and its lifetime.
- **Opened by Game Review, available to every run.** Windows → Review progress
  opens it, the review status line in the engine window's toolbar opens it, and
  a Game Review that starts successfully opens it if it is not already open — a
  long pass should not need the reader to hunt for a menu. The other runs
  publish into it without selecting the tab; the docked layout still belongs to
  the reader. With no run in flight the pane shows the current position of the
  game on the main board.
- **Fed a FEN and nothing else.** `::reviewprogress::positionToBoard` turns the
  engine's own FEN into the string `::board::update` draws, and
  `::reviewprogress::specToBoard` handles both spec shapes the driver queues:
  `position fen …` and the standard game's `position startpos moves …`. The
  board has no game, no cursor and no clock. A run therefore cannot move the reader's board
  or fight it for control, and a click on the progress board does nothing: the
  canvas carries no square bindings and is out of the focus order.
- **The header is a field.** Source, engine name and origin are composed once
  when the run starts and carried in the job, so a run that outlives its window's
  engine choice still says what it was asked to do.
- **Two bars, one source each.** The search bar is `::reviewui::passFraction` of
  the driver's own counts; an empty total is no fraction rather than zero. When
  the coach starts, `::reviewprogress::setProse` publishes its queue, and the
  second bar and its line (`annotating 31 of 31 · prose 3 of 9`) say that the
  model, not the search, is what is still running. The coach row is hidden for a
  run with no model behind it. Autoscan's rapid job ends with its last answer or
  its commit, not at the next game.
- **Hidden is not paused.** The job is published whether or not the tab is
  selected, and `<Map>` redraws from the current position, so a reader who comes
  back sees where the run is now. The board is built at an explicit `psize`,
  because a canvas in an unselected tab has no measured width to ask for.
- **Closing cancels nothing; Cancel stops the run on screen.** The job carries
  its owner's stop command (`::reviewdriver::cancel` for review, Move Comment and
  annotate, `::batch_annotate::cancel`, `::enginewin::stop` for rapid annotate,
  `::finishgame::stop`), and the pane's button invokes that command — never the
  review driver for a batch or Finish Game. Closing the tab leaves the run
  alone; a run that outlives a closed pane keeps publishing, and reopening the
  pane reads the job and draws the run as it stands.
- **Every run publishes into it, not only the engine window's** (G5=b). Game
  Review and Move Comment begin the job in `::reviewui::runCall`; annotate
  composes its header in `::reviewannotate::headerFields`; rapid annotate owns a
  job of its own and leaves one another run holds alone; the batch starts one job
  for the whole run. A batch's header carries the game in flight
  (`· game 4 of 4`), recomposed from the fields the run began with as each game is
  assigned, so it is still a stored field rather than a lookup at draw time;
  `pipe_seq` counts the games actually handed to a pipe, so a skipped selection
  cannot shift the numbers, and a game requeued after an engine died keeps the
  number it already had. The
  board always shows the position the engine is searching — the driver's own
  `position` string replayed on a pure `::chessboard`, never the reader's game —
  so none of these runs can walk the main board.

Finish Game uses the same board. It collects the continuation on pure
`::chessboard` positions — each move from the previous one — and writes once at
the end, with the cursor saved and restored the way `::review::writeMove` does
it. `::addMoveUCI`, which follows the cursor and animates, is off the path, so the
reader's board stays where they left it for the whole pass. A cancel writes
nothing because the collect phase touched nothing. The engine window's Finish
Game and the classic Analysis window's both run this one pass
(`::finishgame::start` and `::finishgame::startPane`).

The pass also keeps the old Finish Game's rules. It counts repetitions on the
pure board, seeded from the game's own history, and stops when a position occurs
for the third time; the result is written as a draw after the commit. It starts
only at the end of the main line - a midgame cursor or a variation is refused,
because the commit appends there - and applies Chess960 castling on the pure
board. It records the game it started on — base, number and final position — and refuses to write
when the reader has opened or edited a different game meanwhile, rather than
appending the continuation to whatever is current. And the classic pane's toggle
is left Off when the pass ends, including a pass whose engines could not start,
so the next press starts rather than only clearing a stale flag.

## The review report

`tcl/tools/review_report.tcl` turns a finished pass into the figures a reader
wants first: accuracy per side, ACPL, an estimated Elo, the label tally, the
key moments, and the opening / middlegame / endgame split. The accuracy is the
app's own figure — `::accuracy::calculate`, the same call the engine window's
chart and the PGN viewer's chart make — so one game has one accuracy in this
application instead of two. It is arithmetic over
the pass's own results — no second search and no model — and it writes one block
into the game's header comment, marked `[Game review]` so a second run replaces
the block instead of stacking another under it. It removes only its own lines —
the marker and the indented lines under it — so a note typed below the block
survives the next review. The default writer of a whole-game pass calls it once
the moves are in the game, so the header is part of a review rather than a
separate command; a Move Comment pass names its plies and writes no report.

**It reads in the window's language.** The marker, the side names, the figures,
the phase names and every move label in the tally and the key moments go through
`::tr`, so a Spanish window writes `[Revisión de la partida]` and
`5 Teoría, 2 Error grave` — the same words the scoresheet's own comments use.
Labels come from `::movelabels::text`, the table the annotations use, so the
report and the moves cannot disagree. A language that has not translated a key
falls back to the English text, and `stripHeader` matches the English marker as
well as the translated one, so a game reviewed before the language changed does
not stack two blocks.

**Where the opening ends.** Three signals, and the opening ends at the first one
to fire:

- **Smyrnov's test** — both sides have developed every minor piece (no bishop or
  knight left on c1/f1/b1/g1 or c8/f8/b8/g8; a captured one is not on its square,
  so it counts as developed) *and* both sides' rooks are connected. Connected
  means two rooks sharing a rank or a file with every square strictly between
  them empty, wherever they stand: the back rank is the usual case, not the
  definition. A side with fewer than two rooks has no pair to connect and passes
  that half — otherwise a rook-less game would sit in the opening for ever.
- **mixedness above 150** — how far the two armies have grown into each other
  (ported verbatim from David Crandall's game-review plugin, see
  [`third-party-notices.md`](third-party-notices.md)). It closes a sharp, tangled
  opening early, so a hypermodern line is not held to Smyrnov's strictness.
- **ten or fewer majors-and-minors** — four of the initial fourteen (`n b r q`
  across *both* sides, never per side) have left the board. This is the safety
  net for a game that trades material fast; it fires early, which is why it is
  not the primary signal.

The consequences are deliberate:

- openings now end **later** — typically around moves 12–20, when the back rank
  is resolved — instead of at a fixed ply;
- there is **no ply floor**: a line that is out of the opening on move 5 is out
  on move 4;
- a game that ends before any of the three fires has **no middlegame bucket** and
  gets no middlegame prose. The report does not invent a phase, and it does not
  lend the opening's figures to one that never happened.

The endgame is **one test: 26 points or fewer on the whole board**, and nothing
else. The count is the whole board with both sides summed and a pawn counted as
1 — Speelman's thirteen points a side is 26 total, and counting the pawns is
what makes "thirteen a side" mean material rather than pieces. Flear's "at most
one piece besides kings and pawns" (eight pawns and a minor is 11, plus a rook
13) and Minev's board count are the same figure, and because it is one total an
uneven endgame (20 points against 5) reads as an endgame instead of failing a
per-side test. There is **no queens-off test**: Fine's case — queens off, the
king activates — is the usual way to reach the total, not a condition on it, so
a queen endgame inside 26 points is an endgame. There is also **no six-piece
net**: lichess's `Divider.scala` ends the game on `majorsAndMinors <= 6`, and it
was considered and rejected here, because six majors-and-minors can hold **38
points** — two queens and four rooks, no pawns at all — and six minors with all
sixteen pawns still on the board is 34. The total calls both of those
middlegames, and the net called them endgames: a piece count that ignores
material must not override the count that does not. The piece count is still
what the **opening** uses (ten or fewer majors-and-minors, below, alongside
Smyrnov's test and mixedness). A bucket of fewer than four plies is still
suppressed — three plies of "phase" is a rounding artefact, not a phase.

## The coach's prompts — the facts, and nothing but

`tcl/tools/review_coach.tcl` also builds the requests a model would answer:
`gameMeta` reads the game's identifying facts, `buildPrompts` decides which
prompts a results set has, and `summaryPrompt`, `phasePrompt`, `movePrompt` and
`momentPrompt` write the text. Nothing here calls a model, opens a socket or
touches the board, so the whole layer is checked in tclsh.

**What a prompt is allowed to contain.** A prompt is a short task, the hard
rules, and the FACTS block last. The block is the subject's own facts and only
its own — the game-level facts for the summary, the phase facts for a phase, the
move facts for a move. Every move, square, number and phase boundary the model
may name is in that block, and the rules say so: a piece the block does not list
is not on the board, a line shows only the moves printed in it, and the verdict
words the scoresheet already uses are named only to be forbidden.

**The answer's language.** The prose lands in a game comment beside the move
labels, so it is written in the language `Options → Language` shows. Each prompt
ends with one directive naming that language (`- Write the answer in Spanish.`)
and keeps SAN notation as FACTS writes it — a line in FACTS is SAN, numbered
from the review's own ply (`7... e5 8. Nf3`), and the fifty-move clock is
stated in moves (`49 of 50`) — the summary prompt keeps the three
labels `SUMMARY:`, `LEVEL:` and `OPENING:` because `parseSummary` reads them
back, and translates only their text. English adds no directive — the prompt is
already English — and a language with no name in the table gets none rather than
a wrong one. The banned label words are also named in the chosen language
(`::movelabels::text`), so a model is not told to avoid "mistake" and then free
to write "error".

Two places in the text name something outside the block, and both are
deliberate. The summary prompt carries two worked examples — "the game turned on
move 9, when Black's queen took the pawn on e4 and was won for a rook" — that
show the shape of the answer rather than making a claim about the game. And the
ban list names the labels the move is *not*: a blunder's prompt bans
"inaccuracy", "mistake" and "miss", never "blunder", which is the word it uses
itself. Both are instructions to the model, not text it should echo.

**A reply is read, not trusted.** `parseSummary` reads the model's answer back
into the three blocks the writer places — `summary`, `level` and `opening` — and
nothing else. A block the prompt never asked for is not invented as one; a block
that is missing comes back empty, so the writer writes no line for it; `NONE` is
the answer the prompt asks for when there is no opening name. The reply is also
cleaned before it is stored (`::reviewprose::clean`): typographic dashes and
quotes become ASCII, because scid reads comments in the host codepage and a
UTF-8 em dash arrives as mojibake; square brackets are removed, so a model cannot
close the block it is writing in or open a token of its own; the text is trimmed
and cut at 600 characters.

There is no per-sentence check against the FACTS block. A reply that names a
move, a number or a phase outside its block is placed as written — the facts
were the model's to use, and the review has no way to tell a claim from a
paraphrase of one. What keeps the prose honest is the prompt, the ban list the
model is given, and the reader's own scoresheet beside it. A request that fails
is dropped: the move keeps its label, `[%eval]` and marks and simply has no
prose.

`buildPrompts` decides which prompts exist, in order: the summary first, then
one for each phase that has moves, then one for each mistake, miss or blunder,
in ply order and capped at ten. A key moment that is a good move gets no
prompt: the move prompt asks what the move failed to do, which is the wrong
question there, and tier 2 is mistakes only. The same results set gives the same
prompts byte for byte — nothing in the layer reads a clock or a random number.

## The coach's prose — where it lands, and what replaces it

`tcl/tools/review_prose.tcl` is the queue: one request at a time, in order,
cache-keyed by `{kind key prompt}`, with `run`, `next`, `reply`, `record`,
`finish`, `cancel`, `status` and `clearCache`. It sends through
`::auto_comment::queryAsync`, so the request never blocks the event loop, and a
model that answers out of turn, twice, or after its run was cancelled cannot
record an answer against the wrong question: every reply carries the run and the
item it was asked for.

`start`, `place`, `finish` and `clear` in `tcl/tools/review_coach.tcl` are the
orchestration. A **whole-game** review asks for prose when the coach is on — a
Move Comment pass over named moves is not a review and writes none. The labels,
the `[%eval]`s, the marks and the report are written **first**, the reader is put
back and the board is redrawn, and only then is the model asked. The run is not
over until every answer has landed or failed: its state stays `writing`,
`Cancel` is live, and the status line counts the answers
(`annotating 31 of 31 · prose 7 of 9`). Nothing is saved before the coach runs:
the Annotate dialog's batch writes each game to the database (`sc_game save`, in
`::reviewannotate::done`, and only when the batch has more than one game) when
the run ends, and in the coach path the run ends through `proseDone` — after the
last answer has landed or failed. The engine-window Game Review saves nothing at
all. `Cancel` drops the queue and leaves the prose already written in the game.

Placement, each block on a line of its own:

| Answer | Where it goes |
| --- | --- |
| `summary` | the three labelled lines at the start of the game's comment (ply 0): `Summary:`, `Level:`, `Opening:` — the labels are written in the window's language, English shown here |
| `phase` | a line at the phase's last move: `[Phase opening] moves 1-10 - accuracy W 84.0% B 79.1%, ACPL W 34 B 41.` and then the prose. The `[Phase …]` tag stays English as a marker; the phase word and the figures follow the language |
| `moment` | `[Coach] …` at the move the prompt was about, after the label and the score |

**Replacement, not stacking.** Before the writer runs, a whole-game review takes
the previous run's blocks off every planned move — with the coach off as well, so
turning the switch off removes the prose and nothing else. Placement then strips
again and writes the new answer. A phase whose answer failed still gets its
figures and no sentence; a moment whose answer failed simply has no `[Coach]`
line. Because each block is one line, the strip takes the whole line and nothing
else: a note the reader wrote **under** a block survives, and so does one above
it. Text appended to the end of a coach line is that line's and goes with it.

The coach's endpoint and model are the Game Comment provider settings; Review
Settings carries the switch (`Coach prose`) and a `Coach settings…` button that
opens them. Review Settings no longer holds a Tk grab, because that grab
swallowed every event meant for the dialog it opens.

### What a failure looks like

| Failure | What the user sees |
| --- | --- |
| no provider configured, coach on | one message when the review ends; the review itself is complete |
| a request fails (`ERROR: …`) | that move or phase has no prose; the labels, `[%eval]`s and marks are untouched |
| the endpoint hangs | `curl --max-time` ends it; the same as a failed request |
| Cancel while waiting | the queue is dropped, the prose already written stays, and one message says how many notes were kept |
| another game opened while the model wrote | the prose is discarded and one message says so; the review stays written |
| a second review, coach on | the previous prose is replaced, not stacked |
| a second review, coach off | the previous prose is removed; the review's own comments are untouched |

## Comment colours

The comments a review writes say where they came from by their colour. It is a
provenance colour, chosen by the writer and not by the shape of the text:

| Writer | Colour | What it writes |
| --- | --- | --- |
| `::review` | green `#008000` | the move verdicts (`[Best] [%eval …]`, `[Book]`) and the `[Game review]` report block |
| `::reviewcoach` | blue `#3B82F6` | the coach's `Summary:`/`Level:`/`Opening:` block, `[Phase …]` lines and `[Coach] …` moments |
| the reader | `::pgnColor(Comment)` (default green `#008b00`) | text typed without a formatting span |

`tcl/tools/comment_colors.tcl` writes the colour as the comment editor's own
`<span style="color:…">` markup, so the comment window, the PGN window and the
RTF export render it, and plain PGN export strips it (`src/game.cpp`). Nothing
is written for text the reader typed, which is what lets the global comment
colour be theirs: the Format menu's **Default comment color…** and the PGN
window's Colors → Comment set the same `::pgnColor(Comment)`, and the comment
window paints unspanned text with it.

The blue is a compromise: no single blue reaches 4.5:1 against both white and
the dark themes' `#1e1e2e`, and `#3B82F6` gives 4.46:1 on the darkest bundled
background (the review's green is 3.67:1 there).

Because a generated block is one span around one line, the strips that replace a
previous run take the wrapper with the text, and `::commentcolors::stripEmpty`
clears a wrapper left behind when only its tokens were removed. A comment
written before the colours existed is still stripped: every strip keeps its
plain-text form.

## Files

| File | What is there |
| --- | --- |
| `tcl/tools/game_review.tcl` | `::review` settings, `passLimits`, `plan`, `searchPlies`, `mainLineMap`, `playedMove`, `moveCommentPlan`, `writeMove`, `selectLines`, `scoreToNag`, `variationWanted` |
| `tcl/tools/comment_colors.tcl` | the provenance spans: the review's green, the coach's blue, line wrapping, and the span-aware strip |
| `tcl/tools/review_driver.tcl` | `::reviewdriver` — the engine pass on connection 20, `run` (plan → verdicts → write), the `-done` completion hook, the `-coach` override, coach-block ownership for the default writer only, `status`, `cancel` |
| `tcl/tools/review_annotate.tcl` | `::reviewannotate` — the annotate dialog's decision, the run (single game and batch chain), Cancel, the progress line, the classic marks |
| `tcl/tools/review_ui.tcl` | `::reviewui` — button state, the call a press makes, dialog values, the time cap's note, the status line |
| `tcl/tools/review_report.tcl` | the deterministic report: accuracy, ACPL, estimated Elo, key moments, and the phase split with the three-signal opening boundary |
| `tcl/tools/review_coach.tcl` | `::reviewcoach` — the facts a coach may use, the prompts built from them, and the prose layer: `start`, `place`, `finish`, `clear`, `strip`, `stripHeader`. No model, no network |
| `tcl/tools/review_prose.tcl` | `::reviewprose` — the queue: one request at a time through `::auto_comment::queryAsync`, cache-keyed, with progress, cancel and a failed request dropped |
| `tcl/windows/engine.tcl` | the review icons, the status line, the settings dialog (guarded glue) |
| `tcl/tools/analysis.tcl` | the Analysis window's annotate dialog, its OK (`configAnnotateOK`) and the button on every pane |
| `tests/tcl/review_settings_dialog.tcl` | 51 checks: under Tk: the dialog builds, has OK/Cancel, stores what is typed, refuses a bad value, the variation box follows `mpv`, the time cap's row shows the preset's cap and drops the note, the on/off rows are checkboxes, `Coach settings…` opens a window of its own from a dialog that holds no grab, and both traces are removed when the dialog closes |
| `tests/tcl/review_ui.tcl` | 229 checks: the call a press makes, the status line (including the coach's counts), the button states, the dialog round trip, the precedence table through the dialog, the time cap's note, which move a comment judges, the move-comment depth, the key set |
| `tests/tcl/review_toolbar.tcl` | 42 checks: the five review icons use `::icon::` names and exist in icons_light and icons_dark at 24×24, the whole engine toolbar uses `::icon::` images, the labels are tooltips rather than text, the stop icon is gridded only while a pass runs, a visible divider separates the review group from Config, the dark-theme cache matches `::icon::` names, and the threat button exists only when its command does |
| `tests/tcl/review_driver.tcl` | 316 checks: the pass against a stub engine, the four Go shapes the precedence table produces, a capped run, two reviews of the same game in a row, the engine window's hand-off to it, the completion hook, the engine name on an exported variation and in the Annotator tag, and the coach: started after the write, the run held open until the answers land, not started for a single move or an annotate pass, an annotate pass leaving the coach blocks alone, not holding a run open when it cannot start, and Cancel while the model is writing |
| `tests/tcl/annotate_dialog.tcl` | 56 checks: the dialog's decision (pane preset, book end, tier, the non-UCI refusal), the blunders-only filter, and the Cancel label rule |
| `tests/tcl/annotate_run.tcl` | 82 checks: the plan run against a stub engine, the write, the batch chain, the Cancel escalation and a cancelled run writing nothing |
| `tests/tcl/review_report.tcl` | 115 checks: accuracy as the app's own figure and the parity a phase starting on Black's move needs, Elo, key moments, the endgame rule — one material total, with the six-piece net rejected at 38 points — the opening boundary — Smyrnov met and half met, rook-less and file/rank connectivity, mixedness at 150 and 161, the material net at ten and eleven, the first-firing signal at 17/21/25, no ply floor — and the block removal, two writes deep |
| `tests/tcl/comment_colors.tcl` | 14 checks: the two writer colours, the wrapper's escaping and per-line form, the empty-wrapper cleanup, and a strip that takes a wrapper with its line while a reader's note beside it stays |
| `tests/tcl/comment_default_color_tk.tcl` | 8 checks: under Tk: unspanned text takes `::pgnColor(Comment)`, the Format menu carries the entry, and choosing a colour saves it, repaints the editor and tells the PGN window |
| `tests/tcl/comment_facts.tcl` | 107 checks: the position core against the published perft counts, the exact block for a mating move, each rule line stated positively and negatively, the fifty-move clock stated in moves, the engine's line as SAN numbered from the position's own fullmove — one conversion per line, the five-ply clip, a setup game at move 30, a line that starts on Black, a mate score surviving it, the "no bare UCI" and "one number per move" invariants — and a punishment line that ends in mate |
| `tests/tcl/review_coach.tcl` | 123 checks: the move facts, the game-level facts, the turning move, the phase facts, the prose markers, that the header block comes off without taking the report's header with it, what a prompt may name and what it may not, which prompts a results set has and in what order, that a brilliant key moment gets no prompt, that the same set gives the same prompts, the summary reply, the game's identifying facts, and the prose layer: what a strip takes off and what a reader's own note keeps, where each answer lands, a second review replacing the first, a failed answer leaving no block, the coach off taking only its own prose, what a cancelled run reports, and the queue being wired to the prompts (including a queue that refuses to start) |
| `tests/tcl/review_prose.tcl` | 52 checks: one prompt at a time in order, each item's own token budget, the cache answering a second run, a failed request dropped without failing the run, a reply for a question that is no longer outstanding ignored, a cancelled run's answer never landing in the next run, the cleaning of what a model writes, and the status a caller asks for |
| `tests/tcl/review_transport.tcl` | 37 checks: a stub `curl` on PATH sleeps for a second, `queryAsync` returns in under 500 ms and its callback then arrives with the text, the blocking path holds the caller for the whole sleep (the control), two requests in flight do not cross, a refused provider starts no process, a failed request is an `ERROR:` string, Cancel kills the child and drops its reply (with the Windows `taskkill` fallback pinned), and no request or reply file is left behind |

## Tests

`tclsh tests/tcl/review_ui.tcl` (also run by the Tcl Tests workflow) pins what a
widget would otherwise have to decide:

- **the call a press makes** — `::reviewdriver::run`, with `-bookEnd`, the one move
  and depth for Move Comment, and a refusal (not an engine opening) when there is
  no game, no engine or no driver;
- **the status line** the driver's own state maps to: a search's count, silence
  for the write phase, a finished run and a cancelled one, and the reason a run
  that failed or was partly refused gives;
- **button state** for every combination the window can be in — no game, no
  engine, last position, a pass running, and a state dict with a key missing;
- **the dialog round trip**: read, change, refuse one field, and check the four
  good fields still landed and the refused one kept its old value, with the
  spin-box ranges checked against what `::review::setValue` accepts;
- **the one-move depth**, from `moveCommentPlan`, for a deep analysis, a shallow
  one, nothing analysed, the wait turned off, and a preset that raises the depth
  the review would use;
- **the key set**: the twenty-one review strings are present in all 29
  `tcl/lang/*.tcl` files, the file list is read from the tree so a new language
  file fails loudly, and the English text is the text the labels are asserted
  against.

The Tk glue in `tcl/windows/engine.tcl` is guarded rather than tested for its
widgets: a missing widget, a missing engine or a driver that refuses to start is a
no-op with a message, never an exception in the middle of a game.

One part of it is not a widget and is tested: **who owns a run**. One pass exists
at a time, so a second engine window pressing Game Review while a review is
searching is refused by the driver, and that refusal must not disturb the window
that started the pass. `tests/tcl/review_driver.tcl` loads `engine.tcl` over its
fake board with the widget commands stubbed, presses from two windows, and checks
that the refused press leaves the first window's Cancel live and its status line
following the pass. A window claims a run only once `::reviewdriver::run` has
actually started it.

## Related

- `docs/move-labels.md` — the label ladder the comments are built on.
- `docs/engine-presets.md` — the presets that own Threads, Hash and the search
  limits.
- `docs/comment-facts.md` — the deterministic facts a comment may state.
