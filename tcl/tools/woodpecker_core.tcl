### woodpecker_core.tcl: Woodpecker trainer - scoring, schedule and records.
### SPDX-License-Identifier: GPL-2.0-or-later
###
### Pure Tcl: no Tk and no sc_* commands, so the same code runs in the
### application and in tests/tcl/woodpecker_core.tcl. Time is always passed
### in, never read here. Design: docs/woodpecker-method.md.
###
### Vocabulary
###   set        a fixed, ordered list of exercises (a Scid database + files)
###   exercise   one position to solve; its solution is the main line
###   solver move  a move the trainee has to find (plies 1, 3, 5 ... of the line)
###   cycle      one pass through the whole set, in order
###   session    one sitting; a cycle spans several sessions
###   marks      one of "" "!" "!!" per solver move, from the Woodpecker review
###              or from the author's annotations
###
### Files in a set directory (tab separated, read as data, never executed)
###   set.tsv        key <tab> value
###   exercises.tsv  ex game puzzleId rating nmoves fen solution lastMove
###   marks.tsv      ver ex marks source        (marks: "-" "!" "!!" joined by spaces)
###   log.tsv        X ts cycle session ex result found ms
###                  S ts cycle session start dur_ms
###                  C ts cycle order days1 from   (the scope of the cycles from
###                                                 `cycle` on: an inner circle)
###   ring-<date>.tsv  a log put aside by a reset, like a tree's growth ring:
###                  it can be brought back

namespace eval ::woodpecker {
    variable P
    array set P {
        base     1.0
        bonus1   1.0
        bonus2   2.0
        clean    1.0
        malus    0.5
        weightRef 1500.0
        weightMin 0.5
        weightMax 2.0
        quotaCap 1.5
        stretchMax 2.0
        restDays 1
        idleMs   120000
        sacPoints 2
        shallowDepth 3
    }
}

################################################################################
# Scoring (docs/woodpecker-method.md, Decision 4)

# How much a puzzle's points are worth: its Lichess rating over 1500, clamped.
# A set without ratings (a book) weighs every exercise 1.
proc ::woodpecker::weight {rating} {
    variable P
    if {![string is double -strict $rating] || $rating <= 0} { return 1.0 }
    set w [expr {double($rating) / $P(weightRef)}]
    return [expr {max($P(weightMin), min($P(weightMax), $w))}]
}

proc ::woodpecker::markValue {mark} {
    variable P
    switch -- $mark {
        "!"  { return $P(bonus1) }
        "!!" { return $P(bonus2) }
    }
    return 0.0
}

# The points of one exercise.
#   marks   one mark per solver move ("" / "-" for none); {} when unrated
#   found   one 0/1 per solver move: found before the mistake
#   result  clean (no error) | failed (one mistake ends the exercise)
#   weight  ::woodpecker::weight of the puzzle
# Returns {points P max M bonus B}: everything scaled by the weight.
#   clean   V + bonuses + C
#   failed  bonuses - V*malus, never below 0 (the bonuses found are kept)
proc ::woodpecker::score {marks found result {weight 1.0}} {
    variable P
    set bonus 0.0
    set bmax 0.0
    set i 0
    foreach m $marks {
        set v [markValue $m]
        set bmax [expr {$bmax + $v}]
        if {[lindex $found $i] eq "1"} { set bonus [expr {$bonus + $v}] }
        incr i
    }
    switch -- $result {
        clean  { set pts [expr {$P(base) + $bonus + $P(clean)}] }
        failed { set pts [expr {max(0.0, $bonus - $P(base) * $P(malus))}] }
        default { error "unknown result '$result'" }
    }
    set max [expr {$P(base) + $bmax + $P(clean)}]
    return [dict create points [expr {$pts * $weight}] max [expr {$max * $weight}] \
        bonus [expr {$bonus * $weight}]]
}

################################################################################
# One attempt per exercise, as on Lichess (Decision 7): the first wrong move
# fails it. The exercise's state is a dict.

proc ::woodpecker::exStart {n} {
    return [dict create n $n idx 0 found [lrepeat $n 0] result ""]
}

# Record one answer to the current solver move. Returns the new state and what
# happens next: continue | solved | failed.
proc ::woodpecker::exAnswer {state correct} {
    if {[dict get $state result] ne ""} { error "exercise already finished" }
    if {!$correct} {
        dict set state result failed
        return [list $state failed]
    }
    set idx [dict get $state idx]
    dict set state found [lreplace [dict get $state found] $idx $idx 1]
    incr idx
    dict set state idx $idx
    if {$idx >= [dict get $state n]} {
        dict set state result clean
        return [list $state solved]
    }
    return [list $state continue]
}

proc ::woodpecker::foundString {state} { return [join [dict get $state found] ""] }

################################################################################
# Marks for puzzles (Decision 3): the Woodpecker profile of the review.
#
# Only the solution's own moves are marked, and only when the engine agrees
# with them (label best, excellent, great or brilliant: the review's refine step
# turns a sound sacrifice into brilliant, so leaving it out dropped most "!!").
# `ctx` keys:
#   label      ::reviewdriver::judge's label for the move
#   isBest     the move is the engine's first choice
#   hanging    ::chessboard::hangingMaterial of the move (points left en prise)
#   trivial    ::movelabels::isTrivialRecapture of the reply line (1 = trade-back)
#   pvAfter    the engine's line after the move
#   played     the move (UCI)
#   shallow    the move a short independent search (depth 3) chooses
#   quiet      1 when the move neither captures nor gives check
# "!!" a sound sacrifice: refine's brilliant test without its +5 ceiling (in a
#      puzzle the evaluation before the move already contains the combination)
# "!"  a move that is not the obvious one: quiet, or not what the short search
#      plays
# On 150 Lichess puzzles (scripts/woodpecker/calibrate.py, depth 12) this marks
# 10.0% of the solver's moves "!!" and 20.1% "!": 30.1% earn a bonus.
proc ::woodpecker::markFor {ctx} {
    variable P
    set label [dict get $ctx label]
    # great: the review gives it to an only move when it can see the second line
    if {$label ni {best excellent great brilliant}} { return "" }
    set hanging [expr {[dict exists $ctx hanging] ? [dict get $ctx hanging] : 0}]
    if {$hanging eq ""} { set hanging 0 }
    if {[dict get $ctx isBest] && $hanging >= $P(sacPoints) \
        && [llength [dict get $ctx pvAfter]] && ![dict get $ctx trivial]} {
        return "!!"
    }
    if {[dict exists $ctx quiet] && [dict get $ctx quiet]} { return "!" }
    set shallow [expr {[dict exists $ctx shallow] ? [dict get $ctx shallow] : ""}]
    if {$shallow ne "" && $shallow ne [dict get $ctx played]} { return "!" }
    return ""
}

