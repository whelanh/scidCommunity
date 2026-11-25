# Woodpecker Method trainer — architecture decision record

**Play > Woodpecker Method** trains tactics the way Axel Smith and Hans
Tikkanen describe in *The Woodpecker Method* (Quality Chess, 2018): one fixed
set of exercises, solved in order, again and again, each cycle faster than the
one before. This record says what was built, which choices were made and why,
and what was measured to make them. The code is four Tcl files under
`tcl/tools/`; nothing in `src/` changed.

```
Play > Woodpecker Method
   |
   +-- woodpecker_ui.tcl    one window: sets page, session panel, summary;
   |                        new-set and evaluate dialogs, statistics window
   +-- woodpecker_set.tcl   build a set (bundled puzzles, Lichess batch API, or
   |                        a PGN/Scid file),
   |                        the set's database, the token, the data folder
   +-- woodpecker_eval.tcl  grade a set: two passes on ::reviewdriver
   +-- woodpecker_core.tcl  pure Tcl: score, attempts, marks, schedule,
                            record files, statistics, JSON, SAN<->UCI
```

## Context

The method itself is simple; following it from a book is not. The trainee has
to keep a record sheet on paper (date, time spent, solved, failed, per cycle),
turn to the back of the book after every exercise to check the solution, work
out how many exercises a day keep the cycle on schedule, and use the one set of
exercises the book provides. All of that is bookkeeping a program can do, so
the trainer takes it over.

What the book establishes (from the publicly available excerpt: *Woodpecker
History*, pp. 6–8, *General Introduction*, pp. 10–12):

| Point | Page |
| --- | --- |
| A set of about 1000 exercises solved in full, then repeated "again and again, getting faster each time" | 7 |
| Each cycle aims to halve the total time of the previous one | 7 |
| A rest after each cycle, from a day to more than a week | 7 |
| 1128 exercises in three levels: Easy 222, Intermediate 762, Advanced 144; Advanced not recommended to most | 11 |
| "The goal is not to score 100%, especially in early cycles" | 11 |
| Exercises carry no hint of their theme; some contain red herrings | 12 |

The *Instructions* (p. 26) and the *Sample Record Sheets* (p. 390) are not in
the excerpt, so the record columns and the scoring below are this
implementation's own, not the book's rules.

Two existing pieces of scidCommunity made the trainer cheap to build: the
Lichess puzzle API client in `tcl/tools/lichess_puzzles.tcl`, and the game
review (`::reviewdriver`, `::movelabels`), whose engine pass already handles
games that start from a FEN.

## Decision 1 — a set is a folder: a Scid database plus tab-separated files

```
<data folder>/woodpecker/
    README.txt                  what each file is; log.tsv cannot be recreated
    token.txt                   only in Scid's own user folder, never elsewhere
    2026-11-17-Standard 300/
        set.si5 set.sg5 set.sn5 one game per exercise: FEN = position to solve,
                                main line = solution
        set.tsv                 key <tab> value: name, source, days1, restDays
        exercises.tsv           ex game puzzleId rating nmoves fen solution lastMove
        marks.tsv               ver ex marks source       ("-" "!" "!!" per solver move)
        log.tsv                 X ts cycle session ex result found ms
                                S ts cycle session start dur_ms
```

The database makes a Lichess set and a book set the same thing, and lets the
review, Batch annotate and NAG writing work on it without changes. The `.tsv`
files are the records: columns, tab separated, read as data and never sourced,
written atomically (`::woodpecker::writeAtomic`) or appended one line at a
time (`::woodpecker::appendLine`). A session does not create files; it adds
rows to `log.tsv`, about 60 bytes per exercise, so 1000 exercises × 10 cycles
is about 600 KB. `exercises.tsv` repeats the FEN and solution so that a
session never opens the set's database.

The sets page can open the database as a normal Scid database (Open Puzzle
Database), to study the positions, run an engine, or correct the set. Because
a session reads `exercises.tsv`, not the database, the file is rebuilt from the
database before a session when the database was edited. An exercise is matched
by its Lichess id, or, for a book set, by its position and solution: the ones
that stay keep their exercise number, so `marks.tsv` and `log.tsv` still name
the same puzzle; a deleted exercise leaves a gap, and an added one gets a new
number at the end, with the author's `!`/`!!` appended as a new marks version.
Existing marks are never rewritten. Nothing has to rewrite the history. A sync
is deferred while another game or training is using the board, or while the set
database has unsaved changes: the action that needed it asks the user to finish
first rather than using the old exercises.

