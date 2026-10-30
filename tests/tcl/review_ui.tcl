#!/usr/bin/env tclsh
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_ui.tcl -- the engine window's two review buttons, without Tk.
#
#   tclsh tests/tcl/review_ui.tcl
#
# Everything a widget would otherwise have to decide lives here: which button
# is live, which positions a pass searches, what the settings dialog holds and
# what it stores. The Tk glue in tcl/windows/engine.tcl stays a few lines of
# widget calls, and is guarded so a missing widget or engine is a no-op.

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

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools accuracy.tcl]
source [file join $root tcl tools move_labels.tcl]
source [file join $root tcl tools score_seed.tcl]
source [file join $root tcl tools game_review.tcl]
source [file join $root tcl tools review_ui.tcl]

# The English text of every key this file adds, so a label is asserted as
# something a reader would recognise rather than as a key name, and so the key
# set the language files must carry is written down in one place. A tclsh test
# has no language files; tr() returns the key when a tag is unknown, which is
# what Scid itself does for an untranslated string.
array set ::EN {
    ReviewGameButton        {Game Review}
    ReviewGameButtonTooltip {Review every move of the main line and label it}
    ReviewMoveButton        {Move Comment}
    ReviewMoveButtonTooltip {Label the move played from here and write it in}
    ReviewSettings          {Review Settings}
    ReviewVarLines          {Variations to write}
    ReviewVarCp             {Variation margin (cp)}
    ReviewMoveWait          {Wait for the review depth}
    ReviewFromPreset        {%s (from engine preset)}
    ReviewProgress          {Reviewing position %s of %s}
    ReviewWaitForDepth      {Waiting for depth %s}
    ReviewFailed            {Review failed: %s}
    Lines                   {Lines}
    Depth                   {Depth}
}
proc tr {tag} {
    if {[info exists ::EN($tag)]} { return $::EN($tag) }
    return $tag
}
# The keys that must be in every language file: the fourteen above are Scid's
# already, and the twelve new ones are the assertion at the end of this file.
set ::NEWKEYS {
    ReviewGameButton ReviewGameButtonTooltip ReviewMoveButton
    ReviewMoveButtonTooltip ReviewSettings ReviewVarLines ReviewVarCp
    ReviewMoveWait ReviewFromPreset ReviewProgress ReviewWaitForDepth
    ReviewFailed
}

puts "which button is live"

# One dict in, one dict out: the window asks this before it draws the bar and
# after every event that can change the answer - a new game, an engine starting
# or stopping, a pass starting, finishing or being cancelled. `reason` is for
# the log and for tests, not for the user: a disabled button keeps its tooltip.
set live [dict create game 20 engine Stockfish pass {} move e2e4]
set b [::reviewui::buttons $live]
checkEq "with a game and an engine, Game Review is live" [dict get $b review] normal
checkEq "and so is Move Comment" [dict get $b movecomment] normal
checkEq "nothing to cancel" [dict get $b cancel] disabled
checkEq "and no reason to give" [dict get $b reason] ""

set nogame [dict replace $live game 0]
checkEq "no game: Game Review is disabled" [dict get [::reviewui::buttons $nogame] review] disabled
checkEq "no game: the reason says so" [dict get [::reviewui::buttons $nogame] reason] {no game}
checkEq "no game: Move Comment is disabled too" \
    [dict get [::reviewui::buttons $nogame] movecomment] disabled

set noengine [dict replace $live engine {}]
checkEq "no engine: Game Review is disabled" \
    [dict get [::reviewui::buttons $noengine] review] disabled
checkEq "no engine: the reason says so" \
    [dict get [::reviewui::buttons $noengine] reason] {no engine}
checkEq "no engine: Move Comment is disabled" \
    [dict get [::reviewui::buttons $noengine] movecomment] disabled

# The last position of the game has no move after it, so there is nothing for
# Move Comment to label; the whole line can still be reviewed.
set atEnd [dict replace $live move {}]
checkEq "last position: nothing to comment" \
    [dict get [::reviewui::buttons $atEnd] movecomment] disabled
checkEq "last position: the game can still be reviewed" \
    [dict get [::reviewui::buttons $atEnd] review] normal
checkEq "last position: no reason against the review" \
    [dict get [::reviewui::buttons $atEnd] reason] ""

