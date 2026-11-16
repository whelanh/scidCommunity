# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_cloud.tcl -- the cloud pre-pass behind a review, and which provider's
# reply it keeps.
#
# The review pass used to search every position locally. Two providers keep a
# stored evaluation of a great many positions, each answered by one cheap GET
# per question:
#
#   lichess   GET /api/cloud-eval - a depth and a list of lines, or a 404 when it
#             holds nothing for the FEN. ::lichess_eval is the transport.
#   chessdb   GET cdb.php?action=querypv - the position's stored line, with its
#             score, depth and principal line in ONE response. Its other
#             endpoints state no depth and are never asked: `queryscore` answers
#             `eval:<cp>` alone, and `queryall`'s per-move `note` is undocumented
#             and does not match querypv's depth, so ChessDB supplies one
#             depth-bearing line per position and never a candidate list.
#             ::cdbeval is the transport.
#
# This module owns only the decision. It does not search, does not touch the
# board and does not write: the driver hands it a position spec and its limits
# and gets back what to do with the position.
#
#   D = the effective depth bound (::review::passLimits), 0 = none
#   T = the effective time bound in ms, 0 = none
#   C = the adopted provider evaluation's depth
#   L = the local engine's achieved depth
#
#   T = 0  a provider reply at C >= D  -> adopt it and skip the local search.
#          every reply under D          -> search locally (no caching, no waiting).
#   T > 0  the local depth is unknowable until the search ends, so the providers
#          are queried beside the search and the deeper evaluation wins when the
#          search finishes; a tie goes to the local engine, which is the engine
#          the user configured. This holds even when D > C, because the time cap
#          can cut L below both.
#
# The two rules that are easy to confuse, and are kept as two procs for that
# reason: ::reviewcloud::reaches (C >= D) is the depth-only rule, where the local
# search never runs and D is the depth the user asked for; ::reviewcloud::deeper
# (C > D) is the rule for stopping a search under a time cap. With a time cap a
# reply AT the bound does not stop the search - the search can still reach the
# bound and the tie is the local engine's - so only a reply PAST the bound
# settles the position early.
#
#   Between the providers the deeper reply wins, and a tie goes to the FIRST one
#   in ::reviewcloud::providers - Lichess, which is what this pass used before
#   ChessDB existed. The list is the tie-break, so a provider added later cannot
#   silently outrank it.
#
# Both transports are asynchronous and never block the Tk event loop, and a
# reply that has not landed when the local search completes is not waited for -
# the local result is adopted and the run is not extended. In a depth-only pass
# a reply that reaches the depth bound settles the position without waiting for
# the other provider: nothing the other one can say is deeper than what the user
# asked for.
#
# A transport failure ends that provider's part in the PASS that saw it, not the
# session: ::reviewcloud::newPass clears every provider's latch when the driver
# starts a cloud-enabled pass, and the cache is kept across passes. One rate
# limit, one timeout or one offline start must not disable the pre-pass for
# every later review while the setting still shows it on.
#
# The cache key is the evaluation-relevant FEN: placement, side to move,
# castling rights and en-passant square. The halfmove and fullmove counters do
# not change an evaluation, so they are dropped; two positions that differ only
# in those counters share one cache entry.

namespace eval ::reviewcloud {
    # The providers, in tie-break order: a tie between two replies goes to the
    # first one named here.
    variable providers {lichess chessdb}
    # provider,key|mpv -> the parsed evaluation, or the string "none" for a FEN
    # the provider holds nothing for. Keyed by mpv as well, because a reply
    # carrying fewer lines than the verdict needs cannot be used at all.
    variable cache
    # handle -> {fen mpv arrive mode reach awaiting} for a request in flight.
    variable pending
    # handle -> provider -> the parsed evaluation, waiting for the driver.
    variable entries
    # provider -> set when that transport failed (no curl, no network). One
    # failure is that provider's answer for the pass that saw it: a review of
    # eighty positions must not spend three seconds per position discovering the
    # same thing. ::reviewcloud::newPass clears every latch at the start of the
    # next cloud-enabled pass (the cache is kept).
    variable unusable
    array set cache {}
    array set pending {}
    array set entries {}
    array set unusable {lichess 0 chessdb 0}
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
    array unset unusable
    array set cache {}
    array set pending {}
    array set entries {}
    array set unusable {lichess 0 chessdb 0}
    # ::cdbeval's own latch is NOT cleared here: it belongs to that client, and
    # the pass-level clear is ::reviewcloud::newPass's job. A harness that wants
    # a clean client calls ::cdbeval::reset itself.
    return
}

