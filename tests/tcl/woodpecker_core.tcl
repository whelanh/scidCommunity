#!/usr/bin/env tclsh
# Woodpecker trainer core: scoring, attempts, marks, schedule, records.

set fails 0
set checks 0
proc check {name cond} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} { incr fails; puts "FAIL $name" }
}
proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} { incr fails; puts "FAIL $name -- got '$got' want '$want'" }
}
proc near {a b {eps 1e-9}} { return [expr {abs($a - $b) < $eps}] }

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools woodpecker_core.tcl]

# ---------------------------------------------------------------- weight ----
checkEq "a 1500 puzzle weighs 1" [::woodpecker::weight 1500] 1.0
check "a 2100 puzzle weighs 1.4" {[near [::woodpecker::weight 2100] 1.4]}
checkEq "the weight is clamped below" [::woodpecker::weight 400] 0.5
checkEq "the weight is clamped above" [::woodpecker::weight 4000] 2.0
checkEq "no rating (a book) weighs 1" [::woodpecker::weight ""] 1.0
checkEq "a non-number weighs 1" [::woodpecker::weight abc] 1.0

# ----------------------------------------------------------------- score ----
# The plan's example: a line with one ! and one !!.
set m {"!" "!!"}
set s [::woodpecker::score $m {1 1} clean]
checkEq "perfect line: V + 1 + 2 + C" [dict get $s points] 5.0
checkEq "its maximum" [dict get $s max] 5.0
set s [::woodpecker::score $m {1 1} second]
checkEq "one error, then completed: V*0.75 + bonuses" [dict get $s points] 3.75
set s [::woodpecker::score {"!!" "!"} {1 0} failed]
checkEq "failed after the !!: the bonus is kept, minus the malus" [dict get $s points] 1.5
set s [::woodpecker::score $m {0 0} failed]
checkEq "failed with nothing found is 0, never negative" [dict get $s points] 0.0
set s [::woodpecker::score {"" "!" ""} {1 1 1} clean 1.4]
check "the weight scales points" {[near [dict get $s points] 4.2]}
check "... and the maximum" {[near [dict get $s max] 4.2]}
set s [::woodpecker::score {"!" ""} {1 0} failed 2.0]
check "the weight scales the malus too" {[near [dict get $s points] 1.0]}
set s [::woodpecker::score {} {1 1} clean]
checkEq "an unrated exercise is worth the line only" [list [dict get $s points] [dict get $s max]] {2.0 2.0}
set s [::woodpecker::score {- "!"} {1 1} clean]
checkEq "'-' is no mark" [dict get $s points] 3.0
check "an unknown result is refused" {[catch {::woodpecker::score {} {} bogus}]}

# --------------------------------------------------------------- attempts ----
set st [::woodpecker::exStart 3]
lassign [::woodpecker::exAnswer $st 1] st what
checkEq "a right move continues" $what continue
lassign [::woodpecker::exAnswer $st 1] st what
lassign [::woodpecker::exAnswer $st 1] st what
checkEq "the last right move solves" $what solved
checkEq "no error is clean" [dict get $st result] clean
checkEq "all found" [::woodpecker::foundString $st] 111
check "a finished exercise takes no more answers" {[catch {::woodpecker::exAnswer $st 1}]}

set st [::woodpecker::exStart 2]
lassign [::woodpecker::exAnswer $st 1] st what
lassign [::woodpecker::exAnswer $st 0] st what
checkEq "the first error asks again" $what retry
lassign [::woodpecker::exAnswer $st 1] st what
checkEq "right on the second attempt solves" $what solved
checkEq "... as a second-attempt result" [dict get $st result] second
checkEq "... and the move counts as found" [::woodpecker::foundString $st] 11

set st [::woodpecker::exStart 3]
lassign [::woodpecker::exAnswer $st 0] st what
lassign [::woodpecker::exAnswer $st 1] st what
lassign [::woodpecker::exAnswer $st 0] st what
checkEq "the second error fails the exercise" $what failed
checkEq "failed result" [dict get $st result] failed
checkEq "the moves before the failure are kept" [::woodpecker::foundString $st] 100

