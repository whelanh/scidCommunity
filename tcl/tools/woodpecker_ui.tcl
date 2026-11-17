### woodpecker_ui.tcl: Woodpecker trainer - windows and the training session.
### SPDX-License-Identifier: GPL-2.0-or-later
###
### Play > Woodpecker Method. One window with three pages: the sets, the
### session panel and the session summary; a dialog to create a set, one to
### evaluate it, and a statistics window. Plan: docs/woodpecker-plan.md.
###
### A session takes the whole main window (the "focus layout"): the user's
### layout is saved, every window is closed but the board and this panel, and
### the layout comes back when the trainee leaves the session. Inside the
### session Repertoire Recall's rules apply: no pop-up inside an exercise,
### feedback that never blocks, the reply without a click, the important things
### (result, attempts, clock) readable from the corner of the eye.

namespace eval ::woodpecker::ui {
    variable w .woodpeckerWin
    variable txt
    array set txt {}
    variable run
    array set run {on 0}
    variable focus
    array set focus {active 0 relayout 0}
    variable keysBound 0
    variable newCfg
    array set newCfg {}
    variable progress
    array set progress {}
    # The panel's place in the focus layout: share of the width for the board.
    variable BOARD_SHARE 0.58
}

if {[llength [info commands ::options.store]]} {
    ::options.store ::woodpecker::ui::engine ""
    ::options.store ::woodpecker::ui::lastCount 300
    ::options.store ::woodpecker::ui::lastDays 28
    ::options.store ::woodpecker::ui::lastPreset standard
    ::options.store ::woodpecker::ui::lastRating 1500
    ::options.store ::woodpecker::dataDir ""
    ::options.store ::woodpecker::usedDir ""
}
foreach {_v _d} {engine "" lastCount 300 lastDays 28 lastPreset standard lastRating 1500} {
    if {![info exists ::woodpecker::ui::$_v]} { set ::woodpecker::ui::$_v $_d }
}
unset -nocomplain _v _d

proc ::woodpecker::ui::T {tag args} {
    if {[llength $args]} { return [format [tr $tag] {*}$args] }
    return [tr $tag]
}

proc ::woodpecker::ui::pct {x} { return [format "%.0f%%" $x] }

proc ::woodpecker::ui::num {x} {
    set r [format "%.1f" $x]
    if {[string match *.0 $r]} { set r [string range $r 0 end-2] }
    return $r
}

################################################################################
# Look: colours that read on light and dark themes, and the fonts

proc ::woodpecker::ui::dark {} {
    return [expr {[info exists ::darkThemes] && [ttk::style theme use] in $::darkThemes}]
}

proc ::woodpecker::ui::color {name} {
    set d [dark]
    switch -- $name {
        bg     { return [ttk::style lookup . -background {} [expr {$d ? "#2b2b2b" : "#efefef"}]] }
        fg     { return [ttk::style lookup . -foreground {} [expr {$d ? "#e6e6e6" : "#202020"}]] }
        field  { return [ttk::style lookup TEntry -fieldbackground {} [expr {$d ? "#1f1f1f" : "#ffffff"}]] }
        muted  { return [expr {$d ? "#a8a8a8" : "#6f6f6f"}] }
        track  { return [expr {$d ? "#454545" : "#dedede"}] }
        accent { return [expr {$d ? "#5aa2e8" : "#2f7bd0"}] }
        good   { return [expr {$d ? "#4cc24c" : "#2e9d2e"}] }
        bad    { return [expr {$d ? "#ef5350" : "#d32f2f"}] }
        warn   { return [expr {$d ? "#f0b040" : "#c98200"}] }
        extra  { return "#f5a623" }
        bang   { return [expr {$d ? "#4cc24c" : "#1e8a1e"}] }
        bang2  { return [expr {$d ? "#4dd0c8" : "#00897b"}] }
        link   { return [expr {$d ? "#6db3f2" : "#1a6ec4"}] }
    }
    return black
}

proc ::woodpecker::ui::fonts {} {
    set base [font actual font_Regular]
    foreach {name size weight} {woodpeckerClock 22 bold woodpeckerHead 18 bold woodpeckerTitle 13 bold
            woodpeckerText 11 normal woodpeckerMove 12 bold woodpeckerSmall 9 normal woodpeckerBig 26 bold} {
        catch { font create $name {*}$base -size $size -weight $weight }
    }
}

# A rounded rectangle on a canvas.
proc ::woodpecker::ui::roundRect {c x0 y0 x1 y1 r args} {
    if {$x1 - $x0 < 2 * $r} { set r [expr {max(0, ($x1 - $x0) / 2.0)}] }
    set pts [list [expr {$x0 + $r}] $y0 [expr {$x1 - $r}] $y0 $x1 $y0 $x1 [expr {$y0 + $r}] \
        $x1 [expr {$y1 - $r}] $x1 $y1 [expr {$x1 - $r}] $y1 [expr {$x0 + $r}] $y1 $x0 $y1 \
        $x0 [expr {$y1 - $r}] $x0 [expr {$y0 + $r}] $x0 $y0]
    return [$c create polygon $pts -smooth 1 {*}$args]
}

proc ::woodpecker::ui::openLink {url} {
    if {$::tcl_platform(platform) eq "windows"} {
        catch { exec rundll32 url.dll,FileProtocolHandler $url & }
    } else {
        catch { openURL $url }
    }
}

################################################################################
# The window

proc ::woodpecker::ui::open {} {
    variable w
    if {[::createToplevel $w] eq "already_exists"} { return }
    build
    showPage home
    refresh
    after idle ::woodpecker::ui::dataDirCheck
}

################################################################################
# The data folder (Options > Resources)

# The browse button of the Resources dialog.
proc ::woodpecker::ui::chooseDataDir {widget} {
    set init [expr {$::woodpecker::dataDir ne "" ? $::woodpecker::dataDir : $::scidUserDir}]
    set dir [tk_chooseDirectory -initialdir $init -parent [winfo toplevel $widget] -mustexist 1 \
        -title [tr WoodpeckerDataDir]]
    if {$dir eq ""} { return }
    $widget delete 0 end
    $widget insert end $dir
    set ::woodpecker::dataDir $dir
    dataDirCheck
}

# The Resources dialog's setter: called while the path is typed, so the
# question about the existing sets waits for the typing to stop.
proc ::woodpecker::ui::setDataDir {dir} {
    set ::woodpecker::dataDir $dir
    after cancel ::woodpecker::ui::dataDirCheck
    after 1500 ::woodpecker::ui::dataDirCheck
}

# The folder changed since the sets were last used: offer to bring them along
# (once), and show the sets of the folder now in use.
proc ::woodpecker::ui::dataDirCheck {} {
    if {[catch { ::woodpecker::set::dataRoot } new]} { refresh; return }
    set old $::woodpecker::usedDir
    set ::woodpecker::usedDir $new
    if {$old eq "" || [file normalize $old] eq [file normalize $new] || ![file isdirectory $old]} {
        refresh
        return
    }
    set oldSets [::woodpecker::set::setDirs $old]
    if {![llength $oldSets]} { refresh; return }
    set parent [expr {[winfo exists .resDialog] ? ".resDialog" : "."}]
    set newSets [::woodpecker::set::setDirs $new]
    if {[llength $newSets]} {
        tk_messageBox -icon info -parent $parent -title [tr WoodpeckerTitle] \
            -message [T WoodpeckerDataDirHasSets [llength $newSets] $new $old]
        refresh
        return
    }
    if {[tk_messageBox -icon question -type yesno -parent $parent -title [tr WoodpeckerTitle] \
            -message [T WoodpeckerDataDirMove [llength $oldSets] $old $new]] eq "yes"} {
        if {[catch { ::woodpecker::set::moveSets $old $new } res]} {
            tk_messageBox -icon error -parent $parent -message $res
        }
    }
    refresh
}

proc ::woodpecker::ui::build {} {
    variable w
    ::setTitle $w [tr WoodpeckerTitle]
    fonts
    set v ::woodpecker::ui

    # --- the sets
    set h [ttk::frame $w.home -padding 12]
    ttk::label $h.title -text [tr WoodpeckerTitle] -font woodpeckerHead
    ttk::label $h.sub -text [tr WoodpeckerTagline] -foreground [color muted]
    ttk::treeview $h.sets -columns {name ex cycle progress last} -show headings -height 7 \
        -selectmode browse -yscrollcommand [list $h.sb set]
    ttk::scrollbar $h.sb -command [list $h.sets yview]
    foreach {c tag width} {name WoodpeckerColName 200 ex WoodpeckerColExercises 80 \
            cycle WoodpeckerColCycle 60 progress WoodpeckerColProgress 110 last WoodpeckerColLast 110} {
        $h.sets heading $c -text [tr $tag]
        $h.sets column $c -width $width -stretch [expr {$c eq "name"}] -anchor [expr {$c eq "name" ? "w" : "center"}]
    }
    bind $h.sets <<TreeviewSelect>> ${v}::selected
    bind $h.sets <Double-1> ${v}::train
    ttk::label $h.info -textvariable ${v}::txt(info) -wraplength 520 -justify left -font woodpeckerText
    ttk::frame $h.b
    ttk::button $h.b.train -image tb_play -text [tr WoodpeckerTrain] -compound left -command ${v}::train
    ttk::button $h.b.new -text [tr WoodpeckerNew] -command ${v}::newDialog
    ttk::button $h.b.eval -text [tr WoodpeckerEvaluate] -command ${v}::evaluate
    ttk::button $h.b.stats -text [tr WoodpeckerStats] -command ${v}::stats
    ttk::button $h.b.del -text [tr WoodpeckerDelete] -command ${v}::deleteSet
    pack $h.b.train $h.b.new $h.b.eval $h.b.stats -side left -padx {0 6}
    pack $h.b.del -side right
    grid $h.title -row 0 -column 0 -columnspan 2 -sticky w
    grid $h.sub -row 1 -column 0 -columnspan 2 -sticky w -pady {0 8}
    grid $h.sets -row 2 -column 0 -sticky nsew
    grid $h.sb -row 2 -column 1 -sticky ns
    grid $h.info -row 3 -column 0 -columnspan 2 -sticky w -pady 10
    grid $h.b -row 4 -column 0 -columnspan 2 -sticky ew
    grid rowconfigure $h 2 -weight 1
    grid columnconfigure $h 0 -weight 1

    buildSession
    buildSummary

    ::createToplevelFinalize $w
    bind $w <Destroy> "+if {{%W} eq {$w}} { ${v}::closed }"
}

