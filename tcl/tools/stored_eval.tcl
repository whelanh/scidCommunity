############################################################
### Stored Evaluations
### Per-engine in-memory database of position evaluations.
### Populated from Lichess cloud eval API and/or engine analysis.
### Cleared when a new game is loaded or the engine window is closed.

namespace eval ::stored_eval {
    # Per-engine databases: db($id,$fenKey) = {depth source pvlines}
    # pvlines is a list of: {multipv score score_type pv_uci}
    variable db
    array set db {}

    # Pending async Lichess queries: pendingFd($id) = file descriptor
    variable pendingFd
    array set pendingFd {}

    # Buffers for async reads: queryBuf($id) = accumulated data
    variable queryBuf
    array set queryBuf {}

    variable apiUrl "https://lichess.org/api/cloud-eval"
    variable multiPv 5
}

# Extract position-only key from a full FEN (board + side + castling + ep).
# Drops halfmove clock and fullmove number so the same position reached
# via different move orders shares the same key.
proc ::stored_eval::fenKey {fen} {
    set parts [split $fen]
    return "[lindex $parts 0] [lindex $parts 1] [lindex $parts 2] [lindex $parts 3]"
}

# Return stored eval data for a position, or "" if not found.
# Result format: {depth source pvlines}
proc ::stored_eval::get {id fenKey} {
    variable db
    if {[info exists db($id,$fenKey)]} {
        return $db($id,$fenKey)
    }
    return ""
}

# Store or update an eval entry. Only replaces if new depth >= existing depth.
# pvlines: list of {multipv score score_type pv_uci}
proc ::stored_eval::store {id fenKey depth source pvlines} {
    variable db
    if {[info exists db($id,$fenKey)]} {
        set existing $db($id,$fenKey)
        set existingDepth [lindex $existing 0]
        if {$depth < $existingDepth} {
            return
        }
    }
    set db($id,$fenKey) [list $depth $source $pvlines]
}

# Clear the stored eval DB for a specific engine window.
proc ::stored_eval::clear {id} {
    variable db
    foreach key [array names db "$id,*"] {
        unset db($key)
    }
}

# Clear all stored eval DBs (all engines).
proc ::stored_eval::clearAll {} {
    variable db
    array unset db
    array set db {}
}

# Cancel any pending Lichess query for the given engine.
proc ::stored_eval::cancelQuery {id} {
    variable pendingFd
    variable queryBuf
    if {[info exists pendingFd($id)] && $pendingFd($id) ne ""} {
        catch { close $pendingFd($id) }
        unset pendingFd($id)
    }
    unset -nocomplain queryBuf($id)
}