The data folder is Scid's user folder (`%APPDATA%\scidCommunity` on Windows,
`~/.scid<version>` on Linux, `~/Library/Application Support/scidCommunity` on
macOS) unless **Options > Resources > Woodpecker data folder** points
elsewhere, typically to a folder a cloud service synchronises. Then:

- a chosen folder that is missing (a drive not mounted) is reported, never
  replaced by the default one, which would split the records in two;
- when the folder changes and the old one holds sets, Scid offers once to move
  them (copy, check, delete); a set already present in the new folder is left
  alone, and a new folder that already has sets is simply used;
- the question waits until the path stops changing, because the Resources
  dialog applies a path as it is typed.

The Lichess token (`token.txt`, permissions 0600 where the platform has them)
always stays in Scid's own folder, so it is never written into a synchronised
one.

*Rejected:* a new binary format, or a SQLite file. Nothing in the records needs
indexing, and plain text can be read, diffed and repaired by hand.

## Decision 2 — three sources: the bundled puzzles, the Lichess batch API, the user's own file

**The puzzles shipped with Scid** (`::woodpecker::set::fetchBundled`, the
default). `puzzles/set-*.pgn` are graded Lichess puzzles in plain PGN, built
offline by `scripts/build_puzzle_sets.py` (see `puzzles/README.md`) and
installed to `share/scid/puzzles`. Their union is one pool, filtered the way
the no-token Lichess fetch filters (below): per level, centre = rating + delta,
band = centre ± (100 + |1500 − centre| / 4). Then:

- the pool is read once per session, tags only (under a second for 6000
  games); the SAN solution is converted to UCI, and the opponent's last move
  found as the one legal move from `SourceFEN` to `FEN`, only for the puzzles
  drawn;
- the solver's side comes from the FEN; the `FlipB` tag, which orients the
  board when a set is opened as a plain PGN, is not read (a test checks it
  agrees with the FEN);
- inside a band each puzzle is drawn with a weight of 1 / (puzzles in its 50
  rating points): the sets are not equally dense (1000 in 300 points up to
  2450, 1000 in 150 above), and an unweighted draw pulled a band crossing 2450
  upwards (2000, *harder*: median 2474 instead of about 2300; weighted, 2314);
- a centre beyond the pool's range is clipped to its edge, so a 2500 player's
  *hardest* gets the top of the pool instead of nothing;
- a short band widens once by 100. Not more: at 1500 six steps would turn
  *normal* from 1400–1600 into 800–2200. A level still short opens a dialog
  that offers to download the shortfall from Lichess with the same levels
  (no token, rating-emulated, none of the puzzles already drawn). Measured:
  at 1500, seven Standard sets of 300 before the eighth comes up short;
- new `set-*.pgn` files join the pool without code changes; nothing assumes
  a number of files or a ceiling. Sets 7–9 (2451–2899, 1,000 each) were added
  this way, with sets 1–6 left byte-identical.