# The session panel. The order of packing is the order of importance: the
# buttons and the status line from the bottom, then from the top the result
# and the clock, the exercise, the card with the solution, the progress bars,
# and last the details a small pane may hide.
proc ::woodpecker::ui::buildSession {} {
    variable w
    set v ::woodpecker::ui
    set p [ttk::frame $w.sess -padding 12]
    ttk::frame $p.head
    label $p.head.verdict -textvariable ${v}::txt(verdict) -font woodpeckerClock -width 2 \
        -background [color bg] -foreground white -padx 6
    ttk::label $p.head.clock -textvariable ${v}::txt(clock) -font woodpeckerClock
    canvas $p.head.att -width 64 -height 28 -highlightthickness 0 -background [color bg]
    pack $p.head.verdict -side left
    pack $p.head.clock -side left -padx 14
    pack $p.head.att -side right
    ttk::label $p.title -textvariable ${v}::txt(title) -font woodpeckerTitle
    ttk::frame $p.sub
    canvas $p.sub.side -width 12 -height 12 -highlightthickness 0 -background [color bg]
    ttk::label $p.sub.text -textvariable ${v}::txt(sub) -foreground [color muted]
    pack $p.sub.side -side left -padx {0 6}
    pack $p.sub.text -side left
    # The card: the result, the points and the solution. While the exercise is
    # on, it says only whose move it is - the solution stays hidden.
    frame $p.card -background [color field] -highlightthickness 1 -highlightbackground [color track]
    frame $p.card.stripe -width 5 -background [color track]
    text $p.card.t -height 4 -width 40 -wrap word -font woodpeckerText -relief flat -borderwidth 0 \
        -padx 10 -pady 8 -cursor arrow -state disabled -takefocus 0 \
        -background [color field] -foreground [color fg]
    pack $p.card.stripe -side left -fill y
    pack $p.card.t -side left -fill both -expand 1
    set t $p.card.t
    $t tag configure head -font woodpeckerTitle
    $t tag configure good -foreground [color good]
    $t tag configure bad -foreground [color bad]
    $t tag configure warn -foreground [color warn]
    $t tag configure pts -font woodpeckerMove
    $t tag configure move -font woodpeckerMove
    $t tag configure bang -foreground [color bang] -font woodpeckerMove
    $t tag configure bang2 -foreground [color bang2] -font woodpeckerMove
    $t tag configure dim -foreground [color muted]
    $t tag configure cur -background [color track]
    $t tag configure link -underline 0
    ttk::frame $p.bars
    foreach {k} {today cycle} {
        ttk::label $p.bars.l$k -textvariable ${v}::txt(l$k) -foreground [color muted]
        canvas $p.bars.c$k -height 10 -highlightthickness 0 -background [color bg]
        ttk::label $p.bars.n$k -textvariable ${v}::txt(n$k) -font woodpeckerMove
    }
    grid $p.bars.ltoday $p.bars.ctoday $p.bars.ntoday -sticky ew -pady 3
    grid $p.bars.lcycle $p.bars.ccycle $p.bars.ncycle -sticky ew -pady 3
    grid configure $p.bars.ltoday $p.bars.lcycle -sticky w -padx {0 10}
    grid configure $p.bars.ntoday $p.bars.ncycle -sticky e -padx {10 0}
    grid columnconfigure $p.bars 1 -weight 1
    bind $p.bars.ctoday <Configure> ${v}::drawBars
    ttk::label $p.meta -textvariable ${v}::txt(meta) -foreground [color muted]
    # One tile per exercise of this session: green, amber or red.
    canvas $p.strip -height 18 -highlightthickness 0 -background [color bg]
    bind $p.strip <Configure> ${v}::drawStrip
    ttk::label $p.notice -textvariable ${v}::txt(notice) -wraplength 360 -justify left \
        -foreground [color warn] -font woodpeckerSmall
    ttk::frame $p.line
    ttk::label $p.line.status -textvariable ${v}::txt(status) -wraplength 260 -justify left
    ttk::button $p.line.cont -text [tr WoodpeckerContinue] -command ${v}::keyContinue -default active
    pack $p.line.status -side left
    ttk::frame $p.b
    ttk::button $p.b.pause -text [tr WoodpeckerPause] -command ${v}::pause
    ttk::button $p.b.end -text [tr WoodpeckerEnd] -command ${v}::finish
    pack $p.b.pause -side left
    pack $p.b.end -side right
    pack $p.b -side bottom -fill x -pady {8 0}
    pack $p.line -side bottom -fill x -pady {6 0}
    pack $p.head -side top -fill x
    pack $p.title -side top -anchor w -pady {10 0}
    pack $p.sub -side top -anchor w -pady {2 8}
    pack $p.card -side top -fill x
    pack $p.bars -side top -fill x -pady {12 4}
    pack $p.meta -side top -anchor w
    pack $p.strip -side top -fill x -pady {10 0}
    pack $p.notice -side top -anchor w -pady {6 0}
}

proc ::woodpecker::ui::buildSummary {} {
    variable w
    set v ::woodpecker::ui
    set s [ttk::frame $w.sum -padding 16]
    ttk::label $s.title -textvariable ${v}::txt(sumTitle) -font woodpeckerHead
    ttk::label $s.badge -textvariable ${v}::txt(sumBadge) -foreground [color good] -font woodpeckerTitle
    ttk::label $s.points -textvariable ${v}::txt(sumPoints) -font woodpeckerBig
    ttk::label $s.pl -textvariable ${v}::txt(sumPointsLabel) -foreground [color muted]
    canvas $s.strip -height 18 -highlightthickness 0 -background [color bg]
    bind $s.strip <Configure> ${v}::drawStrip
    ttk::frame $s.grid
    ttk::label $s.notes -textvariable ${v}::txt(sumNotes) -wraplength 380 -justify left
    ttk::frame $s.b
    ttk::button $s.b.exit -text [tr WoodpeckerExit] -command ${v}::exitSession -default active
    ttk::button $s.b.more -text [tr WoodpeckerMore] -command ${v}::more
    ttk::button $s.b.stats -text [tr WoodpeckerStats] -command ${v}::stats
    pack $s.b.exit -side right
    pack $s.b.more $s.b.stats -side left -padx {0 6}
    pack $s.b -side bottom -fill x -pady {12 0}
    pack $s.title -side top -anchor w
    pack $s.badge -side top -anchor w
    pack $s.points -side top -anchor w -pady {10 0}
    pack $s.pl -side top -anchor w
    pack $s.strip -side top -fill x -pady {10 0}
    pack $s.grid -side top -anchor w -pady 10
    pack $s.notes -side top -anchor w
}

proc ::woodpecker::ui::showPage {page} {
    variable w
    foreach p {home sess sum} { catch { pack forget $w.$p } }
    pack $w.$page -fill both -expand 1
}

# The window is gone. During a relayout that is the layout's doing; otherwise
# the trainee closed it: the session ends and the layout comes back.
proc ::woodpecker::ui::closed {} {
    variable run
    variable focus
    if {$focus(relayout)} { return }
    if {$run(on)} { stop }
    # The panel was closed on purpose: back to Scid as it was, without it.
    if {$focus(active)} { after idle [list ::woodpecker::ui::leaveFocus 0] }
}

################################################################################
# The focus layout: board and panel, nothing else, for the whole session

# Scid saves the layout as "auto" when it writes its options, on exit too. A
# session must not become the layout the next start opens: while the focus
# layout is on, the saved "auto" is the trainee's own layout.
proc ::woodpecker::ui::layoutSaved {cmd code result op} {
    variable focus
    if {!$focus(active) || [lindex $cmd 1] ne "auto"} { return }
    if {[info exists ::docking::layout_list(woodpecker_user)]} {
        set ::docking::layout_list(auto) $::docking::layout_list(woodpecker_user)
    }
}
if {[llength [info commands ::docking::layout_save]]} {
    trace add execution ::docking::layout_save leave ::woodpecker::ui::layoutSaved
}

proc ::woodpecker::ui::enterFocus {} {
    variable focus
    variable w
    variable BOARD_SHARE
    if {$focus(active)} { return 1 }
    if {![llength [info commands ::docking::layout_restore]]} { return 0 }
    ::docking::layout_save woodpecker_user
    set geom [wm geometry .]
    set zoomed [expr {[wm state .] eq "zoomed"}]
    if {[scan $geom "%dx%d+%d+%d" gw gh gx gy] == 4 && !$zoomed} {
        # The panel needs room beside the board.
        set gw [expr {max($gw, min([winfo screenwidth .] - 40, 1180))}]
        set gh [expr {max($gh, min([winfo screenheight .] - 80, 720))}]
        set geom "${gw}x${gh}+$gx+$gy"
    }
    set g [list MainWindowGeometry $geom]
    if {$zoomed} { lappend g zoomed }
    set ::docking::layout_list(woodpecker_focus) [list $g {{.pw horizontal {}} {TNotebook .nb .main}}]
    set focus(relayout) 1
    set err [catch {
        ::docking::layout_restore woodpecker_focus
        set nb .pw.woodpeckerTab
        ::docking::create_notebook_ $nb
        ::docking::insert_notebook_ .pw end $nb
        set ::docking::layout_dest_notebook $nb
        ::createToplevel $w
        unset -nocomplain ::docking::layout_dest_notebook
        build
        update idletasks
        catch { .pw sashpos 0 [expr {int([winfo width .pw] * $BOARD_SHARE)}] }
    } msg]
    unset -nocomplain ::docking::layout_dest_notebook
    set focus(relayout) 0
    unset -nocomplain ::docking::layout_list(woodpecker_focus)
    if {$err} {
        puts stderr "Woodpecker: focus layout failed: $msg"
        # Put the trainee's layout back; the session runs in it.
        set focus(relayout) 1
        catch { ::docking::layout_restore woodpecker_user }
        set focus(relayout) 0
        unset -nocomplain ::docking::layout_list(woodpecker_user)
        if {![winfo exists $w]} { open }
        return 0
    }
    set focus(active) 1
    return 1
}

# Back to the trainee's layout; `reopen` puts this window back on its list of
# sets (not when the trainee closed it to leave).
proc ::woodpecker::ui::leaveFocus {{reopen 1}} {
    variable focus
    variable w
    if {!$focus(active)} { return }
    set focus(relayout) 1
    catch { ::docking::layout_restore woodpecker_user }
    set focus(relayout) 0
    set focus(active) 0
    unset -nocomplain ::docking::layout_list(woodpecker_user)
    if {!$reopen} { return }
    open
    showPage home
    refresh
}

proc ::woodpecker::ui::exitSession {} {
    variable run
    if {$run(on)} { finish }
    leaveFocus
    if {![winfo exists .woodpeckerWin.home]} { open }
    showPage home
    refresh
}

################################################################################
# The set list

