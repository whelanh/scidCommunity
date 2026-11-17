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
    checkEq "readable by its owner only" [file attributes [::woodpecker::set::tokenPath] -permissions] 00600
}
check "a malformed token is refused" {[catch {::woodpecker::set::tokenWrite "not a token"}]}
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

file delete -force $tmp
puts "$checks checks, $fails failures"
exit [expr {$fails > 0}]
