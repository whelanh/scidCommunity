# Comment facts

`tcl/tools/comment_facts.tcl` builds the block of statements a comment is
allowed to make about a position: what the move did, what it attacked, what it
left hanging, the piece inventory, the rule state, and material against the
engine's score. Everything is computed from the position and the move —
nothing searches, nothing calls an engine, nothing reads the database — so the
same position always produces the same lines.

The point is to remove the guesswork. A comment written from an engine score
alone has to invent the board, and gets it wrong in ways a reader cannot check:
a piece called hanging that is defended, a castling right twenty moves after it
was lost, a mate threat that does not exist.

```
::facts::forMove {
    fen_before {rnbqkb1r/ppp2ppp/5n2/3pp3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 5}
    played     e4d5
    side       white
    best_uci   b1c3
    best_san   Nc3
}
```

```
played: White's pawn takes the pawn on d5
it moves the pawn on e4 out of danger
it takes the pressure off the bishop on c4
what the move played achieved: it takes the pressure off the bishop on c4, moves the pawn out of danger, lets White castle next move
better was Nc3 - White's knight on b1 moves to c3: it also lets White castle next move, and unlike the move played it protects the pawn on e4 and develops a piece
White has queen on d1, rook on a1, ... king on e1, and 8 pawns
Black has queen on d8, rook on a8, ... king on e8, and 8 pawns
castling: White may still castle kingside and queenside; Black may still castle kingside and queenside
en passant: none available
fifty-move rule: 0 plies since the last capture or pawn move; 100 more plies would allow a draw claim
repetition: not available for this position
material: White is 1 point up, and Black is missing a pawn
```

## The move dict

| Key | Meaning |
| --- | --- |
| `fen_before`, `played` (UCI), `side` (`white`/`black`) | required |
| `fen_after` | derived from the two above when absent |
| `ply` | one-based; the position before the move is `ply-1` |
| `best_uci`, `best_san`, `best_pv`, `best_pv_long` | the engine's alternative, described only when `best_uci` is given |
| `classification`, `eval_after_cp`, `punish_pv`, `rep_count` | optional context from the caller |

## Rule state is always stated

Castling rights, en passant and the fifty-move clock are emitted for every
position, including in the negative — "Black has no castling rights", "en
passant: none available". A fact that is merely absent is exactly what lets a
model produce it anyway. Repetition follows the same rule: when it cannot be
computed (no `ply`, a variation, a ply past the main line) the line says so
rather than disappearing.

## What "true" costs

These are the mistakes this layer has already had to fix, and each has a test:

- an attack is not a threat — a pinned piece attacks geometrically and cannot
  capture, so every "hanging"/"attacks" claim goes through a legal-capture test;
- an en passant square is only part of the position when a pawn of the side to
  move can use it (FIDE 9.2), and the captured pawn stands one rank *behind* the
  landing square, not on it;
- SEE must price a promotion, or a promoting recapture is undervalued;
- a discovered check is not the moved piece's check;
- "has lost" is unprovable from a set-up FEN — the line says what is missing
  from the board;
- repetition needs the main line parsed as a Tcl list (`sc_game UCI_mainLine`
  returns the header as its first element), and `ply` is one-based.

## Position core

`tcl/utils/chessboard.tcl` is the pure-Tcl position the facts need: `sc_pos` can
only answer about the game's current position, and these facts ask about
positions that are not on the board — the engine's alternative move, the reply
it expects, and the null move that asks what the other side would play. It
generates legal moves, applies them, counts material and does a static exchange
evaluation. Move generation is pinned to the published perft counts for the
start position, Kiwipete and position 3.

## Tests

`tclsh tests/tcl/comment_facts.tcl` (also run by the Tcl Tests workflow): 84
checks, including exact expected blocks, each rule line stated positively and
negatively, and the en passant capture square.

## Related

- `docs/move-labels.md` — the label ladder, from `tcl/tools/move_labels.tcl`.

## Licence

Patzer is MIT-licensed, © Arsen Apostolov and contributors; the full notice is in `tcl/tools/comment_facts.tcl` and `tcl/tools/move_labels.tcl`. See [`docs/third-party-notices.md`](third-party-notices.md).
