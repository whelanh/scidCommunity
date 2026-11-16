#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Computer tournament (tcl/tools/multicomp.tcl): the PGN time control, the
# repetition key that decides a draw, and the time-per-move deadline.
#
#   tclsh tests/tcl/multicomp.tcl            # the tree's multicomp.tcl
#   tclsh tests/tcl/multicomp.tcl FILE.tcl   # any other copy (e.g. the base)

set fails 0
set checks 0

proc check {name cond} {
    global fails checks
    incr checks
    if {![uplevel 1 [list expr $cond]]} {
        incr fails
        puts "FAIL $name"
    }
}

proc checkEq {name got want} {
    global fails checks
    incr checks
    if {$got ne $want} {
        incr fails
        puts "FAIL $name -- got '$got' want '$want'"
    }
}

proc checkMatch {name got pattern} {
    global fails checks
    incr checks
    if {![string match $pattern $got]} {
        incr fails
        puts "FAIL $name -- got '$got' want '$pattern'"
    }
}

# A check that a procedure added by this branch may not exist in an older copy
# of the file must still report a FAIL rather than take the run down with it.
proc call {script} {
    if {[catch {uplevel 1 $script} v]} { return "ERROR:$v" }
    return $v
}

# The stubs multicomp.tcl needs: tr at load time, and the square conversions of
# tcl/board.tcl (a1 == 0, uppercase white at the bottom) at call time.
proc tr {s} { return $s }
namespace eval ::board {}
proc ::board::sq {n} {
    if {![info exists ::squares]} {
        set ::squares {}
        foreach rank {1 2 3 4 5 6 7 8} {
            foreach file {a b c d e f g h} { lappend ::squares $file$rank }
        }
    }
    return [lsearch -exact $::squares $n]
}
proc ::board::san {i} {
    return [format %c%c [expr {($i % 8) + 97}] [expr {($i / 8) + 49}]]
}

set root [file normalize [file join [file dirname [info script]] .. ..]]
if {[llength $argv]} {
    set file [lindex $argv 0]
} else {
    set file [file join $root tcl tools multicomp.tcl]
}
if {[catch {source $file} err]} {
    puts "FAIL cannot load $file: $err"
    puts "\n$checks checks, $fails failures"
    exit 1
}

set START "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"

# Replay a move list the way ::comp::compCheckMove drives the repetition test:
# board through compUpdateboard, state through nextPositionState, key through
# repetitionKey, journal through checkRepetition.  Returns, per ply, whether the
# position was called a repetition.
#
# A copy of the file without the castling/en-passant state procedures is replayed
# with the old keying (placement and side only), so the run shows the false draw
# itself instead of an "invalid command name".
proc replay {moves} {
    set stateful [expr {
        [llength [info commands ::comp::stateFromPosition]] &&
        [llength [info commands ::comp::nextPositionState]] &&
        [llength [info commands ::comp::startPositionKey]] &&
        [llength [info commands ::comp::repetitionKey]] }]
    set board $::START
    if {$stateful} {
        lassign [::comp::stateFromPosition startpos $board] rights epsq
        set journal [list [::comp::startPositionKey startpos]]
    } else {
        set rights ""
        set epsq ""
        set journal {}
    }
    set side w
    set out {}
    foreach mv $moves {
        set pre $board
        lassign [::comp::compUpdateboard $pre $mv] ok board
        if {!$ok} { error "compUpdateboard rejected $mv" }
        set side [expr {$side eq "w" ? "b" : "w"}]
        if {$stateful} {
            lassign [::comp::nextPositionState [list $rights $epsq] $pre $mv] rights epsq
            set key [::comp::repetitionKey $board $side $rights $epsq]
        } else {
            set key "$board $side"
        }
        lassign [::comp::checkRepetition $journal $key] isRep journal
        lappend out [list $isRep]
    }
    return $out
}

proc repAt {plies ply} {
    return [lindex [lindex $plies [expr {$ply - 1}]] 0]
}

