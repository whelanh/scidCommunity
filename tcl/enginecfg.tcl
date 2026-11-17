########################################################################
# Copyright (C) 2020-2023 Fulvio Benini
#
# This file is part of SCID (Shane's Chess Information Database).
# SCID is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Functions and sub-window for chess engine configuration.

namespace eval enginecfg {}

# Return a list containing the engine's names sorted by last use.
proc ::enginecfg::names {} {
    return [lmap elem [lsort -integer -decreasing -index 5 $::engines(list)] {
        lindex $elem 0
    }]
}

# Return the engine's config.
# If there is no config for the requested engine's name, returns "".
proc ::enginecfg::get {name} {
    set res [lsearch -exact -inline -index 0 $::engines(list) $name]
    if {$res ne ""} {
        # The old url element is now used to store the values for:
        # scoreside notation pvwrap debugframe priority netport
        if {[llength [lindex $res 6]] != 6} {
            lset res 6 [list white 1 none false normal ""]
        }
    }
    return $res
}

# Change the name of an engine and write the "Engine list" file.
# Returns the new name on success or the old name on error.
proc ::enginecfg::rename {oldname newname} {
    set idx [lsearch -exact -index 0 $::engines(list) $oldname]
    if {$idx < 0 || $newname eq $oldname || $newname eq ""} {
        return $oldname
    }
    set newname [::enginecfg::uniquename $newname]
    lset ::engines(list) $idx 0 $newname
    ::enginecfg::write
    return $newname
}

# Append a number, or increments it, to the name of an engine to make it unique.
# Return the unique name.
proc ::enginecfg::uniquename {name} {
    set copyn 0
    while {[lsearch -exact -index 0 $::engines(list) $name] >= 0} {
        regexp {^(.*?)\s*(\(\d+\))*$} $name -> name
        set name "$name ([incr copyn])"
    }
    return $name
}

# Add an engine, possibly changing the name to make it unique,
# and save the "Engine list" file.
# Return the name of the new engine or "".
proc ::enginecfg::add {enginecfg} {
    lset enginecfg 0 [::enginecfg::uniquename [lindex $enginecfg 0]]
    lappend ::engines(list) $enginecfg
    return [::enginecfg::save $enginecfg true]
}

# Return a copy of an engine's config under a name not yet in the list.
# The copy is the complete spec - command, arguments, directory, the UCI
# options and the search limits - because a duplicate exists to become a
# second preset of the same binary that differs only in how it is used.
# The raw element count is kept: a legacy nine-element entry copies as nine,
# so its copy still falls back to the global limits and writes no Limits line,
# while an entry whose limits were all cleared copies as ten with the empty
# dict that overrides those globals.
proc ::enginecfg::duplicate {enginecfg} {
    lset enginecfg 0 [::enginecfg::uniquename [lindex $enginecfg 0]]
    return $enginecfg
}

# Remove an engine from the "Engine list" file.
# Returns true if the engine was removed
proc ::enginecfg::remove {name} {
    set idx [lsearch -exact -index 0 $::engines(list) $name]
    if {$idx < 0} { return false }

    lassign [lindex $::engines(list) $idx] name cmd
    set msg "Name: $name\n"
    append msg "Command: $cmd\n\n"
    append msg "Do you really want to remove this engine from the list?"
    set answer [tk_messageBox -title scidCommunity -icon question -type yesno -message $msg]
    if {$answer ne "yes"} { return false }

    set ::engines(list) [lreplace $::engines(list) $idx $idx]
    ::enginecfg::write
    return true
}

# The review's own per-config switch.
#
# It lives in the engine configuration's option list (element 8) beside Threads
# and MultiPV, but it is not a UCI option: nothing is ever sent to the engine for
# it (::enginecfg::uciOptions strips it from every SetOptions), and the review
# reads it back with ::review::engineDefaults. A config that does not carry it
# keeps the built-in default, on - which is what every engines.dat written before
# it moved there carries, so nothing needs migrating.
#
# The value is true/false, the shape element 8's other check options already use,
# and `default` is true for the same reason: ::enginecfg::save drops an option
# sitting at its default, so a config that keeps the pre-pass on writes nothing
# and stays a config that "says nothing".
variable ::enginecfg::REVIEW_OPTIONS {
    cloud_eval   ReviewCloudEval
}

# Is `name` that switch (case insensitive)?
proc ::enginecfg::isReviewOption {name} {
    variable REVIEW_OPTIONS
    return [expr {[dict exists $REVIEW_OPTIONS [string tolower $name]]}]
}

# The label a review option's row shows, translated.
proc ::enginecfg::reviewOptionLabel {name} {
    variable REVIEW_OPTIONS
    set key [dict get $REVIEW_OPTIONS [string tolower $name]]
    if {[llength [info commands tr]] == 0} { return $name }
    return [tr $key]
}

# One review option as an element-8 row:
# {name value type default min max var_list internal}.
#
# min and max are empty on purpose: a check row whose bounds were set would have
# ::enginecfg::setOption compare "true" as a number.
proc ::enginecfg::reviewOptionRow {name value} {
    return [list $name $value check true {} {} {} 0]
}

# A stored on/off value as the checkbutton's true/false.
#
# engines.dat is hand-editable, and the switch is documented as reading 0/1 as
# well as the true/false the panel writes. A value neither spelling recognises
# means the config says nothing usable, so the built-in default (on) is shown -
# the same answer ::review::flagValue gives the pass.
proc ::enginecfg::switchValue {value {default true}} {
    switch -nocase -- [string trim $value] {
        true  - yes - on  - 1 { return true }
        false - no  - off - 0 { return false }
    }
    return $default
}