proc ::woodpecker::ui::refresh {} {
    variable w
    if {![winfo exists $w.home.sets]} { return }
    set t $w.home.sets
    set keep [$t selection]
    $t delete [$t children {}]
    set today [::woodpecker::today [clock seconds]]
    if {[catch { ::woodpecker::set::all } sets]} {
        set ::woodpecker::ui::txt(info) [T WoodpeckerNoDataDir $::woodpecker::dataDir]
        return
    }
    foreach s $sets {
        lassign $s dir meta
        set exs [::woodpecker::readExercises $dir]
        set n [dict size $exs]
        lassign [::woodpecker::readLog $dir] xs ss
        set pr [::woodpecker::progress $xs $n $today]
        set last [expr {[llength $xs] ? [::woodpecker::today [dict get [lindex $xs end] ts]] : "-"}]
        $t insert {} end -id $dir -values [list [dict get $meta name] $n [dict get $pr cycle] \
            "[dict get $pr done]/$n" $last]
    }
    if {[llength $keep] && [$t exists [lindex $keep 0]]} {
        $t selection set [lindex $keep 0]
    } elseif {[llength [$t children {}]]} {
        $t selection set [lindex [$t children {}] 0]
    }
    selected
}

proc ::woodpecker::ui::current {} {
    variable w
    if {![winfo exists $w.home.sets]} { return "" }
    return [lindex [$w.home.sets selection] 0]
}

proc ::woodpecker::ui::selected {} {
    variable txt
    set dir [current]
    if {$dir eq ""} { set txt(info) [tr WoodpeckerNoSets]; return }
    set info [dayPlan $dir]
    set lines [dict get $info lines]
    set st [::woodpecker::set::markStatus $dir]
    set marked [expr {[dict get $st annotated] + [dict get $st reviewed]}]
    if {$marked < [dict get $st total]} {
        lappend lines [T WoodpeckerUnrated [expr {[dict get $st total] - $marked}] [dict get $st total]]
    }
    set txt(info) [join $lines "\n"]
}

# Today's plan for a set: {cycle next n quota doneToday start deadline status
# rest lines}. `rest` is the first day of the next cycle when the cycle is over.
proc ::woodpecker::ui::dayPlan {dir {now ""}} {
    if {$now eq ""} { set now [clock seconds] }
    set today [::woodpecker::today $now]
    set meta [::woodpecker::readMeta $dir]
    set n [dict size [::woodpecker::readExercises $dir]]
    lassign [::woodpecker::readLog $dir] xs ss
    set pr [::woodpecker::progress $xs $n $today]
    set days1 [expr {[dict exists $meta days1] ? [dict get $meta days1] : 28}]
    set restDays [expr {[dict exists $meta restDays] ? [dict get $meta restDays] : 1}]
    set cycle [dict get $pr cycle]
    set lines {}
    set rest ""
    if {[dict get $pr complete]} {
        set rest [::woodpecker::nextCycleDay [dict get $pr end] $restDays]
        set cycle [expr {$cycle + 1}]
        set pr [dict create cycle $cycle next 1 done 0 doneBefore 0 complete 0 start "" end ""]
        lappend lines [T WoodpeckerCycleOver [expr {$cycle - 1}] $rest]
    }
    set start [expr {[dict get $pr start] ne "" ? [dict get $pr start] : $today}]
    if {$rest ne "" && $today < $rest} { set start $rest }
    set days [::woodpecker::cycleDays $cycle $days1]
    set plan [::woodpecker::plan $n $days $start [dict get $pr doneBefore] $today]
    set doneToday [expr {[dict get $pr done] - [dict get $pr doneBefore]}]
    lappend lines [T WoodpeckerCycleLine $cycle [dict get $pr done] $n $days [dict get $plan deadline]]
    lappend lines [T WoodpeckerQuotaLine $doneToday [dict get $plan quota]]
    switch -- [dict get $plan status] {
        quota_raised { lappend lines [T WoodpeckerQuotaRaised [dict get $plan quota] [dict get $plan base]] }
        deadline_moved { lappend lines [T WoodpeckerDeadlineMoved [dict get $plan slip] [dict get $plan deadline] [dict get $plan quota]] }
        over_stretch { lappend lines [T WoodpeckerOverStretch [dict get $plan deadline] [dict get $plan quota]] }
    }
    return [dict merge $plan [dict create cycle $cycle next [dict get $pr next] n $n \
        doneToday $doneToday start $start rest $rest lines $lines meta $meta]]
}

proc ::woodpecker::ui::deleteSet {} {
    variable run
    set dir [current]
    if {$dir eq "" || $run(on)} { return }
    set name [dict get [::woodpecker::readMeta $dir] name]
    if {[tk_messageBox -icon warning -type yesno -parent .woodpeckerWin -title [tr WoodpeckerTitle] \
            -message [T WoodpeckerDeleteAsk $name]] ne "yes"} { return }
    catch {
        set want [file normalize [::woodpecker::set::basePath $dir]]
        foreach b [sc_base list] {
            if {[file normalize [file rootname [sc_base filename $b]]] eq $want} { ::file::Close $b }
        }
    }
    file delete -force $dir
    refresh
}

################################################################################
# Creating a set

proc ::woodpecker::ui::presetLabels {} {
    return [list automatic [tr WoodpeckerPreset_automatic] standard [tr WoodpeckerPreset_standard] \
        challenge [tr WoodpeckerPreset_challenge] custom [tr WoodpeckerPreset_custom]]
}

proc ::woodpecker::ui::newDialog {} {
    variable newCfg
    set d .woodpeckerNew
    if {[winfo exists $d]} { raise $d; return }
    if {[catch { ::woodpecker::set::rootDir } err]} {
        tk_messageBox -icon error -parent .woodpeckerWin -message [T WoodpeckerNoDataDir $::woodpecker::dataDir]
        return
    }
    win::createDialog $d
    ::setTitle $d [tr WoodpeckerNewTitle]
    fonts
    set v ::woodpecker::ui
    set preset $::woodpecker::ui::lastPreset
    if {$preset ni {automatic standard challenge custom}} { set preset standard }
    array set newCfg [list name "Woodpecker [clock format [clock seconds] -format %Y-%m-%d]" \
        source lichess count $::woodpecker::ui::lastCount color both theme [tr WoodpeckerThemeMix] \
        file "" days1 $::woodpecker::ui::lastDays restDays 1 preset $preset \
        presetLabel [dict get [presetLabels] $preset] \
        easiest 0 easier 25 normal 60 harder 15 hardest 0 \
        token [::woodpecker::set::tokenRead] tokenState "" tokenUser "" tokenRating "" \
        rating $::woodpecker::ui::lastRating]
    set f [ttk::frame $d.f -padding 4]
    pack $f -fill both -expand 1
    ttk::label $f.lname -text [tr WoodpeckerName]
    ttk::entry $f.name -textvariable ${v}::newCfg(name) -width 36
    ttk::radiobutton $f.rl -text [tr WoodpeckerFromLichess] -variable ${v}::newCfg(source) -value lichess
    set l [ttk::frame $f.lich -padding {20 2 0 0}]
    # The token first: without it the set is hardly usable.
    ttk::label $l.ltoken -text [tr WoodpeckerToken]
    ttk::frame $l.tok
    ttk::entry $l.tok.e -textvariable ${v}::newCfg(token) -show * -width 28
    ttk::button $l.tok.b -text [tr WoodpeckerTokenSave] -command ${v}::tokenSave
    pack $l.tok.e -side left
    pack $l.tok.b -side left -padx 4
    ttk::label $l.toklink -text [tr WoodpeckerTokenCreate] -foreground [color link] -cursor hand2
    bind $l.toklink <ButtonRelease-1> [list ${v}::openLink [::woodpecker::set::tokenCreateUrl]]
    ttk::label $l.tokstate -textvariable ${v}::newCfg(tokenText) -wraplength 400 -justify left
    # Without a token the trainee's rating stands in for Lichess's own.
    ttk::label $l.lrating -text [tr WoodpeckerRatingAsk]
    ttk::spinbox $l.rating -from 400 -to 3200 -increment 50 -width 6 -textvariable ${v}::newCfg(rating) \
        -command ${v}::presetChosen
    bind $l.rating <KeyRelease> ${v}::presetChosen
    ttk::label $l.lcount -text [tr WoodpeckerCount]
    ttk::spinbox $l.count -from 20 -to 2000 -increment 50 -width 6 -textvariable ${v}::newCfg(count)
    ttk::label $l.ldiff -text [tr WoodpeckerDifficulty]
    ttk::combobox $l.preset -state readonly -width 30 -values [dict values [presetLabels]] \
        -textvariable ${v}::newCfg(presetLabel)
    bind $l.preset <<ComboboxSelected>> ${v}::presetChosen
    ttk::label $l.presethelp -textvariable ${v}::newCfg(presetHelp) -wraplength 400 -justify left \
        -foreground [color muted]
    ttk::frame $l.diff
    set col 0
    foreach lv $::woodpecker::set::LEVELS {
        ttk::label $l.diff.l$lv -text [tr WoodpeckerLevel_$lv]
        ttk::spinbox $l.diff.s$lv -from 0 -to 100 -increment 5 -width 4 -textvariable ${v}::newCfg($lv)
        grid $l.diff.l$lv -row 0 -column $col -padx 3
        grid $l.diff.s$lv -row 1 -column $col -padx 3
        incr col
    }
    ttk::label $l.ltheme -text [tr WoodpeckerTheme]
    set themes [list [tr WoodpeckerThemeMix]]
    if {[info exists ::lichess_puzzles::themeNames]} { lappend themes {*}$::lichess_puzzles::themeNames }
    ttk::combobox $l.theme -state readonly -width 30 -values $themes -textvariable ${v}::newCfg(theme)
    ttk::label $l.lcolor -text [tr WoodpeckerColor]
    ttk::frame $l.color
    foreach c {both white black} {
        ttk::radiobutton $l.color.$c -text [tr WoodpeckerColor_$c] -variable ${v}::newCfg(color) -value $c
        pack $l.color.$c -side left -padx {0 8}
    }
    grid $l.ltoken $l.tok -sticky w -pady 2
    grid x $l.toklink -sticky w
    grid x $l.tokstate -sticky w -pady {0 6}
    grid $l.lrating $l.rating -sticky w -pady {0 6}
    grid configure $l.lrating -padx {0 10}
    grid $l.lcount $l.count -sticky w -pady 2
    grid $l.ldiff $l.preset -sticky w -pady 2
    grid x $l.presethelp -sticky w
    grid x $l.diff -sticky w -pady 2
    grid $l.ltheme $l.theme -sticky w -pady 2
    grid $l.lcolor $l.color -sticky w -pady 2
    grid configure $l.ltoken $l.lcount $l.ldiff $l.ltheme $l.lcolor -padx {0 10}
    ttk::radiobutton $f.rf -text [tr WoodpeckerFromFile] -variable ${v}::newCfg(source) -value file
    ttk::frame $f.file -padding {20 0 0 0}
    ttk::entry $f.file.e -textvariable ${v}::newCfg(file) -width 36
    ttk::button $f.file.b -text "..." -width 3 -command ${v}::chooseFile
    pack $f.file.e -side left -fill x -expand 1
    pack $f.file.b -side left -padx 4
    ttk::label $f.filehelp -text [tr WoodpeckerFileHelp] -wraplength 440 -justify left \
        -padding {20 0 0 0} -foreground [color muted]
    ttk::separator $f.sep
    ttk::label $f.ldays -text [tr WoodpeckerDays1]
    ttk::spinbox $f.days -from 1 -to 120 -width 5 -textvariable ${v}::newCfg(days1)
    ttk::label $f.lrest -text [tr WoodpeckerRestDays]
    ttk::spinbox $f.rest -from 0 -to 14 -width 5 -textvariable ${v}::newCfg(restDays)
    ttk::label $f.dayshelp -text [tr WoodpeckerDaysHelp] -wraplength 440 -justify left -foreground [color muted]
    grid $f.lname $f.name -sticky w -pady 3
    grid $f.rl - -sticky w -pady {8 2}
    grid $f.lich - -sticky w
    grid $f.rf - -sticky w -pady {10 2}
    grid $f.file - -sticky ew
    grid $f.filehelp - -sticky w
    grid $f.sep - -sticky ew -pady 8
    grid $f.ldays $f.days -sticky w -pady 2
    grid $f.lrest $f.rest -sticky w -pady 2
    grid $f.dayshelp - -sticky w -pady 2
    ttk::frame $d.b -padding {10 6 10 10}
    ttk::button $d.b.ok -text [tr WoodpeckerCreate] -command ${v}::create -default active
    ttk::button $d.b.cancel -text $::tr(Cancel) -command [list destroy $d]
    pack $d.b.cancel $d.b.ok -side right -padx 4
    pack $d.b -fill x
    presetChosen
    tokenShow
    if {$newCfg(token) ne ""} { after idle ::woodpecker::ui::tokenVerify }
}