puts "the PGN time control"
set ::comp::_Data(timecontrol) pergame
set ::comp::_Data(base) 300
set ::comp::_Data(incr) 0.5
# PGN TimeControl is base+increment in seconds: "5:00/0.5" read as 0 moves in 5
# seconds, and no chess database could use it.
checkEq "5:00 + 0.5 is 300+0.5" [call {::comp::timeControlTag}] {TimeControl "300+0.5"}
set ::comp::_Data(base) 60
set ::comp::_Data(incr) 0
checkEq "60 + 0 is 60+0, not 1:00/0" [call {::comp::timeControlTag}] {TimeControl "60+0"}
set ::comp::_Data(base) 2
set ::comp::_Data(incr) 0.5
checkEq "2 s + 0.5 is 2+0.5" [call {::comp::timeControlTag}] {TimeControl "2+0.5"}
set ::comp::_Data(timecontrol) permove
set ::comp::_Data(seconds) 0.5
checkEq "a time per move stays Movetime" [call {::comp::timeControlTag}] {Movetime "0.5"}
set ::comp::_Data(timecontrol) pergame

puts "\nthe repetition key"
checkEq "the key holds placement, side, rights and ep" \
    [call {::comp::repetitionKey {RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr w} w KQkq -}] \
    [list $START w KQkq -]
checkEq "a FEN board's side token is not part of it" \
    [call {::comp::repetitionKey [list $START b] b - e3}] [list $START b - e3]

# A FEN/EPD whose castling field is "-" grants nothing at all. It used to keep
# initialPositionState's KQkq default (the "-" satisfies no [KQkq] pattern), so a
# position that can only ever exist without a right was keyed as if it had all
# four, and since rights only shrink a real repetition never matched.
set noRightsFEN "4k3/8/8/8/8/8/8/4K2R w - - 0 1"
checkEq "a FEN that grants no castling right says so" \
    [call {::comp::initialPositionState $noRightsFEN}] {- -}
checkEq "and its start key carries no phantom right" \
    [call {::comp::startPositionKey $noRightsFEN}] \
    [call {::comp::repetitionKey [::comp::FENtoBoard $noRightsFEN] w - -}]
checkEq "a FEN that does grant a right still keeps it" \
    [call {::comp::initialPositionState "4k3/8/8/8/8/8/8/4K2R w K - 0 1"}] {K -}

# A rook out and home again returns the placement, but White's Q-side right is
# gone for good: the second and third occurrences are not the first position.
set castlingMoves {
    b1c3 g8f6 a1b1 f6g8 b1a1 g8f6
    a1b1 f6g8 b1a1 g8f6
    a1b1 f6g8 b1a1 g8f6
}
set p [call {replay $::castlingMoves}]
# Base (placement + side only) sees three of the same position at ply 10 and
# calls a draw; the rights differ at the first one, so it is not a repetition.
checkEq "a repetition that differs in castling rights is not a draw" [call {repAt $p 10}] 0
checkEq "the real third occurrence is a draw" [call {repAt $p 14}] 1
checkEq "the first occurrence is never a draw" [call {repAt $p 2}] 0

# A double pawn push leaves an en-passant square only when an enemy pawn can
# actually take there (FIDE 9.2). After 1.e4 no black pawn stands on d4 or f4,
# so the position is the same as any other: ply 5 is its second occurrence and
# ply 9 the third, which is the draw.
set epMoves {
    e2e4 g8f6 g1f3 f6g8 f3g1
    g8f6 g1f3 f6g8 f3g1
    g8f6 g1f3 f6g8 f3g1
}
set q [call {replay $::epMoves}]
checkEq "a double push nobody can answer is the same position" [call {repAt $q 9}] 1
checkEq "its second occurrence is not a draw yet" [call {repAt $q 5}] 0
checkEq "the fourth occurrence is a draw here too" [call {repAt $q 13}] 1

# The distinction FIDE 9.2 does draw: an enemy pawn on the file beside the
# landing square makes the en-passant capture available, so the position stays a
# different one. Board indices start at a1, so d4 is 27 and c4/e4 are 26/28.
set epBoard "...........P................p..................................."
checkEq "a double push beside an enemy pawn records its ep square" \
    [call {lindex [::comp::nextPositionState {KQkq -} $epBoard d2d4] 1}] d3
checkEq "a double push with no enemy pawn beside it records none" \
    [call {lindex [::comp::nextPositionState {KQkq -} $START e2e4] 1}] -

