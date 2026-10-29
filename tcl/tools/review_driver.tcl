########################################################################
### The engine pass behind Game Review and Move Comment.
###
### The pass runs on its own engine connection (id 20) so it never disturbs the
### analysis window's search: changing MultiPV on a window's engine restarts what
### the user is watching (::enginewin::changeOption), and a review that borrowed
### that connection would do the same.
###
### The driver is deliberately dumb about positions: the caller hands it
### {ply positionSpec} pairs, the same shape ::engine::send Go takes, because
### turning a game into position specs needs the game commands and this module
### must stay testable without them.
###
### onprogress {done total ply lines} reports each finished position, and ondone
### {results} fires exactly once per pass: on the last reply, or when the engine
### is lost. A results dict with fewer plies than the positions handed in is how a
### pass that was cut short is reported.

namespace eval reviewdriver {}

variable job
variable seq 0

# The pass ::reviewdriver::run has in flight (token, snapshot, cursor, options),
# and the public half of it that ::reviewdriver::status reports. Declared here so
# that a fresh session and a refused run start from the same empty state.
namespace eval ::reviewdriver {
    variable pass {}
    variable state {}
}

set ::reviewdriver::ENGINE_ID 20

# Whether an engine window may take this connection id. Window ids come from the
# same pool as every other engine connection, and ::engine::connect closes
# whatever already holds the id it is given, so a window opened on the pass's id
# would take the pass's engine - and the pass would take the window's.
# ::enginewin::Open asks this before it takes an id.
proc ::reviewdriver::reservedId {id} {
    return [expr {[string equal $id $::reviewdriver::ENGINE_ID]}]
}

proc ::reviewdriver::start {enginecfg positions mpv depth onprogress ondone} {
    variable job
    variable seq
    set id $::reviewdriver::ENGINE_ID
    if {[::reviewdriver::busy $id]} {
        error "engine $id is already running a pass"
    }
    incr seq
    set token "pass$seq"
    set job($token) [dict create \
        id $id enginecfg $enginecfg positions $positions index -1 \
        mpv $mpv depth $depth results {} lines {} configured 0 \
        stopped 0 onprogress $onprogress ondone $ondone]
    set exe [lindex $enginecfg 1]
    set args [lindex $enginecfg 2]
    ::engine::setLogCmd $id {}
    if {[catch {
        # The preset's args go in as one element, the way ::enginewin and
        # ::engineNoWin pass them: ::engine::connect takes the protocol from its
        # last positional, so splatting here either swallows "uci" into the
        # engine's own argv (Stockfish runs it as a command and exits) or gives
        # connect more positionals than it has parameters.
        ::engine::connect $id [list ::reviewdriver::callback $token] $exe $args uci
    } err]} {
        unset -nocomplain job($token)
        error $err
    }
    return $token
}

# Is a pass using this engine id? A finished pass leaves its connection open
# until the queued close runs, so the id can be occupied with nothing to run.
proc ::reviewdriver::busy {id} {
    variable job
    foreach token [array names job] {
        if {[dict get $job($token) id] eq $id} {
            return 1
        }
    }
    return 0
}

# Stop a pass: no further positions are started and the engine is closed.
proc ::reviewdriver::stop {token} {
    variable job
    variable pass
    variable state
    if {![info exists job($token)]} {
        return 0
    }
    set id [dict get $job($token) id]
    unset job($token)
    catch { ::engine::send $id StopGo }
    ::reviewdriver::closeSoon $id
    # A run of ours that is stopped here writes nothing - the write phase only
    # ever runs once the search has finished - and puts the reader back where
    # the pass found them, which cursorSave has already walked out of.
    if {[dict size $pass] && [dict get $pass token] eq $token} {
        set p $pass
        set pass {}
        dict set state state cancelled
        ::reviewdriver::restoreRun $p
    }
    return 1
}