proc ::woodpecker::ui::presetChosen {} {
    variable newCfg
    set key custom
    dict for {k label} [presetLabels] { if {$label eq $newCfg(presetLabel)} { set key $k } }
    set newCfg(preset) $key
    set l .woodpeckerNew.f.lich
    if {$key eq "custom"} {
        grid $l.diff
        set newCfg(presetHelp) [tr WoodpeckerPresetHelp_custom]
    } else {
        grid remove $l.diff
        foreach lv $::woodpecker::set::LEVELS { set newCfg($lv) 0 }
        dict for {lv share} [::woodpecker::presetShares $key] { set newCfg($lv) $share }
        set newCfg(presetHelp) [tr WoodpeckerPresetHelp_$key]
    }
    if {$newCfg(tokenState) eq "ok" && $newCfg(tokenRating) ne ""} {
        append newCfg(presetHelp) " " [T WoodpeckerPresetRating $newCfg(tokenRating)]
    } elseif {$newCfg(tokenState) eq "ok"} {
        append newCfg(presetHelp) " " [tr WoodpeckerPresetNoRating]
    } elseif {[string is integer -strict $newCfg(rating)]} {
        append newCfg(presetHelp) " " [T WoodpeckerPresetStated $newCfg(rating)]
    }
}

# The line under the token: what the token is, or why a set needs one.
proc ::woodpecker::ui::tokenShow {} {
    variable newCfg
    set l .woodpeckerNew.f.lich
    if {![winfo exists $l.tokstate]} { return }
    switch -- $newCfg(tokenState) {
        ok {
            set txt [T WoodpeckerTokenOk $newCfg(tokenUser)]
            if {$newCfg(tokenRating) ne ""} { append txt " " [T WoodpeckerTokenRating $newCfg(tokenRating)] }
            set c good
        }
        noscope { set txt [tr WoodpeckerTokenNoScope]; set c bad }
        invalid { set txt [tr WoodpeckerTokenInvalid]; set c bad }
        error   { set txt [tr WoodpeckerTokenUnchecked]; set c warn }
        checking { set txt [tr WoodpeckerTokenChecking]; set c muted }
        default { set txt [tr WoodpeckerTokenMissing]; set c warn }
    }
    set newCfg(tokenText) $txt
    $l.tokstate configure -foreground [color $c]
    # The rating field only when Lichess will not supply the rating.
    if {$newCfg(tokenState) eq "ok"} {
        grid remove $l.lrating $l.rating
    } else {
        grid $l.lrating $l.rating
    }
}

proc ::woodpecker::ui::tokenSave {} {
    variable newCfg
    set t [string trim $newCfg(token)]
    if {$t ne "" && ![::woodpecker::set::tokenValid $t]} {
        set newCfg(tokenState) invalid
        tokenShow
        return
    }
    catch { ::woodpecker::set::tokenWrite $t }
    if {$t eq ""} {
        set newCfg(tokenState) ""
        set newCfg(tokenRating) ""
        tokenShow
        presetChosen
        return
    }
    tokenVerify
}

proc ::woodpecker::ui::tokenVerify {} {
    variable newCfg
    set t [string trim $newCfg(token)]
    if {$t eq ""} { return }
    set newCfg(tokenState) checking
    tokenShow
    set r [::woodpecker::set::tokenCheck $t]
    if {![winfo exists .woodpeckerNew]} { return }
    set newCfg(tokenState) [dict get $r status]
    set newCfg(tokenUser) [dict get $r user]
    set newCfg(tokenRating) [dict get $r rating]
    tokenShow
    presetChosen
}

proc ::woodpecker::ui::chooseFile {} {
    variable newCfg
    set f [tk_getOpenFile -parent .woodpeckerNew -filetypes {
        {{PGN} {.pgn .PGN}} {{Scid} {.si5 .si4}} {{All} *}}]
    if {$f ne ""} {
        set newCfg(file) $f
        set newCfg(source) file
        if {[string match "Woodpecker *" $newCfg(name)]} { set newCfg(name) [file rootname [file tail $f]] }
    }
}

proc ::woodpecker::ui::themeKey {label} {
    if {$label eq [tr WoodpeckerThemeMix] || ![info exists ::lichess_puzzles::themeNames]} { return mix }
    set i [lsearch -exact $::lichess_puzzles::themeNames $label]
    if {$i < 0} { return mix }
    return [lindex $::lichess_puzzles::themeKeys $i]
}

proc ::woodpecker::ui::create {} {
    variable newCfg
    set d .woodpeckerNew
    set name [string trim $newCfg(name)]
    if {$name eq ""} { return }
    foreach k {days1 restDays count} {
        if {![string is integer -strict $newCfg($k)] || $newCfg($k) < 0} {
            tk_messageBox -icon error -parent $d -message [T WoodpeckerBadNumber $k]
            return
        }
    }
    set meta [::woodpecker::set::newMeta $name $newCfg(source) [expr {max(1, $newCfg(days1))}] \
        $newCfg(restDays) [clock seconds]]
    set ::woodpecker::ui::lastDays $newCfg(days1)
    if {$newCfg(source) eq "lichess"} {
        set token [string trim $newCfg(token)]
        if {$token ne "" && $newCfg(tokenState) ne "ok"} { tokenVerify }
        switch -- $newCfg(tokenState) {
            invalid - noscope {
                tk_messageBox -icon error -parent $d -message $newCfg(tokenText)
                return
            }
        }
        set rating ""
        if {$token eq ""} {
            set rating [string trim $newCfg(rating)]
            if {![string is integer -strict $rating] || $rating < 400 || $rating > 3200} {
                tk_messageBox -icon error -parent $d -message [tr WoodpeckerBadRating]
                return
            }
            set ::woodpecker::ui::lastRating $rating
        } else {
            catch { ::woodpecker::set::tokenWrite $token }
        }
        set shares [dict create]
        foreach lv $::woodpecker::set::LEVELS {
            if {[string is double -strict $newCfg($lv)] && $newCfg($lv) > 0} { dict set shares $lv $newCfg($lv) }
        }
        if {![dict size $shares] || $newCfg(count) < 1} {
            tk_messageBox -icon error -parent $d -message [tr WoodpeckerNoDifficulty]
            return
        }
        set ::woodpecker::ui::lastCount $newCfg(count)
        set ::woodpecker::ui::lastPreset $newCfg(preset)
        set spec [dict create count $newCfg(count) shares $shares angle [themeKey $newCfg(theme)] \
            color $newCfg(color) token $token rating $rating]
        dict set meta preset $newCfg(preset)
        dict set meta shares $shares
        dict set meta angle [dict get $spec angle]
        dict set meta token [expr {$token ne ""}]
        if {$newCfg(tokenRating) ne ""} { dict set meta rating $newCfg(tokenRating) }
        if {$rating ne ""} { dict set meta rating $rating }
        destroy $d
        set dir [::woodpecker::set::newDir $name]
        progressOpen [tr WoodpeckerDownloading] ::woodpecker::set::cancel
        if {[catch {
            set exs [::woodpecker::set::fetchLichess $spec ::woodpecker::ui::progressStep]
            progressStep 0 0 [tr WoodpeckerBuilding]
            set n [::woodpecker::set::buildFromExercises $dir $meta $exs]
        } err]} {
            progressClose
            file delete -force $dir
            if {$err ne "cancelled"} {
                tk_messageBox -icon error -parent .woodpeckerWin -message [T WoodpeckerCreateFailed $err]
            }
            refresh
            return
        }
        progressClose
        set msg [T WoodpeckerCreated $n]
        if {$n < $newCfg(count)} { append msg "\n" [T WoodpeckerFewer $n $newCfg(count)] }
        refresh
        selectSet $dir
        afterCreate $dir $msg
    } else {
        set file $newCfg(file)
        if {![file readable $file]} {
            tk_messageBox -icon error -parent $d -message [T WoodpeckerNoFile $file]
            return
        }
        destroy $d
        set dir [::woodpecker::set::newDir $name]
        progressOpen [tr WoodpeckerBuilding] ""
        if {[catch { ::woodpecker::set::buildFromFile $dir $meta $file } res]} {
            progressClose
            file delete -force $dir
            tk_messageBox -icon error -parent .woodpeckerWin -message [T WoodpeckerCreateFailed $res]
            refresh
            return
        }
        progressClose
        lassign $res n annotated skipped
        set msg [T WoodpeckerCreated $n]
        if {$skipped} { append msg "\n" [T WoodpeckerSkipped $skipped] }
        refresh
        selectSet $dir
        afterCreate $dir $msg
    }
}

proc ::woodpecker::ui::selectSet {dir} {
    variable w
    if {[winfo exists $w.home.sets] && [$w.home.sets exists $dir]} {
        $w.home.sets selection set $dir
        $w.home.sets see $dir
    }
}

