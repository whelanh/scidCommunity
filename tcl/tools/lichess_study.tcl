# lichess_study.tcl -- Publish games to a Lichess study.
# Copyright (C) 2026 TBergh98
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Publishes games from a scidCommunity database as new chapters of one of
# your Lichess studies. It replaces "export PGN -> open Lichess -> find the
# study -> add chapter -> import PGN" with one dialog. The feature was
# designed by TBergh98 (https://github.com/TBergh98).
#
# Where to find it:
#   * Game List window: select one or more games, right click,
#     "Publish to Lichess study (N)...".
#   * Tools menu: "Publish current game to Lichess study..." publishes the
#     game on the board, unsaved changes included.
# The dialog also sets the board orientation and the chapter mode (normal
# analysis, hide next moves, practice with computer, interactive lesson).
# Needs curl (bundled with scidCommunity on Windows, preinstalled on macOS
# and most Linux systems).
#
# Lichess API used (https://lichess.org/api#tag/Studies):
#   GET  /api/account                -> your username
#   GET  /api/study/by/{username}    -> your studies, private too (study:read)
#   GET  /api/study/{id}.pgn         -> name of a study added by link (study:read)
#   POST /api/study/{id}/import-pgn  -> one chapter per game (study:write)
#   POST /api/study                  -> create a new study (study:write); it
#                                       starts with one empty chapter, which
#                                       is deleted after the import
#   DELETE /api/study/{id}/{chapter} -> that empty chapter (study:write)
# For a new study with 64 games the first game is imported before the empty
# chapter is deleted and the other 63 after, so that all of them fit.
# A study holds at most 64 chapters. Before publishing, the chapters of the
# study are counted (GET /api/study/{id}.pgn); if the games do not all fit
# the user can abort, publish only the first ones, or publish the first ones
# and put the rest in a new study (named in the dialog). Lichess itself imports
# games one by one until the limit and then answers HTTP 200 with error "Too
# many chapters"; the feature shows that error in a dialog. Lichess has no
# endpoint listing the studies you only contribute to: add those once by
# pasting their link.
#
# Files kept in <user folder>/lichess_study/:
#   token.txt   your personal API token, in plain text
#   extra.txt   studies added by link (id <TAB> name, one per line; delete a
#               line to remove a study from the list)

namespace eval ::lichstudy {
    variable dir [file join $::scidUserDir lichess_study]
    variable maxChapters 64
    variable userAgent "scidCommunity-lichess-study"
    variable token ""
    variable studies {}     ;# {id name updatedAt byLink} for each study
    variable shown {}       ;# indexes into studies, in listbox order
    variable games {}       ;# the games to publish, one PGN text each
    variable filter ""
    variable orientation auto
    variable mode normal
    variable busy 0
    variable newName ""
    variable newVisibility private
    variable fresh {}       ;# {studyId emptyChapterId} of a study just created
    variable ovfAct split   ;# the "study is full" question (askOverflow)
    variable ovfName ""
    variable ovfMsg ""
    variable ovfDone 0
}

### Small helpers ###########################################################

# "1 game" / "5 games" for the dialog labels.
proc ::lichstudy::gamesText {n} {
    if {$n == 1} { return "1 [tr game]" }
    return "$n [tr games]"
}

proc ::lichstudy::readFile {path} {
    if {![file exists $path]} { return "" }
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set data [read $f]
    close $f
    return $data
}

proc ::lichstudy::writeFile {path data} {
    file mkdir [file dirname $path]
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $data
    close $f
}

# Decodes a JSON string body (\" \\ \/ \n \uXXXX ...). subst runs with
# commands and variables disabled, so only backslash escapes are expanded.
proc ::lichstudy::unescape {s} {
    return [subst -nocommands -novariables $s]
}

# Opens a link in the browser. On Windows scidCommunity's openURL goes
# through "cmd /c start", which cuts URLs at the first "&".
proc ::lichstudy::openLink {url} {
    if {$::tcl_platform(platform) eq "windows"} {
        catch {exec rundll32 url.dll,FileProtocolHandler $url &}
    } else {
        openURL $url
    }
}

# A link colour readable on both light and dark themes (plain "blue" is too
# dark against a dark theme's background).
proc ::lichstudy::linkColor {} {
    if {[info exists ::darkThemes] && [ttk::style theme use] in $::darkThemes} {
        return "#6db3f2"
    }
    return "#1a6ec4"
}