# The review option rows an option list carries, in a fixed order, with the
# values it stores or the default for one it does not. `options` is element 8's
# list, whatever shape its rows are in.
proc ::enginecfg::reviewOptions {options} {
    variable REVIEW_OPTIONS
    set stored [dict create]
    foreach elem $options {
        lassign $elem name value
        if {[isReviewOption $name]} {
            dict set stored [string tolower $name] $value
        }
    }
    set out {}
    foreach name [dict keys $REVIEW_OPTIONS] {
        set value true
        if {[dict exists $stored $name]} {
            set value [switchValue [dict get $stored $name]]
        }
        lappend out [reviewOptionRow $name $value]
    }
    return $out
}

# An option list with the review row put back: the engine's own options first, in
# the order it advertised them, then the review's.
#
# The engine hands over a fresh option list on every handshake and on every
# SetOptions reply, and the review row is not in it - the engine has never heard
# of it. Carrying it across from the list being replaced is what keeps a config's
# switch from being wiped by the engine connecting.
proc ::enginecfg::withReviewOptions {options {oldOptions ""}} {
    return [concat [uciOptions $options] [reviewOptions $oldOptions]]
}

# The options that are the engine's own: the review's rows are settings for the
# review pass, not UCI options, and are never sent to an engine.
proc ::enginecfg::uciOptions {options} {
    set out {}
    foreach elem $options {
        if {[isReviewOption [lindex $elem 0]]} { continue }
        lappend out $elem
    }
    return $out
}

# Persist one review switch into the saved preset, leaving every other field of
# the preset alone.
#
# The switch is the one option a window can change without the engine answering,
# and two engine windows can hold the same preset (a fresh window starts the most
# recently used engine). Saving a window's whole snapshot would let the older
# window's close write its stale row back over the newer value, so a toggle
# writes only its own row here and ::enginecfg::save carries the stored row
# through a snapshot rather than taking the snapshot's value.
proc ::enginecfg::saveReviewOption {engine option value {default true}} {
    set pos [lsearch -exact -index 0 $::engines(list) $engine]
    if {$pos < 0} {
        return
    }
    set stored [lindex $::engines(list) $pos]
    set rows {}
    set found 0
    foreach row [lindex $stored 8] {
        if {[llength $row] > 1 && [string equal -nocase [lindex $row 0] $option]} {
            set found 1
            # A value at its default is left out, exactly as ::enginecfg::save
            # leaves it out of element 8.
            if {$value ne $default} { lappend rows [list $option $value] }
        } else {
            lappend rows $row
        }
    }
    if {!$found && $value ne $default} { lappend rows [list $option $value] }
    lset ::engines(list) $pos [lreplace $stored 8 8 $rows]
    # Not swallowed: a failed write is a setting that will revert on restart, and
    # the caller's option-error path (the switch's error style) is where the user
    # sees it. Every other engines.dat write behaves the same way.
    ::enginecfg::write
}

# Search a previous configuration with the same name and replace it.
# Write the "Engine list" file if it is necessary or force_write is true.
# Return the engine's name or "" (and does nothing) if the engine do not exists.
proc ::enginecfg::save {enginecfg {force_write false}} {
    lassign $enginecfg enginename
    set idx [lsearch -exact -index 0 $::engines(list) $enginename]
    if {$idx < 0} {
        return ""
    }
    # A record loaded from the file holds already-filtered {name value} pairs;
    # only the live widget form carries the type/default/... fields. The old
    # filter threw "expected boolean value" on a loaded pair.
    #
    # A review switch is NOT taken from this snapshot: it is persisted by its own
    # row (::enginecfg::saveReviewOption), and another window holding the same
    # preset may have an older value. The stored row is carried through instead,
    # so a stale window's close cannot revert it.
    set storedReview {}
    foreach row [::enginecfg::reviewOptions [lindex [lindex $::engines(list) $idx] 8]] {
        lassign $row name value type default
        if {$value ne $default} { lappend storedReview [list $name $value] }
    }
    lset enginecfg 8 [concat [lmap elem [lindex $enginecfg 8] {
        if {[llength $elem] == 2} {
            if {[::enginecfg::isReviewOption [lindex $elem 0]]} { continue }
            set elem
        } else {
            lassign $elem name value type default min max var_list internal
            if {$internal || $value eq $default} { continue }
            if {[::enginecfg::isReviewOption $name]} { continue }
            list $name $value
        }
    }] $storedReview]
    if {$force_write || [lindex $::engines(list) $idx] ne $enginecfg} {
        lset ::engines(list) $idx $enginecfg
        ::enginecfg::write
    }
    return $enginename
}

# Writes the "Engine list" file.
# Throw an exception on error.
proc ::enginecfg::write {} {
    set enginesFile [scidConfigFile engines]
    set f [open $enginesFile w]
    puts $f "\# Analysis engines list file for Scid $::scidVersion with UCI support"
    puts $f ""
    foreach e $::engines(list) {
        # The raw length says whether this preset ever had a Limits field: an
        # entry from an older file has nine elements, and an explicit empty
        # dict (all limits cleared) must still be written as "Limits {}".
        set hasLimits [expr {[llength $e] >= 10}]
        lassign [::enginelimits::pad $e] name cmd args dir elo time url uci opt lim
        puts $f "engine {"
            puts $f "  Name [list $name]"
            puts $f "  Cmd  [list $cmd]"
            puts $f "  Args [list $args]"
            puts $f "  Dir  [list $dir]"
            puts $f "  Elo  [list $elo]"
            puts $f "  Time [list $time]"
            puts $f "  URL  [list $url]"
            puts $f "  UCI [list $uci]"
            puts $f "  UCIoptions [list $opt]"
            # Written only when the preset sets a limit, so a file that never
            # used them is byte-identical to one written by an older version.
            if {$hasLimits} {
                puts $f "  Limits [list $lim]"
            }
            puts $f "}"
        puts $f ""
    }
    close $f
}

