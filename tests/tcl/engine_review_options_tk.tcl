#!/usr/bin/env wish
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# engine_review_options_tk.tcl -- the cloud pre-pass switch as engine
# configuration, in the engine options panel.
#
#   xvfb-run -a wish tests/tcl/engine_review_options_tk.tcl
#
# The switch used to be a global review setting, so a 100 ms browsing config and
# a depth-18 verdict config shared it. It is now a row of the engine
# configuration's option list (element 8, beside Threads and MultiPV): the engine
# options panel draws it, ::enginecfg::save writes it into engines.dat, and
# ::review::engineDefaults reads it back for the pass.
#
# This harness builds that panel for real - the text widget, the checkbutton,
# ::enginecfg::setOption, ::enginecfg::save and the engines.dat write - and then
# reopens it from the saved file, which is the round trip a user makes. Only the
# window's own fields (name, command, protocol) are stubbed out: they belong to
# the engine window's test, not to this panel.

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

# --------------------------------------------------------------- environment --
proc tr {tag args} {
    if {[info exists ::TR($tag)]} { return $::TR($tag) }
    if {[llength $args]} { return [lindex $args 0] }
    return $tag
}
array set ::TR {
    ReviewCloudEval {Cloud pre-pass}
}
# The real helper is in tcl/start.tcl and also paints the switch's glyph. What
# matters here is the value it answers, which is what ::enginecfg::setOption
# stores.
proc ::update_switch_btn {widget {set_value ""}} {
    set varname [$widget cget -variable]
    if {$set_value ne ""} { set ::$varname $set_value }
    return [expr {[$widget instate selected] ? "true" : "false"}]
}
# The engine is not part of this panel's contract, but what is SENT to it is: the
# review's row is not a UCI option and must never reach a setoption.
set ::sent {}
namespace eval ::engine {}
proc ::engine::send {id msg args} {
    lappend ::sent [list $id $msg [lindex $args 0]]
}
# The real wrapper is in enginecomm.tcl, which this panel harness does not load;
# the filter itself belongs to ::enginecfg and is what the checks read.
proc ::engine::uciOptions {options} {
    return [::enginecfg::uciOptions $options]
}
# ::engineNoWin::initEngineOptions asks the engine for InfoConfig after it has built
# the panel; the reply is what repaints the rows and settles the Reset button. The
# answer is recorded here and delivered by hand, so the windowless section below can
# show what the panel looks like at the moment the user could click Reset.
set ::infoConfigAsked {}
proc ::engine::replyInfoConfig {id} {
    lappend ::infoConfigAsked $id
}
# The spinbox validator the real app loads from tcl/validate.tcl.
namespace eval ::validate {}
proc ::validate::integer {value {min ""} {max ""}} {
    if {![string is integer -strict $value]} { return 0 }
    if {$min ne "" && $value < $min} { return 0 }
    if {$max ne "" && $value > $max} { return 0 }
    return 1
}
# The text widget's own font, which the panel measures its labels with.
set ::font_Regular TkDefaultFont
# engines.dat, written where the panel's save path expects it.
set ::enginesFile [file join [pwd] engines-test.dat]
proc scidConfigFile {name} { return $::enginesFile }
set ::scidVersion test

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl enginecfg.tcl]
source [file join $root tcl tools engine_limits.tcl]
source [file join $root tcl tools enginenowin.tcl]
source [file join $root tcl tools game_review.tcl]

# The window's fields are the engine window's business; the option merge and the
# option panel are this harness's.
rename ::enginecfg::createConfigWidgets ::enginecfg_createConfigWidgets_real
proc ::enginecfg::createConfigWidgets {id configFrame engCfg} { return 1 }

# ---------------------------------------------------------- the saved config --
# A preset with the engine's own options in element 8, in the shape a handshake
# leaves them: what engines.dat carries is the {name value} pairs ::enginecfg::save
# keeps from this.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 \
        {{Threads 8 integer 1 1 128 {} 0} {MultiPV 3 spin 1 1 10 {} 0}}]]

wm withdraw .
proc panel {cfname} {
    if {[winfo exists $cfname]} { destroy $cfname }
    ttk::frame $cfname
    text $cfname.text -wrap none -width 60 -height 12
    $cfname.text tag configure netclients_tag
    return $cfname.text
}

