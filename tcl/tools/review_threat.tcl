# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_threat.tcl -- "What's the threat?" for the position on the board.
#
# One short search on a connection of its own, the deterministic facts that
# describe the engine's move, and one sentence of coach prose on top of them.
# Nothing is written into the game.
#
# The facts are the answer. They come from the position - the move, its SAN and
# the clauses ::facts builds for a move comment - so the probe still answers when
# no model is configured. No provider is a supported state, not a failure: prose
# is an enrichment that can be absent.
#
# The connection is one-shot: opened for the search, closed in the reply that
# delivered the move. ::engine::reply captures its channel before it runs a
# callback and stops when the callback has closed the connection (#422 item 1,
# #423), which is what makes closing here safe rather than one event turn later.
#
# Ported from the threat probe on the review-coach-prototype branch (5556eb44),
# which follows 15_cr_llm.tcl in David Crandall's game-review plugin
# (GPL-2.0-or-later, like this project). See docs/third-party-notices.md.

namespace eval ::reviewthreat {
    # The connection this probe owns. The review pass has 20 and the verifier its
    # own id; a probe must not disturb either, and no engine window can take
    # this one because window ids are numbers.
    variable id reviewThreat
    # The probe in flight: {onDone <command> watch <timer>}. Empty when idle.
    variable job {}
}

# The side to move, the way the facts and the answers name it.
proc ::reviewthreat::sideName {fen} {
    return [expr {[lindex [split $fen] 1] eq "w" ? "White" : "Black"}]
}

# The move in SAN, through the board's own conversion - the command
# ::facts::mateInOne and the report already use. A tclsh harness, or a build
# without the C board, has no sc_pos; the answer then carries no SAN rather than
# the engine's coordinates, which are not a description a reader can use.
proc ::reviewthreat::san {fen uci} {
    if {[llength [info commands sc_pos]] == 0} { return "" }
    set out ""
    catch { set out [sc_pos coordToSAN $fen [list $uci]] }
    if {[llength $out] != 1} { return "" }
    return [lindex $out 0]
}

# The clauses that describe a threat, in the vocabulary a move comment uses.
# Escaping danger and protecting a piece are about the mover's own position, not
# a threat to the opponent, and castling is about the mover's king: none of them
# belongs in an answer to "what is the threat?". A mate is stated by the answer
# itself, so "is checkmate" is not repeated here.
proc ::reviewthreat::threatClauses {fen uci} {
    set d [::facts::describeMove $fen $uci]
    set mover [expr {[dict get $d side] eq "White" ? "w" : "b"}]
    set out {}
    foreach g [::facts::gainsOf $fen $uci $mover] {
        if {![regexp {^(threatens|wins|attacks)} $g]} { continue }
        if {$g eq "is checkmate"} { continue }
        if {[string match {*castle*} $g]} { continue }
        lappend out $g
    }
    return $out
}

# Whether the strongest move is a threat at all. A quiet best move is still the
# strongest move, and calling it a threat is the one thing the answer must not
# do: say there is no immediate threat instead.
proc ::reviewthreat::forcing {fen uci} {
    set d [::facts::describeMove $fen $uci]
    if {[dict get $d check] || [dict get $d mate]} { return 1 }
    return [expr {[llength [::reviewthreat::threatClauses $fen $uci]] > 0}]
}

# The deterministic answer: what the move is, in SAN and in words, and what it
# threatens. One dict, so the prose path and the no-provider path cannot drift:
#
#   {side White|Black san <SAN or ""> forcing 0|1 text <one or two sentences>}
proc ::reviewthreat::answer {fen uci} {
    set d [::facts::describeMove $fen $uci]
    set side [::reviewthreat::sideName $fen]
    set san [::reviewthreat::san $fen $uci]
    set forcing [::reviewthreat::forcing $fen $uci]
    set detail [::facts::movePhrase $d]
    if {[dict get $d mate]} {
        append detail ", and it is checkmate"
    } elseif {[dict get $d check]} {
        append detail ", with check"
    }
    if {$forcing} {
        set clauses [::reviewthreat::threatClauses $fen $uci]
        if {[llength $clauses]} {
            append detail ", and it [join [lrange $clauses 0 1] {, }]"
        }
        set text [expr {$san ne "" ? "$side threatens $san" : "$side's threat"}]
        append text ": $detail."
    } else {
        # The strongest move exists; it is just not a threat. Naming it as one
        # would be the invention the answer exists to avoid.
        set text "$side has no immediate threat. "
        append text [expr {$san ne "" ? "The strongest move is $san" : "The strongest move"}]
        append text ": $detail."
    }
    return [dict create side $side san $san forcing $forcing detail $detail text $text]
}

