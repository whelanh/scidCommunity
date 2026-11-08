###
### search/comments.tcl: Search the comments of games in the current filter.
###

namespace eval ::search::comments {
    variable win .searchCommentsWin
    variable hits
    array set hits {}
}

# ::search::comments::Open
#   Opens (or raises) the Search Comments window.
#
proc ::search::comments::Open {} {
    variable win

    if {[winfo exists $win]} {
        wm deiconify $win
        raise $win
        focus $win.top.text
        return
    }

    toplevel $win
    wm title $win "scidCommunity: [tr SearchComments]"
    wm minsize $win 640 360

    ttk::frame $win.top -padding 6
    pack $win.top -side top -fill x
    ttk::label $win.top.label -text "[tr Search]:"
    ttk::entry $win.top.text -width 40
    ttk::button $win.top.search -text [tr Search] \
        -command ::search::comments::Search
    ttk::button $win.top.copy -text "Copy" \
        -command ::search::comments::Copy
    ttk::button $win.top.close -text [tr Close] \
        -command [list destroy $win]
    pack $win.top.label -side left
    pack $win.top.text -side left -fill x -expand 1 -padx 4
    pack $win.top.search -side left
    pack $win.top.copy -side left -padx 2
    pack $win.top.close -side left -padx 4
    ::utils::tooltip::Set $win.top.copy \
        "Copy Game, White, Black and Move as tab-separated text"

    ttk::label $win.status -text "" -anchor w -padding {6 0}
    pack $win.status -side top -fill x

    ttk::frame $win.results -padding 6
    pack $win.results -side top -fill both -expand 1
    ttk::treeview $win.results.tv -columns {game white black move comment} \
        -show headings -selectmode browse
    set tv $win.results.tv
    $tv heading game -text "Game"
    $tv column game -width 55 -anchor w
    $tv heading white -text [tr White]
    $tv column white -width 130 -anchor w
    $tv heading black -text [tr Black]
    $tv column black -width 130 -anchor w
    $tv heading move -text "Move"
    $tv column move -width 90 -anchor w
    $tv heading comment -text [tr Comment]
    $tv column comment -width 330 -anchor w
    ttk::scrollbar $win.results.ys -orient vertical \
        -command [list $win.results.tv yview]
    ttk::scrollbar $win.results.xs -orient horizontal \
        -command [list $win.results.tv xview]
    $win.results.tv configure -yscrollcommand [list $win.results.ys set] \
        -xscrollcommand [list $win.results.xs set]
    grid $win.results.tv -row 0 -column 0 -sticky nsew
    grid $win.results.ys -row 0 -column 1 -sticky ns
    grid $win.results.xs -row 1 -column 0 -sticky ew
    grid rowconfigure $win.results 0 -weight 1
    grid columnconfigure $win.results 0 -weight 1

    bind $win.top.text <Return> ::search::comments::Search
    bind $win.top.text <Escape> [list destroy $win]
    bind $win.results.tv <Double-1> ::search::comments::Jump
    bind $win.results.tv <Return> ::search::comments::Jump
    bind $win.results.tv "<$::COMMAND-c>" ::search::comments::Copy
    bind $win <Escape> [list destroy $win]

    if {[catch { lassign [sc_filter sizes [sc_base current] dbfilter] n }]} {
        $win.status configure -text "No database is open."
    } else {
        $win.status configure -text "Searching in the current filter ($n games)."
    }
    focus $win.top.text
}

# ::search::comments::Search
#   Runs the comment search and fills the result list.
#
proc ::search::comments::Search {} {
    variable win
    variable hits

    set text [$win.top.text get]
    if {[string trim $text] eq ""} {
        tk_messageBox -parent $win -title "scidCommunity" -type ok -icon info \
            -message "Enter the text to search for."
        return
    }

    busyCursor .
    $win.top.search configure -state disabled
    progressWindow "scidCommunity" "Searching comments..." [tr Cancel]
    set err [catch { sc_search comments $text dbfilter } raw]
    closeProgressWindow
    unbusyCursor .
    # The dialog may have been closed while the search was running.
    if {![winfo exists $win]} { return }
    $win.top.search configure -state normal
    if {$err} {
        if {$::errorCode ne $::ERROR::UserCancel} { ERROR::MessageBox }
        return
    }

    array unset hits
    set tv $win.results.tv
    $tv delete [$tv children {}]
    set n 0
    foreach {g offset ply counter white black move comment} $raw {
        incr n
        if {$ply == 0} {
            set movetxt "start"
        } else {
            # counter is the absolute half-move count, so games with a FEN
            # start are numbered from the FEN's move number, not from 1.
            set moveno [expr {($counter + 1) / 2}]
            set dots [expr {$counter % 2 ? "." : "..."}]
            set movetxt "$moveno$dots $move"
        }
        set snippet [string map {"\n" " " "\r" " "} $comment]
        if {[string length $snippet] > 120} {
            set snippet "[string range $snippet 0 117]..."
        }
        set iid [$tv insert {} end \
            -values [list $g $white $black $movetxt $snippet]]
        set hits($iid) [list $g $offset]
    }

    $win.status configure -text \
        "$n matching comment[expr {$n == 1 ? {} : {s}}]."
    if {$n > 0} {
        set first [lindex [$tv children {}] 0]
        $tv selection set $first
        $tv focus $first
        $tv see $first
    }
}

# ::search::comments::Copy
#   Copies the Game, White, Black and Move columns of the selected result,
#   separated by tabs, so they can be pasted into a spreadsheet or another
#   program.
#
proc ::search::comments::Copy {} {
    variable win

    set tv $win.results.tv
    set iid [$tv focus]
    if {$iid eq ""} { set iid [lindex [$tv selection] 0] }
    if {$iid eq ""} { return }

    lassign [$tv item $iid -values] game white black move
    ::utils::setClipboardText [join [list $game $white $black $move] \t]
    $win.status configure -text \
        "Copied Game, White, Black and Move to the clipboard."
}

# ::search::comments::Jump
#   Loads the game of the selected result and moves to the matching position.
#
proc ::search::comments::Jump {} {
    variable win
    variable hits

    set tv $win.results.tv
    set iid [$tv focus]
    if {$iid eq "" || ![info exists hits($iid)]} { return }
    lassign $hits($iid) g offset

    if {[::game::ConfirmDiscard] == 0} { return }
    if {[catch {
        sc_game load $g
        ::notify::GameChanged
        # PGN offsets address main-line and variation positions alike.
        sc_move pgn $offset
        ::notify::PosChanged -pgn
    } err]} {
        set ::errorInfo $err
        ERROR::MessageBox
    }
}

# ----------------------------------------------------------------------
# End of file: comments.tcl
# ----------------------------------------------------------------------