# The handshake: the engine answers with its own option list, which
# ::enginecfg::updateConfigOptions stores in element 8 and renders. The tag range
# ::enginecfg::updateNetClients replaces has to exist, because the real panel's
# builder leaves one behind and resetConfigOptions has just emptied the widget.
proc handshake {id frame options} {
    # resetConfigOptions leaves the widget disabled, and an insert into a disabled
    # text is ignored.
    $frame.text configure -state normal
    $frame.text insert end " " netclients_tag
    ::enginecfg::updateConfigOptions $id $frame [list uci {} $options]
    update idletasks
}

proc config {name} {
    return [lsearch -exact -inline -index 0 $::engines(list) $name]
}

puts "\nthe rows the panel draws"

set frame .cfgA
set w [panel $frame]
::enginecfg::resetConfigOptions r1 $frame [::enginecfg::get Stockfish]
# A handshake replaces element 8 with the engine's own list; the review's row is
# carried across it, which is what keeps the switch from being wiped by the engine
# connecting.
handshake r1 $frame {{Threads 8 integer 1 1 128 {} 0} {MultiPV 3 spin 1 1 10 {} 0}}

set options [lindex [set ::enginecfg::engConfig_r1] 8]
checkEq "the engine's own options are still there" \
    [lmap e $options {if {[::enginecfg::isReviewOption [lindex $e 0]]} continue ; lindex $e 0}] \
    {Threads MultiPV}
checkEq "with the review's row at the end" \
    [lmap e $options {if {![::enginecfg::isReviewOption [lindex $e 0]]} continue ; lindex $e 0}] \
    {cloud_eval}
checkEq "a config that says nothing opens it on" \
    [lindex [set ::enginecfg::engConfig_r1] 8 2 1] true
check "the Cloud pre-pass row is drawn" [winfo exists $w.value2]
checkEq "as a switch" [winfo class $w.value2] TCheckbutton
set text [$w get 1.0 end]
check "the switch's row says Cloud pre-pass" \
    [expr {[string first "Cloud pre-pass:" $text] >= 0}]
checkEq "and the engine's own option label is unchanged" \
    [expr {[string first "Threads:" $text] >= 0}] 1

puts "\nticking the switch"

set ::sent {}
$w.value2 invoke
update idletasks
checkEq "the switch reads off" [::update_switch_btn $w.value2] false
checkEq "and the config carries it" \
    [lindex [set ::enginecfg::engConfig_r1] 8 2 1] false
# No engine reply will make the frame save later, so the toggle is written to the
# saved preset at once: a pass started from this window reads it through
# ::enginecfg::get.
checkEq "and the saved preset carries it at once" \
    [dict get [::review::engineDefaults [::enginecfg::get Stockfish]] cloud_eval] 0
checkEq "nothing was sent to the engine for it" $::sent {}
# The engine's own options are still sent, on the other hand, and the review's
# row is not a UCI option: ::enginecfg::uciOptions is what every SetOptions is
# built from (::engine::uciOptions in enginecomm.tcl is the guarded call site).
::enginecfg::setOption r1 0 4
checkEq "an engine option is sent" [lindex $::sent 0 2] {{Threads 4}}
checkEq "and the review's row is not an option to send" \
    [lmap e [::enginecfg::uciOptions [lindex [set ::enginecfg::engConfig_r1] 8]] {lindex $e 0}] \
    {Threads MultiPV}

puts "\nsaving it, and reopening"

checkEq "the preset saves under its own name" \
    [::enginecfg::save [set ::enginecfg::engConfig_r1]] Stockfish
# engines.dat keeps the {name value} pairs that are not at their default: the
# engine's own Threads 8 and MultiPV 3, and the switch the user turned off.
checkEq "engines.dat keeps the value as the config's own option" \
    [lindex [config Stockfish] 8] \
    {{Threads 8} {MultiPV 3} {cloud_eval false}}
check "and the file on disk carries it" \
    [expr {[string first "cloud_eval" [read [set fh [open $::enginesFile r]]]] >= 0}]