# Pop up a dialog box for the user to select the cmd file referring to a local engine
# and adds the engine to the list of the available ones.
# Return the name of the new engine or "".
proc ::enginecfg::dlgNewLocal {} {
    if {$::windowsOS} {
        lappend ftype [list "Executable" [list ".exe" ".bat"]]
    }
    lappend ftype [list "All files" *]
    set fName [tk_getOpenFile -initialdir $::scidEnginesDir -filetypes $ftype]
    if {$fName eq ""} { return "" }
    set ::scidEnginesDir [file dirname $fName]
    return [::enginecfg::add [list $fName $fName {} {} {} 0 {} 1 {}]]
}

# Pop up a dialog box for the user to enter the url of a remote engine
# and adds the engine to the list of the available ones.
# Return the name of the new engine or "".
proc ::enginecfg::dlgNewRemote {} {
    set ::enginecfg_dlgresult ""
    set w .engineDlgNewRemote
    win::createDialog $w
    pack [ttk::label $w.msg -text "Remote engine (hostname:port):"] -fill x
    pack [ttk::entry $w.value] -fill x
    dialogbutton $w.cancel -text [tr Cancel] -command "destroy $w"
    dialogbutton $w.ok -text "OK" -command "
        set ::enginecfg_dlgresult \[$w.value get\]
        destroy $w
    "
    ::packdlgbuttons $w.cancel $w.ok
    grab $w
    tkwait window $w
    if {$::enginecfg_dlgresult eq ""} { return "" }
    return [::enginecfg::add [list $::enginecfg_dlgresult $::enginecfg_dlgresult {} {} {} 0 {} 2]]
}

# Creates buttons used for selecting an engine and managing configured engines:
# Adds a new local or remote engine; reloads, clones, or deletes an existing engine.
# fn_connect: Callback function invoked upon engine selection.
# In response to the virtual event <<UpdateEngineName>>, it updates the name of the
# selected engine and the state of the reload, clone, and delete buttons.
proc ::enginecfg::createConfigButtons {id w} {
    ttk::combobox $w.engine -width 30 -state readonly -postcommand [list apply {{w} {
        $w.engine configure -values [::enginecfg::names ]
    }} $w]
    bind $w.engine <<ComboboxSelected>> \
        "event generate $w <<EngineCfgConnect>> -data \[list $id \[%W get]]"
    ::utils::tooltip::Set $w.engine [tr EngineSelect]

    ttk::button $w.reload -text "\u21BB" -style Toolbutton \
        -command "event generate $w.engine <<ComboboxSelected>>"
    ::utils::tooltip::Set $w.reload [tr EngineReload]

    ttk::button $w.addpipe -text "\u271A" -style Toolbutton -command [list apply {{id w} {
        if {[set newEngine [::enginecfg::dlgNewLocal]] ne ""} {
            event generate $w <<EngineCfgConnect>> -data [list $id $newEngine]
        }
    }} $id $w]
    ::utils::tooltip::Set $w.addpipe [tr EngineAddLocal]

    ttk::button $w.addremote -text "\u2B82" -style Toolbutton -command [list apply {{id w} {
        if {[set newEngine [::enginecfg::dlgNewRemote]] ne ""} {
            event generate $w <<EngineCfgConnect>> -data [list $id $newEngine]
        }
    }} $id $w]
    ::utils::tooltip::Set $w.addremote [tr EngineAddRemote]

    ttk::button $w.clone -text "\u29C9" -style Toolbutton -command [list apply {{id w} {
        event generate $w <<EngineCfgConnect>> -data [list $id [::enginecfg::add [set ::enginecfg::engConfig_$id]]]
    }} $id $w]
    ::utils::tooltip::Set $w.clone [tr EngineClone]

    ttk::button $w.delete -text "\u2A02" -style Toolbutton -command [list apply {{id w} {
        if {[::enginecfg::remove [$w.engine get]]} {
            event generate $w <<EngineCfgConnect>> -data [list $id {}]
        }
    }} $id $w]
    ::utils::tooltip::Set $w.delete [tr EngineDelete]

    grid $w.engine $w.reload $w.addpipe $w.addremote \
         $w.clone $w.delete -sticky news -padx 4

    bind $w <<UpdateEngineName>> [list apply {{w} {
        lassign %d name
        set state "normal"
        if {$name eq ""} {
            set name "[tr Engine]:"
            set state "disabled"
        }
        $w.engine set $name
        $w.reload configure -state $state
        $w.clone configure -state $state
        $w.delete configure -state $state
    }} $w]
}

# Creates the frame with the widgets necessary to change an engine's configuration.
proc ::enginecfg::createConfigOptions {id configFrame} {
    ttk_text $configFrame.text -wrap none -padx 4
    autoscrollBars both $configFrame $configFrame.text
    $configFrame.text configure -state disabled
}