# The FACTS block the model reads: side to move, rule state, the strongest move
# and what it threatens. It says the quiet case too, so a model cannot turn a
# quiet move into a threat to fill the gap.
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
    set a [::reviewthreat::answer $fen $uci]
    set detail [dict get $a detail]
    set san [dict get $a san]
    set named [expr {$san ne "" ? "$san - $detail" : $detail}]
    if {[dict get $a forcing]} {
        append lines "\nThe strongest move: $named."
    } else {
        append lines "\nThe strongest move is not forcing: $named."
    }
    return $lines
}

# One sentence of coach prose over the facts, and nothing else. The rules are
# the ones the comment vocabulary can prove; a model that breaks them is not
# allowed to take the facts away, because the answer is shown first.
proc ::reviewthreat::prompt {side facts} {
    return "You are a chess coach telling a player what one side is threatening in the position on the board.
Write ONE sentence of at most 30 words: what $side is threatening, and why it matters to the opponent.

Rules:
- Use only the FACTS below. Do not invent pieces or squares.
- Never write a move in coordinates or algebraic notation. Describe the move in words.
- Never mention castling unless the FACTS line about castling says that side may still castle.
- Never say a move frees, develops, activates or opens a line for any piece unless FACTS names that piece.
- If FACTS says the strongest move is not forcing, say that $side has no immediate threat and name the move as the strongest move, not as a threat.
- Name $side explicitly. Never write the phrase \"the side to move\".
- No preamble, no lists.
FACTS:
$facts"
}

# The translation of a frame this module owns, or its English text when the
# window has no such key: the probe must never show a tag to a user.
proc ::reviewthreat::phrase {key english} {
    set out $english
    if {[llength [info commands ::tr]]} {
        set text ""
        # No `return` inside the catch body: Tcl turns it into TCL_RETURN and
        # catch reports a failure, which throws the translation away.
        catch { set text [::tr $key] }
        if {$text ne "" && $text ne $key} { set out $text }
    }
    return $out
}