# Nothing may close a connection from inside an engine reply. ::engine::close runs
# ::engine::destroy_, which unsets the arrays ::engine::reply walks *after* the
# callback returns, so a close in finish, or in an onprogress handler that stops the
# pass, throws on every completed pass. Queue the close instead, and take the channel
# it was queued for: a pass that starts in the meantime has its own connection and
# must keep it.
proc ::reviewdriver::closeSoon {id} {
    set channel ""
    catch { set channel $::engconn(channel_$id) }
    if {$channel eq ""} {
        return
    }
    after idle [list ::reviewdriver::closeConn $id $channel]
}

proc ::reviewdriver::closeConn {id channel} {
    if {![info exists ::engconn(channel_$id)]} {
        return
    }
    if {$::engconn(channel_$id) ne $channel} {
        return
    }
    catch { ::engine::close $id }
}

# The engine messages for a pass.
proc ::reviewdriver::callback {token msg} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    lassign $msg msgType msgData
    switch -- $msgType {
        "InfoConfig" {
            # SetOptions answers with another InfoConfig: configure once.
            if {[dict get $job($token) configured]} {
                return
            }
            dict set job($token) configured 1
            ::reviewdriver::configure $token
            ::reviewdriver::next $token
        }
        "InfoPV" {
            ::reviewdriver::collect $token $msgData
        }
        "InfoBestMove" {
            ::reviewdriver::next $token
        }
        "InfoDisconnected" {
            # The process died mid-pass: its connection is already gone, and the
            # caller would otherwise wait forever for a pass nobody will finish.
            ::reviewdriver::lost $token
        }
    }
}

proc ::reviewdriver::configure {token} {
    variable job
    set id [dict get $job($token) id]
    set opts [list [list MultiPV [dict get $job($token) mpv]]]
    # ::review::effective, not the preset itself: a pass is a second engine, and
    # that is where the ceiling on the threads and hash it may take lives. Ask
    # the preset here and a 110 GB transposition table is allocated twice.
    set eff [::review::effective [dict get $job($token) enginecfg]]
    foreach key {threads hash} {
        set value [dict get $eff $key]
        if {$value ne ""} {
            lappend opts [list [expr {$key eq "threads" ? "Threads" : "Hash"}] $value]
        }
    }
    ::engine::send $id SetOptions $opts
}

# Keep the deepest line seen for each MultiPV slot of the current position.
proc ::reviewdriver::collect {token msgData} {
    variable job
    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time \
        score score_type score_wdl pv
    if {$multipv eq "" || $score eq ""} {
        return
    }
    set lines [dict get $job($token) lines]
    if {[dict exists $lines $multipv] && [lindex [dict get $lines $multipv] 0] >= $depth} {
        return
    }
    dict set lines $multipv [list $depth $score $score_type $pv]
    dict set job($token) lines $lines
}

proc ::reviewdriver::next {token} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    set j $job($token)
    set positions [dict get $j positions]
    set index [dict get $j index]
    if {$index >= 0} {
        # The position we were searching has finished: keep what it found.
        lassign [lindex $positions $index] ply spec
        set lines [dict get $j lines]
        set results [dict get $j results]
        dict set results $ply $lines
        dict set job($token) results $results
        dict set job($token) lines {}
        if {[dict get $j onprogress] ne ""} {
            catch { {*}[dict get $j onprogress] [expr {$index + 1}] [llength $positions] $ply $lines }
            # The handler may have stopped the pass. Then there is no job to
            # advance and no engine left to search the next position.
            if {![info exists job($token)]} {
                return
            }
        }
    }
    incr index
    if {$index >= [llength $positions]} {
        ::reviewdriver::finish $token
        return
    }
    dict set job($token) index $index
    dict set job($token) lines {}
    lassign [lindex $positions $index] ply spec
    set id [dict get $j id]
    ::engine::send $id Go [list $spec [list depth [dict get $j depth]]]
}

proc ::reviewdriver::finish {token} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    set j $job($token)
    set id [dict get $j id]
    set results [dict get $j results]
    set done [dict get $j ondone]
    unset job($token)
    # finish runs inside the last InfoBestMove reply, so the close is queued rather
    # than done here; ondone still sees the whole result.
    ::reviewdriver::closeSoon $id
    if {$done ne ""} {
        catch { {*}$done $results }
    }
    return $results
}

