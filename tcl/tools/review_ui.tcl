# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_ui.tcl -- the engine window's two review buttons, without Tk.
#
# Game Review and Move Comment are two buttons over one engine pass. What they
# do is decided here, where it can be tested from tclsh: which of them is live,
# which positions a pass searches, what the settings dialog holds and what it
# stores. tcl/windows/engine.tcl keeps the widgets, and every call into it is
# guarded so a missing widget or engine is a no-op rather than an error in the
# middle of a game.
#
# Nothing here searches and nothing here touches the board.

namespace eval ::reviewui {}

# What a press of Game Review or Move Comment asks the engine pass to do.
#
# The driver's entry point and every argument it is given, decided here so a
# tclsh test can reach it. Which position each move is searched at belongs to
# ::reviewdriver::planPositions, and which moves are judged belongs to
# ::review::plan; this only decides the call.
#
#   game     plies in the open main line (0: no game, or an empty one)
#   engine   the preset ::enginecfg::get answered ({} when none is selected)
#   driver   1 when ::reviewdriver::run is loaded
#   bookEnd  where the opening book ends (0: search from the first move)
#   plies    the moves to judge ({}: every move the plan covers)
#   depth    the depth to search ({}: the pass decides, from ::review::effective)
#   progress the command the driver calls as {*}$progress <done> <total>
#   notify   1 to refresh the board once the write phase ends
#
# Answers {entry <command> args <argv> reason <why entry is empty>}. A missing
# key is that key's default, so a window caught mid-teardown is refused rather
# than raising inside a button callback.
proc ::reviewui::runCall {state} {
    set out [dict create entry "" args {} reason ""]
    set game [expr {[dict exists $state game] ? [dict get $state game] : 0}]
    set engine [expr {[dict exists $state engine] ? [dict get $state engine] : {}}]
    set driver [expr {[dict exists $state driver] ? [dict get $state driver] : 0}]
    set bookEnd [expr {[dict exists $state bookEnd] ? [dict get $state bookEnd] : 0}]
    set plies [expr {[dict exists $state plies] ? [dict get $state plies] : {}}]
    set depth [expr {[dict exists $state depth] ? [dict get $state depth] : ""}]
    set progress [expr {[dict exists $state progress] ? [dict get $state progress] : ""}]
    set notify [expr {[dict exists $state notify] ? [dict get $state notify] : 0}]
    if {![string is integer -strict $game] || $game < 1} {
        return [dict replace $out reason {no game}]
    }
    if {![llength $engine]} {
        return [dict replace $out reason {no engine}]
    }
    if {!$driver} {
        return [dict replace $out reason {no review driver}]
    }
    set args [list $engine -bookEnd $bookEnd]
    if {[llength $plies]} { lappend args -plies $plies }
    if {$depth ne ""} { lappend args -depth $depth }
    lappend args -progress $progress -notify $notify
    return [dict create entry ::reviewdriver::run args $args reason ""]
}

# Which of the window's three review controls are live, from the state the
# window is in. Nothing here reads a widget or asks the engine: the caller
# passes what it knows, so this is the whole decision and it is testable.
#
#   game   plies in the open game (0: no game, or an empty one)
#   engine the analysis engine's name ("" when none is selected)
#   pass   "" , or the pass state: searching, writing
#   move   the UCI move the reader is on - the one that led to this position
#          ("" at the start of the line)
#
# A pass owns its own engine connection, but it owns the window's buttons too:
# starting a second pass over a running one is a Go with no engine behind it.
# Cancel is the way out, so it is live exactly while a pass is.
#
# `reason` is not shown to the user - a disabled button keeps its tooltip - but
# it is what a bug report needs, and it is what the tests assert.
proc ::reviewui::buttons {state} {
    set game [expr {[dict exists $state game] ? [dict get $state game] : 0}]
    set engine [expr {[dict exists $state engine] ? [dict get $state engine] : ""}]
    set pass [expr {[dict exists $state pass] ? [dict get $state pass] : ""}]
    set move [expr {[dict exists $state move] ? [dict get $state move] : ""}]
    set out [dict create review disabled movecomment disabled cancel disabled reason ""]
    if {$pass ne ""} {
        dict set out cancel normal
        dict set out reason {pass running}
        return $out
    }
    if {![string is integer -strict $game] || $game < 1} {
        dict set out reason {no game}
        return $out
    }
    if {$engine eq ""} {
        dict set out reason {no engine}
        return $out
    }
    dict set out review normal
    # No move under the cursor is nothing for Move Comment to label.
    # It is not a reason against the review, which covers the whole line.
    if {$move ne ""} { dict set out movecomment normal }
    return $out
}

