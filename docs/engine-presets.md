# Engine presets

An entry in `engines.dat` describes one engine preset. Two presets may point at
the same binary and differ only in options, which is how "Stockfish Deep" and
"Stockfish Quick Review" coexist.

## What a preset holds

| Field | Meaning |
|---|---|
| `Name` | the key: windows, the review and the trainers find a preset by name |
| `Cmd`, `Args`, `Dir` | the binary and how to start it |
| `Elo`, `Time` | informational, used for sorting and display |
| `URL` | legacy slot, now holds `scoreside notation pvwrap debugframe priority netport` |
| `UCI`, `UCIoptions` | protocol flag and the UCI options the engine advertises (`Threads`, `Hash`, `MultiPV`, `SyzygyPath`, …) |
| `Limits` | search limits — see below |

`UCIoptions` also carries the review pass's own switch, `cloud_eval` — the Cloud
pre-pass, on unless this preset turns it off. It is written beside the engine's
options because it is a per-preset decision, but it is not a UCI option: nothing is
ever sent to the engine for it, and a handshake carries it across.

## Search limits

`Limits` is a dict with three keys, any of which may be absent:

```
Limits {depth 66 movetime 300000 autorun 250}
```

- `depth` — search depth limit (1–500). Empty means unlimited.
- `movetime` — search time limit in milliseconds (1–3600000). Empty means unlimited.
- `autorun` — the default cadence used when the window autoruns the main line,
  in milliseconds. It is applied when an engine window opens and then lives in
  that window's Autorun control; changing the control does not write the preset
  back, so a preset's autorun is set in `engines.dat` (a preset editor will get
  a field for it).

Limits belong to the preset, not to the window and not to Scid globally, so the
same engine can be browsed at `movetime 100` under one preset and searched to
`depth 66` under another.

A **review pass** reads the same two numbers, and reads them the other way round:
the preset may only *deepen* a pass (the review's `depth` is a floor a shallower
preset cannot lower), while its `movetime` is a *ceiling* that applies only when
`::review::movetime` is unset (0). Setting a time cap in Review Settings replaces
the preset's rather than being combined with it. `::review::passLimits` owns that
table for every caller, so a pass cannot run on a bound the dialog never showed.

The engine window's depth and time entries read and write the limits of the
preset it is showing. Editing them saves `engines.dat` immediately; there is no
separate "Save Options" step for them. Only the keys a preset actually sets are
written, and saving depth or time leaves the preset's `autorun` alone.

### Files written by an older version

`Limits` is the tenth element of the entry. A preset that carries the field
writes it even when it is empty (`Limits {}`): that is how "all limits cleared"
survives a reload and overrides the legacy globals. An entry from a file written
before the field existed has nine elements and no `Limits` line, so it is
byte-identical to what an older version wrote; the legacy global options
(`enginewin::depth_limit` / `enginewin::movetime_limit`) still apply to it.
Those globals remain stored for this reason and are no longer edited by the UI.

## Duplicating a preset

The engines list (Tools → Analysis) has **Duplicate**: the selected preset is
copied as a *complete* spec — command, arguments, directory, the whole
`UCIoptions` list and `Limits` — under a name made unique by
`::enginecfg::uniquename` (`Stockfish` → `Stockfish (1)`), and the copy opens in
the edit dialog so it can be renamed to what it is for (`Stockfish Quick
Review`). The copy is written to `engines.dat` at once, so cancelling the rename
leaves a usable preset behind.

The copy keeps the source's *shape*: a legacy nine-element entry copies as nine
elements (no `Limits` line, still falling back to the global options), while an
entry whose limits were all cleared copies as ten with the explicit empty dict.
Padding every copy to ten would turn "this preset says nothing" into "override
the globals with nothing", and dropping element 9 would turn a cleared preset
back into a legacy one.

`::enginelist::applyEdit` carries element 9 across an ordinary edit as well: the
dialog shows the other nine fields, and renaming a preset used to erase its
limits.

A rename cannot take a name another preset already carries. The list is read by
name (`lsearch -exact -index 0`), so two entries under one name leave the second
unreachable until one of them is renamed or removed — and a rename is exactly how
the copy above would stop being unique. `::enginelist::saveEdit` checks the name
first and offers the one `::enginecfg::uniquename` would have picked instead;
declining writes neither the list nor the file.

## Window shortcuts (Engine Window 1 and 2)

`Tools → Configure Engines` can assign a preset to either engine window. The
list's **Shortcut** column shows the assignment and **Edit** sets it (None,
Window 1 or Window 2). Each window opens its assigned preset regardless of which
presets were used most recently or where the list currently sorts them.

The keys belong to the windows, not to the presets. **Shortcut Keys...** in the
same dialog changes them; the defaults are **F2** and **F3**. The dialog captures
the next key combination pressed, accepts only a function key or a combination
with Ctrl, Alt or Command (so typing cannot start an engine), refuses a key
another command or the operating system already uses, and can reset the pair to
the defaults. The Tools menu shows each window's key and the preset it starts.

The assignment is by preset *name*, not by position:

- one preset per window — assigning it to Window 2 removes it from Window 1;
- a rename carries the assignment, and each window's remembered last preset,
  to the new name;
- a delete clears the assignment; an engine window that is already open keeps
  running the preset it has (Game Review reads that window's live config), and a
  later F2/F3 falls back because the name no longer resolves.

It lives in `options.dat` as `::enginecfg::shortcut(1)` / `(2)`, with the keys as
`::enginecfg::key(1)` / `(2)`. A window with no assignment keeps the old
behaviour: it opens the preset it last used, or the most recently used preset if
it has none.

## Where the code lives

- `tcl/tools/engine_limits.tcl` — the entry layout, validation, `Go` limit
  building and preset lookup (`::enginelimits::forName`).
- `tcl/tools/enginelist.tcl` — reads the file; accepts `Limits` as a dict, or a
  bare integer as the depth; the list's Shortcut column and edit dialog's
  None/F2/F3 choice.
- `tcl/enginecfg.tcl` — writes the file, preserving element 9,
  `::enginecfg::duplicate` copies a preset as a complete spec, and the
  name-keyed shortcut assignment (`assignShortcut`, `renameRefs`, `dropRefs`)
  plus the configurable keys (`keySequence`, `setKey`, `keyFromEvent`).
- `tcl/keyboard.tcl` — installs the two configurable engine keys on the main
  window and removes the old binding when a key changes.
- `tcl/windows/engine.tcl` — `::enginewin::loadLimits` takes a window's limits
  from its preset; `applyLimits` stores them back; `Open` starts the window's
  assigned preset before its remembered one.

## What the review does

A review pass runs on its own engine connection and sends `SetOptions` there.
It never writes to a preset: sharing a preset would otherwise change the values
the user browses with, and `::enginewin::changeOption` restarts the running
search when a value changes.
