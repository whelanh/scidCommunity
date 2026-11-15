# Game phases: what the literature says, and the rule this tree ships

The review surface reports per-phase accuracy, so it has to decide where the
opening ends and the endgame begins. This document records the criteria in the
literature, the one open implementation worth reading (Lichess), the rule an
earlier version of this feature used and why it was wrong, and the rule the code
now implements.

**Where the code is.** `tcl/tools/review_report.tcl`: `::reviewreport::openingOver`
(`:367`), `::reviewreport::endgameNow` (`:385`), `::reviewreport::phaseSplit`
(`:428`) and `::reviewreport::phaseStats` (`:389`). `tcl/tools/accuracy.tcl` holds
the Lichess win-percentage and accuracy formulas and has no phase logic of its
own; `tcl/tools/game_review.tcl` is the writer the phases feed. If this document
and that code disagree, **the code is right** and this file is the bug.

## The finding: no published criterion counts moves

The obvious rule — "the opening is the first N moves" — has no support in the
literature. Every source that defines the transition at all defines it from the
**position**: material, development, or the location of the kings.

| Source | Criterion | Kind |
|---|---|---|
| Alekhine | "we cannot define when the middle game ends" | refuses a definition |
| Fine | the middle game begins when the queens come off | material (queens) |
| Speelman | 13 points a side, king excluded | material (per side) |
| Flear | both sides have at most one piece besides kings and pawns | material (pieces) |
| Dvoretsky | at least one side has reached it | material, one-sided |
| Minev | a board total of about four pieces | material (board total) |
| Alburt & Krogius | positional: king safety, pawn structure, piece activity | positional |
| Mednis & Crouch | positional: the same family of tests | positional |
| Smirnov | no threshold at all — "the king becomes active" | explicitly non-numeric |

Two things follow, and both are in the shipped rule. First, a **move-count
floor** (a 12-ply minimum, say) is not a chess criterion; it is a proxy for "the
openings book we had in mind", and it makes the boundary wrong in exactly the
games that leave theory early. Second, the literature's material criteria are
**totals or shares, not piece counts**: Speelman's 13 points a side is 26 on the
board, Flear's "one piece besides kings and pawns" is a material statement, and
Minev's four pieces is the end of the game, not a phase boundary.

The attributions above are the survey the original feature was written from; the
primary texts were not re-read for this note, and Smirnov's phrasing is quoted
from that survey rather than from a page number. Nothing in the shipped rule
depends on a specific citation: it depends on the two findings, which every row
supports.

## Lichess, quoted

The only review-facing open implementation that draws all three phases is
Lichess's. `modules/game/src/main/Divider.scala` in `lichess-org/lila` is a cache
around the real thing; the rule is in `lichess-org/scalachess`,
`core/src/main/scala/Divider.scala`:

```scala
    val midGame = indexedBoards.collectFirst:
      case (board, index)
          if (majorsAndMinors(board) <= 10 || backrankSparse(board) || mixedness(board) > 150) =>
        index

    val endGame =
      if midGame.isDefined then
        indexedBoards.collectFirst:
          case (board, index) if majorsAndMinors(board) <= 6 => index
      else None
```

with

```scala
  private def majorsAndMinors(board: Board): Int =
    (board.occupied & ~(board.kings | board.pawns)).count

  // Sparse back-rank indicates that pieces have been developed
  private def backrankSparse(board: Board): Boolean =
    (Bitboard.firstRank & board.white).count < 4 ||
      (Bitboard.lastRank & board.black).count < 4
```

Three things are worth taking from it. The opening ends on **the first of three
signals** — an exchange count, a development signal, and **mixedness**, a
spatial measure of how far the two armies have grown into each other. The
endgame is only looked for **once the middlegame has begun**. And the endgame
test is a **piece count** (`majorsAndMinors <= 6`), which is the part this tree
did not keep.

That last choice is defensible where it is made — Lichess only needs a rough
split for a chart — but it cannot be the boundary of a **material** rule, because
six majors-and-minors can hold 38 points: two queens and four rooks with no pawns
at all, or six minors with all sixteen pawns still on the board. A count of
pieces fires in exactly the positions a material total calls a middlegame.