# The board facts markFor needs, from the position before the move, the move,
# and the engine's line after it.
proc ::woodpecker::moveFacts {fenBefore uci pvAfter} {
    set pos [::chessboard::fromFen $fenBefore]
    set after [::chessboard::makeMove $pos $uci]
    set fenAfter [::chessboard::toFen $after]
    set stm [dict get $pos side]
    set capture [expr {[::movelabels::captureVictim $pos $uci] ne ""}]
    set check [::chessboard::inCheck $after [dict get $after side]]
    set hanging 0
    catch { set hanging [::chessboard::hangingMaterial $fenBefore $fenAfter $stm] }
    set trivial 1
    if {[llength $pvAfter]} {
        catch { set trivial [::movelabels::isTrivialRecapture $stm $fenBefore $pvAfter $fenAfter] }
    }
    return [dict create fenAfter $fenAfter capture $capture check $check \
        quiet [expr {!$capture && !$check && [string length $uci] == 4}] \
        hanging $hanging trivial $trivial]
}

# Does `uci` mate in `fen`? Lichess accepts any mate in one on the last move.
proc ::woodpecker::isMateMove {fen uci} {
    set out 0
    catch {
        set pos [::chessboard::fromFen $fen]
        if {$uci in [::chessboard::legalMoves $pos]} {
            set after [::chessboard::makeMove $pos $uci]
            set side [dict get $after side]
            set out [expr {[::chessboard::inCheck $after $side] && ![llength [::chessboard::legalMoves $after]]}]
        }
    }
    return $out
}

################################################################################
# Dates: a day is "YYYY-MM-DD" in local time; arithmetic on day numbers.

proc ::woodpecker::dayNum {ymd} {
    set t [clock scan "$ymd 12:00" -format "%Y-%m-%d %H:%M"]
    return [expr {int(floor($t / 86400.0))}]
}

proc ::woodpecker::ymd {day} {
    return [clock format [expr {$day * 86400 + 43200}] -format "%Y-%m-%d"]
}

proc ::woodpecker::today {now} { return [clock format $now -format "%Y-%m-%d"] }

################################################################################
# Schedule (Decision 6)

# Planned days of cycle k: the first cycle's days halved at every cycle, at
# least one day (Tikkanen halved each cycle's time, p. 7).
proc ::woodpecker::cycleDays {k days1} {
    set d [expr {int(ceil(double($days1) / (2 ** ($k - 1))))}]
    return [expr {max(1, $d)}]
}

# What a plan asks of the trainee, before a set exists: for the first `cycles`
# cycles of `n` exercises, {cycle days perDay}. perDay is rounded up, as the
# base quota of ::woodpecker::plan. Since the days halve and the exercises do
# not, the daily load doubles every cycle until a cycle fits in a day.
proc ::woodpecker::dailyLoad {n days1 {cycles 3}} {
    set out {}
    if {![string is integer -strict $n] || $n < 1 \
            || ![string is integer -strict $days1] || $days1 < 1} { return $out }
    for {set k 1} {$k <= $cycles} {incr k} {
        set d [cycleDays $k $days1]
        lappend out [dict create cycle $k days $d perDay [expr {int(ceil(double($n) / $d))}]]
    }
    return $out
}

# Today's quota for a cycle.
#   n           exercises in the set
#   days        planned days of this cycle
#   start       the cycle's first day ("YYYY-MM-DD")
#   doneBefore  exercises of this cycle finished before today
#   today       "YYYY-MM-DD"
# A missed day or two raises the daily quota, up to quotaCap times the base
# quota. When that is not enough the deadline moves, so that the quota stays at
# the cap - but never beyond stretchMax times the planned length: a cycle is not
# allowed to drift into months. Past that point the quota rises again.
# Returns a dict:
#   quota base deadline planned slip daysLeft remaining status
#   status: done | on_track | quota_raised | deadline_moved | over_stretch
proc ::woodpecker::plan {n days start doneBefore today} {
    variable P
    set s [dayNum $start]
    set t [dayNum $today]
    set planned [expr {$s + $days - 1}]
    set base [expr {int(ceil(double($n) / $days))}]
    set remaining [expr {max(0, $n - $doneBefore)}]
    set out [dict create base $base planned [ymd $planned] remaining $remaining slip 0]
    if {$remaining == 0} {
        return [dict merge $out [dict create quota 0 deadline [ymd $planned] daysLeft 0 status done]]
    }
    set cap [expr {int(floor($base * $P(quotaCap)))}]
    set left [expr {max(1, $planned - $t + 1)}]
    set need [expr {int(ceil(double($remaining) / $left))}]
    if {$need <= $base} {
        return [dict merge $out [dict create quota $need deadline [ymd $planned] daysLeft $left status on_track]]
    }
    if {$need <= $cap} {
        return [dict merge $out [dict create quota $need deadline [ymd $planned] daysLeft $left status quota_raised]]
    }
    # Move the deadline so that the cap is enough, within the stretch limit.
    set latest [expr {$s + int(ceil($days * $P(stretchMax))) - 1}]
    set leftCap [expr {int(ceil(double($remaining) / $cap))}]
    set deadline [expr {$t + $leftCap - 1}]
    set status deadline_moved
    if {$deadline > $latest} {
        set deadline [expr {max($t, $latest)}]
        set status over_stretch
    }
    set left [expr {$deadline - $t + 1}]
    set quota [expr {int(ceil(double($remaining) / $left))}]
    return [dict merge $out [dict create quota $quota deadline [ymd $deadline] daysLeft $left \
        status $status slip [expr {$deadline - $planned}]]]
}

################################################################################
# Files

proc ::woodpecker::clean {s} { return [string map {"\t" " " "\n" " " "\r" " "} $s] }

