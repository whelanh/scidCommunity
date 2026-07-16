###
### enginelist.tcl: part of Scid.
### Copyright (C) 1999-2003  Shane Hudson.
### Copyright (C) 2007  Pascal Georges
### Copyright (C) 2025  Uwe Klimmek

######################################################################
namespace eval enginelist {}

set engines(list) {}

# engine:
#   Adds an engine to the engine list.
#   Calls to this function will be found in the user engines.lis
#   file, which is sourced below.
#
proc engine {arglist} {
    global engines
    array set newEngine {}
    foreach {attr value} $arglist {
        set newEngine($attr) $value
    }
    # Check that required attributes exist:
    if {! [info exists newEngine(Name)]} { return  0 }
    if {! [info exists newEngine(Cmd)]} { return  0 }
    if {! [info exists newEngine(Dir)]} { return  0 }
    # Fill in optional attributes:
    if {! [info exists newEngine(Args)]} { set newEngine(Args) "" }
    if {! [info exists newEngine(Elo)]} { set newEngine(Elo) 0 }
    if {! [info exists newEngine(Time)]} { set newEngine(Time) 0 }
    if {! [info exists newEngine(URL)]} { set newEngine(URL) "" }
    # puts this option here for compatibility with previous file format (?!)
    if {! [info exists newEngine(UCI)]} { set newEngine(UCI) 0 }
    if {! [info exists newEngine(UCIoptions)]} { set newEngine(UCIoptions) "" }

    lappend engines(list) [list $newEngine(Name) $newEngine(Cmd) \
            $newEngine(Args) $newEngine(Dir) \
            $newEngine(Elo) $newEngine(Time) \
            $newEngine(URL) $newEngine(UCI) $newEngine(UCIoptions)]
    return 1
}

# ::enginelist::read
#   Reads the user Engine list file.
#
proc ::enginelist::read {} {
    catch {source [scidConfigFile engines]}
}

# Read the user Engine List file now:
#
catch { ::enginelist::read }
if {[llength $engines(list)] == 0} {
    # No engines, so set up a default engine list:
    set phalanx "phalanx-scid"
    set togaII "togaII"
    set stockfish "stockfish"
    if { $::windowsOS } {
        set phalanx "phalanx-scid.exe"
        set togaII "TogaII.exe"
        set stockfish "stockfish.exe"
    }
    set scidEngPaths [list $::scidEnginesDir $::scidExeDir [file join $::scidExeDir "engines" ] [file join $::scidShareDir "engines" ] \
            [ file join $::scidUserDir "engines" ]  [ file join /usr local share scid engines ] \
            [ file join /usr local bin ] [ file join  /usr bin ] [ file join /usr local games ] [ file join /usr games ] \
            [file join $::scidExeDir "engines" "phalanx-scid" ] [file join $::scidExeDir "engines" "togaII1.2.1a" "src" ] ]

    # The next four lists should have the same length!
    set scidEngCmds [list $stockfish $phalanx $togaII ]
    set scidEngNames [list "Stockfish" "Phalanx-Scid" "Toga II" ]
    array set parentDirs "
    $stockfish { stockfish }
    $phalanx { phalanx-scid Phalanx-XXII }
    $togaII  { togaII1.2.1a toga togaII [ file join togaII1.2.1a src ] }
    "

    set isUCI [list 1 0 1]

    # Let's search the engines:
    foreach cmd $scidEngCmds name $scidEngNames uci $isUCI {
        set leave 0
        foreach path $scidEngPaths {
            set c [ file join $path $cmd]
            if { [file executable $c ] && ! [ file isdirectory $c ] } {
                engine [list \
                        Name $name \
                        Cmd  $c \
                        Dir  [file dirname $c] \
                        UCI  $uci \
                        UCIoptions {} \
                        ]
                set leave 1
            } else {
                foreach parent $parentDirs($cmd) {
                    set c [ file join $path $parent $cmd ]
                    if { [file executable $c] && ! [ file isdirectory $c ] } {
                        engine [list \
                                Name $name \
                                Cmd  $c \
                                Dir  [file dirname $c] \
                                UCI  $uci \
                                UCIoptions {} \
                                ]
                        set leave 1
                        break
                    }
                }
            }
            if { $leave } { break }
        }
    }
}

