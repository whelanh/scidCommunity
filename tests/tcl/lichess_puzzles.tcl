#!/usr/bin/env tclsh
# SPDX-License-Identifier: GPL-2.0-or-later
#
# lichess_puzzles.tcl -- what the Lichess Puzzles window asks lichess.org for,
# without a network and without Tk.
#
#   tclsh tests/tcl/lichess_puzzles.tcl
#
# The module is sourced for real. Its window is replaced by a handful of
# widget stubs (the two comboboxes answer `current`), parseAndLoad by a
# recorder, and httpGet by a fake Lichess that serves puzzles of a known side
# (initialPly) and logs every URL. httpGet itself is tested first, on its own,
# against a fake curl, a local HTTP server (the Tcl http path) and a fake
# powershell, for the User-Agent Lichess asks every client to send.
#
# Lichess accepts difficulty = easiest | easier | normal | harder | hardest
# on /api/puzzle/next and /api/puzzle/batch/{angle}; anything else is served
# as "normal" (lila PuzzleDifficulty.orDefault). So the property checked is:
# each Difficulty menu entry produces a request with its own, valid value.

set fails 0
set checks 0
proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok    $label"
    } else {
        incr ::fails
        if {$detail eq ""} { puts "  FAIL  $label" } else { puts "  FAIL  $label -- $detail" }
    }
}
proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}
proc checkHas {label haystack needle} {
    check $label [expr {[string first $needle $haystack] >= 0}] "'$needle' is not in '$haystack'"
}
proc section {title} { puts "\n$title" }

set apiDiffs {easiest easier normal harder hardest}

# --------------------------------------------------------------- environment --

set root [file normalize [file join [file dirname [info script]] .. ..]]
set tmpBase [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}]
set tmp [file join $tmpBase "lichess_puzzles_test_[pid]"]
file delete -force $tmp
file mkdir $tmp
set ::scidDataDir $tmp

# options.store as tcl/options.tcl defines it: a saved value, already set by
# options.dat when the module is sourced, wins over the default.
proc options.store {varname {default_value ""}} {
    if {![info exists $varname]} { set $varname $default_value }
}

# Translations: the real english.tcl through the same small shim the Lichess
# study harness uses; sourcing it also proves the tags the module asks for exist.
array set ::tr {}
array set ::menuLabel {}
array set ::translations {}
proc menuText {lang tag label underline {helpMsg ""}} { set ::menuLabel($lang,$tag) $label }
proc helpMsg {lang button message} {}
proc translate {lang tag label} {
    regsub -all {\\n} $label "\n" label
    set ::translations($lang,$tag) $label
    set ::tr($tag) $label
}
proc tr {tag {lang ""}} {
    if {[info exists ::menuLabel(E,$tag)]} { return $::menuLabel(E,$tag) }
    if {[info exists ::tr($tag)]} { return $::tr($tag) }
    return $tag
}
set ::optionsFile ""
source -encoding utf-8 [file join $root tcl lang english.tcl]
setLanguage_E

set module [file join $root tcl tools lichess_puzzles.tcl]
proc loadModuleWith {saved} {
    if {$saved eq "-"} {
        unset -nocomplain ::lichess_puzzles::difficulty
    } else {
        namespace eval ::lichess_puzzles {}
        set ::lichess_puzzles::difficulty $saved
    }
    source -encoding utf-8 $::module
    return $::lichess_puzzles::difficulty
}

# ------------------------------------------------------ saved option values --

section "a saved difficulty is mapped onto the API's five when the module loads"
checkEq "no saved value: normal" [loadModuleWith -] normal
foreach v $apiDiffs {
    checkEq "saved $v stays $v" [loadModuleWith $v] $v
}
checkEq "saved easiestThenNormal (old menu) becomes easier" [loadModuleWith easiestThenNormal] easier
checkEq "saved normalThenHardest (old menu) becomes harder" [loadModuleWith normalThenHardest] harder
checkEq "an unknown saved value becomes normal" [loadModuleWith bogus] normal
checkEq "an empty saved value becomes normal" [loadModuleWith ""] normal