# A pass is starting.
#
# A failure ends a provider's part in the pass that saw it, not the session: a
# rate limit at one position, one timeout, or a network that was down when the
# run began must not disable the pre-pass for every later review while the
# setting still shows it on. Every provider's latch is cleared, including the
# one ::cdbeval keeps inside its own client, and the cache is kept - it is keyed
# by the position, and a stored evaluation does not go stale.
#
# The caller is ::reviewdriver::start, and only when it is starting a pass with
# the pre-pass on: a pass with it off neither clears the flags nor sets them.
proc ::reviewcloud::newPass {} {
    variable unusable
    foreach provider [array names unusable] {
        set unusable($provider) 0
    }
    if {[llength [info commands ::cdbeval::newPass]]} {
        catch { ::cdbeval::newPass }
    }
    return
}

proc ::reviewcloud::providers {} {
    variable providers
    return $providers
}

# One review setting, defaulting to `default` when the review module is not in
# the tree (a harness that drives the driver without it) - so a setting never
# decides whether this module can be loaded.
proc ::reviewcloud::setting {key {default 1}} {
    if {[llength [info commands ::review::get]] == 0} { return $default }
    if {[catch { set value [::review::get $key] }]} { return $default }
    return [expr {$value ? 1 : 0}]
}

# Whether this pass may ask one provider at all.
#
# `cloud_eval` is the master switch: it turns the whole pre-pass off, both
# providers with it. `chessdb_eval` turns off the second provider alone.
proc ::reviewcloud::providerEnabled {provider} {
    variable unusable
    if {[info exists unusable($provider)] && $unusable($provider)} { return 0 }
    if {![::reviewcloud::setting cloud_eval]} { return 0 }
    switch -- $provider {
        lichess {
            if {[llength [info commands ::lichess_eval::cloudEvalAsync]] == 0} {
                return 0
            }
            return 1
        }
        chessdb {
            if {[llength [info commands ::cdbeval::evaluateAsync]] == 0} {
                return 0
            }
            if {[llength [info commands ::cdbeval::enabled]] &&
                ![::cdbeval::enabled]} {
                return 0
            }
            return [::reviewcloud::setting chessdb_eval]
        }
    }
    return 0
}

# The providers this pass may ask, in tie-break order.
proc ::reviewcloud::askable {} {
    set out {}
    foreach provider [::reviewcloud::providers] {
        if {[::reviewcloud::providerEnabled $provider]} { lappend out $provider }
    }
    return $out
}