proc ::enginecfg::resetConfigOptions {id configFrame config} {
    set msg "No engine open: select or add one."
    lassign $config name cmd args wdir elo time url uci options
    lassign $url scoreside notation pvwrap debugframe priority netport
    set time [clock seconds]; # Update engine's last used time.
    # The review's own switches start from what the preset stored, so a config
    # whose engine never connects still carries them - and so the handshake's
    # fresh option list has something to be merged with (::enginecfg::withReviewOptions).
    set live [list $name $cmd $args $wdir $elo $time $url $uci [::enginecfg::reviewOptions $options]]
    if {[llength $config] >= 10} { lappend live [lindex $config 9] }
    set ::enginecfg::engConfig_$id $live
    if {$config ne ""} {
        set msg "$cmd $args\nConnecting..."
        event generate $configFrame <<EngineCfgLayout>> -data [list $id debug $debugframe]
        event generate $configFrame <<EngineCfgLayout>> -data [list $id notation $notation]
        event generate $configFrame <<EngineCfgLayout>> -data [list $id scoreside $scoreside]
        event generate $configFrame <<EngineCfgLayout>> -data [list $id wrap $pvwrap]
    }
    $configFrame.text configure -state normal
    $configFrame.text delete 1.0 end
    $configFrame.text insert end $msg
    $configFrame.text configure -state disabled
    return $netport
}

# Update or recreate the config and option widgets
# If it is a new engine added with auto-config, return the new name
# otherwise return an empty "" string
proc ::enginecfg::updateConfigOptions {id configFrame msgInfoConfig} {
    upvar ::enginecfg::engConfig_$id engConfig_
    set w $configFrame.text
    lassign $msgInfoConfig protocol netclients options

    # Replace the engine's available options. The review's switches are not in
    # what the engine advertises, so they are carried across from the list being
    # replaced: the engine connecting must not untick them.
    set oldOptions [lindex $engConfig_ 8]
    set options [::enginecfg::withReviewOptions $options $oldOptions]
    lset engConfig_ 8 $options

    set renamed ""
    set recreate_widgets 1
    if {$msgInfoConfig eq ""} {
        # An emtpy message -> recreate all the widgets
    } elseif {[lindex $engConfig_ 7] == ""} {
        # A new engine added with auto-config, update the name and protocol
        # and recreate all the widgets
        lassign $engConfig_ currname
        if {[set idx [lsearch -index 0 $options "myname"]] >=0} {
            set renamed [::enginecfg::rename $currname [lindex $options $idx 1]]
            lset engConfig_ 0 $renamed
        }
        lset engConfig_ 7 [expr { $protocol eq "uci" }]

    } elseif {[winfo exists $w.name] && [string equal \
                            [lmap elem $oldOptions {lreplace $elem 1 1}] \
                            [lmap elem $options {lreplace $elem 1 1}]]} {
        # Same options, no need to recreate the widgets
        set recreate_widgets 0
    }

    $w configure -state normal
    if {$recreate_widgets} {
        if {![::enginecfg::createConfigWidgets $id $configFrame $engConfig_]} {
            # The option widgets are not created if the engine is not open
            $w configure -state disabled
            return $renamed
        }
        ::enginecfg::createOptionWidgets $id $configFrame $options
    }
    ::enginecfg::updateOptionWidgets $id $configFrame $options $oldOptions
    ::enginecfg::updateNetClients $configFrame $netclients
    $w configure -state disabled
    return $renamed
}

# If enabled will automatically write the "Engine list" file when
# the configFrame is destroyed.
proc ::enginecfg::autoSaveConfig {id configFrame {autosave false}} {
    if {$autosave} {
        bind $configFrame.text <Destroy> "
            ::enginecfg::save \[ set ::enginecfg::engConfig_$id \]
        "
    } else {
        bind $configFrame.text <Destroy> {}
    }
}

# Find an option by name (case insensitive).
# Return the index of options or throw an exception if the option do not exists.
proc ::enginecfg::findOption {id name} {
    set options [lindex [set ::enginecfg::engConfig_$id] 8]
    for {set idx 0} {$idx < [llength $options]} {incr idx} {
        lassign [lindex $options $idx] option_name
        if {[string equal -nocase $name $option_name]} {
            return $idx
        }
    }
    error "wrong option"
}

# Move keyboard focus to the widget associated with an option.
# The option can be specified by name (case insensitive) or by index.
# Returns true if focus was successfully set, false otherwise.
proc ::enginecfg::focusOption {id configFrame option} {
    if {[string is integer -strict $option]} {
        set idx $option
    } else {
        set idx [::enginecfg::findOption $id $option]
    }
    set w $configFrame.text
    set widget $w.value$idx
    if {![winfo exists $widget]} {
        set widget $w.button$idx
    }
    if {[winfo exists $widget]} {
        $w see $widget
        focus $widget
        return true
    }
    return false
}

