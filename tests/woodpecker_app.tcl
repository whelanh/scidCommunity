# Copyright (C) 2026 Tommaso Bergamasco
# SPDX-License-Identifier: GPL-2.0-or-later
#
# woodpecker_app.tcl -- the Woodpecker trainer against real databases: a set
# from Lichess puzzles (a recorded batch reply, no network), a set from a PGN
# book with the author's marks, marks written back as NAGs, and - when a UCI
# engine is available - the evaluation pass on the review's connection. It needs
# the sc_* commands, so it runs inside the built application:
#
#   scidCommunity tests/woodpecker_app.tcl
#
# The engine is $WOODPECKER_ENGINE, else stockfish on PATH or /usr/games.

set fails 0
set checks 0
proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} { puts "  FAIL $label" } else { puts "  FAIL $label -- $detail" }
    }
}
proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}

set root [file normalize [file join [file dirname [info script]] ..]]
foreach f {utils/chessboard.tcl tools/accuracy.tcl tools/move_labels.tcl tools/woodpecker_core.tcl
           tools/woodpecker_set.tcl} {
    source -encoding utf-8 [file join $root tcl $f]
}

set tmp [file join [expr {[info exists ::env(TEMP)] ? $::env(TEMP) : "/tmp"}] woodpecker_app_[pid]]
file delete -force $tmp
file mkdir $tmp
set ::scidUserDir $tmp
set ::clipbase_db [sc_info clipbase]

# A Lichess batch reply, three puzzles, recorded 2026-11-17.
set batch {{"puzzles":[{"game":{"id":"oMbgzh8N","players":[{"name":"keorine2","color":"white"},{"name":"WaterChamp","color":"black"}],"pgn":"d4 f5 c4 Nf6 Nc3 e6 Nf3 Bb4 e3 b6 Bd3 Bb7 O-O O-O d5 Bxc3 bxc3 Qe7 Qb3 exd5 cxd5 d6 Ba3 Nbd7 Bxf5 Nc5 Be6+ Nxe6 dxe6 Rfe8 Ne5 Qxe6 Qxe6+ Rxe6 Nc4 Bd5 Nd2 Ne4 Nxe4 Bxe4 f3 Bd3 Rfe1 Rae8 e4 d5 Rad1 dxe4 fxe4 Bxe4 Re3 Bc2 Rxe6 Rxe6 Rd8+ Kf7 Rf8+ Kg6 Rc8 Bb1 Rxc7 Bxa2 Rxa7 b5 Bb4 Bc4 Bf8"},"puzzle":{"id":"vussK","rating":1466,"plays":981,"solution":["e6e1","g1f2","e1f1","f2e3","f1f8"],"themes":["endgame","advantage","skewer","long"],"initialPly":66}},{"game":{"id":"ogkxNF5j","players":[{"name":"ItsMe-Cyril","color":"white"},{"name":"jladeshara","color":"black"}],"pgn":"e4 e6 Nf3 a6 d4 c5 d5 d6 c4 e5 Nc3 Nf6 b4 b6 Qa4+ Nbd7 Qc6 Rb8 Qa4 Be7 Bd3 O-O b5 a5 Qc2 h6 h4 Nh5 g4 Nf4 Bxf4 exf4 g5 hxg5 hxg5 Ne5 O-O-O Nxf3 e5 Nxg5 Bh7+ Kh8 Rdg1 dxe5 Rxg5 Bxg5"},"puzzle":{"id":"TzjD2","rating":1597,"plays":4239,"solution":["h7g8","g5h4","c2h7"],"themes":["clearance","mateIn2","middlegame","short","discoveredCheck","kingsideAttack","discoveredAttack"],"initialPly":45}},{"game":{"id":"u7vhp33E","players":[{"name":"gchessm1","color":"white"},{"name":"TiberijuBrankovic","color":"black"}],"pgn":"e4 e5 Nf3 Nc6 d4 exd4 Nxd4 Nxd4 Qxd4 c5 Qd1 d6 Bd3 Be6 O-O Qc7 c4 O-O-O Nc3 Nf6 Bf4 h6 h3 g5 Bh2 g4 Qa4 a6 Nd5 Bxd5 cxd5 gxh3 b4 hxg2 Rfc1 Qd7 bxc5 Qxa4 cxd6+ Kb8 d7+ Ka7 Rc8 Be7 Bb8+ Kb6 Rb1+ Ka5"},"puzzle":{"id":"ZXkNc","rating":1547,"plays":22644,"solution":["b8c7","b7b6","c7b6"],"themes":["mateIn2","middlegame","short","fork"],"initialPly":47}}]}}