# A new set: say what was built and offer the evaluation (no annotations ->
# strongly recommended; some -> complete or overwrite).
proc ::woodpecker::ui::afterCreate {dir msg} {
    set st [::woodpecker::set::markStatus $dir]
    if {[dict get $st annotated] == 0} {
        if {[tk_messageBox -icon question -type yesno -parent .woodpeckerWin -title [tr WoodpeckerTitle] \
                -message "$msg\n\n[tr WoodpeckerEvalRecommended]"] eq "yes"} {
            evaluate $dir all
        }
        return
    }
    tk_messageBox -icon info -parent .woodpeckerWin -title [tr WoodpeckerTitle] -message $msg
    evaluate $dir
}

################################################################################
# Progress dialog

proc ::woodpecker::ui::progressOpen {title cancelVar} {
    variable progress
    set d .woodpeckerProgress
    catch { destroy $d }
    win::createDialog $d
    ::setTitle $d [tr WoodpeckerTitle]
    set progress(text) $title
    set progress(value) 0
    ttk::label $d.l -textvariable ::woodpecker::ui::progress(text) -width 46 -padding 10
    ttk::progressbar $d.p -length 340 -maximum 100 -variable ::woodpecker::ui::progress(value)
    pack $d.l -fill x
    pack $d.p -padx 10 -pady 4
    if {$cancelVar ne ""} {
        ttk::button $d.c -text $::tr(Cancel) -command [list set $cancelVar 1]
        pack $d.c -pady {4 10}
    }
    update idletasks
}

proc ::woodpecker::ui::progressStep {done total message} {
    variable progress
    if {![winfo exists .woodpeckerProgress]} { return }
    if {$total > 0} {
        set progress(value) [expr {100.0 * $done / $total}]
        set progress(text) "$message  ($done/$total)"
    } else {
        set progress(text) $message
    }
    update idletasks
}

proc ::woodpecker::ui::progressClose {} {
    catch { destroy .woodpeckerProgress }
}

################################################################################
# Evaluating a set

# `mode`: all | missing | ask. With ask the dialog follows the trainee's rule:
#   no annotations -> the evaluation is strongly recommended
#   some annotated -> complete with the review, or overwrite everything
#   all annotated  -> the review is optional: overwrite or keep
proc ::woodpecker::ui::evaluate {{dir ""} {mode ask}} {
    if {$dir eq ""} { set dir [current] }
    if {$dir eq ""} { return }
    if {[::woodpecker::eval::busy]} {
        tk_messageBox -icon info -parent .woodpeckerWin -message [tr WoodpeckerEvalBusy]
        return
    }
    set exs [::woodpecker::readExercises $dir]
    set all [lsort -integer [dict keys $exs]]
    set st [::woodpecker::set::markStatus $dir]
    set total [dict get $st total]
    set annotated [dict get $st annotated]
    set author {}
    set marks [::woodpecker::readMarks $dir]
    dict for {ex e} [::woodpecker::marksAt $marks [::woodpecker::marksLatest $marks]] {
        if {[dict get $e source] eq "author"} { lappend author $ex }
    }
    set missing {}
    foreach ex $all { if {$ex ni $author} { lappend missing $ex } }
    if {$mode eq "ask"} {
        if {$annotated == 0} {
            set mode all
        } elseif {$annotated < $total} {
            set ans [choice [T WoodpeckerSomeAnnotated $annotated $total] \
                [list missing [tr WoodpeckerComplete] all [tr WoodpeckerOverwrite] cancel $::tr(Cancel)]]
            if {$ans eq "cancel"} { return }
            set mode $ans
        } else {
            set ans [choice [T WoodpeckerAllAnnotated $total] \
                [list all [tr WoodpeckerOverwrite] cancel [tr WoodpeckerKeep]]]
            if {$ans eq "cancel"} { return }
            set mode all
        }
    }
    set list [expr {$mode eq "missing" ? $missing : $all}]
    if {![llength $list]} { return }
    set engine [chooseEngine [llength $list]]
    if {$engine eq ""} { return }
    progressOpen [tr WoodpeckerEvaluating] ::woodpecker::ui::evalCancel
    set ::woodpecker::ui::evalCancel 0
    trace add variable ::woodpecker::ui::evalCancel write ::woodpecker::ui::evalCancelled
    if {[catch {
        ::woodpecker::eval::start $dir $engine $list ::woodpecker::ui::evalProgress \
            [list ::woodpecker::ui::evalDone $dir]
    } err]} {
        evalCleanup
        tk_messageBox -icon error -parent .woodpeckerWin -message $err
    }
}

proc ::woodpecker::ui::evalCancelled {args} { ::woodpecker::eval::cancel }

proc ::woodpecker::ui::evalCleanup {} {
    catch { trace remove variable ::woodpecker::ui::evalCancel write ::woodpecker::ui::evalCancelled }
    progressClose
}

proc ::woodpecker::ui::evalProgress {phase done total} {
    progressStep $done $total [tr WoodpeckerEvalPhase_$phase]
}

proc ::woodpecker::ui::evalDone {dir status summary} {
    evalCleanup
    switch -- $status {
        ok {
            set msg [T WoodpeckerEvalDone [dict get $summary exercises] [dict get $summary bang] \
                [dict get $summary bangbang] [dict get $summary moves]]
            if {[winfo exists .woodpeckerWin]} {
                tk_messageBox -icon info -parent .woodpeckerWin -title [tr WoodpeckerTitle] -message $msg
            }
        }
        error {
            tk_messageBox -icon error -title [tr WoodpeckerTitle] -message $summary
        }
    }
    refresh
}

# A small modal choice outside a session; returns the key of the button.
proc ::woodpecker::ui::choice {message buttons {parent .woodpeckerWin}} {
    set d .woodpeckerChoice
    catch { destroy $d }
    win::createDialog $d
    ::setTitle $d [tr WoodpeckerTitle]
    set ::woodpecker::ui::choiceAns cancel
    ttk::label $d.m -text $message -wraplength 400 -justify left -padding 12
    ttk::frame $d.b -padding {10 0 10 10}
    foreach {key label} $buttons {
        ttk::button $d.b.$key -text $label -command [list set ::woodpecker::ui::choiceAns $key]
        pack $d.b.$key -side left -padx 4
    }
    pack $d.m -fill x
    pack $d.b -fill x
    wm protocol $d WM_DELETE_WINDOW { set ::woodpecker::ui::choiceAns cancel }
    catch { ::tk::PlaceWindow $d widget $parent }
    grab $d
    vwait ::woodpecker::ui::choiceAns
    catch { grab release $d }
    catch { destroy $d }
    return $::woodpecker::ui::choiceAns
}

# The engine for an evaluation: the UCI presets; "" when cancelled.
proc ::woodpecker::ui::chooseEngine {count} {
    set names {}
    foreach n [::enginecfg::names] {
        set cfg [::enginecfg::get $n]
        if {[lindex $cfg 7] ne "" && [lindex $cfg 7] ne 0} { lappend names $n }
    }
    if {![llength $names]} {
        tk_messageBox -icon error -parent .woodpeckerWin -message [tr WoodpeckerNoEngine]
        return ""
    }
    if {$::woodpecker::ui::engine ni $names} { set ::woodpecker::ui::engine [lindex $names 0] }
    set d .woodpeckerEngine
    catch { destroy $d }
    win::createDialog $d
    ::setTitle $d [tr WoodpeckerEvaluate]
    set ::woodpecker::ui::engineAns ""
    ttk::label $d.m -text [T WoodpeckerEvalAsk $count] -wraplength 360 -justify left -padding 12
    ttk::combobox $d.c -state readonly -values $names -textvariable ::woodpecker::ui::engine -width 30
    ttk::frame $d.b -padding 10
    ttk::button $d.b.ok -text [tr WoodpeckerEvaluate] -command { set ::woodpecker::ui::engineAns $::woodpecker::ui::engine }
    ttk::button $d.b.cancel -text $::tr(Cancel) -command { set ::woodpecker::ui::engineAns "-" }
    pack $d.b.cancel $d.b.ok -side right -padx 4
    pack $d.m -fill x
    pack $d.c -padx 12 -anchor w
    pack $d.b -fill x
    wm protocol $d WM_DELETE_WINDOW { set ::woodpecker::ui::engineAns "-" }
    grab $d
    vwait ::woodpecker::ui::engineAns
    catch { grab release $d }
    catch { destroy $d }
    if {$::woodpecker::ui::engineAns eq "-"} { return "" }
    return $::woodpecker::ui::engineAns
}

################################################################################
# The session

proc ::woodpecker::ui::train {{dir ""}} {
    variable run
    variable w
    variable keysBound
    variable txt
    variable focus
    if {$dir eq ""} { set dir [current] }
    if {$dir eq "" || $run(on)} { return }
    if {[info exists ::playMode]} {
        tk_messageBox -icon info -parent $w -message [tr WoodpeckerOtherMode]
        return
    }
    set exs [::woodpecker::readExercises $dir]
    if {![dict size $exs]} { return }
    set now [clock seconds]
    set dp [dayPlan $dir $now]
    if {[dict get $dp rest] ne "" && [::woodpecker::today $now] < [dict get $dp rest]} {
        if {[tk_messageBox -icon question -type yesno -parent $w -title [tr WoodpeckerTitle] \
                -message [T WoodpeckerRestAsk [dict get $dp rest] [dict get $dp cycle]]] ne "yes"} { return }
    }
    # The whole main window for the session: board and panel, nothing else.
    set focused [enterFocus]
    lassign [::woodpecker::readLog $dir] xs ss
    set session 0
    foreach x $xs { if {[dict get $x session] > $session} { set session [dict get $x session] } }
    foreach s $ss { if {[dict get $s session] > $session} { set session [dict get $s session] } }
    set marks [::woodpecker::readMarks $dir]
    set meta [dict get $dp meta]
    array unset run
    array set run [list on 1 dir $dir exs $exs n [dict size $exs] cycle [dict get $dp cycle] \
        next [dict get $dp next] session [expr {$session + 1}] quota [dict get $dp quota] \
        doneToday [dict get $dp doneToday] deadline [dict get $dp deadline] \
        doneCycle [expr {[dict get $dp next] - 1}] \
        table [::woodpecker::marksAt $marks [::woodpecker::marksLatest $marks]] \
        t0 [clock milliseconds] start $now paused 0 pausedMs 0 pauseT 0 lastInput [clock milliseconds] \
        wait "" ex 0 state {} exT0 0 exPaused 0 pending "" results {} streak 0 points 0.0 max 0.0 \
        prevBase [sc_base current] xs $xs engines {} played 0 fen "" solution {} why "" \
        name [dict get $meta name]]
    # The session plays in a database of its own, in memory: the game open in
    # any base is left exactly as it is. (sc_game push/pop keeps one slot per
    # base, which other windows also use, so it cannot hold a game for a
    # whole session.)
    if {[catch { sc_base create MEMORY "Woodpecker" } mem]} {
        array set run {on 0}
        tk_messageBox -icon error -parent $w -message [T WoodpeckerNoSlot $mem]
        if {$focus(active)} { leaveFocus }
        return
    }
    set run(memBase) $mem
    ::file::SwitchToBase $mem
    # Without the focus layout an engine window that follows the board would
    # show the solution.
    if {!$focused} { set run(engines) [pauseEngines] }
    if {!$keysBound} {
        bind MainBoardKeys <Return> {+::woodpecker::ui::keyContinue}
        bind MainBoardKeys <space> {+::woodpecker::ui::keyContinue}
        set keysBound 1
    }
    ::setPlayMode ::woodpecker::ui::callback
    showPage sess
    $w.sess.b.pause configure -text [tr WoodpeckerPause]
    set notes [lrange [dict get $dp lines] 2 end]
    set unrated 0
    dict for {ex e} $exs { if {![dict exists $run(table) $ex]} { incr unrated } }
    if {$unrated} { lappend notes [T WoodpeckerUnratedShort $unrated] }
    set txt(notice) [join $notes "\n"]
    set txt(ltoday) [tr WoodpeckerToday]
    verdict ""
    statsLine
    tick
    nextExercise
}