# A pass owns the engine it runs on, and the window's buttons must not start a
# second one over it. Cancel is the way out, so it is live in every pass state.
set busy [dict replace $live pass searching]
checkEq "a running pass disables Game Review" [dict get [::reviewui::buttons $busy] review] disabled
checkEq "and Move Comment, which shares the window" \
    [dict get [::reviewui::buttons $busy] movecomment] disabled
checkEq "but Cancel is live" [dict get [::reviewui::buttons $busy] cancel] normal
checkEq "with a reason" [dict get [::reviewui::buttons $busy] reason] {pass running}
checkEq "Cancel stays live while the pass writes" \
    [dict get [::reviewui::buttons [dict replace $live pass writing]] cancel] normal

# The window calls this from event handlers: a key that is missing must come
# back as a disabled button, never as an error that leaves the bar stale.
checkEq "an empty state is a disabled pair, not an error" \
    [dict get [::reviewui::buttons {}] review] disabled
checkEq "and its Cancel is disabled" [dict get [::reviewui::buttons {}] cancel] disabled

puts "what a press of Game Review asks the driver to do"

# The whole decision a press makes - which entry point the window calls and with
# which arguments - in one pure function, so it is asserted here instead of being
# read off a widget callback. A pass that searches and writes nothing is exactly
# the failure this phase is about, so the arguments are asserted one by one.
::review::reset
set preset {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {{Threads 8}}}
set base [dict create game 20 engine $preset driver 1 bookEnd 0 plies {} depth {} \
    progress {::enginewin::reviewProgress 1} notify 1]
set call [::reviewui::runCall $base]
checkEq "a review calls the driver's run, not the raw pass" \
    [dict get $call entry] ::reviewdriver::run
checkEq "on this engine, from the first move, refreshing the board at the end" \
    [dict get $call args] \
    [list $preset -bookEnd 0 -progress {::enginewin::reviewProgress 1} -notify 1]
checkEq "and there is nothing to explain" [dict get $call reason] ""
checkEq "the whole line means no -plies" \
    [expr {[lsearch -exact [dict get $call args] -plies] < 0}] 1
checkEq "and the pass's own depth means no -depth" \
    [expr {[lsearch -exact [dict get $call args] -depth] < 0}] 1

# The book's end is the caller's answer, not a constant in the window.
checkEq "a book end goes through as -bookEnd" \
    [lindex [dict get [::reviewui::runCall [dict replace $base bookEnd 7]] args] 2] 7

# Move Comment is one move, and a move it already has a depth for is searched at
# that depth: the two facts that make it a comment rather than a review.
set one [::reviewui::runCall [dict replace $base plies 3 depth 20]]
set args [dict get $one args]
checkEq "Move Comment still calls run" [dict get $one entry] ::reviewdriver::run
checkEq "with the one move to judge, at the depth it has" \
    [lrange $args [lsearch -exact $args -plies] end-4] {-plies 3 -depth 20}
checkEq "and the same engine" [lindex $args 0] $preset

# A press with nothing to review is refused here, before anything is opened:
# ::reviewdriver::run would open an engine and only then refuse.
foreach {label state want} {
    {no game}        {game 0}                  {no game}
    {no engine}      {engine {}}               {no engine}
    {no driver}      {driver 0}                {no review driver}
} {
    set s [dict replace $base {*}$state]
    set c [::reviewui::runCall $s]
    checkEq "$label: nothing is called" [dict get $c entry] ""
    checkEq "$label: and nothing is passed" [dict get $c args] {}
    checkEq "$label: but the reason is the one the window shows" [dict get $c reason] $want
}
checkEq "an empty state is a refusal, not an error" \
    [dict get [::reviewui::runCall {}] reason] {no game}

puts "the status line the driver's state maps to"

# The window no longer tracks its own token: the line is the driver's state,
# translated into the words the user reads. A run that finished says nothing -
# the labels in the game are the report - and a run that did not says why.
proc passState {state args} {
    set d [dict create state $state searched 0 total 0 written 0 failed 0 \
        errors {} reason "" restored 0]
    return [dict merge $d $args]
}
checkEq "nothing running says nothing" [::reviewui::statusText [passState idle]] ""
checkEq "a search says where it has got to" \
    [::reviewui::statusText [passState searching searched 2 total 7]] \
    {Reviewing position 2 of 7}
checkEq "before the first answer it still says how many there are" \
    [::reviewui::statusText [passState searching total 7]] \
    {Reviewing position 0 of 7}