puts "\nthe en-passant target of a FEN start"
# The FEN/EPD ep field used to be taken verbatim while the post-move path kept
# it only when a capture was available, so one position reached two ways keyed
# differently and the repeat was never seen. Both ask epCaptureAvailable now.
set phantomEP "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
set plainEP "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
checkEq "a FEN ep square nobody can take is not part of the position" \
    [call {::comp::initialPositionState $phantomEP}] {KQkq -}
checkEq "so the FEN with it and the FEN without it key the same" \
    [call {::comp::startPositionKey $phantomEP}] \
    [call {::comp::startPositionKey $plainEP}]
# Black pawn d4, White has just played e2-e4: dxe3 is available, so the square
# is real and the start is a different position from the one without it.
set liveEP "4k3/8/8/8/3pP3/8/8/4K3 b - e3 0 1"
checkEq "a FEN ep square an enemy pawn can take is kept" \
    [call {::comp::initialPositionState $liveEP}] {- e3}
set pushBoard [call {::comp::FENtoBoard "4k3/8/8/8/3p4/8/4P3/4K3 w - - 0 1"}]
checkEq "and the post-move path agrees with it" \
    [call {lindex [::comp::nextPositionState {- -} $pushBoard e2e4] 1}] e3

# An ep capture that is illegal is no capture, so the square is not part of the
# position (FIDE 9.2 keys on the *possible* capture, and a pinned pawn cannot
# play one). Black Kd8, pawn d4, White Re1... the rook stands on d1: dxe3 takes
# the d4 pawn off the d-file and exposes its own king, so e3 must not enter the
# key -- it did, and the identical placement reached later never matched.
set pinnedEP [call {::comp::FENtoBoard "3k4/8/8/8/3p4/8/4P3/3RK3 w - - 0 1"}]
set freeEP   [call {::comp::FENtoBoard "3k4/8/8/8/3p4/8/4P3/4K3 w - - 0 1"}]
lassign [call {::comp::nextPositionState {- -} $pinnedEP e2e4}] pr pe
lassign [call {::comp::nextPositionState {- -} $freeEP e2e4}] fr fe
checkEq "a pinned pawn's ep capture leaves no square" $pe -
checkEq "the same push with the pawn free keeps it" $fe e3
set pinnedKey [call {::comp::repetitionKey \
    [call {lindex [::comp::compUpdateboard $pinnedEP e2e4] 1}] b $pr $pe}]
set freeKey [call {::comp::repetitionKey \
    [call {lindex [::comp::compUpdateboard $freeEP e2e4] 1}] b $fr $fe}]
check "the pinned position's key carries no e3" [expr {[lsearch -exact $pinnedKey e3] < 0}]
check "the legal one's key does" [expr {[lsearch -exact $freeKey e3] >= 0}]
checkEq "and the FEN/EPD path drops the pinned square too" \
    [call {::comp::initialPositionState "3k4/8/8/8/3pP3/8/8/3RK3 b - e3 0 1"}] {- -}
checkEq "while it keeps the one that can be taken" \
    [call {::comp::initialPositionState "3k4/8/8/8/3pP3/8/8/4K3 b - e3 0 1"}] {- e3}
# The same rule on the other colour: White Kd1, pawn d5, Black Re8... the rook
# stands on d8 here, so dxe6 e.p. exposes its own king and e6 stays out of the
# key, while the push without the pin keeps it.
set whitePinned [call {::comp::FENtoBoard "3r4/4p3/8/3P4/8/8/8/3K4 w - - 0 1"}]
set whiteFree   [call {::comp::FENtoBoard "8/4p3/8/3P4/8/8/8/3K4 w - - 0 1"}]
checkEq "a pinned White pawn's ep capture leaves no square" \
    [call {lindex [::comp::nextPositionState {- -} $whitePinned e7e5] 1}] -
checkEq "and the unpinned one keeps e6" \
    [call {lindex [::comp::nextPositionState {- -} $whiteFree e7e5] 1}] e6

