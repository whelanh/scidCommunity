# The game the annotate tests write into.
#
# The parity gate compares two pipelines that both talk to scid through the sc_*
# commands, so the comparison needs a game both of them can drive. This is that
# game: one linear line of moves, each with a comment and a list of NAGs, a
# cursor, a book, and a game-flag set. It is deliberately not a game tree -
# variations are covered by tests/tcl/game_review.tcl, and the artefacts this
# gate compares (RTF diagram, PGN NAGs, the T flag) do not include them.
#
# Fixtures are reset per test with ::gamestub::reset, so tests do not see each
# other's writes.

namespace eval ::gamestub {
    variable moves {}       ;# list of dicts: san uci comment nags
    variable cursor 0
    variable flags {}       ;# game flags, e.g. T
    variable annotator {}   ;# the Annotator tag's text
    variable book {}        ;# cursor position -> list of continuation SANs
    variable replies {}     ;# queue of {score move} for sc_pos analyze
    variable analyzeCalls {}
    variable loaded {}      ;# book file name passed to sc_book load
    variable number 1
    variable games 1
    variable tags {}
    variable inVar 0        ;# writing inside a variation (the classic closing line)
    variable varNodes {}
}

# `pairs` is a list of {SAN UCI}: the same game in the two notations the two
# pipelines use. The classic annotator reads SAN (sc_game info previousMoveNT)
# and the review driver reads UCI (sc_game UCI_mainLine).
proc ::gamestub::reset {pairs} {
    variable moves {}
    variable replies {}
    variable analyzeCalls {}
    foreach pair $pairs {
        lassign $pair san uci
        lappend moves [dict create san $san uci $uci comment "" nags {}]
    }
    set ::gamestub::moves $moves
    set ::gamestub::cursor 0
    set ::gamestub::flags {}
    set ::gamestub::annotator ""
    set ::gamestub::book {}
    set ::gamestub::loaded ""
    set ::gamestub::tags {}
    set ::gamestub::number 1
    set ::gamestub::games 1
    set ::gamestub::inVar 0
    set ::gamestub::varNodes {}
    return
}

proc ::gamestub::node {index} {
    variable moves
    if {$index < 1 || $index > [llength $moves]} { return "" }
    return [lindex $moves [expr {$index - 1}]]
}

proc ::gamestub::setNode {index node} {
    variable moves
    if {$index < 1 || $index > [llength $moves]} { return }
    lset moves [expr {$index - 1}] $node
    set ::gamestub::moves $moves
}

# Where a read and a write land: the last move of the variation being written
# while one is open (the classic closing line), the main line's current move
# otherwise.
proc ::gamestub::currentNode {} {
    if {$::gamestub::inVar} {
        set n [llength $::gamestub::varNodes]
        if {$n < 1} { return "" }
        return [lindex $::gamestub::varNodes [expr {$n - 1}]]
    }
    return [::gamestub::node $::gamestub::cursor]
}

proc ::gamestub::setCurrentNode {node} {
    if {$::gamestub::inVar} {
        set n [llength $::gamestub::varNodes]
        if {$n < 1} { return }
        set v $::gamestub::varNodes
        lset v [expr {$n - 1}] $node
        set ::gamestub::varNodes $v
        return
    }
    ::gamestub::setNode $::gamestub::cursor $node
}

# The field of the move that led to the cursor's position. Position 0 has no
# move, and every reader in both pipelines treats that as "nothing here".
proc ::gamestub::field {name} {
    set node [::gamestub::currentNode]
    if {$node eq ""} {
        if {$name eq "nags"} { return {} }
        return ""
    }
    if {![dict exists $node $name]} { return "" }
    return [dict get $node $name]
}

proc ::gamestub::setField {name value} {
    set node [::gamestub::currentNode]
    if {$node eq ""} { return }
    dict set node $name $value
    ::gamestub::setCurrentNode $node
}

