### woodpecker_set.tcl: Woodpecker trainer - building a set.
### SPDX-License-Identifier: GPL-2.0-or-later
###
### A set is a directory under <user dir>/woodpecker/ holding a Scid database
### (set.si5 ...) with one game per exercise, and the files woodpecker_core.tcl
### reads and writes. Three sources: the puzzles shipped with Scid (puzzles/),
### Lichess puzzles (the batch API) and a PGN or Scid database the user already
### has (a book converted to PGN).
###
### Uses sc_* commands and, for Lichess, curl or Tcl's http package. No Tk:
### the GUI passes a progress callback and polls a cancel flag.

namespace eval ::woodpecker::set {
    variable UA "scidCommunity-woodpecker (https://github.com/whelanh/scidCommunity)"
    # Lichess: one request at a time, and wait a minute after a 429.
    variable PAUSE_MS 1000
    variable RETRY_MS 60000
    variable BATCH 50
    # A round of angles that brings nothing new waits WAIT_MS for Lichess to
    # serve the next batch; after MAX_IDLE_ROUNDS such rounds the level stops.
    variable WAIT_MS 20000
    variable MAX_IDLE_ROUNDS 6
    variable cancel 0
    # The difficulty levels the API knows, easiest first.
    variable LEVELS {easiest easier normal harder hardest}
}

################################################################################
# Directories

# The data folder. Options > Resources can point it somewhere else - a folder
# synchronised with a cloud service, typically: the sets then live in its
# "woodpecker" subfolder (or in the folder itself when it is already called
# woodpecker). Empty means Scid's own user folder. A chosen folder that does
# not exist (a cloud drive not mounted) is an error, never a silent switch to
# the default folder: the records would split in two.
if {![info exists ::woodpecker::dataDir]} { set ::woodpecker::dataDir "" }
if {![info exists ::woodpecker::usedDir]} { set ::woodpecker::usedDir "" }

proc ::woodpecker::set::localDir {} {
    set base [expr {[info exists ::scidUserDir] ? $::scidUserDir : [file join $::env(HOME) .scidCommunity]}]
    set dir [file join $base woodpecker]
    file mkdir $dir
    return $dir
}

proc ::woodpecker::set::dataRoot {} {
    set custom [string trim $::woodpecker::dataDir]
    if {$custom eq ""} { return [localDir] }
    if {![file isdirectory $custom]} { error "the Woodpecker data folder does not exist: $custom" }
    if {[file tail $custom] eq "woodpecker"} { return $custom }
    return [file join $custom woodpecker]
}

proc ::woodpecker::set::rootDir {} {
    set dir [dataRoot]
    file mkdir $dir
    set readme [file join $dir README.txt]
    if {![file exists $readme]} { catch { ::woodpecker::writeAtomic $readme [readmeText] } }
    return $dir
}

# What the folder holds, for whoever opens it: nothing here is to be deleted by
# hand unless the whole set is meant to go (the Delete button does that).
proc ::woodpecker::set::readmeText {} {
    return {scidCommunity - Woodpecker Method training data
================================================

One folder per training set, named <creation date>-<set name>. Delete a set
from Play > Woodpecker Method > Delete, not by hand.

In each set folder:
  set.si5 set.sg5 set.sn5   the exercises, a Scid database (one game each:
                            the position to solve and its solution)
  exercises.tsv             the same exercises, read by a session so it never
                            opens the database (kept in step with the database)
  marks.tsv                 the ! and !! of every evaluation, versioned
  log.tsv                   every exercise played and every session: the
                            statistics are computed from this file
  set.tsv                   the set's name, source and schedule

Open the database from the sets page (Open Puzzle Database) to study the
positions, run an engine, or correct the set: delete a game to remove an
exercise, add a game (a set-up position and its main line) to add one. The next
Train rebuilds exercises.tsv. The exercises that stay keep their number, so
they keep their marks and history; a deleted one leaves a gap, and a new one
goes at the end.

log.tsv is the only file that cannot be recreated: back it up with the set.

The folder can be moved (Options > Resources), e.g. into a folder your cloud
service synchronises. The Lichess token never moves with it: it stays in
Scid's own user folder.
}
}

# Every set: a list of {dir meta}, newest first.
# The set folders under a data folder.
proc ::woodpecker::set::setDirs {root} {
    set out {}
    foreach d [glob -nocomplain -types d -directory $root *] {
        if {[file exists [file join $d set.tsv]]} { lappend out $d }
    }
    return [lsort $out]
}

# Close the databases whose files live under `root`, before the folder moves.
# The Open Puzzle Database button makes it easy to have a set open while the
# data folder changes in Options > Resources.
proc ::woodpecker::set::closeBasesUnder {root} {
    if {[llength [info commands sc_base]] == 0} { return }
    set prefix "[file normalize $root][file separator]"
    foreach b [sc_base list] {
        set fn ""
        catch { set fn [file normalize [sc_base filename $b]] }
        if {$fn ne "" && [string first $prefix $fn] == 0} {
            catch { ::file::Close $b }
            if {[sc_base inUse $b]} { error "close the set's database before moving the data folder" }
        }
    }
}

# Move every set from one data folder to another (copy, check, then delete the
# original). A set that already exists in the destination is left where it is.
# Returns {moved skipped}.
proc ::woodpecker::set::moveSets {from to} {
    closeBasesUnder $from
    file mkdir $to
    set moved 0
    set skipped 0
    foreach d [setDirs $from] {
        set dest [file join $to [file tail $d]]
        if {[file exists $dest]} { incr skipped; continue }
        file copy $d $dest
        if {![file exists [file join $dest set.tsv]]} { error "copy of [file tail $d] failed" }
        file delete -force $d
        incr moved
    }
    return [list $moved $skipped]
}

