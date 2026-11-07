# Scid (Shane's Chess Information Database)
#
# Copyright (C) 1999-2004 Shane Hudson
# Copyright (C) 2006-2009 Pascal Georges
# Copyright (C) 2008-2011 Alexander Wagner
# Copyright (C) 2013-2015 Fulvio Benini
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.


####################################################
# Set default values


# Initialize a variable whose value will be restored when the program starts.
# default_value: set the variable to this value if it does not exists.
proc options.store {varname {default_value ""}} {
  if {![info exists $varname]} {
    set $varname $default_value
  }
  if {![info exists ::autosave_opt] || [lsearch -exact $::autosave_opt $varname] == -1} {
    lappend ::autosave_opt $varname
  }
}

proc InitDefaultToolbar {} {
  foreach {tbicon status}  {
    newdb 0 open 0 save 0 closedb 0
    finder 0 bkm 0 gprev 0 gnext 0
    newgame 0 copy 0 paste 0
    boardsearch 0 headersearch 0 materialsearch 0
    switcher 0 glist 0 pgn 0 tmt 0 maint 0 eco 0 tree 0 crosstab 0 engine 0
  } {
    set ::toolbar_state($tbicon) $status
  }
}

proc InitWinsDefaultGeometry {} {
  global winWidth winHeight

  # Default window size:
  set winWidth(.) 1024
  set winHeight(.) 570

  # Default help window size:
  set winWidth(.helpWin)  50
  set winHeight(.helpWin) 32

  # Default stats window size:
  set winWidth(.statsWin) 60
  set winHeight(.statsWin) 13

  # Default spellcheck results window size:
  set winWidth(.spellcheckWin)  55
  set winHeight(.spellcheckWin) 25

  # List of saved layouts : 3 slots available
  set ::docking::layout_list(1) {}
  set ::docking::layout_list(2) {{MainWindowGeometry 540x650+0+0} {{.pw vertical {}} {TNotebook .nb .fdockmain}}}
  set ::docking::layout_list(3) {{MainWindowGeometry 1280x670+0+0} {{.pw vertical {}} {TPanedwindow {{.pw.pw0 horizontal 487} {TPanedwindow {{.pw.pw0.pw0 vertical 82} {TNotebook .pw.pw0.pw0.tb0 .baseWin} {TNotebook .nb .main}}} {TPanedwindow {{.pw.pw0.pw1 vertical 337} {TNotebook .pw.pw0.tb0 .glistWin1} {TPanedwindow {{.pw.pw0.pw1.pw0 horizontal 346} {TNotebook .pw.pw0.pw1.tb0 {.commentWin .pgnWin}} {TNotebook .pw.pw0.pw1.pw0.tb0 .engineWin1}}}}}}}}}
  set ::docking::layout_list(auto) {{MainWindowGeometry 1280x670+0+0} {{.pw vertical {}} {TPanedwindow {{.pw.pw0 horizontal 487} {TPanedwindow {{.pw.pw0.pw0 vertical 82} {TNotebook .pw.pw0.pw0.tb0 .baseWin} {TNotebook .nb .main}}} {TPanedwindow {{.pw.pw0.pw1 vertical 337} {TNotebook .pw.pw0.tb0 .glistWin1} {TPanedwindow {{.pw.pw0.pw1.pw0 horizontal 346} {TNotebook .pw.pw0.pw1.tb0 {.commentWin .pgnWin}} {TNotebook .pw.pw0.pw1.pw0.tb0 .engineWin1}}}}}}}}}
}

proc InitDefaultStats {} {
  # Default stats window lines:
  array set ::windows::stats::display {
    r2600 1
    r2500 1
    r2400 1
    r2300 1
    r2200 0
    r2100 0
    r2000 0
    y1900 0
    y1950 0
    y1960 0
    y1970 0
    y1980 0
    y1990 0
    y1995 0
    y2000 1
    y2002 1
    y2004 1
    y2006 1
    y2007 1
    y2008 1
  }

  # Enable stats for subsequent years
  for { set year [clock format [clock seconds] -format {%Y}] } \
    { $year>2008 && ![info exists ::windows::stats::display([subst {y$year}])] } \
    { incr year -1 } {
    set ::windows::stats::display([subst {y$year}]) 1
  }
}

