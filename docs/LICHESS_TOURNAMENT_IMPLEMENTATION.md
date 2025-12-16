# Live Lichess Tournament Monitor Implementation

## Overview
A complete feature to monitor and display live tournament games from Lichess broadcasts within scidCommunity.

## Files Modified/Created

### New Files
- **tcl/tools/lichess_tournament.tcl** (552 lines)
  - Core module implementing all tournament monitoring functionality

### Modified Files
- **tcl/menus.tcl** - Added "Open Lichess Tournament" menu item in File menu
- **tcl/lang/english.tcl** - Added language strings for the new feature
- **tcl/start.tcl** - Added sourcing of lichess_tournament.tcl module
- **tcl/windows/pgn.tcl** - Added hooks to trigger polling when games are opened and stop on close

## Architecture

### Main Components

#### 1. Tournament Selection Workflow
- `openTournament()` - Entry point from File menu
- `fetchBroadcastsList()` - Downloads Lichess broadcasts page using curl/wget/PowerShell
- `parseBroadcasts()` - Extracts tournament links using regex pattern matching
- `showTournamentSelector()` - Displays a dialog listbox for user selection
- `selectTournament()` - Handles selection and initiates download

#### 2. Games List Display
- `downloadTournamentGames()` - Downloads full tournament PGN by appending ".pgn" to broadcast URL
- Opens PGN in Games List window with `tournamentModeActive` flag set
- Enables menu item disable/enable for UX consistency

#### 3. Live Game Polling (3-minute cycles)
- `onGameOpened()` - Hook called from pgn.tcl::Refresh when game opens in PGN window
  - Checks if game is from Lichess tournament mode
  - Verifies game has `[Result "*"]` (ongoing)
  - Initiates polling for that specific game
  
- `startGamePolling()` - Sets up monitoring for a single game
  - Extracts study and chapter IDs from `[GameURL]` header
  - Constructs study URL: `https://lichess.org/study/<study_id>/<chapter_id>.pgn`
  - Schedules initial 180-second (3-minute) polling timer
  - Stores game polling metadata in `gamePollingData` dict

- `pollGameUpdates()` - Core polling logic (runs every 3 minutes)
  - Downloads updated game PGN from study URL
  - Parses moves using `extractMovesFromPgn()`
  - Compares with current game's move count
  - Appends new moves using `sc_move add` to preserve user annotations
  - Checks game result; stops if finished
  - Reschedules next poll via `scheduleNextPoll()`

#### 4. Polling Control
- `scheduleNextPoll()` - Reschedules 3-minute timer
- `stopGamePolling()` - Cancels active timer (called when:
  - PGN window closes (via pgn.tcl menu hook)
  - User switches to different game from non-tournament source
  - Game result changes from `*` to finished)

#### 5. Utility Functions
- `downloadWithHTTP()` - Fallback HTTP download using Tcl http package + TLS
- `getTempDir()` - Reuses from ::lichess namespace (cross-platform temp directory)
- `extractGameId()` - Parses game ID from URL
- `extractMovesFromPgn()` - Regex-based move list extraction from PGN

## Key Design Decisions

1. **Reuse of Existing Infrastructure**
   - Leverages `::lichess::getTempDir()` for temp files
   - Uses same download patterns (curl/wget/PowerShell) as TWIC/Lichess import
   - Integrates with existing PGN window architecture

2. **Non-Intrusive Integration**
   - PGN window hook uses `catch{}` to gracefully handle missing module
   - Polling only active for games from tournament mode
   - No menu item state changes outside of actual download activity

3. **Move Appending vs. Replacement**
   - Uses `sc_move add` instead of replacing game to preserve user comments/variations
   - Compares move counts to detect new moves
   - Graceful degradation if move parsing fails (continues polling)

4. **Error Handling**
   - Network failures silently retry on next poll cycle (non-blocking)
   - Download errors shown to user with appropriate messaging
   - All file operations wrapped in `catch{}` blocks

5. **Memory Management**
   - Temp files cleaned up after download
   - Timers explicitly cancelled on close
   - Polling data cleared when polling stops

## Usage Flow

1. **User initiates:**
   - File → "Open Lichess Tournament"
   
2. **Tournament selection:**
   - System fetches broadcasts from lichess.org/broadcast
   - User selects from available tournaments
   - PGN downloaded and Games List opened
   
3. **Game monitoring:**
   - User opens a game from tournament list in PGN window
   - System detects live game (Result = "*")
   - Polling starts immediately, then every 3 minutes
   - New moves automatically appended as they're played
   
4. **Monitoring stops when:**
   - User closes PGN window
   - User switches to non-tournament game
   - Game result is no longer "*"
   - User switches database

## Technical Specifications

- **Polling Interval:** 180 seconds (3 minutes) - per requirements
- **Move Detection:** Regex-based parsing; handles algebraic notation
- **URL Parsing:** Extracts last two path segments for study/chapter IDs
- **HTML Parsing:** Regex pattern for broadcast link extraction
- **Download Methods:** curl (preferred) → wget → PowerShell → Tcl http fallback

## Testing Recommendations

1. **Happy Path:**
   - Select active tournament
   - Open live game
   - Verify moves append after 3 minutes
   - Verify annotation preservation

2. **Edge Cases:**
   - No broadcasts available (show message)
   - Network timeout during download (graceful error)
   - Game finishes during monitoring (polling stops)
   - User opens finished game (polling not started)
   - Switch between live and finished games (timers properly managed)

3. **Integration:**
   - Menu item enable/disable during downloads
   - PGN window closure halts polling
   - Game list from other sources don't trigger polling
   - Multiple tournaments in sequence work correctly

## Future Enhancements

- Configurable polling interval
- Visual indicator of polling status in PGN window title
- Persistent tournament history in recent menu
- Broader HTML parsing for tournament metadata (round, players)
- Move annotations from Lichess broadcast analysis