proc ::woodpecker::set::all {} {
    set out {}
    foreach d [glob -nocomplain -types d -directory [rootDir] *] {
        if {![file exists [file join $d set.tsv]]} { continue }
        set meta [::woodpecker::readMeta $d]
        lappend out [list $d $meta]
    }
    return [lsort -decreasing -command {apply {{a b} {
        set ca [expr {[dict exists [lindex $a 1] created] ? [dict get [lindex $a 1] created] : ""}]
        set cb [expr {[dict exists [lindex $b 1] created] ? [dict get [lindex $b 1] created] : ""}]
        string compare $ca $cb
    }}} $out]
}

# A directory name for a new set: letters, digits and dashes from the name,
# made unique.
proc ::woodpecker::set::newDir {name {now ""}} {
    if {$now eq ""} { set now [clock seconds] }
    set slug [string tolower [regsub -all {[^A-Za-z0-9]+} $name "-"]]
    set slug [string trim [string range [string trim $slug "-"] 0 40] "-"]
    if {$slug eq ""} { set slug set }
    # The date first: the folders list in creation order and say when a set
    # was made even to someone who never opens them.
    set slug "[clock format $now -format %Y-%m-%d]-$slug"
    set dir [file join [rootDir] $slug]
    set n 1
    while {[file exists $dir]} { set dir [file join [rootDir] "$slug-[incr n]"] }
    file mkdir $dir
    return $dir
}

# The Lichess puzzle ids already in any set, so a new set never repeats one.
proc ::woodpecker::set::usedIds {} {
    set used [dict create]
    foreach s [all] {
        dict for {ex e} [::woodpecker::readExercises [lindex $s 0]] {
            set id [dict get $e puzzleId]
            if {$id ne ""} { dict set used $id 1 }
        }
    }
    return $used
}

################################################################################
# HTTP

# GET a URL; returns {status body}. curl when available (an identifying
# User-Agent, a bearer token), otherwise Tcl's http package with tls. The wait
# keeps the event loop alive so the progress window stays responsive.
proc ::woodpecker::set::httpGet {url {token ""}} {
    return [httpRequest GET $url $token]
}

proc ::woodpecker::set::httpRequest {method url {token ""} {body ""}} {
    variable UA
    if {[auto_execok curl] ne ""} {
        set cmd [list curl -sS --max-time 30 -A $UA -H "Accept: application/json" -w "\n%{http_code}"]
        if {$token ne ""} { lappend cmd -H "Authorization: Bearer $token" }
        if {$method eq "POST"} { lappend cmd -X POST -H "Content-Type: text/plain" --data-binary $body }
        lappend cmd $url
        set f [open |[concat $cmd [list 2>@1]] r]
        fconfigure $f -blocking 0 -encoding utf-8
        set ::woodpecker::set::http($f) ""
        fileevent $f readable [list ::woodpecker::set::httpRead $f]
        vwait ::woodpecker::set::httpDone($f)
        set data $::woodpecker::set::http($f)
        unset ::woodpecker::set::http($f) ::woodpecker::set::httpDone($f)
        set data [string trimright $data]
        set nl [string last "\n" $data]
        set status [string trim [string range $data [expr {$nl + 1}] end]]
        if {![string is integer -strict $status]} { return [list 0 $data] }
        return [list $status [string range $data 0 [expr {$nl - 1}]]]
    }
    package require http
    catch {
        package require tls
        ::http::register https 443 [list ::tls::socket -autoservername 1]
    }
    set headers [list Accept application/json]
    if {$token ne ""} { lappend headers Authorization "Bearer $token" }
    # The package-wide agent is swapped for this request and put back.
    set savedAgent [::http::config -useragent]
    ::http::config -useragent $UA
    set failed [catch {
        if {$method eq "POST"} {
            ::http::geturl $url -timeout 30000 -headers $headers -type text/plain -query $body
        } else {
            ::http::geturl $url -timeout 30000 -headers $headers
        }
    } tok]
    ::http::config -useragent $savedAgent
    if {$failed} { error $tok }
    set status [::http::ncode $tok]
    set body [::http::data $tok]
    ::http::cleanup $tok
    return [list $status $body]
}

proc ::woodpecker::set::httpRead {f} {
    append ::woodpecker::set::http($f) [read $f]
    if {[eof $f]} {
        fconfigure $f -blocking 1
        catch { close $f }
        set ::woodpecker::set::httpDone($f) 1
    }
}

# Wait `ms` without blocking the event loop; returns early when cancelled.
proc ::woodpecker::set::pause {ms} {
    variable cancel
    set end [expr {[clock milliseconds] + $ms}]
    while {!$cancel && [clock milliseconds] < $end} {
        set ::woodpecker::set::tick 0
        after 200 [list set ::woodpecker::set::tick 1]
        vwait ::woodpecker::set::tick
    }
}

################################################################################
# Lichess

# How many puzzles of each level: shares {level weight ...} turned into counts
# that add up to n (largest remainders).
proc ::woodpecker::set::levelCounts {n shares} {
    set total 0.0
    dict for {k w} $shares { set total [expr {$total + $w}] }
    if {$total <= 0} { error "no difficulty chosen" }
    set out [dict create]
    set rest {}
    set used 0
    dict for {k w} $shares {
        set exact [expr {$n * $w / $total}]
        set c [expr {int(floor($exact))}]
        dict set out $k $c
        incr used $c
        lappend rest [list $k [expr {$exact - $c}]]
    }
    foreach r [lsort -real -decreasing -index 1 $rest] {
        if {$used >= $n} break
        dict incr out [lindex $r 0]
        incr used
    }
    return $out
}