# Sends a SetOptions message to the engine if an option's value is different.
# Return true if a message was sent to the engine.
# Throw an exception in case of error.
proc ::enginecfg::setOption {id idx value} {
    lassign [lindex [set ::enginecfg::engConfig_$id] 8 $idx] \
        name oldValue type default min max

    if {$value eq $oldValue} { return false }

    if {$value eq ""} {
        set value $default
    } elseif {$min != "" && $max != ""} {
        if {$value < $min || $value > $max} {
            error "wrong value"
        }
    } elseif {![catch { set values [$widget cget -values] }]} {
        if {[set idx [lsearch -exact -nocase $values $value]] != -1} {
            set value [lindex $values $idx]
        } else {
            error "wrong value"
        }
    }
    # The review's own switches are stored in the config and go no further: the
    # engine has no such option, so there is nothing to set on it. The value is
    # written into element 8 here because no handshake reply will ever bring it
    # back, and then saved at once: there is no SetOptions reply to make the
    # frame's own save run, so a pass started from this window - and every reader
    # of ::engines(list) - must see the value the switch shows. Only this one row
    # is written to the preset, not the window's whole snapshot: a second window
    # on the same preset may be holding an older value and must not revert it.
    #
    # A write failure is not caught here: ::enginecfg::onReviewToggle turns it
    # into the switch's error style, the same mark an engine option gets when the
    # engine refuses a value.
    if {[::enginecfg::isReviewOption $name]} {
        set row [lreplace [lindex [set ::enginecfg::engConfig_$id] 8 $idx] 1 1 $value]
        set ::enginecfg::engConfig_$id \
            [lreplace [set ::enginecfg::engConfig_$id] 8 8 \
                [lreplace [lindex [set ::enginecfg::engConfig_$id] 8] $idx $idx $row]]
        ::enginecfg::saveReviewOption [lindex [set ::enginecfg::engConfig_$id] 0] \
            $name $value $default
        return true
    }
    ::engine::send $id SetOptions [list [list $name $value]]
    return true
}

# Read an option's value from a widget and if it has changed sends a SetOptions
# message to the engine.
# Return true if a message was sent to the engine.
# On error the widget style is set to Error.WidgetType
proc ::enginecfg::setOptionFromWidget {id idx widget} {
    set value [$widget get]
    if {[catch {::enginecfg::setOption $id $idx $value} res]} {
        $widget configure -style Error.[winfo class $widget]
        return false
    }
    $widget configure -style {}
    return $res
}