# The engine is gone: report what finished and forget the pass. Nothing is closed,
# because there is nothing left to close.
proc ::reviewdriver::lost {token} {
    variable job
    if {![info exists job($token)]} {
        return
    }
    set j $job($token)
    unset job($token)
    set results [dict get $j results]
    set done [dict get $j ondone]
    if {$done ne ""} {
        catch { {*}$done $results }
    }
    return $results
}

########################################################################
### The half the caller owns: the plan, the verdicts, and the write.
###
### Everything above only searches positions it is handed. What turns the
### engine's messages into a review is three decisions that need the game and
### the settings:
###
###   * which positions to search, read from the snapshot map - the board is
###     never moved to build them, and never read again once the pass is over;
###   * what the engine's lines mean for one move: a label, and the White's-POV
###     [%eval] of the position after the move;
###   * searching the whole line first and writing afterwards, because a write
###     navigates the game, and an open engine window would re-enter its
###     sendPosition from the middle of the pass.

# The positions a pass searches, as the {ply positionSpec} pairs
# ::reviewdriver::start takes. ::review::searchPlies decides which positions and
# in what order; this only reads where each one is from the snapshot map.
# A position the map cannot name, and an empty spec, are dropped: an empty
# positional argument is a Go with no position in it.
proc ::reviewdriver::positions {map plies bookEnd} {
    return [::reviewdriver::planPositions $map [::review::plan $plies $bookEnd]]
}

# The positions a list of moves needs searched: the reference position before
# each move it judges, plus the position after the last one so that move can
# still be judged when the engine did not rank the move played.
#
# The plan is the caller's: ::review::plan is the whole line, but a single move
# has to be reviewable on its own (Move Comment writes one move and no others),
# and the positions follow from the moves rather than being worked out again.
# A position the map cannot name, and an empty spec, are dropped: an empty
# positional argument is a Go with no position in it.
proc ::reviewdriver::planPositions {map plan} {
    if {![llength $plan]} { return {} }
    set want {}
    foreach ply $plan { lappend want [expr {$ply - 1}] }
    lappend want [lindex $plan end]
    set out {}
    foreach ply [lsort -unique -integer $want] {
        if {$ply < 0} { continue }
        set spec ""
        if {[catch { set spec [dict get [dict get $map positions] $ply] }]} {
            continue
        }
        if {[string trim $spec] eq ""} {
            continue
        }
        lappend out [list $ply $spec]
    }
    return $out
}

# One engine line's score as centipawns from the mover's point of view, or ""
# when the line carries no score this pass may use.
#
# The searched position is the one BEFORE the move, so its side to move is the
# mover: no colour flip. `mate` is a distance to mate and becomes the encoding
# the label ladder and the graph share. `lowerbound`/`upperbound` are bounds on a
# score the engine never finished, which is not a verdict.
proc ::reviewdriver::lineScore {line} {
    if {[llength $line] < 4} { return "" }
    lassign $line depth score score_type pv
    if {$score eq "" || ![string is integer -strict $score]} { return "" }
    switch -- $score_type {
        cp   { return $score }
        mate { return [::movelabels::mateToCp $score] }
    }
    return ""
}

# The lines at searched position `ply` - the key ::reviewdriver::start records
# its results under - in ::review::writeMove's `{cp pv}` shape.
#
# MultiPV index order, never sorted by score: index 1 is the engine's best line
# and ::review::selectLines reads element 0 as the best line. A slot the engine
# never reported is simply absent rather than renumbered, and nothing past `mpv`
# is kept.
proc ::reviewdriver::lines {results ply mpv} {
    set out {}
    if {![string is integer -strict $mpv] || $mpv < 1} { return $out }
    if {![dict exists $results $ply]} { return $out }
    set got [dict get $results $ply]
    for {set i 1} {$i <= $mpv} {incr i} {
        if {![dict exists $got $i]} { continue }
        set line [dict get $got $i]
        set cp [::reviewdriver::lineScore $line]
        if {$cp eq ""} { continue }
        set pv [lindex $line 3]
        if {![llength $pv]} { continue }
        lappend out [list $cp $pv]
    }
    return $out
}