# Download puzzles. `spec` keys: count, shares {level weight ...}, angle
# ("mix" or a theme/opening key), color (both | white | black), token, and
# rating: the trainee's Lichess puzzle rating, used when there is no token to
# emulate the levels (::woodpecker::anonPlan).
# `progress` is called as {*}$progress done total message.
# Returns the exercises (::woodpecker::lichessExercise dicts) sorted by rating,
# easiest first, none of them already in another set.
proc ::woodpecker::set::fetchLichess {spec {progress ""}} {
    variable BATCH
    variable PAUSE_MS
    variable RETRY_MS
    variable WAIT_MS
    variable MAX_IDLE_ROUNDS
    variable cancel
    set cancel 0
    set n [dict get $spec count]
    set angle [expr {[dict exists $spec angle] && [dict get $spec angle] ne "" ? [dict get $spec angle] : "mix"}]
    set color [expr {[dict exists $spec color] ? [dict get $spec color] : "both"}]
    set token [expr {[dict exists $spec token] ? [dict get $spec token] : ""}]
    set rating [expr {[dict exists $spec rating] ? [dict get $spec rating] : ""}]
    set emulate [expr {$token eq "" && [string is integer -strict $rating]}]
    set want [levelCounts $n [dict get $spec shares]]
    # Without a token Lichess answers the same 50 puzzles for one angle and
    # level for about a minute (measured 2026-11-17). "mix" is therefore
    # rotated with the three game phases, which between them cover every
    # puzzle; when a whole round brings nothing new the next minute is awaited.
    set angles [expr {$angle eq "mix" ? {mix opening middlegame endgame} : [list $angle]}]
    set seen [usedIds]
    # `skip`: ids already chosen for this set (from the bundled pool).
    if {[dict exists $spec skip]} { foreach id [dict get $spec skip] { dict set seen $id 1 } }
    # Puzzles fetched but outside the band of the level being filled: another
    # level, or the same one once its band widens, may still take them.
    # Kept as id -> {difficulty fetched at, exercise}, so a level can tell a
    # leftover of its own batch from one of another difficulty's.
    set spare [dict create]
    set got {}
    set done 0
    dict for {level target} $want {
        if {$target <= 0} { continue }
        if {$emulate} {
            set plan [::woodpecker::anonPlan $rating $level]
            set sources [dict get $plan sources]
            set centre [dict get $plan centre]
            set window [dict get $plan window]
        } else {
            set sources [list $level]
            set centre ""
            set window ""
        }
        set have 0
        set idle 0
        # Does a spare puzzle belong to this level's band? A batch fetched
        # with a token is one difficulty, so its leftovers are only for the
        # level that asked for them; an emulated draw has a rating window and
        # may take any spare that fits it.
        set take [list apply {{ex centre window spareLevel target} {
            if {$centre eq ""} { return [expr {$spareLevel eq $target}] }
            expr {abs([dict get $ex rating] - $centre) <= $window}
        }}]
        # What is already in hand first.
        dict for {id pair} $spare {
            if {$have >= $target} break
            lassign $pair spareLevel ex
            if {[{*}$take $ex $centre $window $spareLevel $level]} {
                dict set ex level $level
                lappend got $ex
                dict unset spare $id
                incr have
                incr done
            }
        }
        while {$have < $target && $idle < $MAX_IDLE_ROUNDS && !$cancel} {
            set roundFresh 0
            foreach src $sources {
                foreach a $angles {
                    if {$have >= $target || $cancel} break
                    set url "https://lichess.org/api/puzzle/batch/[urlPart $a]?nb=$BATCH&difficulty=$src"
                    if {$progress ne ""} { {*}$progress $done $n "lichess: $level" }
                    if {[catch { httpGet $url $token } res]} {
                        error "Lichess: $res"
                    }
                    lassign $res status body
                    if {$status == 429} {
                        if {$progress ne ""} { {*}$progress $done $n "lichess: 429, waiting 60 s" }
                        pause $RETRY_MS
                        continue
                    }
                    if {$status != 200} {
                        error "Lichess answered $status: [string range $body 0 200]"
                    }
                    set reply [::woodpecker::jsonParse $body]
                    foreach entry [dict get $reply puzzles] {
                        set id [dict get $entry puzzle id]
                        if {[dict exists $seen $id]} { continue }
                        dict set seen $id 1
                        if {[catch { ::woodpecker::lichessExercise $entry } ex]} { continue }
                        set side [::woodpecker::fenSide [dict get $ex fen]]
                        if {$color eq "white" && $side ne "w"} { continue }
                        if {$color eq "black" && $side ne "b"} { continue }
                        if {$have < $target && [{*}$take $ex $centre $window $src $level]} {
                            dict set ex level $level
                            lappend got $ex
                            incr have
                            incr done
                            incr roundFresh
                        } else {
                            dict set spare $id [list $src $ex]
                        }
                    }
                    if {$progress ne ""} { {*}$progress $done $n "lichess: $level" }
                    pause $PAUSE_MS
                }
            }
            if {$have >= $target} break
            if {$roundFresh == 0} {
                incr idle
                if {$emulate} {
                    # Nothing new in the band: widen it, and look again at what
                    # was set aside before waiting for Lichess.
                    incr window 100
                    dict for {id pair} $spare {
                        if {$have >= $target} break
                        lassign $pair spareLevel ex
                        if {[{*}$take $ex $centre $window $spareLevel $level]} {
                            dict set ex level $level
                            lappend got $ex
                            dict unset spare $id
                            incr have
                            incr done
                            incr roundFresh
                        }
                    }
                }
                if {$have >= $target} break
                if {$roundFresh == 0} {
                    if {$progress ne ""} { {*}$progress $done $n "lichess: waiting for new puzzles" }
                    pause $WAIT_MS
                }
            } else {
                set idle 0
            }
        }
    }
    if {$cancel} { error cancelled }
    return [byRating $got]
}