# Fire an async Lichess cloud eval query for the given FEN.
# On completion, invokes: callback $id $fen $result
# where result is {depth pvlines} or "" on failure.
proc ::stored_eval::queryLichessAsync {id fen callback} {
    variable pendingFd
    variable queryBuf
    variable apiUrl
    variable multiPv

    # Cancel any previous query for this engine
    cancelQuery $id

    set gameVariant [sc_game variant]
    if {$gameVariant eq "chess960"} {
        set variant "chess960"
    } else {
        set variant "standard"
    }

    set urlFen [string map {" " "%20"} $fen]
    set url "$apiUrl?fen=$urlFen&multiPv=$multiPv&variant=$variant"

    if {[catch {
        set fd [open [list | curl -s --max-time 10 -H {Accept: */*} $url] r]
        fconfigure $fd -blocking 0 -buffering full
        set pendingFd($id) $fd
        set queryBuf($id) ""
        fileevent $fd readable [list ::stored_eval::onLichessData_ $id $fd $fen $callback]
    } err]} {
        # curl not available or error - silently skip
    }
}

# Internal: handle incoming data from async curl.
proc ::stored_eval::onLichessData_ {id fd fen callback} {
    variable pendingFd
    variable queryBuf

    # Read available data
    if {[catch { append queryBuf($id) [read $fd] }]} {
        catch { close $fd }
        unset -nocomplain pendingFd($id) queryBuf($id)
        return
    }

    if {[eof $fd]} {
        set data $queryBuf($id)
        catch { close $fd }
        if {[info exists pendingFd($id)]} { unset pendingFd($id) }
        if {[info exists queryBuf($id)]} { unset queryBuf($id) }

        # Parse the JSON response
        set result [parseLichessJson_ $data $fen]
        if {$result ne ""} {
            if {[catch { {*}$callback $id $fen $result }]} {
                # Callback failed (e.g. window closed) - ignore
            }
        }
    }
}

# Internal: parse Lichess cloud eval JSON response.
# Returns {depth pvlines} or "" on failure.
# pvlines: list of {multipv score score_type pv_uci}
proc ::stored_eval::parseLichessJson_ {jsonData fen} {
    # Check for error responses
    if {$jsonData eq "" || ([string match "*error*" $jsonData] && ![regexp {"pvs"} $jsonData])} {
        return ""
    }

    # Extract depth
    set depth ""
    regexp {"depth":(\d+)} $jsonData -> depth
    if {$depth eq ""} { return "" }

    # Find the pvs array and extract individual PV objects
    set pvlines {}
    set lineNum 1

    if {[regexp -indices {"pvs"\s*:\s*\[} $jsonData match]} {
        set arrayStart [lindex $match 1]
        set remaining [string range $jsonData $arrayStart end]

        while {[regexp -indices {\{[^\}]+\}} $remaining objMatch]} {
            set objStart [lindex $objMatch 0]
            set objEnd [lindex $objMatch 1]
            set obj [string range $remaining $objStart $objEnd]

            set moves ""
            set cp ""
            set mate ""

            regexp {"moves"\s*:\s*"([^"]*)"} $obj -> moves
            regexp {"cp"\s*:\s*(-?\d+)} $obj -> cp
            regexp {"mate"\s*:\s*(-?\d+)} $obj -> mate

            if {$moves ne ""} {
                if {$mate ne ""} {
                    lappend pvlines [list $lineNum $mate "mate" $moves]
                } elseif {$cp ne ""} {
                    lappend pvlines [list $lineNum $cp "cp" $moves]
                }
                incr lineNum
            }

            set remaining [string range $remaining [expr {$objEnd + 1}] end]
        }
    }

    if {[llength $pvlines] == 0} { return "" }
    return [list $depth $pvlines]
}

# Format stored eval data for display in a text widget.
# Returns a list of {tag text} pairs to insert.
# fen is needed to convert UCI moves to SAN.
proc ::stored_eval::formatForDisplay {storedData fen} {
    lassign $storedData depth source pvlines

    set result {}
    lappend result [list header "Stored (d$depth, $source):\n"]

    foreach pvline $pvlines {
        lassign $pvline multipv score score_type pv_uci

        # Format score
        if {$score_type eq "mate"} {
            if {$score >= 0} {
                set scoreStr "+M$score"
            } else {
                set scoreStr "-M[expr {abs($score)}]"
            }
        } else {
            set scoreStr [format "%+.2f" [expr {$score / 100.0}]]
        }

        # Convert UCI PV to SAN with move numbers
        set sanMoves ""
        if {[catch {
            set moveList [split $pv_uci " "]
            set sanMoves [::uci::formatPv $moveList $fen]
        }]} {
            set sanMoves $pv_uci
        }

        # Format with move numbers
        set numberedMoves ""
        if {[catch {
            set numberedMoves [::lichess_eval::formatLine $fen $sanMoves]
        }]} {
            set numberedMoves $sanMoves
        }

        lappend result [list pvnum "$multipv"]
        lappend result [list score "  $scoreStr"]
        lappend result [list moves "  $numberedMoves\n"]
    }

    return $result
}