checkEq "the write phase has nothing left to count" \
    [::reviewui::statusText [passState writing searched 7 total 7]] ""
checkEq "a finished run leaves the game to speak for it" \
    [::reviewui::statusText [passState done searched 7 total 7 written 7]] ""
checkEq "a cancelled run wrote nothing and says nothing" \
    [::reviewui::statusText [passState cancelled searched 3 total 7]] ""
checkEq "a run that could not start is reported" \
    [::reviewui::statusText [passState failed reason {engine 20 is already running a pass}]] \
    {Review failed: engine 20 is already running a pass}
checkEq "a run that lost its engine is reported in the driver's words" \
    [::reviewui::statusText [passState failed reason {the engine stopped after 3 of 7 positions}]] \
    {Review failed: the engine stopped after 3 of 7 positions}
# A finished pass can still have refused a move: writeMove leaves the game where
# it found it, so the rest of the review landed and the refusal is the only thing
# the user has to be told.
checkEq "a move the game refused is reported, not swallowed" \
    [::reviewui::statusText [passState done written 3 failed 1 \
        errors {{ply 4 is not in this game}}]] \
    {Review failed: ply 4 is not in this game}
checkEq "an empty state is idle" [::reviewui::statusText {}] ""

puts "what the settings dialog holds"

# The dialog owns six settings. Threads and Hash are not among them: they belong
# to the engine preset (#382), and a second place to set them is a second place
# to get them wrong. The dialog shows them, read-only, from the preset.
::review::reset
set s [::reviewui::settings]
checkEq "six rows, no threads, no hash" [dict keys $s] {mpv depth var_lines var_cp move_comment_wait diagram}
checkEq "at their defaults" [dict get $s depth] 18
checkEq "and mpv with them" [dict get $s mpv] 3

set good [dict create mpv 4 depth 24 var_lines 2 var_cp 40 move_comment_wait 0 diagram 1]
checkEq "a valid dialog is stored without complaint" [::reviewui::applySettings $good] {}
checkEq "and reads straight back" [::reviewui::settings] $good

# One refused field must not lose the four that were fine: the user pressed OK
# once, and a dialog that silently drops the whole edit is worse than a refusal.
set bad [dict create mpv 4 depth 24 var_lines 9 var_cp 50 move_comment_wait 1]
set why [::reviewui::applySettings $bad]
checkEq "one refusal, for the one bad field" [llength $why] 1
checkEq "naming the setting and the cap" [lindex $why 0] {var_lines cannot exceed mpv (4)}
checkEq "the other fields still land" [dict get [::reviewui::settings] move_comment_wait] 1
checkEq "and the refused one keeps what it had" [dict get [::reviewui::settings] var_lines] 2

# A value that is not a number is a refusal too, not an error out of the dialog.
set why [::reviewui::applySettings \
    [dict create mpv 3 depth deep var_lines 1 var_cp 0 move_comment_wait 1]]
checkEq "a nonsense depth is refused by name" [lindex $why 0] {depth must be a whole number}
checkEq "and the fields after it still land" [dict get [::reviewui::settings] var_lines] 1

# mpv is applied before var_lines, so one edit that lowers both is honoured
# rather than refused: the dialog order is the order the setter's rules need.
::review::reset
set why [::reviewui::applySettings \
    [dict create mpv 2 depth 18 var_lines 5 var_cp 0 move_comment_wait 1]]
checkEq "lowering mpv and leaving var_lines high is refused once" [llength $why] 1
checkEq "with the mpv it was lowered to" [lindex $why 0] {var_lines cannot exceed mpv (2)}
checkEq "so var_lines keeps the value it had" [dict get [::reviewui::settings] var_lines] 1

# A field the dialog does not have is ignored rather than stored.
checkEq "an unknown field is not a setting" \
    [::reviewui::applySettings [dict create threads 8]] {}

puts "the preset's read-only line"

set enginecfg {Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 \
    {{Threads 8 integer 1 1 128} {Hash 256 spin 16 1 4096} {MultiPV 1 spin 1 1 10}}}
checkEq "threads and hash, from the preset" \
    [::reviewui::presetLimits $enginecfg] {Threads 8, Hash 256 MB}
checkEq "one of the two is enough" \
    [::reviewui::presetLimits {X /x {} {} 0 0 {} 1 {{Threads 4 integer 1 1 128}}}] {Threads 4}
checkEq "an engine that advertises neither shows nothing" \
    [::reviewui::presetLimits {X /x {} {} 0 0 {} 1 {}}] ""