# Whether this pass may ask any provider at all.
proc ::reviewcloud::enabled {} {
    return [expr {[llength [::reviewcloud::askable]] > 0}]
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
# is a position the providers are not asked about, and the pass searches it
# locally.
proc ::reviewcloud::fenForSpec {spec} {
    if {[llength [info commands ::chessboard::makeMove]] == 0} { return "" }
    set words [split [string trim $spec] " "]
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

# The Lichess reply as an entry, or "" when it carries nothing this pass can
# use.
#
#   depth  the depth of the evaluation (one depth for every line)
#   stm    the side to move at the queried position
#   pvs    {{moves cp mate} ...} in the reply's order, best first
#   provider  lichess
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
    return [dict create depth $depth stm $stm pvs $pvs provider lichess]
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
    if {![dict exists $entry pvs]} { return "" }
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

# Which provider an adopted evaluation came from, in the run's own vocabulary.
proc ::reviewcloud::sourceOf {entry} {
    if {$entry eq ""} { return local }
    set provider ""
    catch { set provider [dict get $entry provider] }
    switch -- $provider {
        lichess { return cloud-lichess }
        chessdb { return cloud-chessdb }
    }
    return cloud
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

# Whether a reply is at least as deep as the depth bound - the depth-only rule
# (T = 0), where the local search never runs at all.
#
# This is the whole comparison for that case: C >= D is the depth the user asked
# for, and the reply is at least that deep. It is NOT the rule for stopping a
# search under a time cap - see ::reviewcloud::deeper.
proc ::reviewcloud::reaches {D C} {
    return [expr {$D > 0 && $C >= $D}]
}

# Whether a reply is strictly deeper than the depth bound - the rule for stopping
# a search under a time cap.
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

# The score of one of the driver's lines, in the mover's convention - the figure
# ::reviewdriver::lineScore gives it, kept here so the adoption decision does not
# need the driver module.
proc ::reviewcloud::lineCp {line} {
    lassign $line depth score type pv
    if {$type eq "mate"} {
        if {[llength [info commands ::movelabels::mateToCp]] == 0} { return "" }
        return [::movelabels::mateToCp $score]
    }
    if {$score eq "" || ![string is integer -strict $score]} { return "" }
    return $score
}

# The reply held for this handle that states a depth, and the best one that also
# carries the alternatives a verdict needs: {entry bearer}.
#
# The deeper reply wins, and the first provider in ::reviewcloud::providers wins a
# tie. A reply without a line (no depth, no pv) is not an evaluation and does not
# enter either comparison.
proc ::reviewcloud::bestOf {handle mpv} {
    variable entries
    if {![info exists entries($handle)]} { return {"" ""} }
    set entry ""
    set bearer ""
    foreach provider [::reviewcloud::providers] {
        if {![dict exists $entries($handle) $provider]} { continue }
        set candidate [dict get $entries($handle) $provider]
        if {[::reviewcloud::lines $candidate 1] eq ""} { continue }
        # A reply that could carry the alternatives and did not is no reply for
        # this verdict; a provider that never carries them (ChessDB's one
        # depth-bearing line) competes on its score alone.
        set single 0
        catch { set single [dict get $candidate single] }
        set count [llength [dict get $candidate pvs]]
        if {!$single && [string is integer -strict $mpv] && $count < $mpv} {
            continue
        }
        if {$entry eq "" ||
            [::reviewcloud::depth $candidate] > [::reviewcloud::depth $entry]} {
            set entry $candidate
        }
        if {!$single && [string is integer -strict $mpv] && $mpv > 0 &&
            $count >= $mpv} {
            if {$bearer eq "" ||
                [::reviewcloud::depth $candidate] > [::reviewcloud::depth $bearer]} {
                set bearer $candidate
            }
        }
    }
    return [list $entry $bearer]
}

# The lines a reply may be adopted with: all `mpv` of them when it carries that
# many, otherwise the one line a one-line reply has.
#
# A one-line reply - ChessDB's by construction, and a cached one on a warm pass -
# is adopted AS that one line: it is a complete evaluation of the position, not a
# short candidate list, and the labels it may carry are the ones
# ::reviewcloud::choose allows a one-line reply to decide.
#
# A reply that carries alternatives and fewer than `mpv` of them is a different
# answer rather than a shortcut, so it is not adopted at all: reading it as one
# line would let a one-line ladder stand in for the alternatives a `great` or
# `brilliant` verdict is decided against.
proc ::reviewcloud::adoptable {entry mpv} {
    set lines [::reviewcloud::lines $entry $mpv]
    if {$lines ne ""} { return $lines }
    set single 0
    catch { set single [dict get $entry single] }
    if {!$single} { return "" }
    return [::reviewcloud::lines $entry 1]
}

# Which reply this position may be decided by: {entry bearer}.
#
# A stored evaluation is used only where the verdict it feeds cannot need the
# alternatives the reply does not carry. ChessDB answers with one depth-bearing
# line and no candidate list (its other endpoints state no depth and are never
# asked), so its deeper reply is adopted for the ordinary labels, the [%eval] and
# the ESL. The two labels that read alternatives are treated differently, and
# the difference is the whole of this proc:
#
#   * where a CANDIDATE-BEARING reply exists - Lichess's usable reply, else the
#     local search's own lines - the guard decides. If the drop would qualify for
#     `great` (the gap to the second line) or `brilliant` (a sacrifice), the
#     position is handed back to that reply, whose alternatives decide the label,
#     and `sources` names it. Otherwise the one-line reply is adopted anyway.
#   * where NEITHER exists (no bearer, no local lines) the one line decides the
#     SCORE only. There is no second line, so `great` - the gap to a second line -
#     is not available on that ply and is not awarded; `brilliant` still is,
#     because its sacrifice test reads the line's own best move, which the reply
#     carries. This is deliberate, not a silent skip: falling back to a local
#     search here would throw the deeper stored evaluation away in exactly the
#     case the second provider exists for (Lichess holds nothing, the pass has no
#     time cap so it never searches), and would report a verdict the one line can
#     support anyway.
#
# `fen` is the position being decided, `local` the search's own lines when there
# are any - the guard needs both for brilliant's sacrifice test and for the
# alternatives the search may be the only source of.
proc ::reviewcloud::choose {handle mpv fen {local {}}} {
    lassign [::reviewcloud::bestOf $handle $mpv] entry bearer
    if {$entry eq ""} { return {"" ""} }
    set single 0
    catch { set single [dict get $entry single] }
    if {!$single} { return [list $entry $bearer] }
    # The reply chosen for this position is one line. Find who has the
    # alternatives: the candidate-bearing reply first, else the local search's
    # lines while it runs.
    set lines [::reviewcloud::lines $bearer $mpv]
    if {$lines eq "" && [llength $local]} { set lines $local }
    if {$lines eq ""} {
        # Nothing carries the alternatives: no usable Lichess reply and no local
        # lines to fall back on. The one line decides the score, and the labels a
        # one-line ladder cannot reach are not awarded on this ply - `great` needs
        # the gap to a second line, which this reply does not have. `brilliant` is
        # still decided, from the reply's own best move. The adoption is the
        # decision: no local-search fallback here (see this proc's comment).
        return [list $entry $bearer]
    }
    # There is a candidate-bearing reply, so the guard decides.
    set scores {}
    set bestMove ""
    foreach index [lsort -integer [dict keys $lines]] {
        set cp [::reviewcloud::lineCp [dict get $lines $index]]
        if {$cp eq ""} { continue }
        lappend scores $cp
    }
    set bestMove [lindex [lindex [dict get $lines 1] 3] 0]
    if {[llength $scores] >= 2 &&
        [llength [info commands ::movelabels::needsAlternatives]] &&
        [::movelabels::needsAlternatives $scores $fen $bestMove]} {
        # A `great`- or `brilliant`-capable position: the reply that carries the
        # alternatives decides it.
        return [list $bearer $bearer]
    }
    return [list $entry $bearer]
}

# Forget a handle: the replies it still expects and the evaluations it holds.
proc ::reviewcloud::drop {handle} {
    variable entries
    variable pending
    unset -nocomplain entries($handle)
    unset -nocomplain pending($handle)
    return
}

# The reply this position may be decided by, if one landed, and forget the
# handle - including a reply still in flight, which is no longer this position's
# answer. Answers {entry bearer}.
# `mpv` is the lines a verdict needs, not what a lookup asks for: Lichess answers
# one request with its alternatives, and ChessDB answers with the evaluation and
# no alternatives at all.
proc ::reviewcloud::best {handle mpv fen {local {}}} {
    set chosen [::reviewcloud::choose $handle $mpv $fen $local]
    ::reviewcloud::drop $handle
    return $chosen
}

# Hold an evaluation for the comparison at the end of the position's search.
proc ::reviewcloud::hold {handle provider entry} {
    if {$entry eq "" || $entry eq "none"} { return }
    dict set ::reviewcloud::entries($handle) $provider $entry
    return
}

# What to do with one position.
#
#   handle  a name the caller owns, used to match the reply to the position
#   spec    the engine's own `position ...` spec for the position
#   limits  {depth N movetime M} - ::review::passLimits' answer
#   mpv     the lines the verdict needs
#   variant "standard" or the game's variant (the providers are only asked for
#           standard chess: the FEN this module replays is a standard one)
#   arrive  called as {*}$arrive <handle> <entry> when the position's replies are
#           in, so a depth-only pass can continue and a timed one can stop early
#
# Answers {action ... lines ... depth ... source ...}:
#   cloud  adopt these lines; the local search is not run (or is cancelled)
#   wait   a query is in flight and the answer decides: do not search yet
#   query  a query is in flight beside the local search; search now
#   local  search locally, with nothing from the providers
proc ::reviewcloud::begin {handle spec limits mpv variant arrive} {
    set local [dict create action local lines {} depth 0 source local]
    set active [::reviewcloud::askable]
    if {![llength $active]} { return $local }
    if {$variant ne "standard"} { return $local }
    set D 0
    set T 0
    catch { set D [dict get $limits depth] }
    catch { set T [dict get $limits movetime] }
    if {![string is integer -strict $D]} { set D 0 }
    if {![string is integer -strict $T]} { set T 0 }
    # With neither bound there is no question to answer: a pass with no depth
    # and no time has nothing for a provider to be deeper than.
    if {$D <= 0 && $T <= 0} { return $local }
    set fen [::reviewcloud::fenForSpec $spec]
    if {$fen eq ""} { return $local }
    set k [::reviewcloud::cacheKey $fen $mpv]
    set known {}
    set ask {}
    foreach provider $active {
        if {[info exists ::reviewcloud::cache($provider,$k)]} {
            dict set known $provider $::reviewcloud::cache($provider,$k)
        } else {
            lappend ask $provider
        }
    }
    # Whatever is already known is held for the comparison, so a cached reply
    # and a fresh one are weighed the same way.
    dict for {provider entry} $known {
        ::reviewcloud::hold $handle $provider $entry
    }
    set best [lindex [::reviewcloud::choose $handle $mpv $fen] 0]
    if {$T <= 0} {
        if {$best ne "" && [::reviewcloud::reaches $D [::reviewcloud::depth $best]]} {
            ::reviewcloud::drop $handle
            return [dict create action cloud \
                lines [::reviewcloud::adoptable $best $mpv] \
                depth [::reviewcloud::depth $best] \
                source [::reviewcloud::sourceOf $best]]
        }
        if {[llength $ask]} {
            # A depth-only pass has nothing else to do while the lookups run.
            if {![::reviewcloud::query $handle $fen $variant $mpv $arrive wait $D $ask]} {
                # Not one transport would start: nothing is in flight, nothing
                # will arrive, and the position is searched like any other.
                return $local
            }
            return [dict create action wait lines {} depth 0 source ""]
        }
        ::reviewcloud::drop $handle
        return $local
    }
    # A time cap is in force, so the local search runs either way - unless a
    # reply is already deeper than the depth bound, in which case the search
    # cannot reach past it and the comparison at completion would choose the
    # reply anyway. A reply AT the bound is not that case: the search can still
    # reach it, and the tie goes to the local engine, so it is held instead.
    if {$best ne "" && [::reviewcloud::deeper $D [::reviewcloud::depth $best]]} {
        ::reviewcloud::drop $handle
        return [dict create action cloud \
            lines [::reviewcloud::adoptable $best $mpv] \
            depth [::reviewcloud::depth $best] \
            source [::reviewcloud::sourceOf $best]]
    }
    if {[llength $ask]} {
        if {![::reviewcloud::query $handle $fen $variant $mpv $arrive query $D $ask]} {
            # None of the transports would start: search locally, with whatever
            # the cache already held for the comparison at the end.
            return $local
        }
        return [dict create action query lines {} depth 0 source ""]
    }
    # Held for the comparison when the local search finishes; the handle lives
    # until ::reviewdriver::settle takes it.
    return $local
}

# Ask the providers, asynchronously. Never waits for an answer: the replies
# arrive through the event loop and call ::reviewcloud::reply.
#
# Answers 1 when at least one transport started, 0 when none did. A transport
# that failed to start is NOT reported through `arrive` here: a callback made
# from inside this call would reach the driver before ::reviewcloud::begin had
# returned, and a depth-only pass has nothing to settle until begin's answer has
# told the driver it is waiting - the reply would be dropped and the pass would
# hang with nothing to move it on. A provider whose transport did not start is
# latched off and left out of `awaiting`, so no reply is ever waited for that
# cannot come; the caller tests the return value for the case where none
# started.
#
# `mode` is "wait" (a depth-only pass: the answer decides whether this position
# is searched at all) or "query" (a timed pass: the search runs beside it).
proc ::reviewcloud::query {handle fen variant mpv arrive mode reach ask} {
    variable pending
    set pending($handle) [dict create fen $fen mpv $mpv arrive $arrive \
        mode $mode reach $reach awaiting {}]
    foreach provider $ask {
        if {[::reviewcloud::ask $handle $provider $fen $variant $mpv]} {
            dict lappend pending($handle) awaiting $provider
        }
    }
    if {![llength [dict get $pending($handle) awaiting]]} {
        unset -nocomplain pending($handle)
        return 0
    }
    return 1
}

# One provider's request for one position. Answers whether its transport
# started; a transport that could not start latches that provider off for the
# pass and starts no callback.
proc ::reviewcloud::ask {handle provider fen variant mpv} {
    variable unusable
    if {$provider eq "chessdb"} {
        set id ""
        if {[catch {
            set id [::cdbeval::evaluateAsync $fen $mpv \
                [list ::reviewcloud::cdbArrived $handle]]
        }]} {
            set unusable(chessdb) 1
            return 0
        }
        return [expr {$id ne ""}]
    }
    if {[catch {
        ::lichess_eval::cloudEvalAsync $fen $variant $mpv \
            [list ::reviewcloud::arrived $handle $provider]
    }]} {
        set unusable($provider) 1
        return 0
    }
    return 1
}

# The position a handle was asked about - the side to move decides how a reply's
# score is turned to the mover's.
proc ::reviewcloud::fenOf {handle} {
    variable pending
    if {![info exists pending($handle)]} { return "" }
    return [dict get $pending($handle) fen]
}

# The Lichess reply. `ok` is 0 when the transport failed; a reply that carries no
# evaluation is ok=1 with an error body (Lichess holds nothing for the FEN).
proc ::reviewcloud::arrived {handle provider ok data {err ""}} {
    if {![info exists ::reviewcloud::pending($handle)]} { return }
    # An `ok` carrying an empty body is not an answer: a real reply is a 200 (an
    # evaluation) or a 404 (an error body saying Lichess holds nothing for the
    # FEN), and ::lichess_eval hands both over with their body. An empty one is
    # the transport failing, and it must not be cached as "nothing stored" -
    # that would make an offline pass re-ask for every position.
    if {$ok && [string trim $data] eq ""} { set ok 0 }
    if {!$ok} {
        ::reviewcloud::reply $handle $provider failed ""
        return
    }
    set entry [::reviewcloud::parse $data [::reviewcloud::fenOf $handle]]
    if {$entry eq ""} {
        ::reviewcloud::reply $handle $provider none ""
    } else {
        ::reviewcloud::reply $handle $provider entry $entry
    }
    return
}

# The ChessDB reply: ::cdbeval has already parsed the one stored read - score,
# depth and pv from the same response - so this proc only records it.
proc ::reviewcloud::cdbArrived {handle ok entry {err ""}} {
    if {!$ok} {
        ::reviewcloud::reply $handle chessdb failed ""
        return
    }
    if {$entry eq ""} {
        ::reviewcloud::reply $handle chessdb none ""
        return
    }
    ::reviewcloud::reply $handle chessdb entry $entry
    return
}

# One provider's answer for one position.
#
# The reply is recorded first, then the question is whether this position can be
# answered yet: a depth-only pass waits for a reply at the depth bound, a timed
# one is done when every provider has spoken, and either way an answer that has
# already settled the position is not amended by one that has not landed.
proc ::reviewcloud::reply {handle provider state entry} {
    variable pending
    variable unusable
    if {![info exists pending($handle)]} { return }
    set req $pending($handle)
    if {$state eq "failed"} {
        set unusable($provider) 1
    } else {
        set k [::reviewcloud::cacheKey [dict get $req fen] [dict get $req mpv]]
        if {$state eq "entry"} {
            set ::reviewcloud::cache($provider,$k) $entry
            ::reviewcloud::hold $handle $provider $entry
        } else {
            set ::reviewcloud::cache($provider,$k) none
        }
    }
    set awaiting [lsearch -all -inline -not -exact [dict get $req awaiting] $provider]
    dict set pending($handle) awaiting $awaiting
    set arrive [dict get $req arrive]
    if {[dict get $req mode] eq "query"} {
        # A timed pass: the search is already running. Only a reply that could
        # decide the verdict on its own may stop it - one carrying the
        # alternatives - and only when it is strictly deeper than the depth
        # bound. A one-line reply can be held back for want of the alternatives,
        # and a search cut short cannot supply them, so it is left to finish and
        # weighed against what it reached. The reply stays held for the settle
        # comparison, so a deeper one from the other provider still wins if it
        # lands in time.
        if {$state eq "entry" && $arrive ne "" &&
            [::reviewcloud::usable $entry [dict get $req mpv]] ne "" &&
            [::reviewcloud::deeper [dict get $req reach] \
                [::reviewcloud::depth $entry]]} {
            catch { {*}$arrive $handle $entry }
        }
        return
    }
    # A depth-only pass: a reply at the depth bound settles the position without
    # waiting for a provider that has not answered - nothing it can say is
    # deeper than the depth the user asked for. The driver decides which of the
    # replies it may use (::reviewcloud::best), so nothing is taken here.
    lassign [::reviewcloud::choose $handle [dict get $req mpv] \
        [dict get $req fen]] best bearer
    if {$best ne "" &&
        [::reviewcloud::reaches [dict get $req reach] [::reviewcloud::depth $best]]} {
        if {$arrive ne ""} { catch { {*}$arrive $handle "" } }
        return
    }
    if {[llength $awaiting]} { return }
    if {$arrive ne ""} { catch { {*}$arrive $handle "" } }
    return
}
