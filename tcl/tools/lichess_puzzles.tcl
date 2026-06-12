# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later

############################################################
### Lichess Puzzles
### Fetches and displays Lichess chess puzzles via the
### Lichess API.  Users can solve the daily puzzle or
### request themed/difficulty-filtered puzzles.
### https://lichess.org/api#tag/puzzles

namespace eval ::lichess_puzzles {

    # Persisted options (saved via Options > Save Options)
    options.store ::lichess_puzzles::apiToken ""
    options.store ::lichess_puzzles::difficulty "normal"
    options.store ::lichess_puzzles::color "white"
    options.store ::lichess_puzzles::theme ""

    # -------------------------------------------------------
    # Theme dict: display-name -> Lichess API angle key
    # Ordered as: game-phase first, then motifs, then mate
    # patterns, then length/master categories.
    # -------------------------------------------------------
    variable themeNames [list \
        "Opening" "Middlegame" "Endgame" \
        "Rook endgame" "Bishop endgame" "Pawn endgame" \
        "Knight endgame" "Queen endgame" "Queen and Rook" \
        "Advanced pawn" "Advantage" \
        "Attacking f2 or f7" "Attraction" \
        "Capture the defender" "Castling" "Clearance" \
        "Collinear move" "Crushing" "Defensive move" \
        "Deflection" "Discovered attack" "Discovered check" \
        "Double check" "Equality" "Exposed king" "Fork" \
        "Hanging piece" "Interference" "Intermezzo" \
        "Kingside attack" "Pin" "Promotion" \
        "Queenside attack" "Quiet move" "Sacrifice" \
        "Skewer" "Trapped piece" "Underpromotion" \
        "X-Ray attack" "Zugzwang" \
        "Anastasia's mate" "Arabian mate" "Back rank mate" \
        "Balestra mate" "Blind Swine mate" "Boden's mate" \
        "Checkmate" "Corner mate" "Double bishop mate" \
        "Dovetail mate" "Epaulette mate" "Hook mate" \
        "Kill box mate" "Mate in 1" "Mate in 2" \
        "Mate in 3" "Mate in 4" "Mate in 5 or more" \
        "Morphy's mate" "Opera mate" "Pillsbury's mate" \
        "Smothered mate" "Swallow's tail mate" \
        "Triangle mate" "Vukovi\u0107 mate" \
        "Long puzzle" "One-move puzzle" "Short puzzle" \
        "Very long puzzle" "Master games" \
        "Master vs Master games" "Super GM games" \
        "Player games" \
    ]
    variable themeKeys [list \
        opening middlegame endgame \
        rookEndgame bishopEndgame pawnEndgame \
        knightEndgame queenEndgame queenRookEndgame \
        advancedPawn advantage \
        attackingF2F7 attraction \
        capturingDefender castling clearance \
        collinearMove crushing defensiveMove \
        deflection discoveredAttack discoveredCheck \
        doubleCheck equality exposedKing fork \
        hangingPiece interference intermezzo \
        kingsideAttack pin promotion \
        queensideAttack quietMove sacrifice \
        skewer trappedPiece underPromotion \
        xRayAttack zugzwang \
        anastasiaMate arabianMate backRankMate \
        balestraMate blindSwineMate bodenMate \
        mate cornerMate doubleBishopMate \
        dovetailMate epauletteMate hookMate \
        killBoxMate mateIn1 mateIn2 \
        mateIn3 mateIn4 mateIn5 \
        morphysMate operaMate pillsburysMate \
        smotheredMate swallowstailMate \
        triangleMate vukovicMate \
        long oneMove short \
        veryLong master \
        masterVsMaster superGM \
        playerGames \
    ]

    # -------------------------------------------------------
    # Runtime state
    # -------------------------------------------------------
    variable puzzleData
    variable solutionMoves {}
    variable solutionIndex 0
    variable isDaily 0
    variable puzzleActive 0
    variable prevBase ""
    variable prevGameNum 0
    variable prevFen ""
    variable computerMoving 0
    variable hintSquares {}
    variable pendingSolve ""
    variable pendingComp ""

    # Seen puzzle IDs (for avoiding repeats)
    variable seenFile [file join $::scidDataDir "lichess_puzzles_seen.dat"]
    variable seenIds [dict create]

    # Pre-fetched puzzle queue
    variable puzzleQueue [list]

    # -------------------------------------------------------
    # start  -- main entry point from the Play menu
    # -------------------------------------------------------
    proc start {} {
        variable puzzleActive
        if {$puzzleActive} {
            if {[winfo exists .lichessPuzzlesWin]} {
                raise .lichessPuzzlesWin
                focus .lichessPuzzlesWin
            }
            return
        }
        createWindow
        fetchDailyPuzzle
    }

    # -------------------------------------------------------
    # seen IDs  -- load / save / check puzzle IDs already seen
    # -------------------------------------------------------
    proc loadSeenIds {} {
        variable seenFile
        variable seenIds
        if {[file exists $seenFile]} {
            if {![catch {set data [read [open $seenFile r]]}]} {
                catch {close [open $seenFile r]}
                foreach id [split $data "\n"] {
                    set id [string trim $id]
                    if {$id ne ""} { dict set seenIds $id 1 }
                }
            }
        }
    }

    proc saveSeenIds {} {
        variable seenFile
        variable seenIds
        catch {
            set fd [open $seenFile w]
            puts $fd [join [dict keys $seenIds] "\n"]
            close $fd
        }
    }

    proc isSeen {id} {
        variable seenIds
        return [dict exists $seenIds $id]
    }

    proc markSeen {id} {
        variable seenIds
        dict set seenIds $id 1
        saveSeenIds
    }