# The line under the dialog's own fields: the numbers, and where they come from.
checkEq "the note says where they come from" \
    [::reviewui::presetNote $enginecfg] {Threads 8, Hash 256 MB (from engine preset)}
checkEq "no preset values, no note" \
    [::reviewui::presetNote {X /x {} {} 0 0 {} 1 {}}] ""
# The note is what the pass will take, not what the preset reserves: a preset of
# Threads 64 / Hash 110000 is run as 8 / 512, because the pass is a second engine
# and the preset's full reservation would be allocated beside the window's.
checkEq "the note shows the pass's share of a large preset" \
    [::reviewui::presetNote {X /x {} {} 0 0 {} 1 {{Threads 64} {Hash 110000}}}] \
    {Threads 8, Hash 512 MB (from engine preset)}

puts "the move comment's gate"

# ::review::moveCommentPlan already decides now-or-wait (merged with #378): with
# move_comment_wait set, a comment waits until the analysis reaches the review
# depth, because a verdict written from a depth-12 result is not the verdict the
# user asked for. The window needs that decision as something it can put in the
# status line and act on, so it is handed back as one dict.
::review::reset
set st [::reviewui::moveCommentStatus 20]
checkEq "deep enough: write now" [dict get $st action] now
checkEq "and there is nothing to wait for" [dict get $st depth] ""
checkEq "too shallow: wait" [dict get [::reviewui::moveCommentStatus 12] action] wait
checkEq "and say which depth it waits for" [dict get [::reviewui::moveCommentStatus 12] depth] 18
checkEq "nothing analysed yet is a wait too" [dict get [::reviewui::moveCommentStatus ""] action] wait
checkEq "a nonsense depth is a wait, not a write" \
    [dict get [::reviewui::moveCommentStatus deep] action] wait

::review::setValue move_comment_wait 0
checkEq "with the wait turned off, write whatever the engine has" \
    [dict get [::reviewui::moveCommentStatus 4] action] now
::review::setValue depth 24
::review::setValue move_comment_wait 1
checkEq "the depth it waits for is the review's own" \
    [dict get [::reviewui::moveCommentStatus 20] depth] 24

# The status line is the driver's state, not a sentence about waiting: see
# statusText below, which is where every press's line comes from.

puts "the progress line"

checkEq "a pass says where it is" [::reviewui::progressText 2 7] {Reviewing position 2 of 7}
checkEq "the first position is the first" [::reviewui::progressText 0 7] {Reviewing position 0 of 7}
checkEq "a pass with no positions says nothing" [::reviewui::progressText 0 0] ""

# A failed pass has to say so, in the window, with the reason the driver or the
# board gave: an empty status line after Cancel is fine, after a failure it is a
# silent no-op.
checkEq "a failure names its reason" \
    [::reviewui::failedText {ply 12 is not in this game}] \
    {Review failed: ply 12 is not in this game}
checkEq "no reason, no failure text" [::reviewui::failedText ""] ""

# The two buttons' own labels and tooltips come from the tables above, so the
# window never holds a user-visible string.
checkEq "the Game Review button's text" [::reviewui::label ReviewGameButton] {Game Review}
checkEq "its tooltip" [::reviewui::label ReviewGameButtonTooltip] \
    {Review every move of the main line and label it}
checkEq "the Move Comment button's text" [::reviewui::label ReviewMoveButton] {Move Comment}
checkEq "the settings dialog's title" [::reviewui::label ReviewSettings] {Review Settings}
foreach key {mpv depth var_lines var_cp move_comment_wait diagram} {
    check "the $key row has a label" \
        [expr {[::reviewui::settingLabel $key] ne "" && [::reviewui::settingLabel $key] ne $key}]
}
checkEq "an unknown row has no label" [::reviewui::settingLabel colour] ""

puts "the keys every language file must carry"

# Scid ships one file per language, and a string that reaches only English
# leaves every other user with an English button in a translated window. The
# check is written from ::NEWKEYS so the list here cannot drift from the module,
# and the file list is read from the tree so a new language file fails loudly
# instead of being silently untranslated.
set langDir [file join $root tcl lang]
set langCodes [dict create \
    english.tcl E    czech.tcl C      deutsch.tcl D    francais.tcl F \
    greek.tcl G      hungary.tcl H    italian.tcl I    nederlan.tcl N \
    norsk.tcl O      polish.tcl P     portbr.tcl B     russian.tcl R \
    serbian.tcl Y    spanish.tcl S    suomi.tcl U      swedish.tcl W \
    chinese.tcl M    turkish.tcl T    SerbCyr.tcl J    japanese.tcl A \
    romanian.tcl L   hebrew.tcl V     swahili.tcl Z    hindi.tcl h \
    ukrainian.tcl Q  bengali.tcl b    korean.tcl k     bulgarian.tcl g \
    catalan.tcl K]