puts "\nthe board after an en-passant capture"
# compUpdateboard handles castling but carried a bare "#Todo enpassant": it wrote
# the moved pawn to its destination and cleared the from square, so on e5xd6
# e.p. the black pawn stayed on d5. Every later position of that game was then
# keyed with a phantom pawn -- and the repetition key is built on this board
# string, so a genuine threefold on the position never matched it.
set epStart "rnbqkbnr/1pp1pppp/p7/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq - 0 3"
set epBoard [call {::comp::FENtoBoard $::epStart}]
# a1 is index 0, so d5 is 35, e5 36 and d6 43
checkEq "the captured pawn leaves d5" \
    [call {string index [lindex [::comp::compUpdateboard $::epBoard e5d6] 1] 35}] "."
checkEq "the capturing pawn lands on d6" \
    [call {string index [lindex [::comp::compUpdateboard $::epBoard e5d6] 1] 43}] "P"
# The black pawn is gone, so the position after the capture is the one a FEN
# without it describes: the journal of a line that starts with the capture has
# to key it that way, or a repeat of that position is never recognised.
set epAfter "rnbqkbnr/1pp1pppp/p2P4/8/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 3"
set epLine {e5d6 g8f6 g1f3 f6g8 f3g1 g8f6 g1f3 f6g8 f3g1}
lassign [call {::comp::bookLineJournal $::epStart $::epLine}] epJournal epState
checkEq "the position after an en-passant capture is keyed as the placement it is" \
    [lindex $epJournal 1] \
    [call {::comp::repetitionKey [::comp::FENtoBoard $::epAfter] b KQkq -}]
# The line then returns to that position twice more, so a game that contains an
# en-passant capture and repeats the position is adjudicated a draw on move 9.
checkEq "and its third occurrence draws the game on move 9" \
    [call {::comp::threefoldPosition $::epJournal}] 9

puts "\nthe book line's positions"
# A .opn/.bin line arrives already played into _Data(board,$game) while
# _Data(fen,$game) is still startpos, so the journal used to open with the start
# key alone: every position the line reached was missing from it, and a line
# that repeats a position (or recurs later) undercounted the threefold.
set line {g1f3 g8f6 f3g1 f6g8 g1f3 g8f6 f3g1 f6g8}
lassign [call {::comp::bookLineJournal startpos $line}] journal lineState
checkEq "the journal has one key per position, the start first" \
    [call {llength $journal}] 9
checkEq "with the start key still first" \
    [call {lindex $journal 0}] [call {::comp::startPositionKey startpos}]
checkEq "the line's second occurrence of the start is keyed" \
    [call {lindex $journal 4}] [call {lindex $journal 0}]
checkEq "and the third is already a draw" \
    [call {expr {[llength [lsearch -all -exact $journal [lindex $journal 0]]]}}] 3
checkEq "a position one knight away is not the start" \
    [call {expr {[lindex $journal 1] ne [lindex $journal 0]}}] 1
# The state handed back is the line's last position, so a rook moved inside the
# book line leaves the game without that castling right instead of the start
# position's rights being restored onto a board that has already moved.
lassign [call {::comp::bookLineJournal startpos {a2a3 a7a6 a1a2}}] rookJournal rookState
checkEq "the line's last position hands the game its real rights" \
    [call {lindex $rookState 0}] Kkq
checkEq "and the journal ends on that position" \
    [call {lindex $rookJournal end}] \
    [call {::comp::repetitionKey [call {::comp::FENtoBoard "rnbqkbnr/1ppppppp/p7/8/8/P7/RPPPPPPP/1NBQKBNR b Kqkq - 0 3"}] b Kkq -}]

puts "\nthe book line that is already a repetition"
# compNM seeded the journal with the line's positions and then went straight to
# initEngine + compNextMove: nothing asked whether the journal it had just built
# already held three occurrences, so a line that repeats a position three times
# was played on with a result FIDE 9.2 would have drawn. It is adjudicated at
# setup now -- result, comment, no engine, no move scheduled.
set threefoldLine {g1f3 g8f6 f3g1 f6g8 g1f3 g8f6 f3g1 f6g8}
# The journal's index i is the position after move i, and the third occurrence
# of the start position is the position after the line's eighth move: that move
# is the one the game is drawn on, and the moves before it are the ones the PGN
# has to keep.
checkEq "the journal names the move its third occurrence falls on" \
    [call {::comp::threefoldPosition [lindex [::comp::bookLineJournal startpos $threefoldLine] 0]}] 8
checkEq "a line that never repeats names none" \
    [call {::comp::threefoldPosition [lindex [::comp::bookLineJournal startpos {e2e4 e7e5}] 0]}] ""
