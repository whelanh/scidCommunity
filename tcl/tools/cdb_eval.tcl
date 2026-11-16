# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# cdb_eval.tcl -- the ChessDB (chessdb.cn) stored-evaluation client.
#
# ChessDB holds a deep stored evaluation of most positions - deeper than Lichess
# for a great many of them - and answers one with a plain HTTP GET, no key:
#
#   action=querypv   {"status":"ok","score":-1,"depth":50,"pv":[...],"pvSAN":[...]}
#                    score is CENTIPAWNS FROM WHITE'S POINT OF VIEW and depth is
#                    the primary line's.
#
# ONE endpoint, because a stored evaluation is used only when it STATES A
# POSITIVE DEPTH:
#
#   querypv     score, depth and pv in one response  -> this one, and only this
#   queryscore  `eval:<cp>` and NO depth             -> never asked
#   queryall    per-move score/rank/note and NO depth -> never asked; the
#               `(29-15)` inside `note` is undocumented and does not match
#               querypv's depth for the same FEN, so it is not a depth either
#   queue/store the actions that REQUEST analysis         -> never asked
#
# querypv is a stored read - "Query Analysis Lines", the database's own line for
# the position - so every request carries `learn=0`: the default 1 would also
# feed the server's learning from a review, and the reply shape is identical.
#
# querypv ignores `multipv`/`depth` parameters (measured: one FEN answered depth
# 34, 37 and 38 with `&multipv=3`, `&depth=40` and neither), so ChessDB can
# supply ONE depth-bearing line per position, never a candidate list. A caller
# that needs alternatives for a verdict reads ::review::mpv from another source;
# see ::reviewcloud's adoption rule.
#
# An unvisited position answers {"status":"ok","score":0,"depth":0,"pv":[...]}:
# status ok, a score, a line, and no depth worth anything. It is the "quality
# unknown" case and must not be read as an answer, so a reply is eligible only
# with depth > 0 - independently of any depth bound the pass was given, because a
# pass with no bound (D = 0) would otherwise accept C = 0.
#
# Score, depth and pv are taken from the SAME response and never mixed with a
# second call: two calls for one position can report different depths.
#
# The transport is asynchronous in the same shape as
# ::lichess_eval::cloudEvalAsync: a curl child, a non-blocking pipe, a
# per-channel buffer, and a callback that cannot fire before the call returns.
# A cdb call measured 1.3-2.2 s on the development host, an order slower than
# Lichess, so the child is capped at 3 s.
#
# Status is the PROVIDER's answer, not the transport's. `ok` is an evaluation;
# `invalid board`, `unknown`, `checkmate` and `stalemate` mean ChessDB holds
# nothing for this position (a fact about the position, cached as one); any
# other status, or no reply at all, is a transport failure. One transport
# failure stops this provider asking for the rest of that PASS - a review of
# eighty positions must not pay the same three-second wait at every one - and
# ::cdbeval::newPass clears it when the next cloud-enabled pass starts. A
# transient `Failed to connect ... after 121 ms` is that kind of failure: an
# empty body must never read as "ChessDB holds nothing here".
#
# Decisive positions report a large number (~24988 for K+Q vs K), not material
# centipawns, and there is no mate distance to convert: ::accuracy::winPercent
# saturates well before it. Nothing here invents one. Such a reply measured a
# NEGATIVE depth, which the eligibility rule above refuses - the local search
# finds the mate it is looking at anyway.

namespace eval ::cdbeval {
    variable apiUrl "https://www.chessdb.cn/cdb.php"
    # Measured 1.3-2.2 s per call on the development host; 3 s is the ceiling
    # that keeps a dead or slow endpoint from stalling a depth-only pass.
    variable maxTime 3
    # key|mpv -> the parsed evaluation, or "none" for a position ChessDB holds
    # nothing for. The reply never carries alternatives, so mpv is part of the
    # key only to keep the two callers' answers apart; the entry itself is the
    # one line.
    variable cache
    # request id -> {fen key callback body}.
    variable pending
    # channel -> the bytes read so far (one buffer per child, so two positions'
    # replies cannot interleave).
    variable buffers
    # channel -> {callback} while the child is running.
    variable fdreq
    variable seq 0
    # Set when the transport itself failed. One failure is that provider's answer
    # for the pass that saw it: the review stops asking this provider until
    # ::cdbeval::newPass clears it at the start of the next cloud-enabled pass.
    variable unusable 0
    array set cache {}
    array set pending {}
    array set buffers {}
    array set fdreq {}
}