# ::enginelist::date
#   Given a time in seconds since 1970, returns a
#   formatted date string.
proc ::enginelist::date {time} {
    return [clock format $time -format "%a %b %d %Y %H:%M"]
}

# ::enginelist::sort
#   Sort the engine list.
#   If the engine-open dialog is open, its list is updated.
#   The type defaults to the current engines(sort) value.
#
proc ::enginelist::sort {{type ""}} {
    global engines

    if {$type == ""} {
        set type Time; #$engines(sort)
    } else {
        set engines(sort) $type
    }
    switch $type {
        Name {
            set engines(list) [lsort -dictionary -index 0 $engines(list)]
        }
        Elo {
            set engines(list) [lsort -dictionary -decreasing -index 4 $engines(list)]
        }
        Time {
            set engines(list) [lsort -integer -decreasing -index 5 $engines(list)]
        }
    }

    # If the Engine-open dialog is open, update it:
    #
    set w .enginelist
    if {! [winfo exists $w]} { return }
    set f $w.list.list
    $w.list.list delete [$w.list.list children {}]
    set count 0
    foreach engine $engines(list) {
        set name [lindex $engine 0]
        set elo [lindex $engine 4]
        set time [lindex $engine 5]
        set date [::enginelist::date $time]
        $w.list.list insert {} end -id $count -values [list $name $elo $date]
        incr count
    }
    set children [$w.list.list children {}]
    if {[llength $children] > 0} {
        lassign $children firstItem
        $w.list.list selection set $firstItem
    }
}
################################################################################
# ::enginelist::choose
#   Select an engine from the Engine List.
#   Returns an integer index into the engines(list) list variable.
#   If no engine is selected, returns the empty string.
################################################################################
proc engine.singleclick_ {{w} {x} {y}} {
    lassign [$w identify $x $y] what
    if {$what == "heading"} {
        set col [$w identify column $x $y]
        ::enginelist::sort [$w column $col -id]
    }
}
# ::enginelist::freeSlot
#   Returns the lowest analysis-window slot number (>= 1) that is not
#   currently in use, so that multiple analysis windows can coexist.
#
proc ::enginelist::freeSlot {} {
    set n 1
    while {[winfo exists ".analysisWin$n"]} { incr n }
    return $n
}

# ::enginelist::openSelected
#   Opens an analysis window for the engine currently selected in the
#   engine list, using the lowest free slot. If closeList is true the
#   engine list dialog is closed afterwards (OK / Return); otherwise it
#   stays open so several engines can be launched (double-click).
#
proc ::enginelist::openSelected {{closeList 1}} {
    set sel [lindex [.enginelist.list.list selection] 0]
    if {$sel eq "" || $sel < 0} { return }
    catch { ::enginelist::setTime $sel }
    if {$closeList} { destroy .enginelist }
    ::makeAnalysisWin [::enginelist::freeSlot] $sel
}