Lichess is opt-in, under *Advanced* in the dialog ("Get puzzles from Lichess
instead of the included sets"), where the token lives. The rating stays in the
main part of the dialog because every source needs it, except Lichess with a
token, which knows it.

**Lichess** (`::woodpecker::set::fetchLichess`). `GET /api/puzzle/batch/{angle}`,
50 puzzles per call, one request at a time, a `User-Agent`, a minute's wait
after a 429. The dialog asks for:

- the number of exercises (20–2000);
- a difficulty preset, each a mix of the five Lichess levels split by largest
  remainders (`::woodpecker::set::levelCounts`):

  | Preset | easiest | easier | normal | harder | hardest |
  | --- | --- | --- | --- | --- | --- |
  | Automatic (patterns until they are seen at once) | 30% | 50% | 20% | | |
  | **Standard** (default; the book's Easy/Intermediate proportion, 222/762) | | 25% | 60% | 15% | |
  | Challenging | | | 40% | 45% | 15% |
  | Tough | | | 15% | 40% | 45% |
  | Custom | the five percentages are shown only here | | | | |

- a theme (`mix` by default, as the book gives no hint of the theme) and the
  side to move;
- the planned length of the first cycle in days (default 28) and the rest days
  between cycles.

Puzzles already in another set are skipped, the side is checked locally from
`initialPly` (the API documents `color` as working only with `nb=1`), and the
set is sorted by rating, as the book goes from Easy to Intermediate. The batch
reply has no FEN: the position is rebuilt by replaying the game's PGN
`initialPly + 1` plies (`::woodpecker::lichessExercise`), and the opponent's
last move is kept as a `LastMove` tag so the session can show it.

Two facts found by measurement shaped the fetch:

- without a token, one angle and difficulty return the same 50 puzzles for
  about a minute (three calls 6 s apart: 50/50 overlap; a minute apart: none).
  For `mix` the fetch rotates `mix`, `opening`, `middlegame`, `endgame` (the
  three phases cover every puzzle) and waits 20 s when a whole round brings
  nothing new: 200 distinct puzzles in 13 s;
- without a token the levels are relative to a 1500 player. With a token
  (masked entry, *Save and check* via `POST /api/token/test`, a link to the
  token page with the `puzzle:read` scope filled in) Lichess serves puzzles the
  user has not seen, relative to their puzzle rating, which `/api/account`
  returns and the dialog shows.

**Without a token, at the trainee's own level** (`::woodpecker::anonPlan`). The
trainee enters their Lichess puzzle rating and each level is emulated as lila
picks puzzles for a logged-in user: centre = rating + delta
(`PuzzleDifficulty.scala`: −600, −300, 0, +300, +600), band = centre ±
(100 + |1500 − centre| / 4) (`PuzzlePath.scala`). The anonymous levels nearest
the band are fetched, only the puzzles inside it are kept, and the rest is set
aside for another level. Rating 1900, Standard preset: 60 puzzles in 12 s,
easier 1500–1689, normal 1727–1999. Above about 2100 the anonymous pool runs
thin, so a strong player's hardest band is narrower. The dialog says so inline,
with no pop-up.

**A PGN or Scid file** (`::woodpecker::set::buildFromFile`): every game with a
set-up position becomes an exercise, the main line is the solution, variations
are ignored, and the author's own `!`/`!!` become the first marks version. The
original file is never touched; it is copied into the set.

*Rejected:* importing the Lichess puzzle CSV (6 M puzzles, 310 MB, zstd) at
run time. Scid has no zstd decoder; the bundled sets are a curated subset of
it, chosen offline, which gives absolute rating bands without the download. The API spec asks not to
use the batch endpoint for mass download; a set is a few dozen requests made
one at a time.

## Decision 3 — the marks come from the review, through a puzzle profile of its own

The book's solutions single out the moves worth seeing. To give the same reward
in software, a set is **evaluated** once and each solver move gets `!`, `!!` or
nothing. A probe (`scripts/woodpecker/`) ran the review's own code
(`::review::mainLineMap`, `::reviewdriver::sides`, `::reviewdriver::judge`,
`::movelabels::label`, `::movelabels::refine`) with Stockfish (MultiPV 3,
depth 18) on 150 Lichess puzzles, 399 solver moves, rated 806–2193:

| Measure | Result |
| --- | --- |
| The review already starts from a FEN | yes: `mainLineMap` reads `position fen …`, `sides` takes the side from the FEN |
| Moves the review marked `!` or `!!` at the time | **0**: `refine` (great/brilliant) had no runtime caller |
| With `refine` as it is: *great* / *brilliant* | 56.4% / 5.8% |
| Moves with ≥ 200 cp between first and second line | 98.5%: by construction every Lichess solution move is an "only move" |
| Sacrifices excluded from *brilliant* only by its `cp_before ≤ 500` ceiling | 17 of 42 |
| Depth 12 against depth 18 (40 puzzles) | identical labels on 100% of moves; 0.35 s against 4.4 s per puzzle |

So `refine` as it stands does not discriminate on puzzles: its *great* test
(a big gap to the second line) is nearly always true, and its *brilliant*
ceiling removes exactly the sacrifices of crushing and mating puzzles.
`::woodpecker::markFor` is the Woodpecker profile, rule S3 of
`scripts/woodpecker/calibrate.py`:

- **`!!`, a sound sacrifice**: the engine's first choice leaves at least two
  points en prise (`::chessboard::hangingMaterial`) and the line does not
  simply take them back (`::movelabels::isTrivialRecapture`), i.e. `refine`'s
  brilliant test without the +5 ceiling, since in a puzzle the evaluation
  before the move already contains the combination;
- **`!`, not the obvious move**: quiet (neither capture nor check), or not the
  move a depth-3 search plays (the idea `::reviewannotate::markExercise`
  already uses for tactical exercises);
- only moves the review labels best, excellent, great or brilliant are marked. *great* was
  added once the review began supplying the second line's score, which turns
  some *best* only-moves into *great*.

At depth 12 on the same 150 puzzles this marks 10.0% of the solver moves `!!`
and 20.1% `!`: 30.1% earn a bonus.

The marks are a game reward, not a difficulty estimate. Against the Lichess
rating, which comes from real attempts, the Spearman correlation of a puzzle's
maximum score is about 0.3 for every definition tried, below the 0.38 of the
solution's length alone. That matches the literature: engine-derived measures
capture little of the difficulty a human perceives (Guid & Bratko 2006;
Hristova, Guid & Bratko 2014; Stoiljkovikj, Bratko & Guid 2015). The rating is
therefore used directly as a weight (Decision 4).

| Definition tried | `!` | `!!` | puzzles without marks | ρ with rating |
| --- | --- | --- | --- | --- |
| `refine` as it is | 56.4% | 5.8% | 6.7% | 0.36 |
| `refine`, `!!` without the ceiling | 51.6% | 10.5% | 6.7% | 0.32 |
| quiet only move / sacrifice | 12.5% | 10.5% | 52.7% | 0.27 |
| found only from 4 plies / sacrifice | 16.3% | 10.5% | 47.3% | 0.24 |
| quiet **or** not found by a short search / sacrifice (chosen) | 25.8% | 10.5% | 36.0% | 0.30 |
| every key move / sacrifice | 30.6% | 10.5% | 0% | 0.15 |
| *reference: solution length only* | | | | *0.38* |

With n = 150 the confidence interval is about ±0.15, so the first, second and
chosen rows cannot be told apart; the chosen one marks a minority of moves, so
`!` still means something.

**Scope.** The profile lives in `woodpecker_core.tcl` and only reuses
`::chessboard` and `::movelabels` helpers. `move_labels.tcl`,
`review_driver.tcl` and the Game Review of ordinary games are unchanged: the
trainer changes nothing the review writes for anyone else.

**How the evaluation runs** (`woodpecker_eval.tcl`): two passes on the review's
own engine connection (`::reviewdriver::start`), with an engine chosen among
the UCI presets:

1. every position of every solution, MultiPV 3, depth 12, the review's verdict
   per move;
2. the position before each solver move, MultiPV 1, depth 3, which gives the
   "short search" move for the `!` test. It starts after the driver's queued
   close of the first pass.

About 0.15 s per exercise for the easiest bundled puzzles and 0.85 s for the
hardest (Stockfish 18, one thread, a laptop CPU): lines are longer as the rating
rises. The result is a new version in `marks.tsv`, and the marks are written into the
set's database as NAGs. No engine runs during a session; an evaluation that
finishes during one writes its NAGs when the session ends
(`::woodpecker::eval::flushPending`). The evaluate dialog adapts to what the
set already has: no annotations means the evaluation is recommended right
after creation; some annotated moves offer *complete with the review* or
*overwrite*; a fully annotated book set makes the review optional.

**The bundled puzzles come graded.** Asking a new user to run an engine
evaluation before the first session is friction for the default source, and
it needs an engine they may not have configured. So the evaluation was run once
over all 9,000 puzzles and its result is `puzzles/marks.tsv` (104 KB: the
PuzzleId and one mark per solver move), regenerated by
`scripts/woodpecker/bundled_marks.tcl`. The marks are not in the PGN files:
those stay as the set builder wrote them, and a file of marks keyed by PuzzleId
works the same for sets built from any mix of them.

- When a set is built (`buildFromExercises`), each exercise that carries marks
  (`bundledExercise`, only when there is one mark per solver move) becomes the
  set's first version in `marks.tsv` with source `review`, and the marks are
  written as NAGs. Nothing else changes: the same files, the same score.
- `afterCreate` asks no question when every exercise has its marks, since
  `markStatus` counts them as reviewed; the evaluation stays in the set's menu
  for anyone who wants their own engine's marks. A set topped up from Lichess
  after a shortfall has some exercises without marks and is offered the
  evaluation as before.
- Made with Stockfish 18 (Threads 1, Hash 16), depth 12 MultiPV 3 then depth 3,
  `::woodpecker::markFor` as committed. A second run of set 9 gave identical
  marks on all 1,000 puzzles.

What the rule marks over the whole pool (the same 30% was measured on the 150
puzzles of the calibration, rated up to 2193):

| Puzzles | `!` | `!!` | marked | marks per puzzle |
| --- | --- | --- | --- | --- |
| set 1 (about 600–900) | 7.6% | 6.1% | 13.7% | 0.25 |
| set 3 | 15.9% | 8.9% | 24.8% | 0.58 |
| set 5 | 27.2% | 10.1% | 37.2% | 1.03 |
| set 7 | 37.3% | 11.6% | 48.9% | 1.61 |
| set 9 (2750–2899) | 46.8% | 12.2% | 59.0% | 2.16 |
| rating ≤ 2193 (5,440) | 19.1% | 9.2% | 28.3% | 0.67 |
| all 9,000 | 29.6% | 10.7% | 40.3% | 1.12 |

Up to 2193 it reproduces the calibration (20.1% `!`, 10.0% `!!`). Above it `!`
keeps climbing: in a hard puzzle most solver moves are quiet or not what a short
search finds, so about half of the moves of sets 7–9 are marked (at most 8 in
one puzzle). A deeper short search does little (depth 5: 54% marked in set 9
becomes 50%) and depth 12 against depth 18 on 69 puzzles of sets 7–9 gave the
same mark on 92.5% of the moves, so the rise is the rule, not a shallow engine.
The rule was left as it is: `!!` stays near 10–13% at every rating and the
score is already weighted by the puzzle's rating.

A bug found by this measurement: `markFor` accepted only *best*, *excellent* and
*great*, but `::reviewdriver::judge` returns the label after `refine`, which
turns a sound sacrifice into *brilliant*. Those moves (7% of all) got no mark,
and `!!` stood at 3.5% instead of 10%.

## Decision 4 — the score

`::woodpecker::score`, per exercise, with `k` solver moves each carrying a mark:

| Result | Points |
| --- | --- |
| solved with no mistake (`clean`) | `V + Σ bonus + C` |
| failed (the first mistake) | `max(0, Σ bonus found − V·0.5)` |

`V = 1` (line completed), `C = 1` (clean line), `b(!) = 1`, `b(!!) = 2`, and a
bonus counts when its move was found before the mistake. The maximum is
`V + Σ b + C`. Everything is multiplied by the puzzle's weight
`clamp(rating / 1500, 0.5, 2)` (`::woodpecker::weight`), so a 2100 puzzle is
worth 1.4 times a 1500 one; a book set without ratings weighs 1. The constants
are the array `::woodpecker::P`.

Example: a line with one `!` and one `!!`. Clean: 1 + 1 + 2 + 1 = 5 of 5. A
mistake after finding the `!!`: 2 − 0.5 = 1.5. A mistake on the first move,
with nothing found: 0.

A failure keeps the bonuses found before it, so an exercise solved most of the
way is not scored the same as one not started. A session and a cycle report
points over the maximum as a percentage. Points only make sense relative to the
trainee's own earlier cycles. The book's own measures, time per cycle and
solved/failed, stay the main figures; the score is a view derived from them.

## Decision 5 — log the events, compute the score

`log.tsv` records what happened, not the points: for each exercise the cycle,
the session, the result, which solver moves were found (`found`, one 0/1 per
move) and the time. Every statistic (`::woodpecker::sessionStats`,
`cycleStats`, `compareCycles`) is computed from the log under a given marks
version. When a set is evaluated after its first cycle, that cycle is rescored
with the new marks and becomes comparable with the next; when marks change
between evaluations (another engine, another depth), every cycle is compared
under the same version, the latest. `log.tsv` is the one file that cannot be
recreated, and the README says so.

## Decision 6 — the schedule

`::woodpecker::cycleDays`: cycle *k* lasts the first cycle's days halved *k−1*
times, at least one day (Tikkanen's halving, p. 7).

`::woodpecker::plan` computes today's quota from the exercises left and the
days left. Falling behind is handled in two steps, so that a missed day is not
a crisis and a long break is not a punishment:

- a day or two missed raises the daily quota, up to 1.5× the base quota
  (`quotaCap`, status `quota_raised`);
- when that is not enough, the deadline moves so that the quota stays at the
  cap (`deadline_moved`), but never beyond 2× the planned length (`stretchMax`);
  past that, the quota rises again (`over_stretch`).

The status reaches the trainee as one sentence on the sets page and in the
session.

## Decision 7 — the session takes the main window

A session must hide the solution and remove distractions. `enterFocus` saves the
user's layout (`::docking::layout_save`), closes every window but the board
(engine and tree windows included, so nothing can show the solution), and docks
the Woodpecker panel beside it. `leaveFocus` restores the layout when the
trainee leaves from the summary or closes the panel. While the focus layout is
on, an options save keeps the user's layout as "auto", so quitting Scid
mid-session does not make the session the next start's layout. If the layout
cannot be built, the session runs in the user's layout with the engines that
follow the board paused.

**The session plays in a `MEMORY` database of its own.** `sc_game push/pop`
keeps one slot per base, which other windows also use, so it cannot hold the
user's open game for a whole session (reproduced in the GUI test). The user's
game and base come back untouched when the session ends.

**Inside an exercise** (rules borrowed from the replay trainer's design: no
pop-up inside an exercise, feedback that never blocks, the reply without a
click):

- one attempt (`::woodpecker::exStart` / `exAnswer`, a small state machine):
  the first wrong move ends the exercise, flagged red, and the solution is shown
  with its marks, step by step with the arrow keys or by clicking the moves on
  the card. Two attempts were tried first and dropped: a second try goes against
  the idea of a Lichess puzzle, where a wrong move is a failed puzzle, and it
  made `second` a third result that the score, the summary and the statistics
  all had to carry;
- the opponent's reply plays at once; on the last move any mate is accepted
  (`::woodpecker::isMateMove`), as on Lichess;
- the panel: result tile and session clock, pace (average per exercise against
  the target, the previous cycle's time halved), streak, points, days left,
  rounded bars for today's target and the cycle, and one coloured tile per
  exercise of the session;
- two minutes without input pause the session, and that time does not count;
- **Auto-pause** (a global option on the sets page, off by default) stops the
  clock at the end of every exercise, right or wrong, and waits for Continue.
  A solved exercise then gets the same step-through review as a failed one
  (a trailing opponent reply is added to the session game first), and the time
  spent reading the solution counts neither in the session nor in the next
  exercise;
- a click anywhere on the panel gives the focus back to the board, so the arrow
  bindings keep working after a click on the card.

**The summary** stays in the focus layout: points, exercises with results in
columns, time, today's target (green when reached), the cycle, the comparison
with the previous cycle, and *more exercises / statistics / leave*. The
**statistics** window has the per-session record sheet, the per-cycle totals,
and a chart of each cycle's solving time against the halving target.

Colours come from `::woodpecker::ui::color` and follow light and dark themes.
The sets page shows each set's cycle, today's target and deadline as cards, and
scrolls when the window is short.

## Changes outside the trainer

| File | Change |
| --- | --- |
| `tcl/menus.tcl`, `tcl/start.tcl` | menu entry under Play, next to Lichess Puzzles; the four files in the load list |
| `tcl/windows/preferences.tcl` | the Woodpecker data folder row in Options > Resources |
| `tcl/lang/english.tcl`, `italian.tcl` | the trainer's strings; other languages fall back to English |
| `tcl/tools/lichess_puzzles.tcl`, all `tcl/lang/*.tcl` | **fix**: the Difficulty menu offered *easiestThenNormal* and *normalThenHardest*, which the API does not know and serves as *normal*. It now sends the five accepted values (a saved old value becomes easier/harder), checks each puzzle's side from `initialPly`, and sends a `User-Agent` on all three transports (curl, Tcl http, PowerShell). Labels follow Lichess's own translations |
| `tcl/utils/win.tcl` | **fix**: `::docking::layout_restore` compared the whole `{Toplevel .wnd}` pair with `Toplevel`, so every floating window was dropped on restore, the "auto" layout at startup included. Found by the Woodpecker GUI test |
| `tcl/main.tcl` | **fix**: the play-mode status line expanded the literal word `pInfo` instead of the variable |
| `.github/workflows/tcl-tests.yml` | four new `tclsh` harnesses |
| `CMakeLists.txt`, `Makefile.conf` | install `puzzles/set-*.pgn`, `marks.tsv` and `Copyright.txt` to `share/scid/puzzles` (not `manifest.csv`) |

## Tests

| Harness | Runs | Covers |
| --- | --- | --- |
| `tests/tcl/woodpecker_core.tcl` | `tclsh`, CI | score, attempts, marks, schedule, record files, statistics, JSON, SAN↔UCI, presets, no-token bands |
| `tests/tcl/woodpecker_eval.tcl` | `tclsh`, CI | marks from the two passes' results |
| `tests/tcl/woodpecker_set.tcl` | `tclsh`, CI | data folder, moving sets, README, token file; bundled pool: FlipB against the FEN, SAN→UCI and last move against `manifest.csv`, one mark per solver move for every puzzle in `marks.tsv`, shares to counts, bands, widening, clipping at the top, no repeats across sets, shortfall |
| `tests/tcl/lichess_puzzles.tcl` | `tclsh`, CI | the Difficulty menu, colour filter and User-Agent against a fake Lichess |
| `tests/woodpecker_app.tcl` | in the built app | sets from the bundled puzzles (with their marks as the first version and as NAGs), from Lichess and from PGN, a real Stockfish evaluation |
| `tests/woodpecker_gui.sh` (+ `.tcl`) | GUI, Xvfb | real sessions: focus layout, hidden solution, abandon, restored layout, card clicks and arrows, auto-pause and review of a solved line, scrolling sets page; `WOODPECKER_GUI_UNDOCKED=1` repeats with a floating window |

`scripts/woodpecker/` holds the calibration probe (needs Stockfish and network
access, not run in CI); its README has the commands.

## Known limits

- Lichess puzzles always have a winning, only-move solution, so they contain no
  red herrings (p. 12). A set built from a book keeps them.
- Without a token, puzzles already solved on Lichess can come back, and the
  hardest band of players above about 2100 is narrower.
- The bundled pool stops at the top of its last set (2897 today; above 2899
  only 88 puzzles pass the quality gates): a band beyond it is clipped, so a
  very strong player's *harder* and *hardest* overlap, and set 9 (2750–2899)
  is thinner than the others.
- Sub-variations of a book's solution are ignored; the main line is the
  exercise.
- The marks rule was calibrated on one sample of 150 puzzles rated up to 2193.
  Above that it marks about half of the moves (sets 7–9), and `puzzles/marks.tsv`
  carries what it gives today; change the rule and the file must be regenerated.
- Translations other than English and Italian show the English strings.

## References

- Smith, A., Tikkanen, H. (2018). *The Woodpecker Method*. Quality Chess.
- Lichess API: <https://lichess.org/api>; puzzle database:
  <https://database.lichess.org/#puzzles>; lila `PuzzleDifficulty.scala`,
  `PuzzlePath.scala`.
- Guid, M., Bratko, I. (2006). Computer analysis of world chess champions.
  *ICGA Journal* 29(2), 65–73.
- Hristova, D., Guid, M., Bratko, I. (2014). Assessing the difficulty of chess
  tactical problems. *Int. Journal on Advances in Intelligent Systems* 7(3&4).
- Stoiljkovikj, S., Bratko, I., Guid, M. (2015). A computational model for
  estimating the difficulty of chess problems. *Proc. 3rd Conference on
  Advances in Cognitive Systems*.