# ------------------------------------------------------------------ marks ----
set base [dict create label best isBest 1 hanging 0 trivial 1 pvAfter {a b} played e2e4 shallow e2e4 quiet 0]
checkEq "an obvious forcing move earns nothing" [::woodpecker::markFor $base] ""
checkEq "a move the engine dislikes earns nothing" [::woodpecker::markFor [dict merge $base {label mistake quiet 1}]] ""
checkEq "a sound sacrifice is !!" [::woodpecker::markFor [dict merge $base {hanging 3 trivial 0}]] "!!"
checkEq "a sacrifice that is traded back is not !!" [::woodpecker::markFor [dict merge $base {hanging 3 trivial 1}]] ""
checkEq "a sacrifice needs a line to prove it" [::woodpecker::markFor [dict merge $base {hanging 3 trivial 0 pvAfter {}}]] ""
checkEq "!! needs the engine's own move" [::woodpecker::markFor [dict merge $base {hanging 3 trivial 0 isBest 0 label excellent}]] ""
checkEq "a quiet move is !" [::woodpecker::markFor [dict merge $base {quiet 1}]] "!"
checkEq "a move the short search misses is !" [::woodpecker::markFor [dict merge $base {shallow d2d4}]] "!"
checkEq "excellent (an alternative mate) can still be !" [::woodpecker::markFor [dict merge $base {label excellent isBest 0 quiet 1}]] "!"

# Real board: Lichess puzzle 8Af02, 34.Rxg7+! Qxg7 35.Qd8+ Qf8 36.Qxc7.
set fen {3r2k1/2rq2pp/p3pQ2/1p6/1P6/P5RP/2p3P1/2R4K w - - 3 34}
set f [::woodpecker::moveFacts $fen g3g7 {d7g7 f6d8 g7f8 d8c7}]
checkEq "Rxg7+ captures" [dict get $f capture] 1
checkEq "Rxg7+ checks" [dict get $f check] 1
checkEq "Rxg7+ is not quiet" [dict get $f quiet] 0
check "Rxg7+ leaves material en prise" {[dict get $f hanging] >= 2}
checkEq "and the line does not just trade back" [dict get $f trivial] 0
checkEq "so it is !!" [::woodpecker::markFor [dict merge [dict create label best isBest 1 \
    pvAfter {d7g7} played g3g7 shallow g3g7] $f]] "!!"
# Lichess puzzle XypwM, 26...Re5+ : a check, no capture.
set f [::woodpecker::moveFacts {8/p1p3k1/2p3p1/6Kp/4rR2/1P2r3/P1P3PP/5R2 b - - 3 26} e4e5 {}]
checkEq "Re5+ is a check, not a capture" [list [dict get $f capture] [dict get $f check] [dict get $f quiet]] {0 1 0}
checkEq "with no line nothing is proven" [dict get $f trivial] 1
set f [::woodpecker::moveFacts {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1} a1a7 {}]
checkEq "a rook lift is quiet" [dict get $f quiet] 1

checkEq "a back-rank mate is a mate" [::woodpecker::isMateMove {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1} a1a8] 1
checkEq "a rook lift is not" [::woodpecker::isMateMove {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1} a1a7] 0
checkEq "an illegal move is not" [::woodpecker::isMateMove {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1} a1h8] 0

# ------------------------------------------------------------------ dates ----
set d [::woodpecker::dayNum 2026-11-17]
checkEq "a day round-trips" [::woodpecker::ymd $d] 2026-11-17
checkEq "days are consecutive" [::woodpecker::ymd [expr {$d + 15}]] 2026-12-02
checkEq "across a DST change" [expr {[::woodpecker::dayNum 2026-03-30] - [::woodpecker::dayNum 2026-03-28]}] 2

# --------------------------------------------------------------- schedule ----
checkEq "cycle lengths halve" [lmap k {1 2 3 4 5 6 7} {::woodpecker::cycleDays $k 28}] {28 14 7 4 2 1 1}
checkEq "a one-day cycle stays one day" [::woodpecker::cycleDays 3 1] 1

