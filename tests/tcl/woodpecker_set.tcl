#!/usr/bin/env tclsh
# Woodpecker sets on disk: the data folder (default, chosen, missing), moving
# sets to a new folder, the token kept local, folder names, level counts.

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

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl utils chessboard.tcl]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools woodpecker_core.tcl]
source [file join $root tcl tools woodpecker_set.tcl]

set tmp [file join [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}] wp_set_[pid]]
file delete -force $tmp
file mkdir $tmp
set ::scidUserDir [file join $tmp user]
file mkdir $::scidUserDir

# --------------------------------------------------------------- the folder ----
set ::woodpecker::dataDir ""
checkEq "by default the data live in Scid's user folder" [::woodpecker::set::rootDir] [file join $::scidUserDir woodpecker]
check "the folder explains itself" {[file exists [file join $::scidUserDir woodpecker README.txt]]}

set cloud [file join $tmp Dropbox Scid]
file mkdir $cloud
set ::woodpecker::dataDir $cloud
checkEq "a chosen folder holds a woodpecker subfolder" [::woodpecker::set::rootDir] [file join $cloud woodpecker]
check "with its own README" {[file exists [file join $cloud woodpecker README.txt]]}
set ::woodpecker::dataDir [file join $cloud woodpecker]
checkEq "a folder already called woodpecker is used as it is" [::woodpecker::set::dataRoot] [file join $cloud woodpecker]
set ::woodpecker::dataDir [file join $tmp NotMounted]
check "a chosen folder that is missing is an error, not the default" {[catch {::woodpecker::set::rootDir}]}
check "and nothing is created in its place" {![file exists [file join $tmp NotMounted]]}

# ------------------------------------------------------------------ the token ----
set ::woodpecker::dataDir $cloud
::woodpecker::set::tokenWrite lip_abc123
checkEq "the token is read back" [::woodpecker::set::tokenRead] lip_abc123
checkEq "it stays in Scid's own folder" [file dirname [::woodpecker::set::tokenPath]] [file join $::scidUserDir woodpecker]
check "never in the synchronised folder" {![file exists [file join $cloud woodpecker token.txt]]}
if {$tcl_platform(platform) eq "unix"} {
    # 0600: Tcl 8.6 prints the mode as 00600 and Tcl 9 as 0o600, so compare
    # the permission bits themselves rather than either spelling.
    checkEq "readable by its owner only" \
        [format %o [file attributes [::woodpecker::set::tokenPath] -permissions]] 600
}
check "a malformed token is refused" {[catch {::woodpecker::set::tokenWrite "not a token"}]}
check "no temporary token file is left" {![llength [glob -nocomplain -directory [file dirname [::woodpecker::set::tokenPath]] token.txt.*]]}
::woodpecker::set::tokenWrite lip_second
checkEq "a new token replaces the old one" [::woodpecker::set::tokenRead] lip_second
if {$tcl_platform(platform) eq "unix"} {
    checkEq "still owner-only after replacing" \
        [format %o [file attributes [::woodpecker::set::tokenPath] -permissions]] 600
}
check "the create link asks for puzzle:read" \
    {[string first {scopes[]=puzzle:read} [::woodpecker::set::tokenCreateUrl]] >= 0}

# --------------------------------------------------------------- set folders ----
set ::woodpecker::dataDir ""
set now [clock scan "2026-11-17 10:00" -format "%Y-%m-%d %H:%M"]
set d1 [::woodpecker::set::newDir "My first set!" $now]
checkEq "a set folder: date, then the name" [file tail $d1] "2026-11-17-my-first-set"
set d2 [::woodpecker::set::newDir "My first set!" $now]
checkEq "the same name twice gets a number" [file tail $d2] "2026-11-17-my-first-set-2"
checkEq "a name without letters" [file tail [::woodpecker::set::newDir "???" $now]] "2026-11-17-set"
foreach d [list $d1 $d2] {
    ::woodpecker::writeMeta $d [dict create name [file tail $d] created 2026-11-17]
    ::woodpecker::appendLine [file join $d log.tsv] {X 1 1 1 1 clean 1 1000}
}
checkEq "a folder without set.tsv is not a set" [llength [::woodpecker::set::setDirs [::woodpecker::set::rootDir]]] 2

