# Copyright (C) 1999-2004 Shane Hudson
# Copyright (C) 2006-2009 Pascal Georges
# Copyright (C) 2008-2011 Alexander Wagner
# Copyright (C) 2013-2016 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid.  If not, see <http://www.gnu.org/licenses/>.

###
### main.tcl: Routines for creating and updating the main window.
###

############################################################
# Keyboard move entry:
#   Handles letters, digits and BackSpace/Delete keys.
#   Note that king- and queen-side castling moves are denoted
#   "OK" and "OQ" respectively.
#   The letters n, r, q, k, o and l are promoted to uppercase
#   automatically. A "b" can match to a b-pawn or Bishop move,
#   so in some rare cases, a capital B may be needed for the
#   Bishop move to distinguish it from the pawn move.

set moveEntry(Text) ""
set moveEntry(List) {}

proc moveEntry_Clear {} {
    global moveEntry
    set moveEntry(Text) ""
    set moveEntry(List) {}
}

proc moveEntry_Complete {} {
    lassign $::moveEntry(List) move
    if {$move eq ""} { return 0 }

    if {$move == "OK"} { set move "O-O" }
    if {$move == "OQ"} { set move "O-O-O" }
    moveEntry_Clear
    return [addSanMove [::untrans $move]]
}

proc moveEntry_Backspace {} {
    global moveEntry
    set moveEntry(Text) [string range $moveEntry(Text) 0 \
            [expr {[string length $moveEntry(Text)] - 2}]]
    moveEntry_Char ""
}

proc moveEntry_Char {ch} {
    global moveEntry
    set oldMoveText $moveEntry(Text)
    set oldMoveList $moveEntry(List)
    append moveEntry(Text) $ch
    set moveEntry(List) [lmap move [sc_pos moves $moveEntry(Coord)] {
        # Translate and remove any occurrence of "x", "=", "+", or "#"
        set move [string map [list "x" "" "=" "" "+" "" "#" ""] [::trans $move]]
        # Replace castling moves
        switch -- $move {
            "O-O" { set move "OK" }
            "O-O-O" { set move "OQ" }
        }
        # Add the move if it matches the prefix
        if {[string match -nocase "$moveEntry(Text)*" $move]} {
            # Add extra sub-elements for sorting the list
            set exact_prefix_len [strPrefixLen $moveEntry(Text) $move]
            list [expr {$exact_prefix_len * -1}] [string length $move] $move
        } else {
            continue
        }
    }]
    # Sort the moves list (and remove the extra sub-elements)
    set moveEntry(List) [lmap elem [lsort $moveEntry(List)] { lindex $elem 2 }]
    # Add the null move if it is valid
    if {$moveEntry(Text) in [list "-" "--"] && ![catch {sc_game SANtoUCI "--"}]} {
        lappend moveEntry(List) "--"
    }
    set len [llength $moveEntry(List)]
    lassign $moveEntry(List) move move2
    if {$len == 2 && [string equal -nocase $move $move2]} {
        # Check for the special case where the user has entered a b-pawn
        # capture that clashes with a Bishop move (e.g. bxc4 and Bxc4):
        set len 1
    }
    if {$len == 0} {
        # No matching moves, so do not accept this character as input:
        set moveEntry(Text) $oldMoveText
        set moveEntry(List) $oldMoveList
    } elseif {$len == 1} {
        # Exactly one matching move, so make it if AutoExpand is on,
        # or if it equals the move entered. Note the comparison is
        # case insensitive to allow for 'b' to match both pawn and
        # Bishop moves.
        if {$moveEntry(AutoExpand) || [string equal -nocase $moveEntry(Text) $move]} {
            return [moveEntry_Complete]
        }
    }
    updateStatusBar
    return $len
}

# updateMainGame:
#   Updates the main board with games's info
#
proc updateMainGame {} {
    global gamePlayers
    set gamePlayers(nameW)  [sc_game info white]
    set gamePlayers(nameB)  [sc_game info black]
    set eloW                [sc_game info welo]
    set gamePlayers(eloW)   [expr {$eloW == 0 ? "" : "($eloW)"}]
    set eloB                [sc_game info belo]
    set gamePlayers(eloB)   [expr {$eloB == 0 ? "" : "($eloB)"}]
    set gamePlayers(clockW) ""
    set gamePlayers(clockB) ""
    set gamePlayers(movetime) ""
}

# updateTitle:
#   Updates the main Scid window title.
#
proc updateTitle {} {
    set title "ScidCommunity - "
    set fname [sc_base filename $::curr_db]
    set fname [file tail $fname]
    append title "$fname ($::tr(game) "
    append title "[::utils::thousands [sc_game number]] / "
    append title "[::utils::thousands [sc_base numGames $::curr_db]])"
    ::setTitle . $title
    set white [sc_game info white]
    set black [sc_game info black]
    if {[string length $white] > 2 &&  [string length $black] > 2} {
        if {$fname == {[clipbase]} } { set fname clipbase }
        set altered ""
        if {[sc_game altered]} { set altered "*" }
        ::setTitle .main "ScidCommunity - ($fname$altered): $white -- $black"
    } else {
        ::setTitle .main "ScidCommunity - $title"
    }
}

# updateStatusBar:
#   Updates the main Scid window status bar.
#
proc updateStatusBar {} {
    if {! [winfo exists .main]} { return }

    if {$::menuHelpMessage != ""} {
        ::board::setInfoAlert .main.board "[tr Help]:" "$::menuHelpMessage" "black" ""
        return
    }

    if {$::autoplayMode == 1} {
        ::board::setInfoAlert .main.board "Autoplay:" [tr Stop] "red" "cancelAutoplay"
        return
    }

    if {[info exists ::playMode]} {
        set pInfo [eval "$::playMode info"]
        if {[llength $pInfo] != 4} {
            ::board::setInfoAlert .main.board "Playing..." [tr Stop] "red" {{*}$::playMode stop}
        } else {
            ::board::setInfoAlert .main.board {*}pInfo
        }
        return
    }

    # show [%clk] command (if we are not playing)
    set toMove  [sc_pos side]
    set comment [sc_pos getComment]
    set evalScore [getScorefromComment $comment 10]
    if {$evalScore ne "" || ![info exists ::mainEvalBarEngineID_]} {
        ::board::updateEvalBar .main.board $evalScore
    }
    if { ![gameclock::isRunning] } {
        set ::gamePlayers(clockW) ""
        set ::gamePlayers(clockB) ""
        set ::gamePlayers(movetime) ""
        set clkExp {.*?\[%clk\s*(.*?)\s*\].*}
        lassign [sc_pos getPrevComment] prevCom movetime
        regexp $clkExp $comment -> ::gamePlayers(clockW)
        regexp $clkExp $prevCom -> ::gamePlayers(clockB)
        regexp $clkExp $movetime -> movetime
        catch {
            set movetime [expr {
                [clock scan $movetime -format {%H:%M:%S}] - \
                [clock scan $::gamePlayers(clockW) -format {%H:%M:%S}] }]
            set ::gamePlayers(movetime) [format_clock_from_seconds $movetime]
        }
        if {$toMove == "white"} {
            set temp_swap $::gamePlayers(clockW)
            set ::gamePlayers(clockW) $::gamePlayers(clockB)
            set ::gamePlayers(clockB) $temp_swap
        }
        set ::gamePlayers(clockW) [format_clock $::gamePlayers(clockW)]
        set ::gamePlayers(clockB) [format_clock $::gamePlayers(clockB)]
    }

    if {[info exists ::guessedAddMove]} {
        set ::gameLastMove [lindex $::guessedAddMove 1]
        ::board::setInfoAlert .main.board [lindex $::guessedAddMove 0] "\[click to change\]" "DodgerBlue3" ".main.menuaddchoice"
        unset ::guessedAddMove
        return
    }

    global moveEntry
    if {$moveEntry(Text) != ""} {
        set msg "\[ $moveEntry(Text) \]  "
        foreach thisMove $moveEntry(List) {
            append msg "$thisMove "
        }
        ::board::setInfoAlert .main.board "Enter Move:" "$msg" "DodgerBlue3" ""
        return
    }

    # remove technical comments, notify only human readable ones
    regsub -all {\[%.*?\]} $comment {} comment

    set statusBar ""
    set move [sc_game info previousMoveNT]
    if {$move != ""} {
      regsub {K} $move "\u2654" move
      regsub {Q} $move "\u2655" move
      regsub {R} $move "\u2656" move
      regsub {B} $move "\u2657" move
      regsub {N} $move "\u2658" move
      set number "[sc_pos moveNumber]"
      if {$toMove == "white"} {
        incr number -1
        append number ".."
      }
      append statusBar [tr LastMove]
      if {[sc_var level] != 0} { append statusBar " (var)" }
      append statusBar ": $number.$move"
      set statusBar [list $statusBar {}]
      if {$::gamePlayers(movetime) ne ""} {
        lappend statusBar "    \u23F1 $::gamePlayers(movetime)" header
      }
      ::board::setInfo .main.board $statusBar
    } else {
      set msg "[sc_game info date] - [sc_game info event]"
      ::board::setInfoAlert .main.board "[tr Event]:" $msg "DodgerBlue3" "::crosstab::Open"
    }
    set eco [sc_game info ECO]
    ::board::addInfo .main.board $eco
    if {$comment != ""} {
        set headermsg ""
        # If this is the first move, or both movetime and eco are empty,
        # show only the comment.
        if {$move eq "" || ($::gamePlayers(movetime) eq "" && $eco eq "")} {
            set headermsg "[tr Comment]"
        }
        ::board::setInfoAlert .main.board $headermsg "$comment" "green" "::makeCommentWin"
    }
}