# Not language files: the tools that maintain them.
set langTools {checklangs.tcl propagatelang.tcl removedeadlang.tcl removetoken.tcl}
set langOnDisk {}
foreach f [glob -nocomplain [file join $langDir *.tcl]] {
    if {[lsearch -exact $langTools [file tail $f]] >= 0} { continue }
    lappend langOnDisk [file tail $f]
}
checkEq "every language file on disk is one this test knows the code for" \
    [lsort $langOnDisk] [lsort [dict keys $langCodes]]

proc langText {file} {
    set fh [open $file r]
    fconfigure $fh -encoding utf-8
    set text [read $fh]
    close $fh
    return $text
}

set missingAll {}
foreach file [lsort [dict keys $langCodes]] {
    set code [dict get $langCodes $file]
    set text [langText [file join $langDir $file]]
    set missing {}
    foreach key $::NEWKEYS {
        if {![regexp "translate $code $key \\{(.+?)\\}" $text -> word] ||
            [string trim $word] eq ""} {
            lappend missing $key
        }
    }
    check "$file carries the twelve review keys" [expr {![llength $missing]}] \
        "missing: $missing"
    if {[llength $missing]} { lappend missingAll $file }
}
check "no language file is missing a review key" [expr {![llength $missingAll]}] \
    "files: $missingAll"

# And the English text is the text this test asserts the labels against, so a
# label that reads "Lines" here and "MultiPV" there fails.
set english [langText [file join $langDir english.tcl]]
foreach key $::NEWKEYS {
    regexp "translate E $key \\{(.+?)\\}" $english -> word
    checkEq "english.tcl says what the label shows ($key)" $word $::EN($key)
}

# Spot checks that these are translations and not the English text a
# propagation run left behind.
regexp {translate D ReviewGameButton \{(.+?)\}} [langText [file join $langDir deutsch.tcl]] -> de
regexp {translate F ReviewMoveButton \{(.+?)\}} [langText [file join $langDir francais.tcl]] -> fr
regexp {translate M ReviewProgress \{(.+?)\}} [langText [file join $langDir chinese.tcl]] -> zh
check "german Game Review is not the English word" [expr {$de ne "Game Review"}] "got '$de'"
check "french Move Comment is not the English word" [expr {$fr ne "Move Comment"}] "got '$fr'"
check "chinese progress keeps both placeholders" \
    [expr {[llength [regexp -all -inline {%s} $zh]] == 2}] "got '$zh'"

puts "the depth a one-move comment searches at"

# Move Comment runs the same pass over one move. Which depth it uses is the
# setting's decision: with move_comment_wait on, the comment has to be the one a
# review would have written, so the pass searches at the review's depth and the
# status line says what it is waiting for. With the wait off, the analysis the
# window is already showing is good enough and nothing waits.
::review::reset
set d [::reviewui::moveCommentDepth 20]
checkEq "the analysis is deep enough: search at what it has" [dict get $d depth] 20
checkEq "and do not make the user wait" [dict get $d wait] 0
set d [::reviewui::moveCommentDepth 12]
checkEq "too shallow: search at the review's depth" [dict get $d depth] 18
checkEq "and say we are waiting" [dict get $d wait] 1
checkEq "nothing analysed: the review's depth, waiting" \
    [dict get [::reviewui::moveCommentDepth ""] depth] 18
# A preset with its own deeper limit raises the depth a review searches at
# (::review::effective), so Move Comment has to wait for that depth and search to
# it, not to the setting: one move cannot get two verdicts at two depths.
set d [::reviewui::moveCommentDepth 20 30]
checkEq "the preset's deeper floor is the depth to search" [dict get $d depth] 30
checkEq "and an analysis at 20 is not deep enough for it" [dict get $d wait] 1
set d [::reviewui::moveCommentDepth 30 30]
checkEq "at the preset's depth the comment can be written" [dict get $d depth] 30
checkEq "and nothing waits" [dict get $d wait] 0
checkEq "an empty target still means the review's own depth" \
    [dict get [::reviewui::moveCommentDepth 12] depth] 18