proc ::woodpecker::writeAtomic {path content} {
    set tmp "$path.tmp"
    set f [open $tmp w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f $content
    close $f
    file rename -force $tmp $path
}

proc ::woodpecker::readLines {path} {
    if {![file exists $path]} { return {} }
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set data [read $f]
    close $f
    set out {}
    foreach line [split $data "\n"] {
        set line [string trimright $line "\r"]
        if {$line eq "" || [string index $line 0] eq "#"} { continue }
        lappend out [split $line "\t"]
    }
    return $out
}

proc ::woodpecker::appendLine {path fields} {
    set f [open $path a]
    fconfigure $f -encoding utf-8
    set out {}
    foreach x $fields { lappend out [clean $x] }
    puts $f [join $out "\t"]
    close $f
}

# set.tsv: a dict of settings.
proc ::woodpecker::readMeta {dir} {
    set d [dict create]
    foreach row [readLines [file join $dir set.tsv]] {
        if {[llength $row] >= 2} { dict set d [lindex $row 0] [lindex $row 1] }
    }
    return $d
}

proc ::woodpecker::writeMeta {dir meta} {
    set out ""
    dict for {k v} $meta { append out "[clean $k]\t[clean $v]\n" }
    writeAtomic [file join $dir set.tsv] $out
}

# exercises.tsv: ex -> {game puzzleId rating nmoves fen solution lastMove}
# fen/solution/lastMove let a session run without opening the database.
proc ::woodpecker::readExercises {dir} {
    set d [dict create]
    foreach row [readLines [file join $dir exercises.tsv]] {
        lassign $row ex game pid rating nmoves fen solution lastMove
        if {![string is integer -strict $ex]} { continue }
        dict set d $ex [dict create game $game puzzleId $pid rating $rating nmoves $nmoves \
            fen $fen solution $solution lastMove $lastMove]
    }
    return $d
}

proc ::woodpecker::writeExercises {dir exercises} {
    set out "# ex\tgame\tpuzzleId\trating\tnmoves\tfen\tsolution\tlastMove\n"
    foreach ex [lsort -integer [dict keys $exercises]] {
        set e [dict get $exercises $ex]
        set row [list $ex [dict get $e game] [clean [dict get $e puzzleId]] \
            [dict get $e rating] [dict get $e nmoves]]
        foreach k {fen solution lastMove} {
            lappend row [expr {[dict exists $e $k] ? [clean [dict get $e $k]] : ""}]
        }
        append out [join $row "\t"] "\n"
    }
    writeAtomic [file join $dir exercises.tsv] $out
}

# marks.tsv: ver -> ex -> {marks source}; marks as a list, "" for none.
proc ::woodpecker::readMarks {dir} {
    set d [dict create]
    foreach row [readLines [file join $dir marks.tsv]] {
        lassign $row ver ex marks source
        if {![string is integer -strict $ver] || ![string is integer -strict $ex]} { continue }
        set l {}
        foreach m [split $marks " "] {
            if {$m eq ""} { continue }
            lappend l [expr {$m eq "-" ? "" : $m}]
        }
        dict set d $ver $ex [dict create marks $l source $source]
    }
    return $d
}

proc ::woodpecker::marksLatest {marks} {
    if {![dict size $marks]} { return 0 }
    return [tcl::mathfunc::max {*}[dict keys $marks]]
}

# The marks of every exercise as of version `ver`: the newest entry of each
# exercise at or below that version (a partial re-evaluation keeps the rest).
proc ::woodpecker::marksAt {marks ver} {
    set out [dict create]
    foreach v [lsort -integer [dict keys $marks]] {
        if {$v > $ver} { break }
        dict for {ex e} [dict get $marks $v] { dict set out $ex $e }
    }
    return $out
}

# Append a new marks version: exMarks is ex -> {marks source}. Returns it.
proc ::woodpecker::marksAppend {dir exMarks} {
    set ver [expr {[marksLatest [readMarks $dir]] + 1}]
    set path [file join $dir marks.tsv]
    foreach ex [lsort -integer [dict keys $exMarks]] {
        set e [dict get $exMarks $ex]
        set l {}
        foreach m [dict get $e marks] { lappend l [expr {$m eq "" ? "-" : $m}] }
        appendLine $path [list $ver $ex [join $l " "] [dict get $e source]]
    }
    return $ver
}

# Ranges of exercise numbers: "1-500 731 900-902" <-> {1 2 ... 500 731 900 901 902},
# in the given order (a scope may start in the middle of the set).
proc ::woodpecker::rangesParse {text} {
    set out {}
    foreach part [split [string trim $text] " ,"] {
        if {$part eq ""} { continue }
        if {[regexp {^(\d+)-(\d+)$} $part -> a b]} {
            scan $a %d a
            scan $b %d b
            if {$a < 1 || $b < $a} { error "bad range: $part" }
            for {set i $a} {$i <= $b} {incr i} { lappend out $i }
        } elseif {[regexp {^\d+$} $part]} {
            scan $part %d i
            if {$i < 1} { error "bad exercise number: $part" }
            lappend out $i
        } else {
            error "bad range: $part"
        }
    }
    return $out
}

proc ::woodpecker::rangesFormat {list} {
    set out {}
    set a ""
    set b ""
    foreach i $list {
        if {$a ne "" && $i == $b + 1} { set b $i; continue }
        if {$a ne ""} { lappend out [expr {$a == $b ? $a : "$a-$b"}] }
        set a $i
        set b $i
    }
    if {$a ne ""} { lappend out [expr {$a == $b ? $a : "$a-$b"}] }
    return [join $out " "]
}

# log.tsv
proc ::woodpecker::logExercise {dir now cycle session ex result found ms} {
    appendLine [file join $dir log.tsv] [list X $now $cycle $session $ex $result $found $ms]
}

proc ::woodpecker::logSession {dir now cycle session start durMs} {
    appendLine [file join $dir log.tsv] [list S $now $cycle $session $start $durMs]
}

# A change of scope (Decision 8): from cycle `cycle` on, a cycle is the
# exercises `order` ("*" = the whole set) in that order; `days1` is the planned
# length of cycle `from`, halved at every later one.
proc ::woodpecker::logScope {dir now cycle order days1 {from ""}} {
    if {$from eq ""} { set from $cycle }
    appendLine [file join $dir log.tsv] [list C $now $cycle $order $days1 $from]
}

# The log as three lists of dicts: exercises, sessions and scopes.
proc ::woodpecker::readLog {dir {file log.tsv}} {
    set xs {}
    set ss {}
    set cs {}
    foreach row [readLines [file join $dir $file]] {
        switch -- [lindex $row 0] {
            X {
                lassign $row - ts cycle session ex result found ms
                if {![string is integer -strict $ex] || $result ni {clean failed}} { continue }
                lappend xs [dict create ts $ts cycle $cycle session $session ex $ex \
                    result $result found $found ms $ms]
            }
            S {
                lassign $row - ts cycle session start dur
                if {![string is integer -strict $session]} { continue }
                lappend ss [dict create ts $ts cycle $cycle session $session start $start dur $dur]
            }
            C {
                lassign $row - ts cycle order days1 from
                if {![string is integer -strict $cycle] || $cycle < 1} { continue }
                if {[catch { rangesParse [lsearch -all -inline -not -exact $order *] }]} { continue }
                if {![string is integer -strict $days1] || $days1 < 1} { set days1 "" }
                if {![string is integer -strict $from] || $from < 1} { set from $cycle }
                lappend cs [dict create ts $ts cycle $cycle order $order days1 $days1 from $from]
            }
        }
    }
    return [list $xs $ss $cs]
}

# The exercises of cycle `cycle` and its schedule (Decision 8).
#   cs       the C rows of the log; the last one (in log order) whose cycle is
#            at or before `cycle` applies, so the latest decision wins
#   exs      the set's exercise numbers in set order (gaps once a puzzle was
#            deleted from its database; an added one comes at the end)
#   retired  exercises taken out of the set for good (moved, given back)
#   days1    the set's first-cycle days, for a set never narrowed
# A "*" in a row's order stands for the set's other exercises: alone it is the
# whole set, at the end it takes in the puzzles added after the row.
# Returns {order locked days1 from}: the exercises of the cycle in order, the
# set's other exercises (locked out of the inner circle), and the plan: cycle
# k lasts cycleDays(k - from + 1, days1).
proc ::woodpecker::scopeAt {cs cycle exs {retired {}} {days1 28}} {
    set row ""
    foreach c $cs { if {[dict get $c cycle] <= $cycle} { set row $c } }
    set out [dict create days1 $days1 from 1]
    set gone [dict create]
    foreach i $retired { dict set gone $i 1 }
    set spec "*"
    if {$row ne ""} {
        set spec [dict get $row order]
        if {[dict get $row days1] ne ""} { dict set out days1 [dict get $row days1] }
        dict set out from [dict get $row from]
    }
    set want {}
    foreach part $spec {
        lappend want {*}[expr {$part eq "*" ? $exs : [rangesParse $part]}]
    }
    set here [dict create]
    foreach i $exs { dict set here $i 1 }
    set order {}
    set in [dict create]
    foreach i $want {
        if {![dict exists $here $i] || [dict exists $gone $i] || [dict exists $in $i]} { continue }
        lappend order $i
        dict set in $i 1
    }
    set locked {}
    foreach i $exs {
        if {![dict exists $gone $i] && ![dict exists $in $i]} { lappend locked $i }
    }
    # Every exercise of an inner circle was deleted: an empty cycle could never
    # be completed, so the set's other exercises take its place.
    if {![llength $order]} {
        set order $locked
        set locked {}
    }
    return [dict merge $out [dict create order $order locked $locked]]
}

# Planned days of cycle `k` under a scope from ::woodpecker::scopeAt.
proc ::woodpecker::scopeDays {scope k} {
    return [cycleDays [expr {max(1, $k - [dict get $scope from] + 1)}] [dict get $scope days1]]
}

################################################################################
# Resetting the statistics (Decision 9): the log is put aside as a "ring", a
# dated copy in the set's folder, never deleted, and the next reset or a
# restore swaps them.

# The set's rings, newest first: a list of {path day}.
proc ::woodpecker::rings {dir} {
    set out {}
    foreach path [glob -nocomplain -types f -directory $dir ring-*.tsv] {
        if {![regexp {^ring-(\d{4}-\d{2}-\d{2})(?:-(\d+))?\.tsv$} [file tail $path] -> day n]} { continue }
        if {$n eq ""} { set n 1 }
        lappend out [list $path $day $n]
    }
    set out [lsort -decreasing -command {apply {{a b} {
        set c [string compare [lindex $a 1] [lindex $b 1]]
        if {$c} { return $c }
        return [expr {[lindex $a 2] - [lindex $b 2]}]
    }}} $out]
    return [lmap r $out { lrange $r 0 1 }]
}

# Put log.tsv aside as ring-<today>.tsv (-2, -3 ... when taken). A log with
# nothing played (missing, empty, or only a scope row) is not worth a ring: it
# is removed. Returns the ring's path, or "".
proc ::woodpecker::archiveLog {dir now} {
    set log [file join $dir log.tsv]
    if {![file exists $log]} { return "" }
    lassign [readLog $dir] xs ss
    if {![llength $xs] && ![llength $ss]} {
        file delete $log
        return ""
    }
    set day [today $now]
    set ring [file join $dir ring-$day.tsv]
    set n 1
    while {[file exists $ring]} { set ring [file join $dir ring-$day-[incr n].tsv] }
    file rename $log $ring
    return $ring
}

# Start the set again from cycle 1: the log becomes a ring, the exercises and
# their marks stay. `days1`, when given and not the set's own, is the new
# first cycle's length. An inner circle goes with the log (its C rows are
# there); exercises moved or given back stay out (set.tsv). Returns the ring.
proc ::woodpecker::resetLog {dir now {days1 ""} {setDays1 ""}} {
    set ring [archiveLog $dir $now]
    if {[string is integer -strict $days1] && $days1 >= 1 && $days1 ne $setDays1} {
        logScope $dir $now 1 * $days1
    }
    return $ring
}

# Bring back the newest ring as the log; the current log, unless empty,
# becomes a ring in its place, so a second restore undoes the first. Returns
# the restored ring's day, "" when there is none.
proc ::woodpecker::restoreRing {dir now} {
    set rings [rings $dir]
    if {![llength $rings]} { return "" }
    lassign [lindex $rings 0] path day
    set tmp [file join $dir ring-restoring.tmp]
    file rename -force $path $tmp
    if {[catch { archiveLog $dir $now } err]} {
        file rename $tmp $path
        error $err
    }
    file rename $tmp [file join $dir log.tsv]
    return $day
}

################################################################################
# Progress and statistics

# Where the trainee is: the current cycle, the next exercise and how many of
# the cycle's exercises were done before `today`. The cycle is its scope's
# exercises in its order (::woodpecker::scopeAt; the whole set when the log
# has no C row): `next` is the first of them not done in this cycle, `pos`
# its place (1-based) in the cycle, and only they count as done. Returns
#   cycle next pos done doneBefore complete start end n order locked days1 from
# with `n` the exercises of the cycle and `days` its planned length.
# `exs` is the set's exercise numbers in training order: they have gaps once a
# puzzle was deleted from the set's database, so `pos`, not the number, is
# what the session and the plan count.
proc ::woodpecker::progress {xs exs today {cs {}} {retired {}} {days1 28}} {
    set cycle 1
    foreach x $xs { if {[dict get $x cycle] > $cycle} { set cycle [dict get $x cycle] } }
    set scope [scopeAt $cs $cycle $exs $retired $days1]
    set valid [dict create]
    foreach i $exs { dict set valid $i 1 }
    set inScope [dict create]
    foreach i [dict get $scope order] { dict set inScope $i 1 }
    set done [dict create]
    set valid [dict create]
    foreach ex $exs { dict set valid $ex 1 }
    set before 0
    set firstDay ""
    set lastDay ""
    foreach x $xs {
        if {[dict get $x cycle] != $cycle} { continue }
        set ex [dict get $x ex]
        if {![dict exists $valid $ex]} { continue }
        set day [today [dict get $x ts]]
        if {$firstDay eq ""} { set firstDay $day }
        set lastDay $day
        if {![dict exists $inScope $ex] || [dict exists $done $ex]} { continue }
        dict set done $ex 1
        if {$day ne $today} { incr before }
    }
    set n [llength $exs]
    set count [dict size $done]
    set size [llength [dict get $scope order]]
    set out [dict merge $scope [dict create cycle $cycle done $count doneBefore $before \
        start $firstDay end $lastDay n $size days [scopeDays $scope $cycle]]]
    if {$count >= $size && $size > 0} {
        return [dict merge $out [dict create next 0 pos 0 complete 1]]
    }
    set next 0
    set pos 0
    foreach i [dict get $scope order] {
        incr pos
        if {![dict exists $done $i]} { set next $i; break }
    }
    return [dict merge $out [dict create next $next pos $pos complete 0]]
}

# Narrowing a set to an inner circle (Decision 8): the first `size` exercises
# of the current cycle's order become the cycle, the others are locked.
#   xs cs     the log's exercise and scope rows
#   exs       the set's exercise numbers; retired, days1 as for scopeAt
# The circle starts at once when the current cycle still has some of it to
# do; when the cycle is over (or the circle is already done in it), the next
# cycle is the circle's first. Returns {cycle order locked from daysLeft}: the
# C row to write (cycle, order, from) and whether the days asked for are the
# days left of the running cycle (daysLeft 1) or the next cycle's (0).
proc ::woodpecker::circlePlan {xs cs exs retired days1 size today} {
    set pr [progress $xs $exs $today $cs $retired $days1]
    set cycle [dict get $pr cycle]
    set base [dict get $pr order]
    set started [expr {[dict get $pr start] ne ""}]
    if {[dict get $pr complete]} {
        incr cycle
        set base [dict get [scopeAt $cs $cycle $exs $retired $days1] order]
        set started 0
    }
    if {![string is integer -strict $size] || $size < 1 || $size >= [llength $base]} {
        error "an inner circle needs between 1 and [expr {[llength $base] - 1}] exercises"
    }
    set order [lrange $base 0 [expr {$size - 1}]]
    set locked [lrange $base $size end]
    set from $cycle
    set daysLeft $started
    if {$started} {
        # Already done in this cycle: the circle may be complete at once.
        set done [dict create]
        foreach x $xs { if {[dict get $x cycle] == $cycle} { dict set done [dict get $x ex] 1 } }
        set left 0
        foreach i $order { if {![dict exists $done $i]} { incr left } }
        if {!$left} {
            set from [expr {$cycle + 1}]
            set daysLeft 0
        }
    }
    return [dict create cycle $cycle order $order locked $locked from $from daysLeft $daysLeft]
}

# Opening the locked exercises again, in the same set. In every cycle that
# has not begun they come first, then the circle. In a cycle under way the
# circle is finished first and the opened exercises follow it in the same
# cycle; from the next cycle on they come first. Returns
#   cycle     the cycle the C row starts at
#   order     that cycle's order
#   then      "" or, for a cycle under way, the order from cycle+1 on
#   opened    the exercises unlocked
#   daysLeft  1 when the days asked for are the days left of the running
#             cycle, 0 when they are the length of a cycle not begun
# An error when nothing is locked.
proc ::woodpecker::openPlan {xs cs exs retired days1 today} {
    set pr [progress $xs $exs $today $cs $retired $days1]
    set cycle [dict get $pr cycle]
    set daysLeft [expr {[dict get $pr start] ne ""}]
    if {[dict get $pr complete]} {
        incr cycle
        set daysLeft 0
    }
    set scope [scopeAt $cs $cycle $exs $retired $days1]
    set opened [dict get $scope locked]
    if {![llength $opened]} { error "no exercise is locked" }
    set first [concat $opened [dict get $scope order]]
    if {$daysLeft} {
        return [dict create cycle $cycle order [concat [dict get $scope order] $opened] then $first \
            opened $opened daysLeft 1]
    }
    return [dict create cycle $cycle order $first then "" opened $opened daysLeft 0]
}

# One exercise row's points under a marks table (ex -> {marks source}).
proc ::woodpecker::rowScore {x exMeta marksTable} {
    set ex [dict get $x ex]
    set rating ""
    if {[dict exists $exMeta $ex]} { set rating [dict get $exMeta $ex rating] }
    set marks {}
    set rated 0
    if {[dict exists $marksTable $ex]} {
        set marks [dict get $marksTable $ex marks]
        set rated 1
    }
    set found [split [dict get $x found] ""]
    set s [score $marks $found [dict get $x result] [weight $rating]]
    dict set s rated $rated
    return $s
}

# Per-session statistics, the user's record sheet: date, duration, exercises,
# points and percentage. Durations come from the S row when the session was
# closed, otherwise from the sum of its exercises' active times.
proc ::woodpecker::sessionStats {xs ss exMeta marksTable} {
    set by [dict create]
    foreach x $xs {
        # A row for an exercise no longer in the set does not count: its
        # number has no marks or rating to score it with.
        if {![dict exists $exMeta [dict get $x ex]]} { continue }
        set id [dict get $x session]
        if {![dict exists $by $id]} {
            dict set by $id [dict create session $id cycle [dict get $x cycle] \
                date [today [dict get $x ts]] exercises 0 points 0.0 max 0.0 ms 0 \
                clean 0 failed 0 unrated 0 dur ""]
        }
        set s [rowScore $x $exMeta $marksTable]
        dict with by $id {
            incr exercises
            set points [expr {$points + [dict get $s points]}]
            set max [expr {$max + [dict get $s max]}]
            if {[string is integer -strict [dict get $x ms]]} { incr ms [dict get $x ms] }
            incr [dict get $x result]
            if {![dict get $s rated]} { incr unrated }
        }
    }
    foreach s $ss {
        set id [dict get $s session]
        if {[dict exists $by $id] && [string is integer -strict [dict get $s dur]]} {
            dict set by $id dur [dict get $s dur]
            dict set by $id date [today [dict get $s start]]
        }
    }
    set out {}
    foreach id [lsort -integer [dict keys $by]] {
        set r [dict get $by $id]
        if {[dict get $r dur] eq ""} { dict set r dur [dict get $r ms] }
        set m [dict get $r max]
        dict set r pct [expr {$m > 0 ? 100.0 * [dict get $r points] / $m : 0.0}]
        lappend out $r
    }
    return $out
}

# Per-cycle statistics: first and last day, exercises, solving time (sum of the
# exercises' active times - the book's "total solving time"), results, points.
proc ::woodpecker::cycleStats {xs exMeta marksTable} {
    set by [dict create]
    foreach x $xs {
        if {![dict exists $exMeta [dict get $x ex]]} { continue }
        set c [dict get $x cycle]
        set day [today [dict get $x ts]]
        if {![dict exists $by $c]} {
            dict set by $c [dict create cycle $c start $day end $day exercises 0 ms 0 \
                clean 0 failed 0 points 0.0 max 0.0]
        }
        set s [rowScore $x $exMeta $marksTable]
        dict with by $c {
            set end $day
            incr exercises
            if {[string is integer -strict [dict get $x ms]]} { incr ms [dict get $x ms] }
            incr [dict get $x result]
            set points [expr {$points + [dict get $s points]}]
            set max [expr {$max + [dict get $s max]}]
        }
    }
    set out {}
    foreach c [lsort -integer [dict keys $by]] {
        set r [dict get $by $c]
        set m [dict get $r max]
        dict set r pct [expr {$m > 0 ? 100.0 * [dict get $r points] / $m : 0.0}]
        lappend out $r
    }
    return $out
}

# Exercise by exercise against the previous cycle, for the session summary:
# the given exercises of `cycle` compared with the same exercises of cycle-1.
#   faster slower newErrors fixed  (an error = result other than clean)
proc ::woodpecker::compareCycles {xs cycle exList} {
    set prev [dict create]
    set cur [dict create]
    foreach x $xs {
        if {[dict get $x cycle] == $cycle - 1} { dict set prev [dict get $x ex] $x }
        if {[dict get $x cycle] == $cycle} { dict set cur [dict get $x ex] $x }
    }
    set out [dict create faster 0 slower 0 newErrors 0 fixed 0 compared 0]
    foreach ex $exList {
        if {![dict exists $prev $ex] || ![dict exists $cur $ex]} { continue }
        set a [dict get $prev $ex]
        set b [dict get $cur $ex]
        dict incr out compared
        if {[dict get $b ms] < [dict get $a ms]} { dict incr out faster } elseif {[dict get $b ms] > [dict get $a ms]} { dict incr out slower }
        set errA [expr {[dict get $a result] ne "clean"}]
        set errB [expr {[dict get $b result] ne "clean"}]
        if {$errB && !$errA} { dict incr out newErrors }
        if {$errA && !$errB} { dict incr out fixed }
    }
    return $out
}

# Rest days before a new cycle may start: the previous cycle's last day plus
# the set's rest days. Returns the first allowed day.
proc ::woodpecker::nextCycleDay {lastDay restDays} {
    return [ymd [expr {[dayNum $lastDay] + $restDays + 1}]]
}

# Milliseconds as "1h 04m", "12m 30s" or "45s".
proc ::woodpecker::fmtDuration {ms} {
    if {![string is integer -strict $ms]} { return "-" }
    set s [expr {$ms / 1000}]
    if {$s >= 3600} { return [format "%dh %02dm" [expr {$s / 3600}] [expr {($s % 3600) / 60}]] }
    if {$s >= 60} { return [format "%dm %02ds" [expr {$s / 60}] [expr {$s % 60}]] }
    return "${s}s"
}

################################################################################
# JSON (the Lichess replies): objects become dicts, arrays lists, true/false 1/0,
# null "". Enough for the puzzle API; not a general-purpose validator.

proc ::woodpecker::jsonParse {text} {
    set i 0
    set v [jsonValue $text i]
    jsonSpace $text i
    if {$i < [string length $text]} { error "trailing data in JSON at $i" }
    return $v
}

proc ::woodpecker::jsonSpace {text iVar} {
    upvar 1 $iVar i
    while {$i < [string length $text] && [string is space [string index $text $i]]} { incr i }
}

proc ::woodpecker::jsonValue {text iVar} {
    upvar 1 $iVar i
    jsonSpace $text i
    set c [string index $text $i]
    switch -- $c {
        "\{" {
            incr i
            set d [dict create]
            jsonSpace $text i
            if {[string index $text $i] eq "\}"} { incr i; return $d }
            while 1 {
                jsonSpace $text i
                if {[string index $text $i] ne "\""} { error "JSON key expected at $i" }
                set k [jsonString $text i]
                jsonSpace $text i
                if {[string index $text $i] ne ":"} { error "JSON ':' expected at $i" }
                incr i
                dict set d $k [jsonValue $text i]
                jsonSpace $text i
                set c [string index $text $i]
                incr i
                if {$c eq "\}"} { return $d }
                if {$c ne ","} { error "JSON ',' or '\}' expected at [expr {$i - 1}]" }
            }
        }
        "\[" {
            incr i
            set l {}
            jsonSpace $text i
            if {[string index $text $i] eq "\]"} { incr i; return $l }
            while 1 {
                lappend l [jsonValue $text i]
                jsonSpace $text i
                set c [string index $text $i]
                incr i
                if {$c eq "\]"} { return $l }
                if {$c ne ","} { error "JSON ',' or '\]' expected at [expr {$i - 1}]" }
            }
        }
        "\"" { return [jsonString $text i] }
        "t" { if {[string range $text $i [expr {$i + 3}]] eq "true"} { incr i 4; return 1 } }
        "f" { if {[string range $text $i [expr {$i + 4}]] eq "false"} { incr i 5; return 0 } }
        "n" { if {[string range $text $i [expr {$i + 3}]] eq "null"} { incr i 4; return "" } }
        default {
            if {[regexp {\A-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?} [string range $text $i [expr {$i + 40}]] num]} {
                incr i [string length $num]
                return $num
            }
        }
    }
    error "unexpected JSON at $i"
}

proc ::woodpecker::jsonString {text iVar} {
    upvar 1 $iVar i
    incr i
    set out ""
    set n [string length $text]
    while {$i < $n} {
        set c [string index $text $i]
        if {$c eq "\""} { incr i; return $out }
        if {$c eq "\\"} {
            incr i
            set e [string index $text $i]
            switch -- $e {
                n { append out "\n" }
                t { append out "\t" }
                r { append out "\r" }
                b { append out "\b" }
                f { append out "\f" }
                u {
                    set hex [string range $text [expr {$i + 1}] [expr {$i + 4}]]
                    append out [format %c [scan $hex %x]]
                    incr i 4
                }
                default { append out $e }
            }
            incr i
            continue
        }
        append out $c
        incr i
    }
    error "unterminated JSON string"
}

################################################################################
# Moves: SAN <-> UCI on ::chessboard, and the start position of a Lichess puzzle.

proc ::woodpecker::startFen {} {
    return "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
}

proc ::woodpecker::sanToUci {pos san} {
    set s [string map {+ "" # "" ! "" ? ""} $san]
    set s [string map {0-0-0 O-O-O 0-0 O-O} $s]
    set side [dict get $pos side]
    set legal [::chessboard::legalMoves $pos]
    if {$s eq "O-O" || $s eq "O-O-O"} {
        set r [expr {$side eq "w" ? 1 : 8}]
        set to [expr {$s eq "O-O" ? "g$r" : "c$r"}]
        if {"e$r$to" in $legal} { return "e$r$to" }
        error "illegal castling $san"
    }
    set promo ""
    if {[regexp {^(.*?)=?([QRBNqrbn])$} $s -> rest p] && [regexp {[a-h][18]$} $rest]} {
        set s $rest
        set promo [string tolower $p]
    }
    set piece P
    if {[string match {[KQRBN]*} $s]} { set piece [string index $s 0]; set s [string range $s 1 end] }
    set s [string map {x "" - ""} $s]
    set dest [string range $s end-1 end]
    set dis [string range $s 0 end-2]
    set board [dict get $pos board]
    set hits {}
    foreach m $legal {
        if {[string range $m 2 3] ne $dest} continue
        if {[string range $m 4 end] ne $promo} continue
        set from [string range $m 0 1]
        if {[string toupper [lindex $board [::chessboard::sqIndex $from]]] ne $piece} continue
        set ok 1
        foreach ch [split $dis ""] { if {[string first $ch $from] < 0} { set ok 0 } }
        if {$ok} { lappend hits $m }
    }
    if {[llength $hits] != 1} { error "SAN '$san' does not name one legal move" }
    return [lindex $hits 0]
}

proc ::woodpecker::uciToSan {pos uci} {
    set legal [::chessboard::legalMoves $pos]
    if {$uci ni $legal} { error "illegal move $uci" }
    set board [dict get $pos board]
    set from [::chessboard::sqIndex [string range $uci 0 1]]
    set to [::chessboard::sqIndex [string range $uci 2 3]]
    set piece [string toupper [lindex $board $from]]
    set after [::chessboard::makeMove $pos $uci]
    set suffix ""
    if {[::chessboard::inCheck $after [dict get $after side]]} {
        set suffix [expr {[llength [::chessboard::legalMoves $after]] ? "+" : "#"}]
    }
    if {$piece eq "K" && abs(($to % 8) - ($from % 8)) == 2} {
        return "[expr {($to % 8) > ($from % 8) ? "O-O" : "O-O-O"}]$suffix"
    }
    set capture [expr {[::movelabels::captureVictim $pos $uci] ne ""}]
    set dest [string range $uci 2 3]
    if {$piece eq "P"} {
        set san [expr {$capture ? "[string index $uci 0]x$dest" : $dest}]
        if {[string length $uci] > 4} { append san "=[string toupper [string index $uci 4]]" }
        return "$san$suffix"
    }
    # Disambiguation: other pieces of the same kind that can reach the square.
    set others {}
    foreach m $legal {
        if {$m eq $uci || [string range $m 2 3] ne $dest} continue
        set f [::chessboard::sqIndex [string range $m 0 1]]
        if {[string toupper [lindex $board $f]] eq $piece} { lappend others [string range $m 0 1] }
    }
    set dis ""
    if {[llength $others]} {
        set file [string index $uci 0]
        set rank [string index $uci 1]
        set sameFile 0
        set sameRank 0
        foreach o $others {
            if {[string index $o 0] eq $file} { set sameFile 1 }
            if {[string index $o 1] eq $rank} { set sameRank 1 }
        }
        if {!$sameFile} { set dis $file } elseif {!$sameRank} { set dis $rank } else { set dis "$file$rank" }
    }
    return "$piece$dis[expr {$capture ? "x" : ""}]$dest$suffix"
}

# The position after the first `plies` SAN moves of a game from the start.
# Returns {fen lastUci}: the FEN, and the UCI of the last move played.
proc ::woodpecker::replaySans {sans plies} {
    set pos [::chessboard::fromFen [startFen]]
    set last ""
    set i 0
    foreach san $sans {
        if {$i >= $plies} break
        set last [sanToUci $pos $san]
        set pos [::chessboard::makeMove $pos $last]
        incr i
    }
    if {$i < $plies} { error "the game has only $i moves" }
    return [list [::chessboard::toFen $pos] $last]
}

# One Lichess puzzle (a dict from the batch reply: {puzzle {...} game {...}}) as
# the trainer's exercise: id rating plays themes fen lastMove solution gameId
# white black. The batch reply has no FEN: the position is the game after
# initialPly + 1 moves (the opponent's last move is part of the PGN).
proc ::woodpecker::lichessExercise {entry} {
    set p [dict get $entry puzzle]
    set g [dict get $entry game]
    set initial [dict get $p initialPly]
    lassign [replaySans [dict get $g pgn] [expr {$initial + 1}]] fen last
    set white ""; set black ""
    if {[dict exists $g players]} {
        foreach pl [dict get $g players] {
            set nm [expr {[dict exists $pl name] ? [dict get $pl name] : "?"}]
            if {[dict exists $pl color] && [dict get $pl color] eq "black"} { set black $nm } else { set white $nm }
        }
    }
    return [dict create id [dict get $p id] rating [dict get $p rating] \
        plays [expr {[dict exists $p plays] ? [dict get $p plays] : ""}] \
        themes [expr {[dict exists $p themes] ? [dict get $p themes] : {}}] \
        fen $fen lastMove $last solution [dict get $p solution] \
        gameId [expr {[dict exists $g id] ? [dict get $g id] : ""}] white $white black $black]
}

# The side the trainee plays in a puzzle: the side to move in its FEN.
proc ::woodpecker::fenSide {fen} { return [lindex [split $fen] 1] }

# A PGN game for one exercise: the position to solve as FEN, the solution as the
# main line. `tags` is a list of {name value} added after the seven roster tags.
proc ::woodpecker::pgnGame {fen solution event round white black site tags} {
    set pos [::chessboard::fromFen $fen]
    set out ""
    foreach {k v} [list Event $event Site $site Date "????.??.??" Round $round \
            White $white Black $black Result "*"] {
        append out "\[$k \"[string map {\\ \\\\ \" \\\"} $v]\"\]\n"
    }
    append out "\[SetUp \"1\"\]\n\[FEN \"$fen\"\]\n"
    foreach t $tags {
        lassign $t k v
        append out "\[$k \"[string map {\\ \\\\ \" \\\"} $v]\"\]\n"
    }
    append out "\n"
    set moves {}
    set first 1
    foreach uci $solution {
        set num [dict get $pos full]
        if {[dict get $pos side] eq "w"} {
            lappend moves "$num."
        } elseif {$first} {
            lappend moves "$num..."
        }
        set first 0
        lappend moves [uciToSan $pos $uci]
        set pos [::chessboard::makeMove $pos $uci]
    }
    lappend moves "*"
    append out [join $moves " "] "\n\n"
    return $out
}

# Exercises: the extra columns a set keeps so a session never opens the
# database: fen, solution (UCI, space separated), lastMove.
proc ::woodpecker::exerciseRow {ex game pid rating fen solution lastMove} {
    set n [expr {([llength $solution] + 1) / 2}]
    return [dict create game $game puzzleId $pid rating $rating nmoves $n \
        fen $fen solution $solution lastMove $lastMove]
}

# The solution as numbered SAN with the solver's marks: "29... Qxe2+! 30. Rf2
# Qxe5". `marks` has one entry per solver move ({} when unrated); `from` is the
# first ply to include (0 = the whole line).
proc ::woodpecker::lineText {fen solution marks {from 0}} {
    set pos [::chessboard::fromFen $fen]
    set out {}
    set i 0
    set first 1
    foreach uci $solution {
        set san [uciToSan $pos $uci]
        if {$i % 2 == 0} {
            set m [lindex $marks [expr {$i / 2}]]
            if {$m ne "" && $m ne "-"} { append san $m }
        }
        if {$i >= $from} {
            set num [dict get $pos full]
            if {[dict get $pos side] eq "w"} {
                lappend out "$num. $san"
            } elseif {$first} {
                lappend out "$num... $san"
            } else {
                lappend out $san
            }
            set first 0
        }
        set pos [::chessboard::makeMove $pos $uci]
        incr i
    }
    return [join $out " "]
}

# Castling entered as king-takes-rook is the same move as the king's two-square
# step; anything else compares as written (lower case promotion letter).
proc ::woodpecker::sameMove {a b} {
    set a [string tolower $a]
    set b [string tolower $b]
    if {$a eq $b} { return 1 }
    set map {e1h1 e1g1 e1a1 e1c1 e8h8 e8g8 e8a8 e8c8}
    if {[dict exists $map $a]} { set a [dict get $map $a] }
    if {[dict exists $map $b]} { set b [dict get $map $b] }
    return [expr {$a eq $b}]
}

################################################################################
# Difficulty presets: shares of the Lichess levels, relative to the trainee's
# puzzle rating. The book is mostly Intermediate with some Easy exercises
# (222 + 762, p. 11) and keeps the Advanced ones out of the main plan; the
# standard preset follows that proportion.
#   automatic  simple tactics until they are seen at once
#   standard   about a quarter easier, the rest around one's level
#   challenge  around and above one's level
#   tough      mostly well above one's level
proc ::woodpecker::presets {} {
    return {
        automatic {easiest 30 easier 50 normal 20}
        standard  {easier 25 normal 60 harder 15}
        challenge {normal 40 harder 45 hardest 15}
        tough     {normal 15 harder 40 hardest 45}
    }
}

proc ::woodpecker::presetShares {name} {
    set p [presets]
    if {![dict exists $p $name]} { error "unknown preset '$name'" }
    return [dict get $p $name]
}

################################################################################
# Difficulty without a Lichess token.
#
# Lichess picks puzzles around the solver's rating plus the level's delta
# (lila, modules/puzzle/src/main/PuzzleDifficulty.scala: easiest -600, easier
# -300, normal 0, harder +300, hardest +600; PuzzlePath.scala takes the range
# rating +- (100 + |1500 - rating| / 4)). Without a token the rating is 1500
# (Lichess API spec). Given the rating the trainee states, each level's target
# band is emulated: the anonymous levels nearest to it are fetched and only the
# puzzles inside the band are kept - slower, since the rest is discarded.

proc ::woodpecker::levelDelta {level} {
    return [dict get {easiest -600 easier -300 normal 0 harder 300 hardest 600} $level]
}

proc ::woodpecker::levelWindow {centre} {
    return [expr {100 + abs(1500 - $centre) / 4}]
}

# For one level and the trainee's rating: {centre window sources}, where
# sources are the anonymous levels (centred on 1500 + delta) to fetch from,
# nearest first: the two that bracket the centre, or the nearest one when the
# centre is outside what the anonymous levels reach.
proc ::woodpecker::anonPlan {rating level} {
    set centre [expr {$rating + [levelDelta $level]}]
    set dist {}
    foreach l {easiest easier normal harder hardest} {
        lappend dist [list $l [expr {abs(1500 + [levelDelta $l] - $centre)}]]
    }
    set dist [lsort -integer -index 1 $dist]
    set first [lindex $dist 0 0]
    set sources [list $first]
    set second [lindex $dist 1 0]
    set c1 [expr {1500 + [levelDelta $first]}]
    set c2 [expr {1500 + [levelDelta $second]}]
    # Only a level on the other side of the centre widens the choice.
    if {($c1 - $centre) * ($c2 - $centre) < 0} { lappend sources $second }
    return [dict create centre $centre window [levelWindow $centre] sources $sources]
}