# The settings the dialog owns, in the order it applies them.
#
# Threads and Hash are deliberately absent: they are properties of the engine
# preset (#382), set from the window's own controls, and a review dialog that
# also wrote them would be a second place to get them wrong. The order matters
# because ::review::setValue has cross-field rules - mpv caps var_lines - so a
# single edit that lowers both must apply mpv first.
variable ::reviewui::SETTING_KEYS {mpv depth movetime var_lines var_cp move_comment_wait diagram}

# The review setting a dialog row edits, and the label it shows. `Lines` and
# `Depth` are the keys the engine window already uses for the same two numbers.
variable ::reviewui::SETTING_LABELS {
    mpv               Lines
    depth             Depth
    movetime          ReviewMovetime
    var_lines         ReviewVarLines
    var_cp            ReviewVarCp
    move_comment_wait ReviewMoveWait
    diagram           Diagram
}

proc ::reviewui::settingKeys {} {
    variable ::reviewui::SETTING_KEYS
    return $::reviewui::SETTING_KEYS
}

proc ::reviewui::settingLabel {key} {
    variable ::reviewui::SETTING_LABELS
    if {![dict exists $::reviewui::SETTING_LABELS $key]} { return "" }
    return [::reviewui::tr [dict get $::reviewui::SETTING_LABELS $key]]
}

# What the dialog opens with.
proc ::reviewui::settings {} {
    set out [dict create]
    foreach key [::reviewui::settingKeys] {
        dict set out $key [::review::get $key]
    }
    return $out
}

# Store what the dialog holds. Every field is offered to ::review::setValue,
# which owns the rules; a refusal is collected and the next field is still
# tried, because the user pressed OK once and losing the four good fields to
# the one bad one is worse than showing them the refusal. Returns the reasons,
# in dialog order; "" means the whole edit landed.
proc ::reviewui::applySettings {values} {
    set why {}
    foreach key [::reviewui::settingKeys] {
        if {![dict exists $values $key]} { continue }
        set reason [::review::setValue $key [dict get $values $key]]
        if {$reason ne ""} { lappend why $reason }
    }
    return $why
}

# Threads and Hash as the preset advertises them, for the dialog's read-only
# line: "Threads 8, Hash 256 MB". Empty when the engine advertises neither,
# which is an engines.dat written before ::enginelimits existed.
proc ::reviewui::presetLimits {enginecfg} {
    # ::review::effective, not the preset: the pass runs on a second engine and is
    # bounded (::review::MAX_PASS_THREADS/HASH), so the dialog should not promise
    # the preset's full reservation. "From engine preset" stays true - these are
    # its numbers, reduced to what a pass may take.
    set d [::review::effective $enginecfg]
    set parts {}
    if {[dict get $d threads] ne ""} { lappend parts "Threads [dict get $d threads]" }
    if {[dict get $d hash] ne ""} { lappend parts "Hash [dict get $d hash] MB" }
    return [join $parts ", "]
}

# The read-only line itself. "" when the preset carries nothing to show, so the
# dialog can leave the row out rather than showing an empty claim.
proc ::reviewui::presetNote {enginecfg} {
    set limits [::reviewui::presetLimits $enginecfg]
    if {$limits eq ""} { return "" }
    return [format [::reviewui::tr ReviewFromPreset] $limits]
}