# 600 exercises in 28 days from 2026-11-01: base quota 22, cap 33.
set p [::woodpecker::plan 600 28 2026-11-01 0 2026-11-01]
checkEq "day one: base quota" [list [dict get $p quota] [dict get $p status] [dict get $p deadline]] {22 on_track 2026-11-28}
set p [::woodpecker::plan 600 28 2026-11-01 22 2026-11-03]
checkEq "one missed day raises the quota a little" [list [dict get $p quota] [dict get $p status] [dict get $p slip]] {23 quota_raised 0}
set p [::woodpecker::plan 600 28 2026-11-01 154 2026-11-15]
checkEq "a missed week is absorbed by the quota" [list [dict get $p quota] [dict get $p status] [dict get $p deadline]] {32 quota_raised 2026-11-28}
set p [::woodpecker::plan 600 28 2026-11-01 154 2026-11-22]
checkEq "two missed weeks move the deadline" [list [dict get $p status] [dict get $p deadline] [dict get $p slip]] {deadline_moved 2026-12-05 7}
check "... and keep the quota within the cap" {[dict get $p quota] <= 33}
set p [::woodpecker::plan 600 28 2026-11-01 154 2026-12-20]
checkEq "the deadline never goes past twice the plan" [list [dict get $p status] [dict get $p deadline]] {over_stretch 2026-12-26}
checkEq "... so the quota rises instead" [dict get $p quota] 64
set p [::woodpecker::plan 600 28 2026-11-01 154 2027-01-10]
checkEq "past the stretch limit the rest is due today" [list [dict get $p deadline] [dict get $p quota]] {2027-01-10 446}
set p [::woodpecker::plan 600 28 2026-11-01 600 2026-11-20]
checkEq "a finished cycle has no quota" [list [dict get $p status] [dict get $p quota]] {done 0}
set p [::woodpecker::plan 10 28 2026-11-01 0 2026-11-01]
checkEq "a tiny set: one a day" [dict get $p quota] 1
checkEq "rest before the next cycle" [::woodpecker::nextCycleDay 2026-11-28 1] 2026-11-30

# ------------------------------------------------------------------ files ----
set tmp [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] wp_core_[pid]]
file delete -force $tmp
file mkdir $tmp

::woodpecker::writeMeta $tmp [dict create name "Set\tone" source lichess days1 28]
set meta [::woodpecker::readMeta $tmp]
checkEq "settings round-trip, tabs cleaned" [dict get $meta name] "Set one"
checkEq "settings keep values" [dict get $meta days1] 28

set exs [dict create \
    1 [dict create game 1 puzzleId aaa rating 1500 nmoves 2] \
    2 [dict create game 2 puzzleId bbb rating 2100 nmoves 1] \
    3 [dict create game 3 puzzleId "" rating "" nmoves 1]]
::woodpecker::writeExercises $tmp $exs
set back [::woodpecker::readExercises $tmp]
checkEq "exercises round-trip" [dict get $back 2 rating] 2100
checkEq "an empty rating survives" [dict get $back 3 rating] ""

checkEq "no marks yet" [::woodpecker::marksLatest [::woodpecker::readMarks $tmp]] 0

# Two sessions of cycle 1, one of cycle 2. Times are seconds.
set t0 [clock scan "2026-11-01 10:00" -format "%Y-%m-%d %H:%M"]
::woodpecker::logExercise $tmp $t0 1 1 1 clean 11 30000
::woodpecker::logExercise $tmp [expr {$t0 + 60}] 1 1 2 failed 0 50000
::woodpecker::logSession $tmp [expr {$t0 + 120}] 1 1 $t0 120000
::woodpecker::logExercise $tmp [expr {$t0 + 86400}] 1 2 3 second 1 20000
::woodpecker::logExercise $tmp [expr {$t0 + 2*86400}] 2 3 1 clean 11 10000
set f [open [file join $tmp log.tsv] a]; puts $f "X\tbroken"; puts $f "garbage line"; close $f
lassign [::woodpecker::readLog $tmp] xs ss
checkEq "malformed log lines are skipped" [llength $xs] 4
checkEq "session rows are read" [llength $ss] 1

set pr [::woodpecker::progress $xs 3 2026-11-03]
checkEq "cycle 2 has started" [dict get $pr cycle] 2
checkEq "the next exercise is 2" [dict get $pr next] 2
checkEq "today's exercises do not count as before" [dict get $pr doneBefore] 0
set pr [::woodpecker::progress [lrange $xs 0 2] 3 2026-11-02]
checkEq "cycle 1 complete" [list [dict get $pr complete] [dict get $pr end]] {1 2026-11-02}
set pr [::woodpecker::progress [lrange $xs 0 1] 3 2026-11-02]
checkEq "mid-cycle: next and before" [list [dict get $pr next] [dict get $pr doneBefore] [dict get $pr start]] {3 2 2026-11-01}
set pr [::woodpecker::progress {} 3 2026-11-02]
checkEq "an empty log starts at 1" [list [dict get $pr cycle] [dict get $pr next] [dict get $pr done]] {1 1 0}