# A book line need not stop at the draw: the move after the third occurrence
# belongs to a game the tournament has already drawn, and must not move the
# adjudication off the drawn move.
set threefoldTail [concat $threefoldLine {e2e4 e7e5}]
checkEq "a draw inside a longer line still falls on move 8" \
    [call {::comp::threefoldPosition [lindex [::comp::bookLineJournal startpos $threefoldTail] 0]}] 8
# When two positions both reach threefold, the draw is the one whose third
# occurrence comes first, not the position that first appears earliest. The
# start position repeats at plies 0/12/16 here, but the Nf3 position repeats at
# 1/5/9, so the game draws on move 9.
set shuffleLine {g1f3 g8f6 f3h4 f6g8 h4f3 g8f6 f3h4 f6g8 h4f3 g8f6 f3g1 f6g8 g1f3 g8f6 f3g1 f6g8}
checkEq "the earliest third occurrence draws, not the first position's" \
    [call {::comp::threefoldPosition [lindex [::comp::bookLineJournal startpos $shuffleLine] 0]}] 9

# compNM's setup path: `update` is a Tk command here, the engines and the save
# are the tournament's I/O, so both are stubbed. Nothing else in the run calls
# compNM, so the stubs stay for the rest of the file.
proc update {} {}
namespace eval ::engineNoWin {}
set ::engineInits {}
proc ::engineNoWin::initEngine {id engine args} {
    lappend ::engineInits [list $id $engine]
    return 1
}
proc ::engineNoWin::closeEngine {id} {}
set ::gamesSaved {}
proc ::comp::compSaveGame {game} { lappend ::gamesSaved $game }

proc pendingScripts {} {
    set out {}
    foreach id [after info] { lappend out [lindex [after info $id] 0] }
    return $out
}

proc tournamentSetup {game moves} {
    set ::comp::_Data(timecontrol) pergame
    set ::comp::_Data(base) 60
    set ::comp::_Data(incr) 0
    # the .bin reader is the app's opening book; the line it hands back is what
    # the setup under test sees, and makeBookLine (real) plays it into the board.
    set ::comp::_Data(usebook) 1
    set ::comp::_Data(bookTyp) bin
    set ::comp::_Data(fen,$game) startpos
    set ::comp::_Data(moves,$game) $moves
    set ::comp::_Data(comments,$game) {}
    set ::comp::_Data(runninggames) 1
}
proc ::comp::readBookLine {game} { return $::bookLineUnderTest }

set ::engineInits {}
set ::bookLineUnderTest $threefoldLine
tournamentSetup 7 {}
set err [catch {compNM 7 White Black 1} res]
checkEq "a threefold book line is set up without an error" $err 0
checkEq "it is adjudicated a draw at setup" [call {set ::comp::_Data(result,7)}] "="
checkEq "with the in-game wording" [call {lindex $::comp::_Data(comments,7) end}] "Book - 3-fold repetion"
checkEq "the comment sits on the line's last move" \
    [call {expr {[llength $::comp::_Data(comments,7)] == [llength $::comp::_Data(moves,7)]}}] 1
checkEq "no engine is started" [llength $::engineInits] 0
check "no move is scheduled" [expr {[string first compNextMove [pendingScripts]] < 0}]
checkEq "and the drawn game is saved" $::gamesSaved 7

# The book line can run on past the third occurrence. The game is drawn on move
# 8, so the saved moves stop there: writing the whole line played e2e4 into the
# PGN and put the note on that move instead.
set ::engineInits {}
set ::gamesSaved {}
set ::bookLineUnderTest $threefoldTail
tournamentSetup 9 {}
set err [catch {compNM 9 White Black 1} res]
checkEq "a line that runs past the draw is set up without an error" $err 0
checkEq "it is adjudicated a draw at setup" [call {set ::comp::_Data(result,9)}] "="
checkEq "the saved moves stop at the drawn move" \
    [call {llength $::comp::_Data(moves,9)}] 8
checkEq "which is the line's eighth move" \
    [call {lindex $::comp::_Data(moves,9) end}] f6g8
check "the move played after the draw is not saved" \
    [expr {[lsearch -exact $::comp::_Data(moves,9) e2e4] < 0}]
