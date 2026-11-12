# OpenBook Rich (`.obr`) — format specification, version 1

*License: this specification is released under CC0 1.0 (public domain). The reference code `obr.py` is MIT.*

OpenBook Rich is an open, single-file format for chess opening books that need more than a Polyglot `.bin` can hold. Like Polyglot, it uses Polyglot Zobrist keys and Polyglot move encoding, and records are sorted by key, so a reader is a binary search. Unlike Polyglot, it stores per-position game statistics, ratings, move annotations and recommendations, plus a link from each move to the resulting position.

## 1. Layout

All integers are **little-endian**, unsigned unless stated otherwise.

```
+-----------------+  offset 0
| Header (64 B)   |
+-----------------+  pos_off
| Positions       |  n_positions x 48 B, sorted by key (ascending)
+-----------------+  move_off
| Moves           |  n_moves x 8 B, grouped by position
+-----------------+  alias_off
| Aliases         |  n_aliases x 12 B, sorted by key
+-----------------+  meta_off
| Metadata (JSON) |  meta_len bytes, UTF-8
+-----------------+
```

## 2. Header (64 bytes)

| off | size | field | notes |
|----:|----:|---|---|
| 0 | 4 | magic | ASCII `OBR1` |
| 4 | 2 | version | `1` |
| 6 | 2 | header_size | `64` |
| 8 | 4 | n_positions | |
| 12 | 4 | n_moves | |
| 16 | 4 | n_aliases | |
| 20 | 2 | position_record_size | `48` |
| 22 | 2 | move_record_size | `8` |
| 24 | 8 | pos_off | |
| 32 | 8 | move_off | |
| 40 | 8 | alias_off | |
| 48 | 8 | meta_off | |
| 56 | 4 | meta_len | |
| 60 | 4 | reserved | 0 |

Readers must reject files whose magic, version or record sizes differ from those listed above.

## 3. Position record (48 bytes)

| off | size | field | meaning |
|----:|----:|---|---|
| 0 | 8 | key | Polyglot Zobrist key of the position |
| 8 | 4 | games | games that reached this position |
| 12 | 4 | white_wins | |
| 16 | 4 | draws | |
| 20 | 4 | black_wins | |
| 24 | 4 | rating_games | games with a known average player rating |
| 28 | 4 | rating_sum | sum of those ratings (average = sum / games) |
| 32 | 4 | perf_games | games counted for the performance rating |
| 36 | 4 | perf_sum | sum of performances (average = sum / games) |
| 40 | 4 | first_move | index of this position's first record in the Moves table |
| 44 | 2 | n_moves | number of book moves (may be 0) |
| 46 | 1 | recommendation | book author's mark for the move that **leads to** this position: `0x80` normal, `0x40` avoid, `0x00` none, other values reserved (see section 9 for the colours) |
| 47 | 1 | flags | bit 0: black to move. Bit 1: the source book stored this position mirrored (informational). Other bits are 0. |

Statistics use **absolute colours**: White wins, draws, Black wins. To score a move, read the stats of its child position. The score of the side that played the move is `(wins_of_mover + draws/2) / games`.

## 4. Move record (8 bytes)

| off | size | field | meaning |
|----:|----:|---|---|
| 0 | 2 | move | Polyglot move encoding. Castling is king-takes-rook (e1h1, e1a1, e8h8, e8a8). |
| 2 | 1 | annotation | bits 0–4: NAG (0 none, 1 `!`, 2 `?`, 3 `!!`, 4 `??`, 5 `!?`, 6 `?!`, 7 forced, 8 only move, 9+ as in the PGN NAG table). Bits 5–7: source-book move flags, stored verbatim (see section 7). |
| 3 | 1 | status | 0: OK. 3: the move is legal but its child position has no record. 1 and 2: undecodable or illegal in the source; `move` is then 0 and the raw source bytes are kept in metadata. |
| 4 | 4 | child | index of the resulting position in the Positions table, or `0xFFFFFFFF` |

A position's moves keep the order of the source book.

## 5. Aliases (12 bytes)

`key: u64, value: u32`, sorted by key. Bits 0–29 of `value` hold a position index. Bits 30–31 hold a **transform**:
- bit 30 (t & 1): **colours reversed**. The alias is the record's position with the board flipped vertically, colours swapped and the side to move swapped.
- bit 31 (t & 2): **files mirrored**. The alias is the record's position mirrored a↔h. This only happens when nobody has castling rights.