# The side to move at every position of the snapshot, from the map itself.
#
# Parity cannot answer this: a game may start from a FEN with Black to move, and
# a null move is a fresh `position fen ... moves` header that leaves the same side
# to move without advancing the ply counter. The header of each position says who
# starts, and only a real move flips the side.
proc ::reviewdriver::sides {map} {
    set sides {}
    set side ""
    catch {
        set words [split [dict get [dict get $map positions] 0]]
        if {[lindex $words 1] eq "startpos"} {
            set side w
        } elseif {[lindex $words 1] eq "fen"} {
            set side [lindex $words 3]
        }
    }
    if {$side ne "w" && $side ne "b"} { set side w }
    dict set sides 0 $side
    set plies 0
    catch { set plies [dict get $map plies] }
    for {set p 1} {$p <= $plies} {incr p} {
        set move ""
        catch { set move [dict get [dict get $map moves] $p] }
        if {$move eq ""} {
            # A null move's own header: it names the side to move, and the ply
            # counter is not a move.
            catch {
                set words [split [dict get [dict get $map positions] $p]]
                if {[lindex $words 1] eq "fen"} {
                    set side [lindex $words 3]
                } elseif {[lindex $words 1] eq "startpos"} {
                    set side w
                }
            }
        } else {
            set side [expr {$side eq "w" ? "b" : "w"}]
        }
        dict set sides $p $side
    }
    return $sides
}

# One move's verdict, as a dict: `label`, `eval_cp`, the two figures the label
# ladder used (`before` = the best line's score at the position before the move,
# `after` = what the ladder compared it with), and `isBest`.
#
# Returned as a dict rather than the {label eval_cp} pair ::reviewdriver::verdicts
# publishes because annotate mode needs the pair the ladder measured - the NAG
# and difficulty comments are written from the same drop the label came from -
# and recomputing it elsewhere would be a second, drifting copy of this
# reasoning. `before`/`after` are centipawns from the mover's point of view.
proc ::reviewdriver::judge {map results sides ply} {
    set before [expr {$ply - 1}]
    if {![dict exists $results $before]} { return "" }
    set lines [dict get $results $before]
    if {![dict exists $lines 1]} { return "" }
    set best [dict get $lines 1]
    set cp1 [::reviewdriver::lineScore $best]
    if {$cp1 eq ""} { return "" }
    set pv1 [lindex $best 3]
    set played [::review::playedMove $map $ply]
    # No move, no verdict: a null move is a header, not a move to label, and
    # writing a comment and variations into it would corrupt the game.
    if {$played eq ""} { return "" }
    set isBest [expr {[string equal [lindex $pv1 0] $played]}]
    # The line the move owns at this root, when the engine ranked it: one
    # search for both figures, so the drop it measures is not search noise.
    set ranked ""
    foreach idx [lsort -integer [dict keys $lines]] {
        set line [dict get $lines $idx]
        if {[string equal [lindex [lindex $line 3] 0] $played]} {
            set ranked [::reviewdriver::lineScore $line]
            break
        }
    }
    # The searched successor is the engine's own evaluation of the position
    # the move reaches, from the opponent's point of view; negate it to the
    # mover's. This is the figure the comment's [%eval] carries, whatever the
    # move's rank at the root: the unranked case already had to use it, and
    # one source for the token beats two.
    set successor ""
    if {[dict exists $results $ply] && [dict exists [dict get $results $ply] 1]} {
        set successor [::reviewdriver::lineScore [dict get [dict get $results $ply] 1]]
        if {$successor ne ""} { set successor [expr {-$successor}] }
    }
    set after $ranked
    if {$after eq ""} { set after $successor }
    # The ladder needs a pair of evaluations. A move the engine measured -
    # the best line, or the line the move owns, or the searched successor -
    # has one; a move it never measured does not, and "no drop measured" is
    # not the same as "excellent". Only the engine's own move is judged
    # without a successor (it is `best` by definition); anything else is
    # left unlabelled rather than given a verdict nothing supports.
    if {$after eq "" && !$isBest} { return "" }
    set judged $after
    if {$judged eq ""} { set judged $cp1 }
    # [%eval] is White's point of view. The figure is the mover's, and the
    # mover is whoever is to move in the position before the move - read from
    # the snapshot, not from ply parity.
    set shown $successor
    if {$shown eq ""} { set shown $ranked }
    set eval_cp ""
    if {$shown ne ""} {
        set mover ""
        catch { set mover [dict get $sides $before] }
        set eval_cp [expr {$mover eq "b" ? -$shown : $shown}]
    }
    return [dict create label [::movelabels::label $cp1 $judged $isBest] \
        eval_cp $eval_cp before $cp1 after $judged isBest $isBest]
}

