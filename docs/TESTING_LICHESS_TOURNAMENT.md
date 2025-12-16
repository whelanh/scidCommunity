# Testing Guide: Live Lichess Tournament Monitor

## Pre-Test Checklist

1. Ensure you're on the `add_live_lichess_tournament_monitor` branch
2. Rebuild scidCommunity to load the new Tcl modules
3. Have a web browser ready to reference active Lichess broadcasts
4. Verify curl/wget is installed on your system

## Test Scenarios

### Test 1: Basic Tournament Selection
**Objective:** Verify broadcast fetching and tournament selection dialog

**Steps:**
1. Launch scidCommunity
2. Click `File` → `Open Lichess Tournament`
3. Wait for broadcasts to load (~2-3 seconds)
4. Verify a list of tournaments appears in the dialog
5. Check that at least one tournament is listed

**Expected Result:**
- Dialog appears with tournament names
- No error messages
- Broadcast links are valid (can verify by clicking one in browser)

**Failure Cases:**
- Empty list with error → check internet/Lichess accessibility
- Menu item disabled → wait longer or check network

---

### Test 2: Tournament Download and Games List
**Objective:** Verify PGN download and Games List display

**Steps:**
1. From Test 1, select an available tournament
2. Click "Open Tournament" button
3. Wait for PGN download (progress bar shows activity)
4. Games List window opens automatically

**Expected Result:**
- PGN file downloads successfully
- Games List window shows tournament games
- Each game has headers (White, Black, Result, etc.)
- No crash or error dialogs

**Failure Cases:**
- Download timeout → check network
- Games List doesn't open → check scidCommunity main window state
- No games in list → tournament may be empty or parsing failed

---

### Test 3: Live Game Polling - Initial Setup
**Objective:** Verify polling starts when opening a live game

**Prerequisite:** Have an active tournament loaded from Test 2

**Steps:**
1. From Games List, find a game with `Result` = "*" (ongoing)
2. Double-click to open the game in the PGN Window
3. Wait 5 seconds and observe the game

**Expected Result:**
- Game opens in PGN Window without errors
- First few moves are displayed
- No immediate error messages
- Game remains responsive

**Failure Cases:**
- PGN window doesn't open → check if game file is valid
- Error about GameURL → game not from tournament mode (expected)

---

### Test 4: Live Move Appending - 3-Minute Cycle
**Objective:** Verify new moves are appended automatically

**Prerequisite:** Have a live game open from Test 3

**Steps:**
1. Note the current move number/position shown in PGN Window
2. Check Lichess broadcast directly in browser to see if new moves exist
3. Wait 3 minutes (180 seconds)
4. Check PGN Window again

**Expected Result:**
- If new moves were played, they appear in the game
- No pop-ups or disruptive messages
- Game still shows in correct position
- User annotations (if any) are preserved

**Failure Cases:**
- Polling doesn't start → check browser console for errors
- Moves aren't appended → check game still has Result = "*"
- Moves are duplicated → contact developers

---

### Test 5: Polling Stops on Game Completion
**Objective:** Verify polling stops when game finishes

**Prerequisite:** Have a live game open from Test 4

**Steps:**
1. Keep game open in PGN Window
2. Watch Lichess broadcast page - wait for game to complete
3. When Result changes from "*" to "1-0" / "0-1" / "1/2-1/2"
4. Wait for next polling cycle (3 minutes)
5. Check if final moves appear

**Expected Result:**
- Polling completes one final cycle after game ends
- Polling stops (no further updates)
- Game displays final position correctly

**Failure Cases:**
- Polling continues after completion → implementation bug
- Final moves missing → polling may have failed on last cycle

---

### Test 6: Polling Stops on PGN Window Close
**Objective:** Verify polling timer is cancelled when window closes

**Prerequisite:** Have a live game open from Test 3

**Steps:**
1. Open PGN Window with live game
2. Let it run for 30+ seconds
3. Close the PGN Window (File → Close PGN Window)
4. Monitor system resources / check for lingering timers
5. Reopen PGN Window and select same game

**Expected Result:**
- PGN Window closes without errors
- Polling timer cancels properly
- No background processes continue
- Game can be reopened and polling restarts

**Failure Cases:**
- Window hangs on close → timer not cancelled
- Error dialog on close → exception in cleanup code

---

### Test 7: Multiple Tournament Games in Sequence
**Objective:** Verify polling handles switching between games correctly

**Prerequisite:** Multiple live games from same tournament

**Steps:**
1. Open Game A (live) in PGN Window
2. Wait 10-15 seconds (partial polling cycle)
3. Go back to Games List
4. Open Game B (different live game)
5. Switch back to Game A
6. Wait for full 3-minute cycle

**Expected Result:**
- Switching games cancels old polling
- New game starts its own polling timer
- Each game tracks moves independently
- No timer conflicts or memory leaks