# --------------------------------------------------------------- Lichess set --
puts "lichess set"
set reply [::woodpecker::jsonParse $batch]
set exs [lmap e [dict get $reply puzzles] { ::woodpecker::lichessExercise $e }]
set exs [lsort -integer -command {apply {{a b} { expr {[dict get $a rating] - [dict get $b rating]} }}} $exs]
set dir [::woodpecker::set::newDir "Test set"]
checkEq "the set directory is under the user directory" [file dirname $dir] [file join $tmp woodpecker]
set meta [::woodpecker::set::newMeta "Test set" lichess 28 1 [clock seconds]]
checkEq "three exercises built" [::woodpecker::set::buildFromExercises $dir $meta $exs] 3
set rows [::woodpecker::readExercises $dir]
checkEq "exercises are ordered by rating" [lmap ex {1 2 3} { dict get $rows $ex rating }] {1466 1547 1597}
checkEq "the puzzle id is kept" [dict get $rows 1 puzzleId] vussK
checkEq "solver moves of a five-ply solution" [dict get $rows 1 nmoves] 3
checkEq "the set is listed" [llength [::woodpecker::set::all]] 1
checkEq "its ids count as used" [lsort [dict keys [::woodpecker::set::usedIds]]] [lsort {vussK TzjD2 ZXkNc}]
check "a second set gets its own directory" [expr {[::woodpecker::set::newDir "Test set"] ne $dir}]

lassign [::woodpecker::set::openBase $dir] b opened
checkEq "the database was opened here" $opened 1
checkEq "one game per exercise" [sc_base numGames $b] 3
set prev [sc_base current]
sc_base switch $b
sc_game load 1
set ml [sc_game UCI_mainLine]
checkEq "the game starts from the puzzle position" [lindex $ml 0] "position fen [dict get $rows 1 fen] moves"
checkEq "its main line is the solution" [lrange $ml 1 end] [dict get $rows 1 solution]
set extra [::woodpecker::set::extraTags]
checkEq "the rating is a tag" [dict get $extra PuzzleRating] 1466
checkEq "so is the opponent's last move" [dict get $extra LastMove] [dict get $rows 1 lastMove]
checkEq "the round is the exercise number" [sc_game tags get Round] 1
sc_base switch $prev
sc_base close $b

# Marks written back: a NAG per marked solver move, the old move marks replaced.
::woodpecker::set::writeMarks $dir [dict create 1 [dict create marks {"!" "" "!!"} source review]]
lassign [::woodpecker::set::openBase $dir] b opened
sc_base switch $b
sc_game load 1
sc_move ply 1
checkEq "the first solver move carries !" [string trim [sc_pos getNags]] "!"
sc_move ply 3
checkEq "the second carries nothing" [string trim [sc_pos getNags]] "0"
sc_move ply 5
checkEq "the third carries !!" [string trim [sc_pos getNags]] "!!"
sc_base switch $prev
sc_base close $b
::woodpecker::set::writeMarks $dir [dict create 1 [dict create marks {"" "" ""} source review]]
lassign [::woodpecker::set::openBase $dir] b opened
sc_base switch $b
sc_game load 1
sc_move ply 1
checkEq "a later evaluation takes its own mark back off" [string trim [sc_pos getNags]] "0"
sc_base switch $prev
sc_base close $b