proc ::woodpecker::ui::more {} {
    variable run
    if {$run(on) || ![info exists run(dir)]} { return }
    train $run(dir)
}

proc ::woodpecker::ui::elapsedMs {} {
    variable run
    set now [clock milliseconds]
    set idle [expr {$run(pausedMs) + ($run(paused) ? $now - $run(pauseT) : 0)}]
    return [expr {$now - $run(t0) - $idle}]
}

proc ::woodpecker::ui::tick {} {
    variable run
    variable txt
    variable w
    if {!$run(on) || ![winfo exists $w]} { return }
    set e [expr {[elapsedMs] / 1000}]
    set txt(clock) [format "%d:%02d" [expr {$e / 60}] [expr {$e % 60}]]
    if {$run(wait) eq "ask" && !$run(paused) \
            && [clock milliseconds] - $run(lastInput) > $::woodpecker::P(idleMs)} {
        pause 1
    }
    after 500 ::woodpecker::ui::tick
}

# The two bars: today's target and the cycle. Blue up to the target, orange for
# what goes beyond it, on a rounded track.
proc ::woodpecker::ui::drawBars {} {
    variable run
    variable w
    if {!$run(on) && ![info exists run(doneToday)]} { return }
    catch { bar $w.sess.bars.ctoday $run(doneToday) $run(quota) }
    catch { bar $w.sess.bars.ccycle $run(doneCycle) $run(n) }
}

proc ::woodpecker::ui::bar {c done target} {
    if {![winfo exists $c]} { return }
    $c delete all
    set cw [winfo width $c]
    set ch [winfo height $c]
    if {$cw < 4} { return }
    set total [expr {double(max($target, $done, 1))}]
    roundRect $c 0 0 $cw $ch [expr {$ch / 2.0}] -fill [color track] -outline ""
    set x [expr {$cw * min($done, $target) / $total}]
    if {$x > 0} { roundRect $c 0 0 $x $ch [expr {$ch / 2.0}] -fill [color accent] -outline "" }
    if {$done > $target} {
        roundRect $c [expr {$cw * $target / $total - $ch / 2.0}] 0 [expr {$cw * $done / $total}] $ch \
            [expr {$ch / 2.0}] -fill [color extra] -outline ""
    }
}

# The attempts left, as two dots: blue while both are there, orange when one
# is left, an empty ring for each spent.
# The session's exercises as tiles, wrapping onto more rows when they do not
# fit: the colour of each result, in the order they were played.
proc ::woodpecker::ui::drawStrip {} {
    variable run
    variable w
    if {![info exists run(results)]} { return }
    foreach c [list $w.sess.strip $w.sum.strip] {
        if {![winfo exists $c]} { continue }
        $c delete all
        set cw [winfo width $c]
        if {$cw < 20} { continue }
        set size 14
        set gap 4
        set perRow [expr {max(1, ($cw + $gap) / ($size + $gap))}]
        set i 0
        foreach r $run(results) {
            set x [expr {($i % $perRow) * ($size + $gap)}]
            set y [expr {($i / $perRow) * ($size + $gap) + 2}]
            set col [dict get {clean good second warn failed bad} [dict get $r result]]
            roundRect $c $x $y [expr {$x + $size}] [expr {$y + $size}] 3 -fill [color $col] -outline ""
            incr i
        }
        set rows [expr {$i ? ($i - 1) / $perRow + 1 : 1}]
        set want [expr {$rows * ($size + $gap) + 2}]
        if {[$c cget -height] != $want} { $c configure -height $want }
    }
}

proc ::woodpecker::ui::drawAttempts {} {
    variable run
    variable w
    set c $w.sess.head.att
    if {![winfo exists $c]} { return }
    $c delete all
    if {$run(state) eq ""} { return }
    set left [expr {2 - [dict get $run(state) errors]}]
    set fill [expr {$left == 2 ? [color accent] : [color warn]}]
    foreach i {0 1} {
        set x [expr {6 + $i * 30}]
        if {$i < $left} {
            $c create oval $x 4 [expr {$x + 20}] 24 -fill $fill -outline $fill
        } else {
            $c create oval [expr {$x + 1}] 5 [expr {$x + 19}] 23 -outline [color muted] -width 2
        }
    }
}

proc ::woodpecker::ui::statsLine {} {
    variable run
    variable txt
    set txt(ntoday) "$run(doneToday) / $run(quota)"
    set txt(lcycle) [T WoodpeckerCycleShort $run(cycle)]
    set txt(ncycle) "$run(doneCycle) / $run(n)"
    set done [llength $run(results)]
    set parts {}
    if {$done} {
        set avg [expr {[sumMs] / 1000.0 / $done}]
        set target [targetPace]
        if {$target ne ""} {
            lappend parts [T WoodpeckerPace [format %.0f $avg] [format %.0f $target]]
        } else {
            lappend parts [T WoodpeckerPaceFirst [format %.0f $avg]]
        }
        set pct [expr {$run(max) > 0 ? 100.0 * $run(points) / $run(max) : 0.0}]
        lappend parts [T WoodpeckerStatsLine $run(streak) [pct $pct]]
    }
    lappend parts [T WoodpeckerDeadline $run(deadline)]
    set txt(meta) [join $parts "   \u00b7   "]
    drawBars
    drawStrip
}

proc ::woodpecker::ui::sumMs {} {
    variable run
    set s 0
    foreach r $run(results) { incr s [dict get $r ms] }
    return $s
}

# Seconds per exercise to halve the previous cycle's solving time.
proc ::woodpecker::ui::targetPace {} {
    variable run
    if {$run(cycle) < 2} { return "" }
    set ms 0
    set n 0
    foreach x $run(xs) {
        if {[dict get $x cycle] == $run(cycle) - 1 && [string is integer -strict [dict get $x ms]]} {
            incr ms [dict get $x ms]
            incr n
        }
    }
    if {!$n} { return "" }
    return [expr {$ms / 2000.0 / $n}]
}

proc ::woodpecker::ui::attemptsLeft {} {
    variable run
    if {$run(state) eq ""} { return 2 }
    return [expr {2 - [dict get $run(state) errors]}]
}

# The next exercise of the cycle, or the end of the cycle.
proc ::woodpecker::ui::nextExercise {} {
    variable run
    variable txt
    variable w
    if {!$run(on)} { return }
    if {$run(next) < 1 || $run(next) > $run(n)} {
        finish cycle
        return
    }
    set ex $run(next)
    set e [dict get $run(exs) $ex]
    set run(ex) $ex
    set run(state) [::woodpecker::exStart [dict get $e nmoves]]
    set run(solution) [dict get $e solution]
    set run(fen) [dict get $e fen]
    set run(played) 0
    sc_game new
    sc_game startBoard $run(fen)
    set side [::woodpecker::fenSide $run(fen)]
    ::board::flipAuto .main.board [expr {$side eq "b"}]
    ::notify::PosChanged -pgn
    clearArrows
    set last [dict get $e lastMove]
    if {$last ne ""} { after [expr {$::animateDelay + 40}] [list ::woodpecker::ui::arrow $last "#9a9a9a" woodpeckerLast] }
    set run(exT0) [clock milliseconds]
    set run(lastInput) $run(exT0)
    set run(exPaused) 0
    set run(wait) ask
    set rating [dict get $e rating]
    set txt(title) [T WoodpeckerExercise $ex $run(n)]
    set txt(sub) "[tr [expr {$side eq "w" ? "WoodpeckerWhiteToMove" : "WoodpeckerBlackToMove"}]][expr {$rating ne "" ? "   \u00b7   $rating" : ""}]"
    set c $w.sess.sub.side
    if {[winfo exists $c]} {
        $c delete all
        $c create rectangle 1 1 11 11 -fill [expr {$side eq "w" ? "#ffffff" : "#1a1a1a"}] -outline [color muted]
    }
    drawAttempts
    cardAsk
    status ""
}

proc ::woodpecker::ui::arrow {uci color tag} {
    if {[string length $uci] < 4 || ![winfo exists .main.board.bd]} { return }
    catch {
        ::board::mark::DrawArrowEx .main.board [::board::sq [string range $uci 0 1]] \
            [::board::sq [string range $uci 2 3]] $color 0.05 {3.6 4.8 2.0} $tag
    }
}

proc ::woodpecker::ui::clearArrows {} {
    if {[winfo exists .main.board.bd]} { catch { .main.board.bd delete woodpeckerLast } }
}

# A move is about to be played: is it the solution's?
proc ::woodpecker::ui::premove {uci} {
    variable run
    if {!$run(on) || $run(wait) ne "ask"} { return 1 }
    if {[catch {sc_game SANtoUCI $uci}]} { return 1 }
    set run(lastInput) [clock milliseconds]
    if {$run(paused)} { pause }
    clearArrows
    set idx [dict get $run(state) idx]
    set ply [expr {2 * $idx}]
    set expected [lindex $run(solution) $ply]
    set last [expr {$ply == [llength $run(solution)] - 1}]
    set correct [::woodpecker::sameMove $uci $expected]
    if {!$correct && $last && [::woodpecker::isMateMove [sc_pos fen] $uci]} { set correct 1 }
    lassign [::woodpecker::exAnswer $run(state) $correct] state what
    set run(state) $state
    drawAttempts
    if {$correct} {
        set run(pending) $what
        set run(wait) move
        return 0
    }
    verdict ko
    catch { ::utils::sound::PlaySound sound_alert }
    if {$what eq "retry"} {
        cardAsk wrong
    } else {
        set run(wait) done
        after idle [list ::woodpecker::ui::exerciseDone failed]
    }
    return 1
}