proc updateMainToolbar {} {
  if {[sc_pos isAt start]} {
    ::board::setButtonCmd .main.board leavevar ""
    ::board::setButtonCmd .main.board back ""
    unset -nocomplain ::gameInfoBar(tb_BD_Start)
  } else {
    ::board::setButtonCmd .main.board leavevar "::move::ExitVarOrStart"
    ::board::setButtonCmd .main.board back "::move::Back"
    set ::gameInfoBar(tb_BD_Start) "::move::Start"
  }
  if {[sc_pos isAt end] || [sc_pos isAt vend]} {
    ::board::setButtonCmd .main.board forward ""
    ::board::setButtonCmd .main.board endvar ""
    unset -nocomplain ::gameInfoBar(tb_BD_End)
    unset -nocomplain ::gameInfoBar(tb_BD_Autoplay)
  } else {
    ::board::setButtonCmd .main.board forward "::move::Forward"
    ::board::setButtonCmd .main.board endvar "::move::EndVar"
    set ::gameInfoBar(tb_BD_End) "::move::End"
    set ::gameInfoBar(tb_BD_Autoplay) "startAutoplay"
  }

  if {[sc_var level] == 0} {
    unset -nocomplain ::gameInfoBar(tb_BD_VarDelete)
    unset -nocomplain ::gameInfoBar(tb_BD_VarPromote)
    unset -nocomplain ::gameInfoBar(tb_BD_VarLeave)
    unset -nocomplain ::gameInfoBar(tb_BD_BackToMainline)
    ::board::setButtonImg .main.board leavevar ::icon::tb_start
  } else {
    set ::gameInfoBar(tb_BD_VarDelete) { ::pgn::deleteVar }
    set ::gameInfoBar(tb_BD_VarPromote) { ::pgn::mainVar }
    set ::gameInfoBar(tb_BD_VarLeave) { ::move::ExitVar }
    set ::gameInfoBar(tb_BD_BackToMainline) { while {[sc_var level] != 0} {::move::ExitVar} }
    ::board::setButtonImg .main.board leavevar ::icon::tb_up
  }

  set ::gameInfoBar(tb_BD_SetupBoard) "setupBoard"
  set ::gameInfoBar(tb_BD_SelectMarker) "::selectMarker"
}

# Update the "tree" filter of databases that have a view (gamelist or tree windows)
# which depends on the current position.
proc ::updateTreeFilter {{base ""}} {
    if { [info exists ::treeFilterUpdating_] } {
        set ::treeFilterUpdating_ {}
        ::progressBarCancel
        return
    }

    set ::treeFilterUpdating_ {}
    set ::treeFilterUpdatingBases_ [::windows::gamelist::listTreeBases $base]
    lappend ::treeFilterUpdatingBases_ {*}[::tree::listTreeBases $base]
    foreach elem [lsort -unique -index 0 $::treeFilterUpdatingBases_] {
        lassign $elem base filter progressbar

        set ::treeFilterUpdating_ [lsearch -all -inline -exact -index 0 $::treeFilterUpdatingBases_ $base]
        if { [llength $::treeFilterUpdating_] == 0 } {
            # canceled while updating another base
            continue
        }

        #TODO: don't do a full database search if there is only one filter.
        #set n_filters [llength [lsort -unique -index 1 $::treeFilterUpdating_]]

        eval progressBarSet $progressbar
        set err [catch {sc_filter search $base "tree" board}]
        if {$err && $::errorCode != $::ERROR::UserCancel} {
            ERROR::MessageBox
        }
        if { [llength $::treeFilterUpdating_] == 0 } {
            # Restart if the position changed before the update finished.
            after idle {
                unset ::treeFilterUpdating_
                ::updateTreeFilter
            }
            return
        }
        ::notify::filter $base tree
    }
    unset ::treeFilterUpdating_
}

proc ::cancelUpdateTreeFilter {progressbar} {
    if {![info exists ::treeFilterUpdating_]} {
        return
    }
    set idx [lsearch -exact -index 2 $::treeFilterUpdating_ $progressbar]
    if {$idx != -1} {
        if {[llength $::treeFilterUpdating_] == 1} {
            ::progressBarCancel
        } else {
            set ::treeFilterUpdating_ [lreplace $::treeFilterUpdating_ $idx $idx]
        }
    } else {
        set idx [lsearch -exact -index 2 $::treeFilterUpdatingBases_ $progressbar]
        if {$idx != -1} {
            set ::treeFilterUpdatingBases_ [lreplace $::treeFilterUpdatingBases_ $idx $idx]
        }
    }
}

# Update the main eval bar to reflect the engine's evaluation.
# If there is only one engine running, il will show that evaluation in the bar.
# If there are multiple engines running, the eval bar will remain associated
# with the first engine that send its evaluation until it stops running.
proc ::updateMainEvalBar {engineID bestmove evaluation {pvlines {}}} {
    if {! $::showEvalBar(.main) || ![winfo exists .main.board]} { return }

    if {![info exists ::mainEvalBarEngineID_]} {
        set ::mainEvalBarEngineID_ $engineID
    }
    if {$engineID == $::mainEvalBarEngineID_} {
        ::board::updateEvalBar .main.board $evaluation
        if {$::showMainEvalBarArrow && $::arrowLastMove} {
            # Convert all PV moves to UCI format
            set uciMoves {}
            set lineCount 0
            foreach move $pvlines {
                # If showEngineVariationArrows is disabled, only show the best move (first line)
                if {!$::showEngineVariationArrows && $lineCount >= 1} { break }
                set cleanMove [string map {"\u2654" K "\u2655" Q "\u2656" R "\u2657" B "\u2658" N} [::untrans $move]]
                if {[catch { sc_game SANtoUCI $cleanMove } moveUCI] == 0 && $moveUCI ne ""} {
                    lappend uciMoves $moveUCI
                }
                incr lineCount
            }
            ::board::mark::DrawMultipleBestMoves .main.board $uciMoves
        }
        if {$bestmove eq "" && $evaluation eq ""} {
            unset ::mainEvalBarEngineID_
        }
    }
}