checkEq "the note is on the drawn move" \
    [call {llength $::comp::_Data(comments,9)}] 8
checkEq "with the in-game wording" \
    [call {lindex $::comp::_Data(comments,9) end}] "Book - 3-fold repetion"
checkEq "no engine is started" [llength $::engineInits] 0
check "no move is scheduled" [expr {[string first compNextMove [pendingScripts]] < 0}]
checkEq "and the drawn game is saved" $::gamesSaved 9

# A line that is not a threefold still goes to the engines.
set ::engineInits {}
set ::gamesSaved {}
set ::bookLineUnderTest {e2e4 e7e5}
tournamentSetup 8 {}
catch {compNM 8 White Black 1} res
checkEq "an ordinary book line is not adjudicated" [call {set ::comp::_Data(result,8)}] "*"
checkEq "both engines are started for it" [llength $::engineInits] 2

puts "\ntime per move"
set ::comp::_Data(timecontrol) permove
set ::comp::_Data(time) 1000
checkEq "1.75 s of a 1 s clock is still in time" [call {::comp::moveOverrun 1750}] 0
checkEq "the grace keeps a 1.8 s first move alive on a 1 s clock" \
    [call {::comp::moveOverrun 1800}] 0
checkEq "the grace ends at 2.75 s for a 1 s clock" [call {::comp::moveOverrun 2750}] 0
checkEq "2.75 s and a tick is too late" [call {::comp::moveOverrun 2751}] 1
set ::comp::_Data(time) 500
checkEq "a 0.5 s clock allows 1.875 s" [call {::comp::moveOverrun 1875}] 0
checkEq "and not 1.9 s" [call {::comp::moveOverrun 1900}] 1
set ::comp::_Data(timecontrol) pergame
set ::comp::_Data(time) 1000
checkEq "time per game never adjudicates on the reply time" \
    [call {::comp::moveOverrun 600000}] 0
# The allowance itself is zero when _Data(time) was never set: startComp assigns
# it for a time-per-move control only, and the default control is per-game.
unset -nocomplain ::comp::_Data(time)
checkEq "no _Data(time) means no allowance, not an error" [call {::comp::permoveAllowed}] 0
set ::comp::_Data(time) 1000

# The loss comment is written in seconds: "950 secs" for an 0.95 s clock was a
# millisecond value, and a reader of the saved game cannot tell.
set ::comp::_Data(timecontrol) permove
set ::comp::_Data(time) 1000
set ::comp::_Data(comments,3) {}
set ::comp::_Data(mate,3) 0
set ::comp::_Data(score,3) 0.0
set ::comp::_Data(result,3) "*"
set ::comp::_Data(moves,3) {}
catch {::comp::compCheckMove 3 white 2800 "Time out"}
set comment [lindex $::comp::_Data(comments,3) 0]
checkMatch "the loss comment names the seconds it took" $comment {*2.80 secs*}
checkMatch "and the time the engine was allowed" $comment {*allowed 2.75 secs*}
check "the raw millisecond count is gone" [expr {[string first 2800 $comment] < 0}]

puts "\nthe tournament's own move path"
# ::comp::compCheckMove is where the key is built for real: a played move has to
# come back accepted, land in the move list, and carry its en-passant square.
proc playMove {game move} {
    set ::comp::_Data(timecontrol) pergame
    set ::comp::_Data(incr50) 50
    set ::comp::_Data(white,$game) 60000
    set ::comp::_Data(black,$game) 60000
    set ::comp::_Data(board,$game) $::START
    set ::comp::_Data(moves,$game) {}
    set ::comp::_Data(comments,$game) {}
    set ::comp::_Data(repetition,$game) [list [::comp::startPositionKey startpos]]
    lassign [::comp::stateFromPosition startpos $::comp::_Data(board,$game)] r e
    set ::comp::_Data(crights,$game) $r
    set ::comp::_Data(epsq,$game) $e
    set ::comp::_Data(score,$game) 0.0
    set ::comp::_Data(scoreIsNew,$game) 0
    set ::comp::_Data(showscores,$game) 0
    set ::comp::_Data(showBoards,$game) 0
    set ::comp::_Data(showtimes,$game) 0
    set ::comp::_Data(mate,$game) 0
    set ::comp::_Data(moves50,$game) 0
    set ::comp::_Data(material,$game) {}
    set ::comp::_Data(pawns,$game) {}
    set ::comp::_Data(playing,$game) 1
    return [::comp::compCheckMove $game white 100 $move]
}