# Exercises sorted by rating, easiest first.
proc ::woodpecker::set::byRating {exs} {
    return [lsort -integer -command {apply {{a b} {
        expr {[dict get $a rating] - [dict get $b rating]}
    }}} $exs]
}

proc ::woodpecker::set::urlPart {s} {
    return [string map {" " "%20" "/" "%2F" "?" "%3F" "&" "%26" "#" "%23"} $s]
}

################################################################################
# The puzzles shipped with Scid (puzzles/set-*.pgn, graded Lichess puzzles).
# Their union is one pool, filtered by the rating band of each level as
# fetchLichess does without a token. A new set-*.pgn joins the pool unchanged.

# share/scid/puzzles once installed; the repository's puzzles/ in a source tree
# run, where scidShareDir is the repository itself.
proc ::woodpecker::set::puzzlesDir {} {
    if {[info exists ::scidShareDir]} { return [file join $::scidShareDir puzzles] }
    variable HERE
    return [file normalize [file join $HERE .. .. puzzles]]
}
set ::woodpecker::set::HERE [file dirname [file normalize [info script]]]

# The pool: one dict per game, its PGN tags plus `moves` (the SAN movetext).
# Only the tags are read here (under a second for 6000 games); the moves are
# converted for the puzzles drawn. Kept for the session.
proc ::woodpecker::set::readPool {{dir ""}} {
    variable pool
    if {$dir eq ""} { set dir [puzzlesDir] }
    if {[info exists pool($dir)]} { return $pool($dir) }
    set games {}
    foreach f [lsort [glob -nocomplain -directory $dir set-*.pgn]] {
        set ch [open $f r]
        fconfigure $ch -encoding utf-8
        set g [dict create]
        while {[gets $ch line] >= 0} {
            set line [string trim $line]
            if {[regexp {^\[(\w+)\s+"(.*)"\]$} $line -> k v]} {
                if {[dict exists $g moves]} { lappend games $g; set g [dict create] }
                dict set g $k $v
            } elseif {$line ne ""} {
                dict append g moves " $line"
            }
        }
        if {[dict exists $g moves]} { lappend games $g }
        close $ch
    }
    set out {}
    foreach g $games {
        if {![dict exists $g PuzzleId] || ![dict exists $g FEN] || ![dict exists $g SourceFEN]} { continue }
        if {![dict exists $g LichessRating] || ![string is integer -strict [dict get $g LichessRating]]} { continue }
        lappend out $g
    }
    set pool($dir) $out
    return $out
}

# puzzles/marks.tsv: the ! and !! of each pool puzzle, graded once with the
# trainer's evaluation (scripts/woodpecker/bundled_marks.tcl). PuzzleId -> the
# mark of each solver move ("" for none). Missing file: no marks, and a new set
# is graded like any other.
proc ::woodpecker::set::readBundledMarks {{dir ""}} {
    variable bmarks
    if {$dir eq ""} { set dir [puzzlesDir] }
    if {[info exists bmarks($dir)]} { return $bmarks($dir) }
    set out [dict create]
    foreach row [::woodpecker::readLines [file join $dir marks.tsv]] {
        lassign $row id marks
        set l {}
        foreach m [split $marks " "] {
            if {$m ne ""} { lappend l [expr {$m eq "-" ? "" : $m}] }
        }
        if {$id ne "" && [llength $l]} { dict set out $id $l }
    }
    set bmarks($dir) $out
    return $out
}

# One pool game as the trainer's exercise (the ::woodpecker::lichessExercise
# shape). The PGN has no LastMove tag: it is the one legal move that leads from
# SourceFEN to FEN. The solver's side comes from the FEN; FlipB is ignored.
# `marks` (readBundledMarks): when it has the puzzle, and one mark per solver
# move, the exercise carries them (key `marks`).
proc ::woodpecker::set::bundledExercise {g {marks ""}} {
    set fen [dict get $g FEN]
    set src [::chessboard::fromFen [dict get $g SourceFEN]]
    set board [lindex $fen 0]
    set last ""
    foreach m [::chessboard::legalMoves $src] {
        if {[lindex [::chessboard::toFen [::chessboard::makeMove $src $m]] 0] eq $board} { set last $m; break }
    }
    if {$last eq ""} { error "[dict get $g PuzzleId]: no move leads from SourceFEN to FEN" }
    set pos [::chessboard::fromFen $fen]
    set solution {}
    foreach tok [dict get $g moves] {
        regsub {^\d+\.+} $tok "" tok
        if {$tok eq "" || $tok in {* 1-0 0-1 1/2-1/2}} { continue }
        set uci [::woodpecker::sanToUci $pos $tok]
        lappend solution $uci
        set pos [::chessboard::makeMove $pos $uci]
    }
    if {![llength $solution]} { error "[dict get $g PuzzleId]: no solution" }
    # The game's page at the puzzle's move: lichess.org/<id>/black#74.
    set gameId ""
    if {[dict exists $g GameUrl]} { regexp {lichess\.org/(?:game/)?(.+)$} [dict get $g GameUrl] -> gameId }
    set ex [dict create id [dict get $g PuzzleId] rating [dict get $g LichessRating] \
        plays [expr {[dict exists $g NbPlays] ? [dict get $g NbPlays] : ""}] \
        themes [expr {[dict exists $g Themes] ? [dict get $g Themes] : {}}] \
        fen $fen lastMove $last solution $solution gameId $gameId white "" black ""]
    # The solver moves are every other ply, from the first.
    set id [dict get $g PuzzleId]
    if {$marks ne "" && [dict exists $marks $id] \
            && [llength [dict get $marks $id]] == (([llength $solution] + 1) / 2)} {
        dict set ex marks [dict get $marks $id]
    }
    return $ex
}