# Unrated: exercise 1 clean = 2, ex 2 failed = 0 (max 2*1.4), ex 3 second = 0.75.
set table [::woodpecker::marksAt [::woodpecker::readMarks $tmp] 0]
set st [::woodpecker::sessionStats $xs $ss $back $table]
checkEq "three sessions" [llength $st] 3
set s1 [lindex $st 0]
checkEq "session 1: date, exercises, closed duration" [list [dict get $s1 date] [dict get $s1 exercises] [dict get $s1 dur]] {2026-11-01 2 120000}
check "session 1 points unrated" {[near [dict get $s1 points] 2.0] && [near [dict get $s1 max] [expr {2.0 + 2.8}]]}
checkEq "session 1 counts unrated exercises" [dict get $s1 unrated] 2
set s2 [lindex $st 1]
checkEq "an unclosed session's duration is its exercises' time" [dict get $s2 dur] 20000

# Now the set is evaluated: ex 1 has "! -", ex 2 "!!". The old sessions are
# scored again with the new marks - the continuity the plan asks for.
set ver [::woodpecker::marksAppend $tmp [dict create \
    1 [dict create marks {"!" ""} source review] \
    2 [dict create marks {"!!"} source review]]]
checkEq "first marks version" $ver 1
set ver2 [::woodpecker::marksAppend $tmp [dict create 3 [dict create marks {"!"} source author]]]
checkEq "second version" $ver2 2
set marks [::woodpecker::readMarks $tmp]
checkEq "latest version" [::woodpecker::marksLatest $marks] 2
set table [::woodpecker::marksAt $marks 2]
checkEq "a later version keeps the earlier exercises" [dict get $table 1 marks] {! {}}
checkEq "source kept" [dict get $table 3 source] author
set st [::woodpecker::sessionStats $xs $ss $back $table]
set s1 [lindex $st 0]
check "session 1 rescored: 1+1+1 for ex 1, 0 for ex 2" {[near [dict get $s1 points] 3.0]}
check "session 1 maximum with marks" {[near [dict get $s1 max] [expr {3.0 + 4.0*1.4}]]}
checkEq "no unrated exercises left" [dict get $s1 unrated] 0
check "percentages are on the maximum" {[near [dict get $s1 pct] [expr {100.0 * 3.0 / (3.0 + 5.6)}]]}
set table1 [::woodpecker::marksAt $marks 1]
checkEq "an older version is still available" [dict exists $table1 3] 0

set cs [::woodpecker::cycleStats $xs $back $table]
checkEq "two cycles" [llength $cs] 2
set c1 [lindex $cs 0]
checkEq "cycle 1: days, exercises, solving time, results" \
    [list [dict get $c1 start] [dict get $c1 end] [dict get $c1 exercises] [dict get $c1 ms] [dict get $c1 clean] [dict get $c1 second] [dict get $c1 failed]] \
    {2026-11-01 2026-11-02 3 100000 1 1 1}

set cmp [::woodpecker::compareCycles $xs 2 {1 2 3}]
checkEq "exercise 1 was faster in cycle 2" [list [dict get $cmp compared] [dict get $cmp faster] [dict get $cmp slower]] {1 1 0}
checkEq "no new errors" [dict get $cmp newErrors] 0

checkEq "durations: hours" [::woodpecker::fmtDuration 3840000] "1h 04m"
checkEq "durations: minutes" [::woodpecker::fmtDuration 750000] "12m 30s"
checkEq "durations: seconds" [::woodpecker::fmtDuration 45000] "45s"
checkEq "durations: nothing" [::woodpecker::fmtDuration ""] "-"


# ---------------------------------------------------------- exercises file ----
::woodpecker::writeExercises $tmp [dict create 1 [::woodpecker::exerciseRow 1 1 abc 1700 \
    "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1" {a1a8} g8h8]]