# ply -> {label eval_cp} for every move the pass can judge, from the results of
# the positions it searched.
#
# For move `ply` the reference position is `ply - 1`: its best line gives the
# evaluation before the move (cp1) and the engine's preferred move (the first
# move of that line, pv1). The evaluation after the move is the score of the line
# the game's own move owns, when the engine ranked that move at all; when it did
# not, the searched successor position `ply` answers instead, negated because its
# side to move is the opponent.
#
# `label` is ::movelabels::label's, both figures from the mover's point of view.
# `eval_cp` is White's-POV centipawns of the position AFTER the move - never the
# best-line score - because that is what a [%eval] token means to the graph. When
# there is no successor to compare against, eval_cp is "" and ::review::commentText
# omits the token.
proc ::reviewdriver::verdicts {map results} {
    set out {}
    set sides [::reviewdriver::sides $map]
    set plies 0
    catch { set plies [dict get $map plies] }
    for {set ply 1} {$ply <= $plies} {incr ply} {
        set v [::reviewdriver::judge $map $results $sides $ply]
        if {$v eq ""} { continue }
        dict set out $ply [list [dict get $v label] [dict get $v eval_cp]]
    }
    return $out
}

# A run's public state as ::reviewdriver::status answers it. `reason` is why a run
# failed ("" otherwise) and `restored` is 1 when the cursor was verified back where
# the pass found it - a restore that fell back to a known position is not a failed
# review, because the comments landed.
proc ::reviewdriver::blankState {{state idle}} {
    return [dict create state $state searched 0 total 0 written 0 failed 0 \
        errors {} reason "" restored 0]
}

proc ::reviewdriver::status {} {
    variable state
    if {![dict size $state]} { return [::reviewdriver::blankState] }
    return $state
}