    # -------------------------------------------------------
    # createWindow  -- build the control / info toplevel
    # -------------------------------------------------------
    proc createWindow {} {
        variable puzzleActive

        # Reuse existing Lichess API token from the Opening Explorer if set
        if {$::lichess_puzzles::apiToken eq ""} {
            if {[info exists ::lichess_openex::apiToken] && $::lichess_openex::apiToken ne ""} {
                set ::lichess_puzzles::apiToken $::lichess_openex::apiToken
            }
        }

        set w .lichessPuzzlesWin
        if {[winfo exists $w]} { destroy $w }

        toplevel $w
        wm title $w [tr LichessPuzzlesTitle]
        wm resizable $w 1 1
        if {[winfo exists .]} { wm transient $w . }
        wm protocol $w WM_DELETE_WINDOW [list ::lichess_puzzles::stop]

        # -- top info area (puzzle details) --
        ttk::frame $w.info -padding 8
        pack $w.info -fill x

        ttk::label $w.info.title -text [tr LichessPuzzlesDailyTitle] -font font_Bold
        grid $w.info.title -row 0 -column 0 -columnspan 2 -sticky w -pady {0 4}

        # puzzle metadata displayed as a text widget for easy wrapping
        text $w.info.detail -wrap word -width 50 -height 11 -state disabled \
            -font font_Small -borderwidth 2 -relief sunken -yscrollcommand "$w.info.sby set"
        ttk::scrollbar $w.info.sby -orient vertical -command "$w.info.detail yview"
        grid $w.info.detail -row 1 -column 0 -sticky nsew
        grid $w.info.sby   -row 1 -column 1 -sticky ns
        grid rowconfigure    $w.info 1 -weight 1
        grid columnconfigure $w.info 0 -weight 1

        # -- separator --
        ttk::separator $w.sep1 -orient horizontal
        pack $w.sep1 -fill x -padx 8 -pady 4

        # -- controls area --
        ttk::frame $w.controls -padding {8 0}
        pack $w.controls -fill x

        set row 0

        # Difficulty dropdown
        ttk::label $w.controls.difflbl -text [tr LichessPuzzlesDifficulty]
        set diffs [list \
            [tr LichessPuzzlesDiffEasiest] \
            [tr LichessPuzzlesDiffEasiestThenNormal] \
            [tr LichessPuzzlesDiffNormal] \
            [tr LichessPuzzlesDiffNormalThenHardest] \
            [tr LichessPuzzlesDiffHardest] \
        ]
        set diffVals [list easiest easiestThenNormal normal normalThenHardest hardest]
        ttk::combobox $w.controls.diff -width 22 -state readonly \
            -values $diffs -textvariable ::lichess_puzzles::difficultyLabel
        set idx [lsearch -exact $diffVals $::lichess_puzzles::difficulty]
        if {$idx < 0} { set idx 2 }
        $w.controls.diff current $idx
        bind $w.controls.diff <<ComboboxSelected>> ::lichess_puzzles::onDiffChange
        grid $w.controls.difflbl -row $row -column 0 -sticky w -padx {0 8} -pady 2
        grid $w.controls.diff    -row $row -column 1 -sticky w -pady 2
        incr row

        # Color dropdown — for next puzzle fetch
        ttk::label $w.controls.colorlbl -text [tr LichessPuzzlesNextColor]
        ttk::combobox $w.controls.color -width 10 -state readonly \
            -values [list [tr White] [tr Black]] \
            -textvariable ::lichess_puzzles::colorLabel
        if {$::lichess_puzzles::color eq "black"} {
            $w.controls.color current 1
        } else {
            $w.controls.color current 0
        }
        bind $w.controls.color <<ComboboxSelected>> ::lichess_puzzles::onColorChange
        grid $w.controls.colorlbl -row $row -column 0 -sticky w -padx {0 8} -pady 2
        grid $w.controls.color    -row $row -column 1 -sticky w -pady 2
        incr row

        # Theme dropdown
        ttk::label $w.controls.themelbl -text [tr LichessPuzzlesTheme]
        set themeDisplay [concat [list [tr LichessPuzzlesMix]] $::lichess_puzzles::themeNames]
        ttk::combobox $w.controls.theme -width 22 -state readonly \
            -values $themeDisplay -textvariable ::lichess_puzzles::themeLabel
        $w.controls.theme current 0
        bind $w.controls.theme <<ComboboxSelected>> ::lichess_puzzles::onThemeChange
        grid $w.controls.themelbl -row $row -column 0 -sticky w -padx {0 8} -pady 2
        grid $w.controls.theme    -row $row -column 1 -columnspan 2 -sticky ew -pady 2
        incr row

        # Token entry
        ttk::label $w.controls.tokenlbl -text [tr LichessApiTokenReq]
        ttk::entry $w.controls.tokenentry -width 30 -textvariable ::lichess_puzzles::apiToken -show "*"
        grid $w.controls.tokenlbl   -row $row -column 0 -sticky w -padx {0 8} -pady 2
        grid $w.controls.tokenentry -row $row -column 1 -columnspan 2 -sticky ew -pady 2
        incr row

        grid columnconfigure $w.controls 1 -weight 1

        # -- separator --
        ttk::separator $w.sep2 -orient horizontal
        pack $w.sep2 -fill x -padx 8 -pady 4

        # -- hint / solution buttons --
        ttk::frame $w.hintbar -padding {8 0 8 4}
        pack $w.hintbar -fill x
        ttk::button $w.hintbar.hint -text [tr LichessPuzzlesHint] \
            -command ::lichess_puzzles::showHint
        ttk::button $w.hintbar.solution -text [tr LichessPuzzlesViewSolution] \
            -command ::lichess_puzzles::showSolution
        pack $w.hintbar.solution -side right -padx 5
        pack $w.hintbar.hint     -side right -padx 5

        # -- new puzzle / close buttons --
        ttk::frame $w.buttons -padding {8 0 8 8}
        pack $w.buttons -fill x
        ttk::button $w.buttons.new -text [tr LichessPuzzlesNew] \
            -command ::lichess_puzzles::fetchNextPuzzle
        ttk::button $w.buttons.close -text [tr Close] \
            -command ::lichess_puzzles::stop
        pack $w.buttons.close -side right -padx 5
        pack $w.buttons.new   -side right -padx 5

        # -- message area --
        ttk::frame $w.msgframe -padding {8 0 8 4}
        pack $w.msgframe -fill x
        ttk::label $w.msgframe.msg -text "" -font font_Small -wraplength 400
        pack $w.msgframe.msg -fill x

        bind $w <Escape> [list ::lichess_puzzles::stop]

        # Center window
        update idletasks
        set x [expr {([winfo screenwidth $w] - [winfo reqwidth $w]) / 2}]
        set y [expr {([winfo screenheight $w] - [winfo reqheight $w]) / 2}]
        wm geometry $w "+$x+$y"

        set ::lichess_puzzles::puzzleActive 1

        # Set up the initial difficulty label
        ::lichess_puzzles::onDiffChange
    }

