# SPDX-License-Identifier: GPL-2.0-or-later
#
# lichess_study_tk.tcl -- the Lichess study feature against a fake Lichess.
#
#   wish tests/tcl/lichess_study_tk.tcl
#   xvfb-run -a wish tests/tcl/lichess_study_tk.tcl   (no display)
#
# tcl/tools/lichess_study.tcl builds real Tk dialogs, so this
# harness runs under wish. Nothing reaches lichess.org:
#
#   * ::lichstudy::api is replaced by ::fake, an in-memory Lichess that keeps
#     studies and chapters and answers the endpoints the plugin calls with the
#     shapes of the Lichess API (import-pgn stops at 64 chapters with
#     "Too many chapters" inside an HTTP 200 answer, a new study starts with one
#     empty chapter, a multi-game PGN is split at a blank line followed by "[").
#   * the real ::lichstudy::api is tested on its own against a fake curl.
#   * sc_base / sc_game answer from a small fake database.
#   * tk_messageBox records what it was asked and answers from a queue.
#   * the "study is full" question (askOverflow, a modal vwait loop) is driven
#     by a script: each time it waits, the next step sets its fields and
#     presses a button.
#
# Scenarios: games into an existing study (1, several, exactly the free
# slots, 64), into a new study (1, several, 63, 64, empty chapter not found,
# retry after a failure), more games than the study can hold (abort, first
# only, split into a new study, full study, name validation, creation failure,
# count unavailable, a study filled meanwhile), HTTP and network errors, and
# the helpers (PGN cleanup, JSON unescape, error texts, study list, token,
# study added by link, curl invocation).
#
# A check marked XFAIL documents a known defect: it does not fail the run, and
# it prints XPASS once the defect is fixed, so it can become a plain check.

set fails 0
set checks 0
set xfails 0
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
proc checkHasNot {label haystack needle} {
    check $label [expr {[string first $needle $haystack] < 0}] "'$needle' is in '$haystack'"
}
proc xfail {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  XPASS $label (the known defect looks fixed: make this a plain check)"
    } else {
        incr ::xfails
        puts "  XFAIL $label -- $detail"
    }
}
proc section {title} { puts "\n$title" }

# --------------------------------------------------------------- environment --

set root [file normalize [file join [file dirname [info script]] .. ..]]
set tmpBase [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) : "/tmp"}]
set tmp [file join $tmpBase "lichstudy_test_[pid]"]
file delete -force $tmp
file mkdir $tmp
set ::scidUserDir $tmp
set ::language E

wm withdraw .

# Minimal translation support so the feature's [tr ...] calls resolve to the
# English strings (the real definitions live in tcl/language.tcl). Sourcing
# tcl/lang/english.tcl also proves every tag the feature uses actually exists.
array set ::tr {}
array set ::menuLabel {}
array set ::menuUnder {}
array set ::helpMessage {}
array set ::translations {}
proc menuText {lang tag label underline {helpMsg ""}} {
    set ::menuLabel($lang,$tag) $label
    set ::menuUnder($lang,$tag) $underline
    if {$helpMsg != ""} { set ::helpMessage($lang,$tag) $helpMsg }
}
proc helpMsg {lang button message} { set ::helpMessage($lang,$button) $message }
proc translate {lang tag label} {
    regsub -all {\\n} $label "\n" label
    set ::translations($lang,$tag) $label
    set ::tr($tag) $label
    foreach extra {":" "..."} { set ::tr("${tag}${extra}") "${label}${extra}" }
}
proc tr {tag {lang ""}} {
    if {$lang eq ""} { set lang E }
    if {[info exists ::menuLabel($lang,$tag)]} { return $::menuLabel($lang,$tag) }
    if {[info exists ::menuLabel(E,$tag)]} { return $::menuLabel(E,$tag) }
    if {[info exists ::tr($tag)]} { return $::tr($tag) }
    return $tag
}
# english.tcl's OptionsSave help text interpolates $::optionsFile.
set ::optionsFile ""
source -encoding utf-8 [file nativename [file join $root tcl lang english.tcl]]
setLanguage_E

# Multi-line messages must turn every \n into a real newline (no literal
# backslash-n left behind, which is what a non -all regsub would do).
section "translation newlines"
checkHasNot "LichessStudyReport has no literal backslash-n" [tr LichessStudyReport] {\\n}
checkHas "LichessStudyReport has real newlines" [tr LichessStudyReport] "\n\n"
checkHasNot "LichessStudyCreateFailed has no literal backslash-n" [tr LichessStudyCreateFailed] {\\n}
checkHas "LichessStudyCreateFailed has real newlines" [tr LichessStudyCreateFailed] "\n\n"

# tk_messageBox: record the call, answer from ::boxAnswers (else "no" to a
# yes/no question and "ok" to anything else).
set ::boxes {}
set ::boxAnswers {}
proc tk_messageBox {args} {
    lappend ::boxes $args
    if {[llength $::boxAnswers]} {
        set a [lindex $::boxAnswers 0]
        set ::boxAnswers [lrange $::boxAnswers 1 end]
        return $a
    }
    if {[dict exists $args -type] && [dict get $args -type] eq "yesno"} { return no }
    return ok
}
proc lastBox {} { return [lindex $::boxes end] }
proc boxField {box key} { if {[dict exists $box $key]} { return [dict get $box $key] }; return "" }

# A fake scid database. Base 1 holds 100 games, base 2 holds 3. Each game has
# CRLF line ends, a comment with a blank line, and a mark command that starts
# a line right after a blank line: without cleanGame, Lichess would split that
# game in two.
array set ::db {n,1 100 n,2 3}
array set ::cur {base 1 num 0 altered 0 pgn ""}
array set ::broken {}
set ::pgnCalls {}
proc dbGame {b n} {
    if {[info exists ::broken($b,$n)]} { return "Error: game $n is damaged" }
    set crlf "\r\n"
    return "\[Event \"Event $n\"\]$crlf\[White \"White$n\"\]$crlf\[Black \"Black$n\"\]$crlf\[Result \"*\"\]$crlf${crlf}1. e4 {first line$crlf$crlf\[%csl Gd4\] after a blank line} e5 \$1$crlf${crlf}2. Nf3 *$crlf"
}
proc sc_base {sub args} {
    switch -- $sub {
        current  { return $::cur(base) }
        numGames { return $::db(n,[lindex $args 0]) }
        inUse    { return [info exists ::db(n,[lindex $args 0])] }
    }
    error "sc_base $sub not faked"
}
proc sc_game {sub args} {
    switch -- $sub {
        number  { return $::cur(num) }
        altered { return $::cur(altered) }
        pgn {
            lappend ::pgnCalls $args
            if {[lindex $args 0] eq "-base"} {
                return [dbGame [lindex $args 1] [lindex $args 3]]
            }
            return $::cur(pgn)
        }
    }
    error "sc_game $sub not faked"
}

if {[catch {source [file join $root tcl tools lichess_study.tcl]} err]} {
    puts "FAIL cannot load the feature: $err\n$::errorInfo"
    exit 1
}

# Keep the real api for its own tests, open no browser.
rename ::lichstudy::api ::lichstudy::realApi
set ::opened {}
proc ::lichstudy::openLink {url} { lappend ::opened $url }

# ------------------------------------------------------------- fake Lichess --

namespace eval ::fake {
    variable studies [dict create]  ;# id -> {name owner writable updatedAt chapters}
    variable log {}                 ;# {method path data} for every request
    variable inject {}              ;# one-shot answers: {method pathRegexp result}
    variable seq 0
    variable user Tester
    variable beforeImport ""        ;# script run before each import-pgn
}

proc ::fake::reset {} {
    variable studies [dict create]
    variable log {}
    variable inject {}
    variable beforeImport ""
}

# Lichess ids are 8 characters.
proc ::fake::newId {prefix} {
    variable seq
    incr seq
    return [format "%s%07d" $prefix $seq]
}