Our opening test is Lichess's shape with two of its three signals changed:
development is **Smyrnov's test** rather than `backrankSparse` (a stricter,
still-positional signal), mixedness is ported verbatim (including its 150
threshold and its 2×2 window scoring), and the exchange count stays at
`majorsAndMinors <= 10`. Our endgame test is Speelman's material total.

## The rule the plugin first shipped, and its four defects

The game-review plugin (`wip/game-review-plugin`, `plugins/game-review/docs/phase-definitions.md`)
defined the phases by move number, with these results:

1. **The phases overlapped.** Opening 1–12 and endgame 9–20 could both be true of
   ply 10, so a move could belong to two phases with different accuracy figures.
2. **The 12-ply floor had no chess meaning.** It is a proxy for "still in the
   book", and it is false in both directions: a mainline Ruy Lopez is still
   theory at ply 12, and a sharp gambit has left it by ply 8.
3. **The opening boundary was theory-driven, not position-driven.** It encoded a
   repertoire, not a position, and a game that transposed out of that repertoire
   was mis-phased.
4. **The endgame rule was both stricter and looser than every published one** —
   stricter in requiring queens off, looser in allowing positions with far more
   than 26 points of material. No source asks for queens off as a *condition*;
   Fine describes queens coming off as the usual *route* to a king-active
   position.

## The rule as shipped

Read from `tcl/tools/review_report.tcl`. No move count appears anywhere.

**The opening ends on the first position where any one of three signals fires**
(`::reviewreport::openingOver`, `:367`):

```tcl
proc ::reviewreport::openingOver {fen} {
    return [expr {[majorsMinors $fen] <= 10 ||
                  [smyrnovOver $fen] ||
                  [mixedness $fen] > 150}]
}
```

- **Smyrnov's test** (`:285`): both sides have every minor piece off its home
  square and their rooks connected. A captured minor cannot be on its square, so
  an empty home square satisfies it. Fewer than two rooks makes the connection
  question moot and counts as connected — demanding a pair that no longer exists
  would leave such a game in the opening for ever.
- **Mixedness > 150** (`:346`): ported verbatim from the plugin's
  `::crclass::_mixedScore`/`mixedness`, which is itself Lichess's 2×2-window
  score over files a–g and ranks 1–7. This closes a sharp, tangled opening early,
  so a hypermodern line is not held to Smyrnov's strictness.
- **`majorsMinors <= 10`** (`:214`): four of the initial fourteen
  knights/bishops/rooks/queens are gone. The count is both sides together, never
  per side, so `<= 10` is the safety net under a fast-trading game. It fires
  early, which is why it is not the primary signal.

**The endgame begins when the material on the board is gone** —
`pointsOnBoard <= 26` and nothing else (`::reviewreport::endgameNow`, `:385`),
with pieces at `p 1 n 3 b 3 r 5 q 9 k 0` (`:36`):

- Speelman's 13 points a side is 26 on the board; Flear's "at most one piece
  besides kings and pawns" and Minev's board count land on the same figure.
- The total is **both sides summed**, so an uneven endgame (20 points against 5)
  is still an endgame.
- **No queens gate.** A queen endgame inside 26 points is an endgame.
- **No six-piece net.** Lichess's `majorsAndMinors <= 6` was considered and
  rejected for the reason above.

**The middlegame is whatever is between the two** (`::reviewreport::phaseSplit`,
`:428`). The endgame is only searched for **after** the opening has ended, as in
Lichess. A game that ends before the opening has ended has no middlegame bucket
at all, and the report says nothing about a middlegame rather than inventing one.

**A phase needs four judged moves to have a figure** (`phaseStats`, `:396`):
fewer than four, or a phase that is entirely book or entirely unjudged, reports
no figure rather than 0.0. Reporting 0.0 printed a 0% phase and made it the
coach's "weakest phase"; no figures is the honest answer.

## What this document does not claim

- It does not claim any of these criteria is the *correct* one. There is no
  agreed boundary in the literature, which is why the rule is written down here
  rather than inferred from the code.
- It does not claim Lichess's thresholds are tuned for a desktop application.
  They are borrowed because they are the only open, review-facing implementation
  of the same three-phase split, and because two of the three signals are
  position-driven rather than count-driven.
- The per-phase figures are the coach's, not a rating: `docs/review-ui.md`
  describes what the report does with them.