# Search the whole main line and then write the verdicts into the game.
#
# `engine` is the preset (::enginecfg::get's shape); "" is a refusal rather than a
# silent choice of some other engine. Returns "" when the pass started, otherwise
# the reason it did not - and in that case nothing was started, nothing was moved
# and nothing was written.
#
#   -bookEnd N      where the opening book ends (default 0)
#   -plies {list}   the moves to judge (default: every move the plan covers), so
#                   that Move Comment can review one move and no others
#   -depth N        the depth to search (default: ::review::effective's, which is
#                   the review's own floor over the preset's)
#   -progress cmd   called as {*}$cmd <done> <total> as positions finish
#   -notify 0|1     refresh the board when the write phase ends (default 0)
proc ::reviewdriver::run {engine args} {
    variable pass
    variable state
    set bookEnd 0
    set plies ""
    set want ""
    set progress ""
    set notify 0
    # The write phase, and the one place a caller can change it: annotate mode
    # (tcl/tools/review_annotate.tcl) writes the classic annotator's marks beside
    # the label, and it must not carry a second copy of the plan ::review::plan
    # already decided. Same contract as writeResults: called as
    # {*}$writer <pass> <results>, returning {written failed errors}.
    set writer ::reviewdriver::writeResults
    for {set i 0} {$i < [llength $args]} {incr i} {
        set opt [lindex $args $i]
        switch -- $opt {
            -bookEnd  { incr i ; set bookEnd [lindex $args $i] }
            -plies    { incr i ; set plies [lindex $args $i] }
            -depth    { incr i ; set want [lindex $args $i] }
            -progress { incr i ; set progress [lindex $args $i] }
            -notify   { incr i ; set notify [lindex $args $i] }
            -writer   { incr i ; set writer [lindex $args $i] }
            default   { return "unknown option: $opt" }
        }
    }
    if {![string is integer -strict $bookEnd]} { return "-bookEnd must be a whole number" }
    if {[llength $plies]} {
        foreach ply $plies {
            if {![string is integer -strict $ply] || $ply < 1} {
                return "-plies must be a list of move numbers"
            }
        }
        set plies [lsort -unique -integer $plies]
    }
    if {$want ne "" && (![string is integer -strict $want] || $want < 1)} {
        return "-depth must be a whole number"
    }
    if {[llength $engine] == 0} { return "no engine selected" }
    # The pass pins the protocol to uci: an XBoard preset would never answer the
    # handshake, and the run would sit in `searching` until the user cancelled.
    if {[lindex $engine 7] eq "" || [lindex $engine 7] eq 0} {
        return "the review needs a UCI engine"
    }
    # One run at a time, and refusal before anything is read: a second call must
    # not rewrite the counts of the pass that is already searching.
    if {[dict size $pass]} {
        return "engine 20 is already running a pass"
    }
    # What the pass may spend is ::review::effective's answer, not a second set of
    # defaults here: the preset wins Threads/Hash, MultiPV is at least two, and the
    # depth is the review's own floor.
    set eff [::review::effective $engine]
    set mpv [dict get $eff mpv]
    set depth [dict get $eff depth]
    # A caller that knows the depth (Move Comment: the window's analysis, or the
    # review's own when the setting says to wait for it) is the depth searched.
    if {$want ne ""} { set depth $want }
    # MultiPV is asked for on the pass's own connection and an engine that does
    # not offer it ignores the option, so a preset that never overrode it is not
    # evidence of anything: ::enginecfg::save drops options sitting at their
    # default, so most presets have no mpv key at all. A one-line engine simply
    # returns one line and the verdicts fall back to the searched successor.
    set map ""
    if {[catch { set map [::review::mainLineMap [sc_game UCI_mainLine]] } err]} {
        return $err
    }
    set plan $plies
    if {![llength $plan]} { set plan [::review::plan [dict get $map plies] $bookEnd] }
    set positions [::reviewdriver::planPositions $map $plan]
    if {![llength $positions]} {
        # Nothing to search is a pass that finished, not a failure: the book
        # covered the game.
        set state [::reviewdriver::blankState done]
        return ""
    }
    # Before anything touches the board and before the engine starts: the restore
    # at the end is the only thing that puts the reader back where the pass found
    # them.
    set cursor [::review::cursorSave]
    # Not published until the pass has started: a refusal must leave the status
    # of a run that is already in flight alone.
    set starting [dict merge [::reviewdriver::blankState searching] \
        [dict create total [llength $positions]]]
    set token ""
    if {[catch {
        set token [::reviewdriver::start $engine $positions $mpv $depth \
            ::reviewdriver::runProgress ::reviewdriver::runDone]
    } err]} {
        # id 20 is already running a pass, or the engine could not be opened. A
        # pass that is already running keeps its own state: this refusal is the
        # caller's answer, not a report about that run.
        catch { ::review::cursorRestore $cursor }
        if {![dict size $pass]} {
            set state [dict merge [::reviewdriver::blankState failed] \
                [dict create total [llength $positions] reason $err]]
        }
        return $err
    }
    set state $starting
    # `plan` is the moves this run judges (all of them, or -plies); `plies` and
    # `bookEnd` are kept for a writer that derives its own plan (annotate mode).
    set pass [dict create token $token map $map plan $plan \
        plies [dict get $map plies] bookEnd $bookEnd mpv $mpv \
        positions $positions cursor $cursor \
        progress $progress notify $notify writer $writer]
    return ""
}

