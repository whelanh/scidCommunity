# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_cloud.tcl -- the Lichess cloud pre-pass behind a review.
#
# The review pass used to search every position locally. Lichess keeps a
# stored evaluation for a great many positions, answered by
# GET /api/cloud-eval with a depth and a list of lines (::lichess_eval's own
# endpoint), and where that evaluation is at least as deep as the search the
# user asked for there is nothing to gain from searching the position again.
#
# This module owns only the decision. It does not search, does not touch the
# board and does not write: the driver hands it a position spec and its limits
# and gets back what to do with the position.
#
#   D = the effective depth bound (::review::passLimits), 0 = none
#   T = the effective time bound in ms, 0 = none
#   C = the cloud evaluation's depth
#   L = the local engine's achieved depth
#
#   T = 0  C >= D  -> adopt the cloud and skip the local search entirely.
#          C <  D  -> search locally (no caching, no waiting).
#   T > 0  the local depth is unknowable until the search ends, so the cloud is
#          queried beside the search and the deeper evaluation wins when the
#          search finishes; a tie goes to the local engine, which is the engine
#          the user configured. This holds even when D > C, because the time cap
#          can cut L below both.
#
# The transport is ::lichess_eval's: one HTTP client, one endpoint. The query is
# asynchronous (::lichess_eval::cloudEvalAsync) and never blocks the Tk event
# loop, and a reply that has not landed when the local search completes is not
# waited for - the local result is adopted and the run is not extended.
#
# The cache key is the evaluation-relevant FEN: placement, side to move,
# castling rights and en-passant square. The halfmove and fullmove counters do
# not change an evaluation, so they are dropped; two positions that differ only
# in those counters share one cache entry.

namespace eval ::reviewcloud {
    # FEN key + "|" + mpv -> the parsed evaluation, or the string "none" for a
    # FEN Lichess holds nothing for. Keyed by mpv as well, because a reply
    # carrying fewer lines than the verdict needs cannot be used at all.
    variable cache
    # handle -> {fen key mpv arrive} for a request in flight.
    variable pending
    # handle -> the parsed evaluation, waiting for the driver to take it.
    variable entries
    # Set when the transport itself failed (no curl, no network). One failure is
    # the whole pass's answer: a review of eighty positions must not spend ten
    # seconds per position discovering the same thing. It lasts for the pass that
    # saw it and no longer - ::reviewcloud::newPass clears it at the start of the
    # next one (the cache is kept).
    variable unusable 0
    array set cache {}
    array set pending {}
    array set entries {}
}

# Forget every cached evaluation and every request in flight. Tests call it;
# a session does not need it, because a cached evaluation is keyed by the
# position it describes.
proc ::reviewcloud::reset {} {
    variable cache
    variable pending
    variable entries
    variable unusable
    # `array set x {}` sets nothing and clears nothing; only `array unset` does.
    array unset cache
    array unset pending
    array unset entries
    array set cache {}
    array set pending {}
    array set entries {}
    set unusable 0
    return
}

# Whether this pass may ask the cloud at all.
proc ::reviewcloud::enabled {} {
    variable unusable
    return [expr {!$unusable && [llength [info commands ::lichess_eval::cloudEvalAsync]] > 0}]
}

# A pass is starting.
#
# A failure ends the cloud for the pass that saw it, not for the session: a rate
# limit at one position, one timeout, or a network that was down when the run
# began must not disable the pre-pass for every later review while the setting
# still shows it on. The cache is kept - it is keyed by the position, and a
# stored evaluation does not go stale.
#
# The caller is ::reviewdriver::start, and only when it is starting a pass with
# the pre-pass on: a pass with it off neither clears the flag nor sets it.
proc ::reviewcloud::newPass {} {
    set ::reviewcloud::unusable 0
    return
}

# The evaluation-relevant FEN: the first four fields. Halfmove and fullmove
# counters must not fragment the cache.
proc ::reviewcloud::key {fen} {
    return [join [lrange [split [string trim $fen]] 0 3] " "]
}

proc ::reviewcloud::cacheKey {fen mpv} {
    return "[::reviewcloud::key $fen]|$mpv"
}