# Draw puzzles from the pool. `spec` keys as for fetchLichess (count, shares,
# angle, color, rating; no token), plus `seed` for a repeatable draw (tests).
# Per level the band is the one Lichess uses (centre = rating + the level's
# delta, ::woodpecker::levelWindow), with its centre clipped to the ratings the
# pool holds; when short it widens once by 100. Not more: the pool is small and
# a band widened further stops being the level asked for (at 1500, six steps
# turn "normal" from 1400-1600 into 800-2200), so a level still short is a
# shortfall the caller can fill from Lichess. `dir` is the puzzle folder
# ("" = puzzlesDir).
# Returns {exercises short}: the exercises sorted by rating, none already in
# another set, and {level missing ...} for the levels that came up short.
proc ::woodpecker::set::fetchBundled {spec {progress ""} {dir ""}} {
    set pool [readPool $dir]
    if {![llength $pool]} { error "no puzzles found in [expr {$dir eq "" ? [puzzlesDir] : $dir}]" }
    if {[dict exists $spec seed]} { expr {srand([dict get $spec seed])} }
    set n [dict get $spec count]
    set angle [expr {[dict exists $spec angle] && [dict get $spec angle] ne "" ? [dict get $spec angle] : "mix"}]
    set color [expr {[dict exists $spec color] ? [dict get $spec color] : "both"}]
    set rating [dict get $spec rating]
    set want [levelCounts $n [dict get $spec shares]]
    set seen [usedIds]
    set bmarks [readBundledMarks $dir]
    # What the pool holds (not what is left): an exhausted band is a shortfall,
    # never a silent move to easier puzzles.
    set lo Inf
    set hi -Inf
    set cands {}
    # Puzzles per 50 rating points: the sets are not equally dense (1000 in
    # 300 points up to 2450, 1000 in 150 above), so a puzzle is drawn with a
    # weight of 1 / density, which makes the draw uniform in rating.
    set dens [dict create]
    foreach g $pool { dict incr dens [expr {[dict get $g LichessRating] / 50}] }
    foreach g $pool {
        set r [dict get $g LichessRating]
        set lo [expr {min($lo, $r)}]
        set hi [expr {max($hi, $r)}]
        if {[dict exists $seen [dict get $g PuzzleId]]} { continue }
        set side [::woodpecker::fenSide [dict get $g FEN]]
        if {($color eq "white" && $side ne "w") || ($color eq "black" && $side ne "b")} { continue }
        if {$angle ne "mix" && (![dict exists $g Themes] || $angle ni [dict get $g Themes])} { continue }
        lappend cands $g
    }
    set got {}
    set short [dict create]
    set done 0
    dict for {level target} $want {
        if {$target <= 0} { continue }
        set centre [expr {$rating + [::woodpecker::levelDelta $level]}]
        set window [::woodpecker::levelWindow $centre]
        set centre [expr {min(max($centre, $lo), $hi)}]
        set have 0
        for {set round 0} {$have < $target && $round <= 1} {incr round} {
            set in {}
            set rest {}
            foreach g $cands {
                set r [dict get $g LichessRating]
                if {abs($r - $centre) <= $window} {
                    # Weighted random order (Efraimidis-Spirakis, log form).
                    lappend in [list [expr {log(rand()) * [dict get $dens [expr {$r / 50}]]}] $g]
                } else {
                    lappend rest $g
                }
            }
            set cands $rest
            foreach k [lsort -real -decreasing -index 0 $in] {
                set g [lindex $k 1]
                # Left over: another level, or a wider band, may take it.
                if {$have >= $target} { lappend cands $g; continue }
                if {[catch { bundledExercise $g $bmarks } ex]} { continue }
                dict set ex level $level
                lappend got $ex
                incr have
                incr done
                if {$progress ne "" && $done % 10 == 0} { {*}$progress $done $n $level }
            }
            incr window 100
        }
        if {$have < $target} { dict set short $level [expr {$target - $have}] }
    }
    return [list [byRating $got] $short]
}

################################################################################
# Building the set's database