close $fh

# Reopening: the saved config is what the next session reads, so the panel is
# built again from it - a fresh handshake included, which is where a switch that
# was not carried across would silently come back on.
set saved [config Stockfish]
set frameD .cfgD
set wD [panel $frameD]
::enginecfg::resetConfigOptions r4 $frameD $saved
checkEq "the saved value is in element 8 before the engine connects" \
    [lmap e [lindex [set ::enginecfg::engConfig_r4] 8] {lindex $e 1}] {false}
handshake r4 $frameD {{Threads 8 integer 1 1 128 {} 0} {MultiPV 3 spin 1 1 10 {} 0}}
checkEq "and the handshake keeps it" \
    [lmap e [::enginecfg::reviewOptions [lindex [set ::enginecfg::engConfig_r4] 8]] {lindex $e 1}] \
    {false}
checkEq "so the reopened panel shows the switch off" \
    [::update_switch_btn $wD.value2] false

# What the pass reads from the saved config.
checkEq "the pass sees the switch off" \
    [dict get [::review::engineDefaults $saved] cloud_eval] 0
checkEq "so ::review::effective turns the pre-pass off for this config" \
    [dict get [::review::effective $saved] cloud_eval] 0
set plain [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {}]
checkEq "while a config that says nothing keeps it on" \
    [dict get [::review::effective $plain] cloud_eval] 1

puts "\ntwo configs, two answers"

# The point of the move: a browsing preset opts out, a verdict preset does not.
set ::engines(list) [list \
    [list Browsing /usr/bin/stockfish {} {} 0 0 {} 1 {{cloud_eval false}}] \
    [list Verdict /usr/bin/stockfish {} {} 0 0 {} 1 {}]]
checkEq "the browsing config turns the pre-pass off" \
    [list [dict get [::review::engineDefaults [::enginecfg::get Browsing]] cloud_eval] \
          [dict get [::review::effective [::enginecfg::get Browsing]] cloud_eval]] {0 0}
checkEq "the verdict config keeps it" \
    [dict get [::review::effective [::enginecfg::get Verdict]] cloud_eval] 1

set frameB .cfgB
set wB [panel $frameB]
::enginecfg::resetConfigOptions r2 $frameB [::enginecfg::get Browsing]
handshake r2 $frameB {{Threads 8 integer 1 1 128 {} 0}}
update idletasks
checkEq "the panel opens the browsing config with the switch off" \
    [lindex [set ::enginecfg::engConfig_r2] 8 1 1] false
checkEq "and the widget shows it" [::update_switch_btn $wB.value1] false
# Ticking it back on and saving must not touch the other config.
$wB.value1 invoke
checkEq "ticking it back on" \
    [lindex [set ::enginecfg::engConfig_r2] 8 1 1] true
checkEq "and the other config keeps its own answer" \
    [dict get [::review::effective [::enginecfg::get Verdict]] cloud_eval] 1

puts "\na value at its default is not written"

# ::enginecfg::save drops an option sitting at its default, so a config that keeps
# the pre-pass on writes nothing at all - which is why an engines.dat from before
# this row existed needs no migration.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 \
        {{Threads 8 integer 1 1 128 {} 0} {cloud_eval true check true {} {} {} 0}}]]
::enginecfg::save [lindex $::engines(list) 0]
checkEq "a config that leaves it on stores no row" \
    [lindex [config Stockfish] 8] {{Threads 8}}

puts "\nthe reset button"

# "Reset Options" resets the whole panel the user is looking at, the review's row
# with it, and sends nothing to the engine for it.
#
# The engine's own option sits at its default here, so the review's switch is the
# only row away from its default: onSubmitReset sends the engine nothing, no
# InfoConfig reply comes back, and the panel is the one thing that can show the
# reset.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 \
        {{cloud_eval false}}]]
set frameC .cfgC
set wC [panel $frameC]
::enginecfg::resetConfigOptions r3 $frameC [::enginecfg::get Stockfish]
handshake r3 $frameC {{Threads 1 integer 1 1 128 {} 0}}
update idletasks
checkEq "the panel opens the preset's switch off" \
    [::update_switch_btn $wC.value1] false