# Forget every cached evaluation and every request in flight. Tests call it; a
# session does not need it, because a cached evaluation is keyed by the position
# it describes.
proc ::cdbeval::reset {} {
    variable cache
    variable pending
    variable buffers
    variable fdreq
    variable unusable
    # `array set x {}` sets nothing and clears nothing; only `array unset` does.
    array unset cache
    array unset pending
    array unset buffers
    array unset fdreq
    array set cache {}
    array set pending {}
    array set buffers {}
    array set fdreq {}
    set unusable 0
    return
}

# Whether this provider may be asked at all this pass.
proc ::cdbeval::enabled {} {
    variable unusable
    return [expr {!$unusable}]
}

# A pass is starting.
#
# A transport failure ends ChessDB's part in the pass that saw it, not the
# session: one timeout or one network that was down when the run began must not
# disable the second provider for every later review while the setting still
# shows it on. ::reviewcloud::newPass calls this when ::reviewdriver::start
# begins a cloud-enabled pass. The cache is kept - it is keyed by the position,
# and a stored evaluation does not go stale.
proc ::cdbeval::newPass {} {
    variable unusable
    set unusable 0
    return
}

# The evaluation-relevant FEN: placement, side to move, castling rights and
# en-passant square. The halfmove and fullmove counters cannot change an
# evaluation, so they are dropped and two positions that differ only in them
# share one cache entry - the same key ::reviewcloud uses for Lichess.
proc ::cdbeval::key {fen} {
    return [join [lrange [split [string trim $fen]] 0 3] " "]
}

# The app names itself, as it does for every other endpoint it calls.
proc ::cdbeval::userAgent {} {
    if {[info exists ::scidVersion] && $::scidVersion ne ""} {
        return "scidCommunity/$::scidVersion"
    }
    return "scidCommunity"
}

proc ::cdbeval::url {action fen} {
    set urlFen [string map {" " "%20" "/" "%2F" "+" "%2B" "?" "%3F" \
        "&" "%26" "=" "%3D" "#" "%23" "%" "%25"} $fen]
    # `learn=0` because this is a stored read: the database's own analysis line of
    # the position, not a request for analysis (`queue` and `store` are the
    # actions that ask for one, and this client asks for neither). Its default is
    # 1, which would also feed the server's learning from a review.
    return "$::cdbeval::apiUrl?action=$action&board=$urlFen&json=1&learn=0"
}

# The curl child's argv. --max-time is the whole point: a cdb call is an order
# slower than Lichess, and a depth-only pass must not stall on it.
proc ::cdbeval::command {url} {
    return [list curl -s --max-time $::cdbeval::maxTime \
        -A [::cdbeval::userAgent] -w {|HTTP%{http_code}} $url]
}

# Ask one question, asynchronously. Calls `callback` as
# {*}$callback <ok> <body> <err> from the event loop: ok 1 with the reply body,
# or ok 0 with the reason. Returns the channel, or "" when the transport could
# not start (the callback still fires, from `after idle`).
#
# curl's --write-out appends the HTTP status, and only 200 is a reply: a refused
# connection, an unresolvable host and a timeout all leave an empty body and
# status 000, which must not read as "ChessDB holds nothing here".
proc ::cdbeval::transport {url callback} {
    variable buffers
    variable fdreq
    set cmd [::cdbeval::command $url]
    if {[catch { set fd [open [list | {*}$cmd] r] } err]} {
        # curl is not on PATH. The same fallback ::lichess_eval::cloudEvalAsync
        # takes: ::http::geturl with -command returns at once and answers from
        # the event loop, so the caller is still not blocked, and the reply goes
        # through onHttp onto the same <ok> <body> <err> contract onData
        # reports - the reply body and its status, never a silent empty answer.
        if {[catch { package require http }]} { error $err }
        catch { package require tls }
        catch { ::http::register https 443 ::tls::socket }
        if {[catch {
            ::http::geturl $url -timeout [expr {$::cdbeval::maxTime * 1000}] \
                -command [list ::cdbeval::onHttp $callback]
        }]} {
            error $err
        }
        return ""
    }
    fconfigure $fd -blocking 0 -buffering full
    set buffers($fd) ""
    set fdreq($fd) [list $callback]
    fileevent $fd readable [list ::cdbeval::onData $fd]
    return $fd
}