checkEq "a played move is accepted" [call {playMove 4 e2e4}] 1
checkEq "it lands in the move list" [call {set ::comp::_Data(moves,4)}] e2e4
checkEq "and a double push nobody can answer records no ep square" \
    [call {set ::comp::_Data(epsq,4)}] -
checkEq "castling rights survive an ordinary pawn move" \
    [call {set ::comp::_Data(crights,4)}] KQkq

puts "\nthe engine reply handler"
# The overrun test used to be handed $_Data(time) at the call site
# (::comp::eng_messages, "InfoBestMove"). startComp sets that element for a
# time-per-move control only, so on the default per-game tournament the handler
# raised -- after cancelling compTimeout and before compNextMove -- and the
# engine's move was dropped for the rest of the game. Drive the handler itself.
namespace eval ::engine {}
set ::sent {}
proc ::engine::send {id cmd args} { lappend ::sent [list $id $cmd $args] }

proc replyFixture {game} {
    set ::comp::_Data(timecontrol) pergame
    unset -nocomplain ::comp::_Data(time)
    set ::comp::_Data(incr50) 50
    set ::comp::_Data(delta) 4000
    set ::comp::_Data(paused) 0
    set ::comp::_Data(showscores) 0
    set ::comp::_Data(showtimes) 0
    set ::comp::_Data(showBoards) 0
    set ::comp::_Data(white,$game) 60000
    set ::comp::_Data(black,$game) 60000
    set ::comp::_Data(board,$game) $::START
    set ::comp::_Data(moves,$game) {}
    set ::comp::_Data(comments,$game) {}
    # Procedures a copy of the file may not have: the handler checks below must
    # still run (and FAIL) against an older file, not abort the run.
    if {[llength [info commands ::comp::startPositionKey]]} {
        set ::comp::_Data(repetition,$game) [list [::comp::startPositionKey startpos]]
    } else {
        set ::comp::_Data(repetition,$game) {}
    }
    set r ""
    set e ""
    if {[llength [info commands ::comp::stateFromPosition]]} {
        lassign [::comp::stateFromPosition startpos $::START] r e
    }
    set ::comp::_Data(crights,$game) $r
    set ::comp::_Data(epsq,$game) $e
    set ::comp::_Data(score,$game) 0.0
    set ::comp::_Data(scoreIsNew,$game) 0
    set ::comp::_Data(mate,$game) 0
    set ::comp::_Data(moves50,$game) 0
    set ::comp::_Data(material,$game) {}
    set ::comp::_Data(pawns,$game) {}
    set ::comp::_Data(playing,$game) 1
    set ::comp::_Data(result,$game) "*"
    set ::comp::_Data(fen,$game) startpos
    set ::comp::_Data(lasttime,$game) [clock clicks -milli]
}

replyFixture 5
set ::sent {}
set err [catch {::comp::eng_messages compEnginewhite5 .nowin {InfoBestMove e2e4}} res]
checkEq "a per-game bestmove is processed" $err 0
checkEq "the engine's move is played" [call {set ::comp::_Data(moves,5)}] e2e4
checkEq "the game keeps going" [call {set ::comp::_Data(playing,5)}] 1
check "the next move is asked for" [expr {[llength $::sent] > 0}]
checkMatch "with a per-game clock" [lindex $::sent 0] {*wtime*btime*}
check "not a movetime" [expr {[string first movetime $::sent] < 0}]
check "and a new timeout is armed" [expr {[llength [after info]] > 0}]

# The same handler must still adjudicate a time-per-move overrun.
replyFixture 6
set ::comp::_Data(timecontrol) permove
set ::comp::_Data(time) 100
set ::comp::_Data(lasttime,6) [expr {[clock clicks -milli] - 5000}]
catch {::comp::eng_messages compEnginewhite6 .nowin {InfoBestMove e2e4}} res
checkEq "a per-move overrun is still a loss" [call {set ::comp::_Data(result,6)}] 0
checkEq "and that move is not played" [call {set ::comp::_Data(moves,6)}] {}

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