# Create a menu containing:
# - the engine currently associated with the evaluation bar
# - engines open in enginewin windows
# - the configured engines that can be started
# - a command to add a new local engine
# - a command to show/hide the best move arrow
# - the command to hide the evaluation bar
# Behavior:
# - if the currently associated engine is selected, stop it
# - if a different engine is selected, stop the current engine and start the new one.
# Returns the name of the created menu.
proc ::createMainEvalBarMenu {w} {
    if {[winfo exists $w.evalbar_menu]} { destroy $w.evalbar_menu }
    menu $w.evalbar_menu

    set engines {}
    set enginewins [enginewin::listEngines]
    foreach {elem} $enginewins {
        lassign $elem engID engName running
        if {!$running} {
            lappend engines [list $engID $engName]
            continue
        }
        if {[info exists ::mainEvalBarEngineID_] && $engID == $::mainEvalBarEngineID_} {
            set ::mainEvalBarCheckbutton 1
            $w.evalbar_menu add checkbutton -variable ::mainEvalBarCheckbutton -label $engName -command {
                ::enginewin::stop $::mainEvalBarEngineID_
            }
        } else {
            $w.evalbar_menu add command -label $engName \
                -command "set ::mainEvalBarEngineID_ \[::enginewin::start $engID\]"
        }
    }
    foreach {engName} [enginecfg::names] {
        if {[lsearch -exact -index 1 $enginewins $engName] == -1} {
            lappend engines [list "" $engName]
        }
    }
    $w.evalbar_menu add separator
    foreach {elem} $engines {
        lassign $elem engID engName
        $w.evalbar_menu add command -label $engName -command [list apply {{engID engName} {
            if {[info exists ::mainEvalBarEngineID_]} {
                ::enginewin::stop $::mainEvalBarEngineID_
            }
            set ::mainEvalBarEngineID_ [::enginewin::start $engID $engName]
        }} $engID $engName]
    }

    $w.evalbar_menu add command -label [tr NewLocalEngine] -command {
        set newEngName [::enginecfg::dlgNewLocal]
        if {$newEngName ne ""} {
            ::enginewin::start "" $newEngName
        }
    }
    $w.evalbar_menu add separator
    $w.evalbar_menu add checkbutton -variable ::showMainEvalBarArrow -label [tr BestMoveArrow] -command {
        ::board::mark::DrawMultipleBestMoves ".main.board" {}
    }
    $w.evalbar_menu add separator
    $w.evalbar_menu add command -label [tr Hide] \
        -command { {*}$::gameInfoBar(tb_BD_Scorebar) }

    return $w.evalbar_menu
}

proc toggleRotateBoard {} {
    ::board::flip .main.board
}
proc main_isFlipped {} {
    tailcall ::board::isFlipped .main.board
}




############################################################
### The board:

proc toggleShowMaterial {} {
    board::toggleMaterial .main.board
}

# MouseWheel in main window:
proc main_mousewheelHandler {direction} {
    if {$direction < 0} {
        ::move::Back
    } else {
        ::move::Forward
    }
}

################################################################################
# added by Pascal Georges
# returns a list of num moves from main line following current position
################################################################################
proc getNextMoves { {num 4} } {
    set tmp ""
    set count 0
    while { [sc_game info nextMove] != "" && $count < $num} {
        append tmp " [sc_game info nextMove]"
        sc_move forward
        incr count
    }
    sc_move back $count
    return $tmp
}
################################################################################
# displays a box with main line and variations for easy selection with keyboard
################################################################################
proc showVars {} {
    if {$::autoplayMode == 1} { return }

    set numVars [sc_var count]
    # No need to display an empty menu
    if {$numVars == 0} { return }

    set prev_focus [focus]
    set w .variations
    destroy $w

    # Present a non-blocking popup of the possible variations
    toplevel $w
    wm overrideredirect $w 1
    set h [expr $numVars + 1]
    if { $h> 19} { set h 19 }
    ttk::treeview $w.lbVar -columns {0} -show {} -selectmode browse
    $w.lbVar configure -height $h
    $w.lbVar column 0 -width 250
    pack $w.lbVar -side left -fill both -expand 1

    #insert main line
    set move [sc_game info nextMove]
    set j 0
    if {$move == ""} {
        set move "($::tr(empty))"
    } else  {
        $w.lbVar insert {} end -id $j -values [list "0: [getNextMoves 5]"]
        incr j
    }

    # insert variations
    set varList [sc_var list]
    for {set i 0} {$i < $numVars} {incr i} {
        set move [::trans [lindex $varList $i]]
        if {$move == ""} {
            set move "($::tr(empty))"
        } else  {
            sc_var moveInto $i
            append move [getNextMoves 5]
            sc_var exit
        }
        set str "[expr {$i + 1}]: $move"
        $w.lbVar insert {} end -id $j -values [list "$str"]
        incr j
    }

    bind $w <FocusOut>        [list destroy $w]
    bind $w <Escape>          [list focus $prev_focus]
    bind $w <Left>            [list focus $prev_focus]
    bind $w <Return>          [list focus $prev_focus]
    bind $w <Return>          {+::move::EnterVar [%W selection]}
    bind $w <Right>           {event generate %W <Return> -when tail}
    bind $w <ButtonRelease-1> {event generate %W <Return> -when tail}

    ::tk::PlaceWindow $w widget .main.board
    focus $w.lbVar
    $w.lbVar focus 0
    $w.lbVar selection set 0
}
################################################################################
#
################################################################################

# updateBoard:
#    Updates the main board.
#    If a parameter "-pgn" is specified, the PGN text is also regenerated.
#    If a parameter "-animate" is specified, board changes are animated.
#
proc updateBoard {args} {
    ::notify::PosChanged {*}$args
}


# updateGameInfo:
#    Update the game status window .main.gameInfo
#
proc updateGameInfo {} {
    global gameInfo

    .main.gameInfo.text configure -state normal
    .main.gameInfo.text delete 0.0 end
    ::htext::display .main.gameInfo.text [sc_game info -hide $gameInfo(hideNextMove) \
            -material $gameInfo(showMaterial) \
            -cfull $gameInfo(fullComment) \
            -fen $gameInfo(showFEN)]
    if {$gameInfo(wrap)} {
        .main.gameInfo.text configure -wrap word
        .main.gameInfo.text tag configure wrap -lmargin2 10
        .main.gameInfo.text tag add wrap 1.0 end
    } else {
        .main.gameInfo.text configure -wrap none
    }
    .main.gameInfo.text configure -state disabled
    togglePhotosSize 0
}

set photosMinimized 0
proc togglePhotosSize {{toggle 1}} {
    place forget .main.photoW
    place forget .main.photoB
    if {! $::gameInfo(photos)} { return }

    updatePlayerPhotos
    if {$toggle} { set ::photosMinimized [expr !$::photosMinimized] }

    set distance [expr {[image width photoB] + 2}]
    if { $distance < 10 } { set distance 82 }

    if {$::photosMinimized} {
        place .main.photoW -in .main.gameInfo.text -x -17 -relx 1.0 -relheight 0.15 -width 15 -anchor ne
        place .main.photoB -in .main.gameInfo.text -x -1 -relx 1.0  -relheight 0.15 -width 15 -anchor ne
    } else  {
        place .main.photoW -in .main.gameInfo.text -x -$distance -relx 1.0 -relheight 1 -width [image width photoW] -anchor ne
        place .main.photoB -in .main.gameInfo.text -x -1 -relx 1.0 -relheight 1 -width [image width photoB] -anchor ne
    }
}