# The FEN of a position spec, or "" when it cannot be named.
#
# The driver is handed `position ...` specs (the shape ::engine::send Go takes)
# and never moves the board to read one, so the position is replayed from the
# spec itself: ::chessboard is the pure-Tcl board the comment facts already use.
# A spec this cannot follow - an unknown header, a move that will not apply -
# is a position the cloud is not asked about, and the pass searches it locally.
proc ::reviewcloud::fenForSpec {spec} {
    if {[llength [info commands ::chessboard::makeMove]] == 0} { return "" }
    set words [split [string trim $spec]]
    if {[lindex $words 0] ne "position"} { return "" }
    set i 1
    set pos ""
    switch -- [lindex $words $i] {
        startpos {
            if {[catch {
                set pos [::chessboard::fromFen \
                    {rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1}]
            }]} {
                return ""
            }
            incr i
        }
        fen {
            set fields [lrange $words [expr {$i + 1}] [expr {$i + 6}]]
            if {[llength $fields] < 4} { return "" }
            if {[catch { set pos [::chessboard::fromFen [join $fields " "]] }]} {
                return ""
            }
            incr i 7
        }
        default { return "" }
    }
    if {[lindex $words $i] eq "moves"} {
        incr i
        foreach move [lrange $words $i end] {
            if {[catch { set pos [::chessboard::makeMove $pos $move] }]} {
                return ""
            }
        }
    }
    if {[catch { set fen [::chessboard::toFen $pos] }]} { return "" }
    return $fen
}

# The reply as a dict, or "" when it carries nothing this pass can use.
#
#   depth  the depth of the evaluation (one depth for every line)
#   stm    the side to move at the queried position
#   pvs    {{moves cp mate} ...} in the reply's order, best first
#
# The reply's score is White's point of view and its mate distance is White's;
# both are turned to the mover's when the lines are built (::reviewcloud::lines),
# which is the convention ::reviewdriver's own lines use.
proc ::reviewcloud::parse {json fen} {
    if {[string first {"pvs"} $json] < 0} { return "" }
    if {![regexp {"depth"\s*:\s*(\d+)} $json -> depth]} { return "" }
    set stm [lindex [split [string trim $fen]] 1]
    if {$stm ne "w" && $stm ne "b"} { return "" }
    set pvs {}
    if {[regexp -indices {"pvs"\s*:\s*\[} $json match]} {
        set remaining [string range $json [lindex $match 1] end]
        while {[regexp -indices {\{[^\}]*\}} $remaining objMatch]} {
            set obj [string range $remaining [lindex $objMatch 0] [lindex $objMatch 1]]
            set moves ""
            set cp ""
            set mate ""
            regexp {"moves"\s*:\s*"([^"]*)"} $obj -> moves
            regexp {"cp"\s*:\s*(-?\d+)} $obj -> cp
            regexp {"mate"\s*:\s*(-?\d+)} $obj -> mate
            if {$moves eq ""} {
                set remaining [string range $remaining [expr {[lindex $objMatch 1] + 1}] end]
                continue
            }
            if {$cp eq "" && $mate eq ""} {
                # A line with no score cannot feed a verdict, and a first line
                # that cannot be read makes the whole reply unusable: the order
                # is the ranking.
                if {![llength $pvs]} { return "" }
                set remaining [string range $remaining [expr {[lindex $objMatch 1] + 1}] end]
                continue
            }
            lappend pvs [list $moves $cp $mate]
            set remaining [string range $remaining [expr {[lindex $objMatch 1] + 1}] end]
        }
    }
    if {![llength $pvs]} { return "" }
    return [dict create depth $depth stm $stm pvs $pvs]
}

# The evaluation's depth. -1 for no evaluation at all, so it loses every
# comparison without a caller having to test for it first.
proc ::reviewcloud::depth {entry} {
    if {$entry eq ""} { return -1 }
    if {![dict exists $entry depth]} { return -1 }
    return [dict get $entry depth]
}