# Creates the widgets for engine configuration, like the engine path, command
# line parameters, uci/xboard protocol, etc...
proc ::enginecfg::createConfigWidgets {id configFrame engCfg} {
    lassign $engCfg name cmd args wdir elo time url uci
    lassign $url scoreside notation pvwrap debugframe priority netport

    set w $configFrame.text

    $w delete 1.0 end

    # Use the last element from the sorted list of the labels' width.
    $w configure -tabs [lindex [lsort -integer [lmap elem [list \
        EngineCmd EngineArgs EngineDir EngineProtocol EngineNotation \
        EngineFlipEvaluation EngineShowLog LowPriority EngineNetworkd] {
             font measure font_Regular -displayof $w "[tr $elem]: "
        }]] end]

    if {$name == ""} {
        return false
    }

    set fn_create_entry {{w widget label value} {
        $w insert end "$label:\t"
        ttk::entry $w.$widget
        $w window create end -window $w.$widget -pady 2
        $w.$widget insert end "$value"
        set wd [string length $value]
        if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
        $w.$widget configure -width $wd
    }}

    set fn_reconnect [list apply {{id configFrame {W %W}} {
        switch [winfo name $W] {
            "cmd"      { set configIdx 1; set newValue [$W get] }
            "cmdbtn"   { set configIdx 1; set dlgcmd tk_getOpenFile }
            "args"     { set configIdx 2; set newValue [$W get] }
            "wdir"     { set configIdx 3; set newValue [$W get] }
            "wdirbtn"  { set configIdx 3; set dlgcmd tk_chooseDirectory }
            "protocol" { set configIdx 7; set newValue [$W current] }
            default { error "wrong option" }
        }
        upvar ::enginecfg::engConfig_$id engConfig_
        set oldValue [lindex $engConfig_ $configIdx]
        if {[info exists dlgcmd]} {
            set newValue [$dlgcmd -initialdir [file dirname $oldValue]]
            if {$newValue == ""} {
                return
            }
        }
        if {$newValue ne $oldValue} {
            lset engConfig_ $configIdx $newValue
            event generate $configFrame <<EngineCfgConnect>> \
                -data [list $id [::enginecfg::save $engConfig_]]
        }
    }} $id $configFrame]

    apply $fn_create_entry $w name [tr EngineName] $name
    bind $w.name <FocusOut> [list apply {{id configFrame} {
        lassign [set ::enginecfg::engConfig_$id] old
        if {$old ne [set name [%W get]]} {
            ::enginecfg::save [set ::enginecfg::engConfig_$id]
            event generate $configFrame <<EngineCfgConnect>> \
                -data [list $id [::enginecfg::rename $old $name]]
        }
    }} $id $configFrame]
    bind $w.name <Return> [bind $w.name <FocusOut>]

    apply $fn_create_entry $w cmd "\n[tr EngineCmd]" $cmd
    bind $w.cmd <FocusOut> $fn_reconnect
    bind $w.cmd <Return> [bind $w.cmd <FocusOut>]
    ttk::button $w.cmdbtn -style Pad0.Small.TButton -text ... \
        -command [list {*}$fn_reconnect $w.cmdbtn]
    $w window create end -window $w.cmdbtn -pady 2 -padx 2

    apply $fn_create_entry $w args "\n[tr EngineArgs]" $args
    bind $w.args <FocusOut> $fn_reconnect
    bind $w.args <Return> [bind $w.args <FocusOut>]

    apply $fn_create_entry $w wdir "\n[tr EngineDir]" $wdir
    bind $w.wdir <FocusOut> $fn_reconnect
    bind $w.wdir <Return> [bind $w.wdir <FocusOut>]
    ttk::button $w.wdirbtn -style Pad0.Small.TButton -text ... \
        -command [list {*}$fn_reconnect $w.wdirbtn]
    $w window create end -window $w.wdirbtn -pady 2 -padx 2

    if {$uci == 0 || $uci == 1} {
        $w insert end "\n[tr EngineProtocol]:\t"
        ttk::combobox $w.protocol -state readonly -width 12 -values {xboard uci}
        bind $w.protocol <<ComboboxSelected>> $fn_reconnect
        $w window create end -window $w.protocol -pady 2
        $w.protocol set [expr { $uci == 0 ? "xboard" : "uci" }]
    }

    $w insert end "\n[tr EngineNotation]:\t"
    ttk::combobox $w.notation -state readonly -width 12 -values [list engine SAN "English SAN" figurine]
    bind $w.notation <<ComboboxSelected>> "
        ::enginecfg::onChangeLayout $id $configFrame notation \[ $w.notation current \]
    "
    $w window create end -window $w.notation -pady 2
    $w.notation current [expr { $notation < 0 ? 0 - $notation : $notation }]
    ::enginecfg::onChangeLayout $id $configFrame notation $notation

    ttk::checkbutton $w.wrap -text [tr GInfoWrap] -onvalue word -offvalue none -style Toolbutton \
        -command "::enginecfg::onChangeLayout $id $configFrame wrap \[ set ::$w.wrap \]"
    $w window create end -window $w.wrap -pady 2 -padx 6
    set ::$w.wrap $pvwrap

    $w insert end "\n[tr EngineFlipEvaluation]:\t"
    ttk::checkbutton $w.scoreside -style Switch.Toolbutton -onvalue engine -offvalue white \
        -command "::enginecfg::onChangeLayout $id $configFrame scoreside \[::update_switch_btn $w.scoreside \]"
    ::update_switch_btn $w.scoreside $scoreside
    $w window create end -window $w.scoreside -pady 2

    $w insert end "\n[tr EngineShowLog]:\t"
    ttk::checkbutton $w.debug -style Switch.Toolbutton \
        -command "::enginecfg::onChangeLayout $id $configFrame debug \[::update_switch_btn $w.debug \]"
    ::update_switch_btn $w.debug $debugframe
    $w window create end -window $w.debug -pady 2

    if {[catch {::engine::pid $id} enginePid]} {
        return false
    }
    if {$enginePid != ""} {
        $w insert end "\n[tr LowPriority]:\t"
        ttk::checkbutton $w.priority -onvalue idle -offvalue normal \
            -style Switch.Toolbutton -command "
                catch { sc_info priority $enginePid \[ ::update_switch_btn $w.priority \] }
                lset ::enginecfg::engConfig_$id 6 4 \[ ::update_switch_btn $w.priority \]
            "
        ::update_switch_btn $w.priority $priority
        $w window create end -window $w.priority -pady 2
        $w insert end "  pid: $enginePid"
        if {$priority eq "idle"} {
            catch { sc_info priority $enginePid idle }
        }
    }

    $w insert end "\n[tr EngineNetworkd]:\t"
    ttk::combobox $w.netd -state readonly -width 12 -values {off on auto_port}
    $w window create end -window $w.netd -pady 2
    $w insert end "  port: "
    ttk::entry $w.netport -width 6 -validate key -validatecommand [list ::validate::integer %P 0]
    $w window create end -window $w.netport -pady 2
    bind $w.netd <<ComboboxSelected>> "::enginecfg::onSubmitNetd $id $w"
    bind $w.netport <FocusOut> "if {\"readonly\" ni \[$w.netport state\]} {
        ::enginecfg::onSubmitNetd $id $w
    }"
    bind $w.netport <Return> [bind $w.netport <FocusOut>]
    if {$netport eq ""} {
        $w.netd set "off"
        $w.netport configure -state disabled
    } elseif {[string match "auto_*" $netport]} {
        $w.netd set "auto_port"
        $w.netport insert 0 [string range $netport 5 end]
        $w.netport configure -state readonly
    } else {
        $w.netd set "on"
        $w.netport insert 0 $netport
    }
    $w insert end "\n" netclients_tag

    return true
}