# Internal: the http package's callback for an async request, the twin of
# ::cdbeval::onData for the fallback taken when curl is absent.
#
# ::http::ncode is the status the reply carried: 200 is the stored line this
# client asked for. Anything else - including the 0 a transport error leaves
# behind - is ok=0 with the reason, because only a reply that arrived can be
# read as "ChessDB holds nothing here". Never throws: the caller is an
# event-loop callback.
proc ::cdbeval::onHttp {callback token} {
    set code 0
    set data ""
    catch { set code [::http::ncode $token] }
    catch { set data [::http::data $token] }
    catch { ::http::cleanup $token }
    if {![string is integer -strict $code]} { set code 0 }
    if {$code == 200} {
        catch { {*}$callback 1 $data "" }
        return
    }
    if {$code == 0} {
        set reason "the chessdb reply did not arrive (no HTTP status)"
    } else {
        set reason "the chessdb reply did not arrive (HTTP $code)"
    }
    catch { {*}$callback 0 $data $reason }
    return
}

# Internal: accumulates one child's reply and hands it to the caller at EOF.
proc ::cdbeval::onData {fd} {
    variable buffers
    variable fdreq
    if {![info exists fdreq($fd)]} {
        catch { close $fd }
        return
    }
    if {[catch { append buffers($fd) [read $fd] }]} {
        set callback [lindex $fdreq($fd) 0]
        unset fdreq($fd)
        unset buffers($fd)
        catch { close $fd }
        catch { {*}$callback 0 "" "the chessdb reply could not be read" }
        return
    }
    if {![eof $fd]} { return }
    set data $buffers($fd)
    set callback [lindex $fdreq($fd) 0]
    unset fdreq($fd)
    unset buffers($fd)
    catch { close $fd }
    # The status trailer goes before anyone sees the body.
    set code ""
    set marker [string last {|HTTP} $data]
    if {$marker >= 0} {
        set code [string trim [string range $data [expr {$marker + 5}] end]]
        set data [string range $data 0 [expr {$marker - 1}]]
    }
    if {$code ne "200"} {
        if {$code eq ""} {
            set reason "the chessdb reply did not arrive (no HTTP status)"
        } else {
            set reason "the chessdb reply did not arrive (HTTP $code)"
        }
        catch { {*}$callback 0 $data $reason }
        return
    }
    catch { {*}$callback 1 $data "" }
    return
}

# The `status` of one cdb reply, or "" when the body carries none.
proc ::cdbeval::status {body} {
    if {[regexp {"status"\s*:\s*"([^"]*)"} $body -> status]} { return $status }
    return ""
}

# Is this a status the client understands? A status it has never seen is a
# broken reply rather than an empty answer, so it stops the provider asking.
proc ::cdbeval::knownStatus {status} {
    return [expr {[lsearch -exact {ok {invalid board} unknown checkmate stalemate} \
        $status] >= 0}]
}

# The reply as an evaluation in ::reviewcloud's entry shape:
#
#   depth     querypv's depth - the primary line's, from the same response as
#             its score and its pv. A reply that does not state a depth is not
#             an evaluation and this returns "".
#   stm       the side to move at the queried position
#   pvs       ONE line - {{moves cp mate}} - the primary line, mate always empty
#             because cdb reports a decisive position as a large cp number
#   provider  chessdb
#
# `cp` is White-relative, as the API reports it; ::reviewcloud::lines turns it to
# the mover's, which is the convention the pass's own lines use.
#
# "" means the reply carries nothing this pass can use.
proc ::cdbeval::parse {body fen} {
    set stm [lindex [split [string trim $fen]] 1]
    if {$stm ne "w" && $stm ne "b"} { return "" }
    if {![regexp {"depth"\s*:\s*(-?\d+)} $body -> depth]} { return "" }
    # A POSITIVE depth is required before a reply is eligible, independently of
    # the depth bound the pass was given: an unvisited position answers
    # {"status":"ok","score":0,"depth":0,"pv":[...]}, which looks like an answer
    # and is the "quality unknown" case. A resolved position can answer a
    # negative depth, which is a marker rather than a search depth; neither is
    # used, and neither is a transport failure.
    if {$depth <= 0} { return "" }
    if {![regexp {"score"\s*:\s*(-?\d+)} $body -> score]} { return "" }
    set pv {}
    if {[regexp {"pv"\s*:\s*\[([^\]]*)} $body -> text]} {
        foreach {all move} [regexp -all -inline {"([^"]*)"} $text] {
            if {$move ne ""} { lappend pv $move }
        }
    }
    if {![llength $pv]} { return "" }
    return [dict create depth $depth stm $stm \
        pvs [list [list [join $pv " "] $score ""]] provider chessdb single 1]
}