    # -------------------------------------------------------
    # onDiffChange -- sync difficulty value with combobox
    # -------------------------------------------------------
    proc onDiffChange {} {
        set diffs [list easiest easiestThenNormal normal normalThenHardest hardest]
        set idx [.lichessPuzzlesWin.controls.diff current]
        if {$idx >= 0 && $idx < [llength $diffs]} {
            set ::lichess_puzzles::difficulty [lindex $diffs $idx]
        }
    }

    # -------------------------------------------------------
    # onColorChange -- sync color value with combobox
    # -------------------------------------------------------
    proc onColorChange {} {
        set idx [.lichessPuzzlesWin.controls.color current]
        if {$idx == 1} {
            set ::lichess_puzzles::color "black"
        } else {
            set ::lichess_puzzles::color "white"
        }
    }

    # -------------------------------------------------------
    # onThemeChange -- sync theme value with combobox
    # -------------------------------------------------------
    proc onThemeChange {} {
        set idx [.lichessPuzzlesWin.controls.theme current]
        if {$idx == 0} {
            set ::lichess_puzzles::theme ""
        } else {
            set ::lichess_puzzles::theme [lindex $::lichess_puzzles::themeKeys [expr {$idx - 1}]]
        }
    }

    # -------------------------------------------------------
    # fetchDailyPuzzle  -- auto-loaded on window open
    # -------------------------------------------------------
    proc fetchDailyPuzzle {} {
        set w .lichessPuzzlesWin
        if {![winfo exists $w]} { return }

        set ::lichess_puzzles::isDaily 1

        $w.info.title configure -text [tr LichessPuzzlesDailyTitle]
        setMsg [tr LichessPuzzlesQuerying]

        set url "https://lichess.org/api/puzzle/daily"
        set token $::lichess_puzzles::apiToken

        set result ""
        if {[catch {set result [::lichess_puzzles::httpGet $url $token]} err]} {
            setMsg [format [tr LichessPuzzlesFailed] $err]
            return
        }

        if {![::lichess_puzzles::parseAndLoad $result]} {
            setMsg [format [tr LichessPuzzlesFailed] [tr LichessPuzzlesParseError]]
        }
    }

    # -------------------------------------------------------
    # fetchNextPuzzle  -- user presses "New Puzzle" button
    # -------------------------------------------------------
    proc fetchNextPuzzle {} {
        variable puzzleData
        variable puzzleQueue
        set w .lichessPuzzlesWin
        if {![winfo exists $w]} { return }

        set ::lichess_puzzles::isDaily 0

        $w.info.title configure -text [tr LichessPuzzlesTitle]
        setMsg [tr LichessPuzzlesQuerying]

        set token $::lichess_puzzles::apiToken
        if {[string trim $token] eq ""} {
            tk_messageBox -icon warning -type ok -title [tr LichessPuzzlesTitle] \
                -message [subst -nocommands -novariables [tr LichessPuzzlesTokenNeeded]] -parent $w
            return
        }

        set colorIdx [$w.controls.color current]
        set reqColor [expr {$colorIdx == 1 ? "black" : "white"}]
        set reqTheme $::lichess_puzzles::theme
        set reqDiff  $::lichess_puzzles::difficulty

        # Try to get a puzzle from the queue first
        set gotData 0
        while {[llength $puzzleQueue] > 0} {
            set entry [lindex $puzzleQueue 0]
            set puzzleQueue [lrange $puzzleQueue 1 end]
            lassign $entry entryPuzzlePart entryGamePart entryId
            if {![::lichess_puzzles::isSeen $entryId]} {
                set puzzlePart $entryPuzzlePart
                set gamePart   $entryGamePart
                set puzzleId   $entryId
                set gotData 1
                break
            }
        }

        # If queue is running low, trigger a background refill
        if {[llength $puzzleQueue] < 5} {
            after idle [list ::lichess_puzzles::refillQueue $reqDiff $reqTheme $reqColor $token]
        }

        # If no queued puzzle, fall back to individual jitter (difficulty only)
        if {!$gotData} {
            set jitterDiffs [list $reqDiff]
            foreach alt {easiestThenNormal normalThenHardest hardest easiest} {
                if {$alt ne $reqDiff} { lappend jitterDiffs $alt }
            }
            foreach diff $jitterDiffs {
                set url "https://lichess.org/api/puzzle/next?"
                append url "difficulty=$diff"
                if {$reqTheme ne ""} {
                    append url "&angle=[::lichess_puzzles::urlEncode $reqTheme]"
                }
                append url "&color=$reqColor"

                set tmpResult ""
                if {[catch {set tmpResult [::lichess_puzzles::httpGet $url $token]}]} {
                    continue
                }
                set pp [::lichess_puzzles::extractJsonObject $tmpResult "puzzle"]
                set gp [::lichess_puzzles::extractJsonObject $tmpResult "game"]
                set newId ""
                if {$pp ne ""} { regexp {"id"\s*:\s*"([^"]*)"} $pp -> newId }
                if {$newId ne "" && ![::lichess_puzzles::isSeen $newId]} {
                    set puzzlePart $pp
                    set gamePart   $gp
                    set puzzleId   $newId
                    set gotData 1
                    break
                }
            }
        }

        if {!$gotData} {
            setMsg [tr LichessPuzzlesNoNew]
            return
        }

        # Fetch FEN from /api/puzzle/{id} if needed
        set result ""
        set fenIncluded 0
        catch { regexp {"fen"\s*:\s*"([^"]*)"} $puzzlePart -> fenVal }
        if {![info exists fenVal] || $fenVal eq ""} {
            if {$puzzleId ne ""} {
                set fenUrl "https://lichess.org/api/puzzle/$puzzleId"
                set fenResult ""
                if {![catch {set fenResult [::lichess_puzzles::httpGet $fenUrl $token]}]} {
                    set fenPart ""
                    if {[regexp {"puzzle"\s*:\s*\{$fenResult} $fenResult]} {
                        set fenPart [::lichess_puzzles::extractJsonObject $fenResult "puzzle"]
                    } else {
                        set fenPart $fenResult
                    }
                    regexp {"fen"\s*:\s*"([^"]*)"} $fenPart -> fenVal
                }
            }
        }
        if {[info exists fenVal] && $fenVal ne ""} {
            set puzzlePart [string trimright $puzzlePart "\}"]
            append puzzlePart ",\"fen\":\"$fenVal\"\}"
            set result "\{\"puzzle\":$puzzlePart"
            if {$gamePart ne ""} {
                append result ",\"game\":$gamePart"
            }
            append result "\}"
        } else {
            set result "\{\"puzzle\":$puzzlePart"
            if {$gamePart ne ""} {
                append result ",\"game\":$gamePart"
            }
            append result "\}"
        }

        if {[info exists result] && $result ne ""} {
            if {![::lichess_puzzles::parseAndLoad $result]} {
                setMsg [format [tr LichessPuzzlesFailed] [tr LichessPuzzlesParseError]]
            }
        } else {
            setMsg [format [tr LichessPuzzlesFailed] [tr LichessPuzzlesParseError]]
        }
    }

