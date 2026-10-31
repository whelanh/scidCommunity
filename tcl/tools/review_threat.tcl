# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_threat.tcl -- "What's the threat?" for the position on the board.
#
# The strongest move for the side to move is the opponent's threat: one short
# search, the same deterministic facts a move comment uses, and one sentence of
# coach prose. The engine move, in words, is also the fallback when no model is
# configured. Nothing is written into the game.
#
# Adapted from David Crandall's game-review plugin (15_cr_llm.tcl, threat
# probe), which is GPL-2.0-or-later like this project.

namespace eval ::reviewthreat {
    # The connection this probe owns. The review pass has 20 and the verifier
    # its own id; a probe must not disturb either.
    variable id reviewThreat
    variable job {}
    # Set while a finished probe's engine is being closed on the next event
    # turn; the engine's message loop still owns its per-line state.
    variable closing 0
}

# Load what the facts need when the caller has not. The app sources them
# already; a tclsh harness sources this file on its own.
if {[llength [info commands ::facts::movePhrase]] == 0} {
    set threatFiles {}
    catch { lappend threatFiles [file join $::scidTclDir tools comment_facts.tcl] }
    lappend threatFiles [file join [file dirname [info script]] comment_facts.tcl]
    foreach f $threatFiles {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
    unset -nocomplain threatFiles
}
if {[llength [info commands ::enginelimits::goLimits]] == 0} {
    set threatFiles {}
    catch { lappend threatFiles [file join $::scidTclDir tools engine_limits.tcl] }
    lappend threatFiles [file join [file dirname [info script]] engine_limits.tcl]
    foreach f $threatFiles {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
    unset -nocomplain threatFiles
}
if {[llength [info commands ::engineNoWin::initEngine]] == 0} {
    set threatFiles {}
    catch { lappend threatFiles [file join $::scidTclDir tools enginenowin.tcl] }
    lappend threatFiles [file join [file dirname [info script]] enginenowin.tcl]
    foreach f $threatFiles {
        if {[file exists $f]} { catch { source -encoding utf-8 $f } ; break }
    }
    unset -nocomplain threatFiles
}

proc ::reviewthreat::sideName {fen} {
    return [expr {[lindex [split $fen] 1] eq "w" ? "White" : "Black"}]
}

proc ::reviewthreat::title {} {
    if {[llength [info commands ::reviewui::label]]} {
        return [::reviewui::label ToolsWhatThreat]
    }
    if {[llength [info commands tr]]} { return [tr ToolsWhatThreat] }
    return "What's the threat?"
}

# The strongest move in words. Only the clauses that describe a threat belong in
# an answer to "what is the threat?" - escaping or protecting is move commentary,
# not a threat. Never echo the engine's coordinates.
proc ::reviewthreat::threatFacts {fen uci} {
    set d [::facts::describeMove $fen $uci]
    set mover [expr {[dict get $d side] eq "White" ? "w" : "b"}]
    set out [::facts::movePhrase $d]
    if {[dict get $d check]} { append out " with check" }
    if {[dict get $d mate]} { append out " and it is mate" }
    set gains [::facts::gainsOf $fen $uci $mover]
    set threats {}
    foreach g $gains {
        if {[regexp {^(threatens|wins|attacks|threatens mate)} $g]} {
            lappend threats $g
        }
    }
    # Castling is about the mover's own king, not a threat to the opponent; and
    # a threat answer never needs it.
    set filtered {}
    foreach g $threats {
        if {![string match {*castle*} $g]} { lappend filtered $g }
    }
    set threats $filtered
    if {![llength $threats]} {
        foreach g [lrange $gains 0 2] {
            if {[string match {*castle*} $g]} continue
            lappend threats $g
        }
    }
    if {[llength $threats]} {
        append out ", and it [join [lrange $threats 0 1] {, }]"
    }
    return $out
}

# What the move actually does, with the empty case stated rather than left
# blank: a blank line is an invitation to invent a purpose.
proc ::reviewthreat::threatAchieves {fen uci} {
    set d [::facts::describeMove $fen $uci]
    if {[dict get $d mate]} { return "what it achieves: checkmate" }
    set mover [expr {[lindex [split $fen] 1] eq "w" ? "w" : "b"}]
    set parts {}
    foreach g [::facts::gainsOf $fen $uci $mover] { lappend parts $g }
    set freed [::facts::freedPieces $fen $uci $mover]
    if {[llength $freed]} { lappend parts "it frees [join $freed { and }]" }
    if {![llength $parts]} {
        return "what it achieves: nothing immediate - no capture, no check, no new threat, and no piece of [::facts::sideWord $mover]'s is freed"
    }
    return "what it achieves: [join $parts {; }]"
}

# Whether the strongest move is a threat at all. A quiet best move is still the
# strongest move, but calling it a "threat" is wrong: say there is no immediate
# threat instead.
proc ::reviewthreat::forcing {fen uci} {
    set d [::facts::describeMove $fen $uci]
    if {[dict get $d check] || [dict get $d mate]} { return 1 }
    set mover [expr {[dict get $d side] eq "White" ? "w" : "b"}]
    foreach g [::facts::gainsOf $fen $uci $mover] {
        if {[regexp {^(threatens|wins|attacks)} $g]} { return 1 }
    }
    return 0
}

# The FACTS block the model reads: side to move, rule state, the strongest move
# and what it does.
proc ::reviewthreat::factsBlock {fen uci {repCount ""}} {
    set side [::reviewthreat::sideName $fen]
    set lines "[string tolower $side] is to move."
    foreach l [list [::facts::castlingLine $fen] [::facts::epLine $fen] \
                   [::facts::clockLine $fen]] {
        if {$l ne ""} { append lines "\n" $l }
    }
    if {$repCount ne ""} {
        append lines "\n" [::facts::repetitionLine $repCount]
    }
    if {[::reviewthreat::forcing $fen $uci]} {
        append lines "\nThe strongest move: [::reviewthreat::threatFacts $fen $uci]."
    } else {
        # The strongest move exists; it just is not a threat to the opponent.
        append lines "\nThe strongest move is not forcing: [::reviewthreat::threatFacts $fen $uci]."
    }
    append lines "\n[::reviewthreat::threatAchieves $fen $uci]"
    return $lines
}

proc ::reviewthreat::prompt {side facts} {
    return "You are a chess coach telling a player what one side is threatening in the position on the board.
Write ONE sentence of at most 30 words: what $side is threatening, and why it matters to the opponent.

Rules:
- Use only the FACTS below. Do not invent pieces or squares.
- Never write a move in coordinates or algebraic notation. Describe the move in words.
- Never mention castling unless the FACTS line about castling says that side may still castle.
- Never say a move frees, develops, activates or opens a line for any piece unless FACTS names that piece. If FACTS says it achieves nothing immediate, say only that the move does something small and name nothing.
- Never mention en passant unless FACTS says a pawn can be captured that way, and never claim a position has repeated or that the fifty-move rule is close unless FACTS says so.
- If FACTS says the strongest move is not forcing, say that $side has no immediate threat and name the move as the strongest move, not as a threat.
- Name $side explicitly. Never write the phrase \"the side to move\".
- No preamble, no lists.
FACTS:
$facts"
}

proc ::reviewthreat::fallback {fen uci} {
    set side [::reviewthreat::sideName $fen]
    if {[::reviewthreat::forcing $fen $uci]} {
        return "$side's threat: [::reviewthreat::threatFacts $fen $uci]."
    }
    return "$side has no immediate threat. The strongest move: [::reviewthreat::threatFacts $fen $uci]."
}

# The engine preset the probe searches with: the one the first open engine
# window is using, else the first configured preset. A probe owns its own
# connection, so it does not need a window of its own.
proc ::reviewthreat::defaultEngine {} {
    foreach id {1 2} {
        if {[info exists ::enginewin_lastengine($id)]} {
            set name $::enginewin_lastengine($id)
            if {$name ne ""} {
                set cfg ""
                catch { set cfg [::enginecfg::get $name] }
                if {[llength $cfg]} { return $cfg }
            }
        }
    }
    set names ""
    catch { set names [::enginecfg::names] }
    if {[llength $names]} {
        set cfg ""
        catch { set cfg [::enginecfg::get [lindex $names 0]] }
        if {[llength $cfg]} { return $cfg }
    }
    return ""
}

proc ::reviewthreat::show {msg} {
    if {[llength [info commands tk_messageBox]] == 0} { return }
    catch { tk_messageBox -icon info -title [::reviewthreat::title] -message $msg }
}

# One short search. `onDone` is called as {*}$onDone <uci move> <error>, once.
# A UCI engine is required: an XBoard preset would never answer the handshake.
proc ::reviewthreat::search {enginecfg fen onDone} {
    variable id
    variable job
    if {[dict size $job]} { return "a threat probe is already running" }
    if {$::reviewthreat::closing} { return "the previous threat probe is still closing" }
    if {[llength $enginecfg] < 8} { return "no UCI engine is configured" }
    if {[lindex $enginecfg 7] eq "" || [lindex $enginecfg 7] eq 0} {
        return "the threat probe needs a UCI engine"
    }
    # A quick probe, capped like a review: depth 14 is enough for a tactic, and
    # the effective time cap (Review Settings or the preset) bounds it.
    set movetime ""
    catch {
        set eff [::review::effective $enginecfg]
        set movetime [dict get $eff movetime]
    }
    set lim [dict create depth 14 movetime $movetime]
    set job [dict create onDone $onDone watch ""]
    dict set job watch [after 30000 [list ::reviewthreat::timeout]]
    if {[catch {
        ::engineNoWin::initEngine $id [lindex $enginecfg 0] \
            [list ::reviewthreat::message]
    } err]} {
        catch { after cancel [dict get $job watch] }
        set job {}
        return $err
    }
    # One line is all the probe needs; a preset set up for MultiPV 3 must not
    # make it wait for lines it will not use.
    ::engine::send $id SetOptions [list [list MultiPV 1]]
    if {[catch {
        ::engine::send $id Go [list "position fen $fen" \
            [::enginelimits::goLimits $lim]]
    } err]} {
        # Not a callback: the caller reports this once, and no half-open probe
        # is left behind.
        catch { after cancel [dict get $job watch] }
        set job {}
        catch { ::engineNoWin::closeEngine $id }
        return $err
    }
    return ""
}

proc ::reviewthreat::finish {move err} {
    variable id
    variable job
    variable closing
    if {![dict size $job]} { return }
    set cb [dict get $job onDone]
    catch { after cancel [dict get $job watch] }
    set job {}
    # Do not close inside the engine's message loop: onMessages_ still owns the
    # line it just replied to. One event turn later the reply is complete.
    set closing 1
    after 0 [list ::reviewthreat::closeNow $id]
    if {$cb ne ""} { catch { {*}$cb $move $err } }
    return
}

proc ::reviewthreat::closeNow {id} {
    catch { ::engineNoWin::closeEngine $id }
    set ::reviewthreat::closing 0
    return
}

proc ::reviewthreat::timeout {} {
    ::reviewthreat::finish "" "the threat search timed out"
}

proc ::reviewthreat::message {msg} {
    variable job
    if {![dict size $job]} { return }
    lassign $msg type data
    switch -- $type {
        InfoBestMove {
            ::reviewthreat::finish [lindex $data 0] ""
        }
        InfoDisconnected {
            ::reviewthreat::finish "" "the engine disconnected"
        }
    }
}

# Clean a model answer for a message box: one paragraph, ASCII punctuation, no
# markup. The answer is not written to the game, so it does not need the
# comment-token rules - only readability.
proc ::reviewthreat::clean {text} {
    if {[llength [info commands ::reviewprose::clean]]} {
        catch { set text [::reviewprose::clean $text] }
    }
    regsub -all {\s+} $text " " text
    return [string trim $text]
}

proc ::reviewthreat::reply {fallback args} {
    set text [join $args " "]
    set msg $fallback
    if {![string match "ERROR:*" $text]} {
        set clean [::reviewthreat::clean $text]
        if {$clean ne ""} { set msg $clean }
    }
    ::reviewthreat::show $msg
}

# What the model is asked once the engine has answered, or the fallback when
# nothing can write prose.
proc ::reviewthreat::ready {fen rep move err} {
    if {$err ne ""} {
        ::reviewthreat::show "The threat probe could not run: $err"
        return
    }
    set side [::reviewthreat::sideName $fen]
    if {$move eq "" || $move eq "0000"} {
        ::reviewthreat::show "$side has nothing forcing here: no move wins material or gives check."
        return
    }
    # A move the board will not accept is not describable: say so rather than
    # building facts from a position the engine did not mean.
    set legal {}
    catch { set legal [::chessboard::legalMoves [::chessboard::fromFen $fen]] }
    if {[llength $legal] && [lsearch -exact $legal $move] < 0} {
        ::reviewthreat::show "The engine returned a move that is not legal in this position:\n\n$move\n\nNothing was reported."
        return
    }
    set facts [::reviewthreat::factsBlock $fen $move $rep]
    set fallback [::reviewthreat::fallback $fen $move]
    set why ""
    catch { set why [::auto_comment::providerReady] }
    if {$why ne "" || [llength [info commands ::auto_comment::queryAsync]] == 0} {
        # No model is a supported state, not an error: the deterministic
        # sentence is still the answer.
        ::reviewthreat::show $fallback
        return
    }
    set p [::reviewthreat::prompt $side $facts]
    if {[catch {
        ::auto_comment::queryAsync $p 220 [list ::reviewthreat::reply $fallback]
    }]} {
        ::reviewthreat::show $fallback
    }
    return
}

# The menu entry and the engine window's button: probe the board's position and
# answer in one sentence. `enginecfg` is the window's preset when a button has
# one; empty means "find the first engine window or the first preset".
proc ::reviewthreat::ask {{enginecfg ""}} {
    variable job
    if {[dict size $job]} {
        ::reviewthreat::show "A threat probe is already running."
        return
    }
    set cfg $enginecfg
    if {![llength $cfg]} { set cfg [::reviewthreat::defaultEngine] }
    if {![llength $cfg]} {
        ::reviewthreat::show "No engine is configured. Choose one in Tools -> Engine List, or open an engine window first."
        return
    }
    set fen ""
    catch { set fen [sc_pos fen] }
    if {$fen eq ""} {
        ::reviewthreat::show "There is no position to look at."
        return
    }
    set rep ""
    catch {
        set rep [::facts::repFromMainline $fen [sc_pos location]]
    }
    set err [::reviewthreat::search $cfg $fen \
        [list ::reviewthreat::ready $fen $rep]]
    if {$err ne ""} { ::reviewthreat::show $err }
    return
}