section "normalizeDifficulty"
foreach {in want} {
    easiest easiest easier easier normal normal harder harder hardest hardest
    easiestThenNormal easier normalThenHardest harder
    Normal normal "" normal hard normal
} {
    checkEq "'$in' -> $want" [::lichess_puzzles::normalizeDifficulty $in] $want
}

# ------------------------------------------------------------ menu labels --

section "the Difficulty menu: five entries, five API values, five labels"
checkEq "menu values are the API's, easiest first" $::lichess_puzzles::difficultyValues $apiDiffs
checkEq "one label key per value" [llength $::lichess_puzzles::diffLabelKeys] [llength $apiDiffs]
set labels {}
foreach key $::lichess_puzzles::diffLabelKeys {
    check "english.tcl defines $key" [info exists ::translations(E,$key)]
    lappend labels [tr $key]
}
checkEq "English labels" $labels {Easiest Easier Normal Harder Hardest}
foreach old {LichessPuzzlesDiffEasiestThenNormal LichessPuzzlesDiffNormalThenHardest} {
    check "english.tcl no longer defines $old" [expr {![info exists ::translations(E,$old)]}]
}

section "every language file carries the same five labels, all different"
set wantKeys [lsort [concat LichessPuzzlesDifficulty $::lichess_puzzles::diffLabelKeys]]
foreach f [lsort [glob -directory [file join $root tcl lang] *.tcl]] {
    set fd [open $f r]
    fconfigure $fd -encoding utf-8
    set text [read $fd]
    close $fd
    set keys {}
    array unset lab
    foreach {- key label} [regexp -all -inline -line \
            {^translate \S+ (LichessPuzzlesDiff\w*) \{(.*)\}$} $text] {
        lappend keys $key
        set lab($key) $label
    }
    if {![llength $keys]} { continue }
    set name [file rootname [file tail $f]]
    checkEq "$name: keys" [lsort $keys] $wantKeys
    set five {}
    foreach key $::lichess_puzzles::diffLabelKeys {
        if {[info exists lab($key)]} { lappend five $lab($key) }
    }
    checkEq "$name: five distinct labels" [llength [lsort -unique $five]] 5
}

# ------------------------------------------------------------ User-Agent --
# httpGet's three transports, each made the only one that can answer.

set ua $::lichess_puzzles::userAgent
checkHas "the User-Agent names the application" $ua scidCommunity

section "User-Agent: the curl path"
set bin [file join $tmp bin]
file mkdir $bin
set fcd [file join $tmp fake]
file mkdir $fcd
set ::env(FAKE_DIR) $fcd
set fc [open [file join $bin curl] w]
puts $fc {#!/bin/sh
printf '%s\n' "$@" > "$FAKE_DIR/curl_argv"
printf '%s' '{"ok":"curl"}'}
close $fc
file attributes [file join $bin curl] -permissions 0755
set savedPath $::env(PATH)
set ::env(PATH) "$bin:$savedPath"
unset -nocomplain ::auto_execs

proc readLines {path} {
    set fd [open $path r]
    set t [read $fd]
    close $fd
    return [split [string trimright $t "\n"] "\n"]
}