**Failure Cases:**
- Multiple timers running simultaneously → memory leak
- Wrong game gets updates → timer not properly switched

---

### Test 8: Non-Tournament Game Opening
**Objective:** Verify polling doesn't activate for non-tournament games

**Steps:**
1. Open a regular game from your database (not from tournament)
2. Open it in PGN Window
3. Wait several seconds

**Expected Result:**
- Game opens normally
- No polling activity starts
- No error messages

**Failure Cases:**
- Unexpected polling messages → filtering logic broken
- Error about GameURL → should fail gracefully

---

### Test 9: Finished Game in Tournament List
**Objective:** Verify polling doesn't start for completed games

**Prerequisite:** Tournament with completed games (Result = "1-0" etc.)

**Steps:**
1. From Games List, find a finished game
2. Open in PGN Window
3. Wait 5+ seconds

**Expected Result:**
- Game opens normally
- No polling activity
- Full game displayed without updates

**Failure Cases:**
- Polling attempts to start → Result check failed
- Error message → unexpected condition

---

### Test 10: Menu Item State Management
**Objective:** Verify menu item enable/disable during operations

**Steps:**
1. Click `File` → `Open Lichess Tournament`
2. Immediately click `File` menu again
3. Check if "Open Lichess Tournament" is disabled during download

**Expected Result:**
- Menu item is **disabled** during fetch/download
- Menu item becomes **enabled** after completion
- User cannot initiate multiple simultaneous downloads

**Failure Cases:**
- Menu item remains enabled → allows duplicate operations
- Menu item stuck disabled → operation hanging

---

## Error Scenario Tests

### Error Test 1: No Internet Connection
**Steps:**
1. Disconnect from internet
2. Click `File` → `Open Lichess Tournament`

**Expected Result:**
- Error message: "Error fetching broadcasts list"
- Menu item re-enabled
- Application remains stable

---

### Error Test 2: Lichess Server Unavailable
**Steps:**
1. Add Lichess IP to hosts file as unreachable (or wait for downtime)
2. Click `File` → `Open Lichess Tournament`

**Expected Result:**
- Timeout or connection error message
- Menu item re-enabled after timeout
- No crash

---

### Error Test 3: Invalid PGN during Polling
**Steps:**
1. Have game open with polling active
2. Wait 3 minutes for poll cycle
3. Manually corrupt the temp PGN file (simulate bad download)

**Expected Result:**
- Move parsing fails silently
- Polling continues on next cycle
- Game remains open and responsive

---

## Performance/Load Tests

### Performance Test 1: Many Games in Tournament
**Objective:** Verify performance with large tournament (50+ games)

**Steps:**
1. Select tournament with 50+ games
2. Open Games List
3. Click through several games quickly
4. Measure load times

**Expected Result:**
- Games List loads within 5 seconds
- Each game opens in <1 second
- No UI lag when switching

---

### Performance Test 2: Long-Running Poll Cycle
**Objective:** Verify polling remains responsive over hours

**Steps:**
1. Open live game
2. Let it run for 2+ hours
3. Periodically check if moves are still being appended
4. Monitor memory usage

**Expected Result:**
- Moves continue to append regularly
- Memory usage stable (no growth)
- Application responsive to user input

---

## Documentation Validation

- [ ] Language strings are correct and complete
- [ ] Error messages are user-friendly
- [ ] Menu items have correct accelerators/underlines
- [ ] Implementation matches lichessStreamingPlan.txt requirements

## Final Checklist

- [ ] All 10 main test scenarios pass
- [ ] At least 3 error scenarios handled gracefully
- [ ] Performance tests show no degradation
- [ ] Code compiles with no Tcl syntax errors
- [ ] Git history is clean with meaningful commits
- [ ] Documentation is complete and accurate

---

## Known Limitations / Future Work

1. **Move Parsing:** Uses simple regex; may not handle complex PGN perfectly
2. **Polling Interval:** Fixed at 3 minutes; not user-configurable
3. **Tournament Metadata:** Only extracts URLs; doesn't parse round/player info
4. **Broadcast Page Parsing:** Regex-based; may break if Lichess HTML structure changes
5. **Offline Support:** Requires active internet for polling (expected behavior)

---

## Debugging Tips

If tests fail, check:

1. **Tcl Syntax:** Use `tclsh` to verify module loads
   ```bash
   tclsh tcl/tools/lichess_tournament.tcl
   ```

2. **Network:** Verify curl/wget works
   ```bash
   curl -L https://lichess.org/broadcast?ref=offerspill.com | head -50
   ```

3. **Logs:** Check scidCommunity console for error messages

4. **File Permissions:** Verify temp directory is writable
   ```bash
   ls -la /tmp/ | grep scid
   ```

5. **Timer Issues:** Add debug output to startGamePolling() / pollGameUpdates()