checkEq "so Reset is offered" [$wC.reset cget -state] normal
set ::sent {}
::enginecfg::onSubmitReset r3 $frameC
update idletasks
checkEq "the review's row goes back to on" \
    [lindex [set ::enginecfg::engConfig_r3] 8 1 1] true
checkEq "nothing at all was sent, so no reply repaints the panel" $::sent {}
checkEq "and the panel shows what reset stored" \
    [::update_switch_btn $wC.value1] true
checkEq "with Reset turned off, nothing being away from its default" \
    [$wC.reset cget -state] disabled

# The same reset with an engine option away from its default as well: the reply will
# repaint the engine's rows, but the review's is already showing what was stored,
# and Reset stays offered for the default the engine has not answered for yet.
set frameE .cfgE
set wE [panel $frameE]
::enginecfg::resetConfigOptions r5 $frameE [::enginecfg::get Stockfish]
handshake r5 $frameE {{Threads 8 integer 1 1 128 {} 0}}
update idletasks
checkEq "the engine's own option is away from its default" \
    [lindex [set ::enginecfg::engConfig_r5] 8 0 1] 8
set ::sent {}
::enginecfg::onSubmitReset r5 $frameE
update idletasks
checkEq "an engine option away from its default is sent" [lindex $::sent 0 2] {{Threads 1}}
checkEq "the review's row is repainted from element 8 all the same" \
    [::update_switch_btn $wE.value1] true
checkEq "and Reset stays offered for the engine's own row" \
    [$wE.reset cget -state] normal

puts "\nthe reset button, from the switch's side"

# The other direction of the same button: a row left away from its default has to
# bring Reset back. The review's row can only be changed through the panel, the
# engine never answers for it, and the reply that settles the button for an engine
# option therefore never comes - the checkbutton's own -command has to.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 \
        {{Threads 1 integer 1 1 128 {} 0}}]]
set frameF .cfgF
set wF [panel $frameF]
::enginecfg::resetConfigOptions r6 $frameF [::enginecfg::get Stockfish]
handshake r6 $frameF {{Threads 1 integer 1 1 128 {} 0}}
update idletasks
checkEq "the panel opens with every row at its default" [$wF.reset cget -state] disabled
checkEq "and the switch shows on" [::update_switch_btn $wF.value1] true
set ::sent {}
$wF.value1 invoke
update idletasks
checkEq "a click stores the value in element 8" \
    [lindex [set ::enginecfg::engConfig_r6] 8 1 1] false
checkEq "and the engine is told nothing" $::sent {}
checkEq "with a row away from its default, Reset is offered" \
    [$wF.reset cget -state] normal
# The label is bold while the row is away from its default, the same way the
# engine's own rows are painted: nothing else repaints a review row, because no
# InfoConfig reply comes for it.
check "and its label is marked as changed" \
    [expr {[llength [$wF tag ranges header]] > 0}]
set offered [$wF.reset cget -state]
# Ticking the same row back is the panel returning to its defaults: there is
# nothing left for Reset to do, and no reply will come to say so.
$wF.value1 invoke
update idletasks
checkEq "ticking it back leaves element 8 at its default" \
    [lindex [set ::enginecfg::engConfig_r6] 8 1 1] true
checkEq "so Reset is turned off again, by the row itself" \
    [list $offered [$wF.reset cget -state]] {normal disabled}
checkEq "and the mark on its label goes with it" [$wF tag ranges header] {}

puts "\nthe windowless panel"

# ::engineNoWin::initEngineOptions is the options frame the new-engine dialog
# (enginelist.tcl) and the engine setup in multicomp.tcl show. It draws
# ::enginecfg::uciOptions - the engine's own rows - while element 8 carries the
# review's row as well, so the row has no widget there. Reset and the Reset button
# must leave it alone: a preset whose pre-pass was turned off in the engine window
# is opened here too, and turning the switch back on behind a panel that does not
# draw it would be a setting the user cannot see.
#
# The engine's own row is away from its default, so the reset has something to send
# and the panel is repainted by the reply, the way it is in the app.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 \
        {{Threads 8 integer 1 1 128 {} 0} {cloud_eval false check true {} {} {} 0}}]]