# ---------------------------------------------------- moving to a new folder ----
set old [::woodpecker::set::rootDir]
set new [file join $cloud woodpecker]
file mkdir [file join $new 2026-11-17-my-first-set-2]
::woodpecker::writeMeta [file join $new 2026-11-17-my-first-set-2] [dict create name other]
lassign [::woodpecker::set::moveSets $old $new] moved skipped
checkEq "one set moved, one already there" [list $moved $skipped] {1 1}
check "the moved set is in the new folder with its log" {[file exists [file join $new 2026-11-17-my-first-set log.tsv]]}
check "and gone from the old one" {![file exists $d1]}
check "the one already there was not overwritten" {[dict get [::woodpecker::readMeta [file join $new 2026-11-17-my-first-set-2]] name] eq "other"}
check "and the old copy of it stays" {[file exists $d2]}

# ---------------------------------------------------------------- level counts ----
checkEq "level counts add up" [::woodpecker::set::levelCounts 10 {easier 25 normal 60 harder 15}] {easier 3 normal 6 harder 1}
checkEq "one level takes all" [::woodpecker::set::levelCounts 7 {normal 1}] {normal 7}
check "no level is an error" {[catch {::woodpecker::set::levelCounts 5 {}}]}

# ---------------------------------------------------------- bundled puzzles ----
set pdir [file join $root puzzles]
set games 0
foreach file [glob -directory $pdir set-*.pgn] {
    set f [open $file r]
    incr games [regexp -all -line {^\[Event } [read $f]]
    close $f
}
set pool [::woodpecker::set::readPool $pdir]
checkEq "the pool is the union of every set file" [llength $pool] $games
set flipBad {}
foreach g $pool {
    set black [expr {[::woodpecker::fenSide [dict get $g FEN]] eq "b"}]
    if {![dict exists $g FlipB] || [dict get $g FlipB] != $black} { lappend flipBad [dict get $g PuzzleId] }
}
checkEq "FlipB is 1 exactly when Black is to move" [lrange $flipBad 0 4] {}

# The loader's conversion against the manifest, which holds the UCI solution.
set f [open [file join $pdir manifest.csv] r]
set head [split [gets $f] ,]
set manifest [dict create]
while {[gets $f line] >= 0} {
    set row [split $line ,]
    dict set manifest [lindex $row [lsearch $head PuzzleId]] [lindex $row [lsearch $head SolutionUCI]]
}
close $f
set convBad {}
foreach g $pool {
    if {[incr _k] % 200 != 1} { continue }
    set ex [::woodpecker::set::bundledExercise $g]
    set after [::chessboard::toFen [::chessboard::makeMove [::chessboard::fromFen [dict get $g SourceFEN]] [dict get $ex lastMove]]]
    if {[dict get $ex solution] ne [dict get $manifest [dict get $ex id]] \
            || [lindex $after 0] ne [lindex [dict get $ex fen] 0]} { lappend convBad [dict get $ex id] }
}
checkEq "solution and last move match the manifest (30 puzzles)" $convBad {}
set ex [::woodpecker::set::bundledExercise [lindex $pool 0]]
checkEq "the exercise links the game at the puzzle's move" "https://lichess.org/[dict get $ex gameId]" \
    [string map {lichess.org/game/ lichess.org/} [dict get [lindex $pool 0] GameUrl]]

# The marks shipped with the puzzles (puzzles/marks.tsv): one line per puzzle,
# one mark per solver move, only ! !! or nothing.
set bm [::woodpecker::set::readBundledMarks $pdir]
checkEq "marks.tsv has one line per pool puzzle" [dict size $bm] [llength $pool]
set markBad {}
set oddMark {}
foreach g $pool {
    set plies 0
    foreach tok [dict get $g moves] {
        regsub {^\d+\.+} $tok "" tok
        if {$tok eq "" || $tok in {* 1-0 0-1 1/2-1/2}} { continue }
        incr plies
    }
    set id [dict get $g PuzzleId]
    if {![dict exists $bm $id] || [llength [dict get $bm $id]] != ($plies + 1) / 2} { lappend markBad $id; continue }
    foreach m [dict get $bm $id] { if {$m ni {"" ! !!}} { lappend oddMark $id } }
}
checkEq "every puzzle has one mark per solver move" [lrange $markBad 0 4] {}
checkEq "marks are only ! !! or nothing" [lrange $oddMark 0 4] {}
set ex [::woodpecker::set::bundledExercise [lindex $pool 0] $bm]
checkEq "an exercise carries its marks" [dict get $ex marks] [dict get $bm [dict get $ex id]]
set ex [::woodpecker::set::bundledExercise [lindex $pool 0] [dict create [dict get [lindex $pool 0] PuzzleId] {! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !}]]
check "marks of the wrong length are not trusted" [expr {![dict exists $ex marks]}]
check "a puzzle without marks is still an exercise" [expr {![dict exists [::woodpecker::set::bundledExercise [lindex $pool 0]] marks]}]

set ::woodpecker::dataDir ""
proc inBand {exs rating level {extra 0}} {
    set centre [expr {$rating + [::woodpecker::levelDelta $level]}]
    set w [expr {[::woodpecker::levelWindow $centre] + $extra}]
    foreach e $exs {
        if {[dict get $e level] eq $level && abs([dict get $e rating] - $centre) > $w} { return 0 }
    }
    return 1
}
proc levelsOf {exs} {
    set c [dict create]
    foreach e $exs { dict incr c [dict get $e level] }
    return [lsort -stride 2 $c]
}
set spec [dict create count 100 shares [::woodpecker::presetShares standard] rating 1500 seed 7]
lassign [::woodpecker::set::fetchBundled $spec "" $pdir] exs short
checkEq "standard at 1500: the shares become counts" [levelsOf $exs] {easier 25 harder 15 normal 60}
checkEq "and nothing is missing" $short {}
checkEq "every drawn puzzle comes with its marks" [llength [lmap e $exs { if {[dict exists $e marks]} continue; set e }]] 0
check "each level stays in its band" {[inBand $exs 1500 easier] && [inBand $exs 1500 normal] && [inBand $exs 1500 harder]}
set ratings {}
foreach e $exs { lappend ratings [dict get $e rating] }
checkEq "easiest first" $ratings [lsort -integer $ratings]
lassign [::woodpecker::set::fetchBundled $spec "" $pdir] again
checkEq "the same seed draws the same puzzles" [lmap e $again {dict get $e id}] [lmap e $exs {dict get $e id}]

# A set made of them: the next draw never repeats its puzzles.
set sd [::woodpecker::set::newDir "bundled" $now]
set rows [dict create]
set i 0
foreach e $exs {
    incr i
    dict set rows $i [::woodpecker::exerciseRow $i $i [dict get $e id] [dict get $e rating] \
        [dict get $e fen] [dict get $e solution] [dict get $e lastMove]]
}
::woodpecker::writeExercises $sd $rows
::woodpecker::writeMeta $sd [dict create name bundled created 2026-11-20]
lassign [::woodpecker::set::fetchBundled [dict replace $spec seed 8] "" $pdir] next
set ids [lmap e $exs {dict get $e id}]
checkEq "no puzzle repeated across sets" [llength [lmap e $next {expr {[dict get $e id] in $ids ? 1 : [continue]}}]] 0

# Across a change of density (sets 6 and 7 meet at 2450) the draw stays even in
# rating: 2000 + harder is centred on 2300, band 2000-2600.
lassign [::woodpecker::set::fetchBundled [dict create count 100 shares {harder 1} rating 2000 seed 5] "" $pdir] hx
set hr [lsort -integer [lmap e $hx {dict get $e rating}]]
check "a band across 2450 is drawn evenly in rating (median [lindex $hr 50])" {abs([lindex $hr 50] - 2300) <= 60}

lassign [::woodpecker::set::fetchBundled [dict create count 60 shares {hardest 1} rating 2500 color black] "" $pdir] top short
checkEq "2500 and hardest: clipped to the top of the pool, not empty" [llength $top] 60
set topMax [tcl::mathfunc::max {*}[lmap g $pool {dict get $g LichessRating}]]
check "from the top of the pool" {[tcl::mathfunc::min {*}[lmap e $top {dict get $e rating}]] >= $topMax - [::woodpecker::levelWindow 3100]}
check "only black to move, as asked" {[llength [lmap e $top {expr {[::woodpecker::fenSide [dict get $e fen]] eq "b" ? [continue] : 1}}]] == 0}

lassign [::woodpecker::set::fetchBundled [dict create count 40 shares {normal 1} rating 1500 angle castling] "" $pdir] dbl short
check "a theme takes only puzzles with it" {[llength [lmap e $dbl {expr {"castling" in [dict get $e themes] ? [continue] : 1}}]] == 0}
checkEq "the band widens by 100 before a shortfall" [inBand $dbl 1500 normal 100] 1
checkEq "what is missing is counted per level" [expr {[llength $dbl] + ([dict exists $short normal] ? [dict get $short normal] : 0)}] 40
check "a thin theme comes up short" {[dict exists $short normal]}

# The identity a database edit is matched by, and the number a new exercise
# may take: never one that marks.tsv or log.tsv still names.
checkEq "a Lichess exercise is identified by its puzzle id" \
    [::woodpecker::set::exerciseUid [dict create puzzleId abc fen f solution {a1a2}]] p:abc
checkEq "a book exercise by position and solution" \
    [::woodpecker::set::exerciseUid [dict create puzzleId "" fen f solution {a1a2}]] "f:f|a1a2"
set idset [file join $tmp idset]
file mkdir $idset
::woodpecker::writeExercises $idset [dict create \
    1 [::woodpecker::exerciseRow 1 1 a 1500 f {a1a2} ""] \
    4 [::woodpecker::exerciseRow 4 4 b 1500 g {b1b2} ""]]
::woodpecker::marksAppend $idset [dict create 5 [dict create marks {"!"} source review]]
::woodpecker::logExercise $idset 100 1 1 7 clean 1 1000
checkEq "a new number skips the history" \
    [::woodpecker::set::maxExerciseId $idset [::woodpecker::readExercises $idset]] 7
::woodpecker::resetLog $idset 100
checkEq "and the history a reset put aside" \
    [::woodpecker::set::maxExerciseId $idset [::woodpecker::readExercises $idset]] 7
::woodpecker::logScope $idset 200 1 "1 9 *" 7
checkEq "and the numbers an inner circle names" \
    [::woodpecker::set::maxExerciseId $idset [::woodpecker::readExercises $idset]] 9

# ------------------------------------------------ a file's exercise count ----
set pgn [file join $tmp book.pgn]
set f [open $pgn w]
puts $f {[Event "1"]
[SetUp "1"]
[FEN "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1"]

1. Ra8# 1-0

[Event "2"]

1. e4 e5 1-0

[Event "3"]
[FEN "6k1/5ppp/8/8/8/8/5PPP/R5K1 w - - 0 1"]

1. Ra8# 1-0
}
close $f
checkEq "a PGN counts its games with a set-up position" [::woodpecker::set::countFileExercises $pgn] 2
checkEq "a Scid database is not read" [::woodpecker::set::countFileExercises [file join $tmp book.si5]] ""
checkEq "a missing file counts nothing" [::woodpecker::set::countFileExercises [file join $tmp none.pgn]] ""

file delete -force $tmp
puts "$checks checks, $fails failures"
exit [expr {$fails > 0}]