# The trainee's right move is on the board: the reply, or the end.
proc ::woodpecker::ui::postmove {} {
    variable run
    if {!$run(on) || $run(wait) ne "move"} { return }
    incr run(played)
    verdict ok
    if {$run(pending) eq "solved"} {
        set run(wait) done
        after $::animateDelay [list ::woodpecker::ui::exerciseDone [dict get $run(state) result]]
        return
    }
    set run(wait) reply
    set idx [dict get $run(state) idx]
    set reply [lindex $run(solution) [expr {2 * $idx - 1}]]
    after $::animateDelay [list ::woodpecker::ui::reply $reply]
}

proc ::woodpecker::ui::reply {uci} {
    variable run
    if {!$run(on) || $run(wait) ne "reply"} { return }
    if {[catch { sc_move addSan $uci }]} { catch { sc_move addSan [string range $uci 0 3] } }
    incr run(played)
    ::notify::PosChanged -pgn -animate
    set run(lastInput) [clock milliseconds]
    set run(wait) ask
    cardAsk
}

################################################################################
# The card

proc ::woodpecker::ui::cardText {} { return $::woodpecker::ui::w.sess.card.t }

proc ::woodpecker::ui::cardBegin {stripe} {
    set t [cardText]
    if {![winfo exists $t]} { return "" }
    $t configure -state normal
    $t delete 1.0 end
    [winfo parent $t].stripe configure -background [color $stripe]
    return $t
}

proc ::woodpecker::ui::cardEnd {t} {
    $t configure -state disabled
}

# While the exercise is on: whose move it is, the moves played so far, and the
# solution kept out of sight. `mode` wrong: one attempt is gone.
proc ::woodpecker::ui::cardAsk {{mode ""}} {
    variable run
    set t [cardBegin [expr {$mode eq "wrong" ? "warn" : "track"}]]
    if {$t eq ""} { return }
    if {$mode eq "wrong"} {
        $t insert end "[tr WoodpeckerWrongHead]\n" {head warn}
        $t insert end [tr WoodpeckerWrong] dim
    } else {
        $t insert end "[tr WoodpeckerYourMove]\n" head
        if {$run(played)} {
            set line ""
            catch { set line [::woodpecker::lineText $run(fen) [lrange $run(solution) 0 [expr {$run(played) - 1}]] {}] }
            $t insert end "$line  " move
        }
        $t insert end [tr WoodpeckerHidden] dim
    }
    cardEnd $t
}

# The exercise is over: the result, the points, and the whole line with its
# marks. On a failure the moves can be clicked to show their position.
proc ::woodpecker::ui::cardResult {result points max marks quotaDone} {
    variable run
    set stripe [dict get {clean good second warn failed bad} $result]
    set t [cardBegin $stripe]
    if {$t eq ""} { return }
    set head [dict get {clean WoodpeckerSolved second WoodpeckerSolvedSecond failed WoodpeckerFailed} $result]
    $t insert end "[tr $head]   " [list head $stripe]
    $t insert end [T WoodpeckerPoints [num $points] [num $max]] pts
    $t insert end "\n"
    set pos [::chessboard::fromFen $run(fen)]
    set i 0
    set first 1
    foreach uci $run(solution) {
        set san ""
        catch { set san [::woodpecker::uciToSan $pos $uci] }
        set mark ""
        if {$i % 2 == 0} { set mark [lindex $marks [expr {$i / 2}]] }
        if {$mark eq "-"} { set mark "" }
        set num [dict get $pos full]
        if {[dict get $pos side] eq "w"} {
            $t insert end "$num. " dim
        } elseif {$first} {
            $t insert end "$num... " dim
        }
        set first 0
        set tag "ply[expr {$i + 1}]"
        $t insert end $san [list move link $tag]
        if {$mark ne ""} { $t insert end $mark [list [expr {$mark eq "!!" ? "bang2" : "bang"}] $tag] }
        $t insert end " "
        $t tag bind $tag <ButtonRelease-1> [list ::woodpecker::ui::gotoPly [expr {$i + 1}]]
        $t tag bind $tag <Enter> [list $t configure -cursor hand2]
        $t tag bind $tag <Leave> [list $t configure -cursor arrow]
        catch { set pos [::chessboard::makeMove $pos $uci] }
        incr i
    }
    if {![llength $marks]} { $t insert end "\n[tr WoodpeckerNoMarks]" dim }
    if {$quotaDone} { $t insert end "\n[tr WoodpeckerQuotaDone]" good }
    cardEnd $t
}

proc ::woodpecker::ui::gotoPly {ply} {
    variable run
    if {!$run(on) || $run(wait) ne "solution"} { return }
    catch { sc_move ply $ply }
    ::notify::PosChanged -pgn
    set t [cardText]
    $t tag remove cur 1.0 end
    foreach {a b} [$t tag ranges ply$ply] { $t tag add cur $a $b }
}

################################################################################
# End of an exercise

# One exercise is over: score it, write it down, then the next one.
proc ::woodpecker::ui::exerciseDone {result} {
    variable run
    if {!$run(on)} { return }
    set ex $run(ex)
    set ms [expr {max(0, [clock milliseconds] - $run(exT0) - $run(exPaused))}]
    set found [::woodpecker::foundString $run(state)]
    set e [dict get $run(exs) $ex]
    set marks {}
    if {[dict exists $run(table) $ex]} { set marks [dict get $run(table) $ex marks] }
    set s [::woodpecker::score $marks [split $found ""] $result [::woodpecker::weight [dict get $e rating]]]
    ::woodpecker::logExercise $run(dir) [clock seconds] $run(cycle) $run(session) $ex $result $found $ms
    lappend run(xs) [dict create ts [clock seconds] cycle $run(cycle) session $run(session) ex $ex \
        result $result found $found ms $ms]
    lappend run(results) [dict create ex $ex result $result ms $ms points [dict get $s points] max [dict get $s max]]
    set run(points) [expr {$run(points) + [dict get $s points]}]
    set run(max) [expr {$run(max) + [dict get $s max]}]
    set run(streak) [expr {$result eq "clean" ? $run(streak) + 1 : 0}]
    incr run(doneToday)
    incr run(doneCycle)
    set run(next) [expr {$ex + 1}]
    statsLine
    cardResult $result [dict get $s points] [dict get $s max] $marks \
        [expr {$run(doneToday) == $run(quota) && $run(quota) > 0}]
    if {$result eq "failed"} {
        showSolution
        return
    }
    set run(wait) next
    after 1100 ::woodpecker::ui::advance
}

proc ::woodpecker::ui::advance {} {
    variable run
    if {!$run(on) || $run(wait) ne "next"} { return }
    nextExercise
}

# After a failure the rest of the solution goes on the board, with its marks,
# and can be stepped through (arrows, or a click on the card); Enter goes on.
proc ::woodpecker::ui::showSolution {} {
    variable run
    set idx [dict get $run(state) idx]
    set marks {}
    if {[dict exists $run(table) $run(ex)]} { set marks [dict get $run(table) $run(ex) marks] }
    set i 0
    foreach uci [lrange $run(solution) [expr {2 * $idx}] end] {
        if {[catch { sc_move addSan $uci }]} { break }
        if {$i % 2 == 0} {
            set m [lindex $marks [expr {$idx + $i / 2}]]
            if {$m ne "" && $m ne "-"} { catch { sc_pos addNag $m } }
        }
        incr i
    }
    sc_move ply [expr {2 * $idx}]
    ::notify::PosChanged -pgn
    set run(wait) solution
    status [tr WoodpeckerSolutionShown] 1
}

proc ::woodpecker::ui::keyContinue {} {
    variable run
    if {!$run(on)} { return }
    if {$run(wait) eq "solution"} {
        status ""
        nextExercise
    } elseif {$run(wait) eq "next"} {
        after cancel ::woodpecker::ui::advance
        nextExercise
    }
}

proc ::woodpecker::ui::pause {{auto 0}} {
    variable run
    variable w
    if {!$run(on)} { return }
    set now [clock milliseconds]
    if {$run(paused)} {
        set gap [expr {$now - $run(pauseT)}]
        incr run(pausedMs) $gap
        incr run(exPaused) $gap
        set run(paused) 0
        set run(lastInput) $now
        $w.sess.b.pause configure -text [tr WoodpeckerPause]
        status ""
    } else {
        set run(paused) 1
        # An automatic pause gives back the time spent away from the board.
        set run(pauseT) [expr {$auto ? $run(lastInput) : $now}]
        $w.sess.b.pause configure -text [tr WoodpeckerResume]
        status [tr [expr {$auto ? "WoodpeckerAutoPaused" : "WoodpeckerPaused"}]]
    }
}

proc ::woodpecker::ui::status {text {cont 0}} {
    variable txt
    variable w
    set txt(status) $text
    if {![winfo exists $w.sess.line.cont]} { return }
    if {$cont} {
        pack $w.sess.line.cont -side right
        focus .main
    } else {
        pack forget $w.sess.line.cont
    }
}

# The tile next to the clock: a tick or a cross for half a second.
proc ::woodpecker::ui::verdict {kind} {
    variable w
    variable txt
    after cancel {::woodpecker::ui::verdict ""}
    if {![winfo exists $w.sess.head.verdict]} { return }
    lassign [dict get [list ok [list "\u2713" good] ko [list "\u2717" bad] "" {{} bg}] $kind] sym col
    set txt(verdict) $sym
    $w.sess.head.verdict configure -background [color $col]
    if {$kind ne ""} { after 500 {::woodpecker::ui::verdict ""} }
}

################################################################################
# End of the session

# The session ends: the record sheet row, the board back as it was, and the
# summary - still in the focus layout, until the trainee leaves.
proc ::woodpecker::ui::finish {{why ""}} {
    variable run
    if {!$run(on)} { return }
    set dur [elapsedMs]
    set done [llength $run(results)]
    if {$done} {
        ::woodpecker::logSession $run(dir) [clock seconds] $run(cycle) $run(session) $run(start) $dur
    }
    set run(why) $why
    set run(dur) $dur
    stop
    if {[winfo exists .woodpeckerWin.sum]} {
        summary
        showPage sum
    }
}