# Creates the widgets used to show/change the engine's specific options
proc ::enginecfg::createOptionWidgets {id configFrame options} {
    set w $configFrame.text

    set tab_width 0
    set disableReset 1
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal} { continue }

        if {$disableReset} {
            set disableReset 0
            $w insert end "\n"
            ttk::button $w.reset -style Pad0.Small.TButton -text "Reset Options" \
                -command "::enginecfg::onSubmitReset $id $configFrame"
            $w window create end -window $w.reset
        }
        # The review's switches read as words ("Cloud pre-pass"), not as their
        # config keys: they are the dialog's own rows, not options an engine
        # advertised.
        set label $name
        if {[::enginecfg::isReviewOption $name]} {
            set label [::enginecfg::reviewOptionLabel $name]
        }
        $w insert end "\n$label:" opt_label "\t"
        set label_width [font measure font_Regular -displayof $w "$label: "]
        if {$label_width > $tab_width} {
            set tab_width $label_width
            $w tag configure opt_label -tabs $tab_width
        }
        set btn ""
        if {$type eq "button" || $type eq "save" || $type eq "reset"} {
            set btn $name
        } else {
            if {$type eq "combo"} {
                lassign [lsort -decreasing -integer [lmap elem $var_list { string length $elem }]] maxlen
                ttk::combobox $w.value$i -width [incr maxlen] -values $var_list -state readonly
                bind $w.value$i <<ComboboxSelected>> "::enginecfg::setOptionFromWidget $id $i %W"
            } elseif {$type eq "check"} {
                if {[::enginecfg::isReviewOption $name]} {
                    # The engine never answers for a review row, so the InfoConfig
                    # reply that repaints the panel and settles Reset after an
                    # engine option changes never comes for this one: the row
                    # settles both itself.
                    ttk::checkbutton $w.value$i -onvalue true -offvalue false -style Switch.Toolbutton -command \
                        "::enginecfg::onReviewToggle $id $i $configFrame $w.value$i"
                } else {
                    ttk::checkbutton $w.value$i -onvalue true -offvalue false -style Switch.Toolbutton -command \
                        "::enginecfg::setOption $id $i \[::update_switch_btn $w.value$i \]"
                }
            } else {
                if {$type eq "spin" || $type eq "slider"} {
                    ttk::spinbox $w.value$i -width 12 -from $min -to $max -increment 1 \
                        -validate key -validatecommand [list ::validate::integer %P $min $max] \
                        -command "after idle \[bind $w.value$i <FocusOut>\] "
                } else {
                    ttk::entry $w.value$i
                    if {$type eq "file"} {
                        set btn "..."
                    } elseif {$type eq "path"} {
                        set btn "+ ..."
                    }
                }
                # Special vars like %W cannot be used in <FocusOut> because the
                # other events are forwarded to it
                bind $w.value$i <FocusOut> "::enginecfg::setOptionFromWidget $id $i $w.value$i"
                bind $w.value$i <Return> [bind $w.value$i <FocusOut>]
            }
            $w window create end -window $w.value$i -pady 2
        }
        if {$btn ne ""} {
            ttk::button $w.button$i -style Pad0.Small.TButton -text $btn \
                -command "::enginecfg::onSubmitButton $id $i"
            $w window create end -window $w.button$i -padx 2 -pady 2
        } elseif {$type eq "spin" || $type eq "slider"} {
            $w insert end " (Range: $min ... $max)"
        }
    }
}

# Update the widgets with the engine's specific options
proc ::enginecfg::updateOptionWidgets {id configFrame options oldOptions} {
    set w $configFrame.text

    set disableReset 1
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal || $type in [list button save reset]} { continue }

        if {$disableReset && $value ne $default} {
            $w.reset configure -state normal
            set disableReset 0
        }

        if {$oldOptions ne "" && $value eq [lindex $oldOptions $i 1]} {
            if {$type eq "check"} {
                set widget_value [::update_switch_btn $w.value$i]
            } else {
                set widget_value [$w.value$i get]
            }
            if {$value eq $widget_value} { continue }
        }

        if {$value eq $default} {
            $w tag remove header "$w.value$i linestart" $w.value$i
        } else {
            $w tag add header "$w.value$i linestart" $w.value$i
        }
        if {$type eq "string" || $type eq "file" || $type eq "path"} {
            set wd [string length $value]
            if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
            $w.value$i configure -width $wd
        }
        if {$type eq "combo"} {
            $w.value$i set $value
        } elseif {$type eq "check"} {
            ::update_switch_btn $w.value$i $value
        } else {
            $w.value$i configure -style {}
            $w.value$i delete 0 end
            $w.value$i insert 0 $value
        }
    }
    if {$disableReset && [winfo exists $w.reset]} {
        $w.reset configure -state disabled
    }
}

proc ::enginecfg::updateNetClients {configFrame netclients} {
    set w $configFrame.text

    set strclients "\n"
    if {[llength $netclients]} {
        append strclients "Network Connections:"
        foreach client $netclients {
            append strclients "\t$client\n"
        }
    }
    $w replace netclients_tag.first netclients_tag.last $strclients netclients_tag
}

# Reset all the engine's options to their default values.
#
# The review's own rows in element 8 are reset with everything else: they are not
# engine options, so a SetOptions for them would set nothing on the engine, but the
# dialog's word "default" covers the whole panel the user is looking at - the panel
# that draws them. ::engineNoWin::initEngineOptions draws the engine's own rows only
# and leaves the review's row in element 8 with no widget; resetting that one would
# turn the Cloud pre-pass back on behind a switch the user cannot see, so a review
# row the panel does not render is left where it is.
proc ::enginecfg::onSubmitReset {id w} {
    upvar ::enginecfg::engConfig_$id engConfig_
    set options {}
    set index 0
    set reviewRows 0
    foreach option [lindex $engConfig_ 8] {
        lassign $option name value type default min max var_list internal
        if {! $internal && $value ne $default} {
            if {[::enginecfg::isReviewOption $name]} {
                if {[winfo exists $w.text.value$index]} {
                    # The switch is reset in memory and written to the preset;
                    # a failed write is the switch's error style, not a background
                    # error out of the Reset button.
                    if {[catch {::enginecfg::setOption $id $index $default}]} {
                        ::enginecfg::refreshReviewRows $id $w
                        $w.text.value$index configure \
                            -style Error.[winfo class $w.text.value$index]
                    } else {
                        set reviewRows 1
                    }
                }
            } else {
                lappend options [list $name $default]
            }
        }
        incr index
    }
    if {[llength $options]} {
        ::engine::send $id SetOptions $options
    }
    # The panel is normally repainted by the InfoConfig reply to the SetOptions
    # above (::enginecfg::updateOptionWidgets). The review's rows are not engine
    # options, so the engine never answers for them: a reset of only those rows
    # sends nothing, no reply comes, and they would go on showing the value the
    # user just reset.
    if {$reviewRows} {
        ::enginecfg::refreshReviewRows $id $w
    }
}