# Write the exercises (lichessExercise-shaped dicts) as set.pgn, import it into a
# new Scid database in `dir`, and write exercises.tsv and set.tsv.
proc ::woodpecker::set::buildFromExercises {dir meta exercises} {
    set pgn [file join $dir set.pgn]
    set f [open $pgn w]
    fconfigure $f -encoding utf-8
    set rows [dict create]
    set marks [dict create]
    set ex 0
    foreach e $exercises {
        incr ex
        # Marks already graded (the bundled puzzles): the set's first marks version.
        if {[dict exists $e marks]} { dict set marks $ex [dict create marks [dict get $e marks] source review] }
        set tags [list [list PuzzleId [dict get $e id]] [list PuzzleRating [dict get $e rating]]]
        if {[dict get $e plays] ne ""} { lappend tags [list PuzzlePlays [dict get $e plays]] }
        lappend tags [list PuzzleThemes [join [dict get $e themes] " "]]
        lappend tags [list LastMove [dict get $e lastMove]]
        set site [expr {[dict get $e gameId] ne "" ? "https://lichess.org/[dict get $e gameId]" : "?"}]
        puts -nonewline $f [::woodpecker::pgnGame [dict get $e fen] [dict get $e solution] \
            [dict get $meta name] $ex [dict get $e white] [dict get $e black] $site $tags]
        dict set rows $ex [::woodpecker::exerciseRow $ex $ex [dict get $e id] [dict get $e rating] \
            [dict get $e fen] [dict get $e solution] [dict get $e lastMove]]
    }
    close $f
    set imported [importPgn $dir $pgn]
    if {$imported != $ex} { error "the set database has $imported games, expected $ex" }
    # The PGN was only the way into the database, which holds the same games.
    catch { file delete $pgn }
    ::woodpecker::writeExercises $dir $rows
    ::woodpecker::writeMeta $dir $meta
    if {[dict size $marks]} {
        ::woodpecker::marksAppend $dir $marks
        writeMarks $dir $marks
    }
    return $ex
}

# Create the set's Scid database from a PGN file; returns the number of games.
proc ::woodpecker::set::importPgn {dir pgn} {
    set path [file join $dir set]
    set prev [sc_base current]
    set b [sc_base create SCID5 $path]
    set err [catch {
        lassign [sc_base import $b $pgn] count errors
        set count [sc_base numGames $b]
    } msg]
    catch { sc_base close $b }
    restoreBase $prev
    if {$err} { error $msg }
    return $count
}

# Creating or opening a database makes it the current one; put back the base
# that was current before (the clipbase when that one is gone).
proc ::woodpecker::set::restoreBase {prev} {
    if {[catch { sc_base switch $prev }]} {
        catch { sc_base switch [sc_info clipbase] }
    }
}

proc ::woodpecker::set::basePath {dir} { return [file join $dir set] }

# The id of the set's database, opening it when it is not open. Returns
# {baseId openedHere}.
proc ::woodpecker::set::openBase {dir} {
    set want [file normalize [basePath $dir]]
    foreach b [sc_base list] {
        set fn ""
        catch { set fn [file normalize [file rootname [sc_base filename $b]]] }
        if {$fn eq $want} { return [list $b 0] }
    }
    return [list [sc_base open SCID5 [basePath $dir]] 1]
}

################################################################################
# Keeping exercises.tsv in step with the set's database
#
# The database is there to be opened, studied and corrected (Open Puzzle
# Database). A puzzle deleted or added there must change the training set, or
# the trainee would see the deleted puzzle come back at the next session.
#
# The exercise number is the identity marks.tsv and log.tsv use, so a sync never
# renumbers: an exercise keeps its number when the database is edited, a deleted
# one leaves a gap, and an added one gets a new number at the end. Matched by
# identity (the Lichess id, or the position and solution), not by game number,
# so a compaction or a sort does not disturb the records.

# What identifies an exercise across edits of the database.
proc ::woodpecker::set::exerciseUid {e} {
    set pid [expr {[dict exists $e puzzleId] ? [dict get $e puzzleId] : ""}]
    if {$pid ne ""} { return "p:$pid" }
    return "f:[dict get $e fen]|[dict get $e solution]"
}

# The newest modification time of the set's database files.
proc ::woodpecker::set::dbMtime {dir} {
    set newest 0
    foreach ext {.si5 .sg5 .sn5} {
        set path "[basePath $dir]$ext"
        if {[file exists $path]} {
            set m [file mtime $path]
            if {$m > $newest} { set newest $m }
        }
    }
    return $newest
}

# Has the database been written since exercises.tsv was written?
proc ::woodpecker::set::dbNewer {dir} {
    set tsv [file join $dir exercises.tsv]
    if {![file exists $tsv]} { return 1 }
    return [expr {[dbMtime $dir] > [file mtime $tsv]}]
}

# The highest exercise number any file still mentions. Marks and log rows of a
# deleted exercise stay (a sync never rewrites the records), so a new exercise
# must not inherit that number.
proc ::woodpecker::set::maxExerciseId {dir old} {
    set max 0
    foreach ex [dict keys $old] {
        if {$ex > $max} { set max $ex }
    }
    lassign [::woodpecker::readLog $dir] xs ss
    foreach x $xs {
        set ex [dict get $x ex]
        if {$ex > $max} { set max $ex }
    }
    set marks [::woodpecker::readMarks $dir]
    foreach ver [dict keys $marks] {
        foreach ex [dict keys [dict get $marks $ver]] {
            if {$ex > $max} { set max $ex }
        }
    }
    return $max
}

# Rebuild exercises.tsv from the set's database when the database is newer.
# Returns 1 when the file was rewritten, 0 when there was nothing to do.
proc ::woodpecker::set::syncFromBase {dir} {
    set key [file normalize [basePath $dir]]
    if {![dict exists $::woodpecker::set::dirty $key] && ![dbNewer $dir]} { return 0 }
    # Switching bases would disturb a session or a game being played.
    if {[info exists ::woodpecker::ui::run(on)] && $::woodpecker::ui::run(on)} { return 0 }
    if {[info exists ::playMode]} { return 0 }

    set old [::woodpecker::readExercises $dir]
    set prev [sc_base current]
    lassign [openBase $dir] b opened
    set err [catch { lassign [readGames $b] rows marks skipped } msg]
    if {$opened} { catch { sc_base close $b } }
    restoreBase $prev
    if {$err} { error $msg }

    # The exercise numbers the old rows had, by identity, in their old order.
    set oldBy [dict create]
    foreach ex [lsort -integer [dict keys $old]] {
        dict lappend oldBy [exerciseUid [dict get $old $ex]] $ex
    }
    set next [expr {[maxExerciseId $dir $old] + 1}]
    set out [dict create]
    set n [dict size $rows]
    for {set i 1} {$i <= $n} {incr i} {
        set e [dict get $rows $i]
        set uid [exerciseUid $e]
        if {[dict exists $oldBy $uid] && [llength [dict get $oldBy $uid]]} {
            set q [dict get $oldBy $uid]
            set ex [lindex $q 0]
            dict set oldBy $uid [lrange $q 1 end]
        } else {
            set ex $next
            incr next
        }
        dict set out $ex $e
    }
    ::woodpecker::writeExercises $dir $out
    dict unset ::woodpecker::set::dirty $key
    return 1
}