proc ::woodpecker::ui::summary {} {
    variable run
    variable txt
    variable w
    set done [llength $run(results)]
    set txt(sumTitle) [tr WoodpeckerSessionOver]
    set txt(sumBadge) [expr {$run(why) eq "cycle" ? [T WoodpeckerCycleComplete $run(cycle)] : ""}]
    set pct [expr {$run(max) > 0 ? 100.0 * $run(points) / $run(max) : 0.0}]
    set txt(sumPoints) [pct $pct]
    set txt(sumPointsLabel) [T WoodpeckerSumPoints [num $run(points)] [num $run(max)]]
    set c [dict create clean 0 second 0 failed 0]
    set failed {}
    foreach r $run(results) {
        dict incr c [dict get $r result]
        if {[dict get $r result] eq "failed"} { lappend failed [dict get $r ex] }
    }
    set g $w.sum.grid
    foreach ch [winfo children $g] { destroy $ch }
    set rows [list \
        WoodpeckerSumDate [clock format $run(start) -format {%Y-%m-%d %H:%M}] \
        WoodpeckerSumDuration [::woodpecker::fmtDuration $run(dur)] \
        WoodpeckerSumExercises $done \
        WoodpeckerSumResults "[dict get $c clean] \u00b7 [dict get $c second] \u00b7 [dict get $c failed]" \
        WoodpeckerSumQuota "$run(doneToday) / $run(quota)[expr {$run(doneToday) >= $run(quota) ? "  \u2713" : ""}]" \
        WoodpeckerSumCycle "$run(doneCycle) / $run(n)   ([T WoodpeckerDeadline $run(deadline)])"]
    if {$done} {
        lappend rows WoodpeckerSumAvg "[format %.0f [expr {[sumMs] / 1000.0 / $done}]] s"
    }
    set r 0
    foreach {tag value} $rows {
        ttk::label $g.l$r -text [tr $tag] -foreground [color muted]
        ttk::label $g.v$r -text $value -font woodpeckerMove
        grid $g.l$r $g.v$r -sticky w -pady 2
        grid configure $g.l$r -padx {0 16}
        incr r
    }
    set notes {}
    if {$run(cycle) > 1 && $done} {
        set cmp [::woodpecker::compareCycles $run(xs) $run(cycle) [lmap x $run(results) { dict get $x ex }]]
        if {[dict get $cmp compared]} {
            lappend notes [T WoodpeckerSumCompare [dict get $cmp faster] [dict get $cmp slower] \
                [dict get $cmp fixed] [dict get $cmp newErrors]]
        }
    }
    if {[llength $failed]} { lappend notes [T WoodpeckerSumReview [join $failed {, }]] }
    set txt(sumNotes) [join $notes "\n\n"]
    after idle ::woodpecker::ui::drawStrip
    # More exercises only while the cycle has some left.
    if {$run(why) eq "cycle"} {
        pack forget $w.sum.b.more
    } elseif {![winfo ismapped $w.sum.b.more]} {
        pack $w.sum.b.more -side left -padx {0 6} -before $w.sum.b.stats
    }
}

# Leave the session's board and put back the open game.
proc ::woodpecker::ui::stop {} {
    variable run
    if {!$run(on)} { return }
    set run(on) 0
    after cancel ::woodpecker::ui::tick
    after cancel ::woodpecker::ui::advance
    after cancel {::woodpecker::ui::verdict ""}
    clearArrows
    if {[info exists ::playMode] && $::playMode eq "::woodpecker::ui::callback"} { ::setPlayMode "" }
    catch { ::board::flipAuto .main.board }
    if {[catch {sc_base switch $run(prevBase)}]} { sc_base switch $::clipbase_db }
    set ::curr_db [sc_base current]
    if {[info exists run(memBase)]} { catch { sc_base close $run(memBase) } }
    catch { ::notify::GameChanged }
    catch { ::notify::DatabaseChanged }
    if {[llength $run(engines)]} { resumeEngines $run(engines) }
    catch { ::woodpecker::eval::flushPending }
}

# Stop the engine windows that follow the board; returns their ids.
proc ::woodpecker::ui::pauseEngines {} {
    set out {}
    if {![array exists ::enginewin::engState]} { return $out }
    foreach id [array names ::enginewin::engState] {
        set following 0
        catch { set following [::enginewin::stateFollow $id] }
        if {$following && ![catch { ::enginewin::stop $id } stopped] && $stopped} { lappend out $id }
    }
    return $out
}

proc ::woodpecker::ui::resumeEngines {ids} {
    foreach id $ids { catch { ::enginewin::start $id } }
}

# What the application asks a game driver (see ::setPlayMode).
proc ::woodpecker::ui::callback {cmd args} {
    variable run
    switch -- $cmd {
        premove { return [premove [lindex $args 0]] }
        postmove {
            if {[catch {postmove} err]} { puts stderr "Woodpecker: $err" }
            return 0
        }
        info { return [list "[tr WoodpeckerTitle]:" $::tr(Stop) red ::woodpecker::ui::finish] }
        stop { finish; return 0 }
        moveBack - moveForward - moveStart - moveEnd - moveExitVar {
            # The solution of a failed exercise can be stepped through.
            return [expr {$run(on) && $run(wait) eq "solution"}]
        }
    }
    return 0
}

################################################################################
# Statistics: the record sheet per session, the cycles, and their trend

proc ::woodpecker::ui::stats {} {
    variable run
    set dir [current]
    if {$dir eq "" && [info exists run(dir)]} { set dir $run(dir) }
    if {$dir eq ""} { return }
    set d .woodpeckerStats
    catch { destroy $d }
    toplevel $d -background [color bg]
    fonts
    ::setTitle $d "[tr WoodpeckerStats]: [dict get [::woodpecker::readMeta $dir] name]"
    set exs [::woodpecker::readExercises $dir]
    lassign [::woodpecker::readLog $dir] xs ss
    set marks [::woodpecker::readMarks $dir]
    set ver [::woodpecker::marksLatest $marks]
    set table [::woodpecker::marksAt $marks $ver]
    set sessions [::woodpecker::sessionStats $xs $ss $exs $table]
    set cycles [::woodpecker::cycleStats $xs $exs $table]

    ttk::label $d.lc -text [tr WoodpeckerCyclesTitle] -font woodpeckerTitle -padding {10 8 10 2}
    canvas $d.chart -width 540 -height 170 -background [color field] -highlightthickness 0
    ttk::treeview $d.cyc -columns {cycle days time ex res pct} -show headings -height 4
    foreach {c tag w} {cycle WoodpeckerColCycle 50 days WoodpeckerColDays 190 time WoodpeckerColTime 90 \
            ex WoodpeckerColExercises 70 res WoodpeckerColResults 110 pct WoodpeckerColPct 60} {
        $d.cyc heading $c -text [tr $tag]
        $d.cyc column $c -width $w -anchor center
    }
    foreach c $cycles {
        $d.cyc insert {} end -values [list [dict get $c cycle] "[dict get $c start] \u2192 [dict get $c end]" \
            [::woodpecker::fmtDuration [dict get $c ms]] [dict get $c exercises] \
            "[dict get $c clean]/[dict get $c second]/[dict get $c failed]" [pct [dict get $c pct]]]
    }
    ttk::label $d.ls -text [tr WoodpeckerSessionsTitle] -font woodpeckerTitle -padding {10 8 10 2}
    ttk::treeview $d.ses -columns {date dur ex pts pct} -show headings -height 10 -yscrollcommand [list $d.sb set]
    ttk::scrollbar $d.sb -command [list $d.ses yview]
    foreach {c tag w} {date WoodpeckerColDate 110 dur WoodpeckerColDuration 90 ex WoodpeckerColExercises 90 \
            pts WoodpeckerColPoints 110 pct WoodpeckerColPct 70} {
        $d.ses heading $c -text [tr $tag]
        $d.ses column $c -width $w -anchor center
    }
    foreach s [lreverse $sessions] {
        $d.ses insert {} end -values [list [dict get $s date] [::woodpecker::fmtDuration [dict get $s dur]] \
            [dict get $s exercises] "[num [dict get $s points]] / [num [dict get $s max]]" [pct [dict get $s pct]]]
    }
    ttk::label $d.note -text [T WoodpeckerStatsNote $ver] -wraplength 540 -justify left -padding 10 \
        -foreground [color muted]
    ttk::button $d.close -text $::tr(Close) -command [list destroy $d]
    grid $d.lc - -sticky w
    grid $d.chart - -padx 10
    grid $d.cyc - -sticky ew -padx 10
    grid $d.ls - -sticky w
    grid $d.ses $d.sb -sticky nsew -padx {10 0}
    grid $d.note - -sticky w
    grid $d.close - -pady {0 10}
    grid columnconfigure $d 0 -weight 1
    grid rowconfigure $d 4 -weight 1
    bind $d <Escape> [list destroy $d]
    after idle [list ::woodpecker::ui::chart $d.chart $cycles]
}

# Bars: each cycle's solving time, with the target (the previous cycle halved)
# as a dashed line; the percentage of points above each bar.
proc ::woodpecker::ui::chart {c cycles} {
    if {![winfo exists $c]} { return }
    $c delete all
    set W [winfo reqwidth $c]
    set H [winfo reqheight $c]
    if {![llength $cycles]} {
        $c create text [expr {$W / 2}] [expr {$H / 2}] -text [tr WoodpeckerNoData] -fill [color muted]
        return
    }
    set maxMs 1
    foreach cy $cycles { set maxMs [expr {max($maxMs, [dict get $cy ms])}] }
    set n [llength $cycles]
    set slot [expr {($W - 40.0) / max($n, 6)}]
    set base [expr {$H - 22}]
    set top 24
    set prev ""
    set i 0
    foreach cy $cycles {
        set x0 [expr {30 + $i * $slot + $slot * 0.2}]
        set x1 [expr {30 + ($i + 1) * $slot - $slot * 0.2}]
        set h [expr {max(2, ($base - $top) * [dict get $cy ms] / double($maxMs))}]
        roundRect $c $x0 [expr {$base - $h}] $x1 $base 4 -fill [color accent] -outline ""
        $c create text [expr {($x0 + $x1) / 2}] [expr {$base + 10}] -text [dict get $cy cycle] \
            -font woodpeckerSmall -fill [color fg]
        $c create text [expr {($x0 + $x1) / 2}] [expr {$base - $h - 8}] \
            -text "[::woodpecker::fmtDuration [dict get $cy ms]] \u00b7 [pct [dict get $cy pct]]" \
            -font woodpeckerSmall -fill [color fg]
        if {$prev ne ""} {
            set ht [expr {($base - $top) * $prev / 2.0 / $maxMs}]
            $c create line [expr {$x0 - 4}] [expr {$base - $ht}] [expr {$x1 + 4}] [expr {$base - $ht}] \
                -fill [color extra] -width 2 -dash {4 2}
        }
        set prev [dict get $cy ms]
        incr i
    }
    $c create line 28 $base [expr {$W - 8}] $base -fill [color muted]
    $c create text [expr {$W - 10}] 8 -anchor ne -text [tr WoodpeckerChartLegend] \
        -font woodpeckerSmall -fill [color muted]
}