set frameG .cfgG
set wG [panel $frameG]
::enginecfg::resetConfigOptions r7 $frameG [::enginecfg::get Stockfish]
set ::infoConfigAsked {}
::engineNoWin::initEngineOptions r7 $frameG {{Threads 8 integer 1 1 128 {} 0}}
update idletasks
checkEq "the handshake leaves the engine's row and the review's in element 8" \
    [lmap e [lindex [set ::enginecfg::engConfig_r7] 8] {lindex $e 0}] {Threads cloud_eval}
checkEq "the panel asks for the repaint that settles its rows" $::infoConfigAsked r7
check "the engine's own row is drawn" [winfo exists $wG.value0]
checkEq "and the review's row is not" \
    [expr {[winfo exists $wG.value1] ? 1 : 0}] 0
checkEq "so the panel carries no switch" \
    [expr {[string first "Cloud pre-pass" [$wG get 1.0 end]] >= 0}] 0
# The InfoConfig reply: the engine's rows repaint from it, and it is what settles the
# Reset button in this panel.
::enginecfg::updateOptionWidgets r7 $frameG \
    [::enginecfg::uciOptions [lindex [set ::enginecfg::engConfig_r7] 8]] {}
checkEq "with the engine's row away from its default, Reset is offered" \
    [$wG.reset cget -state] normal
set ::sent {}
::enginecfg::onSubmitReset r7 $frameG
update idletasks
checkEq "the engine's row is reset as usual" [lindex $::sent 0 2] {{Threads 1}}
checkEq "and the switch the panel does not draw keeps the preset's value" \
    [lindex [set ::enginecfg::engConfig_r7] 8 1 1] false
checkEq "so the preset still opts the pre-pass out" \
    [dict get [::review::effective [lindex $::engines(list) 0]] cloud_eval] 0

# The same panel for a preset with nothing visible away from its default: element 8
# still holds the review's row away from its own default, and the button has to be
# settled by the rows the panel draws. The scan is the one onSubmitReset runs after a
# reset and the engine window's switch runs after a toggle.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 \
        {{Threads 1 integer 1 1 128 {} 0} {cloud_eval false check true {} {} {} 0}}]]
set frameH .cfgH
set wH [panel $frameH]
::enginecfg::resetConfigOptions r8 $frameH [::enginecfg::get Stockfish]
::engineNoWin::initEngineOptions r8 $frameH {{Threads 1 integer 1 1 128 {} 0}}
update idletasks
::enginecfg::updateOptionWidgets r8 $frameH \
    [::enginecfg::uciOptions [lindex [set ::enginecfg::engConfig_r8] 8]] {}
checkEq "every row the panel draws is at its default, so Reset is off" \
    [$wH.reset cget -state] disabled
::enginecfg::refreshReviewRows r8 $frameH
checkEq "and the undrawn review row does not turn it on" \
    [$wH.reset cget -state] disabled
# The guard is about rows without a widget, not about review rows as such: an engine
# row away from its default still offers Reset.
lset ::enginecfg::engConfig_r8 8 0 1 8
::enginecfg::refreshReviewRows r8 $frameH
checkEq "while a row the panel does draw still offers it" [$wH.reset cget -state] normal

puts "\na preset whose only stored row is the review switch"

# Filtering happens before the emptiness test. This preset keeps no engine
# options (they all sit at their defaults), so element 8 is only the review row;
# sending it would be a SetOptions with an empty list, which reaches
# ::uci::sendOptions without its data argument. Nothing must be sent at all.
set ::engines(list) [list \
    [list Stockfish /usr/bin/stockfish {} {} 0 0 {} 1 {{cloud_eval false}} {}]]
# The two calls ::engineNoWin::initEngine makes before it sends: this harness has
# no enginecomm, so their absence is not what is under test.
proc ::engine::setLogCmd {id args} {}
proc ::engine::connect {args} { return 1 }
set ::sent {}
::engineNoWin::initEngine noopts Stockfish {}
checkEq "nothing is sent rather than an empty SetOptions" $::sent {}
unset -nocomplain ::enginecfg::engConfig_noopts

catch { file delete -force $::enginesFile }
puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