# The evaluation as the driver's own line dict - MultiPV index -> {depth score
# type pv} - or "" when the reply cannot serve this pass.
#
# The lines the verdict needs are ::review::mpv of them: `great` and `brilliant`
# are decided against the alternatives, so a MultiPV-1 reply is not a shortcut,
# it is a different answer. A short reply is therefore no reply.
proc ::reviewcloud::lines {entry mpv} {
    if {$entry eq ""} { return "" }
    if {![string is integer -strict $mpv] || $mpv < 1} { return "" }
    set pvs [dict get $entry pvs]
    if {[llength $pvs] < $mpv} { return "" }
    set depth [dict get $entry depth]
    set stm [dict get $entry stm]
    set out {}
    set index 0
    foreach pv [lrange $pvs 0 [expr {$mpv - 1}]] {
        incr index
        lassign $pv moves cp mate
        set pvMoves {}
        foreach move [split $moves " "] {
            if {$move ne ""} { lappend pvMoves $move }
        }
        if {![llength $pvMoves]} { continue }
        if {$mate ne "" && [string is integer -strict $mate]} {
            # White's mate distance to the mover's, then the app's encoding is
            # ::reviewdriver::lineScore's job (::movelabels::mateToCp), exactly
            # as it is for a local engine line.
            set value [expr {$stm eq "w" ? $mate : -$mate}]
            set type mate
        } elseif {$cp ne "" && [string is integer -strict $cp]} {
            set value [expr {$stm eq "w" ? $cp : -$cp}]
            set type cp
        } else {
            continue
        }
        dict set out $index [list $depth $value $type $pvMoves]
    }
    return $out
}

# The cloud evaluation as a usable line dict, or "" when it cannot be used.
proc ::reviewcloud::usable {entry mpv} {
    return [::reviewcloud::lines $entry $mpv]
}

# The comparison, in one place.
#
# T = 0 is a depth bound only: the cloud wins at C >= D, because D is the depth
# the user asked for and the cloud is at least that deep.
# T > 0 defers the answer to the local search's achieved depth: the cloud wins
# only when it is deeper, and a tie goes to the local engine.
proc ::reviewcloud::decide {D T C L} {
    if {$T > 0} {
        return [expr {$C > $L ? "cloud" : "local"}]
    }
    if {[::reviewcloud::reaches $D $C]} { return cloud }
    return local
}

# Whether the cloud is at least as deep as the depth bound - the depth-only rule
# (T = 0), where the local search never runs at all.
#
# This is the whole comparison for that case: C >= D is the depth the user asked
# for, and the cloud is at least that deep. It is NOT the rule for stopping a
# search under a time cap - see ::reviewcloud::deeper.
proc ::reviewcloud::reaches {D C} {
    return [expr {$D > 0 && $C >= $D}]
}

# Whether the cloud is strictly deeper than the depth bound.
#
# With a time cap the local search does run, and it can still reach D, so a reply
# equal to the bound is not unambiguously better than what the search will find:
# only a reply PAST D is. Anything else is compared when the search ends, where
# the deeper evaluation wins and a tie goes to the local engine - the comparison
# at completion decides C > D >= L in the cloud's favour anyway, which is why
# stopping there early cannot change the outcome.
proc ::reviewcloud::deeper {D C} {
    return [expr {$D > 0 && $C > $D}]
}

# What to do with one position.
#
#   handle  a name the caller owns, used to match the reply to the position
#   spec    the engine's own `position ...` spec for the position
#   limits  {depth N movetime M} - ::review::passLimits' answer
#   mpv     the lines the verdict needs
#   variant "standard" or the game's variant (the cloud is only asked for
#           standard chess: the FEN this module replays is a standard one)
#   arrive  called as {*}$arrive <handle> <entry> when a reply lands, so a
#           depth-only pass can continue and a timed one can stop early
#
# Answers {action ... lines ... depth ...}:
#   cloud  adopt these lines; the local search is not run (or is cancelled)
#   wait   a query is in flight and the answer decides: do not search yet
#   query  a query is in flight beside the local search; search now
#   local  search locally, with nothing from the cloud
proc ::reviewcloud::begin {handle spec limits mpv variant arrive} {
    set local [dict create action local lines {} depth 0]
    if {![::reviewcloud::enabled]} { return $local }
    if {$variant ne "standard"} { return $local }
    set D 0
    set T 0
    catch { set D [dict get $limits depth] }
    catch { set T [dict get $limits movetime] }
    if {![string is integer -strict $D]} { set D 0 }
    if {![string is integer -strict $T]} { set T 0 }
    # With neither bound there is no question to answer: a pass with no depth
    # and no time has nothing for the cloud to be deeper than.
    if {$D <= 0 && $T <= 0} { return $local }
    set fen [::reviewcloud::fenForSpec $spec]
    if {$fen eq ""} { return $local }
    set k [::reviewcloud::cacheKey $fen $mpv]
    set entry ""
    set known 0
    if {[info exists ::reviewcloud::cache($k)]} {
        set known 1
        set entry $::reviewcloud::cache($k)
    }
    if {!$known} {
        # A depth-only pass has nothing else to do while the lookup runs, and
        # the lookup is one cheap call; a timed pass searches beside it.
        if {![::reviewcloud::query $handle $fen $variant $mpv $arrive]} {
            # The transport would not even start: nothing is held, nothing will
            # arrive, and the position is searched locally like any other.
            return $local
        }
        if {$T > 0} { return [dict create action query lines {} depth 0] }
        return [dict create action wait lines {} depth 0]
    }
    if {$entry eq "none"} { return $local }
    set lines [::reviewcloud::lines $entry $mpv]
    if {$lines eq ""} { return $local }
    set C [dict get $entry depth]
    if {$T <= 0} {
        if {[::reviewcloud::decide $D 0 $C 0] eq "cloud"} {
            return [dict create action cloud lines $lines depth $C]
        }
        return $local
    }
    # A time cap is in force, so the local search runs either way - unless the
    # cloud is already deeper than the depth bound, in which case the search
    # cannot reach past it and the comparison at completion would choose the
    # cloud anyway. A reply AT the bound is not that case: the search can still
    # reach it, and the tie goes to the local engine, so it is held instead.
    if {[::reviewcloud::deeper $D $C]} {
        return [dict create action cloud lines $lines depth $C]
    }
    # Held for the comparison when the local search finishes.
    set ::reviewcloud::entries($handle) $entry
    return $local
}

