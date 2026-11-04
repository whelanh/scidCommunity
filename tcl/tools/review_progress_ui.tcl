# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_progress_ui.tcl -- the review progress pane.
#
# A docked pane, not a window of its own: it is registered with the
# application's docking layer (::docking::create_window in tcl/utils/win.tcl)
# and built into the frame that layer creates, exactly as .commentWin is. The
# dock owns its visibility - a hidden pane is a tab that is not selected - and
# the dock may destroy and rebuild it at any time (tab closed, undock, layout
# restore), so the job ::reviewprogress keeps is the only state. The pane draws
# from that job and from nothing else: no game, no cursor, no clock, no move
# entry. A click on the board does nothing, because ::board::new installs no
# bindings and the canvas is taken out of the focus order - there is no path by
# which this pane can fight the main board for control.
#
# Hidden does not mean paused. The job is published whether or not the tab is
# selected, and <Map> forces a full redraw from the last position, so a reader
# who comes back sees where the run is now rather than where it was.

namespace eval ::reviewprogress::ui {
    variable win .reviewProgress
    # The board's base path, which is what ::board::new and ::board::update
    # take; its canvas is $board.bd.
    variable board $win.board
    variable psize 40
}

proc ::reviewprogress::ui::title {} {
    return [tr ReviewProgressTitle]
}

# True while there is a pane to paint. The docking layer destroys the frame
# when the reader closes the tab; a run keeps publishing afterwards and must
# not be surprised by it.
proc ::reviewprogress::ui::exists {} {
    variable win
    variable board
    return [expr {[winfo exists $win] && [winfo exists $board]}]
}

# Build the pane's content into the window the dock made. Called once per
# window: a pane that is closed and reopened gets a fresh frame and is built
# again, then repainted from the job.
proc ::reviewprogress::ui::build {} {
    variable win
    variable board
    variable psize

    if {[winfo exists $board]} { return $win }
    if {![winfo exists $win]} { return "" }

    # The ttk widgets inside follow the theme, but the frame the dock creates is
    # a classic Tk widget and keeps Tk's grey. The pane's padding and the strip
    # around Cancel are that frame, so on every dark theme it stayed light grey.
    # Paint it with the theme's background and repaint it when the theme changes.
    catch { ::applyThemeColor_background $win }

    # ::board::new takes a path that does NOT exist yet: it refuses a widget
    # that already exists, creates the frame itself with -class Board (which is
    # where the board styling comes from), creates the canvas $w.bd inside it
    # and grids that canvas. Handing it a frame this proc had already made was
    # the bug that kept the old window invisible: the guard returned, $w.bd was
    # never created and the grid raised into a caller's catch.
    ::board::new $board $psize
    # Read-only by construction: no square bindings are installed by
    # ::board::new, and the canvas is neither focusable nor a drop target.
    catch { $board.bd configure -takefocus 0 -cursor "" }

    ttk::label $win.header -text [::reviewprogress::ui::title] -anchor w \
        -font font_SmallBold
    ttk::label $win.progress -text "" -anchor w -font font_Small

    # The determinate bar (#422 item 3). Its value is ::reviewui::passFraction
    # of the driver's own counts and nothing else, so the bar and the status
    # line cannot disagree; "" (no total) leaves the bar at zero rather than
    # inventing a percentage.
    ttk::progressbar $win.bar -mode determinate -maximum 1 -value 0

    # The coach's own measure (#422). The search bar is full by the time the
    # model starts, so prose needs a bar of its own; it is hidden until a run
    # reports prose counts, because most runs have no model behind them.
    ttk::label $win.coach -text "" -anchor w -font font_Small
    ttk::progressbar $win.coachbar -mode determinate -maximum 1 -value 0

    ttk::button $win.cancel -text [tr Cancel] -state disabled \
        -command ::reviewprogress::ui::cancel

    grid $win.header -row 0 -column 0 -sticky we -padx 8 -pady {8 4}
    grid $board -row 1 -column 0 -sticky news -padx 8
    grid $win.progress -row 2 -column 0 -sticky we -padx 8 -pady {6 0}
    grid $win.bar -row 3 -column 0 -sticky we -padx 8 -pady {2 8}
    grid $win.coach -row 4 -column 0 -sticky we -padx 8 -pady {6 0}
    grid $win.coachbar -row 5 -column 0 -sticky we -padx 8 -pady {2 8}
    grid $win.cancel -row 6 -column 0 -sticky e -padx 8 -pady {0 8}
    grid remove $win.coach $win.coachbar
    # The board takes the space: a pane that does not grow with the dock is a
    # board the reader cannot see.
    grid rowconfigure $win 1 -weight 1
    grid columnconfigure $win 0 -weight 1

    # Coming back to a hidden tab: draw the run as it is now.
    bind $win <Map> ::reviewprogress::ui::redraw

    ::reviewprogress::setPainter ::reviewprogress::ui::draw
    return $win
}

# Open the pane: create it through the dock on first use, then show it where
# the dock put it. This is the whole of "invokable at any time" - the Windows
# menu and the engine window's review status line both call it.
proc ::reviewprogress::ui::open {} {
    variable win

    if {![winfo exists $win]} {
        if {[catch {
            ::win::createWindow $win [::reviewprogress::ui::title] 420x560
        } err]} {
            puts stderr "scidCommunity: the review progress pane could not be created: $err"
            return ""
        }
    }
    if {![winfo exists $win]} { return "" }

    # A build that fails is reported rather than swallowed: the window that
    # never appeared because a catch hid a bad board path is why.
    if {[catch { ::reviewprogress::ui::build } err]} {
        puts stderr "scidCommunity: the review progress pane could not be built: $err"
        return ""
    }
    catch { ::win::makeVisible $win }
    ::reviewprogress::ui::redraw
    return $win
}