proc ::fake::addStudy {name nChapters args} {
    variable studies
    variable user
    set id [newId S]
    set opts [dict merge [dict create owner $user writable 1 updatedAt [clock milliseconds]] $args]
    set chs {}
    for {set i 1} {$i <= $nChapters} {incr i} {
        lappend chs [dict create id [newId C] name "Old $i" orientation "" mode ""]
    }
    dict set studies $id [dict merge $opts [dict create name $name chapters $chs]]
    return $id
}

proc ::fake::chapters {id} {
    variable studies
    return [dict get $studies $id chapters]
}
proc ::fake::chapterNames {id} { return [lmap c [chapters $id] {dict get $c name}] }
proc ::fake::nChapters {id} { return [llength [chapters $id]] }
proc ::fake::exists {id} { variable studies; return [dict exists $studies $id] }

# Requests matching method and a regexp on the path.
proc ::fake::requests {method pathRe} {
    variable log
    set out {}
    foreach r $log {
        lassign $r m p
        if {($method eq "*" || $m eq $method) && [regexp -- $pathRe $p]} { lappend out $r }
    }
    return $out
}
proc ::fake::count {method pathRe} { return [llength [requests $method $pathRe]] }

proc ::fake::injectOnce {method pathRe result} {
    variable inject
    lappend inject [list $method $pathRe $result]
}

# Study ids created by POST /api/study, in order.
proc ::fake::createdIds {} {
    variable studies
    set ids {}
    dict for {id s} $studies { if {[dict exists $s createdByTest]} { lappend ids $id } }
    return $ids
}