# Ask the cloud, asynchronously. Never waits for the answer: the reply arrives
# through the event loop and calls ::reviewcloud::arrived.
#
# Answers 1 when the transport started, 0 when it did not. A transport that
# failed to start is NOT reported through `arrive` here: a callback made from
# inside this call would reach the driver before ::reviewcloud::begin had
# returned, and a depth-only pass has nothing to settle until begin's answer has
# told the driver it is waiting - the reply would be dropped and the pass would
# hang with nothing to move it on. The caller tests the return value instead.
proc ::reviewcloud::query {handle fen variant mpv arrive} {
    variable pending
    set ::reviewcloud::pending($handle) [dict create \
        fen $fen mpv $mpv arrive $arrive]
    if {[catch {
        ::lichess_eval::cloudEvalAsync $fen $variant $mpv \
            [list ::reviewcloud::arrived $handle]
    } err]} {
        # The transport could not even be started: no cloud for this pass.
        unset -nocomplain ::reviewcloud::pending($handle)
        set ::reviewcloud::unusable 1
        return 0
    }
    return 1
}

# The reply. `ok` is 0 when the transport failed; a reply that carries no
# evaluation is ok=1 with an error body (Lichess holds nothing for the FEN).
proc ::reviewcloud::arrived {handle ok data {err ""}} {
    variable pending
    if {![info exists pending($handle)]} { return }
    set req $pending($handle)
    unset pending($handle)
    # An `ok` carrying an empty body is not an answer: a real reply is a 200 (an
    # evaluation) or a 404 (an error body saying Lichess holds nothing for the
    # FEN), and ::lichess_eval hands both over with their body. An empty one is
    # the transport failing, and it must not be cached as "nothing stored" -
    # that would make an offline pass re-ask for every position.
    if {$ok && [string trim $data] eq ""} { set ok 0 }
    set entry ""
    if {$ok} {
        set entry [::reviewcloud::parse $data [dict get $req fen]]
    } else {
        # No curl, no network, a timeout: the whole pass stops asking rather
        # than paying the same wait at every position.
        set ::reviewcloud::unusable 1
    }
    set k [::reviewcloud::cacheKey [dict get $req fen] [dict get $req mpv]]
    if {$ok} {
        if {$entry eq ""} {
            set ::reviewcloud::cache($k) none
        } else {
            set ::reviewcloud::cache($k) $entry
        }
    }
    if {$entry ne ""} { set ::reviewcloud::entries($handle) $entry }
    set arrive [dict get $req arrive]
    if {$arrive ne ""} { catch { {*}$arrive $handle $entry } }
    return
}

# The evaluation held for this handle, if one landed, and forget the handle.
proc ::reviewcloud::take {handle} {
    variable entries
    if {![info exists entries($handle)]} { return "" }
    set entry $entries($handle)
    unset entries($handle)
    return $entry
}

# Forget a handle without taking its evaluation: a pass that was cancelled.
proc ::reviewcloud::drop {handle} {
    variable entries
    variable pending
    unset -nocomplain entries($handle)
    unset -nocomplain pending($handle)
    return
}