# The database's own change notification says "this set was written", even when
# the one-second filesystem timestamp cannot tell an edit from the build that
# wrote exercises.tsv. The path is what identifies the set, so the mark survives
# closing and reopening its database.
namespace eval ::woodpecker::set {
    variable dirty {}
}
proc ::woodpecker::set::dbModifiedTrace {cmd op} {
    set b [lindex $cmd 1]
    if {![string is integer -strict $b] || $b <= 0} { return }
    catch {
        dict set ::woodpecker::set::dirty \
            [file normalize [file rootname [sc_base filename $b]]] 1
    }
}
if {[llength [info commands ::notify::DatabaseModified]]} {
    trace add execution ::notify::DatabaseModified enter ::woodpecker::set::dbModifiedTrace
}

################################################################################
# A set from a PGN or Scid database (a book)

# The marks the author wrote on the solver's moves, from the current game and
# its main line: "!" or "!!" per solver move, and whether any move mark at all
# (! !! !? ?! ? ??) is there - an annotated exercise.
proc ::woodpecker::set::authorMarks {plies} {
    set marks {}
    set annotated 0
    for {set p 1} {$p <= $plies} {incr p 2} {
        sc_move ply $p
        set nags [string trim [sc_pos getNags]]
        if {$nags eq "0"} { set nags "" }
        set m ""
        if {"!!" in $nags} { set m "!!" } elseif {"!" in $nags} { set m "!" }
        foreach q {! !! !? ?! ? ??} { if {$q in $nags} { set annotated 1 } }
        lappend marks $m
    }
    return [list $marks $annotated]
}

# The extra tags of the current game as a dict.
proc ::woodpecker::set::extraTags {} {
    set out [dict create]
    foreach line [split [sc_game tags get Extra] "\n"] {
        if {[regexp {^(\S+)\s+"(.*)"\s*$} $line -> k v]} { dict set out $k $v }
    }
    return $out
}

# Read every game of the open set base `b`: its start position, main line and
# the author's marks. Games that do not start from a set-up position, or have
# no moves, or contain a null move, are not exercises and are skipped.
# Returns {rows authorMarks skipped}.
proc ::woodpecker::set::readGames {b} {
    set prev [sc_base current]
    set prevGame ""
    if {$prev == $b} { catch { set prevGame [sc_game number] } }
    sc_base switch $b
    set rows [dict create]
    set marks [dict create]
    set skipped 0
    set ex 0
    set n [sc_base numGames $b]
    for {set g 1} {$g <= $n} {incr g} {
        # A game deleted in the database editor stays in the file until the
        # next compaction; it is not an exercise any more.
        if {[sc_base gameflag $b $g get D]} { incr skipped; continue }
        if {[catch { sc_game load $g }]} { incr skipped; continue }
        set ml [sc_game UCI_mainLine]
        set head [lindex $ml 0]
        set moves [lrange $ml 1 end]
        if {![regexp {^position fen (.+) moves$} $head -> fen] || ![llength $moves] \
                || [lsearch -glob $moves "position*"] >= 0} {
            incr skipped
            continue
        }
        incr ex
        set extra [extraTags]
        set rating [expr {[dict exists $extra PuzzleRating] ? [dict get $extra PuzzleRating] : ""}]
        set pid [expr {[dict exists $extra PuzzleId] ? [dict get $extra PuzzleId] : ""}]
        set last [expr {[dict exists $extra LastMove] ? [dict get $extra LastMove] : ""}]
        dict set rows $ex [::woodpecker::exerciseRow $ex $g $pid $rating $fen $moves $last]
        lassign [authorMarks [llength $moves]] m annotated
        if {$annotated} { dict set marks $ex [dict create marks $m source author] }
    }
    sc_base switch $prev
    if {$prevGame ne "" && $prevGame > 0} { catch { sc_game load $prevGame } }
    return [list $rows $marks $skipped]
}

# Build a set from a PGN (or .si5/.si4) file. Variations are kept in the
# database but ignored by the trainer: the main line is the solution.
# Returns {exercises annotated skipped}.
proc ::woodpecker::set::buildFromFile {dir meta file} {
    set prev [sc_base current]
    set ext [string tolower [file extension $file]]
    if {$ext in {.si5 .si4}} {
        set type [expr {$ext eq ".si4" ? "SCID4" : "SCID5"}]
        set src [sc_base open $type [file rootname $file]]
    } else {
        set src [sc_base open PGN $file]
    }
    set dst ""
    set err [catch {
        set dst [sc_base create SCID5 [basePath $dir]]
        sc_base copygames $src dbfilter $dst
        lassign [readGames $dst] rows marks skipped
        sc_base close $dst
        set dst ""
    } msg]
    catch { sc_base close $src }
    # A failure before the close above would leave the half-built base open,
    # holding a database slot the UI can no longer free.
    if {$dst ne ""} { catch { sc_base close $dst } }
    restoreBase $prev
    if {$err} { error $msg }
    if {![dict size $rows]} { error "no exercise: no game starts from a set-up position" }
    ::woodpecker::writeExercises $dir $rows
    if {[dict size $marks]} { ::woodpecker::marksAppend $dir $marks }
    dict set meta source file
    dict set meta file $file
    ::woodpecker::writeMeta $dir $meta
    return [list [dict size $rows] [dict size $marks] $skipped]
}