set r [::lichess_puzzles::httpGet https://lichess.org/api/puzzle/daily lip_tok]
checkEq "curl's answer is returned" $r {{"ok":"curl"}}
set argv [readLines [file join $fcd curl_argv]]
set i [lsearch -exact $argv -A]
check "curl is given -A" [expr {$i >= 0}] $argv
checkEq "...with the module's User-Agent" [lindex $argv [expr {$i + 1}]] $ua
check "the token still goes as a Bearer header" \
    [expr {[lsearch -exact $argv "Authorization: Bearer lip_tok"] >= 0}] $argv
checkEq "the URL is the last argument" [lindex $argv end] https://lichess.org/api/puzzle/daily

section "User-Agent: the Tcl http path"
# No curl and no powershell: only the http package can answer, here a local
# server that records the request's header lines.
set empty [file join $tmp emptybin]
file mkdir $empty
set ::env(PATH) $empty
unset -nocomplain ::auto_execs
package require http
set ::reqHeaders {}
proc srvAccept {chan addr port} {
    fconfigure $chan -translation crlf -blocking 0 -buffering line
    fileevent $chan readable [list srvRead $chan]
}
proc srvRead {chan} {
    if {[gets $chan line] < 0} {
        if {[eof $chan]} { close $chan }
        return
    }
    if {$line ne ""} { lappend ::reqHeaders $line; return }
    set body {{"ok":"http"}}
    fconfigure $chan -translation binary
    puts -nonewline $chan "HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nContent-Length: [string length $body]\r\nConnection: close\r\n\r\n$body"
    close $chan
}
set srv [socket -server srvAccept -myaddr 127.0.0.1 0]
set port [lindex [fconfigure $srv -sockname] 2]
set agentBefore [::http::config -useragent]
set r [::lichess_puzzles::httpGet "http://127.0.0.1:$port/api/puzzle/daily" lip_tok]
close $srv
checkEq "the server's answer is returned" $r {{"ok":"http"}}
set uaLines [lsearch -all -inline -nocase -glob $::reqHeaders "User-Agent:*"]
checkEq "exactly one User-Agent line" [llength $uaLines] 1
checkEq "...carrying the module's User-Agent" [string trim [lindex [split [lindex $uaLines 0] :] 1]] $ua
check "the token still goes as a Bearer header" \
    [expr {[lsearch -exact $::reqHeaders "Authorization: Bearer lip_tok"] >= 0}] $::reqHeaders
checkEq "the http package's own User-Agent is put back" [::http::config -useragent] $agentBefore

section "User-Agent: the PowerShell path"
# A refused connection makes the http package fail, so the Windows fallback is
# reached; the fake powershell records what it was given.
set fp [open [file join $bin powershell] w]
puts $fp {#!/bin/sh
printf '%s\n' "$LICHESS_PZ_UA" > "$FAKE_DIR/ps_ua"
printf '%s\n' "$@" > "$FAKE_DIR/ps_argv"
printf '%s' '{"ok":"powershell"}'}
close $fp
file attributes [file join $bin powershell] -permissions 0755
file delete [file join $bin curl]
set ::env(PATH) $bin
unset -nocomplain ::auto_execs
set ::windowsOS 1
set closed [socket -server {apply {args {}}} -myaddr 127.0.0.1 0]
set deadPort [lindex [fconfigure $closed -sockname] 2]
close $closed
set r [::lichess_puzzles::httpGet "http://127.0.0.1:$deadPort/api/puzzle/daily"]
checkEq "powershell's answer is returned" $r {{"ok":"powershell"}}
checkEq "powershell sees the module's User-Agent" [lindex [readLines [file join $fcd ps_ua]] 0] $ua
checkHas "...passed with -UserAgent (PS 5.1 refuses it in -Headers)" \
    [join [readLines [file join $fcd ps_argv]] " "] {-UserAgent $env:LICHESS_PZ_UA}
check "the environment variable is removed afterwards" [expr {![info exists ::env(LICHESS_PZ_UA)]}]
set ::windowsOS 0
set ::env(PATH) $savedPath
unset -nocomplain ::auto_execs

# ----------------------------------------------------------- fake window --

proc winfo {args} { return 1 }
foreach w {.lichessPuzzlesWin.info.title .lichessPuzzlesWin.msgframe.msg} {
    proc $w {args} {}
}
set ::menuIdx 2
set ::colorIdx 0
proc .lichessPuzzlesWin.controls.diff {cmd args} { return $::menuIdx }
proc .lichessPuzzlesWin.controls.color {cmd args} { return $::colorIdx }
set ::boxes {}
proc tk_messageBox {args} { lappend ::boxes $args; return ok }

set ::loaded {}
proc ::lichess_puzzles::parseAndLoad {json} { lappend ::loaded $json; return 1 }

# ----------------------------------------------------------- fake Lichess --
# /next and /batch answer with fresh puzzle ids. ::serve decides the side of
# each puzzle: "asked" honours the URL's color, "alternate" ignores it and
# alternates white, black, white...

set ::urls {}
set ::serial 0
set ::serve asked
set ::alt 0
proc urlParam {url name} {
    if {[regexp "\[?&\]$name=(\[^&\]*)" $url -> v]} { return $v }
    return ""
}
proc fakePuzzle {color} {
    incr ::serial
    if {$::serve eq "alternate"} {
        set color [expr {[incr ::alt] % 2 ? "white" : "black"}]
    }
    # an even initialPly leaves Black to move
    set ply [expr {$color eq "black" ? 20 : 21}]
    return "{\"game\":{\"id\":\"g$::serial\",\"pgn\":\"e4 e5\"},\"puzzle\":{\"id\":\"p$::serial\",\"rating\":1500,\"initialPly\":$ply,\"solution\":\[\"e2e4\"\],\"themes\":\[\"fork\"\]}}"
}
proc ::lichess_puzzles::httpGet {url {token ""}} {
    lappend ::urls $url
    set color [urlParam $url color]
    if {[string match "https://lichess.org/api/puzzle/next?*" $url]} {
        return [fakePuzzle $color]
    }
    if {[string match "https://lichess.org/api/puzzle/batch/*" $url]} {
        set nb [urlParam $url nb]
        set items {}
        for {set i 0} {$i < $nb} {incr i} { lappend items [fakePuzzle $color] }
        return "{\"puzzles\":\[[join $items ,]\]}"
    }
    # /api/puzzle/{id}, asked for the FEN
    return "{\"puzzle\":{\"id\":\"x\",\"fen\":\"8/8/8/8/8/8/8/8 w - - 0 1\"}}"
}
proc puzzleUrls {} {
    return [lsearch -all -inline -regexp $::urls {/api/puzzle/(next|batch)}]
}
proc freshFetch {} {
    set ::lichess_puzzles::puzzleQueue {}
    set ::urls {}
    set ::loaded {}
    ::lichess_puzzles::fetchNextPuzzle
    update   ;# the queue refill is scheduled with after idle
}

set ::lichess_puzzles::apiToken lip_test
set ::lichess_puzzles::theme ""

# ---------------------------------------------------- menu -> request --

section "each Difficulty menu entry sends its own, valid difficulty"
set sent {}
for {set i 0} {$i < 5} {incr i} {
    set ::menuIdx $i
    ::lichess_puzzles::onDiffChange
    set v $::lichess_puzzles::difficulty
    freshFetch
    lassign [puzzleUrls] nextReq batchReq
    checkEq "entry $i ([lindex $labels $i]): /next request" \
        $nextReq "https://lichess.org/api/puzzle/next?difficulty=$v&color=white"
    checkEq "entry $i ([lindex $labels $i]): batch request" \
        $batchReq "https://lichess.org/api/puzzle/batch/mix?difficulty=$v&nb=30&color=white"
    check "entry $i: '$v' is one the API accepts" [expr {$v in $apiDiffs}]
    checkEq "entry $i: one puzzle loaded" [llength $::loaded] 1
    lappend sent [urlParam $nextReq difficulty]
}
checkEq "five entries, five distinct values, easiest first" $sent $apiDiffs

section "a stored old value is sent as its new equivalent"
set ::lichess_puzzles::difficulty normalThenHardest
freshFetch
checkEq "normalThenHardest is requested as harder" [urlParam [lindex [puzzleUrls] 0] difficulty] harder

section "a theme travels with the difficulty"
set ::lichess_puzzles::difficulty hardest
set ::lichess_puzzles::theme mateIn2
freshFetch
lassign [puzzleUrls] nextReq batchReq
checkEq "/next" $nextReq "https://lichess.org/api/puzzle/next?difficulty=hardest&angle=mateIn2&color=white"
checkEq "batch" $batchReq "https://lichess.org/api/puzzle/batch/mateIn2?difficulty=hardest&nb=30&color=white"
set ::lichess_puzzles::theme ""

# ------------------------------------------------------- jitter fallback --

section "the fallback walks the valid difficulties, nearest first"
foreach v $apiDiffs {
    set order [::lichess_puzzles::jitterOrder $v]
    checkEq "$v: starts with itself" [lindex $order 0] $v
    checkEq "$v: tries each API value once" [lsort $order] [lsort $apiDiffs]
}
checkEq "normal" [::lichess_puzzles::jitterOrder normal] {normal easier harder easiest hardest}
checkEq "easiest" [::lichess_puzzles::jitterOrder easiest] {easiest easier normal harder hardest}
checkEq "hardest" [::lichess_puzzles::jitterOrder hardest] {hardest harder normal easier easiest}
checkEq "an old value starts at its new equivalent" \
    [::lichess_puzzles::jitterOrder easiestThenNormal] {easier easiest normal harder hardest}

# Every /next answer is a puzzle already seen: the fallback must ask each
# valid difficulty once, and nothing else.
set ::lichess_puzzles::difficulty harder
rename ::lichess_puzzles::isSeen ::lichess_puzzles::isSeen_real
proc ::lichess_puzzles::isSeen {id} { return 1 }
freshFetch
set nexts [lsearch -all -inline -glob $::urls "*/api/puzzle/next?*"]
set tried {}
foreach u $nexts { lappend tried [urlParam $u difficulty] }
checkEq "all seen: each difficulty asked once, nearest first" $tried {harder normal hardest easier easiest}
checkEq "...and nothing is loaded" [llength $::loaded] 0
rename ::lichess_puzzles::isSeen {}
rename ::lichess_puzzles::isSeen_real ::lichess_puzzles::isSeen

# ---------------------------------------------------------------- colour --

section "the side to move comes from initialPly"
foreach {ply want} {0 black 1 white 20 black 21 white 41 white} {
    checkEq "initialPly $ply: $want" \
        [::lichess_puzzles::puzzleColor "{\"id\":\"a\",\"initialPly\":$ply}"] $want
}
checkEq "no initialPly: unknown" [::lichess_puzzles::puzzleColor {{"id":"a"}}] ""

section "a batch that ignores color: only the asked side is queued"
set ::lichess_puzzles::difficulty normal
set ::colorIdx 1
set ::serve alternate
set ::alt 1   ;# the first /next answer is Black, as asked
freshFetch
checkHas "the batch still asks for the colour" [lindex [puzzleUrls] 1] "&color=black"
set q $::lichess_puzzles::puzzleQueue
checkEq "15 of the 30 are queued" [llength $q] 15
set sides {}
foreach e $q { lappend sides [::lichess_puzzles::puzzleColor [lindex $e 0]] }
checkEq "all of them Black" [lsort -unique $sides] black
checkEq "queued under the black filter" [lindex $q 0 3] {normal {} black}
set ::urls {}
set ::loaded {}
::lichess_puzzles::fetchNextPuzzle
checkEq "the next puzzle comes from the queue: no /next request" \
    [lsearch -all -inline -glob $::urls "*/api/puzzle/next?*"] {}
checkHas "...and it is a Black one" [lindex $::loaded 0] {"initialPly":20}

section "a /next answer of the wrong side is not shown"
set ::alt 0   ;# the first /next answer is White although Black was asked
freshFetch
set nexts [lsearch -all -inline -glob $::urls "*/api/puzzle/next?*"]
checkEq "a second request follows" [llength $nexts] 2
checkEq "...at the nearest other difficulty" [urlParam [lindex $nexts 1] difficulty] easier
checkHas "the loaded puzzle is Black" [lindex $::loaded 0] {"initialPly":20}
set ::serve asked
set ::colorIdx 0

section "a batch that honours color: all 30 are kept"
freshFetch
checkEq "30 queued" [llength $::lichess_puzzles::puzzleQueue] 30

# ------------------------------------------------------- the game link (#531) --

# The detail pane is a plain Tk text widget, so its background is white whatever
# the theme; the link is still coloured by the widget rather than by a literal,
# so it follows the pane if it is ever themed.
section "the puzzle's game link takes its colour from the widget"
set fd [open $::module r]
set src [read $fd]
close $fd
checkHas "the link foreground comes from ::htext::linkColor" $src \
    {tag configure $linkTag -foreground [::htext::linkColor $t]}
check "no literal blue is left on the link" \
    [expr {[string first {$linkTag -foreground blue} $src] < 0}]

# ------------------------------------------------------------------- result --

file delete -force $tmp
puts "\nchecks $checks fails $fails"
exit [expr {$fails ? 1 : 0}]