# Show the review's rows the values element 8 holds now, and settle the Reset
# button from the same pass.
#
# The button is part of it, in both directions. A panel whose every live row is
# back at its default has nothing left for Reset to do; a panel with a row away
# from its default offers it. The review's rows only ever change through this
# file - the engine never answers for them - so no InfoConfig reply comes to
# settle the button, and ::enginecfg::updateOptionWidgets is the only other code
# that sets it.
proc ::enginecfg::refreshReviewRows {id configFrame} {
    upvar ::enginecfg::engConfig_$id engConfig_
    set w $configFrame.text
    set options [lindex $engConfig_ 8]
    set awayFromDefault 0
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal || $type in [list button save reset]} { continue }
        # A review row without a widget is one this panel does not draw
        # (::engineNoWin::initEngineOptions): it shows nothing for Reset to put
        # back, so it is not one that offers the button either.
        if {[::enginecfg::isReviewOption $name] && ![winfo exists $w.value$i]} { continue }
        if {$value ne $default} { set awayFromDefault 1 }
        if {[::enginecfg::isReviewOption $name]} {
            ::update_switch_btn $w.value$i $value
            # The label is bold while the row is away from its default, exactly
            # as ::enginecfg::updateOptionWidgets paints an engine row. No
            # InfoConfig reply comes for a review row to do it, so the repaint
            # that settles the switch settles the mark too.
            if {$value eq $default} {
                $w tag remove header "$w.value$i linestart" $w.value$i
            } else {
                $w tag add header "$w.value$i linestart" $w.value$i
            }
        }
    }
    if {[winfo exists $w.reset]} {
        $w.reset configure -state [expr {$awayFromDefault ? "normal" : "disabled"}]
    }
}

# The checkbutton's own -command for a review switch: store the value in element
# 8 and settle the panel from it.
#
# The engine is not told and never answers (::enginecfg::setOption returns without
# sending for these rows), so this is where the row's effect on the Reset button
# lands: unticking one leaves the panel with something Reset can put back, and
# ticking it again takes that away.
proc ::enginecfg::onReviewToggle {id idx configFrame widget} {
    set value [::update_switch_btn $widget]
    if {[catch {::enginecfg::setOption $id $idx $value} res]} {
        $widget configure -style Error.[winfo class $widget]
        return false
    }
    $widget configure -style {}
    ::enginecfg::refreshReviewRows $id $configFrame
    return $res
}

# Invoked to send to the engine a button option that have no value.
# It also used for option of type "file" and type "path": a dialog is showed
# to select the path (a directory path is appended to the previous value).
# Also, for the options of type "file" or "path", the related widget that
# display the value is updated when the engine replies with InfoConfig.
proc ::enginecfg::onSubmitButton {id idx} {
    lassign [lindex [set ::enginecfg::engConfig_$id] 8 $idx] \
        name oldValue type default min max

    if {$type eq "file"} {
        set value [tk_getOpenFile]
        if {$value == ""} { return }
    } elseif {$type eq "path"} {
        set value [tk_chooseDirectory]
        if {$value == ""} { return }
        if {$oldValue ne "" && $oldValue ne "<empty>"} {
            append oldValue [expr {$::windowsOS ? ";" : ":"}]
            set value "$oldValue$value"
        }
    } else {
        set value ""
    }
    ::engine::send $id SetOptions [list [list $name $value]]
}

# Invoke ::engine::netserver to start/stop listening to remote connection.
# If successful it also updates engConfig_$id
# Return the listening port ("" is the engine is not accepting remote connection).
proc ::enginecfg::setupNetd {id netport} {
    set new_value ""
    if {[string match "auto_*" $netport]} {
        set new_value "auto_"
        set netport 0
    }
    set port [::engine::netserver $id $netport]
    append new_value $port
    lset ::enginecfg::engConfig_$id 6 5 $new_value
    return $port
}

# Invoked when the value of one of the netd widgets has changed.
# Invoke ::enginecfg::setupNetd and update the netd widgets accordingly.
proc ::enginecfg::onSubmitNetd {id w} {
    set old_value [lindex [set ::enginecfg::engConfig_$id] 6 5]

    switch [$w.netd get] {
      "auto_port" {
          set netport auto_
          set state readonly
      }
      "on" {
          set netport [$w.netport get]
          set state normal
      }
      default {
          set netport ""
          set state disabled
      }
    }
    $w.netport configure -state normal -style {}
    if {$old_value ne $netport} {
        if {[catch {
            set port [::enginecfg::setupNetd $id $netport]
            $w.netport delete 0 end
            $w.netport insert 0 $port
        }]} {
            $w.netport configure -style Error.TEntry
            ERROR::MessageBox
        }
    }
    $w.netport configure -state $state
}

proc ::enginecfg::onChangeLayout {id configFrame param value} {
    upvar ::enginecfg::engConfig_$id engConfig_
    switch $param {
        "scoreside" {
            set idx 0
        }
        "notation" {
            set idx 1
            if {$value < 0} {
                set value [expr { 0 - $value }]
            }
            # If it is an xboard engine with san=1 store it as a negative value
            foreach elem [lsearch -all -inline -index 0 [lindex $engConfig_ 8] "san"] {
                if {[lindex $elem 7]} {
                    set value [expr { 0 - $value }]
                    break
                }
            }
        }
        "wrap" {
            set idx 2
        }
        "debug" {
            set idx 3
        }
        default { error "changeLayout unknown $param" }
    }
    lset engConfig_ 6 $idx $value
    event generate $configFrame <<EngineCfgLayout>> -data [list $id $param $value]
}