# The time cap a row with no cap of its own runs on: the engine preset's
# Limits.movetime, or "" when neither side sets one. "" also when the review has
# a cap of its own, because then the number in the box is the answer and a note
# beside it would be noise.
#
# The preset's OWN limit, never ::review::effective's answer: `effective` keeps a
# review cap that is still SAVED, and a box reading 0 is the edit that clears it.
# With 200 ms saved beside a preset's 900 the note read "200 ms (from engine
# preset)" - the wrong number and the wrong side - while applying the edit ran at
# 900. `::enginelimits::forName` is the same lookup the pass makes, so the note
# still reads what the pass would run under, just without the saved cap in it.
proc ::reviewui::movetimeFromPreset {value enginecfg} {
    if {[string is integer -strict $value] && $value > 0} { return "" }
    if {[llength $enginecfg] < 1} { return "" }
    set preset [dict create depth "" movetime ""]
    if {[info commands ::enginelimits::forName] ne ""} {
        set preset [::enginelimits::forName [lindex $enginecfg 0]]
    }
    set lim [::review::passLimits [dict create depth 0 movetime 0] $preset]
    return [dict get $lim movetime]
}

# The note itself, beside the time box: "900 ms (from engine preset)". "" when
# there is nothing to say.
proc ::reviewui::movetimeNote {value enginecfg} {
    set ms [::reviewui::movetimeFromPreset $value $enginecfg]
    if {$ms eq ""} { return "" }
    return [format [::reviewui::tr ReviewFromPreset] "$ms ms"]
}

# The translation table, or the key itself when there is none: a tclsh test has
# no language files, and a missing translation must not be an error on a button.
proc ::reviewui::tr {key} {
    # Fully qualified: an unqualified `info commands tr` finds this very proc,
    # because it runs inside ::reviewui.
    if {[llength [info commands ::tr]] == 0} { return $key }
    return [::tr $key]
}

# A user-visible string this module owns: a button's text, a tooltip, a title.
proc ::reviewui::label {key} {
    return [::reviewui::tr $key]
}

# What Move Comment does from the current analysis depth.
#
#   {action now}          write with what the engine has
#   {action wait depth N} wait until the analysis reaches N
#
# ::review::moveCommentPlan owns the rule (it is ::review's setting and its
# depth); this only turns "now, or the depth to wait for" into a dict the window
# can branch on without re-parsing a number that is either "now" or a depth.
proc ::reviewui::moveCommentStatus {depth_now {target ""}} {
    set plan [::review::moveCommentPlan $depth_now $target]
    if {[string equal $plan now]} {
        return [dict create action now depth ""]
    }
    return [dict create action wait depth $plan]
}

# The status line while a pass runs. "" when there is nothing to report, so the
# window can clear the label rather than show "position 0 of 0".
proc ::reviewui::progressText {done total} {
    if {![string is integer -strict $total] || $total < 1} { return "" }
    return [format [::reviewui::tr ReviewProgress] $done $total]
}

# The status line the driver's state maps to, so the window holds no state of
# its own about a pass: it asks ::reviewdriver::status and this says what to show.
#
# "" when there is nothing to say - idle before a press, the write phase (the
# search is over and nothing is being counted), a run that finished (the labels
# in the game are the report) and a cancelled one (it wrote nothing). A run that
# did not finish, or finished with moves the game refused, says why in the
# driver's or the board's own words.
proc ::reviewui::statusText {st} {
    set state idle
    catch { set state [dict get $st state] }
    switch -- $state {
        searching {
            set done 0
            catch { set done [dict get $st searched] }
            set total 0
            catch { set total [dict get $st total] }
            return [::reviewui::progressText $done $total]
        }
        failed {
            set reason ""
            catch { set reason [dict get $st reason] }
            if {$reason eq ""} {
                # A pass that lost its engine says so in its own words; one whose
                # writes the game refused has the refusal instead.
                catch { set reason [lindex [dict get $st errors] 0] }
            }
            return [::reviewui::failedText $reason]
        }
        done {
            set failed 0
            catch { set failed [dict get $st failed] }
            if {$failed > 0} {
                set reason ""
                catch { set reason [lindex [dict get $st errors] 0] }
                return [::reviewui::failedText $reason]
            }
            return ""
        }
    }
    return ""
}