proc ::enginelist::choose {} {
    global engines
    set w .enginelist
    if {[winfo exists $w]} {
        raise .enginelist
        return }
    win::createDialog $w
    ::setTitle $w "scidCommunity: [tr ToolsAnalysis]"
    ttk::frame $w.buttons
    ttk::frame $w.list
    # Set up enginelist
    ttk::treeview $w.list.list -columns { "Name" "Elo" "Time" } -height 12 \
        -show headings -selectmode browse -yscrollcommand "$w.list.ybar set"
    set wid [font measure font_Regular W]
    $w.list.list column Name -width [expr 12 * $wid]
    $w.list.list heading Name -text [tr EngineName]
    $w.list.list column Elo -anchor e -width [expr 4 * $wid]
    $w.list.list heading Elo -text [tr EngineElo]
    $w.list.list column Time -width [expr 12 * $wid]
    $w.list.list heading Time -text [tr EngineTime]
    ttk::scrollbar $w.list.ybar -command "$w.list.list yview"
    pack $w.list.list $w.list.ybar -side left -fill both -expand 1

    # The list of choices:
    pack $w.list -side top -fill y -expand 1
    pack $w.buttons -side top -fill x -pady { 5 0 }
    bind $w.list.list <Double-ButtonRelease-1> "::enginelist::openSelected 0; break"
    bind $w.list.list <ButtonRelease-1> "engine.singleclick_ %W %x %y"

    set f $w.buttons
    dialogbutton $f.add -text $::tr(EngineNew...) -command { ::enginelist::edit -1 }
    dialogbutton $f.edit -text $::tr(EngineEdit...) -command {
        ::enginelist::edit [lindex [.enginelist.list.list selection] 0]
    }
    dialogbutton $f.delete -text $::tr(Delete...) -command {
        ::enginelist::delete [lindex [.enginelist.list.list selection] 0]
    }
    dialogbutton $f.lucaschess -text "Lucas Chess" -command { ::lucaschess::choose }
    ttk::label $f.sep -text "   "
    dialogbutton $f.open -text [tr EngineOpenAnalysis] -command {
        ::enginelist::openSelected 1
    }
    dialogbutton $f.ok -text "OK" -command {
        destroy .enginelist
    }
    dialogbutton $f.cancel -text $::tr(Cancel) -command {
        destroy .enginelist
    }
    packbuttons right $f.cancel $f.ok $f.open
    pack $f.lucaschess $f.add $f.edit $f.delete -side left -padx 1

    ::enginelist::sort
    focus $w.list.list
    wm protocol $w WM_DELETE_WINDOW "destroy $w"
    bind $w <F1> { helpWindow Analysis List }
    bind $w <Escape> "destroy $w"
    bind $w.list.list <Return> "$w.buttons.open invoke; break"
}

# ::enginelist::setTime
#   Sets the last-opened time of the engine specified by its
#   index in the engines(list) list variable.
#   The time should be in standard format (seconds since 1970)
#   and defaults to the current time.
#
proc ::enginelist::setTime {index {time -1}} {
    global engines
    set e [lindex $engines(list) $index]
    if {$time < 0} { set time [clock seconds] }
    set e [lreplace $e 5 5 $time]
    set engines(list) [lreplace $engines(list) $index $index $e]
}

# ::enginelist::delete
#   Removes an engine from the list.
#
proc ::enginelist::delete {index} {
    global engines
    if {$index == ""  ||  $index < 0} { return }
    set e [lindex $engines(list) $index]
    set msg "Name: [lindex $e 0]\n"
    append msg "Command: [lindex $e 1]\n\n"
    append msg "Do you really want to remove this engine from the list?"
    set answer [tk_messageBox -title scidCommunity -icon question -type yesno \
            -message $msg]
    if {$answer == "yes"} {
        set engines(list) [lreplace $engines(list) $index $index]
        ::enginelist::sort
        ::enginecfg::write
    return true
    }
    return false
}