proc ::gamestub::addNag {nag} {
    set node [::gamestub::currentNode]
    if {$node eq ""} { return }
    set nags [dict get $node nags]
    if {[lsearch -exact $nags $nag] < 0} { lappend nags $nag }
    dict set node nags $nags
    ::gamestub::setCurrentNode $node
}

# What the game carries after a run, in the shape a test compares.
proc ::gamestub::nagsByPly {} {
    variable moves
    set out {}
    set ply 0
    foreach node $moves {
        incr ply
        set nags [dict get $node nags]
        if {[llength $nags]} { dict set out $ply $nags }
    }
    return $out
}

proc ::gamestub::commentsByPly {} {
    variable moves
    set out {}
    set ply 0
    foreach node $moves {
        incr ply
        set comment [dict get $node comment]
        if {$comment ne ""} { dict set out $ply $comment }
    }
    return $out
}

proc ::gamestub::san {ply} {
    set node [::gamestub::node $ply]
    if {$node eq ""} { return "" }
    return [dict get $node san]
}

proc ::gamestub::queueReplies {replies} {
    set ::gamestub::replies $replies
    return
}

proc ::gamestub::popReply {} {
    if {[llength $::gamestub::replies] == 0} { return [list 0 "e2e4"] }
    set first [lindex $::gamestub::replies 0]
    set ::gamestub::replies [lrange $::gamestub::replies 1 end]
    return $first
}

proc ::gamestub::appendMove {san uci} {
    if {$::gamestub::inVar} {
        lappend ::gamestub::varNodes [dict create san $san uci $uci comment "" nags {}]
        return [llength $::gamestub::varNodes]
    }
    lappend ::gamestub::moves [dict create san $san uci $uci comment "" nags {}]
    incr ::gamestub::cursor
    return $::gamestub::cursor
}

### The sc_* commands the two pipelines and the RTF collector drive.

proc sc_pos {sub args} {
    switch -- $sub {
        getComment  { return [::gamestub::field comment] }
        setComment  {
            ::gamestub::setField comment [lindex $args 0]
            return [lindex $args 0]
        }
        addNag      {
            ::gamestub::addNag [lindex $args 0]
            return [lindex $args 0]
        }
        getNags     {
            set nags [::gamestub::field nags]
            if {![llength $nags]} { return 0 }
            return [join $nags " "]
        }
        clearNags   {
            ::gamestub::setField nags {}
            return ""
        }
        side        {
            return [expr {$::gamestub::cursor % 2 == 0 ? "white" : "black"}]
        }
        moveNumber  { return [expr {$::gamestub::cursor / 2 + 1}] }
        isAt        {
            if {[lindex $args 0] eq "vend"} {
                return [expr {$::gamestub::cursor >= [llength $::gamestub::moves]}]
            }
            return 0
        }
        fen         { return "FEN$::gamestub::cursor w KQkq - 0 1" }
        location    { return $::gamestub::cursor }
        analyze     {
            lappend ::gamestub::analyzeCalls $args
            return [::gamestub::popReply]
        }
    }
    return ""
}

proc sc_move {sub args} {
    switch -- $sub {
        start   { set ::gamestub::cursor 0 }
        forward {
            set n 1
            if {[llength $args]} { set n [lindex $args 0] }
            set c [expr {$::gamestub::cursor + $n}]
            set max [llength $::gamestub::moves]
            if {$c > $max} { set c $max }
            set ::gamestub::cursor $c
        }
        back    {
            set n 1
            if {[llength $args]} { set n [lindex $args 0] }
            set c [expr {$::gamestub::cursor - $n}]
            if {$c < 0} { set c 0 }
            set ::gamestub::cursor $c
        }
        ply     { set ::gamestub::cursor [lindex $args 0] }
        addSan  { ::gamestub::appendMove [lindex $args 0] [lindex $args 0] }
    }
    return $::gamestub::cursor
}