set e [dict get [::woodpecker::readExercises $tmp] 1]
checkEq "an exercise row keeps its FEN" [dict get $e fen] "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1"
checkEq "... its solution" [dict get $e solution] a1a8
checkEq "... and the opponent's last move" [dict get $e lastMove] g8h8
checkEq "one solver move" [dict get $e nmoves] 1

# ------------------------------------------------------------------- JSON ----
set j [::woodpecker::jsonParse {{"a": [1, -2.5, true, false, null], "s": "x\"y\\zé\n", "o": {}, "e": []}}]
checkEq "JSON arrays and literals" [dict get $j a] {1 -2.5 1 0 {}}
checkEq "JSON string escapes" [dict get $j s] "x\"y\\zé\n"
checkEq "JSON empty object and array" [list [dict size [dict get $j o]] [llength [dict get $j e]]] {0 0}
check "broken JSON is refused" {[catch {::woodpecker::jsonParse {{"a": [1, 2}}}]}
check "trailing data is refused" {[catch {::woodpecker::jsonParse {{} x}}]}

# ------------------------------------------------------ Lichess puzzle -> FEN ----
# A real batch entry (puzzle Xv7EA, lichess.org/XMJDc53B), shortened to the
# fields the trainer reads. Lichess shows it from 5r2/p2P2k1/4Qbp1/2p1B2p/8/P4P2/3qN1KP/5R2 b.
set pgn {e4 g6 f4 Bg7 Nf3 d6 c3 Nc6 d4 Nf6 Bb5 O-O e5 dxe5 fxe5 Nd5 Bxc6 bxc6 O-O c5 c4 Nb4 d5 c6 a3 Na6 Bf4 cxd5 cxd5 Bb7 Nc3 e6 d6 f6 Qe2 fxe5 Bxe5 Bxf3 Rxf3 Rxf3 gxf3 Qg5+ Bg3 Bd4+ Kg2 Rf8 Qxa6 Qd2+ Ne2 Bxb2 Rf1 h5 d7 Bf6 Qxe6+ Kg7 Be5}
set entry [::woodpecker::jsonParse [format {{"game":{"id":"XMJDc53B","players":[{"name":"W","color":"white"},{"name":"B","color":"black"}],"pgn":"%s"},"puzzle":{"id":"Xv7EA","rating":1384,"plays":3082,"solution":["d2e2","f1f2","e2e5","e6e5","f6e5"],"themes":["middlegame","advantage"],"initialPly":56}}} $pgn]]
set ex [::woodpecker::lichessExercise $entry]
checkEq "the puzzle position is the game after initialPly+1 moves" \
    [lrange [split [dict get $ex fen]] 0 3] {5r2/p2P2k1/4Qbp1/2p1B2p/8/P4P2/3qN1KP/5R2 b - -}
checkEq "the opponent's last move" [dict get $ex lastMove] g3e5
checkEq "the trainee plays Black" [::woodpecker::fenSide [dict get $ex fen]] b
checkEq "players" [list [dict get $ex white] [dict get $ex black]] {W B}
checkEq "rating and themes" [list [dict get $ex rating] [dict get $ex themes]] {1384 {middlegame advantage}}

# Every SAN of the game survives SAN -> UCI -> SAN, castling and checks included.
set pos [::chessboard::fromFen [::woodpecker::startFen]]
set back {}
foreach san $pgn {
    set uci [::woodpecker::sanToUci $pos $san]
    lappend back [::woodpecker::uciToSan $pos $uci]
    set pos [::chessboard::makeMove $pos $uci]
}
checkEq "SAN round trip over a whole game" $back $pgn

set p [::chessboard::fromFen {r3k2r/8/8/3pP3/8/8/8/R3K2R w KQkq d6 0 1}]
checkEq "kingside castling" [::woodpecker::uciToSan $p e1g1] O-O
checkEq "queenside castling" [::woodpecker::uciToSan $p e1c1] O-O-O
checkEq "en passant" [::woodpecker::uciToSan $p e5d6] exd6
checkEq "a rook the king blocks is no rival" [::woodpecker::uciToSan $p a1d1] Rd1
set p [::chessboard::fromFen {4k3/8/8/8/8/8/8/R5RK w - - 0 1}]
checkEq "rooks on one rank need the file" [::woodpecker::uciToSan $p a1d1] Rad1
checkEq "... and back" [::woodpecker::sanToUci $p Rad1] a1d1
set p [::chessboard::fromFen {7k/4P3/8/8/8/8/8/K7 w - - 0 1}]
checkEq "promotion with check" [::woodpecker::uciToSan $p e7e8q] e8=Q+
checkEq "promotion back" [::woodpecker::sanToUci $p e8=Q+] e7e8q
set p [::chessboard::fromFen {6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1}]
checkEq "mate is #" [::woodpecker::uciToSan $p a1a8] Ra8#
set p [::chessboard::fromFen {k7/8/8/8/1N3N2/8/8/K7 w - - 0 1}]
checkEq "knights on one rank need the file" [::woodpecker::uciToSan $p b4d5] Nbd5
set p [::chessboard::fromFen {k7/8/1N6/8/1N6/8/8/K7 w - - 0 1}]
checkEq "knights on one file need the rank" [::woodpecker::uciToSan $p b6d5] N6d5
check "an illegal move has no SAN" {[catch {::woodpecker::uciToSan $p a1a3}]}
check "an ambiguous SAN is refused" {[catch {::woodpecker::sanToUci $p Nd5}]}

set game [::woodpecker::pgnGame [dict get $ex fen] [dict get $ex solution] "My set" 7 W B \
    "https://lichess.org/XMJDc53B" {{PuzzleId Xv7EA} {PuzzleRating 1384}}]
check "the PGN sets up the position" {[string first "\[FEN \"[dict get $ex fen]\"\]" $game] >= 0}
check "the PGN starts with Black's move number" {[string first "29... Qxe2+ 30. Rf2 Qxe5 31. Qxe5 Bxe5 *" $game] >= 0}
check "extra tags are written" {[string first {[PuzzleRating "1384"]} $game] >= 0}


checkEq "the solution as text, with marks" \
    [::woodpecker::lineText [dict get $ex fen] [dict get $ex solution] {"!" "" "!!"}] \
    "29... Qxe2+! 30. Rf2 Qxe5 31. Qxe5 Bxe5!!"
checkEq "the rest of a solution from a ply" \
    [::woodpecker::lineText [dict get $ex fen] [dict get $ex solution] {} 2] "30... Qxe5 31. Qxe5 Bxe5"
checkEq "the same move" [::woodpecker::sameMove e7e8Q e7e8q] 1
checkEq "castling as king takes rook" [::woodpecker::sameMove e1h1 e1g1] 1
checkEq "different moves" [::woodpecker::sameMove e2e4 e2e3] 0


# --------------------------------------------------------------- presets ----
checkEq "four presets" [dict keys [::woodpecker::presets]] {automatic standard challenge tough}
checkEq "standard keeps the book's proportion" [::woodpecker::presetShares standard] {easier 25 normal 60 harder 15}
foreach name {automatic standard challenge tough} {
    set sum 0
    dict for {k v} [::woodpecker::presetShares $name] {
        incr sum $v
        check "$name uses a level the API knows ($k)" {$k in {easiest easier normal harder hardest}}
    }
    checkEq "$name adds up to 100" $sum 100
}
check "an unknown preset is refused" {[catch {::woodpecker::presetShares bogus}]}


# ------------------------------------------------- without a Lichess token ----
checkEq "level deltas as in lila" [lmap l {easiest easier normal harder hardest} { ::woodpecker::levelDelta $l }] {-600 -300 0 300 600}
checkEq "the window at 1500" [::woodpecker::levelWindow 1500] 100
checkEq "the window grows away from 1500" [::woodpecker::levelWindow 2300] 300
set p [::woodpecker::anonPlan 1500 normal]
checkEq "a 1500 player's normal is the anonymous normal" [list [dict get $p centre] [dict get $p sources]] {1500 normal}
set p [::woodpecker::anonPlan 1650 normal]
checkEq "between two levels both are fetched" [list [dict get $p centre] [dict get $p sources]] {1650 {normal harder}}
set p [::woodpecker::anonPlan 1900 harder]
checkEq "above the anonymous range: the nearest level only" [list [dict get $p centre] [dict get $p sources]] {2200 hardest}
set p [::woodpecker::anonPlan 1200 easiest]
checkEq "below it too" [list [dict get $p centre] [dict get $p sources] [dict get $p window]] {600 easiest 325}

file delete -force $tmp
puts "$checks checks, $fails failures"
exit [expr {$fails > 0}]