# And the status line when it ends badly: the reason is the driver's or the
# board's own words, and swallowing it leaves the user with a pass that did
# nothing and said nothing.
proc ::reviewui::failedText {reason} {
    if {$reason eq ""} { return "" }
    return [format [::reviewui::tr ReviewFailed] $reason]
}

# The depth a one-move comment searches at, and whether anything has to wait.
#
# `depth_now` is the window's analysis depth for the position BEFORE the
# commented move: the pass searches that position first, so its depth is what
# says whether the comment can be written from the analysis already on screen.
#
# With move_comment_wait on (the default) the comment has to be the one a review
# would have written, so a shallow analysis is not good enough and the pass
# searches at the review's depth. With it off the window's own analysis is the
# answer whenever it has a number at all: that is what "write whatever the engine
# has now" means, and re-searching it at 18 would be doing the work twice.
proc ::reviewui::moveCommentDepth {depth_now {target ""}} {
    if {$target eq ""} { set target [::review::get depth] }
    set st [::reviewui::moveCommentStatus $depth_now $target]
    if {[dict get $st action] eq "now"} {
        set depth $target
        # 0 is the window's "queued, nothing back yet" marker, not a depth: a
        # `go depth 0` searches nothing at all.
        if {[string is integer -strict $depth_now] && $depth_now > 0} {
            set depth $depth_now
        }
        return [dict create depth $depth wait 0]
    }
    return [dict create depth $target wait 1]
}

# The move Move Comment judges: the one the reader is on, which is the move that
# produced the current position (ply `here`, where `here` is sc_pos location),
# not the move played from it. "" when there is no such move: the start of the
# line, a null move (a `position ...` header), or a ply the main line does not
# have.
#
# The pass searches `here - 1` and `here`, the positions before and after the
# move; the depth already reached is the window's entry for `here - 1`.
proc ::reviewui::moveCommentPly {map here} {
    if {![string is integer -strict $here] || $here < 1} { return "" }
    if {[::review::playedMove $map $here] eq ""} { return "" }
    return $here
}

# The bounds a dialog spin box offers. They agree with ::review::setValue, which
# is still the authority: a value the box should never have offered is refused
# and reported rather than silently clamped. var_cp has no upper bound in the
# setter; 500 is where a variation margin stops being a filter and starts being
# "write no variations at all".
variable ::reviewui::SETTING_RANGES {
    mpv               {1 5}
    depth             {6 60}
    movetime          {0 3600000}
    var_lines         {0 5}
    var_cp            {0 500}
    move_comment_wait {0 1}
    diagram           {0 1}
}

proc ::reviewui::settingRange {key {mpv ""}} {
    variable ::reviewui::SETTING_RANGES
    if {![dict exists $::reviewui::SETTING_RANGES $key]} { return "" }
    set range [dict get $::reviewui::SETTING_RANGES $key]
    # var_lines is capped by mpv, so its box has to follow mpv or it offers a
    # number the setter refuses. mpv 1 means no alternatives at all, and then the
    # only value the setter takes is 0.
    if {$key eq "var_lines"} {
        if {$mpv eq "" || ![string is integer -strict $mpv]} {
            set mpv [::review::get mpv]
        }
        set hi [expr {$mpv < 2 ? 0 : $mpv}]
        return [list [lindex $range 0] $hi]
    }
    return $range
}

# The thread and hash values the dialog shows read-only, for a caller that wants
# them as a pair rather than as the one line presetNote builds.
proc ::reviewui::presetValues {enginecfg} {
    return [::review::engineDefaults $enginecfg]
}
