# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_progress_ui.tcl -- the review progress window.
#
# One toplevel, built on first use and withdrawn rather than destroyed, so the
# same window comes back however many runs a session has. It draws from the job
# ::reviewprogress keeps and from nothing else: no game, no cursor, no clock, no
# move entry. A click on the board does nothing, because ::board::new installs
# no bindings and the canvas is taken out of the focus order - there is no path
# by which this window can fight the main board for control.
#
# Covered does not mean paused. The job is published whether or not the window
# is mapped, and <Map> forces a full redraw from the last FEN, so a reader who
# comes back sees where the run is now rather than where it was when they
# covered it.

namespace eval ::reviewprogress::ui {
    variable win .reviewProgress
    # The board widget, named once so a redraw cannot pick up the wrong one.
    variable board $win.board.bd
    variable psize 40
}

proc ::reviewprogress::ui::title {} {
    return "scidCommunity: [tr ReviewProgressTitle]"
}

# Build the window. Only ever called once.
proc ::reviewprogress::ui::build {} {
    variable win
    variable board
    variable psize

    toplevel $win
    ::setTitle $win [::reviewprogress::ui::title]
    wm withdraw $win
    wm resizable $win 0 0

    ttk::label $win.header -text {} -anchor w -font font_SmallBold
    grid $win.header -row 0 -column 0 -sticky we -padx 8 -pady {8 4}

    ttk::frame $win.board -padding 0
    grid $win.board -row 1 -column 0 -sticky news -padx 8
    # An explicit psize, never a measured width: a canvas built while the window
    # is withdrawn has no geometry to measure, and the board would come out at
    # zero and stay there.
    ::board::new $win.board.bd $psize
    # Read-only by construction: no square bindings are installed by
    # ::board::new, and the canvas is neither focusable nor a drop target.
    catch { $win.board.bd.bd configure -takefocus 0 -cursor "" }
    grid $win.board.bd -row 0 -column 0 -sticky news

    ttk::label $win.progress -text {} -anchor w -font font_Small
    grid $win.progress -row 2 -column 0 -sticky we -padx 8 -pady {6 8}

    ttk::button $win.cancel -text [tr Cancel] \
        -command ::reviewprogress::ui::cancel
    grid $win.cancel -row 3 -column 0 -sticky e -padx 8 -pady {0 8}

    # Closing the window cancels nothing: the board is decoration over a run,
    # and the run's own Cancel is the only thing that stops it.
    wm protocol $win WM_DELETE_WINDOW ::reviewprogress::ui::hide
    bind $win <Escape> ::reviewprogress::ui::hide
    # Coming back to a covered board: draw the run as it is now.
    bind $win <Map> ::reviewprogress::ui::redraw

    ::reviewprogress::setPainter ::reviewprogress::ui::draw
    return $win
}

proc ::reviewprogress::ui::exists {} {
    variable win
    return [winfo exists $win]
}

# Show the window, building it if this is the first run of the session. With no
# run in flight it shows the position on the main board, which is what a reader
# who opened it to see "where is it now" is asking for.
proc ::reviewprogress::ui::show {} {
    variable win
    variable board
    if {![::reviewprogress::ui::exists]} { ::reviewprogress::ui::build }
    set job [::reviewprogress::job]
    if {![dict size $job]} {
        catch { ::reviewprogress::ui::idle }
    }
    catch { wm deiconify $win }
    catch { raise $win }
    ::reviewprogress::ui::redraw
    return $win
}

proc ::reviewprogress::ui::hide {} {
    variable win
    catch { wm withdraw $win }
    return
}

# Nothing is running: name the state rather than leaving the last run's header
# over a board that is not being searched.
proc ::reviewprogress::ui::idle {} {
    variable win
    variable board
    if {![::reviewprogress::ui::exists]} { return }
    catch { $win.header configure -text [tr ReviewProgressTitle] }
    catch { $win.progress configure -text [tr ReviewProgressIdle] }
    set boardString ""
    catch { set boardString [::reviewprogress::positionToBoard [sc_pos fen]] }
    if {$boardString ne ""} {
        catch { ::board::update $board 0 $boardString }
    }
    return
}

# The painter ::reviewprogress calls. It reads the job's fields and nothing
# else: the header is the string the run composed at its start, so a run that
# outlives its window's engine choice still says what it was asked to do.
proc ::reviewprogress::ui::draw {job} {
    variable win
    variable board
    if {![::reviewprogress::ui::exists]} {
        # A run started with the window closed still gets a window: the board is
        # what the reader asked for, and opening it later must not be needed to
        # have it up to date.
        catch { ::reviewprogress::ui::build }
    }
    set header ""
    catch { set header [dict get $job header] }
    catch { $win.header configure -text $header }
    catch { $win.progress configure -text [::reviewprogress::progressText $job] }
    set boardString ""
    catch { set boardString [dict get $job board] }
    if {$boardString ne ""} {
        catch { ::board::update $board $boardString 0 }
    }
    return
}

# Draw the job as it stands. Called when the window is uncovered: the run kept
# publishing while it was covered, and this is what makes that visible.
proc ::reviewprogress::ui::redraw {} {
    variable win
    variable board
    if {![::reviewprogress::ui::exists]} { return }
    set job [::reviewprogress::job]
    if {[dict size $job]} {
        ::reviewprogress::ui::draw $job
    } else {
        ::reviewprogress::ui::idle
    }
    return
}

# The run's Cancel, not the window's. Closing the board leaves the run alone;
# this button is the one the reader means when they say stop.
proc ::reviewprogress::ui::cancel {} {
    catch { ::reviewdriver::cancel }
    ::reviewprogress::ui::redraw
    return
}