# Apply the current ttk theme's colours to a classic listbox. Classic Tk
# widgets do not follow ttk themes, so this is applied at creation and again
# whenever the theme changes.
proc ::lichstudy::applyThemeListbox {lb} {
    set bg [ttk::style lookup . -fieldbackground "" white]
    set fg [ttk::style lookup . -foreground "" black]
    set sbg [ttk::style lookup . -selectbackground "" #4a6984]
    set sfg [ttk::style lookup . -selectforeground "" white]
    catch {
        $lb configure -background $bg -foreground $fg \
            -selectbackground $sbg -selectforeground $sfg
    }
    bind $lb <<ThemeChanged>> [list ::lichstudy::applyThemeListbox $lb]
}

proc ::lichstudy::curlExe {} {
    set exe [auto_execok curl]
    if {$exe eq "" && [info exists ::scidExeDir]} {
        foreach name {curl.exe curl} {
            set c [file join $::scidExeDir $name]
            if {[file executable $c]} { return [list $c] }
        }
    }
    if {$exe eq ""} {
        error [tr LichessStudyCurlNotFound]
    }
    return $exe
}

# Calls the Lichess API with curl. Returns {httpCode body}.
# Extra curl arguments (e.g. --data-urlencode) make it a POST.
# The token is passed on stdin (-K -) so it never appears in the process
# list, and the body goes through a file so UTF-8 text survives on Windows.
proc ::lichstudy::api {url args} {
    variable token
    variable dir
    variable userAgent
    file mkdir $dir
    set out [file join $dir "reply_[pid].tmp"]
    set config ""
    if {$token ne ""} {
        append config "header = \"Authorization: Bearer $token\"\n"
    }
    set cmd [list {*}[curlExe] -s -S -K - --connect-timeout 15 --max-time 120 \
                 -A $userAgent -o $out -w "%{http_code}" {*}$args $url]
    set err [catch {exec {*}$cmd << $config} code]
    set body [readFile $out]
    file delete -force $out
    if {$err} { error [format [tr LichessStudyNetworkError] [string trim $code]] }
    return [list [string trim $code] $body]
}

# Clearer text for the Lichess error messages users are likely to meet.
proc ::lichstudy::friendly {msg} {
    variable maxChapters
    if {$msg eq "Too many chapters"} {
        return [format [tr LichessStudyFull] $maxChapters]
    }
    return $msg
}

# Free chapter slots of study $id, or -1 if they cannot be counted (the
# caller then just publishes and reports what Lichess says).
proc ::lichstudy::freeChapters {id} {
    variable maxChapters
    if {[catch {api "https://lichess.org/api/study/$id.pgn?clocks=false&comments=false&variations=false"} r]
        || [lindex $r 0] ne "200"} {
        return -1
    }
    return [expr {$maxChapters - [regexp -all {\[ChapterURL } [lindex $r 1]]}]
}

proc ::lichstudy::errorText {code body} {
    if {[regexp {"error"\s*:\s*"((?:[^"\\]|\\.)*)"} $body -> msg]} {
        set msg [unescape $msg]
    } else {
        set msg ""
    }
    switch -- $code {
        000 { return [tr LichessStudyNoAnswer] }
        401 { return [tr LichessStudy401] }
        403 { return [tr LichessStudy403] }
        404 { return [tr LichessStudy404] }
        429 { return [tr LichessStudy429] }
    }
    if {$msg ne ""} { return [format [tr LichessStudyHttpError] $code [friendly $msg]] }
    set body [string trim $body]
    if {[string length $body] > 200} { set body "[string range $body 0 199]..." }
    return [format [tr LichessStudyUnexpected] $code $body]
}

### Games -> PGN ############################################################

# Standard PGN for Lichess: NAGs as $n (Lichess shows them as !, ?!, +- ...),
# no column or indentation layout, and [%csl]/[%cal] marks kept so coloured
# squares and arrows appear in the study. -base/-gameNumber must come before
# these options, because sc_game pgn applies them to the game it selected.
proc ::lichstudy::pgnOptions {} {
    return {-width 80 -tags 1 -comments 1 -variations 1 -symbols 0
            -indentVariations 0 -indentComments 0 -space 0 -column 0
            -markCodes 0 -unicode 0 -format plain}
}

# Lichess splits a multi-game PGN at a blank line followed by "[", so the
# movetext of each game must not contain blank lines.
proc ::lichstudy::cleanGame {txt} {
    set txt [string trim [string map {"\r" ""} $txt]]
    set i [string first "\n\n" $txt]
    if {$i < 0} { return $txt }
    set head [string range $txt 0 [expr {$i - 1}]]
    set moves [string range $txt [expr {$i + 2}] end]
    regsub -all {\n(?:[ \t]*\n)+} $moves "\n" moves
    return "$head\n\n[string trim $moves]"
}

# PGN of game $num of base $base, read from the database without loading it
# (so the board, the current game and the current base stay as they are).
# The game on the board with unsaved changes is taken as shown on screen.
proc ::lichstudy::gamePgn {base num} {
    if {$base == [sc_base current] && $num == [sc_game number] && [sc_game altered]} {
        set txt [sc_game pgn {*}[pgnOptions]]
    } else {
        if {$num < 1 || $num > [sc_base numGames $base]} {
            error [format [tr LichessStudyGameNotFound] $num]
        }
        set txt [sc_game pgn -base $base -gameNumber $num {*}[pgnOptions]]
    }
    if {![string match {\[*} [string trimleft $txt]]} {
        error [format [tr LichessStudyCannotRead] $num $txt]
    }
    return [cleanGame $txt]
}

# Game numbers from Game List item ids ("123" or "123_45").
proc ::lichstudy::selectionNumbers {items} {
    set nums {}
    foreach s $items {
        lassign [split [string trim $s] "_"] idx
        if {[string is integer -strict $idx] && $idx > 0 && $idx ni $nums} {
            lappend nums $idx
        }
    }
    return $nums
}

proc ::lichstudy::publishGames {base nums} {
    variable maxChapters
    if {![sc_base inUse $base]} {
        tk_messageBox -icon warning -title [tr LichessStudyTitle] \
            -message [tr LichessStudyDbClosed]
        return
    }
    set n [llength $nums]
    if {$n == 0} { return }
    if {$n > $maxChapters} {
        tk_messageBox -icon warning -title [tr LichessStudyTitle] \
            -message [format [tr LichessStudyTooManyGames] $n $maxChapters]
        return
    }
    set games {}
    if {[catch {
        foreach num $nums { lappend games [gamePgn $base $num] }
    } msg]} {
        tk_messageBox -icon warning -title [tr LichessStudyTitle] -message $msg
        return
    }
    openDialog $games
}

proc ::lichstudy::publishCurrent {} {
    if {[sc_game number] == 0 && ![sc_game altered]} {
        tk_messageBox -icon info -title [tr LichessStudyTitle] \
            -message [tr LichessStudyNoGame]
        return
    }
    if {[catch {cleanGame [sc_game pgn {*}[pgnOptions]]} pgn]} {
        tk_messageBox -icon warning -title [tr LichessStudyTitle] -message $pgn
        return
    }
    openDialog [list $pgn]
}

### Studies #################################################################

proc ::lichstudy::loadStudies {} {
    variable studies
    variable dir
    set studies {}

    lassign [api https://lichess.org/api/account] code body
    if {$code ne "200"} { error [errorText $code $body] }
    if {![regexp {"username"\s*:\s*"([^"]+)"} $body -> user]} {
        error [tr LichessStudyNoUsername]
    }

    lassign [api https://lichess.org/api/study/by/$user] code body
    if {$code ne "200"} { error [errorText $code $body] }
    set own {}
    foreach line [split $body "\n"] {
        if {[regexp {"id"\s*:\s*"([^"]+)"} $line -> id]
            && [regexp {"name"\s*:\s*"((?:[^"\\]|\\.)*)"} $line -> nm]} {
            set up 0
            regexp {"updatedAt"\s*:\s*([0-9]+)} $line -> up
            lappend own [list $id [unescape $nm] $up 0]
        }
    }
    # Most recently updated first.
    set studies [lsort -integer -decreasing -index 2 $own]

    # Studies added by link (ones you contribute to but do not own).
    set ids [lmap s $studies {lindex $s 0}]
    foreach line [split [readFile [file join $dir extra.txt]] "\n"] {
        lassign [split $line "\t"] id nm
        set id [string trim $id]
        if {$id ne "" && $id ni $ids} {
            lappend studies [list $id $nm 0 1]
            lappend ids $id
        }
    }
    return $user
}

proc ::lichstudy::applyFilter {w} {
    variable studies
    variable shown
    variable filter
    if {![winfo exists $w.l.list]} { return }
    $w.l.list delete 0 end
    set shown {}
    set i 0
    foreach s $studies {
        lassign $s id nm up byLink
        if {$filter eq "" || [string first [string tolower $filter] [string tolower $nm]] >= 0} {
            if {$byLink} { append nm "   ([tr LichessStudyAddedByLink])" }
            $w.l.list insert end $nm
            lappend shown $i
        }
        incr i
    }
}

proc ::lichstudy::setStatus {w text} {
    if {[winfo exists $w.status]} {
        $w.status configure -text $text
        update idletasks
    }
}

proc ::lichstudy::refresh {w} {
    variable studies
    variable token
    if {![winfo exists $w]} { return }
    if {$token eq ""} {
        setStatus $w [tr LichessStudyNeedToken]
        return
    }
    setStatus $w [tr LichessStudyLoading]
    $w configure -cursor watch
    set err [catch {loadStudies} res]
    if {![winfo exists $w]} { return }
    $w configure -cursor ""
    applyFilter $w
    if {$err} {
        setStatus $w $res
    } else {
        setStatus $w [format [tr LichessStudyAccountStatus] $res [llength $studies]]
    }
}

proc ::lichstudy::saveToken {w} {
    variable token
    variable dir
    set t [string trim [$w.tok.e get]]
    if {$t ne "" && ![regexp {^[A-Za-z0-9_]+$} $t]} {
        setStatus $w [tr LichessStudyTokenInvalid]
        return
    }
    set token $t
    set path [file join $dir token.txt]
    writeFile $path $token
    # The token grants access to the user's Lichess account, so keep the file
    # readable only by its owner on Unix (options.tcl does the same for
    # options.dat). On Windows -permissions is unsupported and the catch is a
    # no-op.
    catch { file attributes $path -permissions 0600 }
    refresh $w
}

proc ::lichstudy::addByLink {w} {
    variable dir
    variable token
    set txt [string trim [$w.add.e get]]
    if {![regexp {lichess\.org/study/([A-Za-z0-9]{8})} $txt -> id]
        && ![regexp {^([A-Za-z0-9]{8})$} $txt -> id]} {
        tk_messageBox -parent $w -icon warning -title [tr LichessStudyTitle] \
            -message [tr LichessStudyAddLinkPrompt]
        return
    }
    if {$token eq ""} {
        setStatus $w [tr LichessStudySaveTokenFirst]
        return
    }
    setStatus $w [format [tr LichessStudyChecking] $id]
    if {[catch {api "https://lichess.org/api/study/$id.pgn?clocks=false&comments=false&variations=false"} res]} {
        setStatus $w $res
        return
    }
    lassign $res code body
    if {$code ne "200"} {
        setStatus $w [errorText $code $body]
        return
    }
    set nm [format [tr LichessStudyUnnamed] $id]
    if {[regexp {\[StudyName "((?:[^"\\]|\\.)*)"\]} $body -> raw]} {
        set nm [string map {\\\" \" \\\\ \\} $raw]
    }
    set nm [string map {"\t" " " "\n" " "} $nm]
    set path [file join $dir extra.txt]
    set data [readFile $path]
    if {![regexp -line "^$id\t" $data]} {
        if {$data ne "" && [string index $data end] ne "\n"} { append data "\n" }
        append data "$id\t$nm\n"
        writeFile $path $data
    }
    $w.add.e delete 0 end
    refresh $w
}

### Dialog ##################################################################

proc ::lichstudy::publish {w} {
    variable studies
    variable shown
    variable busy
    if {$busy} { return }
    set sel [$w.l.list curselection]
    if {$sel eq ""} {
        tk_messageBox -parent $w -icon info -title [tr LichessStudyTitle] \
            -message [tr LichessStudyPickStudy]
        return
    }
    lassign [lindex $studies [lindex $shown $sel]] id nm
    doPublish $w $id $nm
}

# Creates a study named $nm and returns its id; raises a readable error.
# The new study holds one empty chapter: it is remembered in "fresh" to be
# deleted after the import (if it cannot be found, it just stays).
proc ::lichstudy::createStudy {nm} {
    variable dir
    variable newVisibility
    variable fresh
    # The name goes through a file so UTF-8 survives on Windows.
    set file [file join $dir "name_[pid].txt"]
    writeFile $file $nm
    set err [catch {api https://lichess.org/api/study \
        --data-urlencode "name@$file" --data-urlencode "visibility=$newVisibility" \
        --data-urlencode computer=everyone --data-urlencode explorer=everyone \
        --data-urlencode cloneable=everyone --data-urlencode shareable=everyone \
        --data-urlencode chat=everyone} res]
    file delete -force $file
    if {$err} { error $res }
    lassign $res code body
    if {$code ne "200" || ![regexp {"id"\s*:\s*"([^"]+)"} $body -> id]} {
        error [errorText $code $body]
    }
    set fresh [list $id ""]
    if {![catch {api "https://lichess.org/api/study/$id.pgn?clocks=false&comments=false&variations=false"} r]
        && [lindex $r 0] eq "200"} {
        set urls [regexp -all -inline {\[ChapterURL "[^"]*/([A-Za-z0-9]{8})"\]} [lindex $r 1]]
        if {[llength $urls] == 2} { set fresh [list $id [lindex $urls 1]] }
    }
    return $id
}

# Creates a new study from the "New study" fields, selects it in the list
# and publishes into it. If the publish fails the study stays selected, so
# pressing "Publish" retries without creating a second one (Lichess allows
# 30 new studies a day).
proc ::lichstudy::createAndPublish {w} {
    variable token
    variable dir
    variable studies
    variable filter
    variable newName
    variable newVisibility
    variable fresh
    variable busy
    if {$busy} { return }
    set nm [string trim $newName]
    if {[string length $nm] < 2 || [string length $nm] > 100} {
        setStatus $w [tr LichessStudyNameLength]
        return
    }
    if {$token eq ""} {
        setStatus $w [tr LichessStudySaveTokenFirst]
        return
    }

    set busy 1
    $w.btn.pub state disabled
    $w.new.go state disabled
    $w configure -cursor watch
    setStatus $w [format [tr LichessStudyCreating] $nm]

    set err [catch {createStudy $nm} id]

    set busy 0
    if {![winfo exists $w]} { return }
    $w configure -cursor ""
    $w.btn.pub state !disabled
    $w.new.go state !disabled
    if {$err} { setStatus $w $id; return }

    set studies [linsert $studies 0 [list $id $nm 0 0]]
    set filter ""
    applyFilter $w
    $w.l.list selection set 0
    set newName ""
    doPublish $w $id $nm
}

# Imports a list of games into study $id, one chapter each.
# Returns {httpCode body}; raises an error on network failure.
proc ::lichstudy::importGames {id gameList} {
    variable orientation
    variable mode
    variable dir
    set file [file join $dir "upload_[pid].pgn"]
    writeFile $file "[join $gameList "\n\n\n"]\n"
    set opts [list --data-urlencode "pgn@$file"]
    if {$orientation ne "auto"} {
        lappend opts --data-urlencode "orientation=$orientation"
    }
    # Normal analysis is Lichess' default: the API wants no "mode" for it.
    if {$mode ne "normal"} {
        lappend opts --data-urlencode "mode=$mode"
    }
    set err [catch {api https://lichess.org/api/study/$id/import-pgn {*}$opts} res]
    file delete -force $file
    if {$err} { error $res }
    return $res
}

# Ends the "busy" state of the dialog. Returns 0 if the dialog is gone.
proc ::lichstudy::idle {w} {
    variable busy
    set busy 0
    if {![winfo exists $w]} { return 0 }
    $w configure -cursor ""
    $w.btn.pub state !disabled
    $w.new.go state !disabled
    return 1
}

# Imports $gameList into study $id. Returns {created problem}; problem is ""
# or a text starting with a blank line.
proc ::lichstudy::importChunked {id gameList} {
    variable fresh
    variable maxChapters
    # A study created by this dialog holds an empty chapter that counts toward
    # the 64-chapter limit. Up to 63 games fit next to it: import all, then
    # delete it. Only 64 games need two steps: the first game, delete the
    # empty chapter, then the other 63.
    set chunks [list $gameList]
    if {$id eq [lindex $fresh 0] && [lindex $fresh 1] ne "" && [llength $gameList] >= $maxChapters} {
        set chunks [list [lrange $gameList 0 0] [lrange $gameList 1 end]]
    }
    set created 0
    foreach chunk $chunks {
        if {![llength $chunk]} { continue }
        if {[catch {importGames $id $chunk} res]} {
            return [list $created "\n\n$res"]
        }
        lassign $res code body
        if {$code ne "200"} {
            return [list $created "\n\n[errorText $code $body]"]
        }
        # {"chapters":[{"id":..,"name":..,...},...],"error":null|"..."}
        set n [regexp -all {"id"\s*:\s*} $body]
        incr created $n
        if {$n > 0 && $id eq [lindex $fresh 0]} {
            if {[lindex $fresh 1] ne ""} {
                catch {api https://lichess.org/api/study/$id/[lindex $fresh 1] -X DELETE}
            }
            set fresh {}
        }
        if {[regexp {"error"\s*:\s*"((?:[^"\\]|\\.)*)"} $body -> msg]} {
            return [list $created "\n\n[format [tr LichessStudyReports] [friendly [unescape $msg]]]"]
        }
    }
    return [list $created ""]
}

# Default name for the study that takes the games that do not fit: "nm (2)",
# or "nm (3)" if nm already ends with "(2)". The base is shortened so the
# number always survives the 100-character limit; cutting "nm (2)" itself
# could give back exactly nm.
proc ::lichstudy::nextName {nm} {
    set nm [string trim $nm]
    set num 2
    if {[regexp {^(.*\S)\s*\((\d{1,6})\)$} $nm -> base n]} {
        set nm $base
        set num [expr {[scan $n %d] + 1}]
    }
    set suffix " ($num)"
    set nm [string trimright [string range $nm 0 [expr {99 - [string length $suffix]}]]]
    return "$nm$suffix"
}

proc ::lichstudy::ovfDestroyed {win d} {
    variable ovfDone
    if {$win eq $d && $ovfDone == -1} { set ovfDone 0 }
}

# Modal question when the games do not fit in the study. Returns {} (abort),
# {first} (publish only the first $free) or {split name} (the first $free here,
# the others in a new study called "name").
proc ::lichstudy::askOverflow {w nm free nGames} {
    variable maxChapters
    variable ovfAct
    variable ovfName
    variable ovfMsg
    variable ovfDone
    set rest [expr {$nGames - $free}]
    set d $w.ovf
    destroy $d
    toplevel $d -background [ttk::style lookup . -background]
    wm title $d [tr LichessStudyTitle]
    wm transient $d $w
    wm protocol $d WM_DELETE_WINDOW {set ::lichstudy::ovfDone 0}
    # Closing the publish dialog destroys this one too: count it as "Abort",
    # or the vwait below would never return.
    bind $d <Destroy> [list ::lichstudy::ovfDestroyed %W $d]
    set ovfAct split
    set ovfName [nextName $nm]
    set ovfMsg ""
    set ovfDone -1

    if {$free > 0} {
        set txt [format [tr LichessStudyOvfFree] $nm $free $maxChapters $nGames]
    } else {
        set txt [format [tr LichessStudyOvfFull] $nm $maxChapters]
    }
    ttk::label $d.msg -wraplength 480 -justify left \
        -text [format [tr LichessStudyOvfQuestion] $txt]
    pack $d.msg -padx 12 -pady {12 6} -anchor w
    if {$free > 0} {
        ttk::radiobutton $d.r1 -variable ::lichstudy::ovfAct -value first \
            -text [format [tr LichessStudyOvfFirst] $free $rest]
        pack $d.r1 -padx 12 -anchor w
        set t2 [format [tr LichessStudyOvfSplit] $free $rest]
    } else {
        set t2 [format [tr LichessStudyOvfAllNew] $nGames]
    }
    ttk::radiobutton $d.r2 -variable ::lichstudy::ovfAct -value split -text $t2
    pack $d.r2 -padx 12 -anchor w
    ttk::frame $d.n
    ttk::label $d.n.l -text [tr LichessStudyOvfName]
    ttk::entry $d.n.e -textvariable ::lichstudy::ovfName -width 42
    pack $d.n.l $d.n.e -side left -padx {0 6}
    pack $d.n -padx {34 12} -pady 4 -anchor w
    ttk::label $d.err -textvariable ::lichstudy::ovfMsg -foreground red
    pack $d.err -padx 12 -anchor w
    ttk::frame $d.b
    ttk::button $d.b.ok -text [tr LichessStudyPublishButton] \
        -command {set ::lichstudy::ovfDone 1}
    ttk::button $d.b.no -text [tr Abort] -command {set ::lichstudy::ovfDone 0}
    pack $d.b.no $d.b.ok -side right -padx 4
    pack $d.b -padx 12 -pady 12 -fill x
    catch {::tk::PlaceWindow $d widget $w}

    update
    catch {grab $d}
    # If the dialog was destroyed while `update` drained events, ovfDone was
    # already cleared (the <Destroy> binding) and the vwait below would wait
    # forever. Treat a vanished dialog as "abort".
    if {![winfo exists $d]} {
        return {}
    }
    while 1 {
        vwait ::lichstudy::ovfDone
        if {$ovfDone == 0} { break }
        if {$ovfAct eq "first"} { break }
        set l [string length [string trim $ovfName]]
        if {$l >= 2 && $l <= 100} { break }
        set ovfMsg [tr LichessStudyNameLength]
        set ovfDone -1
    }
    set act $ovfAct
    set name [string trim $ovfName]
    set done $ovfDone
    destroy $d
    if {!$done} { return {} }
    if {$act eq "first"} { return [list first] }
    return [list split $name]
}

proc ::lichstudy::doPublish {w id nm} {
    variable games
    variable busy
    variable fresh
    variable studies
    variable filter
    if {$busy} { return }
    set nGames [llength $games]

    set busy 1
    $w.btn.pub state disabled
    $w.new.go state disabled
    $w configure -cursor watch

    # Lichess imports games one by one until the study reaches 64 chapters,
    # then stops with "Too many chapters" (HTTP 200: the earlier games are
    # kept). So count the free slots first and let the user decide. A study
    # created by this dialog is known to be empty: skip the check.
    # parts: {studyId name games} for each study to publish into, in order.
    set parts [list [list $id $nm $games]]
    set cut 0
    if {$id ne [lindex $fresh 0]} {
        setStatus $w [format [tr LichessStudyCheckingFree] $nm]
        set free [freeChapters $id]
        if {$free >= 0 && $nGames > $free} {
            set ans [askOverflow $w $nm $free $nGames]
            if {![llength $ans]} {
                idle $w
                setStatus $w [tr LichessStudyCancelled]
                return
            }
            set head [lrange $games 0 [expr {$free - 1}]]
            if {[lindex $ans 0] eq "first"} {
                set parts [list [list $id $nm $head]]
                set cut [expr {$nGames - $free}]
            } else {
                # Create the new study first: if that fails nothing is published.
                set newNm [lindex $ans 1]
                setStatus $w [format [tr LichessStudyCreating] $newNm]
                if {[catch {createStudy $newNm} newId]} {
                    idle $w
                    setStatus $w $newId
                    tk_messageBox -parent $w -icon error -title [tr LichessStudyTitle] \
                        -message [format [tr LichessStudyCreateFailed] $newNm $newId]
                    return
                }
                set parts [list [list $id $nm $head] [list $newId $newNm [lrange $games $free end]]]
            }
        }
    }

    # Every part is tried even if an earlier one fails: the games of the new
    # study do not depend on the old one (which may have been filled by
    # someone else since its chapters were counted).
    set created 0
    set problem ""
    set report {}
    set openId $id
    set emptyNew {}
    foreach part $parts {
        lassign $part pid pnm pgames
        if {![llength $pgames]} { continue }
        setStatus $w [format [tr LichessStudyPublishing] [llength $pgames] $pnm]
        lassign [importChunked $pid $pgames] n p
        incr created $n
        if {$n > 0} {
            lappend report [format [tr LichessStudyReportItem] $n $pnm]
            set openId $pid
        } elseif {$pid ne $id} {
            set emptyNew [list $pid $pnm]
        }
        if {$p ne ""} { append problem "\n\nIn \"$pnm\":$p" }
    }
    if {$cut} { append problem "\n\n[format [tr LichessStudyGamesNotPublished] $cut]" }
    if {[llength $emptyNew]} {
        lassign $emptyNew pid pnm
        append problem "\n\n[format [tr LichessStudyEmptyNew] $pnm \
            "https://lichess.org/study/$pid"]"
    }

    if {![idle $w]} { return }
    if {[llength $emptyNew]} {
        # List it, so publishing again uses it instead of making another one.
        set studies [linsert $studies 0 [list {*}$emptyNew 0 0]]
        set filter ""
        applyFilter $w
    }
    if {$created == 0 && $problem ne ""} {
        setStatus $w [string trim $problem]
        tk_messageBox -parent $w -icon error -title [tr LichessStudyTitle] \
            -message [format [tr LichessStudyNothingPublished] $problem]
        return
    }
    set icon [expr {$created == $nGames && $problem eq "" ? "info" : "warning"}]
    set ans [tk_messageBox -parent $w -type yesno -icon $icon -title [tr LichessStudyTitle] \
                 -message [format [tr LichessStudyReport] $created $nGames \
                               [join $report {, }] $problem]]
    if {$ans eq "yes"} { openLink "https://lichess.org/study/$openId" }
    if {$created > 0} {
        destroy $w
    } else {
        setStatus $w [format [tr LichessStudyNoChapters] $problem]
    }
}

proc ::lichstudy::openDialog {gameList} {
    variable token
    variable dir
    variable games
    variable filter
    variable busy

    set games $gameList
    set n [llength $games]
    set filter ""
    set busy 0
    set token [string trim [readFile [file join $dir token.txt]]]

    set w .lichstudy
    if {[winfo exists $w]} { destroy $w }
    toplevel $w -background [ttk::style lookup . -background]
    wm title $w [tr LichessStudyTitle]

    ttk::label $w.head -text [format [tr LichessStudyToPublish] [gamesText $n]]

    ttk::frame $w.tok
    ttk::label $w.tok.l -text [tr LichessStudyToken]
    ttk::entry $w.tok.e -width 34 -show "*"
    $w.tok.e insert 0 $token
    ttk::button $w.tok.save -text [tr Save] -command [list ::lichstudy::saveToken $w]
    ttk::label $w.tok.link -text [tr LichessStudyCreateToken] \
        -foreground [linkColor] -cursor hand2
    set url {https://lichess.org/account/oauth/token/create?scopes[]=study:read&scopes[]=study:write&description=scidCommunity+studies}
    bind $w.tok.link <ButtonRelease-1> [list ::lichstudy::openLink $url]
    grid $w.tok.l $w.tok.e $w.tok.save -sticky w -padx 2
    grid x $w.tok.link - -sticky w -padx 2

    ttk::frame $w.find
    ttk::label $w.find.l -text [tr LichessStudySearch]
    ttk::entry $w.find.e -width 30 -textvariable ::lichstudy::filter
    pack $w.find.l $w.find.e -side left -padx 2
    bind $w.find.e <KeyRelease> [list ::lichstudy::applyFilter $w]

    ttk::frame $w.l
    listbox $w.l.list -height 14 -width 60 -exportselection 0 \
        -yscrollcommand [list $w.l.sb set]
    applyThemeListbox $w.l.list
    ttk::scrollbar $w.l.sb -command [list $w.l.list yview]
    pack $w.l.sb -side right -fill y
    pack $w.l.list -side left -fill both -expand 1

    # Chapter settings, applied to every chapter created by this import.
    ttk::labelframe $w.opt -text [tr LichessStudyChapterSettings]
    ttk::label $w.opt.ol -text [tr LichessStudyOrientation]
    grid $w.opt.ol -row 0 -column 0 -sticky w -padx 4 -pady 2
    set col 1
    foreach {val tag} {auto LichessStudyOrientationAuto white White black Black} {
        ttk::radiobutton $w.opt.o$val -text [tr $tag] -value $val \
            -variable ::lichstudy::orientation
        grid $w.opt.o$val -row 0 -column $col -sticky w -padx 4 -pady 2
        incr col
    }
    ttk::label $w.opt.ml -text [tr LichessStudyAnalysisMode]
    grid $w.opt.ml -row 1 -column 0 -sticky nw -padx 4 -pady 2
    set row 1
    foreach {val tag} {
        normal   LichessStudyModeNormal
        conceal  LichessStudyModeConceal
        practice LichessStudyModePractice
        gamebook LichessStudyModeGamebook
    } {
        ttk::radiobutton $w.opt.m$val -text [tr $tag] -value $val \
            -variable ::lichstudy::mode
        grid $w.opt.m$val -row $row -column 1 -columnspan 3 -sticky w -padx 4
        incr row
    }

    ttk::labelframe $w.new -text [tr LichessStudyCreateNew]
    ttk::label $w.new.nl -text [tr LichessStudyName]
    ttk::entry $w.new.ne -width 28 -textvariable ::lichstudy::newName
    ttk::button $w.new.go -text [tr LichessStudyCreateAndPublish] \
        -command [list ::lichstudy::createAndPublish $w]
    grid $w.new.nl $w.new.ne $w.new.go -sticky w -padx 4 -pady 2
    ttk::label $w.new.vl -text [tr LichessStudyVisibility]
    ttk::radiobutton $w.new.vp -text [tr LichessStudyVisPrivate] -value private \
        -variable ::lichstudy::newVisibility
    ttk::radiobutton $w.new.vu -text [tr LichessStudyVisUnlisted] -value unlisted \
        -variable ::lichstudy::newVisibility
    ttk::radiobutton $w.new.vb -text [tr LichessStudyVisPublic] -value public \
        -variable ::lichstudy::newVisibility
    grid $w.new.vl $w.new.vp $w.new.vu $w.new.vb -sticky w -padx 4 -pady 2

    ttk::frame $w.add
    ttk::label $w.add.l -text [tr LichessStudyAddByLink]
    ttk::entry $w.add.e -width 34
    ttk::button $w.add.b -text [tr LichessStudyAddButton] \
        -command [list ::lichstudy::addByLink $w]
    pack $w.add.l $w.add.e $w.add.b -side left -padx 2

    ttk::label $w.status -text "" -wraplength 480 -justify left
    ttk::frame $w.btn
    ttk::button $w.btn.reload -text [tr LichessStudyReload] \
        -command [list ::lichstudy::refresh $w]
    ttk::button $w.btn.pub -text [tr LichessStudyPublishButton] \
        -command [list ::lichstudy::publish $w]
    ttk::button $w.btn.cancel -text [tr Cancel] -command [list destroy $w]
    pack $w.btn.reload -side left -padx 4
    pack $w.btn.cancel $w.btn.pub -side right -padx 4

    # Pack the bottom controls before the study list: when the window is
    # shorter than requested (Windows caps it at the screen height) the list
    # shrinks and keeps its scrollbar, instead of the buttons being cut off.
    pack $w.head -anchor w -padx 8 -pady {8 4}
    pack $w.tok -anchor w -padx 8 -pady 4
    pack $w.find -anchor w -padx 8 -pady 4
    pack $w.btn -side bottom -fill x -padx 8 -pady {4 8}
    pack $w.status -side bottom -anchor w -padx 8 -pady 4
    pack $w.add -side bottom -anchor w -padx 8 -pady 4
    pack $w.new -side bottom -fill x -padx 8 -pady 4
    pack $w.opt -side bottom -fill x -padx 8 -pady 4
    pack $w.l -fill both -expand 1 -padx 8 -pady 4
    bind $w <Escape> [list destroy $w]
    # Open over the Scid window, on whatever monitor it is on.
    catch {::tk::PlaceWindow $w widget .}

    after idle [list ::lichstudy::refresh $w]
}
