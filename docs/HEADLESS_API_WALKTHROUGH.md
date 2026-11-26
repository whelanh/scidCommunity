# scidCommunity Headless API - Project Walkthrough

I have successfully implemented the first three phases of the scidCommunity Headless API. This project provides a JSON-RPC 2.0 interface to the Scid C++ backend, enabling standalone database operations without the Tcl/Tk GUI.

---

## Phase 1: Foundation & Infrastructure (Completed)

The goal of Phase 1 was to establish the basic communication layer and ensure the C++ backend could run independently.

### Key Achievements
- **CLI Flag**: Added `--headless` to `main()` in `src/tkscid.cpp`.
- **Control Loop**: Implemented a JSON-RPC loop in `src/api_headless.cpp` reading from `stdin` and writing to `stdout`.
- **JSON Library**: Integrated `nlohmann/json` as the primary serialization format.
- **Decoupling**: Resolved compilation issues by isolating headless code from Tcl/Tk header pollution.

---

## Phase 2: Core Read-Only Functionality (Completed)

Phase 2 extended the API to interact with real chess databases, supporting search and data retrieval.

### Key Achievements
- **Database Management**: Integrated `DBasePool` to manage multiple open databases.
- **Header Search**: Exposed the powerful `search_index` engine to allow filtering games by players, events, ratings, etc.
- **Game Retrieval**: Implemented PGN export and metadata extraction (ELO, ECO, Date, Result).
- **Real-World Verification**: Successfully searched and retrieved games from a real `testTWIC` database (SCID5).

---

## Phase 3: Write Operations (Completed)

Phase 3 enabled full database modification, creation, and maintenance.

### Key Achievements
- **Database Creation**: `db_create` allows initializing new Scid databases programmatically.
- **PGN Ingestion**: `game_add` uses the native `pgnParseGame` engine to import games from PGN strings with supplemental tags.
- **Maintenance**: `game_delete` and `db_compact` enable marking games for deletion and physically cleaning up the database files.
- **Graceful Lifecycle**: `db_close` ensures database handles are released properly.

### Verification Success
All Write Operations were verified via `scripts/test_phase3_write.py`:
- ✓ Created new database handle.
- ✓ Added multiple games via PGN.
- ✓ Verified searchability of new games (Nakamura vs Carlsen).
- ✓ Marked games for deletion.
- ✓ Compacted database and verified physical count reduction.

---

## Phase 4: Position Search (Completed)

The header search only inspects the game index, so it cannot answer "which games
reach this position?". `db_search` now accepts a `fen` parameter and matches the
board position through the same engine the GUI's board search uses.

### Key Achievements
- **Shared core**: the search loop was extracted from the Tcl command
  `sc_search board` into `src/searchboard.cpp` (`boardSearch()`), which has no
  Tcl dependency and is used by both the GUI and the headless API.
- **Match modes**: `position_match` exposes exact, pawns, files and material
  matching; `position_ignore_colors` and `position_in_variations` mirror the
  GUI's "Ignore colors" and "Look in vars" checkboxes.
- **Composition**: the position result is AND-ed with the header criteria by
  default, or OR-ed with `position_op: "or"`.
- **Strict parameters**: unknown `db_search` parameters are now rejected with
  `-32602` instead of silently returning the whole database.
- **Cancellation**: the shared core reports incremental progress, so long
  position searches remain interruptible in the GUI and report their status.

### Verification
- `gtest/test_searchboard.cpp` covers every match mode, variations, color
  reversal, candidate subsets and cancellation (run with `-DGTEST=ON`).
- `scripts/test_headless_position.py` exercises the JSON interface end to end.

---

## Technical Resources
- **Test Scripts**: 
    - `scripts/test_headless_api.py` (Basic & PGN)
    - `scripts/test_headless_api_si5.py` (Real Database)
    - `scripts/test_phase3_write.py` (Creation & Modification)
    - `scripts/test_headless_position.py` (Position search)
- **Source Code**: `src/api_headless.cpp` | `src/api_headless.h` | `src/searchboard.cpp` | `src/searchboard.h`
- **Task List**: `.gemini/antigravity/brain/.../task.md`