# ------------------------------------------------------------------ PGN book --
puts "book set"
set pgn [file join $tmp book.pgn]
set f [open $pgn w]
puts $f {[Event "Book"]
[Site "?"]
[Date "????.??.??"]
[Round "1"]
[White "A"]
[Black "B"]
[Result "*"]
[SetUp "1"]
[FEN "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1"]

1. Ra8# $1 *

[Event "Book"]
[Site "?"]
[Date "????.??.??"]
[Round "2"]
[White "A"]
[Black "B"]
[Result "*"]
[SetUp "1"]
[FEN "r1bqkbnr/pppp1ppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4"]

4. Qxf7# (4. Bxf7+ Ke7) *

[Event "Book"]
[Site "?"]
[Date "????.??.??"]
[Round "3"]
[White "A"]
[Black "B"]
[Result "*"]

1. e4 e5 *
}
close $f
set bdir [::woodpecker::set::newDir "Book"]
lassign [::woodpecker::set::buildFromFile $bdir [::woodpecker::set::newMeta Book file 14 1 [clock seconds]] $pgn] n annotated skipped
checkEq "two exercises, one annotated, one game from the start skipped" [list $n $annotated $skipped] {2 1 1}
set rows [::woodpecker::readExercises $bdir]
checkEq "the main line is the solution, the variation ignored" [dict get $rows 2 solution] h5f7
checkEq "game numbers follow the database" [dict get $rows 2 game] 2
set st [::woodpecker::set::markStatus $bdir]
checkEq "mark status: one of two annotated by the author" [list [dict get $st total] [dict get $st annotated] [dict get $st reviewed]] {2 1 0}
set table [::woodpecker::marksAt [::woodpecker::readMarks $bdir] 1]
checkEq "the author's ! became the exercise's mark" [dict get $table 1 marks] "!"
checkEq "the book file is remembered" [dict get [::woodpecker::readMeta $bdir] file] $pgn
checkEq "the source base was closed" [lsearch -exact [lmap x [sc_base list] { sc_base filename $x }] $pgn] -1

# ----------------------------------------------------------------- evaluation --
set engine ""
if {[info exists ::env(WOODPECKER_ENGINE)]} { set engine $::env(WOODPECKER_ENGINE) }
if {$engine eq ""} { set engine [lindex [auto_execok stockfish] 0] }
if {$engine eq "" && [file executable /usr/games/stockfish]} { set engine /usr/games/stockfish }
if {$engine eq ""} {
    puts "evaluation: skipped (no engine)"
} else {
    puts "evaluation with $engine"
    foreach f {enginecfg.tcl enginecomm.tcl tools/engine_limits.tcl tools/score_seed.tcl
               tools/comment_colors.tcl tools/game_review.tcl tools/review_driver.tcl
               tools/woodpecker_eval.tcl} {
        source -encoding utf-8 [file join $root tcl $f]
    }
    set ::engines(list) [list [list TestFish $engine {} {} 0 0 {} 1 {}]]
    set ::evalDone ""
    set ::phases {}
    proc onProg {phase done total} { if {[lsearch $::phases $phase] < 0} { lappend ::phases $phase } }
    proc onDone {status summary} { set ::evalDone [list $status $summary] }
    after 120000 { set ::evalDone timeout }
    ::woodpecker::eval::start $dir TestFish {1 2 3} onProg onDone
    vwait ::evalDone
    lassign $::evalDone status summary
    checkEq "the evaluation finished" $status ok
    checkEq "both passes and the write ran" $::phases {deep shallow write}
    if {$status eq "ok"} {
        checkEq "three exercises graded" [dict get $summary exercises] 3
        checkEq "seven solver moves" [dict get $summary moves] 7
        set marks [::woodpecker::readMarks $dir]
        set ver [::woodpecker::marksLatest $marks]
        checkEq "a new marks version" $ver [dict get $summary version]
        set table [::woodpecker::marksAt $marks $ver]
        checkEq "every exercise has marks from the review" [lsort -unique [lmap ex {1 2 3} { dict get $table $ex source }]] review
        foreach ex {1 2 3} { puts "    ex $ex: [dict get $table $ex marks]" }
        check "marks are only ! !! or nothing" [expr {[llength [lsearch -all -inline -not -regexp [concat {*}[lmap ex {1 2 3} { dict get $table $ex marks }]] {^(!|!!|)$}]] == 0}]
        check "the busy flag is cleared" [expr {![::woodpecker::eval::busy]}]
    }
}

file delete -force $tmp
puts "$checks checks, $fails failures"
exit [expr {$fails > 0}]