Some source formats answer several real positions with one stored entry. CTG, for example, always stores the side to move as White and mirrors boards without castling rights. So 1.d4 g6 and 1.g3 d5 share one entry, and also share its statistics and moves.

OBR stores such an entry once, as a Position record. The other real positions become aliases.

When a key is found in Aliases with transform `t`, the reader applies `t` to what it reads:
- **Stats:** if `t & 1`, swap `white_wins` and `black_wins`, and invert flag bit 0.
- **Moves:** for both the from and to square, if `t & 1` then square ^= 56 (flip rank); if `t & 2` then square ^= 7 (flip file). Promotion bits are unchanged.
- **Children:** the child of an alias is the child record seen through the same transform `t`.

A reader that misses a key in Positions must also search Aliases.

## 6. Metadata

A UTF-8 JSON object. Required keys:
- `format` (`"OpenBook Rich"`)
- `version`
- `source`, an object describing the origin

Optional keys used by the CTG converter:
- `derived_fields`: source fields not stored as columns because they can be computed. The value is the formula.
- `exceptions`: source records that break a `derived_fields` rule, stored verbatim (hex).
- `unreached_raw`: source entries not reachable from the initial position, stored verbatim (hex).
- `unplayable_moves`: raw source move codes that could not be decoded or were illegal.

Together, these keys mean the conversion loses no information from the source book.

## 7. Notes for CTG-derived files

Bits 5–7 of `annotation` are copied from the CTG move byte. Their exact meaning in the source software is not publicly documented.

In the one book analysed (Hiarcs 15, 32.8M moves), only these combinations occur: `0xE0` (always with `!`), `0xC0`, `0x20` (with no NAG, `!?` or `?`), `0xA0`, `0x80` and `0x60`. They track the author's preference and the results. On a 3M-move sample the mover's average score is:

| combination | average score |
|---|---|
| `0xE0` | 0.523 |
| `0xC0` | 0.493 |
| `0x20`, no NAG | 0.473 |
| `0x20` + `!?` | 0.452 |
| `0xA0` | 0.405 |
| `0x20` + `?` | 0.324 |
| `0x80` | 0.281 |

Converters must copy these bits verbatim. Readers may ignore them.

The CTG fields "score in tenths" (`5*(2*wins+draws)`), "total games", and the two trailing bytes (always 0 in that book) are not stored as columns. Each was checked to be exactly derivable for all 32.3M entries. A record that breaks a rule would be kept verbatim in `exceptions`.

## 8. Reading algorithm

1. Compute the Polyglot key of the position.
2. Binary search Positions for `key` (transform 0). If it is missing, binary search Aliases and take the index and transform from there.
3. Read `first_move` and `n_moves`, then read those Move records.
4. For each move with `child` other than `0xFFFFFFFF`, read the child Position record to get its statistics.
5. Apply the transform from step 2 to the moves and stats (section 5).

The reference reader (`obr.py`, class `ObrBook`) is about 80 lines of standard-library Python.

## 9. Move colours

The file stores no colour value. A move's display colour comes from two stored fields: the `recommendation` byte of the child position, and the NAG in bits 0–4 of the move's `annotation`. To show the same colours as ChessBase for CTG-derived books:

| recommendation (child) | NAG of the move | colour |
|---|---|---|
| `0x40` | any | **red** (avoid) |
| `0x80` or `0xA4` | 2 `?`, 4 `??`, 5 `!?`, 6 `?!`, 9 (worst move) | **blue** |
| `0x80` or `0xA4` | any other, including none | **green** |
| `0x00` or other | any | no colour |

How this was established. In Hiarcs 15 the `recommendation` byte only takes the values `0x80` and `0x40`. ChessBase nevertheless shows three colours. Checked by eye in ChessBase:
- every `!?` move with `0x80` is blue (for example 1.e3, 1.g3, 1.b3 and 1.f4 in the initial position);
- a `?` move with `0x80` is blue;
- `!` moves and moves with no NAG are green;
- every `0x40` move is red.

jja 0.9.1 (`colored_uci` and `Nag::is_question_mark`) uses the same rule, except that it always shows `0xA4` as green. That value does not occur in Hiarcs 15, so this behaviour is unverified.

Example of a reader implementation (Tcl): `colour = red if rec == 0x40; blue if rec in {0x80, 0xA4} and nag in {2,4,5,6,9}; green if rec in {0x80, 0xA4}`.
