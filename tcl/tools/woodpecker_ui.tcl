### woodpecker_ui.tcl: Woodpecker trainer - windows and the training session.
### SPDX-License-Identifier: GPL-2.0-or-later
###
### Play > Woodpecker Method. One window with three pages: the sets, the
### session panel and the session summary; a dialog to create a set, one to
### evaluate it, and a statistics window. Plan: docs/woodpecker-plan.md.
###
### The session follows Repertoire Recall's rules: a scratch game in the
### clipbase (the open game is left alone), no pop-up inside an exercise,
### feedback that never blocks, the opponent's reply without a click.

namespace eval ::woodpecker::ui {
    variable w .woodpeckerWin
    variable txt
    array set txt {}
    variable run
    array set run {on 0}
    variable keysBound 0
    variable newCfg
    array set newCfg {}
    variable evalCfg
    array set evalCfg {}
    variable progress
    array set progress {}
}

if {[llength [info commands ::options.store]]} {
    ::options.store ::woodpecker::ui::engine ""
    ::options.store ::woodpecker::ui::lastCount 300
    ::options.store ::woodpecker::ui::lastDays 28
}
if {![info exists ::woodpecker::ui::engine]} { set ::woodpecker::ui::engine "" }
if {![info exists ::woodpecker::ui::lastCount]} { set ::woodpecker::ui::lastCount 300 }
if {![info exists ::woodpecker::ui::lastDays]} { set ::woodpecker::ui::lastDays 28 }

proc ::woodpecker::ui::T {tag args} {
    if {[llength $args]} { return [format [tr $tag] {*}$args] }
    return [tr $tag]
}

proc ::woodpecker::ui::neutral {} { return [ttk::style lookup TFrame -background] }

proc ::woodpecker::ui::pct {x} { return [format "%.0f%%" $x] }

proc ::woodpecker::ui::num {x} {
    set r [format "%.1f" $x]
    if {[string match *.0 $r]} { set r [string range $r 0 end-2] }
    return $r
}

################################################################################
# The window