proc InitDefaultFonts {} {
  global fontOptions
  if {$::windowsOS} {
    set fontOptions(Regular) [list {Segoe UI}   10 normal roman]
    set fontOptions(Menu)    [list {Segoe UI}   10 normal roman]
    set fontOptions(Small)   [list {Segoe UI}    8 normal roman]
    set fontOptions(Tiny)    [list {Segoe UI}    7 normal roman]
    set fontOptions(Fixed)   [list courier       9 normal roman]
  } elseif {$::macOS} {
    set fontOptions(Regular) {}
    set fontOptions(Menu)    {}
    set fontOptions(Small)   {}
    set fontOptions(Tiny)    {}
    set fontOptions(Fixed)   [list Monaco              10 normal roman]
  } else {
    set family [lsearch -inline -nocase [font families] "droid sans"]
    if {$family eq ""} {
        set family [font actual TkDefaultFont -family]
    }
    set fixed [font actual TkFixedFont -family]
    set fontOptions(Regular) [list $family 11 normal roman]
    set fontOptions(Menu)    [list $family 11 normal roman]
    set fontOptions(Small)   [list $family  9 normal roman]
    set fontOptions(Tiny)    [list $family  8 normal roman]
    set fontOptions(Fixed)   [list $fixed  10 normal roman]
  }
}

proc InitDefaultAnnotate {} {
  set ::isBatchOpening 0
  set ::isBatchOpeningMoves 12
  set ::isBatch 0
  set ::markTacticalExercises 0
  set ::isAnnotateVar 0
  set ::isShortAnnotation 0
  set ::addScoreToShortAnnotations 0
  set ::addAnnotatorTag 0
  set ::annotateMoves all
  set ::annotateBlunders blundersonly
  set ::scoreAllMoves 0
  set ::useAnalysisBook 1
  set ::annotateWhiteMoves 1
  set ::annotateBlackMoves 1
  set ::annotationVariationLength 9
  # Blunder Threshold
  set ::blunderThreshold 1.0
}

InitDefaultFonts
InitWinsDefaultGeometry
InitDefaultToolbar
InitDefaultStats
InitDefaultAnnotate

#Default textures for lite and dark squares
set boardfile_dark "LightWood3-d"
set boardfile_lite "LightWood3-l"

# boardSize: Default board size.
set boardSize 40

# boardStyle: Default board piece set.
set boardStyle Neo-Wood

# Colors: squareColor_dark and squareColor_lite are square colors
#     whitecolor/blackcolor are piece colors
#     highcolor is the color when something is selected.
#     bestcolor is used to indicate a suggested move square.
set squareColor_lite "\#f3f3f3"
set squareColor_dark "\#7389b6"
set whitecolor  "\#ffffff"
set blackcolor  "\#000000"
set whiteborder "\#000000"
set blackborder "\#ffffff"
set highcolor   "\#b0d0e0"
set bestcolor   "\#bebebe"
set buttoncolor "\#b0c0d0"
set borderwidth 0

# Square markers color and type. The defaults are set here, before the options
# file is loaded; ::options.store (which makes them persist) is called further
# down, after the file has been loaded, so a saved value is not clobbered.
set ::markColor green
set ::markType square

# boardCoords: 1-4 to show board Coordinates, 0 to hide them.
set boardCoords 0

# autoResizeBoard:
# resize the board to fit the container
set autoResizeBoard 1

# showGameInfo:
# The game info panel below the main board
set showGameInfo 0

# language for help pages and messages:
set language E

# Default theme
set ::lookTheme "sand"
set ::ThemePackageFile ""

# Auto-apply the Omarchy-derived theme on Omarchy systems (no-op elsewhere)
set ::omarchyAutoTheme 1

# Auto-save options when exiting:
set optionsAutoSave 1

#  Numeric locale: first char is decimal, second is thousands.
#  Example: ".," for "1,234.5" format; ",." for "1.234,5" format.
set locale(numeric) ".,"

# Ask for piece translations (first letter)
set translatePieces 1

# Highlight the last move played
set arrowLastMove 0
set highlightLastMove 1
set highlightLastMoveNag 1
set highlightLastMoveEval 0
set highlightLastMoveWidth 2
set highlightLastMoveColor "grey"
set highlightLastMovePattern {} ; # this option is not saved

# Gloss Of Danger
set glossOfDanger 0

# Lichess/ChessBase format for annotations
set lichessFormat 1

# Show suggested moves: on by default
set suggestMoves 1

# Show variations popup window
set showVarPopup 0
set showVarArrows 1
set showEngineVariationArrows 1
# Number of moves (2 plies each) of each engine PV line to display in the
# Engine windows (F2/F3) and in the Analysis Engine window.
set ::enginePvDisplayLength 6
::options.store ::showMainEvalBarArrow 1

# Keyboard Move entry options:
set moveEntry(On) 1
set moveEntry(AutoExpand) 0
set moveEntry(Coord) 1