proc ::reviewthreat::title {} {
    return [::reviewthreat::phrase ToolsWhatThreat {What's the threat?}]
}

# An answer is shown, never written: one message box, the facts first.
proc ::reviewthreat::show {msg} {
    if {[llength [info commands tk_messageBox]] == 0} { return }
    catch { tk_messageBox -icon info -title [::reviewthreat::title] -message $msg }
    return
}

# The engine preset the probe searches with: the one the first open engine
# window is using, else the first configured preset. The probe owns its own
# connection, so it needs no window of its own.
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

# One short search on a connection of its own. `onDone` is called once, as
# {*}$onDone <uci move> <error>. Returns "" when the search started, or the
# reason it could not - a refusal is reported by the caller, so a half-open
# probe is never left behind.
#
# A UCI engine is required: an XBoard preset would never answer the handshake.
proc ::reviewthreat::search {enginecfg fen onDone} {
    variable id
    variable job
    if {[dict size $job]} {
        return [::reviewthreat::phrase WhatThreatRunning {A threat probe is already running.}]
    }
    if {[llength $enginecfg] < 8} { return "no UCI engine is configured" }
    if {[lindex $enginecfg 7] eq "" || [lindex $enginecfg 7] eq 0} {
        return "the threat probe needs a UCI engine"
    }
    # A quick probe: depth 14 is enough for a tactic, and the review's time cap
    # bounds it. The pass's depth is deliberately not used - this is one answer
    # on demand, not a review.
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
    # One line is all the probe needs: a preset set up for MultiPV 3 must not
    # make it wait for lines it will not use.
    if {[catch {
        ::engine::send $id SetOptions [list [list MultiPV 1]]
        ::engine::send $id Go [list "position fen $fen" \
            [::enginelimits::goLimits $lim]]
    } err]} {
        catch { after cancel [dict get $job watch] }
        set job {}
        catch { ::engineNoWin::closeEngine $id }
        return $err
    }
    return ""
}

# One answer, one close. The job is cleared before anything can re-enter, so a
# timer that fires while the box is open finds nothing to do.
proc ::reviewthreat::finish {move err} {
    variable id
    variable job
    if {![dict size $job]} { return }
    set cb [dict get $job onDone]
    catch { after cancel [dict get $job watch] }
    set job {}
    # Closed inside the reply, not one event turn later: #423 is what makes that
    # safe, and it leaves no process running behind a modal message box.
    catch { ::engineNoWin::closeEngine $id }
    if {$cb ne ""} { catch { {*}$cb $move $err } }
    return
}

proc ::reviewthreat::timeout {} {
    ::reviewthreat::finish "" "the threat search timed out"
}

# The engine's callback. Every message that ends the search goes through finish;
# anything else (InfoConfig, InfoGo) is the handshake and needs no answer.
proc ::reviewthreat::message {msg} {
    variable job
    if {![dict size $job]} { return }
    lassign $msg type data
    switch -- $type {
        InfoBestMove     { ::reviewthreat::finish [lindex $data 0] "" }
        InfoDisconnected { ::reviewthreat::finish "" "the engine disconnected" }
    }
    return
}

# Clean a model answer for a message box: one paragraph, ASCII punctuation, no
# markup. The answer is not written to the game, so only readability matters.
proc ::reviewthreat::clean {text} {
    if {[llength [info commands ::reviewprose::clean]]} {
        catch { set text [::reviewprose::clean $text] }
    }
    regsub -all {\s+} $text " " text
    return [string trim $text]
}

# The deterministic answer comes first and stays: a model adds a sentence, it
# does not replace the facts the board proves.
proc ::reviewthreat::reply {facts args} {
    set text [join $args " "]
    if {[string match "ERROR:*" $text]} {
        ::reviewthreat::show $facts
        return
    }
    set clean [::reviewthreat::clean $text]
    if {$clean eq ""} {
        ::reviewthreat::show $facts
        return
    }
    ::reviewthreat::show "$facts\n\n$clean"
}

# The answer, once the engine has replied: the facts always, the prose when a
# model is configured. An error or an illegal move is reported rather than turned
# into facts from a position the engine did not mean.
proc ::reviewthreat::ready {fen rep move err} {
    if {$err ne ""} {
        ::reviewthreat::show [format [::reviewthreat::phrase WhatThreatFailed \
            {The threat probe could not run: %s}] $err]
        return
    }
    set side [::reviewthreat::sideName $fen]
    if {$move eq "" || $move eq "0000"} {
        ::reviewthreat::show [format [::reviewthreat::phrase WhatThreatNothingForcing \
            {%s has nothing forcing here: no move wins material or gives check.}] $side]
        return
    }
    set legal {}
    catch { set legal [::chessboard::legalMoves [::chessboard::fromFen $fen]] }
    if {[llength $legal] && [lsearch -exact $legal $move] < 0} {
        set why "the engine returned a move that is not legal in this position ($move)"
        ::reviewthreat::show [format [::reviewthreat::phrase WhatThreatFailed \
            {The threat probe could not run: %s}] $why]
        return
    }
    set a [::reviewthreat::answer $fen $move]
    set facts [dict get $a text]
    set why ""
    catch { set why [::auto_comment::providerReady] }
    if {$why ne "" || [llength [info commands ::auto_comment::queryAsync]] == 0} {
        # No model is a supported state, not an error: the deterministic
        # sentence is still the whole answer.
        ::reviewthreat::show $facts
        return
    }
    set prompt [::reviewthreat::prompt $side [::reviewthreat::factsBlock $fen $move $rep]]
    if {[catch {
        ::auto_comment::queryAsync $prompt 160 [list ::reviewthreat::reply $facts]
    }]} {
        ::reviewthreat::show $facts
    }
    return
}

# The menu entry and the engine window's button: probe the board's position and
# answer. `enginecfg` is the window's preset when a button has one; empty means
# "the first engine window's preset, or the first configured one".
proc ::reviewthreat::ask {{enginecfg ""}} {
    variable job
    if {[dict size $job]} {
        ::reviewthreat::show [::reviewthreat::phrase WhatThreatRunning \
            {A threat probe is already running.}]
        return
    }
    set cfg $enginecfg
    if {![llength $cfg]} { set cfg [::reviewthreat::defaultEngine] }
    if {![llength $cfg]} {
        ::reviewthreat::show [::reviewthreat::phrase WhatThreatNoEngine \
            {No engine is configured. Choose one in Tools -> Engine List, or open an engine window first.}]
        return
    }
    set fen ""
    catch { set fen [sc_pos fen] }
    if {$fen eq ""} {
        ::reviewthreat::show [::reviewthreat::phrase WhatThreatNoPosition \
            {There is no position to look at.}]
        return
    }
    set rep ""
    catch { set rep [::facts::repFromMainline $fen [sc_pos location]] }
    set err [::reviewthreat::search $cfg $fen \
        [list ::reviewthreat::ready $fen $rep]]
    if {$err ne ""} {
        ::reviewthreat::show [format [::reviewthreat::phrase WhatThreatFailed \
            {The threat probe could not run: %s}] $err]
    }
    return
}