proc ::woodpecker::ui::open {} {
    variable w
    if {[::createToplevel $w] eq "already_exists"} { return }
    ::setTitle $w [tr WoodpeckerTitle]
    catch { font create woodpeckerBig {*}[font actual font_Regular] -size 18 -weight bold }
    catch { font create woodpeckerMid {*}[font actual font_Regular] -size 11 }
    catch { font create woodpeckerMove {*}[font actual font_Regular] -size 12 -weight bold }
    set v ::woodpecker::ui

    # --- the sets
    set h [ttk::frame $w.home -padding 10]
    ttk::treeview $h.sets -columns {name ex cycle progress last} -show headings -height 8 \
        -selectmode browse -yscrollcommand [list $h.sb set]
    ttk::scrollbar $h.sb -command [list $h.sets yview]
    foreach {c tag width} {name WoodpeckerColName 200 ex WoodpeckerColExercises 80 \
            cycle WoodpeckerColCycle 60 progress WoodpeckerColProgress 110 last WoodpeckerColLast 110} {
        $h.sets heading $c -text [tr $tag]
        $h.sets column $c -width $width -stretch [expr {$c eq "name"}]
    }
    bind $h.sets <<TreeviewSelect>> ${v}::selected
    bind $h.sets <Double-1> ${v}::train
    ttk::label $h.info -textvariable ${v}::txt(info) -wraplength 520 -justify left -font woodpeckerMid
    ttk::frame $h.b
    ttk::button $h.b.new -text [tr WoodpeckerNew] -command ${v}::newDialog
    ttk::button $h.b.train -image tb_play -text [tr WoodpeckerTrain] -compound left -command ${v}::train
    ttk::button $h.b.eval -text [tr WoodpeckerEvaluate] -command ${v}::evaluate
    ttk::button $h.b.stats -text [tr WoodpeckerStats] -command ${v}::stats
    ttk::button $h.b.del -text [tr WoodpeckerDelete] -command ${v}::deleteSet
    ttk::button $h.b.close -text $::tr(Close) -command [list destroy $w]
    pack $h.b.new $h.b.train $h.b.eval $h.b.stats $h.b.del -side left -padx {0 6}
    pack $h.b.close -side right
    grid $h.sets -row 0 -column 0 -sticky nsew
    grid $h.sb -row 0 -column 1 -sticky ns
    grid $h.info -row 1 -column 0 -columnspan 2 -sticky w -pady 8
    grid $h.b -row 2 -column 0 -columnspan 2 -sticky ew
    grid rowconfigure $h 0 -weight 1
    grid columnconfigure $h 0 -weight 1

    # --- the session
    set p [ttk::frame $w.sess -padding 10]
    ttk::frame $p.top
    label $p.top.verdict -textvariable ${v}::txt(verdict) -font woodpeckerBig -width 3 -background [neutral]
    ttk::label $p.top.clock -textvariable ${v}::txt(clock) -font woodpeckerBig
    ttk::label $p.top.att -textvariable ${v}::txt(attempts) -font woodpeckerBig
    pack $p.top.verdict -side left
    pack $p.top.clock -side left -padx 16
    pack $p.top.att -side right
    ttk::label $p.title -textvariable ${v}::txt(title) -font woodpeckerMove
    ttk::label $p.ltoday -textvariable ${v}::txt(today) -font woodpeckerMid
    canvas $p.today -height 8 -highlightthickness 0 -background white -relief solid -borderwidth 1
    ttk::label $p.lcycle -textvariable ${v}::txt(cycle) -font woodpeckerMid
    canvas $p.cyc -height 8 -highlightthickness 0 -background white -relief solid -borderwidth 1
    ttk::label $p.pace -textvariable ${v}::txt(pace) -font woodpeckerMid
    ttk::label $p.stats -textvariable ${v}::txt(stats) -font woodpeckerMid
    ttk::label $p.notice -textvariable ${v}::txt(notice) -wraplength 340 -justify left -foreground "#8a5a00"
    text $p.card -height 3 -width 42 -wrap word -font woodpeckerMid -relief solid -borderwidth 1 \
        -padx 8 -pady 6 -cursor arrow -state disabled -takefocus 0
    $p.card tag configure move -font woodpeckerMove
    $p.card tag configure good -font woodpeckerMove -foreground "#1e8a1e"
    $p.card tag configure bad -font woodpeckerMove -foreground "#c62828"
    ttk::frame $p.line
    ttk::label $p.line.status -textvariable ${v}::txt(status) -font woodpeckerMid -wraplength 300 -justify left
    ttk::button $p.line.cont -text [tr WoodpeckerContinue] -command ${v}::keyContinue
    pack $p.line.status -side left
    ttk::frame $p.b
    ttk::button $p.b.pause -text [tr WoodpeckerPause] -command ${v}::pause
    ttk::button $p.b.end -text [tr WoodpeckerEnd] -command ${v}::finish
    pack $p.b.pause -side left
    pack $p.b.end -side right
    # The buttons and the status line go in first, from the bottom, so a small
    # docked pane squeezes the feedback card rather than hiding them.
    pack $p.b -side bottom -fill x -pady {6 0}
    pack $p.line -side bottom -fill x
    pack $p.top -side top -anchor w -fill x
    pack $p.title -side top -anchor w -pady {4 2}
    # Then the feedback card, before the bars: the result and the points of
    # the exercise just played matter more than the totals below it.
    pack $p.card -side top -fill x -pady 4
    pack $p.ltoday -side top -anchor w
    pack $p.today -side top -fill x -pady {0 4}
    pack $p.lcycle -side top -anchor w
    pack $p.cyc -side top -fill x -pady {0 4}
    pack $p.pace $p.stats -side top -anchor w -pady 1
    pack $p.notice -side top -anchor w -pady 2

    # --- the summary
    set s [ttk::frame $w.sum -padding 10]
    text $s.t -height 12 -width 52 -wrap word -font woodpeckerMid -relief flat -cursor arrow \
        -state disabled -takefocus 0 -background [neutral]
    $s.t tag configure title -font woodpeckerBig
    $s.t tag configure head -font woodpeckerMove
    ttk::frame $s.b
    ttk::button $s.b.back -text [tr WoodpeckerBack] -command ${v}::backHome
    ttk::button $s.b.stats -text [tr WoodpeckerStats] -command ${v}::stats
    pack $s.b.back -side left
    pack $s.b.stats -side right
    pack $s.b -side bottom -fill x -pady {8 0}
    pack $s.t -side top -fill both -expand 1

    ::createToplevelFinalize $w
    bind $w <Destroy> "+if {{%W} eq {$w}} { ${v}::closed }"
    showPage home
    refresh
}