# The reply. `ok` is 0 when the transport failed; a reply that carries no
# evaluation is ok=1 with an entry of "" (ChessDB holds nothing for the FEN).
proc ::cdbeval::arrived {id ok body {err ""}} {
    variable pending
    variable cache
    variable unusable
    if {![info exists pending($id)]} { return }
    set req $pending($id)
    unset pending($id)
    set callback [dict get $req callback]
    if {!$ok} {
        # No curl, no network, a refused connection, a timeout: the session
        # stops asking this provider rather than paying the same wait at every
        # position.
        set unusable 1
        catch { {*}$callback 0 "" $err }
        return
    }
    set status [::cdbeval::status $body]
    if {![::cdbeval::knownStatus $status]} {
        # A reply this client cannot read is not "no evaluation here": it is the
        # endpoint answering something else, and asking again would repeat it.
        set unusable 1
        catch { {*}$callback 0 "" "the chessdb reply carried an unknown status" }
        return
    }
    set entry ""
    if {$status eq "ok"} {
        set entry [::cdbeval::parse $body [dict get $req fen]]
    }
    if {$entry eq ""} {
        set cache([dict get $req key]) none
    } else {
        set cache([dict get $req key]) $entry
    }
    catch { {*}$callback 1 $entry "" }
    return
}

# The async entry point: ask ChessDB for the position's evaluation.
#
#   fen       the position, in full FEN
#   mpv       the lines the verdict needs; ChessDB answers with one, so a caller
#             that needs more reads them elsewhere (::reviewcloud decides)
#   callback  called as {*}$callback <ok> <entry> <err>: ok 1 with the parsed
#             entry, or "" for a position ChessDB holds nothing for; ok 0 when
#             the transport failed.
#
# Never blocks the Tk event loop and never calls back before it returns. A cache
# hit answers from `after idle`, which is the same contract without a child.
#
# Answers the request id when a reply is on its way, and "" when nothing will
# arrive - a transport that could not start at all, or a provider already
# latched off for the pass. A caller that must not wait (::reviewcloud::ask)
# tests the answer rather than a callback: a callback made from inside this call
# would reach the driver before it had been told that anything was in flight.
proc ::cdbeval::evaluateAsync {fen mpv callback} {
    variable cache
    variable pending
    variable unusable
    variable seq
    if {![::cdbeval::enabled]} {
        return ""
    }
    set key "[::cdbeval::key $fen]|$mpv"
    if {[info exists cache($key)]} {
        incr seq
        set id "cdb$seq"
        after idle [list {*}$callback 1 $cache($key) ""]
        return $id
    }
    incr seq
    set id "cdb$seq"
    set pending($id) [dict create fen $fen key $key callback $callback]
    if {[catch {
        ::cdbeval::transport [::cdbeval::url querypv $fen] \
            [list ::cdbeval::arrived $id]
    } err]} {
        # No child and no http package: nothing is in flight, and the pass must
        # search this position rather than wait for a reply that cannot come.
        unset -nocomplain pending($id)
        set unusable 1
        return ""
    }
    return $id
}