# Nothing is running: name the state rather than leaving the last run's header
# over a board that is not being searched.
proc ::reviewprogress::ui::idle {} {
    variable win
    variable board
    if {![::reviewprogress::ui::exists]} { return }
    catch { $win.header configure -text [tr ReviewProgressTitle] }
    catch { $win.progress configure -text [tr ReviewProgressIdle] }
    catch { $win.bar configure -value 0 }
    catch { $win.coach configure -text "" }
    catch { $win.coachbar configure -value 0 }
    catch { grid remove $win.coach $win.coachbar }
    catch { $win.cancel configure -state disabled }
    set boardString ""
    catch { set boardString [::reviewprogress::positionToBoard [sc_pos fen]] }
    if {$boardString ne ""} {
        # (w, board, animate): the board string is the second argument, not the
        # first. Passing it third put it in the animate slot and the idle board
        # never drew at all.
        catch { ::board::update $board $boardString 0 }
    }
    return
}

# Draw a position on the pane's board. Gloss of Danger is a main-board
# overlay: it asks `sc_pos attacks`, which belongs to the reader's position, not
# this job's. Turn it off for the duration of the draw and put it back.
proc ::reviewprogress::ui::paintBoard {boardString} {
    variable board
    set gloss 0
    catch { set gloss $::glossOfDanger }
    if {$gloss} { catch { set ::glossOfDanger 0 } }
    catch { ::board::update $board $boardString 0 }
    if {$gloss} { catch { set ::glossOfDanger 1 } }
    return
}

# The painter ::reviewprogress calls. It reads the job's fields and nothing
# else: the header is the string the run composed at its start, so a run that
# outlives its window's engine choice still says what it was asked to do.
#
# A missing pane is not an error and never a rebuild: the reader closed the
# tab, the run carries on, and opening the pane again reads the job.
proc ::reviewprogress::ui::draw {job} {
    variable win
    variable board
    if {![::reviewprogress::ui::exists]} { return }
    # A finished run leaves no job. The painter is called with it, so this is
    # where the pane falls back to saying so rather than freezing on the last
    # position of a pass that is over.
    if {![dict size $job]} { ::reviewprogress::ui::idle ; return }
    set header ""
    catch { set header [dict get $job header] }
    if {$header eq ""} { set header [::reviewprogress::ui::title] }
    catch { $win.header configure -text $header }
    catch { $win.progress configure -text [::reviewprogress::progressText $job] }
    # The bar reads the same counts as the line, through the one progress source
    # (#422): ::reviewui::passFraction. A job with no total leaves it at zero.
    set done ""
    set total ""
    catch { set done [dict get $job done] }
    catch { set total [dict get $job total] }
    set fraction ""
    catch { set fraction [::reviewui::passFraction $done $total] }
    if {$fraction eq ""} { set fraction 0 }
    catch { $win.bar configure -value $fraction }

    # The coach's queue, when this run has one. Its line names both measures,
    # exactly as the engine window's status line does, so the pane and the
    # corner cannot disagree.
    set coachDone ""
    set coachTotal ""
    catch { set coachDone [dict get $job coachDone] }
    catch { set coachTotal [dict get $job coachTotal] }
    if {$coachDone ne "" && [string is integer -strict $coachTotal] \
            && $coachTotal >= 1} {
        set searchDone $done
        if {$searchDone eq ""} { set searchDone 0 }
        set searchTotal $total
        if {$searchTotal eq ""} { set searchTotal 0 }
        catch { $win.coach configure -text [format [tr ReviewCoachProgress] \
            $searchDone $searchTotal $coachDone $coachTotal] }
        set coachFraction ""
        catch { set coachFraction [::reviewui::passFraction $coachDone $coachTotal] }
        if {$coachFraction eq ""} { set coachFraction 0 }
        catch { $win.coachbar configure -value $coachFraction }
        catch { grid $win.coach -row 4 -column 0 -sticky we -padx 8 -pady {6 0} }
        catch { grid $win.coachbar -row 5 -column 0 -sticky we -padx 8 -pady {2 8} }
    } else {
        catch { grid remove $win.coach $win.coachbar }
    }

    # The pane serves every run, so Cancel belongs to the run that owns the
    # board, not to the review driver: a batch, Rapid Annotate or Finish Game
    # has its own stop.
    set cancel ""
    catch { set cancel [dict get $job cancel] }
    catch { $win.cancel configure -state [expr {$cancel eq "" ? "disabled" : "normal"}] }

    set boardString ""
    catch { set boardString [dict get $job board] }
    if {$boardString ne ""} {
        ::reviewprogress::ui::paintBoard $boardString
    } elseif {[dict get $job done] eq ""} {
        # A new run has no position yet. Clear the previous run's board rather
        # than leaving it under the new header; a blank board is honest until
        # the first search arrives.
        ::reviewprogress::ui::paintBoard [string repeat . 64]
    }
    return
}

# Draw the job as it stands. Called when the pane is mapped again: the run kept
# publishing while the tab was hidden, and this is what makes that visible.
proc ::reviewprogress::ui::redraw {} {
    if {![::reviewprogress::ui::exists]} { return }
    set job [::reviewprogress::job]
    if {[dict size $job]} {
        ::reviewprogress::ui::draw $job
    } else {
        ::reviewprogress::ui::idle
    }
    return
}

# The run's Cancel, not the pane's. Closing the tab leaves the run alone; this
# button is the one the reader means when they say stop.
proc ::reviewprogress::ui::cancel {} {
    set job [::reviewprogress::job]
    set cancel ""
    catch { set cancel [dict get $job cancel] }
    if {$cancel ne ""} { catch { {*}$cancel } }
    ::reviewprogress::ui::redraw
    return
}