# Variations are written and then dropped: the closing line the classic adds at
# the last move goes into an open variation and never becomes part of the main
# line, so no reader downstream of this model ever sees one.
proc sc_var {sub args} {
    switch -- $sub {
        count  { return 0 }
        level  { return [expr {$::gamestub::inVar ? 1 : 0}] }
        number { return 0 }
        list   { return {} }
        create {
            set ::gamestub::inVar 1
            set ::gamestub::varNodes {}
            return 0
        }
        delete { set ::gamestub::varNodes {} ; return 0 }
        enter  { return 0 }
        exit   {
            set ::gamestub::inVar 0
            set ::gamestub::varNodes {}
            return 0
        }
    }
    return ""
}

# The classic inserts moves into the variation it just created.
proc sc_move_add {args} { return 0 }
# ... through the uci layer, which is where analysis.tcl's own sc_move_add sends
# them: the variation is dropped by this model, so nothing is added.
namespace eval ::uci {}
proc ::uci::sc_move_add {moves} { return 0 }

proc sc_game {sub args} {
    switch -- $sub {
        info {
            set what [lindex $args 0]
            if {$what eq "previousMove" || $what eq "previousMoveNT"} {
                return [::gamestub::san $::gamestub::cursor]
            }
            return ""
        }
        UCI_mainLine {
            set ml [list "position startpos"]
            foreach node $::gamestub::moves {
                lappend ml [dict get $node uci]
            }
            return $ml
        }
        number  { return $::gamestub::number }
        load    {
            set ::gamestub::number [lindex $args 0]
            set ::gamestub::cursor 0
            return ""
        }
        push    { return "" }
        pop     { return "" }
        tags    {
            set op [lindex $args 0]
            if {$op eq "get"} {
                # scid returns the extra tags as one string of lines, which is
                # also what the callers iterate over.
                set out ""
                foreach pair $::gamestub::tags {
                    lassign $pair name value
                    append out "$name \"$value\"\n"
                }
                return $out
            }
            if {$op eq "set"} {
                set value [lindex [lrange $args 2 end] 0]
                if {[lindex $args 1] eq "-extra"} {
                    # scid clears the extra tags and parses each element as a
                    # {name value} pair; anything that is not a pair is dropped.
                    set kept {}
                    foreach elem $value {
                        if {[llength $elem] == 2} { lappend kept $elem }
                    }
                    set ::gamestub::tags $kept
                    set ::gamestub::annotator ""
                    foreach pair $kept {
                        lassign $pair name value
                        append ::gamestub::annotator "$name \"$value\"\n"
                    }
                }
            }
            return ""
        }
    }
    return ""
}

proc sc_base {sub args} {
    switch -- $sub {
        current  { return 0 }
        numGames { return $::gamestub::games }
        gameflag {
            lassign $args base game op flag
            if {$op eq "set"} {
                lappend ::gamestub::flags $flag
                return 1
            }
            return [expr {[lsearch -exact $::gamestub::flags $flag] >= 0}]
        }
    }
    return ""
}

# The book is a dict from cursor position to the SAN continuations it offers
# there: ::gamestub::book is what the two pipelines read.
proc sc_book {sub args} {
    switch -- $sub {
        load  { set ::gamestub::loaded [lindex $args 0] ; return 1 }
        close { return 1 }
        moves {
            set at $::gamestub::cursor
            if {[dict exists $::gamestub::book $at]} {
                return [dict get $::gamestub::book $at]
            }
            return ""
        }
    }
    return ""
}

proc sc_info {args} { return "" }
proc sc_filter {args} { return "" }
proc sc_import {args} { return "" }

### The rest of the application the classic annotator calls into.

# The two translation entry points both pipelines use. They are identity here so
# that a parity comparison compares the same text on both sides; the few keys the
# annotator writes into comments are the English ones, because that is what a
# language file that was never updated falls back to.
proc tr {key args} { return $key }
proc ::trans {text} { return $text }
array set ::tr {
    MoveOutOfBook "Out of book"
    LastBookMove  "Last book move"
}

proc updateBoard {args} { return }
proc resetAnalysis {args} { return }
proc changePVSize {args} { return }

namespace eval ::move {}
proc ::move::Forward {} { sc_move forward ; return }
proc ::move::Back {} { sc_move back ; return }