# How many exercises carry marks, and from whom: {total annotated reviewed}.
# `annotated` = the author's marks are the newest for the exercise.
proc ::woodpecker::set::markStatus {dir} {
    set exs [::woodpecker::readExercises $dir]
    set marks [::woodpecker::readMarks $dir]
    set table [::woodpecker::marksAt $marks [::woodpecker::marksLatest $marks]]
    set author 0
    set review 0
    dict for {ex e} $table {
        if {![dict exists $exs $ex]} { continue }
        if {[dict get $e source] eq "author"} { incr author } else { incr review }
    }
    return [dict create total [dict size $exs] annotated $author reviewed $review]
}

################################################################################
# Writing marks into the database, so a shown solution carries them

proc ::woodpecker::set::writeMarks {dir exMarks} {
    set exs [::woodpecker::readExercises $dir]
    set prev [sc_base current]
    lassign [openBase $dir] b opened
    sc_base switch $b
    set err [catch {
        dict for {ex e} $exMarks {
            if {![dict exists $exs $ex]} { continue }
            set g [dict get $exs $ex game]
            sc_game load $g
            set p 1
            foreach m [dict get $e marks] {
                sc_move ply $p
                set nags [string trim [sc_pos getNags]]
                if {$nags eq "0"} { set nags "" }
                set keep {}
                foreach n $nags { if {$n ni {! !! !? ?! ? ??}} { lappend keep $n } }
                sc_pos clearNags
                foreach n $keep { sc_pos addNag $n }
                if {$m ne ""} { sc_pos addNag $m }
                incr p 2
            }
            sc_game save $g
        }
    } msg]
    if {$opened} { catch { sc_base close $b } }
    restoreBase $prev
    if {$err} { error $msg }
}

################################################################################
# Creating a set: the meta every set carries

proc ::woodpecker::set::newMeta {name source days1 restDays now} {
    return [dict create name $name source $source created [clock format $now -format "%Y-%m-%d %H:%M:%S"] \
        days1 $days1 restDays $restDays version 1]
}

################################################################################
# The Lichess token: <Scid user dir>/woodpecker/token.txt, readable by its owner
# only (the publish-to-Lichess feature keeps its own the same way). Always in
# Scid's own folder, never in a data folder that may be synchronised.

proc ::woodpecker::set::tokenPath {} { return [file join [localDir] token.txt] }

proc ::woodpecker::set::tokenRead {} {
    set path [tokenPath]
    if {![file exists $path]} { return "" }
    set f [open $path r]
    set t [string trim [read $f]]
    close $f
    return $t
}

proc ::woodpecker::set::tokenValid {t} { return [regexp {^[A-Za-z0-9_]+$} $t] }

proc ::woodpecker::set::tokenWrite {t} {
    set t [string trim $t]
    if {$t ne "" && ![tokenValid $t]} { error "invalid token" }
    set path [tokenPath]
    # A fresh file created 0600 from the start (never world-readable, not even
    # briefly), renamed over the old token only once fully written.
    set tmp "$path.[pid].tmp"
    file delete $tmp
    set f ""
    if {[catch {
        set f [open $tmp {WRONLY CREAT EXCL} 0600]
        fconfigure $f -encoding utf-8
        puts -nonewline $f $t
        close $f
        set f ""
        file rename -force $tmp $path
    } err opts]} {
        catch { close $f }
        catch { file delete $tmp }
        return -options $opts $err
    }
}

# The page that creates a token with exactly the scope the trainer needs.
proc ::woodpecker::set::tokenCreateUrl {} {
    return {https://lichess.org/account/oauth/token/create?scopes[]=puzzle:read&description=scidCommunity+Woodpecker}
}

# Ask Lichess what a token is: {status user scopes rating}.
#   status: ok | noscope (valid, but without puzzle:read) | invalid | error
#   rating: the account's puzzle rating, "" when unknown
proc ::woodpecker::set::tokenCheck {t} {
    set out [dict create status error user "" scopes "" rating ""]
    if {![tokenValid $t]} { dict set out status invalid; return $out }
    if {[catch { httpRequest POST https://lichess.org/api/token/test "" $t } res]} { return $out }
    lassign $res status body
    if {$status != 200 || [catch { ::woodpecker::jsonParse $body } reply]} { return $out }
    if {![dict exists $reply $t] || [dict get $reply $t] eq ""} {
        dict set out status invalid
        return $out
    }
    set info [dict get $reply $t]
    set scopes [expr {[dict exists $info scopes] ? [dict get $info scopes] : ""}]
    dict set out user [expr {[dict exists $info userId] ? [dict get $info userId] : ""}]
    dict set out scopes $scopes
    dict set out status [expr {"puzzle:read" in [split $scopes ","] ? "ok" : "noscope"}]
    if {![catch { httpRequest GET https://lichess.org/api/account $t } acc]} {
        lassign $acc st body
        if {$st == 200 && ![catch { ::woodpecker::jsonParse $body } me]} {
            if {[dict exists $me perfs puzzle rating]} { dict set out rating [dict get $me perfs puzzle rating] }
        }
    }
    return $out
}