# Stop the run ::reviewdriver::run started. Nothing is written: the write phase
# only ever runs once the search has finished.
proc ::reviewdriver::cancel {} {
    variable pass
    if {![dict size $pass]} { return 0 }
    return [::reviewdriver::stop [dict get $pass token]]
}

# Between searches a run reports progress only, and the caller's command hears
# about it in its own vocabulary: {*}$cmd <done> <total>.
proc ::reviewdriver::runProgress {done total ply lines} {
    variable pass
    variable state
    if {![dict size $pass]} { return }
    dict set state searched $done
    set cmd [dict get $pass progress]
    if {$cmd ne ""} { catch { {*}$cmd $done $total } }
}

# The runner finished: now, and only now, the game is written.
proc ::reviewdriver::runDone {results} {
    variable pass
    variable state
    if {![dict size $pass]} { return }
    set p $pass
    set total [llength [dict get $p positions]]
    dict set state searched [dict size $results]
    if {[dict size $results] < $total} {
        # A pass that lost its engine reports what it had through the same
        # callback. Half a review is worse than none: nothing is written.
        dict set state state failed
        dict set state reason \
            "the engine stopped after [dict size $results] of $total positions"
        ::reviewdriver::endRun $p
        return
    }
    dict set state state writing
    set counts ""
    if {[catch { set counts [{*}[dict get $p writer] $p $results] } err]} {
        # A writer that blew up wrote part of a review: report it rather than
        # calling the pass clean, and still put the cursor back.
        dict incr state failed
        dict lappend state errors "write phase: $err"
    } else {
        foreach key {written failed} {
            if {[dict exists $counts $key]} {
                dict set state $key [dict get $counts $key]
            }
        }
        if {[dict exists $counts errors]} {
            dict set state errors [dict get $counts errors]
        }
    }
    dict set state state done
    ::reviewdriver::endRun $p
}

# Write one move at a time, ascending, from the verdicts the search produced.
# A writeMove refusal is collected and the next move is still written: writeMove
# leaves the game where it found it on every path, so one refusal cannot corrupt
# the rest.
proc ::reviewdriver::writeResults {p results} {
    set map [dict get $p map]
    set mpv [dict get $p mpv]
    set written 0
    set failed 0
    set errors {}
    set verdicts [::reviewdriver::verdicts $map $results]
    foreach ply [dict get $p plan] {
        if {![dict exists $verdicts $ply]} { continue }
        lassign [dict get $verdicts $ply] label eval_cp
        set err [::review::writeMove $ply $label $eval_cp \
            [::reviewdriver::lines $results [expr {$ply - 1}] $mpv]]
        if {$err eq ""} {
            incr written
        } else {
            incr failed
            lappend errors $err
        }
    }
    # The counts, not the state: runDone owns the status dict, so a -writer that
    # is not this proc reports in the same vocabulary.
    return [dict create written $written failed $failed errors $errors]
}

# Put the cursor back and say whether it landed exactly. Never raises: a restore
# that could not be verified leaves the board on a known position.
proc ::reviewdriver::restoreRun {p} {
    variable state
    # cursorRestore's own answer, not a loc/level comparison: a game that changed
    # while the pass ran can put the same ply on a different position, and only
    # the FEN check inside cursorRestore tells the two apart. 1 is exact, 0 is a
    # known fallback, -1 an unknown one.
    set restored 0
    catch { set restored [::review::cursorRestore [dict get $p cursor]] }
    if {![string is integer -strict $restored] || $restored != 1} {
        set restored 0
    }
    dict set state restored $restored
    return $restored
}

# The end of a run: the cursor goes back exactly once, and the board is told the
# game changed when the caller asked for it. The driver itself has no Tk.
proc ::reviewdriver::endRun {p} {
    variable pass
    set pass {}
    ::reviewdriver::restoreRun $p
    if {[dict get $p notify] && [llength [info commands ::notify::PosChanged]]} {
        catch { ::notify::PosChanged "" }
    }
}