proc ::woodpecker::ui::showPage {page} {
    variable w
    foreach p {home sess sum} { pack forget $w.$p }
    pack $w.$page -fill both -expand 1
}

proc ::woodpecker::ui::closed {} {
    variable run
    if {$run(on)} { stop }
}

proc ::woodpecker::ui::backHome {} {
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
    foreach s [::woodpecker::set::all] {
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

# The selected set's day, in a few lines: where the cycle is, today's quota,
# rest days, and whether the set has been evaluated.
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
    # A set's database may be open in the main window.
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

proc ::woodpecker::ui::newDialog {} {
    variable newCfg
    set d .woodpeckerNew
    if {[winfo exists $d]} { raise $d; return }
    win::createDialog $d
    ::setTitle $d [tr WoodpeckerNewTitle]
    set v ::woodpecker::ui
    array set newCfg [list name "Woodpecker [clock format [clock seconds] -format %Y-%m-%d]" \
        source lichess count $::woodpecker::ui::lastCount color both theme [tr WoodpeckerThemeMix] \
        file "" days1 $::woodpecker::ui::lastDays restDays 1 \
        easiest 0 easier 0 normal 100 harder 0 hardest 0 token ""]
    if {[info exists ::lichess_puzzles::apiToken]} { set newCfg(token) $::lichess_puzzles::apiToken }
    set f [ttk::frame $d.f -padding 10]
    pack $f -fill both -expand 1
    ttk::label $f.lname -text [tr WoodpeckerName]
    ttk::entry $f.name -textvariable ${v}::newCfg(name) -width 36
    ttk::radiobutton $f.rl -text [tr WoodpeckerFromLichess] -variable ${v}::newCfg(source) -value lichess
    ttk::frame $f.lich -padding {20 0 0 0}
    ttk::label $f.lich.lcount -text [tr WoodpeckerCount]
    ttk::spinbox $f.lich.count -from 20 -to 2000 -increment 10 -width 6 -textvariable ${v}::newCfg(count)
    ttk::label $f.lich.ldiff -text [tr WoodpeckerDifficulty]
    ttk::frame $f.lich.diff
    set col 0
    foreach lv $::woodpecker::set::LEVELS {
        ttk::label $f.lich.diff.l$lv -text [tr WoodpeckerLevel_$lv]
        ttk::spinbox $f.lich.diff.s$lv -from 0 -to 100 -increment 10 -width 4 -textvariable ${v}::newCfg($lv)
        grid $f.lich.diff.l$lv -row 0 -column $col -padx 3
        grid $f.lich.diff.s$lv -row 1 -column $col -padx 3
        incr col
    }
    ttk::label $f.lich.diffhelp -text [tr WoodpeckerDifficultyHelp] -wraplength 380 -justify left
    ttk::label $f.lich.ltheme -text [tr WoodpeckerTheme]
    set themes [list [tr WoodpeckerThemeMix]]
    if {[info exists ::lichess_puzzles::themeNames]} { lappend themes {*}$::lichess_puzzles::themeNames }
    ttk::combobox $f.lich.theme -state readonly -width 28 -values $themes -textvariable ${v}::newCfg(theme)
    ttk::label $f.lich.lcolor -text [tr WoodpeckerColor]
    ttk::frame $f.lich.color
    foreach c {both white black} {
        ttk::radiobutton $f.lich.color.$c -text [tr WoodpeckerColor_$c] -variable ${v}::newCfg(color) -value $c
        pack $f.lich.color.$c -side left -padx {0 8}
    }
    ttk::label $f.lich.ltoken -text [tr WoodpeckerToken]
    ttk::entry $f.lich.token -textvariable ${v}::newCfg(token) -show * -width 30
    set r 0
    foreach {l x} {lcount count ldiff diff {} diffhelp ltheme theme lcolor color ltoken token} {
        if {$l ne ""} { grid $f.lich.$l -row $r -column 0 -sticky nw -padx {0 8} -pady 2 }
        grid $f.lich.$x -row $r -column 1 -sticky w -pady 2
        incr r
    }
    ttk::radiobutton $f.rf -text [tr WoodpeckerFromFile] -variable ${v}::newCfg(source) -value file
    ttk::frame $f.file -padding {20 0 0 0}
    ttk::entry $f.file.e -textvariable ${v}::newCfg(file) -width 36
    ttk::button $f.file.b -text "..." -width 3 -command ${v}::chooseFile
    pack $f.file.e -side left -fill x -expand 1
    pack $f.file.b -side left -padx 4
    ttk::label $f.filehelp -text [tr WoodpeckerFileHelp] -wraplength 420 -justify left -padding {20 0 0 0}
    ttk::separator $f.sep
    ttk::label $f.ldays -text [tr WoodpeckerDays1]
    ttk::spinbox $f.days -from 1 -to 120 -width 5 -textvariable ${v}::newCfg(days1)
    ttk::label $f.lrest -text [tr WoodpeckerRestDays]
    ttk::spinbox $f.rest -from 0 -to 14 -width 5 -textvariable ${v}::newCfg(restDays)
    ttk::label $f.dayshelp -text [tr WoodpeckerDaysHelp] -wraplength 420 -justify left
    grid $f.lname $f.name -sticky w -pady 3
    grid $f.rl - -sticky w -pady {8 2}
    grid $f.lich - -sticky w
    grid $f.rf - -sticky w -pady {8 2}
    grid $f.file - -sticky ew
    grid $f.filehelp - -sticky w
    grid $f.sep - -sticky ew -pady 8
    grid $f.ldays $f.days -sticky w -pady 2
    grid $f.lrest $f.rest -sticky w -pady 2
    grid $f.dayshelp - -sticky w -pady 2
    ttk::frame $d.b -padding {10 0 10 10}
    ttk::button $d.b.ok -text [tr WoodpeckerCreate] -command ${v}::create
    ttk::button $d.b.cancel -text $::tr(Cancel) -command [list destroy $d]
    pack $d.b.cancel $d.b.ok -side right -padx 4
    pack $d.b -fill x
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
        set shares [dict create]
        foreach lv $::woodpecker::set::LEVELS {
            if {[string is double -strict $newCfg($lv)] && $newCfg($lv) > 0} { dict set shares $lv $newCfg($lv) }
        }
        if {![dict size $shares] || $newCfg(count) < 1} {
            tk_messageBox -icon error -parent $d -message [tr WoodpeckerNoDifficulty]
            return
        }
        set ::woodpecker::ui::lastCount $newCfg(count)
        set spec [dict create count $newCfg(count) shares $shares angle [themeKey $newCfg(theme)] \
            color $newCfg(color) token [string trim $newCfg(token)]]
        dict set meta shares $shares
        dict set meta angle [dict get $spec angle]
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

# A new set: say what was built and offer the evaluation (plan 7, user's rule:
# no annotations -> strongly recommended; some -> complete or overwrite).
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
# Evaluating a set (plan 7)

# `mode`: all | missing | ask. With ask, the dialog follows the user's rule:
#   no annotations       -> the evaluation is strongly recommended
#   some annotated       -> complete with the review, or overwrite everything
#   all annotated        -> the review is optional: overwrite or keep
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

# A small modal choice; returns the key of the button pressed.
proc ::woodpecker::ui::choice {message buttons} {
    set d .woodpeckerChoice
    catch { destroy $d }
    win::createDialog $d
    ::setTitle $d [tr WoodpeckerTitle]
    set ::woodpecker::ui::choiceAns cancel
    ttk::label $d.m -text $message -wraplength 380 -justify left -padding 12
    ttk::frame $d.b -padding {10 0 10 10}
    foreach {key label} $buttons {
        ttk::button $d.b.$key -text $label -command [list set ::woodpecker::ui::choiceAns $key]
        pack $d.b.$key -side left -padx 4
    }
    pack $d.m -fill x
    pack $d.b -fill x
    wm protocol $d WM_DELETE_WINDOW { set ::woodpecker::ui::choiceAns cancel }
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

proc ::woodpecker::ui::train {} {
    variable run
    variable w
    variable keysBound
    variable txt
    set dir [current]
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
    lassign [::woodpecker::readLog $dir] xs ss
    set session 0
    foreach x $xs { if {[dict get $x session] > $session} { set session [dict get $x session] } }
    foreach s $ss { if {[dict get $s session] > $session} { set session [dict get $s session] } }
    set marks [::woodpecker::readMarks $dir]
    array unset run
    array set run [list on 1 dir $dir exs $exs n [dict size $exs] cycle [dict get $dp cycle] \
        next [dict get $dp next] session [expr {$session + 1}] quota [dict get $dp quota] \
        doneToday0 [dict get $dp doneToday] doneToday [dict get $dp doneToday] \
        deadline [dict get $dp deadline] doneCycle [expr {[dict get $dp next] - 1}] \
        table [::woodpecker::marksAt $marks [::woodpecker::marksLatest $marks]] \
        t0 [clock milliseconds] start $now paused 0 pausedMs 0 pauseT 0 lastInput [clock milliseconds] \
        wait "" ex 0 state {} exT0 0 exPaused 0 pending "" results {} streak 0 points 0.0 max 0.0 \
        prevBase [sc_base current] cycleDays [::woodpecker::cycleDays [dict get $dp cycle] \
            [expr {[dict exists [dict get $dp meta] days1] ? [dict get [dict get $dp meta] days1] : 28}]] \
        xs $xs]
    # The session plays in a database of its own, in memory: the game open in
    # any base is left exactly as it is. (sc_game push/pop keeps one slot per
    # base, which other windows also use, so it cannot hold a game for a
    # whole session.)
    if {[catch { sc_base create MEMORY "Woodpecker" } mem]} {
        array set run {on 0}
        tk_messageBox -icon error -parent $w -message [T WoodpeckerNoSlot $mem]
        return
    }
    set run(memBase) $mem
    ::file::SwitchToBase $mem
    # An engine window that follows the board would show the solution.
    set run(engines) [pauseEngines]
    if {!$keysBound} {
        bind MainBoardKeys <Return> {+::woodpecker::ui::keyContinue}
        bind MainBoardKeys <space> {+::woodpecker::ui::keyContinue}
        set keysBound 1
    }
    ::setPlayMode ::woodpecker::ui::callback
    showPage sess
    $w.sess.b.pause configure -text [tr WoodpeckerPause]
    set notes {}
    foreach l [lrange [dict get $dp lines] 2 end] { lappend notes $l }
    set unrated 0
    dict for {ex e} $exs { if {![dict exists $run(table) $ex]} { incr unrated } }
    if {$unrated} { lappend notes [T WoodpeckerUnratedShort $unrated] }
    set txt(notice) [join $notes "\n"]
    card {}
    verdict ""
    statsLine
    tick
    nextExercise
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
    bar $w.sess.today $run(doneToday) $run(quota)
    bar $w.sess.cyc $run(doneCycle) $run(n)
    if {$run(wait) eq "ask" && !$run(paused) \
            && [clock milliseconds] - $run(lastInput) > $::woodpecker::P(idleMs)} {
        pause 1
    }
    after 500 ::woodpecker::ui::tick
}

# A progress bar: blue up to the target, orange for what goes beyond it.
proc ::woodpecker::ui::bar {c done target} {
    if {![winfo exists $c]} { return }
    $c delete all
    set cw [winfo width $c]
    set ch [winfo height $c]
    set total [expr {double(max($target, $done, 1))}]
    set xt [expr {$cw * $target / $total}]
    $c create rectangle 0 0 [expr {$cw * min($done, $target) / $total}] $ch -fill "#4a90d9" -outline ""
    if {$done > $target} {
        $c create rectangle $xt 0 [expr {$cw * $done / $total}] $ch -fill "#f5a623" -outline ""
    }
    if {$target > 0} { $c create line $xt 0 $xt $ch -fill black -width 2 }
}

proc ::woodpecker::ui::statsLine {} {
    variable run
    variable txt
    set txt(today) [T WoodpeckerTodayBar $run(doneToday) $run(quota)]
    set txt(cycle) [T WoodpeckerCycleBar $run(cycle) $run(doneCycle) $run(n) $run(deadline)]
    set done [llength $run(results)]
    set pct [expr {$run(max) > 0 ? 100.0 * $run(points) / $run(max) : 0.0}]
    set txt(stats) [T WoodpeckerStatsLine $run(streak) [num $run(points)] [pct $pct]]
    # Pace: this session's average against the target (the previous cycle's
    # time halved, spread over the set), when there is a previous cycle.
    set txt(pace) ""
    if {$done} {
        set avg [expr {[sumMs] / 1000.0 / $done}]
        set target [targetPace]
        if {$target ne ""} {
            set txt(pace) [T WoodpeckerPace [format %.0f $avg] [format %.0f $target]]
        } else {
            set txt(pace) [T WoodpeckerPaceFirst [format %.0f $avg]]
        }
    }
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

proc ::woodpecker::ui::attemptsText {} {
    variable run
    if {$run(state) eq ""} { return "" }
    set left [expr {2 - [dict get $run(state) errors]}]
    return [string repeat "●" $left][string repeat "○" [expr {2 - $left}]]
}

# The next exercise of the cycle, or the end of the cycle.
proc ::woodpecker::ui::nextExercise {} {
    variable run
    variable txt
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
    set txt(title) [T WoodpeckerExercise $ex $run(n) [tr [expr {$side eq "w" ? "WoodpeckerWhiteToMove" : "WoodpeckerBlackToMove"}]] \
        [expr {$rating ne "" ? " · $rating" : ""}]]
    set txt(attempts) [attemptsText]
    status [tr WoodpeckerYourMove]
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
    set ::woodpecker::ui::txt(attempts) [attemptsText]
    if {$correct} {
        set run(pending) $what
        set run(wait) move
        return 0
    }
    verdict ko
    catch { ::utils::sound::PlaySound sound_alert }
    if {$what eq "retry"} {
        status [tr WoodpeckerWrong]
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
    ::notify::PosChanged -pgn -animate
    set run(lastInput) [clock milliseconds]
    set run(wait) ask
    status [tr WoodpeckerYourMove]
}

# One exercise is over: score it, write it down, then the next one.
proc ::woodpecker::ui::exerciseDone {result} {
    variable run
    variable txt
    if {!$run(on)} { return }
    set ex $run(ex)
    set ms [expr {[clock milliseconds] - $run(exT0) - $run(exPaused)}]
    set ms [expr {max(0, $ms)}]
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
    # What the card shows: the result, the points, and the line with its marks.
    set head [dict get {clean WoodpeckerSolved second WoodpeckerSolvedSecond failed WoodpeckerFailed} $result]
    set parts [list "[tr $head]  " [expr {$result eq "failed" ? "bad" : "good"}] \
        [T WoodpeckerPoints [num [dict get $s points]] [num [dict get $s max]]] {}]
    set line ""
    catch { set line [::woodpecker::lineText $run(fen) $run(solution) $marks] }
    if {$line ne ""} { lappend parts "\n$line" move }
    if {![llength $marks]} { lappend parts "\n[tr WoodpeckerNoMarks]" {} }
    if {$run(doneToday) == $run(quota) && $run(quota) > 0} { lappend parts "\n\n[tr WoodpeckerQuotaDone]" good }
    card $parts
    if {$result eq "failed"} {
        showSolution
        return
    }
    set run(wait) next
    after 900 ::woodpecker::ui::advance
}

proc ::woodpecker::ui::advance {} {
    variable run
    if {!$run(on) || $run(wait) ne "next"} { return }
    nextExercise
}

# After a failure the rest of the solution goes on the board, with its marks,
# and can be stepped through; Enter goes on.
proc ::woodpecker::ui::showSolution {} {
    variable run
    set idx [dict get $run(state) idx]
    set marks {}
    if {[dict exists $run(table) $run(ex)]} { set marks [dict get $run(table) $run(ex) marks] }
    set i 0
    foreach uci [lrange $run(solution) [expr {2 * $idx}] end] {
        if {[catch { sc_move addSan $uci }]} { break }
        set solver [expr {(2 * $idx + $i) % 2 == 0}]
        if {$solver} {
            set m [lindex $marks [expr {($idx * 2 + $i) / 2}]]
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
        if {$run(wait) eq "ask"} { status [tr WoodpeckerYourMove] }
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

proc ::woodpecker::ui::card {parts} {
    variable w
    set t $w.sess.card
    if {![winfo exists $t]} { return }
    $t configure -state normal
    $t delete 1.0 end
    foreach {text tag} $parts { $t insert end $text $tag }
    $t configure -state disabled
}

proc ::woodpecker::ui::verdict {kind} {
    variable w
    variable txt
    after cancel {::woodpecker::ui::verdict ""}
    if {![winfo exists $w.sess.top.verdict]} { return }
    lassign [dict get {ok {"✓" #2e9d2e} ko {"✗" #d32f2f} "" {{} {}}} $kind] sym color
    set txt(verdict) $sym
    $w.sess.top.verdict configure -background [expr {$color eq "" ? [neutral] : $color}] -foreground white
    if {$kind ne ""} { after 500 {::woodpecker::ui::verdict ""} }
}

# The session ends: the record sheet row, the summary, and the board back as
# it was. `why`: "" (the trainee stopped) or cycle (the set is done).
proc ::woodpecker::ui::finish {{why ""}} {
    variable run
    if {!$run(on)} { return }
    set dur [elapsedMs]
    set done [llength $run(results)]
    if {$done} {
        ::woodpecker::logSession $run(dir) [clock seconds] $run(cycle) $run(session) $run(start) $dur
    }
    set summary [summaryParts $why $dur]
    stop
    showPage sum
    summary $summary
}

proc ::woodpecker::ui::summaryParts {why dur} {
    variable run
    set done [llength $run(results)]
    set parts [list "[tr WoodpeckerSessionOver]\n" title]
    if {$why eq "cycle"} { lappend parts "[T WoodpeckerCycleComplete $run(cycle)]\n" head }
    set c [dict create clean 0 second 0 failed 0]
    set failed {}
    foreach r $run(results) {
        dict incr c [dict get $r result]
        if {[dict get $r result] eq "failed"} { lappend failed [dict get $r ex] }
    }
    set pct [expr {$run(max) > 0 ? 100.0 * $run(points) / $run(max) : 0.0}]
    lappend parts "\n" {} \
        "[T WoodpeckerSumDate [clock format $run(start) -format {%Y-%m-%d %H:%M}]]\n" {} \
        "[T WoodpeckerSumDuration [::woodpecker::fmtDuration $dur]]\n" {} \
        "[T WoodpeckerSumExercises $done]\n" {} \
        "[T WoodpeckerSumPoints [num $run(points)] [num $run(max)] [pct $pct]]\n" head \
        "[T WoodpeckerSumResults [dict get $c clean] [dict get $c second] [dict get $c failed]]\n" {}
    if {$done} {
        lappend parts "[T WoodpeckerSumAvg [format %.0f [expr {[sumMs] / 1000.0 / $done}]]]\n" {}
    }
    set ok [expr {$run(doneToday) >= $run(quota)}]
    lappend parts "\n[T WoodpeckerSumQuota $run(doneToday) $run(quota)]" [expr {$ok ? "head" : ""}] \
        [expr {$ok ? "  ✓\n" : "\n"}] {} \
        "[T WoodpeckerCycleBar $run(cycle) $run(doneCycle) $run(n) $run(deadline)]\n" {}
    if {$run(cycle) > 1 && $done} {
        set cmp [::woodpecker::compareCycles $run(xs) $run(cycle) [lmap r $run(results) { dict get $r ex }]]
        if {[dict get $cmp compared]} {
            lappend parts "\n[T WoodpeckerSumCompare [dict get $cmp faster] [dict get $cmp slower] \
                [dict get $cmp fixed] [dict get $cmp newErrors]]\n" {}
        }
    }
    if {[llength $failed]} {
        lappend parts "\n[T WoodpeckerSumReview [join $failed {, }]]\n" {}
    }
    return $parts
}

proc ::woodpecker::ui::summary {parts} {
    variable w
    set t $w.sum.t
    if {![winfo exists $t]} { return }
    $t configure -state normal
    $t delete 1.0 end
    foreach {text tag} $parts { $t insert end $text $tag }
    $t configure -state disabled
}

# Leave the session and put the board and the open game back.
proc ::woodpecker::ui::stop {} {
    variable run
    if {!$run(on)} { return }
    set run(on) 0
    after cancel ::woodpecker::ui::tick
    after cancel ::woodpecker::ui::advance
    after cancel {::woodpecker::ui::verdict ""}
    clearArrows
    if {[info exists ::playMode] && $::playMode eq "::woodpecker::ui::callback"} { ::setPlayMode "" }
    ::board::flipAuto .main.board
    if {[catch {sc_base switch $run(prevBase)}]} { sc_base switch $::clipbase_db }
    set ::curr_db [sc_base current]
    if {[info exists run(memBase)]} { catch { sc_base close $run(memBase) } }
    ::notify::GameChanged
    ::notify::DatabaseChanged
    if {[info exists run(engines)]} { resumeEngines $run(engines) }
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
    set dir [current]
    if {$dir eq ""} { return }
    set d .woodpeckerStats
    catch { destroy $d }
    toplevel $d
    ::setTitle $d "[tr WoodpeckerStats]: [dict get [::woodpecker::readMeta $dir] name]"
    set exs [::woodpecker::readExercises $dir]
    lassign [::woodpecker::readLog $dir] xs ss
    set marks [::woodpecker::readMarks $dir]
    set ver [::woodpecker::marksLatest $marks]
    set table [::woodpecker::marksAt $marks $ver]
    set sessions [::woodpecker::sessionStats $xs $ss $exs $table]
    set cycles [::woodpecker::cycleStats $xs $exs $table]

    ttk::label $d.lc -text [tr WoodpeckerCyclesTitle] -font font_Bold -padding {10 8 10 2}
    canvas $d.chart -width 520 -height 170 -background white -highlightthickness 0
    ttk::treeview $d.cyc -columns {cycle days time ex res pct} -show headings -height 4
    foreach {c tag w} {cycle WoodpeckerColCycle 50 days WoodpeckerColDays 170 time WoodpeckerColTime 80 \
            ex WoodpeckerColExercises 70 res WoodpeckerColResults 110 pct WoodpeckerColPct 60} {
        $d.cyc heading $c -text [tr $tag]
        $d.cyc column $c -width $w -anchor center
    }
    foreach c $cycles {
        $d.cyc insert {} end -values [list [dict get $c cycle] "[dict get $c start] → [dict get $c end]" \
            [::woodpecker::fmtDuration [dict get $c ms]] [dict get $c exercises] \
            "[dict get $c clean]/[dict get $c second]/[dict get $c failed]" [pct [dict get $c pct]]]
    }
    ttk::label $d.ls -text [tr WoodpeckerSessionsTitle] -font font_Bold -padding {10 8 10 2}
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
    ttk::label $d.note -text [T WoodpeckerStatsNote $ver] -wraplength 520 -justify left -padding 10
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
    after idle [list ::woodpecker::ui::chart $d.chart $cycles]
}

# Bars: each cycle's solving time, with the target (the previous cycle halved)
# as a line; the percentage of points above each bar.
proc ::woodpecker::ui::chart {c cycles} {
    if {![winfo exists $c]} { return }
    $c delete all
    set W [winfo reqwidth $c]
    set H [winfo reqheight $c]
    if {![llength $cycles]} {
        $c create text [expr {$W / 2}] [expr {$H / 2}] -text [tr WoodpeckerNoData] -fill "#777777"
        return
    }
    set maxMs 1
    foreach cy $cycles { set maxMs [expr {max($maxMs, [dict get $cy ms])}] }
    set n [llength $cycles]
    set slot [expr {($W - 40.0) / max($n, 6)}]
    set base [expr {$H - 22}]
    set top 18
    set prev ""
    set i 0
    foreach cy $cycles {
        set x0 [expr {30 + $i * $slot + $slot * 0.2}]
        set x1 [expr {30 + ($i + 1) * $slot - $slot * 0.2}]
        set h [expr {($base - $top) * [dict get $cy ms] / double($maxMs)}]
        $c create rectangle $x0 [expr {$base - $h}] $x1 $base -fill "#4a90d9" -outline ""
        $c create text [expr {($x0 + $x1) / 2}] [expr {$base + 10}] -text [dict get $cy cycle] -font font_Small
        $c create text [expr {($x0 + $x1) / 2}] [expr {$base - $h - 8}] \
            -text "[::woodpecker::fmtDuration [dict get $cy ms]] · [pct [dict get $cy pct]]" -font font_Small
        if {$prev ne ""} {
            set ht [expr {($base - $top) * $prev / 2.0 / $maxMs}]
            $c create line [expr {$x0 - 4}] [expr {$base - $ht}] [expr {$x1 + 4}] [expr {$base - $ht}] \
                -fill "#f5a623" -width 2 -dash {4 2}
        }
        set prev [dict get $cy ms]
        incr i
    }
    $c create line 28 $base [expr {$W - 8}] $base -fill "#999999"
    $c create text [expr {$W - 10}] 8 -anchor ne -text [tr WoodpeckerChartLegend] -font font_Small -fill "#555555"
}