proc ::fake::json {s} {
    return "\"[string map {\\ \\\\ \" \\\" \n \\n \t \\t} $s]\""
}
proc ::fake::pgnTag {s} { return [string map {\\ \\\\ \" \\\"} $s] }

# Lichess splits a multi-game PGN at a blank line followed by "[".
proc ::fake::splitPgn {pgn} {
    set pgn [string map {"\r" ""} $pgn]
    set games {}
    set start 0
    foreach m [regexp -all -indices -inline {\n\n(?=\[)} $pgn] {
        lappend games [string range $pgn $start [expr {[lindex $m 0] - 1}]]
        set start [expr {[lindex $m 1] + 1}]
    }
    lappend games [string range $pgn $start end]
    set out {}
    foreach g $games {
        set g [string trim $g]
        if {$g ne ""} { lappend out $g }
    }
    return $out
}

proc ::fake::tag {pgn name} {
    if {[regexp "\\\[$name \"(\[^\"\]*)\"\\\]" $pgn -> v]} { return $v }
    return ""
}

proc ::lichstudy::api {url args} {
    return [::fake::serve $url $args]
}

proc ::fake::serve {url argList} {
    variable log
    variable inject
    variable studies
    variable user
    variable beforeImport

    set method GET
    set data [dict create]
    for {set i 0} {$i < [llength $argList]} {incr i} {
        set a [lindex $argList $i]
        switch -- $a {
            -X { incr i; set method [lindex $argList $i] }
            --data-urlencode {
                incr i
                set kv [lindex $argList $i]
                if {[regexp {^(\w+)@(.*)$} $kv -> k f]} {
                    dict set data $k [::lichstudy::readFile $f]
                } else {
                    set eq [string first = $kv]
                    dict set data [string range $kv 0 [expr {$eq - 1}]] [string range $kv [expr {$eq + 1}] end]
                }
                if {$method eq "GET"} { set method POST }
            }
            default { error "fake Lichess: unexpected curl argument $a" }
        }
    }
    if {![regexp {^https://lichess\.org(/[^?]*)(?:\?(.*))?$} $url -> path query]} {
        error "fake Lichess: not a Lichess URL: $url"
    }
    lappend log [list $method $path $data]

    set i 0
    foreach inj $inject {
        lassign $inj m re result
        if {($m eq "*" || $m eq $method) && [regexp -- $re $path]} {
            set inject [lreplace $inject $i $i]
            if {[lindex $result 0] eq "neterr"} { error "Network error: [lindex $result 1]" }
            return $result
        }
        incr i
    }

    if {$method eq "GET" && $path eq "/api/account"} {
        return [list 200 "{\"id\":\"[string tolower $user]\",\"username\":\"$user\",\"perfs\":{}}"]
    }
    if {$method eq "GET" && [regexp {^/api/study/by/([^/]+)$} $path -> who]} {
        set body ""
        dict for {id s} $studies {
            if {[dict get $s owner] ne $who} { continue }
            append body "{\"id\":\"$id\",\"name\":[json [dict get $s name]],\"createdAt\":1,\"updatedAt\":[dict get $s updatedAt]}\n"
        }
        return [list 200 $body]
    }
    if {$method eq "GET" && [regexp {^/api/study/([A-Za-z0-9]{8})\.pgn$} $path -> id]} {
        if {![dict exists $studies $id]} { return [list 404 "{\"error\":\"Not found\"}"] }
        set body ""
        set nm [pgnTag [dict get $studies $id name]]
        foreach c [dict get $studies $id chapters] {
            append body "\[Event \"$nm: [pgnTag [dict get $c name]]\"\]\n\[StudyName \"$nm\"\]\n"
            append body "\[ChapterName \"[pgnTag [dict get $c name]]\"\]\n"
            append body "\[ChapterURL \"https://lichess.org/study/$id/[dict get $c id]\"\]\n\n*\n\n\n"
        }
        return [list 200 $body]
    }
    if {$method eq "POST" && $path eq "/api/study"} {
        set nm [dict get $data name]
        if {[string length $nm] < 2 || [string length $nm] > 100} {
            return [list 400 "{\"error\":{\"name\":\[\"Invalid\"\]}}"]
        }
        set id [newId S]
        dict set studies $id [dict create name $nm owner $user writable 1 \
            updatedAt [clock milliseconds] createdByTest 1 settings $data \
            chapters [list [dict create id [newId C] name "Chapter 1" orientation "" mode ""]]]
        return [list 200 "{\"id\":\"$id\",\"name\":[json $nm]}"]
    }
    if {$method eq "POST" && [regexp {^/api/study/([A-Za-z0-9]{8})/import-pgn$} $path -> id]} {
        if {$beforeImport ne ""} { uplevel #0 $beforeImport }
        if {![dict exists $studies $id]} { return [list 404 "{\"error\":\"Not found\"}"] }
        if {![dict get $studies $id writable]} { return [list 403 "{\"error\":\"Forbidden\"}"] }
        set orient [expr {[dict exists $data orientation] ? [dict get $data orientation] : ""}]
        set mode [expr {[dict exists $data mode] ? [dict get $data mode] : ""}]
        set chs [dict get $studies $id chapters]
        set made {}
        set err null
        foreach g [splitPgn [dict get $data pgn]] {
            if {[llength $chs] >= 64} { set err [json "Too many chapters"]; break }
            set w [tag $g White]
            set b [tag $g Black]
            set nm [expr {$w ne "" ? "$w - $b" : [tag $g Event]}]
            set c [dict create id [newId C] name $nm orientation $orient mode $mode pgn $g]
            lappend chs $c
            lappend made "{\"id\":\"[dict get $c id]\",\"name\":[json $nm],\"players\":\[{\"name\":[json $w]},{\"name\":[json $b]}\],\"status\":\"*\"}"
        }
        dict set studies $id chapters $chs
        return [list 200 "{\"chapters\":\[[join $made ,]\],\"error\":$err}"]
    }
    if {$method eq "DELETE" && [regexp {^/api/study/([A-Za-z0-9]{8})/([A-Za-z0-9]{8})$} $path -> id ch]} {
        if {![dict exists $studies $id]} { return [list 404 "{\"error\":\"Not found\"}"] }
        set chs [dict get $studies $id chapters]
        set keep [lmap c $chs {if {[dict get $c id] eq $ch} continue; set c}]
        if {[llength $keep] == [llength $chs]} { return [list 404 "{\"error\":\"Not found\"}"] }
        if {![llength $keep]} { return [list 400 "{\"error\":\"Cannot delete the last chapter\"}"] }
        dict set studies $id chapters $keep
        return [list 204 ""]
    }
    error "fake Lichess: no route for $method $path"
}

# ------------------------------------------------- driving the overflow dialog --

# Each step: {action name press}. action: first|split|"" (keep), name: new
# study name or "-" (keep), press: ok | abort | wmclose | destroyMain.
set ::ovfScript {}
set ::ovfSeen {}
proc ovfHook {args} {
    if {[llength $::ovfScript]} {
        after 0 ovfDrive
    } else {
        # A question no scenario expected: fail and abort it rather than hang.
        after 0 {
            check "no unexpected \"study is full\" question" 0 \
                [expr {[winfo exists .lichstudy.ovf] ? [.lichstudy.ovf.msg cget -text] : ""}]
            set ::lichstudy::ovfDone 0
        }
    }
}
proc ovfDrive {} {
    set step [lindex $::ovfScript 0]
    set ::ovfScript [lrange $::ovfScript 1 end]
    lassign $step act name press
    set d .lichstudy.ovf
    if {![winfo exists $d]} {
        lappend ::ovfSeen [dict create missing 1]
        set ::lichstudy::ovfDone 0
        return
    }
    set seen [dict create msg [$d.msg cget -text] hasFirst [winfo exists $d.r1] \
        split [$d.r2 cget -text] name $::lichstudy::ovfName err $::lichstudy::ovfMsg \
        act $::lichstudy::ovfAct transient [wm transient $d]]
    if {[winfo exists $d.r1]} { dict set seen first [$d.r1 cget -text] }
    lappend ::ovfSeen $seen
    if {$act ne ""} { set ::lichstudy::ovfAct $act }
    if {$name ne "-"} { set ::lichstudy::ovfName $name }
    switch -- $press {
        ok          { $d.b.ok invoke }
        abort       { $d.b.no invoke }
        wmclose     { uplevel #0 [wm protocol $d WM_DELETE_WINDOW] }
        destroyMain { destroy .lichstudy }
    }
}
trace add execution vwait enter ovfHook

# ---------------------------------------------------------------- scenarios --

proc range {a b} { set l {}; for {set i $a} {$i <= $b} {incr i} { lappend l $i }; return $l }

# A clean slate: fake Lichess empty, token saved, plugin options at defaults.
proc fresh {} {
    destroy .lichstudy
    ::fake::reset
    set ::boxes {}
    set ::boxAnswers {}
    set ::opened {}
    set ::ovfScript {}
    set ::ovfSeen {}
    set ::pgnCalls {}
    array set ::cur {base 1 num 0 altered 0 pgn ""}
    array unset ::broken
    set ::lichstudy::fresh {}
    set ::lichstudy::orientation auto
    set ::lichstudy::mode normal
    set ::lichstudy::newName ""
    set ::lichstudy::newVisibility private
    set ::lichstudy::busy 0
    file delete -force [file join $::tmp lichess_study]
    ::lichstudy::writeFile [file join $::tmp lichess_study token.txt] "lip_testtoken\n"
}

# Opens the dialog for games 1..n of base 1 and lets it load the study list.
proc openFor {n} {
    ::lichstudy::publishGames 1 [range 1 $n]
    update
    return .lichstudy
}

proc pick {w id} {
    set i 0
    foreach idx $::lichstudy::shown {
        if {[lindex $::lichstudy::studies $idx 0] eq $id} {
            $w.l.list selection clear 0 end
            $w.l.list selection set $i
            return
        }
        incr i
    }
    error "study $id is not in the list"
}

proc publishTo {id n} {
    set w [openFor $n]
    pick $w $id
    ::lichstudy::publish $w
    update
}

proc createNew {name n} {
    set w [openFor $n]
    set ::lichstudy::newName $name
    ::lichstudy::createAndPublish $w
    update
}

proc gameNames {a b} { return [lmap i [range $a $b] {string cat "White$i - Black$i"}] }
proc oldNames {n} { return [lmap i [range 1 $n] {string cat "Old $i"}] }

# =========================================================== pure helpers ===

section "selectionNumbers: Game List item ids"
checkEq "plain and row_col ids" [::lichstudy::selectionNumbers {12 13_4 " 7 "}] {12 13 7}
checkEq "duplicates kept once, in order" [::lichstudy::selectionNumbers {5 3 5_1 3}] {5 3}
checkEq "zero, negative and junk dropped" [::lichstudy::selectionNumbers {0 -3 abc 2.5 "" 9}] {9}
checkEq "nothing selected" [::lichstudy::selectionNumbers {}] {}

section "cleanGame: one game must stay one Lichess chapter"
set g [::lichstudy::cleanGame "\[White \"a\"\]\r\n\r\n1. e4 {x\r\n\r\n\[%cal Ge2e4\]} e5\n \t\n\n2. d4 *\n\n"]
checkEq "CR removed, header blank line kept, movetext blank lines gone" $g \
    "\[White \"a\"\]\n\n1. e4 {x\n\[%cal Ge2e4\]} e5\n2. d4 *"
checkEq "tags only" [::lichstudy::cleanGame "\n\[Event \"x\"\]\n"] "\[Event \"x\"\]"
checkEq "Lichess sees one game" [llength [::fake::splitPgn [::lichstudy::cleanGame [dbGame 1 1]]]] 1
checkEq "the raw game would have been split in two" [llength [::fake::splitPgn [dbGame 1 1]]] 2
set many [join [lmap i {1 2 3} {::lichstudy::cleanGame [dbGame 1 $i]}] "\n\n\n"]
checkEq "three cleaned games joined as the upload does are three games" [llength [::fake::splitPgn $many]] 3

section "unescape: JSON strings, and nothing else"
checkEq "quotes, backslash, slash, newline" [::lichstudy::unescape {a\"b\\c\/d\ne}] "a\"b\\c/d\ne"
checkEq "unicode escape" [::lichstudy::unescape {Café}] "Café"
set ::pwned 0
checkEq "no command substitution" [::lichstudy::unescape {[set ::pwned 1]}] {[set ::pwned 1]}
checkEq "the command did not run" $::pwned 0
checkEq "no variable substitution" [::lichstudy::unescape {$::tcl_version}] {$::tcl_version}

section "errorText / friendly"
checkHas "no answer" [::lichstudy::errorText 000 ""] "No answer from Lichess"
checkHas "401" [::lichstudy::errorText 401 "{}"] "Invalid or expired token"
checkHas "403" [::lichstudy::errorText 403 "{\"error\":\"Forbidden\"}"] "study:write"
checkHas "404" [::lichstudy::errorText 404 ""] "Study not found"
checkHas "429" [::lichstudy::errorText 429 ""] "wait a minute"
checkEq "Lichess message, unescaped" [::lichstudy::errorText 400 {{"error":"bad \"pgn\""}}] \
    {Lichess (HTTP 400): bad "pgn"}
checkHas "Too many chapters explained" [::lichstudy::errorText 400 {{"error":"Too many chapters"}}] \
    "the study is full: a Lichess study holds at most 64 chapters"
set long [string repeat x 300]
set t [::lichstudy::errorText 500 $long]
checkHas "unexpected body cut at 200 characters" $t "[string repeat x 200]..."
checkHasNot "...and not longer" $t [string repeat x 201]
checkEq "friendly leaves other messages alone" [::lichstudy::friendly "Oops"] "Oops"

section "freeChapters"
fresh
set s [::fake::addStudy "Count" 10]
checkEq "64 minus the chapters in the export" [::lichstudy::freeChapters $s] 54
checkEq "a full study has 0" [::lichstudy::freeChapters [::fake::addStudy "Full" 64]] 0
::fake::injectOnce GET {\.pgn$} {500 "oops"}
checkEq "-1 when the export fails" [::lichstudy::freeChapters $s] -1
::fake::injectOnce GET {\.pgn$} {neterr "timeout"}
checkEq "-1 on a network error" [::lichstudy::freeChapters $s] -1
checkEq "-1 for an unknown study" [::lichstudy::freeChapters ZZZZZZZZ] -1

# =================================================== games -> dialog ===

section "publishGames: what can be opened"
fresh
::lichstudy::publishGames 9 {1 2}
checkHas "closed database refused" [boxField [lastBox] -message] "no longer open"
checkEq "no dialog" [winfo exists .lichstudy] 0

set ::boxes {}
::lichstudy::publishGames 1 {}
checkEq "no games: nothing happens" [list [llength $::boxes] [winfo exists .lichstudy]] {0 0}

::lichstudy::publishGames 1 [range 1 65]
checkHas "65 games refused" [boxField [lastBox] -message] "You selected 65 games"
checkEq "no dialog for 65" [winfo exists .lichstudy] 0

set ::boxes {}
::lichstudy::publishGames 1 [range 1 64]
checkEq "64 games accepted" [llength $::lichstudy::games] 64
checkEq "no warning for 64" [llength $::boxes] 0
checkEq "dialog title line" [.lichstudy.head cget -text] "To publish: 64 games (one chapter per game)"
check "-base and -gameNumber come before the PGN options" \
    [expr {[lrange [lindex $::pgnCalls 0] 0 3] eq {-base 1 -gameNumber 1}}] [lindex $::pgnCalls 0]
checkEq "games kept in selection order" [::fake::tag [lindex $::lichstudy::games 63] White] White64

fresh
::lichstudy::publishGames 2 {1 7}
checkHas "game number beyond the base" [boxField [lastBox] -message] "Game 7 not found"
checkEq "no dialog" [winfo exists .lichstudy] 0

fresh
set ::broken(1,2) 1
::lichstudy::publishGames 1 {1 2 3}
checkHas "unreadable game reported" [boxField [lastBox] -message] "Cannot read game 2"
checkEq "no dialog" [winfo exists .lichstudy] 0

fresh
array set ::cur {base 1 num 5 altered 1}
set ::cur(pgn) "\[Event \"Edited\"\]\n\[White \"Me\"\]\n\n1. d4 *"
::lichstudy::publishGames 1 {4 5}
checkEq "game on the board with unsaved changes is taken as shown" \
    [::fake::tag [lindex $::lichstudy::games 1] Event] Edited
checkEq "the other game comes from the database" [::fake::tag [lindex $::lichstudy::games 0] Event] "Event 4"
destroy .lichstudy

section "publishCurrent"
fresh
::lichstudy::publishCurrent
checkHas "empty board: explained" [boxField [lastBox] -message] "There is no game on the board"
checkEq "no dialog" [winfo exists .lichstudy] 0
array set ::cur {num 0 altered 1}
set ::cur(pgn) "\[Event \"New\"\]\r\n\r\n1. e4\r\n\r\n*"
::lichstudy::publishCurrent
checkEq "new unsaved game: 1 game" [llength $::lichstudy::games] 1
checkEq "...cleaned" [lindex $::lichstudy::games 0] "\[Event \"New\"\]\n\n1. e4\n*"
destroy .lichstudy

# ===================================================== the study list ===

section "study list, filter, token, studies added by link"
fresh
set old [::fake::addStudy "Alpha openings" 3 updatedAt 100]
set new [::fake::addStudy "Beta \"endgames\" café" 3 updatedAt 300]
set mid [::fake::addStudy "alphabet" 3 updatedAt 200]
::fake::addStudy "Somebody else's" 3 owner Other
::lichstudy::writeFile [file join $tmp lichess_study extra.txt] "AAAAAAAA\tShared one\n\n$old\tduplicate of an own study\nBBBBBBBB\tShared two"
set w [openFor 2]
checkEq "own studies newest first, then studies added by link, no duplicates" \
    [lmap s $::lichstudy::studies {lindex $s 0}] [list $new $mid $old AAAAAAAA BBBBBBBB]
checkEq "escaped quotes and accents in names" [lindex $::lichstudy::studies 0 1] "Beta \"endgames\" café"
checkEq "studies added by link are marked" [$w.l.list get 3] "Shared one   (added by link)"
checkHas "status names the account" [$w.status cget -text] "Account Tester: 5 studies"
set ::lichstudy::filter "ALPHA"
::lichstudy::applyFilter $w
checkEq "filter is case-insensitive" [$w.l.list get 0 end] [list alphabet "Alpha openings"]
# The second visible row is "Alpha openings": the publish must go there, not
# to the second study of the full list.
pick $w $old
$w.l.list selection clear 0 end
$w.l.list selection set 1
::lichstudy::publish $w
update
checkEq "filtered selection publishes into the right study" [::fake::nChapters $old] 5
checkEq "...and nowhere else" [::fake::nChapters $mid] 3

fresh
::fake::addStudy "One" 1
set w [openFor 1]
::lichstudy::publish $w
checkHas "Publish with nothing picked" [boxField [lastBox] -message] "Pick a study"
checkEq "no request made" [::fake::count POST import] 0

fresh
file delete [file join $tmp lichess_study token.txt]
set w [openFor 1]
checkHas "no token: asks for one" [$w.status cget -text] "Paste your Lichess token"
checkEq "no request without a token" [llength $::fake::log] 0
$w.tok.e insert 0 "bad token!"
::lichstudy::saveToken $w
checkHas "invalid token rejected" [$w.status cget -text] "invalid characters"
checkEq "invalid token not saved" [file exists [file join $tmp lichess_study token.txt]] 0
$w.tok.e delete 0 end
$w.tok.e insert 0 "  lip_Good_123  "
::lichstudy::saveToken $w
checkEq "token trimmed and saved" [::lichstudy::readFile [file join $tmp lichess_study token.txt]] lip_Good_123
checkEq "saving reloads the list" [::fake::count GET {^/api/account$}] 1
set ::lichstudy::newName "Some study"
::lichstudy::createAndPublish $w
checkEq "with a token, creation works" [llength [::fake::createdIds]] 1
destroy .lichstudy

fresh
::fake::injectOnce GET {^/api/account$} {401 "{\"error\":\"No such token\"}"}
set w [openFor 1]
checkHas "expired token shown" [$w.status cget -text] "Invalid or expired token"
checkEq "empty list" [$w.l.list size] 0
destroy $w

fresh
set shared [::fake::addStudy "Club \"Wednesday\"\tnight" 5 owner Other]
set w [openFor 1]
$w.add.e insert 0 "not a link"
::lichstudy::addByLink $w
checkHas "bad link refused" [boxField [lastBox] -message] "Paste the link of a study"
$w.add.e delete 0 end
$w.add.e insert 0 "https://lichess.org/study/$shared/C0000001#comments"
::lichstudy::addByLink $w
set extra [::lichstudy::readFile [file join $tmp lichess_study extra.txt]]
checkEq "study saved with its name, tab replaced" $extra "$shared\tClub \"Wednesday\" night\n"
checkEq "entry emptied" [$w.add.e get] ""
check "study now in the list" [expr {[lsearch -index 0 $::lichstudy::studies $shared] >= 0}]
$w.add.e insert 0 $shared
::lichstudy::addByLink $w
checkEq "adding it again (bare id) keeps one line" [::lichstudy::readFile [file join $tmp lichess_study extra.txt]] $extra
$w.add.e insert 0 "https://lichess.org/study/ZZZZZZZZ"
::lichstudy::addByLink $w
checkHas "unknown study reported" [$w.status cget -text] "Study not found"
destroy $w

# ============================================ games into an existing study ===

section "1 game into an existing study"
fresh
set s [::fake::addStudy "Repertoire" 5]
set ::boxAnswers {yes}
publishTo $s 1
checkEq "chapter added after the existing ones" [::fake::chapterNames $s] [concat [oldNames 5] [gameNames 1 1]]
checkEq "free chapters checked first" [::fake::count GET "^/api/study/$s\\.pgn$"] 1
checkEq "one import request" [::fake::count POST import-pgn] 1
checkEq "no study created" [::fake::count POST {^/api/study$}] 0
checkEq "no overflow question" [llength $::ovfSeen] 0
checkEq "success box is info" [boxField [lastBox] -icon] info
checkHas "success message" [boxField [lastBox] -message] "Created 1 of 1 chapters (1 in \"Repertoire\")."
checkEq "browser opened on the study" $::opened [list "https://lichess.org/study/$s"]
checkEq "dialog closed" [winfo exists .lichstudy] 0
checkEq "temporary upload file removed" [glob -nocomplain -dir [file join $tmp lichess_study] *.pgn] {}
set pgn [dict get [lindex [::fake::chapters $s] end] pgn]
checkHas "NAG sent as \$n" $pgn "e5 \$1"
checkHas "marks kept" $pgn {[%csl Gd4]}

section "several games into an existing study"
fresh
set s [::fake::addStudy "Repertoire" 1]
publishTo $s 5
checkEq "five chapters, in order" [::fake::chapterNames $s] [concat [oldNames 1] [gameNames 1 5]]
checkEq "in one request" [::fake::count POST import-pgn] 1
checkHas "report" [boxField [lastBox] -message] "Created 5 of 5 chapters"
checkEq "answering no opens nothing" $::opened {}
checkEq "dialog closed" [winfo exists .lichstudy] 0

section "chapter settings: orientation and analysis mode"
fresh
set s [::fake::addStudy "Settings" 1]
publishTo $s 2
set d [lindex [lindex [::fake::requests POST import-pgn] 0] 2]
check "automatic orientation sends no orientation" [expr {![dict exists $d orientation]}] $d
check "normal analysis sends no mode" [expr {![dict exists $d mode]}] $d
foreach {o m} {black gamebook white practice black conceal} {
    fresh
    set s [::fake::addStudy "Settings" 1]
    set w [openFor 2]
    set ::lichstudy::orientation $o
    set ::lichstudy::mode $m
    pick $w $s
    ::lichstudy::publish $w
    update
    set c [lindex [::fake::chapters $s] end]
    checkEq "orientation $o reaches the chapter" [dict get $c orientation] $o
    checkEq "mode $m reaches the chapter" [dict get $c mode] $m
}

section "exactly as many games as free chapters"
fresh
set s [::fake::addStudy "Almost full" 54]
publishTo $s 10
checkEq "no question" [llength $::ovfSeen] 0
checkEq "study now full" [::fake::nChapters $s] 64
checkEq "info" [boxField [lastBox] -icon] info

section "64 games into an existing study"
# A Lichess study always has at least one chapter, so 64 games never fit in
# an existing study: the user is always asked.
fresh
set s [::fake::addStudy "One chapter" 1]
set ::ovfScript {{first - ok}}
publishTo $s 64
checkEq "asked once" [llength $::ovfSeen] 1
checkHas "63 free of 64" [dict get [lindex $::ovfSeen 0] msg] "has only 63 free chapters out of 64"
checkEq "63 published" [::fake::nChapters $s] 64
checkEq "the first 63 games" [lrange [::fake::chapterNames $s] 1 end] [gameNames 1 63]
checkHas "one game reported as left out" [boxField [lastBox] -message] "Games not published because the study is full: 1."
checkEq "partial is a warning" [boxField [lastBox] -icon] warning

fresh
set s [::fake::addStudy "One chapter" 1]
set ::ovfScript {{split - ok}}
publishTo $s 64
set n [lindex [::fake::createdIds] 0]
checkEq "63 here" [::fake::nChapters $s] 64
checkEq "the last game in the new study, its empty chapter deleted" [::fake::chapterNames $n] [gameNames 64 64]
checkEq "new study named after the old one" [dict get $::fake::studies $n name] "One chapter (2)"
checkHas "report names both studies" [boxField [lastBox] -message] \
    "Created 64 of 64 chapters (63 in \"One chapter\", 1 in \"One chapter (2)\")."
checkEq "all published: info" [boxField [lastBox] -icon] info

fresh
# Hypothetical study without chapters (Lichess does not allow it): all fit.
set s [::fake::addStudy "Empty" 0]
publishTo $s 64
checkEq "no question when 64 are free" [llength $::ovfSeen] 0
checkEq "64 chapters" [::fake::nChapters $s] 64

# ================================================ games into a new study ===

foreach n {1 5 63} {
    section "$n game(s) into a new study"
    fresh
    set ::lichstudy::newVisibility unlisted
    createNew "  Fresh study $n  " $n
    set ids [::fake::createdIds]
    checkEq "one study created" [llength $ids] 1
    set id [lindex $ids 0]
    checkEq "name trimmed" [dict get $::fake::studies $id name] "Fresh study $n"
    checkEq "visibility sent" [dict get $::fake::studies $id settings visibility] unlisted
    checkEq "empty chapter deleted, games in order" [::fake::chapterNames $id] [gameNames 1 $n]
    checkEq "one import request" [::fake::count POST import-pgn] 1
    checkEq "no free-chapter check for a study just created" [::fake::count GET "^/api/study/$id\\.pgn$"] 1
    checkEq "one delete" [::fake::count DELETE .] 1
    checkHas "report" [boxField [lastBox] -message] "Created $n of $n chapters"
    checkEq "info" [boxField [lastBox] -icon] info
    checkEq "dialog closed" [winfo exists .lichstudy] 0
    checkEq "fresh forgotten" $::lichstudy::fresh {}
    checkEq "temporary name file removed" [glob -nocomplain -dir [file join $tmp lichess_study] name_*] {}
}

section "64 games into a new study"
fresh
createNew "Sixty-four" 64
set id [lindex [::fake::createdIds] 0]
set imports [::fake::requests POST import-pgn]
checkEq "two import requests" [llength $imports] 2
checkEq "the first holds one game" [llength [::fake::splitPgn [dict get [lindex $imports 0 2] pgn]]] 1
checkEq "the second holds 63" [llength [::fake::splitPgn [dict get [lindex $imports 1 2] pgn]]] 63
set order [lmap r $::fake::log {lindex $r 0}]
checkEq "delete between the two imports" [lrange $order end-2 end] {POST DELETE POST}
checkEq "64 chapters, all games, in order" [::fake::chapterNames $id] [gameNames 1 64]
checkHas "report" [boxField [lastBox] -message] "Created 64 of 64 chapters"

section "new study whose empty chapter cannot be found"
fresh
# The export right after the creation fails: the empty chapter stays.
::fake::injectOnce GET {\.pgn$} {500 ""}
createNew "No export" 63
set id [lindex [::fake::createdIds] 0]
checkEq "63 games fit next to the empty chapter" [::fake::chapterNames $id] [concat {{Chapter 1}} [gameNames 1 63]]
checkEq "nothing deleted" [::fake::count DELETE .] 0
checkHas "all 63 reported" [boxField [lastBox] -message] "Created 63 of 63 chapters"

fresh
::fake::injectOnce GET {\.pgn$} {500 ""}
createNew "No export" 64
set id [lindex [::fake::createdIds] 0]
checkEq "64 games: one request, Lichess stops at 64 chapters" [::fake::count POST import-pgn] 1
checkEq "63 imported" [::fake::nChapters $id] 64
checkHas "the lost game is reported" [boxField [lastBox] -message] "Created 63 of 64 chapters"
checkHas "...in plain words" [boxField [lastBox] -message] "the study is full"
checkEq "warning" [boxField [lastBox] -icon] warning

section "new study: name checks and failures"
fresh
set w [openFor 1]
foreach bad [list "" " x " [string repeat a 101]] {
    set ::lichstudy::newName $bad
    ::lichstudy::createAndPublish $w
    checkHas "name '[string range $bad 0 9]' refused" [$w.status cget -text] "2 to 100 characters"
}
checkEq "nothing created" [::fake::count POST {^/api/study$}] 0
set ::lichstudy::newName [string repeat b 100]
::lichstudy::createAndPublish $w
checkEq "100 characters accepted" [llength [::fake::createdIds]] 1

fresh
::fake::injectOnce POST {^/api/study$} {429 ""}
set w [openFor 2]
set ::lichstudy::newName "Too fast"
::lichstudy::createAndPublish $w
checkHas "creation refused: status" [$w.status cget -text] "Too many requests"
checkEq "nothing imported" [::fake::count POST import-pgn] 0
checkEq "dialog stays open" [winfo exists $w] 1
checkEq "buttons usable again" [$w.btn.pub instate disabled] 0
checkEq "name kept to retry" $::lichstudy::newName "Too fast"
destroy $w

section "new study: retry after a failed import does not create a second study"
fresh
::fake::injectOnce POST import-pgn {neterr "connection reset"}
set w [openFor 3]
set ::lichstudy::newName "Retry me"
::lichstudy::createAndPublish $w
update
set id [lindex [::fake::createdIds] 0]
checkHas "failure shown" [boxField [lastBox] -message] "Nothing was published."
checkHas "...with the cause" [boxField [lastBox] -message] "connection reset"
checkEq "error icon" [boxField [lastBox] -icon] error
checkEq "dialog stays open" [winfo exists $w] 1
checkEq "new study listed and selected" [list [lindex $::lichstudy::studies [lindex $::lichstudy::shown [$w.l.list curselection]] 0]] [list $id]
::lichstudy::publish $w
update
checkEq "still one study" [llength [::fake::createdIds]] 1
checkEq "no free-chapter check on the retry" [::fake::count GET "^/api/study/$id\\.pgn$"] 1
checkEq "empty chapter deleted on the retry" [::fake::chapterNames $id] [gameNames 1 3]

# ======================================= more games than the study can hold ===

section "x games, fewer free chapters: abort"
fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript {{"" - abort}}
publishTo $s 10
set seen [lindex $::ovfSeen 0]
checkHas "question names the free chapters" [dict get $seen msg] "\"Nearly full\" has only 4 free chapters out of 64"
checkHas "...and the games" [dict get $seen msg] "publish 10 games"
checkEq "'first' offered" [dict get $seen first] "Publish only the first 4 games here (6 will not be published)"
checkEq "'split' offered" [dict get $seen split] "Publish the first 4 games here and the other 6 in a new study"
checkEq "split is the default" [dict get $seen act] split
checkEq "default new name" [dict get $seen name] "Nearly full (2)"
checkEq "question belongs to the dialog" [dict get $seen transient] .lichstudy
checkEq "nothing imported" [::fake::count POST import-pgn] 0
checkEq "nothing created" [::fake::count POST {^/api/study$}] 0
checkHas "status says so" [.lichstudy.status cget -text] "Publish cancelled"
checkEq "no message box" [llength $::boxes] 0
checkEq "dialog usable again" [list $::lichstudy::busy [.lichstudy.btn.pub instate disabled]] {0 0}
checkEq "question closed" [winfo exists .lichstudy.ovf] 0

fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript {{"" - wmclose}}
publishTo $s 10
checkEq "closing the question aborts" [::fake::count POST import-pgn] 0
checkHas "status" [.lichstudy.status cget -text] "Publish cancelled"

section "x games, fewer free chapters: publish only the first ones"
fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript {{first - ok}}
publishTo $s 10
checkEq "first four games added" [::fake::chapterNames $s] [concat [oldNames 60] [gameNames 1 4]]
checkEq "no new study" [::fake::count POST {^/api/study$}] 0
set msg [boxField [lastBox] -message]
checkHas "4 of 10" $msg "Created 4 of 10 chapters (4 in \"Nearly full\")"
checkHas "6 left out" $msg "Games not published because the study is full: 6."
checkEq "warning" [boxField [lastBox] -icon] warning

section "x games, fewer free chapters: the rest in a new study"
fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript {{split "  Overflow  " ok}}
set ::boxAnswers {yes}
publishTo $s 10
set n [lindex [::fake::createdIds] 0]
checkEq "existing study filled with the first 4" [lrange [::fake::chapterNames $s] 60 end] [gameNames 1 4]
checkEq "new study, name trimmed" [dict get $::fake::studies $n name] Overflow
checkEq "new study holds games 5-10, its empty chapter deleted" [::fake::chapterNames $n] [gameNames 5 10]
set order [lmap r [::fake::requests * {^/api/study(/[^/]+/import-pgn)?$}] {lindex $r 1}]
checkEq "new study created before anything is imported" [lindex $order 0] /api/study
checkHas "report" [boxField [lastBox] -message] "Created 10 of 10 chapters (4 in \"Nearly full\", 6 in \"Overflow\")"
checkEq "info" [boxField [lastBox] -icon] info
checkEq "browser opens the new study (the last one filled)" $::opened [list "https://lichess.org/study/$n"]
checkEq "new study uses the dialog's visibility" [dict get $::fake::studies $n settings visibility] private

section "name of the new study: validation and default"
fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript [list {split " x " ok} {split "" ok} {split - ok} \
    [list split [string repeat n 101] ok] {split "Good name" ok}]
publishTo $s 6
checkEq "asked until the name was valid" [llength $::ovfSeen] 5
checkEq "first try had no error" [dict get [lindex $::ovfSeen 0] err] ""
checkHas "too short name refused" [dict get [lindex $::ovfSeen 1] err] "2 to 100 characters"
checkHas "empty name refused" [dict get [lindex $::ovfSeen 2] err] "2 to 100 characters"
checkEq "the bad name is still in the field" [dict get [lindex $::ovfSeen 2] name] ""
checkHas "101 characters refused" [dict get [lindex $::ovfSeen 4] err] "2 to 100 characters"
checkEq "one study created, with the valid name" \
    [lmap id [::fake::createdIds] {dict get $::fake::studies $id name}] [list "Good name"]

fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript {{first "" ok}}
publishTo $s 6
checkEq "'first' ignores an empty name" [::fake::nChapters $s] 64

fresh
set long [string repeat L 99]
set s [::fake::addStudy $long 62]
set ::ovfScript {{"" - ok}}
publishTo $s 3
set n [lindex [::fake::createdIds] 0]
set newNm [dict get $::fake::studies $n name]
checkEq "long name: base shortened, suffix kept, 100 characters" $newNm "[string repeat L 96] (2)"

fresh
set s [::fake::addStudy "Openings (2)" 64]
set ::ovfScript {{"" - abort}}
publishTo $s 1
checkEq "a study already numbered gets the next number" [dict get [lindex $::ovfSeen 0] name] "Openings (3)"

section "nextName"
checkEq "plain" [::lichstudy::nextName "Repertoire"] "Repertoire (2)"
checkEq "(2) -> (3)" [::lichstudy::nextName "Repertoire (2)"] "Repertoire (3)"
checkEq "(9) -> (10)" [::lichstudy::nextName "Repertoire (9)"] "Repertoire (10)"
checkEq "leading zeros are not octal" [::lichstudy::nextName "R (08)"] "R (9)"
checkEq "no space before the number" [::lichstudy::nextName "R(4)"] "R (5)"
checkEq "a name that is only a number in brackets" [::lichstudy::nextName "(2)"] "(2) (2)"
checkEq "brackets with words are not a number" [::lichstudy::nextName "Najdorf (main)"] "Najdorf (main) (2)"
set n96 "[string repeat a 96] (2)"
checkEq "100 characters ending in (2)" [::lichstudy::nextName $n96] "[string repeat a 96] (3)"
set sp "[string repeat a 95] [string repeat b 10]"
checkEq "cut landing on a space: no double space" [::lichstudy::nextName $sp] "[string repeat a 95] (2)"
foreach nm [list $long $n96 $sp "ab" [string repeat x 100]] {
    set r [::lichstudy::nextName $nm]
    check "'[string range $nm 0 7]...' -> at most 100 characters and different" \
        [expr {[string length $r] <= 100 && $r ne $nm}] $r
}

section "full study"
fresh
set s [::fake::addStudy "Full" 64]
set ::ovfScript {{"" - ok}}
publishTo $s 1
set seen [lindex $::ovfSeen 0]
checkHas "says it is full" [dict get $seen msg] "\"Full\" is full"
checkEq "no 'first' option" [dict get $seen hasFirst] 0
checkEq "only the new study" [dict get $seen split] "Publish all 1 games in a new study"
set n [lindex [::fake::createdIds] 0]
checkEq "the game went to the new study" [::fake::chapterNames $n] [gameNames 1 1]
checkEq "full study untouched" [::fake::nChapters $s] 64
checkEq "no import into the full study" [::fake::count POST "^/api/study/$s/import-pgn$"] 0
checkHas "report" [boxField [lastBox] -message] "Created 1 of 1 chapters (1 in \"Full (2)\")"

fresh
set s [::fake::addStudy "Full" 64]
set ::ovfScript {{"" - ok}}
publishTo $s 64
set n [lindex [::fake::createdIds] 0]
checkEq "64 games from a full study: all in the new one" [::fake::chapterNames $n] [gameNames 1 64]
checkEq "...in two steps around the empty chapter" [::fake::count POST "^/api/study/$n/import-pgn$"] 2

section "new study for the rest cannot be created"
fresh
set s [::fake::addStudy "Nearly full" 60]
::fake::injectOnce POST {^/api/study$} {429 ""}
set ::ovfScript {{split - ok}}
publishTo $s 10
checkEq "nothing imported anywhere" [::fake::count POST import-pgn] 0
checkEq "existing study untouched" [::fake::nChapters $s] 60
checkHas "error box" [boxField [lastBox] -message] "Could not create the study \"Nearly full (2)\""
checkHas "...says nothing was published" [boxField [lastBox] -message] "Nothing was published."
checkEq "dialog stays open" [winfo exists .lichstudy] 1
checkEq "dialog usable again" [.lichstudy.btn.pub instate disabled] 0

section "chapters cannot be counted: Lichess decides"
fresh
set s [::fake::addStudy "Uncountable" 60]
::fake::injectOnce GET {\.pgn$} {403 ""}
publishTo $s 10
checkEq "no question" [llength $::ovfSeen] 0
checkEq "Lichess took 4" [::fake::nChapters $s] 64
set msg [boxField [lastBox] -message]
checkHas "4 of 10" $msg "Created 4 of 10 chapters"
checkHas "Lichess' error explained" $msg "Lichess reports: the study is full"
checkEq "warning" [boxField [lastBox] -icon] warning

section "the study fills up between the count and the import"
fresh
set s [::fake::addStudy "Busy" 60]
set ::fake::beforeImport [list apply {{s} {
    # A co-author adds two chapters; only once.
    set chs [dict get $::fake::studies $s chapters]
    lappend chs [dict create id [::fake::newId C] name "Theirs" orientation "" mode ""]
    lappend chs [dict create id [::fake::newId C] name "Theirs" orientation "" mode ""]
    dict set ::fake::studies $s chapters $chs
    set ::fake::beforeImport ""
}} $s]
set ::ovfScript {{first - ok}}
publishTo $s 10
checkEq "only 2 fit" [::fake::nChapters $s] 64
set msg [boxField [lastBox] -message]
checkHas "2 of 10" $msg "Created 2 of 10 chapters"
checkHas "the study is full" $msg "the study is full"
checkHas "the 6 left out by choice are still reported" $msg "Games not published because the study is full: 6."

fresh
set s [::fake::addStudy "Busy" 60]
set ::fake::beforeImport [list apply {{s} {
    set chs [dict get $::fake::studies $s chapters]
    lappend chs [dict create id [::fake::newId C] name "Theirs" orientation "" mode ""]
    lappend chs [dict create id [::fake::newId C] name "Theirs" orientation "" mode ""]
    dict set ::fake::studies $s chapters $chs
    set ::fake::beforeImport ""
}} $s]
set ::ovfScript {{split "Rest" ok}}
publishTo $s 10
set n [lindex [::fake::createdIds] 0]
set msg [boxField [lastBox] -message]
checkEq "the games meant for the new study still go there" [::fake::chapterNames $n] [gameNames 5 10]
checkHas "split, study filled meanwhile: 2 + 6 published" $msg \
    "Created 8 of 10 chapters (2 in \"Busy\", 6 in \"Rest\")."
checkHas "the problem is placed in the full study" $msg "In \"Busy\":"
checkHas "...explained" $msg "the study is full"
checkHasNot "no empty-study note" $msg "holds none of the games"
checkEq "warning" [boxField [lastBox] -icon] warning

section "split: the new study gets none of the games"
fresh
set s [::fake::addStudy "Nearly full" 60]
::fake::injectOnce POST "^/api/study/(?!$s)\[^/\]+/import-pgn$" {neterr "connection reset"}
set ::ovfScript {{split "Rest" ok}}
set ::boxAnswers {yes}
publishTo $s 10
set n [lindex [::fake::createdIds] 0]
set msg [boxField [lastBox] -message]
checkEq "old study filled" [::fake::nChapters $s] 64
checkHas "4 of 10" $msg "Created 4 of 10 chapters (4 in \"Nearly full\")."
checkHas "the new study's error" $msg "In \"Rest\":\n\nNetwork error: connection reset"
checkHas "the empty new study is mentioned, with its link" $msg \
    "The new study \"Rest\" was created but holds none of the games (https://lichess.org/study/$n)."
checkEq "the browser opens the study that got games" $::opened [list "https://lichess.org/study/$s"]

fresh
set s [::fake::addStudy "Locked" 60 writable 0]
::fake::injectOnce POST "^/api/study/(?!$s)\[^/\]+/import-pgn$" {neterr "connection reset"}
set ::ovfScript {{split "Rest" ok}}
publishTo $s 10
set n [lindex [::fake::createdIds] 0]
set msg [boxField [lastBox] -message]
checkHas "both parts fail: nothing published" $msg "Nothing was published."
checkHas "...both causes" $msg "In \"Locked\":\n\nPermission denied (403)"
checkHas "...and the second" $msg "In \"Rest\":\n\nNetwork error"
checkHas "...and the empty new study" $msg "The new study \"Rest\" was created but holds none of the games"
checkEq "dialog stays open" [winfo exists .lichstudy] 1
checkEq "the new study is listed first" [lrange [lindex $::lichstudy::studies 0] 0 1] [list $n Rest]
checkEq "...and shown" [.lichstudy.l.list get 0] Rest
pick .lichstudy $n
::lichstudy::publish .lichstudy
update
checkEq "publishing into it again creates no other study" [llength [::fake::createdIds]] 1
checkEq "no question for the study just created" [llength $::ovfSeen] 1
checkEq "its empty chapter deleted, the games in" [::fake::chapterNames $n] [gameNames 1 10]

# ================================================= HTTP and network errors ===

section "import refused or failed"
fresh
set s [::fake::addStudy "Not mine" 2 owner Other writable 0]
::lichstudy::writeFile [file join $tmp lichess_study extra.txt] "$s\tNot mine\n"
publishTo $s 2
set msg [boxField [lastBox] -message]
checkHas "403: nothing published" $msg "Nothing was published."
checkHas "...why" $msg "Permission denied (403)"
checkHas "...where" $msg "In \"Not mine\":"
checkEq "error icon" [boxField [lastBox] -icon] error
checkEq "dialog stays open" [winfo exists .lichstudy] 1
checkHas "status repeats it" [.lichstudy.status cget -text] "Permission denied"
checkEq "dialog usable again" [list $::lichstudy::busy [.lichstudy.btn.pub instate disabled] [.lichstudy.new.go instate disabled]] {0 0 0}

fresh
set s [::fake::addStudy "Flaky" 2]
::fake::injectOnce POST import-pgn {neterr "Could not resolve host"}
publishTo $s 2
checkHas "network error reported" [boxField [lastBox] -message] "Could not resolve host"
checkEq "nothing created" [::fake::nChapters $s] 2

fresh
set s [::fake::addStudy "Weird" 2]
::fake::injectOnce POST import-pgn {200 "{\"chapters\":[],\"error\":\"Invalid PGN\"}"}
publishTo $s 2
checkHas "HTTP 200 with an error and no chapter" [boxField [lastBox] -message] "Nothing was published."
checkHas "...Lichess' text" [boxField [lastBox] -message] "Lichess reports: Invalid PGN"

fresh
set s [::fake::addStudy "Gone" 2]
::fake::injectOnce GET {\.pgn$} {404 ""}
::fake::injectOnce POST import-pgn {404 "{\"error\":\"Not found\"}"}
publishTo $s 1
checkHas "study deleted on Lichess" [boxField [lastBox] -message] "Study not found (404)"

# ============================================================= robustness ===

section "busy guard"
fresh
set s [::fake::addStudy "Guarded" 2]
set w [openFor 1]
set ::lichstudy::busy 1
::lichstudy::doPublish $w $s Guarded
set ::lichstudy::newName "Another"
::lichstudy::createAndPublish $w
checkEq "nothing sent while busy" [list [::fake::count POST import-pgn] [::fake::count POST {^/api/study$}]] {0 0}
set ::lichstudy::busy 0
destroy $w

section "the dialog is closed while the overflow question is open"
fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript {{"" - destroyMain}}
# If askOverflow never returns, this releases it after 3 s.
set ::ovfHung 0
set watchdog [after 3000 {set ::ovfHung 1; set ::lichstudy::ovfDone 0}]
publishTo $s 10
after cancel $watchdog
checkEq "askOverflow returns when its window is destroyed" $::ovfHung 0
checkEq "nothing imported" [::fake::count POST import-pgn] 0
checkEq "nothing created" [::fake::count POST {^/api/study$}] 0
checkEq "no error" [llength $::boxes] 0
checkEq "the publish ended (not busy)" $::lichstudy::busy 0
# The <Destroy> binding must not overwrite an answer already given.
fresh
set s [::fake::addStudy "Nearly full" 60]
set ::ovfScript {{first - ok}}
publishTo $s 10
checkEq "a normal answer still counts once the question is destroyed" [::fake::nChapters $s] 64

# ================================================== native entry points ===

section "entry points"
check "publishGames is defined" [expr {[llength [info commands ::lichstudy::publishGames]] == 1}]
check "publishCurrent is defined" [expr {[llength [info commands ::lichstudy::publishCurrent]] == 1}]
# The menus are wired natively in menus.tcl (Tools) and gamelist.tcl (the
# Game List right-click menu), so the feature must no longer install its own
# tk_popup trace.
check "no tk_popup trace is installed" \
    [expr {[lsearch -exact [trace info execution ::tk_popup] {enter ::lichstudy::onPopup}] < 0}]
check "onPopup no longer exists" [expr {[llength [info commands ::lichstudy::onPopup]] == 0}]

# =============================================== the real api, fake curl ===

section "api: how curl is called"
set bin [file join $tmp bin]
file mkdir $bin
set fakeCurl [file join $bin curl]
set fc [open $fakeCurl w]
puts $fc {#!/bin/sh
PATH=/usr/bin:/bin
printf '%s\n' "$@" > "$FAKECURL_DIR/argv"
cat > "$FAKECURL_DIR/stdin"
out=""; prev=""
for a in "$@"; do
  if [ "$prev" = "-o" ]; then out="$a"; fi
  prev="$a"
done
echo "$out" > "$FAKECURL_DIR/outpath"
if [ -f "$FAKECURL_DIR/fail" ]; then echo "curl: (6) Could not resolve host: lichess.org" >&2; exit 6; fi
if [ -n "$out" ]; then cp "$FAKECURL_DIR/body" "$out"; fi
printf '%s' "$(cat "$FAKECURL_DIR/code")"}
close $fc
file attributes $fakeCurl -permissions 0755
set fcd [file join $tmp fakecurl]
file mkdir $fcd
set ::env(FAKECURL_DIR) $fcd
set savedPath $::env(PATH)
set ::env(PATH) "$bin:$savedPath"
unset -nocomplain ::auto_execs
proc curlSays {code body} {
    ::lichstudy::writeFile [file join $::fcd code] $code
    ::lichstudy::writeFile [file join $::fcd body] $body
}
proc curlArgs {} { return [split [string trimright [::lichstudy::readFile [file join $::fcd argv]] "\n"] "\n"] }

set ::lichstudy::token lip_secret_42
curlSays 200 "{\"name\":\"Café\"}"
set r [::lichstudy::realApi https://lichess.org/api/account]
checkEq "returns code and UTF-8 body" $r [list 200 "{\"name\":\"Café\"}"]
set a [curlArgs]
checkEq "URL is the last argument" [lindex $a end] https://lichess.org/api/account
checkEq "token not on the command line" [lsearch -glob $a *lip_secret_42*] -1
checkHas "token read from stdin" [::lichstudy::readFile [file join $fcd stdin]] {header = "Authorization: Bearer lip_secret_42"}
check "config read from stdin (-K -)" [expr {[lsearch -exact $a -K] >= 0 && [lindex $a [expr {[lsearch -exact $a -K] + 1}]] eq "-"}]
checkEq "user agent" [lindex $a [expr {[lsearch -exact $a -A] + 1}]] scidCommunity-lichess-study
check "timeouts set" [expr {[lsearch -exact $a --connect-timeout] >= 0 && [lsearch -exact $a --max-time] >= 0}]
set outPath [string trim [::lichstudy::readFile [file join $fcd outpath]]]
checkEq "reply written inside the plugin folder" [file dirname $outPath] [file join $tmp lichess_study]
checkEq "reply file removed" [file exists $outPath] 0

curlSays 200 "{}"
::lichstudy::realApi https://lichess.org/api/study/AbCd1234/C1234567 -X DELETE
set a [curlArgs]
checkEq "extra arguments go before the URL" [lrange $a end-2 end] {-X DELETE https://lichess.org/api/study/AbCd1234/C1234567}

set ::lichstudy::token ""
curlSays 200 "ok"
::lichstudy::realApi https://lichess.org/api/account
checkEq "no token: empty config, no header" [::lichstudy::readFile [file join $fcd stdin]] ""

::lichstudy::writeFile [file join $fcd fail] 1
set err [catch {::lichstudy::realApi https://lichess.org/api/account} msg]
checkEq "curl failure raises" $err 1
checkHas "...as a network error" $msg "Network error: curl: (6) Could not resolve host"
checkEq "no reply file left behind" [glob -nocomplain -dir [file join $tmp lichess_study] reply_*] {}
file delete [file join $fcd fail]

section "curlExe: where curl comes from"
set empty [file join $tmp emptybin]
file mkdir $empty
set ::env(PATH) $empty
unset -nocomplain ::auto_execs
set ::scidExeDir $bin
checkEq "falls back to curl next to the scid executable" [::lichstudy::curlExe] [list $fakeCurl]
unset -nocomplain ::auto_execs
set ::scidExeDir $empty
set err [catch {::lichstudy::curlExe} msg]
checkEq "no curl anywhere: error" [list $err $msg] {1 {curl not found: it is needed to talk to Lichess.}}
set ::env(PATH) $savedPath
unset -nocomplain ::auto_execs

# ------------------------------------------------------------------- result --

file delete -force $tmp
puts "\nchecks $checks fails $fails known defects (XFAIL) $xfails"
exit [expr {$fails ? 1 : 0}]