# readPhotoFile executed once at startup for each SPF file. Loads SPI file if it exists.
# Otherwise it generates index information and tries to write SPI file to disk (if it can be done)
proc readPhotoFile {fname} {
    set count 0
    set writespi 0

    if {! [regsub {\.spf$} $fname {.spi} spi]} {
        # How does it happend?
        return
    }

    # If SPI file was found then just source it and exit
    if { [file readable $spi]} {
        set count [array size ::unsafe::spffile]
        safeSource $spi fname $fname
        set newcount [array size ::unsafe::spffile]
        if {[expr $newcount - $count] > 0} {
            ::splash::add "Found [expr $newcount - $count] player photos in [file tail $fname]"
            ::splash::add "Loading information from index file [file tail $spi]"
            return [expr $newcount - $count]
        } else {
            set count 0
        }
    }

    # Check for the absence of the SPI file and check for the write permissions
    if { ![file exists $spi] && ![catch {open $spi w} fd_spi]} {
        # SPI file will be written to disk by scid
        set writespi 1
    }

    if {! [file readable $fname]} { return }

    set fd [open $fname]
    while {[gets $fd line] >= 0} {
        # search for the string      photo "Player Name"
        if { [regexp {^photo \"(.*)\" \{$} $line -> name] } {
            set count [expr $count + 1 ]
            set begin [tell $fd]
            # skip data block
            while {1} {
                set end [tell $fd]
                gets $fd line
                if {[regexp {.*\}.*} $line ]} {break}
            }
            set trimname [trimString $name]
            set size [expr $end - $begin ]
            set ::unsafe::photobegin($trimname) $begin
            set ::unsafe::photosize($trimname) $size
            set ::unsafe::spffile($trimname) $fname
            if { $writespi } {
                # writing SPI file to disk
                puts $fd_spi "set \"photobegin($trimname)\" $begin"
                puts $fd_spi "set \"photosize($trimname)\" $size"
                puts $fd_spi "set \"spffile($trimname)\" \"\$fname\""
            }
        }
    }
    if {$count > 0 && $writespi} {
        ::splash::add "Found $count player photos in [file tail $fname]"
        ::splash::add "Index file [file tail $spi] was generated succesfully"
    }
    if {$count > 0 && !$writespi} {
        ::splash::add "Found $count player photos in [file tail $fname]"
        ::splash::add "Could not generate index file [file tail $spi]"
        ::splash::add "Use spf2spi script to generate [file tail $spi] file "
    }

    if { $writespi } { close $fd_spi }
    close $fd
    return $count
}


#convert $data string tolower case and strip the first two blanks.
# Normalize a player name for photo lookup
# Converts to lowercase, removes spaces, and strips diacritical marks
# Examples:
#   "Carlsen, Magnus" -> "carlsen,magnus"
#   "carlsen, magnus" -> "carlsen,magnus"
#   "Kasparov, Garry" -> "kasparov,garry"
#   "Lékó, Peter" -> "leko,peter"
#   "Grischuk, Alexander" -> "grischuk,alexander"
proc normalizePhotoName {name} {
    # Convert to lowercase
    set name [string tolower $name]
    
    # Remove ALL spaces (not just first two)
    regsub -all { } $name {} name
    
    # Convert common accented/diacritical characters to ASCII equivalents
    # This handles most European chess player names
    array set charmap {
        à a á a â a ã a ä a å a ā a
        è e é e ê e ë e ē e
        ì i í i î i ï i ī i
        ò o ó o ô o õ o ö o ø o ō o
        ù u ú u û u ü u ū u
        ý y ÿ y
        ç c ć c ĉ c č c
        ð d đ d
        ĝ g ğ g
        ĥ h
        ĵ j
        ķ k
        ł l
        ñ n ń n ň n
        ř r
        ś s ŝ s š s
        ţ t ț t ť t
        ź z ż z
        ß ss
        æ ae
        œ ae
        а a б b в v г g д d е e ё yo
        ж zh з z и i й y к k л l м m н n о o п p р r
        с s т t у u ф f х kh ц ts ч ch ш sh щ shch
        ъ y ы y ь y э e ю yu я ya
    }
    
    set result {}
    for {set i 0} {$i < [string length $name]} {incr i} {
        set c [string index $name $i]
        if {[info exists charmap($c)]} {
            append result $charmap($c)
        } else {
            append result $c
        }
    }
    set name $result
    
    return $name
}

# Old function kept for backwards compatibility
proc trimString {data} {
    return [normalizePhotoName $data]
}


# retrieve photo from the SPF file using index information
proc getphoto {name} {
    set data ""
    if {[info exists ::unsafe::spffile($name)]} {
        set fd [open $::unsafe::spffile($name)]
        seek $fd $::unsafe::photobegin($name) start
        set data [read $fd $::unsafe::photosize($name) ]
        close $fd
    }
    return $data
}


# Array to store custom photo filenames (indexed by normalized player name)
array set customPhoto {}

# List of {globpattern filepath} pairs for wildcard custom photo matching.
# Populated by loadCustomPhotos for any image filename containing parentheses.
set customPhotoWild {}

proc loadCustomPhotos {} {
    # Load custom photos from the user-configured photo directory.
    # Supports: .gif and .png files (JPEG often not supported by Tcl/Tk)
    # Recommended size: 80x80 to 200x200 pixels (larger images may display too big)
    #
    # Two filename conventions are supported:
    #
    # 1. Exact match (no parentheses in filename):
    #       "Carlsen, Magnus.png"  ->  normalized and stored in ::customPhoto array
    #       "Smith.png"         ->  normalized and stored in ::customPhoto array
    #    The name is normalized (lowercase, accents stripped, spaces removed) before
    #    lookup, so "Carlsen, Magnus.png" matches a player named "Carlsen, Magnus".
    #
    # 2. Wildcard match (parentheses present in filename):
    #    Parentheses act as wildcards (each () pair becomes * in the match pattern),
    #    allowing flexible matching against the raw player name. This syntax is used
    #    because "*" is illegal in filenames on Windows.
    #
    #       "(stockfish).png"      ->  matches any player name containing "stockfish"
    #                                  (pattern: *stockfish*)
    #       "Smith().png"       ->  matches any player name starting with "Smith"
    #                                  (pattern: smith*)
    #       "()Stockfish().png"    ->  same as (stockfish).png, more explicit
    #                                  (pattern: *stockfish*)
    #
    #    Patterns are matched case-insensitively against the raw player name as it
    #    appears in the game header (e.g., "Stockfish 17", "stockfish_elo3500").
    #
    # Priority: exact match wins over wildcard. Among wildcards, first file found wins.

    if {![info exists ::scidPhotoDir] || ![file isdirectory $::scidPhotoDir]} {
        return 0
    }

    set count 0
    set pwd [pwd]

    if {[catch {cd $::scidPhotoDir}]} {
        return 0
    }

    # Reset wildcard list on each load so stale entries don't accumulate
    set ::customPhotoWild {}

    # Search for image files with supported extensions (GIF and PNG only)
    foreach pattern {*.gif *.png} {
        foreach imgfile [glob -nocomplain $pattern] {
            set playername [file rootname $imgfile]

            # Test that the image file is valid by trying to create a temp photo
            if {[catch {image create photo _tmpPhoto -file $imgfile} result]} {
                continue
            }
            image delete _tmpPhoto

            set abspath [file normalize $imgfile]

            if {[string first "(" $playername] != -1} {
                # Wildcard filename: translate parentheses into * wildcards.
                # "(" and ")" each become "*", then collapse any "**" runs.
                set globpat [string tolower $playername]
                set globpat [string map {"(" "*" ")" "*"} $globpat]
                while {[string first "**" $globpat] != -1} {
                    set globpat [string map {"**" "*"} $globpat]
                }
                lappend ::customPhotoWild [list $globpat $abspath]
            } else {
                # Exact match: normalize as usual (handles accents, case, spaces)
                set key [normalizePhotoName $playername]
                set ::customPhoto($key) $abspath
            }
            incr count
        }
    }

    cd $pwd

    return $count
}

proc loadPlayersPhoto {} {
  set ::gamePlayers(photoW) {}
  set ::gamePlayers(photoB) {}
  image create photo photoW
  image create photo photoB

  # Directories where Scid searches for the photo files
  set photodirs [list $::scidDataDir $::scidUserDir $::scidConfigDir [file join $::scidShareDir "photos"]]
  if {[info exists ::scidPhotoDir]} { lappend photodirs $::scidPhotoDir }

  # Read all Scid photo (*.spf) files in the Scid data/user/config directories:
  set nImg 0
  set nFiles 0
  foreach dir $photodirs {
      foreach photofile [glob -nocomplain -directory $dir "*.spf"] {
          set n [readPhotoFile $photofile]
          if {$n > 0} {
              incr nFiles
              incr nImg $n
          }
      }
  }
  
  # Load custom photos (gif, jpg, jpeg, png) from the user-configured directory
  set nCustom [loadCustomPhotos]
  incr nImg $nCustom
  incr nFiles $nCustom

  return [list $nImg $nFiles]
}
loadPlayersPhoto

# Normalizes player or game engine names by standardizing case, removing
# specific prefixes ('deep '), and eliminating excess whitespace.
# Returns:
#     A list with two elements: the normalized engine name and the spell name.
proc normalizePlayerName { engine } {
    set spelled $engine
    catch {
        set spell_name [sc_name retrievename $engine]
        if {$spell_name != ""} {
            set engine $spell_name
            set spelled $spell_name
        }
    }
    
    if { [string first "deep " $engine] == 0 } {
        # strip "deep "
        set engine [string range $engine 5 end]
    }
    # delete two first blank to make "The King" same as "TheKing"
    # or "Green Light Chess" as "Greenlightchess"
    set strindex [string first "\ " $engine]
    set engine [string replace $engine $strindex $strindex]
    set strindex [string first "\ " $engine]
    set engine [string replace $engine $strindex $strindex]
    set strindex [string first "," $engine]
    set slen [string length $engine]
    if { $strindex == -1 && $slen > 2 } {
        #seems to be a engine name:
        # search until longest name matches an engine name
        set slen [string length $engine]
        for { set strindex $slen} {![info exists ::unsafe::spffile([string range $engine 0 $strindex])]\
                    && $strindex > 2 } {set strindex [expr {$strindex - 1}] } { }
        set engine [string range $engine 0 $strindex]
    }
    
    # Apply final normalization (lowercase, remove spaces, handle accents)
    set engine [normalizePhotoName $engine]
    
    return [list $engine $spelled]
}


# updatePlayerPhotos
#   Updates the images photoW and photoB for the two players of the current game.
#   Photo lookup proceeds in priority order:
#     1. Exact custom photo match   (::customPhoto array, normalized name key)
#     2. Wildcard custom photo match (::customPhotoWild list, parentheses-derived glob)
#     3. SPF photo file fallback
#
proc updatePlayerPhotos {{force ""}} {
    foreach {name img} {nameW photoW nameB photoB} {
        set spellname $::gamePlayers($name)
        if {$::gamePlayers($img) != $spellname || $force == "-force"} {
            set ::gamePlayers($img) $spellname
            lassign [normalizePlayerName $spellname] normalized

            # 1. Exact custom photo match (existing behavior, unchanged)
            if {[info exists ::customPhoto($normalized)]} {
                image create photo $img -file $::customPhoto($normalized)

            # 2. Wildcard custom photo match (new)
            } elseif {[llength $::customPhotoWild] > 0} {
                set rawlower [string tolower $spellname]
                set matched ""
                foreach entry $::customPhotoWild {
                    lassign $entry globpat filepath
                    if {[string match $globpat $rawlower]} {
                        set matched $filepath
                        break
                    }
                }
                if {$matched ne ""} {
                    image create photo $img -file $matched
                } else {
                    set data [getphoto $normalized]
                    if {$data ne ""} {
                        image create photo $img -data $data
                    } else {
                        $img blank
                    }
                }

            # 3. SPF file fallback (existing behavior, unchanged)
            } else {
                set data [getphoto $normalized]
                if {$data ne ""} {
                    image create photo $img -data $data
                } else {
                    $img blank
                }
            }
        }
    }
}

#########################################################
### Chess move input

# Globals for mouse-based move input:

set selectedSq -1
set bestSq -1

set EMPTY 0
set KING 1
set QUEEN 2
set ROOK 3
set BISHOP 4
set KNIGHT 5
set PAWN 6

################################################################################
#
################################################################################
proc getPromoPiece {} {
    set w .promoWin
    set ::result 2
    toplevel $w
    # wm transient $w .main
    ::setTitle $w "Scid"
    wm resizable $w 0 0
    set col "w"
    if { [sc_pos side] == "black" } { set col "b" }
    ttk::button $w.bq -image ${col}q45 -command "set ::result 2 ; destroy $w"
    ttk::button $w.br -image ${col}r45 -command "set ::result 3 ; destroy $w"
    ttk::button $w.bb -image ${col}b45 -command "set ::result 4 ; destroy $w"
    ttk::button $w.bn -image ${col}n45 -command "set ::result 5 ; destroy $w"
    pack $w.bq $w.br $w.bb $w.bn -side left
    bind $w <Escape> "set ::result 2 ; destroy $w"
    bind $w <Return> "set ::result 2 ; destroy $w"
    update
    catch { grab $w }
    tkwait window $w
    return $::result
}

# TODO: remove this
# confirmReplaceMove:
#   Asks the user what to do when adding a move when a move already
#   exists.
#   Returns a string value:
#      "replace" to replace the move, truncating the game.
#      "var" to add the move as a new variation.
#      "cancel" to do nothing.
#

proc confirmReplaceMove {} {
    if {[winfo exists $::reviewgame::window]} {
        return "var"
    }

    option add *Dialog.msg.wrapLength 4i interactive
    catch {tk_dialog .dialog "Scid: $::tr(ReplaceMove)?" \
                $::tr(ReplaceMoveMessage) "" 0 \
                $::tr(ReplaceMove) $::tr(NewMainLine) \
                $::tr(AddNewVar) $::tr(Cancel)} answer
    option add *Dialog.msg.wrapLength 3i interactive
    if {$answer == 0} { return "replace" }
    if {$answer == 1} { return "mainline" }
    if {$answer == 2} { return "var" }
    return "cancel"
}

# Add a move to the current game.
# If the current position is not the end of the game, the default action is to add the move as a new variant.
# The move notation can be SAN or UCI.
# Return true if the move is both legal and has been successfully added.
proc addMoveEx {{move} {action "var"} {notify "-pgn -animate"}} {
    undoFeature save
    if {[catch {
        if {![sc_pos isAt vend]} {
            switch -- $action {
                mainline { sc_var create; set ::guessedAddMove [list "New Main Line"]}
                var      { sc_var create; set ::guessedAddMove [list "New Variation"]}
                replace  { set ::guessedAddMove [list "Replaced Main Line"]}
            }
            lappend ::guessedAddMove $move
        }

        sc_move addSan $move

        if {$action == "mainline"} {
            sc_var promote
            sc_move forward 1
        }
    }]} {
        # On error:
        undoFeature undo
        return 0
    }

    ::notify::PosChanged {*}$notify
    ::pgn::CheckRepetition
    return 1
}

proc addMove { sq1 sq2 {animate "-animate"}} {
    set moveUCI [::board::san $sq2][::board::san $sq1]
    return [addMoveUCI $moveUCI $animate]
}

# Return true if the move is legal and has been successfully added.
proc addSanMove { {san} } {
    if {[catch {sc_game SANtoUCI $san} moveUCI]} {
        return 0
    }
    return [addMoveUCI $moveUCI]
}

# addMoveUCI:
#   Adds the move indicated if it is legal.
#   If the move is a promotion, getPromoPiece will be called
#   to get the promotion piece from the user.
#   Return true if the move is legal and has been successfully added.
#
proc addMoveUCI {{moveUCI} {animate "-animate"}} {
    set sq1 [::board::sq [string range $moveUCI 0 1] ]
    set sq2 [::board::sq [string range $moveUCI 2 3] ]

    if { [string length $moveUCI] == 4 && $sq1 != $sq2 && [sc_pos isPromotion $sq1 $sq2] } {
        switch -- [getPromoPiece] {
            2 { set promoLetter "q"}
            3 { set promoLetter "r"}
            4 { set promoLetter "b"}
            5 { set promoLetter "n"}
            default {set promoLetter ""}
        }
        append moveUCI $promoLetter
    } else {
        # If it is King takes king then treat it as entering a null move:
        set board [sc_pos board]
        set k1 [string tolower [string index $board $sq1]]
        set k2 [string tolower [string index $board $sq2]]
        if {$moveUCI eq "0000" || ($k1 == "k"  &&  $k2 == "k")} { set moveUCI "null" }
    }

    if {[info exists ::playMode] && [eval "$::playMode premove {$moveUCI}"]} { return 0 } ;# not player's turn

    if { [::fics::setPremove $sq1 $sq2] || ! [::fics::playerCanMove]} { return 0 } ;# not player's turn

    if {! [::move::Follow $moveUCI] && ! [addMoveEx $moveUCI var "-pgn $animate"]} {
        return 0
    }

    # TODO: move this to fics.tcl
    if {[winfo exists .fics]} {
        if { [::fics::playerCanMove] } {
            if { [string length $moveUCI] == 5 } {
                set promoletter [ string tolower [ string index $moveUCI end ] ]
                ::fics::writechan "promote $promoletter"
            }
            ::fics::writechan [ string range [sc_game info previousMoveUCI] 0 3 ]
            ::fics::storeTime
        }
    }

    if {$::novag::connected} {
        ::novag::addMove "$moveUCI"
    }

    set san [sc_game info previous]
    after idle [list ::utils::sound::AnnounceNewMove $san]

    return 1
}

proc suggestMove {} {
    if {! $::suggestMoves} { return 0}
    if {[info exists ::playMode]} {
        return [eval "$::playMode suggestMove"]
    }
    if {$::fics::playing != 0} { return 0 }
    return 1
}

# enterSquare:
#   Called when the mouse pointer enters a board square.
#   Finds the best matching square for a move (if there is a
#   legal move to or from this square), and colors the squares
#   to indicate the suggested move.
#
proc enterSquare { square } {
    global bestSq bestcolor selectedSq
    if {$selectedSq == -1} {
        set bestSq -1
        if {[::suggestMove]} {
            set bestSq [sc_pos bestSquare $square]
            if {$bestSq != -1} {
                ::board::colorSquare .main.board $square $bestcolor
                ::board::colorSquare .main.board $bestSq $bestcolor
            }
        }
    }
}

# leaveSquare:
#    Called when the mouse pointer leaves a board square.
#    Recolors squares to normal (lite/dark) color.
#
proc leaveSquare { square } {
    global selectedSq bestSq
    if {$selectedSq == -1} {
        ::board::colorSquare .main.board $bestSq
        ::board::colorSquare .main.board $square
    }
}

# pressSquare:
#    Called when the left mouse button is pressed on a square. Sets
#    that square to be the selected square.
#
proc pressSquare { square } {
    global selectedSq highcolor

    if { ![::fics::playerCanMove] } { return } ;# not player's turn

    # if training with calculations of var is on, just log the event
    if { [winfo exists .calvarWin] } {
        ::calvar::pressSquare $square
        return
    }

    if {$selectedSq == -1} {
        set selectedSq $square
        ::board::colorSquare .main.board $square $highcolor
        # Drag this piece if it is the same color as the side to move:
        set c [string index [sc_pos side] 0]  ;# will be "w" or "b"
        set p [string index [::board::piece .main.board $square] 0] ;# "w", "b" or "e"
        if {$c == $p} {
            ::board::setDragSquare .main.board $square
        }
    } else {
        ::board::setDragSquare .main.board -1
        ::board::colorSquare .main.board $selectedSq
        ::board::colorSquare .main.board $square
        set tmp $selectedSq
        set selectedSq -1
        if {$square != $tmp} {
            addMove $square $tmp
        }
        enterSquare $square
    }
}

# releaseSquare:
#   Called when the left mouse button is released over a square.
#   If the square is different to that the button was pressed on, it
#   is a dragged move; otherwise it is just selecting this square as
#   part of a move.
#
proc releaseSquare { w x y } {
    if { [winfo exists .calvarWin] } { return }

    global selectedSq bestSq

    ::board::setDragSquare $w -1
    set square [::board::getSquare $w $x $y]
    if {$square < 0} {
        set selectedSq -1
        return
    }

    if {$square == $selectedSq} {
        if {[::suggestMove]} {
            # User pressed and released on same square, so make the
            # suggested move if there is one:
            set selectedSq -1
            ::board::colorSquare $w $bestSq
            ::board::colorSquare $w $square
            addMove $square $bestSq
            enterSquare $square
        } else {
            # Current square is the square user pressed the button on,
            # so we do nothing.
        }
    } elseif {$selectedSq != -1} {
        # User has dragged to another square, so try to add this as a move:
        set tmp $selectedSq
        set selectedSq -1
        addMove $square $tmp ""
        ::board::colorSquare $w $square
        ::board::colorSquare $w $tmp
    }
}

# addMarker:
#   add/delete square markers and arrows to the current position
#
proc addMarker {w x y} {
    set sq [::board::getSquare $w $x $y]
    if {! [info exists ::markStartSq]} {
        set ::markStartSq [::board::san $sq]
        return
    }

    set from $::markStartSq
    unset ::markStartSq
    set to [::board::san $sq]
    if {$from == "" || $to == ""} { return }

    set oldComment [sc_pos getComment]
    if { $::lichessFormat } {
        set col [string toupper [string index $::markColor 0 ]]
        if {$from == $to } {
            set cmd "%csl $col$to"
            set cmd_erase "%csl \[BGRYOC\]$to*"
        } else {
            set cmd "%cal $col$from$to"
            set cmd_erase "%cal \[BGRYOC\]$from$to"
        }
        regsub -all " *\\\[$cmd\\\]" $oldComment "" newComment
        if {$newComment == $oldComment} {
            regsub -all " *\\\[$cmd_erase\\\]" $oldComment "" newComment
            append newComment " \[$cmd\]"
        }
    } else {
        if {$from == $to } {
            set cmd "$::markType,$to,$::markColor"
            set cmd_erase "\[a-z\]*,$to,\[a-z\]*"
        } else {
            set cmd "arrow,$from,$to,$::markColor"
            set cmd_erase "arrow,$from,$to,\[a-z\]*"
        }
        regsub -all " *\\\[%draw $cmd\\\]" $oldComment "" newComment
        if {$newComment == $oldComment} {
            regsub -all " *\\\[%draw $cmd_erase\\\]" $oldComment "" newComment
            append newComment " \[%draw $cmd\]"
        }
    }

    sc_pos setComment $newComment
    ::notify::PosChanged pgnonly
}

proc selectMarker {} {
    set w_ .mainSelectMarker
    toplevel $w_
    # This small picker is a transient helper window, so tiling WMs should
    # treat it like a floating dialog instead of a normal application window.
    catch { wm transient $w_ . }
    catch { wm group $w_ . }
    catch { wm attributes $w_ -type dialog }
    if {! $::macOS } {
        wm attributes $w_ -topmost 1
    } else {
        # On macOS, TK 8.6.16, the mouse events are weird.
        # Right-clicks are sent to this window, even if they happens outside.
        # With "wm overrideredirect $w_ 1" the <Leave> message is not sent.
        bind $w_ <Leave> {
            if {[string last . %W] == 0 &&
                [string first %W [winfo containing %X %Y]] != 0} {
                destroy %W
            }
        }
    }
    lassign [winfo pointerxy .] x y
    set x [expr {max(0, $x - 20)}]
    set y [expr {max(0, $y - 40)}]
    wm geometry $w_ "+$x+$y"

    applyThemeColor_background $w_
    ttk::frame $w_.markers
    set i 0
    set lmark {
        full █
        circle ◯
        disk ⬤
        + +
        - -
        X X
        ! !
        ? ?
        = =
        A A
        B B
        C C
        D D
        E E
        F F
        0 0
        1 1
        2 2
        3 3
        4 4
        5 5
        6 6
        7 7
        8 8
        9 9
    }
    if { $::lichessFormat } { set lmark { circle ◯ } }
    foreach {marker lbl} $lmark {
        radiobutton $w_.markers.mark_$marker \
            -indicatoron "false" \
            -foreground "$::markColor" -background "light gray" -selectcolor "dark gray" \
            -text "$lbl" -width 2 \
            -variable "::markType" -value "$marker"
        grid $w_.markers.mark_$marker -row [expr {$i % 5}] -column [expr {int($i / 5)}]
        incr i
    }
    ttk::frame $w_.colors
    set i 0
    set markColors { green red orange yellow blue cyan }
    if { ! $::lichessFormat } { append markColors { purple white black gray } }
    foreach color $markColors {
        radiobutton $w_.colors.col_$color \
            -indicatoron "false" \
            -background "$color" -selectcolor "$color" \
            -text " " -width 2 \
            -variable "::markColor" -value "$color" \
            -command [list apply {{btns} {
                foreach b $btns { $b configure -foreground $::markColor }
            }} [winfo children $w_.markers] ]
        grid $w_.colors.col_$color -row [expr {$i / 2}] -column [expr {int($i % 2)}]
        incr i
    }
    grid $w_.colors $w_.markers -sticky nsew -pady 12 -padx 12
}

# addNag:
#   add a Nag to the current position
#
proc addNag {nag} {
    undoFeature save
    sc_pos addNag "$nag"
    ::notify::PosChanged pgnonly
}

################################################################################
#
################################################################################
proc undoFeature {action} {
    if {$action == "save"} {
        sc_game undoPoint
    } elseif {$action == "undo"} {
        sc_game undo
        notify::GameChanged
    } elseif {$action == "redo"} {
        sc_game redo
        notify::GameChanged
    } elseif {$action == "undoAll"} {
        sc_game undoAll
        notify::GameChanged
    }
}

proc setPlayMode { callback } {
    set ::playMode "$callback"
    if {$::playMode == ""} { unset ::playMode }
    ::notify::PosChanged
}

################################################################################
# In docked mode, resize board automatically
################################################################################
proc resizeMainBoard {} {
  if { $::autoResizeBoard } {
    update idletasks
    set availw [winfo width .main]
    set availh [winfo height .main]
    if {$::showGameInfo} {
      set availh [expr $availh - [winfo height .main.gameInfo] ]
    }
    if { [llength [pack slaves .main.tb]] != 0 } {
      set availh [expr $availh - [winfo height .main.tb] ]
    }
    set ::boardSize [::board::resizeAuto .main.board "0 0 $availw $availh"]
  }
}
################################################################################
# sets visibility of gameInfo panel at the bottom of main board
proc toggleGameInfo {} {
  if {$::showGameInfo} {
    grid .main.gameInfo -row 3 -column 0 -sticky news
  } else  {
    grid forget .main.gameInfo
  }
  updateGameInfo
}
################################################################################

proc CreateMainBoard { {w} } {
  ::win::createWindow $w [ ::tr "Board" ]

  CreateGameInfo

  ::board::new $w.board $::boardSize
  ::board::showMarks $w.board $::gameInfo(showMarks)
  ::board::coords $w.board $::boardCoords
  ::board::bindEvalBar $w.board <ButtonRelease> "
    tk_popup \[::createMainEvalBarMenu $w.board \] %X %Y
  "
  ::options.store ::showEvalBar($w) 1
  ::options.store ::showMainEvalBarArrow 1
  if {$::showEvalBar($w)} { ::board::toggleEvalBar $w.board }
  if {$::gameInfo(showMaterial)} { ::board::toggleMaterial $w.board }

  ::board::addNamesBar $w.board gamePlayers
  ::board::addInfoBar $w.board gameInfoBar

  set ::gameInfoBar(tb_BD_Material) "set ::gameInfo(showMaterial) \[::board::toggleMaterial $w.board\]"
  set ::gameInfoBar(tb_BD_Scorebar) [list apply {{w} {
    set ::showEvalBar($w) [::board::toggleEvalBar $w.board]
    unset -nocomplain ::mainEvalBarEngineID_
    ::board::updateEvalBar .main.board ""
    ::board::mark::DrawMultipleBestMoves $w.board {}
  }} $w]

  menu .main.menuaddchoice
  .main.menuaddchoice add command -label " Undo" -image tb_BD_Undo -compound left \
      -command {undoFeature undo}
  .main.menuaddchoice add command -label " $::tr(ReplaceMove)" -image tb_BD_Replace -compound left \
      -command {sc_game undo; addMoveEx $::gameLastMove replace}
  .main.menuaddchoice add command -label " $::tr(NewMainLine)" -image tb_BD_NewMainline -compound left \
      -command {sc_game undo; addMoveEx $::gameLastMove mainline}
  .main.menuaddchoice add command -label " $::tr(AddNewVar)" -image tb_BD_NewVar -compound left \
      -command {sc_game undo; addMoveEx $::gameLastMove var}

  InitToolbar .main.tb

  for {set i 0} { $i < 64 } { incr i } {
    ::board::bind $w.board $i <Enter> "enterSquare $i"
    ::board::bind $w.board $i <Leave> "leaveSquare $i"
    ::board::bind $w.board $i <ButtonPress-1> "pressSquare $i"
    ::board::bind $w.board $i <Control-ButtonPress-1> "addMarker $w.board %X %Y"
    ::board::bind $w.board $i <Control-ButtonRelease-1> "addMarker $w.board %X %Y"
    ::board::bind $w.board $i <ButtonPress-$::MB3> "addMarker $w.board %X %Y"
    ::board::bind $w.board $i <ButtonRelease-$::MB3> "addMarker $w.board %X %Y"
    ::board::bind $w.board $i <B1-Motion> "::board::dragPiece $w.board %X %Y"
    ::board::bind $w.board $i <ButtonRelease-1> "releaseSquare $w.board %X %Y"
  }

  bind $w <Key> {
    set ch %A
    if {(%s & 0xC) == 0 && $ch ne "" && [moveEntry_Char $ch]} {
      break
    }
  }
  bind $w <BackSpace> moveEntry_Backspace
  bind $w <Delete> moveEntry_Backspace
  bind $w <space> moveEntry_Complete
  bind $w <ButtonRelease> "focus $w"
  bind $w <Configure> {+::resizeMainBoard }

  bindMouseWheel $w.board "main_mousewheelHandler"
  bindMouseWheel $w.board.bd "main_mousewheelHandler"
  bindMouseWheel $w.board.bar "main_mousewheelHandler"

  ttk::frame $w.space
  grid $w.space -row 4 -column 0 -columnspan 3 -sticky nsew
  grid rowconfigure $w 3 -weight 0
  grid rowconfigure $w 4 -weight 1

  grid columnconfigure $w 0 -weight 1
  grid $w.board -row 2 -column 0 -sticky we ;# -padx 5 -pady 5

  updateMainGame
  toggleGameInfo
  updateStatusBar
  updateMainToolbar
  updateTitle
}

proc CreateGameInfo {} {
  # .gameInfo is the game information widget:
  #
  autoscrollText y .main.gameInfo .main.gameInfo.text Treeview
  .main.gameInfo.text configure -width 20 -height 8 -wrap none -state disabled -cursor top_left_arrow
  ::htext::init .main.gameInfo.text

  # Set up player photos:
  ttk::label .main.photoW -image photoW -anchor ne
  ttk::label .main.photoB -image photoB -anchor ne
  bind .main.photoW <ButtonPress-1> "togglePhotosSize"
  bind .main.photoB <ButtonPress-1> "togglePhotosSize"

  # Right-mouse button menu for gameInfo frame:
  menu .main.gameInfo.menu -tearoff 0

  .main.gameInfo.menu add checkbutton -label GInfoHideNext \
          -variable gameInfo(hideNextMove) -offvalue 0 -onvalue 1 -command updateBoard

  .main.gameInfo.menu add checkbutton -label GInfoMaterial -variable gameInfo(showMaterial) -offvalue 0 -onvalue 1 \
          -command { toggleShowMaterial }

  .main.gameInfo.menu add checkbutton -label GInfoFEN \
          -variable gameInfo(showFEN) -offvalue 0 -onvalue 1 -command updateBoard

  .main.gameInfo.menu add checkbutton -label GInfoMarks \
          -variable gameInfo(showMarks) -offvalue 0 -onvalue 1 -command {
              ::board::showMarks .main.board $gameInfo(showMarks)
              updateBoard }

  .main.gameInfo.menu add checkbutton -label GInfoWrap \
          -variable gameInfo(wrap) -offvalue 0 -onvalue 1 -command updateBoard

  .main.gameInfo.menu add checkbutton -label GInfoFullComment \
          -variable gameInfo(fullComment) -offvalue 0 -onvalue 1 -command updateBoard

  .main.gameInfo.menu add checkbutton -label GInfoPhotos \
          -variable gameInfo(photos) -offvalue 0 -onvalue 1 \
          -command {togglePhotosSize 0}

  .main.gameInfo.menu add separator

  .main.gameInfo.menu add command -label GInfoDelete -command {
      sc_base gameflag [sc_base current] [sc_game number] invert del
      ::notify::DatabaseModified [sc_base current]
  }

  bind .main.gameInfo.text <ButtonPress-$::MB3> {
    tk_popup .main.gameInfo.menu %X %Y
  }

  translateMenuLabels .main.gameInfo.menu
}

# Set toolbar help status messages:
proc setToolbarTooltips { tb } {
    foreach {b m} {
	newdb FileNew open FileOpen finder FileFinder
	save GameReplace closedb FileClose bkm FileBookmarks
	gprev GamePrev gnext GameNext
	newgame GameNew copy EditCopy paste EditPaste
	boardsearch SearchCurrent
	headersearch SearchHeader materialsearch SearchMaterial
	switcher WindowsSwitcher glist WindowsGList pgn WindowsPGN tmt WindowsTmt
	maint WindowsMaint eco WindowsECO tree WindowsTree crosstab ToolsCross
	engine ToolsAnalysis } {
	catch { ::utils::tooltip::Set $tb.$b $::helpMessage($::language,$m) }
    }
}

proc InitToolbar {{tb}} {
	ttk::frame $tb -relief raised -border 1
	ttk::menubutton .main.tb.bkm -image tb_bkm -menu .main.tb.bkm.menu -padding {2 0}
	ttk::button .main.tb.gprev -image tb_gprev -command {::game::LoadNextPrev previous} -padding {2 0}
	ttk::button .main.tb.gnext -image tb_gnext -command {::game::LoadNextPrev next} -padding {2 0}
	menu .main.tb.bkm.menu
	::bookmarks::RefreshMenu .main.tb.bkm.menu
	redrawToolbar
}

proc toggleToolbarButton { b i } {
    if { $::toolbar_temp($i) } {
	set ::toolbar_temp($i) 0
	$b.$i state !pressed
    } else {
	set ::toolbar_temp($i) 1
	$b.$i state pressed
    }
    array set ::toolbar_state [array get ::toolbar_temp]
    redrawToolbar
}

proc toggleAllToolbarButtons { b state } {
    foreach i [array names ::toolbar_temp] {
	set ::toolbar_temp($i) $state
	if { $state } { $b.$i state pressed } else { $b.$i state !pressed }
    }
    array set ::toolbar_state [array get ::toolbar_temp]
    redrawToolbar
}

proc ConfigToolbar { w } {
  array set ::toolbar_temp [array get ::toolbar_state]
  pack [ttk::frame $w.f] -side top -fill x
  set col 0
  set row 0
  foreach i {newdb open closedb finder save bkm row gprev gnext row newgame copy paste row boardsearch headersearch \
		 materialsearch row switcher glist pgn tmt maint eco tree crosstab engine } {
      if { $i eq "row" } { incr row; set col 0 } else {
	  ttk::button $w.f.$i -image tb_$i -command "toggleToolbarButton $w.f $i"
	  if { $::toolbar_temp($i) } { $w.f.$i state pressed }
	  grid $w.f.$i -row $row -column $col -sticky news -padx 4 -pady "0 8"
	  incr col
      }
  }
  setToolbarTooltips $w.f
  addHorizontalRule $w
  pack [ttk::frame $w.b] -side bottom -fill x
  ttk::button $w.on -text "+ [::utils::string::Capital $::tr(all)]" -command "toggleAllToolbarButtons $w.f 1"
  ttk::button $w.off -text "- [::utils::string::Capital $::tr(all)]" -command "toggleAllToolbarButtons $w.f 0"

  pack $w.on $w.off -side left -padx 2 -pady "5 0"
}

proc redrawToolbar { args } {
    # Remove any previously-added toolbar icons from the menu bar.
    # The first N entries are the cascade menus; toolbar icons start after them.
    set lastCascade -1
    set n [.menu index end]
    for {set i 0} {$n ne "none" && $i <= $n} {incr i} {
        if {[.menu type $i] eq "cascade"} {
            # Skip tb_bkm cascade (added by previous toolbar redraw) - only count top-level menu cascades
            if {[catch {.menu entrycget $i -image} img] || $img ne "tb_bkm"} {
                set lastCascade $i
            }
        }
    }
    set tbStart [expr {$lastCascade + 1}]
    if {$n ne "none" && $n >= $tbStart} {
        .menu delete $tbStart $n
    }

    # Mapping from toolbar icon name to its command
    array set tbCmd {
        newdb       ::file::New
        open        ::file::Open
        closedb     ::file::Close
        save        {if {[sc_game number] != 0} { gameReplace } else { gameAdd }}
        finder      ::file::finder::Open
        newgame     ::game::Clear
        gprev       {::game::LoadNextPrev previous}
        gnext       {::game::LoadNextPrev next}
        copy        ::gameAddToClipbase
        paste       {catch {sc_clipbase paste}; updateBoard -pgn}
        boardsearch ::search::board
        headersearch ::search::header
        materialsearch ::search::material
        pgn         ::pgn::OpenClose
        tmt         ::tourney::toggle
        maint       ::maint::OpenClose
        switcher    ::windows::switcher::Open
        glist       ::windows::gamelist::Open
        eco         ::windows::eco::OpenClose
        tree        ::tree::make
        crosstab    ::crosstab::OpenClose
        engine      ::enginewin::Open
    }

    # Mapping from toolbar icon name to its help/tooltip key
    array set tbHelp {
        newdb FileNew  open FileOpen  closedb FileClose  save GameReplace
        finder FileFinder  newgame GameNew  gprev GamePrev  gnext GameNext
        copy EditCopy  paste EditPaste  boardsearch SearchCurrent
        headersearch SearchHeader  materialsearch SearchMaterial
        pgn WindowsPGN  tmt WindowsTmt  maint WindowsMaint
        switcher WindowsSwitcher  glist WindowsGList  eco WindowsECO
        tree WindowsTree  crosstab ToolsCross  engine ToolsAnalysis
    }

    set nr $tbStart
    foreach i {newdb open closedb save finder newgame gprev gnext copy paste \
                boardsearch headersearch materialsearch pgn tmt \
                maint switcher glist eco tree crosstab engine} {
        if {$::toolbar_state($i)} {
            .menu add command -image tb_$i -command $tbCmd($i)
            catch { ::utils::tooltip::Set .menu -index $nr $::helpMessage($::language,$tbHelp($i)) }
            incr nr
        }
    }
    if {$::toolbar_state(bkm)} {
        if {![winfo exists .menubookmarks]} { menu .menubookmarks }
        .menu add cascade -image tb_bkm -menu .menubookmarks
        ::bookmarks::RefreshMenu .menubookmarks
    }
    # Hide the old toolbar frame — all icons now live in the menu bar
    grid forget .main.tb
}

##############################