# windowsDock:
# if true, most of toplevel windows are dockable and embedded in a main window
# windows can be moves among tabs (drag and drop) or undocked (right-clicking on tab)
set windowsDock 1


set ::tactics::analysisTime 3

# Analysis command: to start chess analysis engine.
set analysisCommand ""
if {$windowsOS} {
  set analysisChoices {wcrafty.exe}
} else {
  set analysisChoices {crafty}
}

# Default Tree sort method:
set tree(order) frequency

# Default Tree move depth:
set tree(moveDepth) 1

### Tree/mask options:
set ::tree::mask::recentMask {}

# Defaults for the PGN window:
# if ::pgn::showColor is 1, the PGN text will be colorized.
set ::pgn::showColor 1
set ::pgn::indentVars 1
set ::pgn::indentComments 0
set ::pgn::symbolicNags 1
set ::pgn::moveNumberSpaces 0
set ::pgn::shortHeader 0
set ::pgn::boldMainLine 1
set ::pgn::columnFormat 0
set ::pgn::stripMarks 0
set ::pgn::showPhoto 1
set ::pgn::figurine 0
# How a repetition is announced in the PGN window: "off", "banner" (a
# non-blocking notice that fades by itself) or "dialog" (the modal message
# box). Only the presentation changes; threefold detection still ends games.
set ::pgn::repetitionAlert banner
set pgnColor(Var) ""
set pgnColor(Nag) {#cf6403}
set pgnColor(Comment) {#008b00}
set pgnColor(Current) steelBlue

# Defaults for FICS
set ::fics::use_timeseal 0
set ::fics::timeseal_exec "timeseal"
set ::fics::port_fics 5000
set ::fics::port_timeseal 5001
set ::fics::login ""
set ::fics::password ""
set ::fics::usedefaultvars 1
set ::fics::findopponent(initTime) 15
set ::fics::findopponent(incTime) 20
set ::fics::findopponent(rated) "rated"
set ::fics::findopponent(color) ""
set ::fics::findopponent(limitrating) 1
set ::fics::findopponent(rating1) 1500
set ::fics::findopponent(rating2) 3000
set ::fics::findopponent(manual) "auto"
set ::fics::findopponent(formula) ""
set ::fics::consolebg     black
set ::fics::consolefg     LimeGreen
set ::fics::consoleheight 10
set ::fics::consolewidth  40
set ::fics::colseeking     coral
set ::fics::colgame        grey70
set ::fics::colgameresult  SlateBlue1
set ::fics::colficspercent khaki1
set ::fics::colficshelpnext blue
set ::fics::server_ip "0.0.0.0"
set ::fics::premoveEnabled 1
set ::fics::playing 0

# Defaults for ICCF
set ::iccf::username ""
set ::iccf::password ""
set ::iccf::server "https://www.iccf.com/xfccbasic.asmx"
set ::iccf::playing 0
# Defaults for LSS
set ::lss::username ""
set ::lss::password ""
set ::lss::server "https://www.chess-server.net/de/api/server/xfcc/soap"
set ::lss::playing 0

# default resolvers for player info
set ::pinfo::wikipAPI      "http://de.wikipedia.org/w/api.php?action=query&format=xml"
# Appers PND resolver
set ::pinfo::wikipurl      "http://toolserver.org/~apper/pd/person/pnd-redirect"
# SeeAlso resolver for PND -> WikiPedia
set ::pinfo::SeeAlsoPND2WP "http://ws.gbv.de/seealso/pnd2wikipedia/?format=seealso&id="
# Deutsche NationalBibliothek
set ::pinfo::dnburl        "http://d-nb.info/gnd"
# all other ID resolvers come from [scidConfigFile resolvers]

# Defaults for Novag Citrine
set ::novag::referee "OFF"

# Defaults for Play versus Engine
set ::sergame::isOpening 0
set ::sergame::chosenOpening 0
set ::sergame::chosenEngine 0
set ::sergame::useBook 1
set ::sergame::bookToUse ""
set ::sergame::startFromCurrent 0
set ::sergame::coachIsWatching 0
set ::sergame::timeMode "timebonus"
set ::sergame::depth 3
set ::sergame::movetime 0
set ::sergame::nodes 10000
set ::sergame::ponder 0
set ::sergame::useChessClock 1
set ::sergame::showblunder 1
set ::sergame::showblundervalue 1
set ::sergame::showevaluation 1
set ::sergame::threshold 0.9
set ::sergame::isLimitedAnalysisTime 1
set ::sergame::analysisTime 10
set ::sergame::storeEval 0
set ::sergame::storeEvalAll 0
set ::sergame::coachIndex 0
set ::sergame::playerColor "white"
set ::uci::uciInfo(wtime1) [expr 5 * 60 * 1000 ]
set ::uci::uciInfo(winc1) [expr 10 * 1000 ]
set ::uci::uciInfo(btime1) [expr 5 * 60 * 1000 ]
set ::uci::uciInfo(binc1) [expr 10 * 1000 ]
set ::uci::uciInfo(fixeddepth1) 3
set ::uci::uciInfo(fixednodes1) 10000
set ::uci::uciInfo(movetime1) 3000

# Defaults for initial directories:
set initialDir(base) "."
set initialDir(pgn) "."
set initialDir(book) "."
set initialDir(html) "."
set initialDir(tex)  "."
set initialDir(stm)  "."
set initialDir(report) "."

# Default PGN display options:
set pgnStyle(Tags) 1
set pgnStyle(Comments) 1
set pgnStyle(Vars) 1

# Autoplay and animation delays in milliseconds:
set autoplayDelay 5000
set animateDelay 200
set autoplayMode 0

# Geometry of windows:
array set geometry {}

# startup:
#   Stores which windows should be opened on startup.
set startup(tip) 1


# Game information area options:
set gameInfo(photos) 1
set gameInfo(hideNextMove) 0
set gameInfo(showMaterial) 0
set gameInfo(showFEN) 0
set gameInfo(showMarks) 1
set gameInfo(wrap) 0
set gameInfo(fullComment) 0

# Twin deletion options:

array set twinSettings {
  players No
  colors  No
  event   No
  site    Yes
  round   Yes
  year    Yes
  month   Yes
  day     No
  result  No
  eco     No
  moves   Yes
  skipshort  Yes
  setfilter  Yes
  undelete   Yes
  comments   Yes
  variations Yes
  usefilter  No
  delete     Shorter
}
array set twinSettingsDefaults [array get twinSettings]

# Opening report options:
array set optable {
  Stats 1
  Oldest 5
  Newest 5
  Popular 1
  MostFrequent 6
  MostFrequentWhite 1
  MostFrequentBlack 1
  AvgPerf 1
  HighRating 8
  Results 1
  Shortest 5
  ShortestWhite 1
  ShortestBlack 1
  MoveOrders 8
  MovesFrom 1
  Themes 1
  Endgames 1
  MaxGames 500
  ExtraMoves 1
  MergeMoves 8
  MergeUnique 1
}
array set optableDefaults [array get optable]

# Player report options
array set preport {
  Stats 1
  Oldest 5
  Newest 5
  MostFrequentOpponents 6
  AvgPerf 1
  HighRating 8
  Results 1
  MostFrequentEcoCodes 6
  Themes 1
  Endgames 1
  MaxGames 500
  ExtraMoves 1
}
array set preportDefaults [array get preport]

# Analysis options (Informant values)
# The different threshold values for !? ?? += etc
# Thresholds based on typical values used by Lichess/Chess.com for club players (~1500 rating)
array set informantDefaults {
  !? 0.3
  ?! 0.3
  ?  0.8
  ?? 1.5
  += 0.5
  +/- 1.5
  +- 2.5
  +-- 4.0
}
# Ensure the arrays are clean of any quoted keys that might have persisted.
foreach arr {informant informantDefaults} {
    foreach name [array names $arr *\"*] {
        unset ${arr}($name)
    }
}
array set informant [array get informantDefaults]

# [/] Modify `tcl/options.tcl` to use unquoted keys in `informantDefaults`

# Export file options:
set exportFlags(comments) 1
set exportFlags(indentc) 0
set exportFlags(vars) 1
set exportFlags(indentv) 0
set exportFlags(column) 0
set exportFlags(append) 0
set exportFlags(symbols) 0
set exportFlags(htmldiag) 0
set exportFlags(stripMarks) 0
set exportFlags(convertNullMoves) 0
set default_exportStartFile(PGN) {}
set default_exportEndFile(PGN) {}




set default_exportStartFile(HTML) {<html>
  <head>
    <title>scidCommunity export</title>
    <link rel="stylesheet" type="text/css" href="scid.css">
    <style>
      @media print {
        table { page-break-inside: avoid; }
      }
    </style>
  </head>
  <body bgcolor="#ffffff">

}
set default_exportEndFile(HTML) {</body>
  </html>
}

foreach type {PGN HTML} {
  set exportStartFile($type) $default_exportStartFile($type)
  set exportEndFile($type) $default_exportEndFile($type)
}

# autoRaise: defines whether the "raise" command should be used to raise
# certain windows (like progress bars) when they become obscured.
# Some Unix window managers (e.g. some versions of Enlightenment and sawfish,
# so I have heard) have a bug where the Tcl/Tk "raise" command times out
# and takes a few seconds. Setting autoRaise to 0 will help avoid this.

set autoRaise 1

proc raiseWin {w} {
  global autoRaise
  if {$autoRaise} { raise $w }
  return
}

### Audio move announcement options:
set ::utils::sound::soundFolder [file nativename [file join $::scidShareDir sounds]]
set ::utils::sound::announceNew 0
set ::utils::sound::announceForward 0
set ::utils::sound::announceBack 0
set ::utils::sound::moveSoundOnly 0
set ::utils::sound::soundTheme ""

# Spell-checking file: default is "spelling.ssp".
set spellCheckFile [file join $scidShareDir "spelling.ssp"]

# book configuration
set ::book::lastBook1 "" ; # book name without extension (.bin)
set ::book::lastBook2 ""
set ::book::lastBook3 ""
set ::book::bookCount 1      ; # number of books shown in the book window (1..3)
set ::book::sortAlpha 0
set ::book::oppMovesVisible 0


# Engines data:
set engines(list) {}
set engines(sort) Time
set engineCoach1 {}
set engineCoach2 {}



# scidConfigFile:
#   Returns the full path and name of a Scid configuration file,
#   given its configuration type.
#
proc scidConfigFile {type} {
  global scidConfigDir

  foreach {cfgtype fname} {
    options "options.dat"
    engines "engines.dat"
    engines.bak "engines.dat"
    recentfiles "recent.dat"
    history "history.dat"
    bookmarks "bookmarks.dat"
    reports "reports.dat"
    optrainer "optrainer.dat"
    resolvers "resolvers.dat"
    ExtHardware "hardware.dat"
    treecache "treecache.dat"
  } {
    if { $type == $cfgtype } {
      return [file nativename [file join $scidConfigDir $fname]]
    }
  }

  return -code error "No such config file type: $type"
}

set optionsFile [scidConfigFile options]

################################################################################
#  Load options file. All default values should be set before this point or new saved values will be overwritten by default ones
################################################################################
if {[file exists $optionsFile] && [catch {safeLoadConfig $optionsFile}]} {
  tk_messageBox -message $::errorInfo
}

# myPlayerNames:
#   List of player name patterns for which the chessboard should be
#   flipped each time a game is loaded, to show the board from that
#   player's perspective.
options.store ::myPlayerNames {}

# userColorSchemes:
#   Solid-colour board presets saved by the user from the Chessboard
#   preferences. Each entry is {lite dark selected suggested}. Registered
#   after the options file is loaded so a saved list is kept and the variable
#   is added to the autosave list of the current options file.
options.store ::userColorSchemes {}

# Marker palette color and type (defaults set above, before the options file
# was loaded). Registered here so the user's choice survives a restart.
options.store ::markColor green
options.store ::markType square

# Migrate the single-book setting without overwriting a newer slot-1 choice.
if {[info exists ::book::lastBook] && $::book::lastBook ne "" && $::book::lastBook1 eq ""} {
  set ::book::lastBook1 $::book::lastBook
}

# Clean up legacy toolbar_state entries that no longer map to widgets
if {[info exists toolbar_state(rotate)]} {
  unset toolbar_state(rotate)
}

# Now, if the options file was written by Scid 3.5 or older, it has a lot of
# yucky variable names in the global namespace. So convert them to the new
# namespace variables:
#
proc ConvertOldOptionVariables {} {
  set oldNewNames {
    doColorPgn ::pgn::showColor
    pgnIndentVars ::pgn::indentVars
    pgnIndentComments ::pgn::indentComments
    pgnShortHeader ::pgn::shortHeader
    pgnMoveFont ::pgn::boldMainLine
    pgnMoveNumSpace ::pgn::moveNumberSpaces
    pgnStripMarks ::pgn::stripMarks
    pgnSymbolicNags ::pgn::symbolicNags
    pgnColumn ::pgn::columnFormat
  }

  foreach {old new} $oldNewNames {
    if {[info exists ::$old]} {
      set $new [set ::$old]
    }
  }
}
ConvertOldOptionVariables

proc options.write {} {
 uplevel #0 {
  set optionF ""
  # Write a temporary file and rename it over the options file once it is
  # complete, the way options.writeVar already does. Opening the real file "w"
  # truncated it before a byte was written, so an error part-way through (a
  # full disk, most obviously) left every saved preference lost rather than
  # just the setting being changed.
  #
  # Report the outcome to the caller: a failed write is shown to the user here
  # and returns 0, so a caller that must not lose the user's edits can refuse
  # to close its dialog. An error raised by the body itself still propagates,
  # with the options file untouched and a stray *.tmp[pid] left behind.
  set ok 1
  set realFile [scidConfigFile options]
  set tmpFile "${realFile}.tmp[pid]"
  if {[catch {open $tmpFile w} optionF]} {
    set ok 0
    tk_messageBox -title "scidCommunity: Unable to write file" -type ok -icon warning \
        -message "Unable to write options file: $realFile\n$optionF"
  } else {
    puts $optionF "# Scid options file"
    puts $optionF "# Version: $scidVersion"
    puts $optionF "# This file contains commands in the Tcl language format."
    puts $optionF "# If you edit this file, you must preserve valid its Tcl"
    puts $optionF "# format or it will not set your Scid options properly."
    puts $optionF ""
    foreach i {boardSize boardStyle language ::pgn::showColor \
          ::pgn::indentVars ::pgn::indentComments ::pgn::showPhoto \
          ::pgn::shortHeader ::pgn::boldMainLine ::pgn::stripMarks ::pgn::figurine \
          ::pgn::symbolicNags ::pgn::moveNumberSpaces ::pgn::columnFormat \
          ::pgn::repetitionAlert \
          tree(order) tree(moveDepth) optionsAutoSave ::tree::mask::recentMask \
          ecoFile suggestMoves showVarPopup showVarArrows showEngineVariationArrows \
          enginePvDisplayLength \
          blunderThreshold autoplayDelay animateDelay boardCoords \
          moveEntry(AutoExpand) moveEntry(Coord) \
          translatePieces lichessFormat arrowLastMove highlightLastMove highlightLastMoveWidth \
          highlightLastMoveColor highlightLastMoveNag highlightLastMoveEval \
          glossOfDanger locale(numeric) \
          spellCheckFile autoRaise windowsDock showGameInfo \
          exportFlags(comments) exportFlags(vars) \
          exportFlags(indentc) exportFlags(indentv) \
          exportFlags(column) exportFlags(symbols) \
          exportFlags(htmldiag) exportFlags(convertNullMoves) \
          gameInfo(photos) gameInfo(hideNextMove) gameInfo(wrap) \
          gameInfo(fullComment) gameInfo(showMarks) \
          gameInfo(showMaterial) gameInfo(showFEN) \
          engineCoach1 engineCoach2 scidBooksDir scidBasesDir ::book::lastBook1 \
          ::book::lastBook2 ::book::lastBook3 ::book::bookCount ::book::sortAlpha \
          ::book::oppMovesVisible \
          ::utils::sound::soundFolder ::utils::sound::announceNew \
          ::utils::sound::announceForward ::utils::sound::announceBack \
          ::utils::sound::moveSoundOnly ::utils::sound::soundTheme \
          ::sergame::threshold ::sergame::isLimitedAnalysisTime ::sergame::showblunder ::sergame::showblundervalue \
          ::sergame::showevaluation ::sergame::analysisTime ::sergame::useChessClock ::sergame::storeEval \
          ::sergame::storeEvalAll \
          ::sergame::chosenOpening ::sergame::chosenEngine ::sergame::useBook ::sergame::bookToUse \
          ::sergame::startFromCurrent ::sergame::coachIsWatching ::sergame::timeMode \
          ::sergame::depth ::sergame::movetime ::sergame::nodes ::sergame::ponder ::sergame::isOpening \
          ::sergame::coachIndex ::sergame::playerColor \
          ::uci::uciInfo(wtime1) ::uci::uciInfo(winc1) ::uci::uciInfo(btime1) ::uci::uciInfo(binc1) \
          ::uci::uciInfo(fixeddepth1) ::uci::uciInfo(fixednodes1) ::uci::uciInfo(movetime1) \
          boardfile_lite boardfile_dark \
          FilterMaxMoves FilterMinMoves FilterStepMoves FilterMaxElo FilterMinElo FilterStepElo \
          FilterMaxYear FilterMinYear FilterStepYear FilterGuessELO lookTheme ThemePackageFile omarchyAutoTheme autoResizeBoard \
          isBatchOpening isBatchOpeningMoves isBatch \
          markTacticalExercises scoreAllMoves \
          useAnalysisBook annotateWhiteMoves annotateBlackMoves annotationVariationLength \
          isAnnotateVar isShortAnnotation addScoreToShortAnnotations annotateBlunders\
          addAnnotatorTag annotateMoves } {
      puts $optionF "set $i [list [set $i]]"
    }

    puts $optionF ""
    foreach i [lsort [array names winWidth]] {
      puts $optionF "set winWidth($i)  [expr $winWidth($i)]"
      puts $optionF "set winHeight($i) [expr $winHeight($i)]"
    }
    puts $optionF ""
    foreach i [lsort [array names winX]] {
      puts $optionF "set winX($i)  [expr $winX($i)]"
      puts $optionF "set winY($i)  [expr $winY($i)]"
    }
    puts $optionF ""
    puts $optionF "set analysisCommand [list $analysisCommand]"
    puts $optionF "set analysisChoices [list $analysisChoices]"
    puts $optionF ""
    foreach i {squareColor_lite squareColor_dark whitecolor blackcolor highcolor bestcolor \
          whiteborder blackborder borderwidth \
          pgnColor(Var) \
          pgnColor(Nag) pgnColor(Comment) \
          pgnColor(Current) } {
      puts $optionF "set $i [list [set $i]]"
    }
    puts $optionF ""
    foreach i [lsort [array names optable]] {
      puts $optionF "set optable($i) [list $optable($i)]"
    }
    foreach i [lsort [array names ::windows::stats::display]] {
      puts $optionF "set ::windows::stats::display($i) [list $::windows::stats::display($i)]"
    }
    foreach i [lsort [array names startup]] {
      puts $optionF "set startup($i) [list $startup($i)]"
    }
    foreach i [lsort [array names toolbar_state]] {
      puts $optionF "set toolbar_state($i) [list $toolbar_state($i)]"
    }
    foreach i [lsort [array names twinSettings]] {
      puts $optionF "set twinSettings($i) [list $twinSettings($i)]"
    }
    puts $optionF ""
    foreach i {Regular Menu Small Tiny Fixed} {
      puts $optionF "set fontOptions($i) [list $fontOptions($i)]"
    }
    puts $optionF ""
    foreach type [array names initialDir] {
      puts $optionF "set initialDir($type) [list $initialDir($type)]"
    }
    puts $optionF ""
    foreach type {PGN HTML} {
      puts $optionF "set exportStartFile($type) [list $exportStartFile($type)]"
      puts $optionF "set exportEndFile($type) [list $exportEndFile($type)]"
    }
    puts $optionF ""
    foreach i [lsort [array names informant]] {
      puts $optionF "set informant($i) [list $informant($i)]"
    }
    puts $optionF ""

    # save FICS config
    foreach i { use_timeseal timeseal_exec port_fics port_timeseal login password usedefaultvars premoveEnabled \
          consolebg consolefg consoleheight consolewidth colseeking colgame colgameresult colficspercent server_ip } {
      puts $optionF "set ::fics::$i [list [set ::fics::$i]]"
    }
    foreach i [lsort [array names ::fics::profileVars]] {
      puts $optionF "set ::fics::profileVars($i) [list $::fics::profileVars($i)]"
    }

# save ICCF config
    foreach i { username password server } {
      puts $optionF "set ::iccf::$i [list [set ::iccf::$i]]"
    }
    # save LSS config
    foreach i { username password server } {
      puts $optionF "set ::lss::$i [list [set ::lss::$i]]"
    }

    # save pinfo config
    foreach i { wikipurl dnburl SeeAlsoPND2WP wikipAPI} {
      puts $optionF "set ::pinfo::$i [list [set ::pinfo::$i]]"
    }

    # save NOVAG config
    foreach i { referee } {
      puts $optionF "set ::novag::$i [list [set ::novag::$i]]"
    }

    # Save layouts
    ::docking::layout_save "auto"
    foreach slot {1 2 3 auto} {
      puts $optionF "set ::docking::layout_list($slot) [list $::docking::layout_list($slot)]"
    }
    foreach wnd [array names ::winGeometry] {
      if {[winfo exists $wnd]} {
        ::win::saveWinGeometry $wnd
      }
      if {$::winGeometry($wnd) ne ""} {
        puts $optionF "set ::winGeometry([list $wnd]) [list $::winGeometry($wnd)]"
      }
    }

    # Save vars that were added with options.store()
    if {[info exists ::autosave_opt]} {
      set opt_sorted [lsort -dictionary [lmap elem $::autosave_opt {
        if {![info exists $elem]} {continue}
        if {[array exists $elem] && [array size $elem] == 0} { continue }
        set elem
      }]]
      puts $optionF ""
      puts $optionF "set ::autosave_opt [list $opt_sorted]"
      foreach ns [lsort -unique [lmap elem $opt_sorted { namespace qualifiers $elem }]] {
        if {$ns eq ""} { continue }
        puts $optionF "namespace eval $ns {}"
      }
      set vars {}
      foreach elem $opt_sorted {
        if {[array exists $elem]} {
          lappend vars {*}[lmap name [array names $elem] {subst "$elem\($name\)"}]
        } else {
          lappend vars $elem
        }
      }
      foreach var [lsort -unique $vars] {
        puts $optionF "set [list $var] [list [set $var]]"
      }
    }

    set writeErr [options.finishWrite $optionF $tmpFile $realFile]
    if {$writeErr ne ""} {
        set ok 0
        tk_messageBox -title "scidCommunity: Unable to write file" -type ok -icon warning \
            -message "Unable to write options file: $realFile\n$writeErr"
    } else {
        set ::statusBar "Options were saved to: $realFile"
    }
  }
  set ok
 }
}

# options.finishWrite:
#   Close a fully written temporary options file and move it over the real one.
#   The rename is what makes the save atomic: until it succeeds the previous
#   file is still the one on disk, so a failure cannot lose every saved
#   preference. Returns "" on success, or the error message; the temporary file
#   is removed either way.
proc options.finishWrite {fh tmpFile realFile} {
  set err ""
  if {[catch {
    close $fh
    catch {file attributes $tmpFile -permissions 0600}
    file rename -force $tmpFile $realFile
  } err]} {
    catch {close $fh}
    catch {file delete -force $tmpFile}
    return $err
  }
  return ""
}

# options.writeVar:
#   Write a single option variable to the options file without rewriting the
#   other settings. An existing "set varname ..." command is replaced in
#   place (even when its value spans several lines); otherwise a new command
#   is appended. The rest of the file is left untouched.
#
proc options.writeVar {varname} {
  if {![info exists $varname] || [array exists $varname]} { return }

  set filename [scidConfigFile options]
  set assignment "set [list $varname] [list [set $varname]]"
  set bare [string trimleft $varname :]

  set content ""
  if {[file exists $filename]} {
    if {[catch {open $filename r} fh]} {
      tk_messageBox -title "scidCommunity: Unable to write file" -type ok -icon warning \
          -message "Unable to write options file: $filename\n$fh"
      return
    }
    # "auto" would silently turn CRLF into LF on read; we want to preserve
    # the file's existing convention.
    fconfigure $fh -translation lf
    set content [read $fh]
    close $fh
  }

  # Remember the file's line-ending convention and normalise to LF while
  # parsing, so "info complete" can delimit Tcl commands reliably.
  set eol "\n"
  if {[string first "\r\n" $content] >= 0} { set eol "\r\n" }
  set content [string map [list "\r\n" "\n"] $content]

  # Walk whole Tcl commands rather than raw lines: a saved list value can
  # legitimately span several lines.
  set lines [split $content "\n"]
  if {[lindex $lines end] eq ""} { set lines [lrange $lines 0 end-1] }
  set out ""
  set buf ""
  set found 0
  foreach line $lines {
    append buf $line "\n"
    if {![info complete $buf]} { continue }
    if {[string trim $buf] eq ""} {
      append out $buf
      set buf ""
      continue
    }
    set cmd [string trimleft $buf]
    set isTarget 0
    if {![catch {llength $cmd} cmdLen] && $cmdLen >= 2 && [lindex $cmd 0] eq "set"} {
      set cmdVar [lindex $cmd 1]
      if {$cmdVar eq $varname || $cmdVar eq $bare} { set isTarget 1 }
    }
    if {$isTarget} {
      if {!$found} {
        append out $assignment "\n"
        set found 1
      }
      # Any duplicate assignment for the same variable is dropped.
    } else {
      append out $buf
    }
    set buf ""
  }
  if {$buf ne ""} { append out $buf }

  if {!$found} {
    if {$out ne "" && [string index $out end] ne "\n"} { append out "\n" }
    append out $assignment "\n"
  }
  if {$eol ne "\n"} { set out [string map [list "\n" $eol] $out] }

  # Replace the file atomically, so an interrupted write cannot lose the
  # rest of the user's options.
  set tmp "${filename}.tmp[pid]"
  if {[catch {
    set fh [open $tmp w]
    fconfigure $fh -translation lf
    puts -nonewline $fh $out
    close $fh
    catch {file attributes $tmp -permissions 0600}
    file rename -force $tmp $filename
  } err]} {
    catch {close $fh}
    catch {file delete $tmp}
    tk_messageBox -title "scidCommunity: Unable to write file" -type ok -icon warning \
        -message "Unable to write options file: $filename\n$err"
  }
}

proc options.autoSaveHack {} {
  catch {
    set optionF [open [scidConfigFile options] "a"]
	puts $optionF "set ::optionsAutoSave $::optionsAutoSave"
    close $optionF
  }
}


###
### End of file: options.tcl