    # -------------------------------------------------------
    # refillQueue  -- batch-fetch puzzles from Lichess
    # -------------------------------------------------------
    proc refillQueue {diff theme color token} {
        variable puzzleQueue
        if {[llength $puzzleQueue] >= 10} { return }

        set anglePath "mix"
        if {$theme ne ""} {
            set anglePath $theme
        }

        set url "https://lichess.org/api/puzzle/batch/$anglePath?difficulty=$diff&nb=30"
        if {$color ne ""} {
            append url "&color=$color"
        }

        set batchResult ""
        if {[catch {set batchResult [::lichess_puzzles::httpGet $url $token]}]} {
            return
        }

        # Parse batch response: {"puzzles": [{puzzle:{...}, game:{...}}, ...]}
        if {[regexp -indices {"puzzles"\s*:\s*\[} $batchResult match]} {
            set arrStart [lindex $match 1]
            set remaining [string range $batchResult $arrStart end]
            set depth 1; set pos 1
            set len [string length $remaining]
            while {$pos < $len && $depth > 0} {
                set ch [string index $remaining $pos]
                if {$ch eq "\["} { incr depth }
                if {$ch eq "\]"} { incr depth -1 }
                incr pos
            }
            set arrStr [string range $remaining 1 [expr {$pos - 2}]]
            set entries [::lichess_puzzles::splitJsonObjects $arrStr]
            foreach entry $entries {
                set pp [::lichess_puzzles::extractJsonObject $entry "puzzle"]
                set gp [::lichess_puzzles::extractJsonObject $entry "game"]
                set eid ""
                if {$pp ne ""} { regexp {"id"\s*:\s*"([^"]*)"} $pp -> eid }
                if {$eid ne "" && ![::lichess_puzzles::isSeen $eid]} {
                    lappend puzzleQueue [list $pp $gp $eid]
                }
            }
        }
    }

    # -------------------------------------------------------
    # parseAndLoad  -- parse JSON, display info, load board
    # -------------------------------------------------------
    proc parseAndLoad {jsonData} {
        variable puzzleData
        variable solutionMoves
        variable solutionIndex
        variable prevBase
        variable prevGameNum
        variable prevFen

        # Parse puzzle wrapper
        set puzzlePart ""
        set gamePart ""
        if {[regexp {"puzzle"\s*:\s*(\{)} $jsonData]} {
            set puzzlePart [::lichess_puzzles::extractJsonObject $jsonData "puzzle"]
            set gamePart   [::lichess_puzzles::extractJsonObject $jsonData "game"]
        } else {
            # Some endpoints return the puzzle object directly
            set puzzlePart $jsonData
            set gamePart ""
        }

        if {$puzzlePart eq ""} {
            return 0
        }

        # Parse puzzle fields
        set puzzleData(puzzleId) ""
        set puzzleData(rating) ""
        set puzzleData(plays) ""
        set puzzleData(initialPly) 0
        set puzzleData(solution) {}
        set puzzleData(themes) {}
        set puzzleData(fen) ""

        regexp {"id"\s*:\s*"([^"]*)"} $puzzlePart -> puzzleData(puzzleId)
        regexp {"rating"\s*:\s*(\d+)} $puzzlePart -> puzzleData(rating)
        regexp {"plays"\s*:\s*(\d+)} $puzzlePart -> puzzleData(plays)
        regexp {"initialPly"\s*:\s*(\d+)} $puzzlePart -> puzzleData(initialPly)
        regexp {"fen"\s*:\s*"([^"]*)"} $puzzlePart -> puzzleData(fen)

        # Extract solution array
        if {[regexp -indices {"solution"\s*:\s*\[} $puzzlePart match]} {
            set arrStart [lindex $match 1]
            set remaining [string range $puzzlePart $arrStart end]
            set depth 1; set pos 1
            while {$pos < [string length $remaining] && $depth > 0} {
                set ch [string index $remaining $pos]
                if {$ch eq "\["} { incr depth }
                if {$ch eq "\]"} { incr depth -1 }
                incr pos
            }
            set arrStr [string range $remaining 1 [expr {$pos - 2}]]
            # Parse individual UCI strings
            set moves {}
            foreach {_ move} [regexp -all -inline {"([^"]*)"} $arrStr] {
                lappend moves $move
            }
            set puzzleData(solution) $moves
        }

        # Extract themes array
        if {[regexp -indices {"themes"\s*:\s*\[} $puzzlePart match]} {
            set arrStart [lindex $match 1]
            set remaining [string range $puzzlePart $arrStart end]
            set depth 1; set pos 1
            while {$pos < [string length $remaining] && $depth > 0} {
                set ch [string index $remaining $pos]
                if {$ch eq "\["} { incr depth }
                if {$ch eq "\]"} { incr depth -1 }
                incr pos
            }
            set arrStr [string range $remaining 1 [expr {$pos - 2}]]
            set themes {}
            foreach {_ t} [regexp -all -inline {"([^"]*)"} $arrStr] {
                lappend themes $t
            }
            set puzzleData(themes) $themes
        }

        # Parse game fields
        if {$gamePart ne ""} {
            set puzzleData(gameId) ""
            set puzzleData(perfName) ""
            set puzzleData(clock) ""
            set puzzleData(rated) ""
            set puzzleData(pgn) ""
            set puzzleData(whiteName) ""
            set puzzleData(whiteRating) ""
            set puzzleData(blackName) ""
            set puzzleData(blackRating) ""

            regexp {"id"\s*:\s*"([^"]*)"} $gamePart -> puzzleData(gameId)
            regexp {"clock"\s*:\s*"([^"]*)"} $gamePart -> puzzleData(clock)
            regexp {"rated"\s*:\s*(true|false)} $gamePart -> puzzleData(rated)
            regexp {"pgn"\s*:\s*"([^"]*)"} $gamePart -> puzzleData(pgn)

            if {[regexp {"perf"\s*:\s*\{([^\}]*)\}} $gamePart -> perfObj]} {
                regexp {"name"\s*:\s*"([^"]*)"} $perfObj -> puzzleData(perfName)
            }

            # Parse players array
            if {[regexp -indices {"players"\s*:\s*\[} $gamePart match]} {
                set arrStart [lindex $match 1]
                set remaining [string range $gamePart $arrStart end]
                set depth 1; set pos 1
                while {$pos < [string length $remaining] && $depth > 0} {
                    set ch [string index $remaining $pos]
                    if {$ch eq "\["} { incr depth }
                    if {$ch eq "\]"} { incr depth -1 }
                    incr pos
                }
                set playersStr [string range $remaining 1 [expr {$pos - 3}]]
                # Extract player names and ratings
                set playerObjs [::lichess_puzzles::splitJsonObjects $playersStr]
                if {[llength $playerObjs] >= 1} {
                    set p0 [lindex $playerObjs 0]
                    regexp {"name"\s*:\s*"([^"]*)"} $p0 -> puzzleData(whiteName)
                    regexp {"rating"\s*:\s*(\d+)} $p0 -> puzzleData(whiteRating)
                }
                if {[llength $playerObjs] >= 2} {
                    set p1 [lindex $playerObjs 1]
                    regexp {"name"\s*:\s*"([^"]*)"} $p1 -> puzzleData(blackName)
                    regexp {"rating"\s*:\s*(\d+)} $p1 -> puzzleData(blackRating)
                }
            }
        }

        # Save state: solution moves
        set solutionMoves $puzzleData(solution)
        set solutionIndex 0

        # Mark this puzzle as seen
        if {$puzzleData(puzzleId) ne ""} {
            ::lichess_puzzles::markSeen $puzzleData(puzzleId)
        }

        # Cancel any stale after-events from a previous puzzle
        after cancel $::lichess_puzzles::pendingSolve
        after cancel $::lichess_puzzles::pendingComp
        set ::lichess_puzzles::pendingSolve ""
        set ::lichess_puzzles::pendingComp ""
        set ::lichess_puzzles::computerMoving 0

        # Update the info display
        ::lichess_puzzles::updateInfoDisplay

        # Load the puzzle position onto the main board
        if {![::lichess_puzzles::loadPuzzlePosition]} {
            setMsg [tr LichessPuzzlesLoadError]
            return 0
        }

        setMsg [tr LichessPuzzlesSolve]
        return 1
    }

    # -------------------------------------------------------
    # updateInfoDisplay  -- fill the text widget with metadata
    # -------------------------------------------------------
    proc updateInfoDisplay {} {
        variable puzzleData
        set w .lichessPuzzlesWin
        if {![winfo exists $w]} { return }

        set t $w.info.detail
        $t configure -state normal
        $t delete 1.0 end

        if {$puzzleData(puzzleId) ne ""} {
            $t insert end "[tr LichessPuzzlesId]: $puzzleData(puzzleId)\n"
        }
        if {$puzzleData(rating) ne ""} {
            $t insert end "[tr Rating]: $puzzleData(rating)\n"
        }
        if {$puzzleData(plays) ne ""} {
            $t insert end "[tr LichessPuzzlesPlays]: $puzzleData(plays)\n"
        }

        # Show current side to move
        if {[winfo exists .lichessPuzzlesWin]} {
            catch {
                set side [sc_pos side]
                if {$side eq "white"} {
                    $t insert end "[tr LichessPuzzlesSideToMove]: [tr White]\n"
                } else {
                    $t insert end "[tr LichessPuzzlesSideToMove]: [tr Black]\n"
                }
            }
        }

        if {[llength $puzzleData(themes)] > 0} {
            $t insert end "[tr LichessPuzzlesThemes]: [join $puzzleData(themes) {, }]\n"
        }
        if {$puzzleData(perfName) ne ""} {
            $t insert end "[tr LichessPuzzlesPerf]: $puzzleData(perfName)\n"
        }
        if {$puzzleData(clock) ne ""} {
            $t insert end "[tr LichessPuzzlesClock]: $puzzleData(clock)\n"
        }
        if {$puzzleData(rated) ne ""} {
            $t insert end "[tr LichessPuzzlesRated]: $puzzleData(rated)\n"
        }
        if {$puzzleData(whiteName) ne "" || $puzzleData(blackName) ne ""} {
            set wname $puzzleData(whiteName)
            set bname $puzzleData(blackName)
            if {$puzzleData(whiteRating) ne ""} { append wname " ($puzzleData(whiteRating))" }
            if {$puzzleData(blackRating) ne ""} { append bname " ($puzzleData(blackRating))" }
            $t insert end "[tr White]: $wname\n"
            $t insert end "[tr Black]: $bname\n"
        }
        if {$puzzleData(gameId) ne ""} {
            set gameUrl "https://lichess.org/$puzzleData(gameId)"
            set linkTag "link_$puzzleData(gameId)"
            $t insert end "[tr LichessPuzzlesGame]: " {}
            $t insert end $gameUrl $linkTag
            $t tag configure $linkTag -foreground blue -underline 1
            $t tag bind $linkTag <ButtonRelease-1> \
                [list ::lichess_puzzles::openBrowser $gameUrl]
            $t insert end "\n" {}
        }

        $t configure -state disabled
    }

    # -------------------------------------------------------
    # loadPuzzlePosition  -- load the puzzle FEN onto the
    #                         main board and set up play mode.
    # -------------------------------------------------------
    proc loadPuzzlePosition {} {
        variable puzzleData
        variable prevBase
        variable prevGameNum
        variable prevFen

        # Prefer FEN when available (always present in daily puzzles)
        if {$puzzleData(fen) ne ""} {
            return [::lichess_puzzles::loadFromFen $puzzleData(fen)]
        }

        # Fallback: navigate the game PGN to initialPly
        set pgn $puzzleData(pgn)
        set initialPly $puzzleData(initialPly)

        if {$pgn eq ""} {
            return 0
        }

        # Save current game state
        set prevBase [sc_base current]
        set prevGameNum [sc_game number]

        # Switch to clipbase and import the puzzle game
        ::file::SwitchToBase $::clipbase_db

        catch { sc_game new }
        if {[catch { sc_game import $pgn }]} { return 0 }
        catch { sc_game save 0 $::clipbase_db }

        # Navigate to the puzzle starting position
        catch { sc_move start }
        if {$initialPly > 0} {
            catch { sc_move forward $initialPly }
        }

        set prevFen [sc_pos fen]
        ::setPlayMode "::lichess_puzzles::callback"

        set side [sc_pos side]
        if {$side eq "black"} {
            ::board::flipAuto .main.board 1
        } else {
            ::board::flipAuto .main.board 0
        }

        updateBoard -pgn
        ::lichess_puzzles::updateInfoDisplay
        focus .main
        return 1
    }

    # -------------------------------------------------------
    # loadFromFen  -- fallback: use sc_game import with a
    #                 minimal PGN built from the FEN.
    # -------------------------------------------------------
    proc loadFromFen {fen} {
        variable prevBase
        variable prevGameNum
        variable prevFen

        # Save original game state only on first load
        if {$prevBase eq ""} {
            set prevBase [sc_base current]
            set prevGameNum [sc_game number]
        }

        ::file::SwitchToBase $::clipbase_db

        catch { sc_game new }

        # Build a minimal PGN with a FEN tag
        set setupPgn "\[FEN \"$fen\"\]\n\[SetUp \"1\"\]\n*"
        if {[catch { sc_game import $setupPgn } err]} {
            return 0
        }
        catch { sc_game save 0 $::clipbase_db }

        set prevFen [sc_pos fen]
        ::setPlayMode "::lichess_puzzles::callback"

        set side [sc_pos side]
        if {$side eq "black"} {
            ::board::flipAuto .main.board 1
        } else {
            ::board::flipAuto .main.board 0
        }

        updateBoard -pgn
        ::lichess_puzzles::updateInfoDisplay
        focus .main
        return 1
    }

    # -------------------------------------------------------
    # callback  -- play-mode callback, called by main.tcl
    # -------------------------------------------------------
    proc callback {cmd args} {
        variable solutionMoves
        variable solutionIndex
        variable computerMoving

        switch -- $cmd {
            premove {
                set moveUCI [lindex $args 0]
                if {$computerMoving} {
                    set computerMoving 0
                    return 0
                }
                if {![::lichess_puzzles::isPlayerTurn]} {
                    return 1
                }

                set totalMoves [llength $solutionMoves]
                if {$totalMoves == 0} {
                    return 1
                }
                if {$solutionIndex >= $totalMoves} {
                    # Puzzle should be complete; allow moves to finish
                    return 0
                }

                set expected [lindex $solutionMoves $solutionIndex]

                if {![string equal -nocase $moveUCI $expected]} {
                    ::lichess_puzzles::setMsg [tr LichessPuzzlesWrong]
                    return 1
                }

                # Correct move — advance to next expected move
                incr solutionIndex
                ::lichess_puzzles::clearHints
                ::lichess_puzzles::setMsg [tr LichessPuzzlesBestMove]

                # Check if there are more moves remaining
                if {$solutionIndex >= $totalMoves} {
                    after cancel $::lichess_puzzles::pendingSolve
                    set ::lichess_puzzles::pendingSolve [after 400 ::lichess_puzzles::puzzleSolved]
                    return 0
                }

                # The next move is the computer's response
                set compMove [lindex $solutionMoves $solutionIndex]
                incr solutionIndex
                set computerMoving 1
                set ::lichess_puzzles::pendingComp [after 400 [list ::lichess_puzzles::playComputerMove $compMove]]
                return 0
            }
            moveBack    { return 1 }
            moveForward { return 1 }
            moveStart   { return 1 }
            moveEnd     { return 1 }
            moveExitVar { return 1 }
            drawVarArrows { return 0 }
            info {
                return [list [tr LichessPuzzlesPlaying] [tr LichessPuzzlesStop] "red"]
            }
            stop {
                ::lichess_puzzles::stop
            }
            suggestMove { return 0 }
        }
        return 0
    }

    # -------------------------------------------------------
    # isPlayerTurn  -- return 1 when it is the human's turn
    # -------------------------------------------------------
    proc isPlayerTurn {} {
        set side [sc_pos side]
        set flipped [main_isFlipped]
        if {($side eq "white" && !$flipped) || ($side eq "black" && $flipped)} {
            return 1
        }
        return 0
    }

    # -------------------------------------------------------
    # showHint  -- highlight the correct piece's source square
    # -------------------------------------------------------
    proc showHint {} {
        variable solutionMoves
        variable solutionIndex
        variable hintSquares
        if {$solutionIndex >= [llength $solutionMoves]} { return }

        ::lichess_puzzles::clearHints

        set nextMove [lindex $solutionMoves $solutionIndex]
        set fromSq [string range $nextMove 0 1]
        set sqIdx [::board::sq $fromSq]

        # Highlight the source square
        ::board::mark::add ".main.board" "full" $sqIdx "" "#00cc44"
        lappend hintSquares $sqIdx

        ::lichess_puzzles::setMsg [format [tr LichessPuzzlesHintMsg] $fromSq]
    }

    # -------------------------------------------------------
    # showSolution  -- display the full solution sequence
    # -------------------------------------------------------
    proc showSolution {} {
        variable solutionMoves
        variable solutionIndex

        set remaining [lrange $solutionMoves $solutionIndex end]
        if {![llength $remaining]} { return }

        # Convert UCI to SAN by temporarily playing the moves
        set sanSolution ""
        if {![catch {
            sc_game push copyfast
            foreach m $remaining {
                if {[catch {sc_move addSan $m}]} break
                set prev [sc_game info previousMove]
                if {$prev ne ""} { append sanSolution " $prev" }
            }
            sc_game pop
        }]} {
            set sanSolution [string trim $sanSolution]
        } else {
            catch { sc_game pop }
        }

        if {$sanSolution eq ""} {
            set sanSolution [join $remaining " "]
        }

        tk_messageBox -icon info -type ok \
            -title [tr LichessPuzzlesViewSolution] \
            -message [format [tr LichessPuzzlesSolutionMsg] $sanSolution] \
            -parent .lichessPuzzlesWin
    }

    # -------------------------------------------------------
    # clearHints  -- remove any hint highlights from the board
    # -------------------------------------------------------
    proc clearHints {} {
        variable hintSquares
        foreach sq $hintSquares {
            catch { ::board::colorSquare ".main.board" $sq "" }
        }
        set hintSquares {}
    }

    # -------------------------------------------------------
    # playComputerMove  -- play the system's response
    # -------------------------------------------------------
    proc playComputerMove {uciMove} {
        variable computerMoving
        if {![winfo exists .lichessPuzzlesWin]} { return }

        set computerMoving 1
        if {[catch { sc_move addSan $uciMove } err]} {
            # Fallback: try via UCI path
            catch { ::move::Follow $uciMove }
        }

        set ::lichess_puzzles::prevFen [sc_pos fen]
        updateBoard -pgn

        set computerMoving 0

        # Check if puzzle is solved (computer played the last solution move)
        if {$::lichess_puzzles::solutionIndex >= [llength $::lichess_puzzles::solutionMoves]} {
            after 400 ::lichess_puzzles::puzzleSolved
        }
    }

    # -------------------------------------------------------
    # puzzleSolved  -- congratulate the user
    # -------------------------------------------------------
    proc puzzleSolved {} {
        variable puzzleData
        variable solutionMoves
        variable solutionIndex
        if {![winfo exists .lichessPuzzlesWin]} { return }

        after cancel $::lichess_puzzles::pendingSolve
        set ::lichess_puzzles::pendingSolve ""

        set w .lichessPuzzlesWin
        $w.info.title configure -text [tr LichessPuzzlesSolvedTitle]

        set msg [tr LichessPuzzlesSolved]
        if {$puzzleData(rating) ne ""} {
            append msg "  ([tr Rating]: $puzzleData(rating))"
        }
        tk_messageBox -icon info -type ok -title [tr LichessPuzzlesTitle] -message $msg -parent $w
        ::lichess_puzzles::setMsg $msg
    }

    # -------------------------------------------------------
    # stop  -- clean up and close
    # -------------------------------------------------------
    proc stop {} {
        variable puzzleActive
        variable prevBase
        variable prevGameNum

        if {!$puzzleActive} { return }

        set puzzleActive 0

        after cancel $::lichess_puzzles::pendingSolve
        after cancel $::lichess_puzzles::pendingComp
        set ::lichess_puzzles::pendingSolve ""
        set ::lichess_puzzles::pendingComp ""
        set ::lichess_puzzles::computerMoving 0

        # Restore play mode
        if {[info exists ::playMode]} {
            if {[string match "*::lichess_puzzles::callback*" $::playMode]} {
                ::setPlayMode ""
            }
        }

        # Destroy the window
        if {[winfo exists .lichessPuzzlesWin]} {
            destroy .lichessPuzzlesWin
        }

        # Restore the previous game state if we saved it
        if {$prevBase ne "" && $prevBase != [sc_base current]} {
            catch { ::file::SwitchToBase $prevBase }
        }
        if {$prevGameNum > 0} {
            catch { sc_game load $prevGameNum }
            ::notify::GameChanged
        } else {
            catch { ::game::Clear }
            ::notify::GameChanged
        }

        ::board::flipAuto .main.board 0
        updateBoard -pgn
        updateStatusBar

        # Clear saved state for next session
        set prevBase ""
        set prevGameNum 0
    }

    # -------------------------------------------------------
    # openBrowser  -- open a URL in the user's default browser
    # -------------------------------------------------------
    proc openBrowser {url} {
        if {[info exists ::windowsOS] && $::windowsOS} {
            catch { eval exec [auto_execok cmd] /c start \"\" \"$url\" & }
        } elseif {$::macOS} {
            catch { exec open $url & }
        } else {
            catch { exec xdg-open $url & }
        }
    }

    # -------------------------------------------------------
    # setMsg  -- update the message label
    # -------------------------------------------------------
    proc setMsg {msg} {
        if {[winfo exists .lichessPuzzlesWin]} {
            .lichessPuzzlesWin.msgframe.msg configure -text $msg
        }
    }

    # -------------------------------------------------------
    # httpGet  -- cross-platform HTTP GET
    # -------------------------------------------------------
    proc httpGet {url {token ""}} {
        set result ""

        # Use exec curl with explicit quoting (avoids shell & issues with pipe open)
        if {[auto_execok curl] ne ""} {
            set args [list -s --max-time 15 -H "Accept: */*"]
            if {$token ne ""} {
                lappend args -H "Authorization: Bearer $token"
            }
            lappend args $url
            if {![catch {exec curl {*}$args 2>@1} result]} {
                set result [string trim $result]
                if {$result ne "" && [string index $result 0] eq "\{"} {
                    return $result
                }
            }
        }

        # Fallback: Tcl http + tls
        if {![catch {package require http}]} {
            catch {package require tls}
            catch {::http::register https 443 ::tls::socket}
            set headers [list Accept "*/*"]
            if {$token ne ""} {
                lappend headers Authorization "Bearer $token"
            }
            set httpToken ""
            if {![catch {set httpToken [::http::geturl $url -timeout 15000 -headers $headers]} httpErr]} {
                set result [::http::data $httpToken]
                ::http::cleanup $httpToken
                return $result
            }
        }

        # Windows fallback: PowerShell
        if {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
            set psHeaders ""
            if {$token ne ""} {
                set psHeaders "-Headers @{'Authorization'='Bearer \$env:LICHESS_PZ_TOKEN'; 'Accept'='*/*'}"
                set ::env(LICHESS_PZ_TOKEN) $token
            } else {
                set psHeaders "-Headers @{'Accept'='*/*'}"
            }
            set ::env(LICHESS_PZ_URL) $url
            if {![catch {exec powershell -NoLogo -NoProfile -Command \
                "(Invoke-WebRequest -Uri \$env:LICHESS_PZ_URL $psHeaders -TimeoutSec 15).Content"} result]} {
                catch {unset ::env(LICHESS_PZ_TOKEN)}
                catch {unset ::env(LICHESS_PZ_URL)}
                return $result
            }
            catch {unset ::env(LICHESS_PZ_TOKEN)}
            catch {unset ::env(LICHESS_PZ_URL)}
        }

        error "Failed to query Lichess Puzzles"
    }

    # -------------------------------------------------------
    # urlEncode  -- simple URL encoding
    # -------------------------------------------------------
    proc urlEncode {str} {
        return [string map {
            " " "%20" "/" "%2F" "+" "%2B" "?" "%3F" "&" "%26" "=" "%3D"
            "#" "%23" "%" "%25" "\"" "%22" "'" "%27"
        } $str]
    }

    # -------------------------------------------------------
    # extractJsonObject  -- extract a named JSON object value
    # -------------------------------------------------------
    proc extractJsonObject {jsonData key} {
        if {![regexp -indices "\"$key\"\\s*:\\s*\{" $jsonData match]} {
            return ""
        }
        set start [lindex $match 1]
        set remaining [string range $jsonData $start end]
        set depth 1
        set pos 1
        set len [string length $remaining]
        while {$pos < $len && $depth > 0} {
            set ch [string index $remaining $pos]
            if {$ch eq "\{"} { incr depth }
            if {$ch eq "\}"} { incr depth -1 }
            incr pos
        }
        return [string range $remaining 0 [expr {$pos - 1}]]
    }

    # -------------------------------------------------------
    # splitJsonObjects  -- split a JSON array string into
    #                      individual top-level objects
    # -------------------------------------------------------
    proc splitJsonObjects {arrStr} {
        set objs {}
        set searchStr $arrStr
        while {[set idx [string first "\{" $searchStr]] >= 0} {
            set depth 1
            set p [expr {$idx + 1}]
            set slen [string length $searchStr]
            while {$p < $slen && $depth > 0} {
                set ch [string index $searchStr $p]
                if {$ch eq "\{"} { incr depth }
                if {$ch eq "\}"} { incr depth -1 }
                incr p
            }
            lappend objs [string range $searchStr $idx [expr {$p - 1}]]
            set searchStr [string range $searchStr $p end]
        }
        return $objs
    }

    # Initialize seen-IDs on source
    loadSeenIds

}
