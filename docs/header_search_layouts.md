# Header Search "Layouts" Feature Summary

This document memorializes the implementation details, design decisions, pitfalls encountered, and future improvement ideas for the Header Search "Layouts" functionality added to `tcl/search/header.tcl`.

## Overview
The Layouts feature allows users to save and reload named sets of header search parameters ("layouts"), enabling quick switching between frequently used search presets (e.g. `iccf`, `monthly`).

## Core Data Structures
- `::searchHeader_Layouts`: List of layout names (strings).
- `::searchHeader_Data(<name>)`: Array entries storing a serialized list of key/value pairs representing one layout.
- Both variables are registered with the Scid options system via `::options.store`, so they persist automatically across sessions without requiring explicit "Save Options".

## Saved Elements
The save routine (`::search::header::layout_save`) collects:
- Scalar variables (players, site, event, round, ratings ranges, date ranges, ECO, flags, variant toggles, etc.).
- Array variables: `sPgntext`, `sHeaderFlags`, `sTitles`.
  These are stored using `array get` then appended to a single list structure.

The load routine (`::search::header::layout_load`) reverses this process:
- Rehydrates scalars if present.
- Unsets and restores arrays from the serialized list.

## Menu Integration
`::search::header::rebuildLayoutsMenu` dynamically (re)builds the Layouts menu in the Header Search dialog:
1. Destroys any previously created submenu widgets to avoid the Tcl error: `window name "ly<name>" already exists`.
2. Removes prior cascade entries (from index 2 onward) and recreates cascades for each stored layout.
3. Each submenu provides:
   - Load: Calls `layout_load`.
   - Delete: Removes the layout and triggers menu rebuild.

## Combobox History Interaction Pitfall
The header search dialog uses `::utils::history::SetCombobox` to attach history lists to several `ttk::combobox` widgets (`White`, `Black`, `Event`, `Site`).

`SetCombobox` internally calls `RefillCombobox`, which executes `$cbWidget delete 0 end`. For a `ttk::combobox` this clears the entry field text—not just the dropdown items. Subsequent `AddEntry` calls may also trigger selection changes (`$cb current 0`).

### Observed Issue
After loading a layout, closing the dialog, and reopening it:
- All fields (players, event, round, etc.) restored correctly.
- The `Site` combobox appeared blank even though its underlying variable `::sSite` still held the expected value and the value existed in the dropdown list.

### Root Causes
1. Field cleared by `RefillCombobox` during dialog recreation.

### Final Resolution
Immediately after each `SetCombobox` call:
- Capture the variable value (`currentVal`).
- Retrieve the list of combobox values: `$widget cget -values`.
- If the value is present (`lsearch -exact`), select it via `$widget current $idx`.
- Otherwise, set it as free text: `$widget set $currentVal`.

This guarantees correct display whether or not the value is already in the history list.

## Functions Added / Modified
- Added: Layout persistence block at top (guarded initialization + `::options.store`).
- Added: `layout_save`, `layout_load`, `layout_delete`, `promptSaveLayout`, `rebuildLayoutsMenu`.
- Modified: Header Search frame builder (`search::headerCreateFrame`) to integrate Layouts button and robust combobox value restore logic.
- Modified: `rebuildLayoutsMenu` to destroy stale submenus before recreating them.

## Known Limitations / Future Improvements
1. History System Coupling:
   - Consider patching `RefillCombobox` to avoid clearing the entry widget text (`delete 0 end` vs updating only `-values`).
2. Partial Field Save:
   - Currently saves all scalar and array fields; could add version tagging to layout data for backward compatibility.
3. Validation:
   - Add guard against saving empty layout names or duplicate names with differing value sets (prompt overwrite?).
4. UX Enhancements:
   - Add a "Rename" option in each layout submenu.
   - Add a "Save As" when modifying an existing layout.
5. Sorting / Ordering:
   - Allow user-defined ordering or alphabetical sorting of layout names.
6. Export / Import:
   - Provide a bulk export/import facility (`.slayouts` file) for sharing.
7. Diff View:
   - Add optional comparison between current parameters and a chosen layout before overwriting.

## Testing Notes
Manual verification steps used:
1. Create layouts (`iccf`, `monthly`) with distinct Site / Event / rating ranges.
2. Load layout, perform search, close and reopen dialog, verify all restored.
3. Delete layout and confirm removal from menu without orphaned submenu errors.
4. Confirm persistence across application restart (due to `::options.store`).

## Design Rationale
- Avoided embedding widget references inside layout data to keep it backend-agnostic.
- Chose list serialization for simplicity; could migrate to dict-style for clarity (`dict create var value`).
- Performed minimal invasive changes to existing header search logic; feature is additive.

## Maintenance Tips
- When adding new header search fields, extend both `scalar_vars` and load loop in `layout_save` / `layout_load`.
- Always destroy old submenus before recreating to avoid Tk path collisions.
- To diagnose combobox issues, temporarily log values after `SetCombobox` and after restore block.

## Quick Reference (APIs)
- Save Layout: `::search::header::layout_save <name>`
- Load Layout: `::search::header::layout_load <name>`
- Delete Layout: `::search::header::layout_delete <name>`
- Rebuild Menu: `::search::header::rebuildLayoutsMenu <windowPath>`

---
Last updated: 2025-12-01
