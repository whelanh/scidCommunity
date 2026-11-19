### woodpecker_set.tcl: Woodpecker trainer - building a set.
### SPDX-License-Identifier: GPL-2.0-or-later
###
### A set is a directory under <user dir>/woodpecker/ holding a Scid database
### (set.si5 ...) with one game per exercise, and the files woodpecker_core.tcl
### reads and writes. Two sources: Lichess puzzles (the batch API) and a PGN or
### Scid database the user already has (a book converted to PGN).
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
                            opens the database (rebuilt with the set)
  marks.tsv                 the ! and !! of every evaluation, versioned
  log.tsv                   every exercise played and every session: the
                            statistics are computed from this file
  set.tsv                   the set's name, source and schedule

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

# Move every set from one data folder to another (copy, check, then delete the
# original). A set that already exists in the destination is left where it is.
# Returns {moved skipped}.
proc ::woodpecker::set::moveSets {from to} {
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
    ::http::config -useragent $UA
    if {$method eq "POST"} {
        set tok [::http::geturl $url -timeout 30000 -headers $headers -type text/plain -query $body]
    } else {
        set tok [::http::geturl $url -timeout 30000 -headers $headers]
    }
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
    # Puzzles fetched but outside the band of the level being filled: another
    # level, or the same one once its band widens, may still take them.
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
        set take [list apply {{ex centre window} {
            expr {$centre eq "" || abs([dict get $ex rating] - $centre) <= $window}
        }}]
        # What is already in hand first.
        dict for {id ex} $spare {
            if {$have >= $target} break
            if {[{*}$take $ex $centre $window]} {
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
                        if {$have < $target && [{*}$take $ex $centre $window]} {
                            dict set ex level $level
                            lappend got $ex
                            incr have
                            incr done
                            incr roundFresh
                        } else {
                            dict set spare $id $ex
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
                    dict for {id ex} $spare {
                        if {$have >= $target} break
                        if {[{*}$take $ex $centre $window]} {
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
    return [lsort -integer -command {apply {{a b} {
        expr {[dict get $a rating] - [dict get $b rating]}
    }}} $got]
}

proc ::woodpecker::set::urlPart {s} {
    return [string map {" " "%20" "/" "%2F" "?" "%3F" "&" "%26" "#" "%23"} $s]
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
    set ex 0
    foreach e $exercises {
        incr ex
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
    sc_base switch $b
    set rows [dict create]
    set marks [dict create]
    set skipped 0
    set ex 0
    set n [sc_base numGames $b]
    for {set g 1} {$g <= $n} {incr g} {
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
    set err [catch {
        set dst [sc_base create SCID5 [basePath $dir]]
        sc_base copygames $src dbfilter $dst
        lassign [readGames $dst] rows marks skipped
        sc_base close $dst
    } msg]
    catch { sc_base close $src }
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
    ::woodpecker::writeAtomic $path $t
    catch { file attributes $path -permissions 0600 }
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