# ::enginelist::edit
#   Opens a dialog for editing an existing engine list entry (if
#   index >= 0), or adding a new entry (if index is -1).
#
proc ::enginelist::showHideOptionsFrame {id w enginevar callback col} {
    if { [winfo ismapped $w] } { grid forget $w ; return }
    grid $w -row 0 -column $col -rowspan 5 -sticky ne -padx 10
    set engine [set $enginevar]
    ::enginelist::initEngine $id $engine [list $callback $id $w]
}
proc ::enginelist::edit {index} {
    global engines
    if {$index == ""} { return }

    if {$index >= 0 } {
        set e [lindex $engines(list) $index]
        set engines(newEngine) 0
    } else {
        set name [::enginecfg::dlgNewLocal]
        if { $name eq ""} { return }
        set index [expr [llength $engines(list)] - 1]
        set engines(newEngine) 1
        set e [lindex $engines(list) $index]
        lset e 3 .
        set engines(newOptions) [lindex $e 8]
    }

    set engines(newIndex) $index
    set engines(newName) [lindex $e 0]
    set engines(newCmd) [lindex $e 1]
    set engines(newArgs) [lindex $e 2]
    set engines(newDir) [lindex $e 3]
    set engines(newElo) [lindex $e 4]
    set engines(newTime) [lindex $e 5]
    set engines(newURL) [lindex $e 6]
    set engines(newUCI) [lindex $e 7]
    set engines(newOptions) [lindex $e 8]

    set engines(newDate) $::tr(None)
    if {$engines(newTime) > 0 } {
        set engines(newDate) [::enginelist::date $engines(newTime)]
    }

    set w .engineEdit
    win::createDialog $w
    ::setTitle $w scidCommunity

    set f [ttk::frame $w.f]
    grid $f -row 0 -column 0 -sticky nwe
    set row 0

    foreach i {Name Cmd Args Dir} {
        ttk::label $f.l$i -text $i
        if {[info exists ::tr(Engine$i)]} {
            $f.l$i configure -text $::tr(Engine$i)
        }
        ttk::entry $f.e$i -textvariable engines(new$i) -width 40
        grid $f.l$i -row $row -column 0 -sticky w
        grid $f.e$i -row $row -column 1 -sticky we

        if {$i == "Name"} {
            ::engineNoWin::createEngineOptionsFrame $w editEngine ::engines(newName) 4 ::enginelist::eng_messages all
            pack forget $w.editEngine.eng
            $w.optseditEngine.text configure -height 24
            grid $w.editEngine -in $f -column 2 -row $row
            if { $engines(newEngine) } { $w.editEngine.opts invoke }
        }
        # Browse button for choosing an executable file:
        if {$i == "Cmd"} {
            ttk::button $f.b$i -text "..." -command {
                if {$::windowsOS} {
                    set ftype {
                        {"Applications" {".bat" ".exe"} }
                        {"All files" {"*"} }
                    }
                    set fName [tk_getOpenFile -initialdir $engines(newDir) \
                        -title "scidCommunity: [tr ToolsAnalysis]" -filetypes $ftype]
                } else {
                    set fName [tk_getOpenFile -initialdir $engines(newDir) \
                        -title "scidCommunity: [tr ToolsAnalysis]"]
                }
                if {$fName != ""} {
                    set engines(newCmd) $fName
                    .engineEdit.editEngine.opts configure -state enabled
                    # Set the directory from the executable path if possible:
                    set engines(newDir) [file dirname $fName]
                    if {$engines(newDir) == ""} { set engines(newDir) . }
                }
            }
            grid $f.b$i -row $row -column 2 -sticky we
        }

        if {$i == "Dir"} {
            ttk::button $f.current -text " . " -command {
                set engines(newDir) .
            }
            if {$::windowsOS} {
                ttk::button $f.user -text "scid.exe dir" -command {
                    set engines(newDir) $scidInstallDir
                }
            } else {
                ttk::button $f.user -text "~/.scid" -command {
                    set engines(newDir) $scidUserDir
                }
            }
            grid $f.current -row $row -column 2 -sticky we
            grid $f.user -row $row -column 3 -sticky we
        }
        incr row
    }

    grid columnconfigure $f 1 -weight 1
    # Mark required fields:
    $f.lName configure -font font_Bold
    $f.lCmd configure -font font_Bold
    $f.lDir configure -font font_Bold

    ttk::label $f.lElo -text $::tr(EngineElo)
    ttk::entry $f.eElo -textvariable engines(newElo) -justify right -width 5
    grid $f.lElo -row $row -column 0 -sticky w
    grid $f.eElo -row $row -column 1 -sticky w

    ttk::checkbutton $f.cbUci -text UCI -variable engines(newUCI) -style Bold.TCheckbutton
    grid $f.cbUci -row $row -column 1 -sticky e
    incr row

    ttk::label $f.lTime -text $::tr(EngineTime)
    ttk::label $f.eTime -textvariable engines(newDate) -anchor w -width 1
    grid $f.lTime -row $row -column 0 -sticky w
    grid $f.eTime -row $row -column 1 -sticky we
    ttk::button $f.clearTime -text $::tr(Clear) -command {
        set engines(newTime) 0
        set engines(newDate) $::tr(None)
    }
    ttk::button $f.nowTime -text $::tr(Update) -command {
        set engines(newTime) [clock seconds]
        set engines(newDate) [::enginelist::date $engines(newTime)]
    }
    grid $f.clearTime -row $row -column 2 -sticky we
    grid $f.nowTime -row $row -column 3 -sticky we
    incr row

    ttk::button $f.ok -text OK -command {
        if {[string trim $engines(newName)] == ""  ||
            [string trim $engines(newCmd)] == ""  ||
            [string trim $engines(newDir)] == ""} {
            tk_messageBox -title scidCommunity -icon info \
                    -message "The Name, Command and Directory fields must not be empty."
        } else {
            set newEntry [list $engines(newName) $engines(newCmd) \
                    $engines(newArgs) $engines(newDir) \
                    $engines(newElo) $engines(newTime) \
                    $engines(newURL) $engines(newUCI) $engines(newOptions) ]
            set engines(list) [lreplace $engines(list) $engines(newIndex) $engines(newIndex) $newEntry]
            ::engineNoWin::saveEngineSetup editEngine
            ::enginelist::sort
            ::enginecfg::write
            destroy .engineEdit
        }
    }
    if { $engines(newEngine) } {
        set cancelCmd [list ::enginelist::cancelNewEngine $index]
        ttk::button $f.cancel -text $::tr(Cancel) -command "
            $cancelCmd
            destroy $w
        "
        bind $w <Escape> "
            $cancelCmd
            destroy $w
        "
        bind $w <Destroy> "
            if {\[winfo exists $w\]} {
                $cancelCmd
            }
            raise .enginelist
            focus .enginelist
        "
    } else {
        ttk::button $f.cancel -text $::tr(Cancel) -command "destroy $w"
        bind $w <Escape> "destroy $w"
        bind $w <Destroy> "raise .enginelist; focus .enginelist"
    }
    ttk::label $f.required -font font_Small -text $::tr(EngineRequired)
    grid $f.required -row $row -column 0 -columnspan 2 -sticky we
    grid $f.ok -row $row -column 2 -sticky we -pady { 10 0 }
    grid $f.cancel -row $row -column 3 -sticky we -pady { 10 0 }

    bind $w <Return> "$f.ok invoke"
    bind $w <F1> { helpWindow Analysis List }
    focus $w.f.eName
    wm resizable $w 1 0
    catch {grab $w}
}

# ::enginelist::cancelNewEngine
#   Removes a new engine placeholder from the list when the user cancels
#   the engine creation dialog. This cleanup is needed when a temporary
#   engine was added by ::enginecfg::dlgNewLocal.
#
proc ::enginelist::cancelNewEngine {index} {
    global engines
    set engines(list) [lreplace $engines(list) $index $index]
    ::enginelist::sort
    ::enginecfg::write
}

proc ::enginelist::eng_messages {id w msg} {
    lassign $msg msgType msgData
    switch $msgType {
        "InfoConfig" {
            set msgData [lindex $msgData 2]
            if {$::engines(newEngine) && [set idx [lsearch -index 0 $msgData "myname"]] >=0} {
                set ::engines(newName) [lindex $msgData $idx 1]
            }
            ::engineNoWin::initEngineOptions $id $w $msgData
        }
        "InfoDisconnected" {
            ::engineNoWin::disconnected $id $msgData
        }
    }
}