::review::setValue move_comment_wait 0
checkEq "with the wait off, a shallow analysis is still enough" \
    [dict get [::reviewui::moveCommentDepth 4] depth] 4
# 0 is what the depth map holds for a position whose analysis is queued and has
# not answered yet; it is not a depth to search at.
checkEq "a queued position is not a depth to search" \
    [dict get [::reviewui::moveCommentDepth 0] depth] 18
checkEq "and it does not wait for a number that is already there" \
    [dict get [::reviewui::moveCommentDepth 0] wait] 0
checkEq "and nothing waits" [dict get [::reviewui::moveCommentDepth 4] wait] 0
::review::reset

puts "the dialog's spin boxes"

# A spinbox needs bounds, and they have to agree with what ::review::setValue
# accepts: a box that offers a value the setter refuses is a dialog that cannot
# be completed.
foreach key {mpv depth var_lines var_cp move_comment_wait diagram} {
    set range [::reviewui::settingRange $key]
    check "$key has a range" [expr {[llength $range] == 2}]
    lassign $range lo hi
    set now [::review::get $key]
    check "$key's current value is inside its range" [expr {$now >= $lo && $now <= $hi}] \
        "now $now, range $range"
    check "$key's range agrees with the setter" \
        [expr {[::review::setValue $key $lo] eq "" && [::review::setValue $key $hi] eq ""}] \
        "range $range refused by setValue"
    ::review::reset
}
checkEq "an unknown row has no range" [::reviewui::settingRange colour] ""
::review::reset
checkEq "the mpv range stops where the setter does" \
    [lindex [::reviewui::settingRange mpv] 1] 5
# The dialog asks about the mpv the user is editing, not the stored one, so the
# variation box can offer the lines a raised MultiPV allows.
checkEq "a pending mpv raises the variation box" \
    [lindex [::reviewui::settingRange var_lines 5] 1] 5
checkEq "and one line means no variations at all" \
    [lindex [::reviewui::settingRange var_lines 1] 1] 0
checkEq "with no mpv given it reads the stored one" \
    [lindex [::reviewui::settingRange var_lines] 1] [::review::get mpv]
checkEq "and so does the depth range" \
    [lindex [::reviewui::settingRange depth] 0] 6

puts "\nthe engine window's guards (read, not run: this harness has no Tk)"

# tcl/windows/engine.tcl cannot be loaded here, and each of these is one clause
# in a loop or a line in a <Destroy> binding. Both are invisible until the case
# they exist for happens - a window opened on the pass's own connection, or a
# window closed while its pass is still searching - so they are asserted as text.
set engineSrc [langText [file join $root tcl windows engine.tcl]]
check "a window never takes the pass's connection id" \
    [regexp {while \{\[winfo exists \.engineWin\$id\] \|\| \[::enginewin::idReserved \$id\]\}} $engineSrc]
check "and a viewer's window neither" \
    [regexp {while \{\[info exists ::enginewin::pgnviewer\(\$id\)\] \|\| \[::enginewin::idReserved \$id\]\}} $engineSrc]
check "closing a window stops its pass" \
    [regexp {catch \{ ::enginewin::reviewCancel \$id \}} $engineSrc]
check "and a new game stops any pass, whichever window started it" \
    [regexp {catch \{ ::enginewin::reviewStopAll \}} $engineSrc]
# The window no longer keeps the pass's results: ::reviewdriver::run writes them
# into the game, and ::reviewdriver::status is the only copy of the run's state.
check "the window asks what to call instead of calling the raw pass" \
    [regexp {::reviewui::runCall \$state} $engineSrc]
check "a finished run is announced by the driver's board refresh" \
    [regexp -- {progress \[list ::enginewin::reviewProgress \$id\] notify 1} $engineSrc]
check "and gives the window back when it does" \
    [regexp {::enginewin::reviewRefreshAll} $engineSrc]
check "the status line is the driver's state, not a token" \
    [regexp {::reviewui::statusText \[::reviewdriver::status\]} $engineSrc]
check "Cancel asks the driver, not a token it tracked" \
    [regexp {::reviewdriver::cancel} $engineSrc]
check "the settings dialog asks about the mpv being edited" \
    [regexp {::reviewui::settingRange var_lines \$mpv} $engineSrc]

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
