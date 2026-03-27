### optable.tcl: Opening report and theory table generation.
### Part of Scid. Copyright 2001-2003 Shane Hudson.

namespace eval ::optable {}
array set ::optable::_data {}

set ::optable::_data(exclude) "---"
set ::optable::_docStart(text) {}
set ::optable::_docEnd(text) {}
set ::optable::_docStart(ctext) {}
set ::optable::_docEnd(ctext) {}
set ::optable::_flip 0

set ::optable::_docStart(html) {<html>
  <head>
  <title>[OprepTitle]</title>
  <link rel="stylesheet" type="text/css" href="scid.css">
  <style type="text/css">
  <!--
  h1 { color:#990000 }
  h2 { color:#990000 }
  h3 { color:#990000 }
  .player {
    color:darkblue
  }
  .elo {
    color:green
    font-style:italic
  }
  sup {
    color:red
  }
  -->
  </style>
  </head>
  <body bgcolor="#ffffff">
}
set ::optable::_docEnd(html) {</body>
  </html>
}



proc ::optable::ConfigMenus {{lang ""}} {
  if {! [winfo exists .oprepWin]} { return }
  if {$lang == ""} { set lang $::language }
  set m .oprepWin.menu
  foreach idx {0 1 2} tag {File Favorites Help} {
    configMenuText $m $idx Oprep$tag $lang
  }
  foreach idx {0 1 3 5} tag {Text Html Options Close} {
    configMenuText $m.file $idx OprepFile$tag $lang
  }
  foreach idx {0 1 2} tag {Add Edit Generate} {
    configMenuText $m.favorites $idx OprepFavorites$tag $lang
  }
  foreach idx {0 1} tag {Report Index} {
    configMenuText $m.helpmenu $idx OprepHelp$tag $lang
  }
}

proc ::optable::makeReportWin {args} {
  set ::optable::opReportBase [sc_base current]
  set showProgress 1
  set args [linsert $args 0 "args"]
  if {[lsearch -exact $args "-noprogress"] >= 0} { set showProgress 0 }
  if {$showProgress} {
    set w .progress
    toplevel $w -background [ttk::style lookup . -background]
    wm withdraw $w
    wm title $w "scidCommunity: Generating Report"
    bind $w <Visibility> "raiseWin $w"

    pack [ttk::frame $w.b] -side bottom -fill x
    set ::optable::_interrupt 0
    ttk::button $w.b.cancel -text $::tr(Cancel) -command {
      set ::optable::_interrupt 1
      progressBarCancel
    }
    pack $w.b.cancel -side right -pady 5 -padx 2

    foreach i {1 2} name { "Searching database for report games" "Generating report information" } {
      ttk::label $w.text$i -text "$i. $name"
      pack $w.text$i -side top
      canvas $w.c$i -width 400 -height 20 -bg white -relief solid -border 1
      $w.c$i create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
      $w.c$i create text 395 10 -anchor e -font font_Regular -tags time \
          -fill black -text "0:00 / 0:00"
      pack $w.c$i -side top -pady 10
    }
    wm resizable $w 0 0
    # Set up geometry for middle of screen:
    set x [winfo screenwidth $w]; set x [expr $x - 400]; set x [expr $x / 2]
    set y [winfo screenheight $w]; set y [expr $y - 20]; set y [expr $y / 2]
    wm geometry $w +$x+$y
    wm deiconify $w
    grab $w.b.cancel
    progressBarSet $w.c1 401 21
  }

  # The Opening Report should always honor the dbfilter (header search filter)
  # We compose dbfilter with tree to get games that match both the position AND the filter
  set baseNumber $::curr_db

  # Save original dbfilter by creating a temporary copy
  set tempFilter [sc_filter new $::curr_db]
  sc_filter copy $::curr_db $tempFilter dbfilter

  # Compose dbfilter with tree filter to get games that match both
  set ::optable::_data(composedFilter) [sc_filter compose $::curr_db "dbfilter" "tree"]
  set newTreeData [sc_tree stats $::curr_db $::optable::_data(composedFilter)]
  # Copy the composed filter to dbfilter so the report uses it
  sc_filter copy $::curr_db dbfilter $::optable::_data(composedFilter)
  
  if {$showProgress} {
    if {$::optable::_interrupt} {
      grab release $w.b.cancel
      destroy $w
      return
    }
    progressBarSet $w.c2 401 21
  }
  sc_report opening create $::optable(ExtraMoves) $::optable(MaxGames) $::optable::_data(exclude)

  if {$showProgress} {
    grab release $w.b.cancel
    destroy $w
    if {$::optable::_interrupt} { return }
  }

  set ::optable::_data(tree) $newTreeData

  # Enable HTML diagram generation (like the Export HTML feature does)
  sc_info html 0
  # Generate board HTML with explicit path to bitmaps directory
  set ::optable::_data(bdHTML) [sc_pos html -path "bitmaps"]
  set ::optable::_data(bdHTML_flip) [sc_pos html -flip 1 -path "bitmaps"]

  # Populate moves list for the "Exclude" dropdown from the tree stats output.
  # Each data line looks like: " N: <move(25 chars)>  <eco>  <freq>: ..."
  # The first SAN move occupies columns 4..28; we only want the first token.
  set ::optable::_data(moves) {}
  foreach line [split $newTreeData "\n"] {
    if {[regexp {^\s*\d+:\s+(\S+)} $line -> move]} {
      if {$move ne "---" && $move ne "TOTAL:"} {
        lappend ::optable::_data(moves) $move
      }
    }
  }

  ::optable::setupRatios

  set report [::optable::report ctext 1]

  # Now restore original dbfilter after report is fully generated
  sc_filter copy $::curr_db dbfilter $tempFilter
  sc_filter release $::curr_db $tempFilter

  if {[lsearch -exact $args "-nodisplay"] >= 0} { return }

  set w .oprepWin
  if {![winfo exists $w]} {
    ::createToplevel $w
    ::setTitle $w "[tr ToolsOpReport]"
    menu $w.menu
    ::setMenu $w $w.menu

    $w.menu add cascade -label OprepFile -menu $w.menu.file
    $w.menu add cascade -label OprepFavorites -menu $w.menu.favorites
    $w.menu add cascade -label OprepHelp -menu $w.menu.helpmenu
    foreach i {file favorites helpmenu} {
      menu $w.menu.$i -tearoff 0
    }

    $w.menu.file add command -label OprepFileText \
        -command {::optable::saveReport text}
    $w.menu.file add command -label OprepFileHtml \
        -command {::optable::saveReport html}
    $w.menu.file add separator
    $w.menu.file add command -label OprepFileOptions \
        -command ::optable::setOptions
    $w.menu.file add separator
    $w.menu.file add command -label OprepFileClose \
        -command "$w.b.close invoke"
    $w.menu.favorites add command -label OprepFavoritesAdd \
        -command ::optable::addFavoriteDlg
    $w.menu.favorites add command -label OprepFavoritesEdit \
        -command ::optable::editFavoritesDlg
    $w.menu.favorites add command -label OprepFavoritesGenerate \
        -command ::optable::generateFavoriteReports
    $w.menu.favorites add separator
    $w.menu.helpmenu add command -label OprepHelpReport \
        -accelerator F1 -command {helpWindow Reports Opening}
    $w.menu.helpmenu add command -label OprepHelpIndex \
        -command {helpWindow Index}

    ::optable::updateFavoritesMenu

    bind $w <F1> {helpWindow Reports Opening}
    bind $w <Escape> "$w.b.close invoke"
    bind $w <Up> "$w.text yview scroll -1 units"
    bind $w <Down> "$w.text yview scroll 1 units"
    bind $w <Prior> "$w.text yview scroll -1 pages"
    bind $w <Next> "$w.text yview scroll 1 pages"
    bind $w <Key-Home> "$w.text yview moveto 0"
    bind $w <Key-End> "$w.text yview moveto 0.99"

    # TODO: Is it really ok for the text to not be a child of the frame (grid propagate)?
    autoscrollText y $w.scroll $w.text Treeview
    $w.text configure -height 30 -width 85 -font font_Small -wrap word -state normal
    ::htext::init $w.text
    ttk::frame $w.b
    ttk::button $w.b.previewHTML -textvar ::tr(OprepViewHTML) \
        -command ::optable::previewHTML
    ttk::button $w.b.opts -text [tr OprepFileOptions] -command ::optable::setOptions
    ttk::label $w.b.lexclude -text "Exclude:"
    ttk::menubutton $w.b.exclude -textvar ::optable::_data(exclude) -menu $w.b.exclude.m
    menu $w.b.exclude.m -tearoff 0
    ttk::button $w.b.update -textvar ::tr(Update) -command {
      set ::optable::_data(yview) [lindex [.oprepWin.text yview] 0]
      ::optable::makeReportWin
      .oprepWin.text yview moveto $::optable::_data(yview)
    }

    ttk::button $w.b.mergeGames -textvar ::tr(MergeGames) -command ::optable::mergeGames
    ttk::button $w.b.help -textvar ::tr(Help) -command {helpWindow Reports Opening}
    ttk::button $w.b.close -textvar ::tr(Close) -command "focus .; destroy $w"
    pack $w.b -side bottom -fill x
    pack $w.scroll -side left -fill both -expand yes
    pack $w.b.close $w.b.update -side right -padx 1 -pady 2
      pack $w.b.previewHTML -side left -padx 1 -pady 2
    pack $w.b.opts $w.b.lexclude $w.b.exclude $w.b.mergeGames -side left -padx 1 -pady 2
    ::optable::ConfigMenus
    ::createToplevelFinalize $w
  }

  catch {destroy $w.text.bd}

  ::board::new $w.text.bd 30

  if {$::optable::_flip} { ::board::flip $w.text.bd }
  $w.text.bd configure -relief solid -borderwidth 1
  for {set i 0} {$i < 63} {incr i} {
    ::board::bind $w.text.bd $i <ButtonPress-1> ::optable::flipBoard
    #::board::bind $w.text.bd $i <ButtonPress-$::MB3> ::optable::resizeBoard
  }
  ::board::update $w.text.bd [sc_pos board]
  $w.b.exclude.m delete 0 end
  $w.b.exclude.m add radiobutton -label "---" -variable ::optable::_data(exclude) -command "$w.b.update invoke"
  foreach move $::optable::_data(moves) {
    $w.b.exclude.m add radiobutton -label $move -variable ::optable::_data(exclude) -command "$w.b.update invoke"
  }
  if {[lsearch $::optable::_data(moves) $::optable::_data(exclude)] < 0} {
    set ::optable::_data(exclude) "---"
  }
  busyCursor .
  $w.text configure -state normal
  $w.text delete 1.0 end
  regsub -all "\n" $report "<br>" report
  ::htext::display $w.text $report
  $w.text configure -state disabled
  unbusyCursor .

  ::notify::filter $::curr_db dbfilter
}
################################################################################
# merges the N best games up to P plies to current game
# P (ply limit) is taken from the MergeMoves option
# Note: MergeMoves is stored as full moves, but sc_game merge expects plies
# The ply limit is from the START of the game, so we need to add current ply
# If MergeUnique is enabled, only games with unique move sequences are merged
################################################################################
proc ::optable::mergeGames { {game_count 50} } {
  set base  $::optable::opReportBase
  # Get current move number and convert to ply (1 move = 2 plies)
  set currentMove [sc_pos moveNumber]
  set currentPly [expr {$currentMove * 2}]
  # Convert MergeMoves (full moves) to plies and add to current position
  set mergePlies [expr {$::optable(MergeMoves) * 2}]
  set totalPly [expr {$currentPly + $mergePlies}]
  
  # Save current game number and database
  set currentGameNum [sc_game number]
  set currentBase [sc_base current]
  
  set games [split [sc_report opening best a $game_count] "\n"]
  
  # Track unique move sequences if option is enabled
  set mergeUnique $::optable(MergeUnique)
  array set seenMoves {}
  set mergedCount 0
  
  foreach g $games {
    if {$g == "" } { continue }
    set res [scan $g "%d:  <g_%d>" d1 game_number]
    if {$res != 2} {
      if {[info exists game_number]} {
        tk_messageBox -title "scidCommunity: Error writing report" -type ok -icon warning -message "Error merging game $game_number"
      } else  {
        tk_messageBox -title "scidCommunity: Error writing report" -type ok -icon warning -message "Error merging game"
      }
      break
    }
    
    # Skip if this is the current game (can't merge a game into itself)
    if {$base == $currentBase && $game_number == $currentGameNum} {
      continue
    }
    
    # Check for unique moves if option is enabled
    if {$mergeUnique} {
      # Save current state
      sc_game push copyfast
      
      # Load the candidate game to get its moves (from the report base)
      sc_base switch $base
      sc_game load $game_number
      
      # Navigate to the merge limit ply
      sc_move ply $totalPly
      
      # Get the move list
      set moveList [sc_game moves]
      
      # Restore original game and database
      sc_base switch $currentBase
      sc_game load $currentGameNum
      sc_game pop
      
      # Skip if we've already seen this move sequence
      if {[info exists seenMoves($moveList)]} {
        continue
      }
      set seenMoves($moveList) 1
    }
    
    # Merge the game - need to be on the target game in the current database
    # sc_game merge merges the specified game into the current game
    set err [ catch { sc_game merge $base $game_number $totalPly } result ]
    if {$err} {
      tk_messageBox -title "scidCommunity" -type ok -icon info -message "Unable to merge the selected game:\n$result"
      break
    }
    incr mergedCount
  }
  
  if {$mergeUnique} {
    puts "Merged $mergedCount unique games (out of $game_count requested)"
  }
  updateBoard -pgn
}
################################################################################
#
################################################################################

proc ::optable::flipBoard {} {
  ::board::flip .oprepWin.text.bd
  set ::optable::_flip [::board::isFlipped .oprepWin.text.bd]
}

proc ::optable::resizeBoard {} {
  set bd .oprepWin.text.bd
  set size [::board::size $bd]
  if {$size >= 40} { set size 25 } else { incr size 5 }
  ::board::resize $bd $size
}

proc ::optable::setOptions {} {
  set w .oprepOptions
  if {[winfo exists $w]} { return }
  win::createDialog $w
  pack [ttk::frame $w.f] -side top -fill x -padx 5
  set row 0
  foreach i {Stats Popular AvgPerf Results MovesFrom Themes Endgames} {
    set yesno($i) 1
  }
  set left 0
  set right 1
  foreach i {Stats Oldest Newest Popular MostFrequent sep \
        AvgPerf HighRating sep \
        Results Shortest sep col \
        MoveOrders MovesFrom Themes Endgames gap sep \
        MaxGames ExtraMoves MergeMoves MergeUnique sep} {
    set from 0; set to 10; set tick 1; set res 1

    if {$i == "col"} {
      incr left 4
      ttk::frame $w.f.colsep$left -width 8
      grid $w.f.colsep$left -row 0 -column $left
      incr left
      set right [expr {$left + 1}]
      set row 0
    } elseif {$i == "gap"} {
      # nothing
    } elseif {$i == "sep"} {
      ttk::separator $w.f.fsep$row$left
      ttk::separator $w.f.tsep$row$left
      grid $w.f.fsep$row$left -row $row -column $left -sticky we -columnspan 4 -pady 2
    } elseif {[info exists yesno($i)]} {
      ttk::checkbutton $w.f.f$i -variable ::optable($i) -onvalue 1 -offvalue 0 -text $::tr(Oprep$i)
      grid $w.f.f$i -row $row -column $left -sticky w -columnspan 3
    } else {

      # Pascal Georges : changed combobox to spinbox to widen choices
      if {$i == "MaxGames"} {
        ttk::spinbox $w.f.s$i -textvariable ::optable($i) -from 0 -to 5000 -increment 50 \
            -state readonly -width 5 -justify right -font font_Small
      } elseif {$i == "MergeMoves"} {
        # Use a simple entry widget for direct number input (easier than clicking down from 999)
        ttk::entry $w.f.s$i -textvariable ::optable($i) -width 5 -justify right -font font_Small
      } elseif {$i == "MergeUnique"} {
        # Checkbox for merging only unique games - displayed on same row as MergeMoves
        ttk::checkbutton $w.f.s$i -variable ::optable($i) -onvalue 1 -offvalue 0 \
            -text $::tr(OprepMergeUnique)
        grid $w.f.s$i -row $row -column $left -sticky w -columnspan 3
        incr row
        continue
      } else  {
        set tmpcombo {}
        for {set x $from} {$x <= $to} {incr x $res} {
          lappend tmpcombo $x
        }
        ttk::combobox $w.f.s$i -textvariable ::optable($i) -width 2 -values $tmpcombo -justify right -state readonly
      }

      ttk::label $w.f.t$i -textvar ::tr(Oprep$i) -font font_Small
      grid $w.f.s$i -row $row -column $left -sticky w
      if {$i == "MostFrequent"  ||  $i == "Shortest"} {
        ttk::checkbutton $w.f.w$i -text $::tr(White) \
            -variable ::optable(${i}White)
        ttk::checkbutton $w.f.b$i -text $::tr(Black) \
            -variable ::optable(${i}Black)
        grid $w.f.t$i -row $row -column $right -sticky w
        grid $w.f.w$i -row $row -column 2 -sticky w -padx 5
        grid $w.f.b$i -row $row -column 3 -sticky w
      } else {
        grid $w.f.t$i -row $row -column $right -columnspan 3 -sticky w
      }
    }
    if {$i != "col"} { incr row }
  }
  pack [ttk::frame $w.b] -side bottom -fill x
  dialogbutton $w.b.defaults -textvar ::tr(Defaults) -command {
    array set ::optable [array get ::optableDefaults]
  }
  dialogbutton $w.b.ok -text "OK" -command {
    destroy .oprepOptions
    catch {set ::optable::_data(yview) [lindex [.oprepWin.text yview] 0]}
    ::optable::makeReportWin
    catch {.oprepWin.text yview moveto $::optable::_data(yview)}
  }
  dialogbutton $w.b.cancel -textvar ::tr(Cancel) -command {
    array set ::optable [array get ::optable::backup]
    destroy .oprepOptions
  }
  packbuttons left $w.b.defaults
  packdlgbuttons $w.b.cancel $w.b.ok
  array set ::optable::backup [array get ::optable]
  wm resizable $w 0 0
  wm title $w  "scidCommunity: [tr ToolsOpReport]: [tr OprepFileOptions]"
  bind $w <Escape> "$w.b.cancel invoke"
}



# previewHTML:
#   Saves the report to a temporary file, and invokes the user's web
#   browser to display it.
#
proc ::optable::previewHTML {} {
  busyCursor .
  set tmpdir $::scidLogDir
  set tmpfile "TempOpeningReport"
  set fname [file join $tmpdir $tmpfile]
  
  # Copy CSS and bitmaps for proper diagram display (like Export HTML does)
  # The HTML uses relative paths like "bitmaps/wr.gif" so we need bitmaps in the same dir
  # Use scidExeDir as the base directory where bitmaps folder is located
  catch {file copy -force [file join $::scidExeDir bitmaps] $tmpdir}
  catch {file copy -force [file join $::scidExeDir html scid.css] $tmpdir}
  
  if {[catch {set tempfile [open $fname.html w]}]} {
    tk_messageBox -title "scidCommunity: Error writing report" -type ok -icon warning \
        -message "Unable to write the file: $fname.html"
  }
  puts $tempfile [::optable::report html 1 $::optable::_flip]
  close $tempfile
  # Use openURL to open the HTML file in the user's default browser
  openURL "file://$fname.html"
  unbusyCursor .
}

# saveReport:
#   Saves the current opening report to a file.
#   "fmt" is the format: text, html or latex.
#   "type" is the report type: report, table, or both.
#
proc ::optable::saveReport {fmt} {
  set t [tk_dialog .dialog "scidCommunity: Select report type" \
      "Select the report type. You may save a full report (which includes the theory table), a compact report (with no theory table), or just the theory table by itself." \
      "" 0 "Full report" "Compact report" \
      "Theory table" "Cancel"]
  if {$t == 3} { return }
  set default ".txt"
  set ftype {
    { "Text files" {".txt"} }
    { "All files"  {"*"}    }
  }
  if {$fmt == "html"} {
    set default ".html"
    set ftype {
      { "HTML files" {".html" ".htm"} }
      { "All files"  {"*"}    }
    }
  }

  set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype \
      -defaultextension $default -title "scidCommunity: Save opening report"]
  if {$fname == ""} { return }

  busyCursor .
  if {[catch {set tempfile [open $fname w]}]} {
    tk_messageBox -title "scidCommunity: Error writing report" -type ok -icon warning \
        -message "Unable to write the file: $fname\n\n"
  } else {
    # For HTML saves, copy bitmaps and CSS to the same directory
    if {$fmt == "html"} {
      set dstdir [file dirname $fname]
      catch {file copy -force [file join $::scidExeDir bitmaps] $dstdir}
      catch {file copy -force [file join $::scidExeDir html scid.css] $dstdir}
    }
    if {$t == 2} {
      set report [::optable::table $fmt]
    } elseif {$t == 1} {
      set report [::optable::report $fmt 0 $::optable::_flip]
    } else {
      set report [::optable::report $fmt 1 $::optable::_flip]
    }
    if {$::hasEncoding  &&  $::langEncoding($::language) != ""} {
      catch {set report [encoding convertto $::langEncoding($::language) $report]}
    }
    puts $tempfile $report
    close $tempfile
  }
  unbusyCursor .
}



proc ::optable::setupRatios {} {
  # Use the composed filter that was set in makeReportWin
  set filterSpec $::optable::_data(composedFilter)
  
  set r [sc_filter freq [sc_base current] $filterSpec date 0000.00.00]
  if {[lindex $r 0] == 0} {
    set ::optable::_data(ratioAll) 0
  } else {
    set ::optable::_data(ratioAll) \
        [expr {int(double([lindex $r 1]) / double([lindex $r 0]))} ]
  }
  # Calculate decade ranges dynamically up to the current decade
  # Early periods use larger bins due to fewer games; decades start from 1950
  set currentYear [::utils::date::today year]
  set currentDecadeStart [expr {($currentYear / 10) * 10}]

  # Define the fixed early period bins, then decades from 1950 to current
  set decadeRanges {1800 1899  1900 1949}

  # Add decades from 1950 up to current decade
  for {set start 1950} {$start <= $currentDecadeStart} {incr start 10} {
    set end [expr {$start + 9}]
    lappend decadeRanges $start $end
  }

  foreach {start end} $decadeRanges {
    set r [sc_filter freq [sc_base current] $filterSpec date $start.00.00 $end.12.31]
    set filter [lindex $r 0]
    set all [lindex $r 1]
    if {$filter == 0} {
      set ::optable::_data(range$start) "---"
    } else {
      set ::optable::_data(range$start) \
          [expr {int(double($all) / double($filter))} ]
    }
  }
  # Store the decade start years for later use in the report
  set ::optable::_data(decadeStarts) {}
  foreach {start end} $decadeRanges {
    lappend ::optable::_data(decadeStarts) $start
  }
  foreach y {1 5 10} {
    set year "[expr [::utils::date::today year]-$y]"
    append year ".[::utils::date::today month].[::utils::date::today day]"
    set r [sc_filter freq [sc_base current] $filterSpec date $year]
    set filter [lindex $r 0]
    set all [lindex $r 1]
    if {$filter == 0} {
      set ::optable::_data(ratio$y) 0
    } else {
      set ::optable::_data(ratio$y) \
          [expr {int(double($all) / double($filter))} ]
    }
    if {$::optable::_data(ratio$y) == 0} {
      set r 1.0
    } else {
      set r [expr {double($::optable::_data(ratioAll))} ]
      set r [expr {$r / double($::optable::_data(ratio$y))} ]
    }
    set ::optable::_data(delta$y) [expr {int(($r - 1.0) * 100.0 + 0.5)} ]
  }
}

proc ::optable::_percent {x fmt} {
  set p "%"
  if {$fmt == "latex"} { set p "\\%" }
  return "[expr $x / 10][sc_info decimal][expr $x % 10]$p"
}

proc ::optable::results {reportType fmt} {
  set s {}
  set n "\n"; set next " "; set p "%"
  set white "1-0"; set draw "=-="; set black "0-1"

  if {$fmt == "latex"} {
    set next " & "; set n "\\\\\n"; set p "\\%"
    set white "\\win"; set draw "\\draw"; set black "\\loss"
    append s "\\begin{tabular}{lccccccc}\n"
  }

  if {$fmt == "html"} { append s "<pre>\n" }
  if {$fmt == "ctext"} { append s "<tt>" }
  if {$fmt == "latex"} { append s "\\hline\n" }

  set lenReport [string length $::tr(OprepReportGames)]
  set lenAll [string length $::tr(OprepAllGames)]
  set len [expr {($lenReport > $lenAll) ? $lenReport : $lenAll} ]
  set score [::utils::string::Capital $::tr(score)]
  set slen [string length $score]
  if {$slen < 7} { set slen 7 }

  append s " [::utils::string::Pad {} $len] $next"
  append s "[::utils::string::PadRight $score $slen] $next"
  if {$fmt == "latex"} {
    append s "\\multicolumn{3}{c}{$::tr(OprepLength)} & "
    append s "\\multicolumn{3}{c}{$::tr(OprepFrequency)} $n "
  } else {
    append s "[::utils::string::PadCenter $::tr(OprepLength) 19] $next"
    append s "[::utils::string::PadCenter $::tr(OprepFrequency) 22] $n"
  }

  append s " [::utils::string::Pad {} $len] $next"
  append s "[::utils::string::PadRight {} $slen] $next"
  append s "[::utils::string::PadRight $white 5] $next"
  append s "[::utils::string::PadRight $draw  5] $next"
  append s "[::utils::string::PadRight $black 5] $next"
  append s "[::utils::string::PadRight $white 5]  $next"
  append s "[::utils::string::PadRight $draw  5]  $next"
  append s "[::utils::string::PadRight $black 5]  $n"
  if {$fmt == "latex"} { append s "\\hline\n" }

  set sc [sc_report $reportType score]
  set wlen [sc_report $reportType avgLength 1]
  set dlen [sc_report $reportType avgLength =]
  set blen [sc_report $reportType avgLength 0]
  set wf [sc_report $reportType freq 1]
  set df [sc_report $reportType freq =]
  set bf [sc_report $reportType freq 0]

  append s " [::utils::string::Pad $::tr(OprepReportGames) $len] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $sc 0] $fmt] $slen] $next"
  append s "[::utils::string::PadRight [lindex $wlen 0] 5] $next"
  append s "[::utils::string::PadRight [lindex $dlen 0] 5] $next"
  append s "[::utils::string::PadRight [lindex $blen 0] 5] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $wf 0] $fmt] 6] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $df 0] $fmt] 6] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $bf 0] $fmt] 6] $n"

  append s " [::utils::string::Pad $::tr(OprepAllGames) $len] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $sc 1] $fmt] $slen] $next"
  append s "[::utils::string::PadRight [lindex $wlen 1] 5] $next"
  append s "[::utils::string::PadRight [lindex $dlen 1] 5] $next"
  append s "[::utils::string::PadRight [lindex $blen 1] 5] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $wf 1] $fmt] 6] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $df 1] $fmt] 6] $next"
  append s "[::utils::string::PadRight [::optable::_percent [lindex $bf 1] $fmt] 6] $n"

  if {$fmt == "latex"} { append s "\\hline\n\\end{tabular}\n" }
  if {$fmt == "html"} { append s "</pre>\n" }
  if {$fmt == "ctext"} { append s "</tt>" }

  return $s
}

proc ::optable::stats {fmt} {
  global stats
  set s {}
  set all $::tr(OprepStatAll)
  set both $::tr(OprepStatBoth)
  set since $::tr(OprepStatSince)
  set games [::utils::string::Capital $::tr(games)]
  set score [::utils::string::Capital $::tr(score)]

  set alen [string length $all]
  set blen [expr {[string length $both] + 6} ]
  set slen [expr {[string length $since] + 11} ]
  set len $alen
  if {$len < $blen} { set len $blen }
  if {$len < $slen} { set len $slen }

  set ratings 0
  set years 0
  set rlist [lsort -decreasing [array names stats r*]]
  set ylist [lsort [array names stats y*]]
  foreach i $rlist { if {$stats($i)} { set ratings 1 } }
  foreach i $ylist { if {$stats($i)} { set years 1 } }

  if {$fmt == "latex"} {
    append s "\\begin{tabular}{l r r r r r @{.} l}\n\\hline\n"
    append s "       & $games & \\win & \\draw & \\loss & "
    append s "\\multicolumn{2}{c}{$score} \\tspace \\\\ \\hline \n"
    scan [sc_filter stats all] "%u%u%u%u%u%\[.,\]%u" g w d l p c x
    append s "$all & $g & $w & $d & $l & $p&$x\\% \\\\\n"

    if {$ratings} {
      append s "\\hline\n"
      foreach i $rlist {
        if {$stats($i)} {
          set elo [string range $i 1 end]
          scan [sc_filter stats elo $elo] "%u%u%u%u%u%\[.,\]%u" g w d l p c x
          append s "$both $elo+ & $g & $w & $d & $l & $p&$x\\% \\\\\n"
        }
      }
    }
    if {$years} {
      append s "\\hline\n"
      foreach i $ylist {
        if {$stats($i)} {
          set year [string range $i 1 end]
          scan [sc_filter stats year $year] "%u%u%u%u%u%\[.,\]%u" g w d l p c x
          append s "$since $year.01.01 & $g & $w & $d & $l & $p&$x\\% \\\\\n"
        }
      }
    }
    append s "\\hline\n\\end{tabular}\n"
    return $s
  }

  # For plain text format, just display in plain text:
  if {$fmt == "html"} { append s "<pre>\n" }
  if {$fmt == "ctext"} { append s "<tt>" }
  set stat ""
  append s " [::utils::string::Pad $stat [expr $len - 4]] [::utils::string::PadRight $games 10]"
  append s "     1-0     =-=     0-1 [::utils::string::PadRight $score 8]\n"
  append s "-----------------------------------------------------------"
  append s "\n [::utils::string::Pad $all $len]"     [sc_filter stats all]

  if {$ratings} {
    append s "\n"
    foreach i $rlist {
      if {$stats($i)} {
        set elo [string range $i 1 end]
        set stat "$both $elo+"
        append s "\n [::utils::string::Pad $stat $len]"   [sc_filter stats elo $elo]
      }
    }
  }
  if {$years} {
    append s "\n"
    foreach i $ylist {
      if {$stats($i)} {
        set year [string range $i 1 end]
        set stat "$since $year.01.01"
        append s "\n [::utils::string::Pad $stat $len]"   [sc_filter stats year $year]
      }
    }
  }
  append s "\n-----------------------------------------------------------\n"
  if {$fmt == "html"} { append s "</pre>\n" }
  if {$fmt == "ctext"} { append s "</tt>" }
  return $s
}

proc ::optable::_reset {} {
  set ::optable::_data(sec) 0
  set ::optable::_data(subsec) 0
}

proc ::optable::_title {} {
  set fmt $::optable::_data(fmt)
  set title $::tr(OprepTitle)
  if {$fmt == "latex"} {
    return "\\begin{center}{\\LARGE \\bf $title}\\end{center}\n\n"
  } elseif {$fmt == "html"} {
    return "<h1><center>$title</center></h1>\n\n"
  } elseif {$fmt == "ctext"} {
    return "<h1><center>$title</center></h1>\n\n"
  }
  set r    "--------------------------------------------------------------"
  append r "\n                        [string toupper $title]\n"
  append r "--------------------------------------------------------------"
  append r "\n\n"
  return $r
}

proc ::optable::_sec {text} {
  set fmt $::optable::_data(fmt)
  incr ::optable::_data(sec)
  set ::optable::_data(subsec) 0
  if {$fmt == "latex"} {
    return "\n\n\\section{$text}\n"
  } elseif {$fmt == "html"} {
    return "\n<h2>$::optable::_data(sec). $text</h2>\n"
  } elseif {$fmt == "ctext"} {
    return "<h4>$::optable::_data(sec). $text</h4>"
  }
  set line "$::optable::_data(sec). [string toupper $text]"
  set underline "-----------------------------------------------------"
  return "\n\n$line\n[string range $underline 1 [string length $line]]\n"
}

proc ::optable::_subsec {text} {
  set fmt $::optable::_data(fmt)
  incr ::optable::_data(subsec)
  if {$fmt == "latex"} {
    return "\n\\subsection{$text}\n\n"
  } elseif {$fmt == "html"} {
    return "\n<h3>$::optable::_data(sec).$::optable::_data(subsec) $text</h3>\n\n"
  } elseif {$fmt == "ctext"} {
    return "\n<maroon><b>$::optable::_data(sec).$::optable::_data(subsec) $text</b></maroon>\n\n"
  }
  return "\n$::optable::_data(sec).$::optable::_data(subsec)  $text\n\n"
}
################################################################################
# report:
#   Produces a report in the appropriate format. If "withTable" is true,
#   the theory table is also included.
################################################################################
proc ::optable::report {fmt withTable {flipPos 0}} {
  global tr
  sc_report opening format $fmt
  set fmt [string tolower $fmt]
  set ::optable::_data(fmt) $fmt
  ::optable::_reset

  # numRows: the number of rows to show in the theory table.
  # If it is zero, the number of rows if decided according to the
  # number of games in the report.
  set numRows 0

  # Specify whether a theory table is to be printed, so note numbers
  # can be generated and displayed if necessary:
  sc_report opening notes $withTable $numRows

  set n "\n"; set p "\n\n"; set preText ""; set postText ""
  set percent "%"; set bullet "  * "
  if {$fmt == "latex"} {
    set n "\\\\\n"; set p "\n\n"
    #set preText "{\\samepage\\begin{verbatim}\n"
    #set postText "\\end{verbatim}\n}\n"
    set percent "\\%"; set bullet "\\hspace{0.5cm}\$\\bullet\$"
  } elseif {$fmt == "html"} {
    set n "<br>\n"; set p "<p>\n\n"
    set preText "<pre>\n"; set postText "</pre>\n"
  } elseif {$fmt == "ctext"} {
    set preText "<tt>"; set postText "</tt>"
  }

  # Generate the report:
  set games $tr(games)
  set moves $tr(moves)
  set counts [sc_report opening count]
  set rgames [lindex $counts 0]
  set tgames [lindex $counts 1]

  set r {}
  append r $::optable::_docStart($fmt)
  set title $::tr(OprepTitle)
  set r [string map [list "\[OprepTitle\]" $title] $r]
  append r [::optable::_title]
  append r "$tr(Database): [file tail [sc_base filename $::curr_db]] "
  append r "([::utils::thousands [sc_base numGames $::curr_db]] $games)$n"
  append r "$tr(OprepReport): [::trans [sc_report opening line]] ("
  if {$fmt == "ctext"} {
    append r "<darkblue><run sc_report opening select all 0; ::windows::stats::Refresh>"
  }
  append r "$rgames"
  if {$fmt == "ctext"} { append r "</run></darkblue>"; }
  append r " $games)$n"
  set eco [sc_report opening eco]
  if {$eco != ""} {
    append r "$tr(ECO): $eco$n"
  }

  append r "$::tr(OprepGenerated) scidCommunity $::scidVersion, [::utils::date::today]\n"
  if {$fmt == "html"} {
    if {$flipPos} {
      append r $::optable::_data(bdHTML_flip)
    } else {
      append r $::optable::_data(bdHTML)
    }
  } elseif {$fmt == "ctext"} {
    append r "\n<center><window .oprepWin.text.bd></center>\n"
  }
  if {$rgames == 0} {
    append r $::optable::_docEnd($fmt)
    return $r
  }

  if {$::optable(Stats) > 0  ||
    $::optable(Oldest) > 0  ||
    $::optable(Newest) > 0  ||
    $::optable(Popular) > 0  ||
    ($::optable(MostFrequent) > 0 &&
    ($::optable(MostFrequentWhite) || $::optable(MostFrequentBlack)))} {
    append r [::optable::_sec $tr(OprepStatsHist)]
  }
  if {$::optable(Stats)} {
    append r [::optable::_subsec $tr(OprepStats)]
    append r [::optable::stats $fmt]
  }
  if {$::optable(Oldest) > 0} {
    append r [::optable::_subsec $tr(OprepOldest)]
    append r [sc_report opening best o $::optable(Oldest)]
  }
  if {$::optable(Newest) > 0} {
    append r [::optable::_subsec $tr(OprepNewest)]
    append r [sc_report opening best n $::optable(Newest)]
  }

  if {$::optable(Popular) > 0} {
    append r [::optable::_subsec $tr(OprepPopular)]
    set next ""
    if {$fmt == "latex"} { set next " & " }

    # A table showing popularity by year ranges:
    if {$fmt == "latex"} {
      append r "\\begin{tabular}{lccccccc}\n\\hline\n"
    } else {
      append r $preText
    }

    set sYear $tr(Year)
    set sEvery [::utils::string::Capital $tr(OprepEvery)]
    regsub "%u" $sEvery X sEvery
    set len [string length $sYear]
    if {[string length $sEvery] > $len} { set len [string length $sEvery] }
    append r [::utils::string::Pad $tr(Year) $len]
    
    # Display decade ranges dynamically based on stored decade starts
    foreach start $::optable::_data(decadeStarts) {
      # Calculate end year based on start year (early bins have different sizes)
      if {$start == 1800} {
        set end 1899
      } elseif {$start == 1900} {
        set end 1949
      } else {
        set end [expr {$start + 9}]
      }
      # Format the range label (e.g., "1800-99", "1950-59", "2020-29")
      set endShort [string range $end 2 3]
      append r $next
      append r [::utils::string::PadCenter "${start}-${endShort}" 8]
    }

    append r $n
    append r [::utils::string::Pad $sEvery $len]
    foreach start $::optable::_data(decadeStarts) {
      append r $next
      append r [::utils::string::PadCenter $::optable::_data(range$start) 8]
    }
    append r $n
    if {$fmt == "latex"} {
      append r "\\hline\n\\end{tabular}\n"
    } else {
      append r $postText
    }

    append r "\n"

    # A table showing popularity in the last 1/5/10 years:
    if {$fmt == "latex"} {
      append r "\\begin{tabular}{lrr}\n"
    }

    foreach y {All 10 5 1} {
      if {$fmt == "ctext"} { append r "<tt>" }
      append r $tr(OprepFreq$y)
      if {$fmt == "ctext"} { append r "</tt>" }
      append r $next
      append r [format $tr(OprepEvery) $::optable::_data(ratio$y)]
      if {$y != "All"} {
        append r $next
        set d $::optable::_data(delta$y)
        if {$d > 0} {
          append r " ([format $tr(OprepUp) $d $percent])"
        } elseif {$d < 0} {
          append r " ([format $tr(OprepDown) [expr 0- $d] $percent])"
        } else {
          append r " ($tr(OprepSame))"
        }
      }
      append r "$n"
    }
    if {$fmt == "latex"} {
      append r "\\end{tabular}\n"
    }
  }

  if {$::optable(MostFrequent) > 0  &&  $::optable(MostFrequentWhite)} {
    append r [::optable::_subsec "$tr(OprepMostFrequent) ($tr(White))"]
    append r [sc_report opening players white $::optable(MostFrequent)]
  }
  if {$::optable(MostFrequent) > 0  &&  $::optable(MostFrequentBlack)} {
    append r [::optable::_subsec "$tr(OprepMostFrequent) ($tr(Black))"]
    append r [sc_report opening players black $::optable(MostFrequent)]
  }

  if {$::optable(AvgPerf)  ||  $::optable(HighRating)} {
    append r [::optable::_sec $tr(OprepRatingsPerf)]
  }
  if {$::optable(AvgPerf)} {
    append r [::optable::_subsec $tr(OprepAvgPerf)]
    set e [sc_report opening elo white]
    set welo [lindex $e 0]; set wng [lindex $e 1]
    set bpct [lindex $e 2]; set bperf [lindex $e 3]
    set e [sc_report opening elo black]
    set belo [lindex $e 0]; set bng [lindex $e 1]
    set wpct [lindex $e 2]; set wperf [lindex $e 3]
    append r "$tr(OprepWRating): $welo ($wng $games);  "
    append r "$tr(OprepWPerf): $wperf ($wpct$percent vs $belo)$n"
    append r "$tr(OprepBRating): $belo ($bng $games);  "
    append r "$tr(OprepBPerf): $bperf ($bpct$percent vs $welo)$n"
  }

  if {$::optable(HighRating) > 0} {
    append r [::optable::_subsec $tr(OprepHighRating)]
    append r [sc_report opening best a $::optable(HighRating)]
  }

  if {$::optable(Results)  ||
    ($::optable(Shortest) > 0  &&
    ($::optable(ShortestBlack) || $::optable(ShortestBlack)))} {
    append r [::optable::_sec $tr(OprepTrends)]
  }

  if {$::optable(Results)} {
    append r [::optable::_subsec $::tr(OprepResults)]
    append r [::optable::results opening $fmt]
  }

  if {$::optable(Shortest) > 0  &&  $::optable(ShortestWhite)} {
    append r [::optable::_subsec "$tr(OprepShortest) ($tr(White))"]
    append r [sc_report opening best w $::optable(Shortest)]
  }
  if {$::optable(Shortest) > 0  &&  $::optable(ShortestBlack)} {
    append r [::optable::_subsec "$tr(OprepShortest) ($tr(Black))"]
    append r [sc_report opening best b $::optable(Shortest)]
  }

  if {$::optable(MoveOrders) > 0  ||
    $::optable(MovesFrom) > 0  ||
    $::optable(Themes) > 0  ||
    $::optable(Endgames) > 0} {
    append r [::optable::_sec $tr(OprepMovesThemes)]
  }
  if {$::optable(MoveOrders) > 0} {
    append r [::optable::_subsec $tr(OprepMoveOrders)]
    set nOrders [sc_report opening moveOrders 0]
    set maxOrders $::optable(MoveOrders)
    if {$nOrders == 1} {
      append r $tr(OprepMoveOrdersOne)
    } elseif {$nOrders <= $maxOrders} {
      append r [format $tr(OprepMoveOrdersAll) $nOrders]
    } else {
      append r [format $tr(OprepMoveOrdersMany) $nOrders $maxOrders]
    }
    append r $n
    append r [::trans [sc_report opening moveOrders $maxOrders]]
  }
  if {$::optable(MovesFrom)} {
    append r [::optable::_subsec $tr(OprepMovesFrom)]
    if {$fmt == "latex"} {
      append r $::optable::_data(latexTree)
    } else {
      append r $preText
      append r $::optable::_data(tree)
      append r $postText
    }
  }

  if {$::optable(Themes) > 0} {
    append r [::optable::_subsec $tr(OprepThemes)]
    append r [sc_report opening themes $tr(OprepThemeDescription:) \
        $tr(OprepThemeSameCastling:) $tr(OprepThemeOppCastling:) \
        $tr(OprepThemeKPawnStorm:) $tr(OprepThemeQueenswap:) \
        $tr(OprepTheme1BishopPair:) \
        $tr(OprepThemeWIQP:) $tr(OprepThemeBIQP:) \
        $tr(OprepThemeWP567:) $tr(OprepThemeBP234:) \
        $tr(OprepThemeOpenCDE:) ]
  }

  if {$::optable(Endgames) > 0} {
    append r [::optable::_subsec $tr(OprepEndgames)]
    append r "$tr(OprepEndClass:)$n"
    append r [sc_report opening endmat]
  }

  if {$withTable  &&  $::optable(MaxGames) > 0} {
    set sec [::optable::_sec $tr(OprepTheoryTable)]
    set comment ""
    if {$tgames > $::optable(MaxGames)} {
      set comment [format $tr(OprepTableComment) $::optable(MaxGames)]
    }
    append r [sc_report opening print $numRows $sec $comment]
    # puts [sc_report opening print $numRows $sec $comment]
  }

  append r $::optable::_docEnd($fmt)


  return $r
}

# table:
#   Produces only the ECO table, not any other part of the report.
#
proc ::optable::table {fmt} {
  sc_report opening format $fmt
  set ::optable::_data(fmt) $fmt
  set r {}
  append r $::optable::_docStart($fmt)
  set r [string map [list "\[OprepTitle\]" $::tr(OprepTitle)] $r]
  append r [sc_report opening print]
  append r $::optable::_docEnd($fmt)
  return $r
}


set reportFavorites {}

# updateFavoritesMenu
#   Update the Favorites menu in the report window, adding a
#   command for each favorite report position.
#
proc ::optable::updateFavoritesMenu {} {
  set m .oprepWin.menu.favorites
  $m delete 3 end
  $m add separator
  foreach entry $::reportFavorites {
    set name [lindex $entry 0]
    set moves [lindex $entry 1]
    $m add command -label $name \
        -command "importMoveList [list $moves]; ::optable::makeReportWin"
  }
  if {[llength $::reportFavorites] == 0} {
    $m entryconfigure 1 -state disabled
    $m entryconfigure 2 -state disabled
  } else {
    $m entryconfigure 1 -state normal
    $m entryconfigure 2 -state normal
  }
}

# favoriteReportNames
#   Return a list of the favorite report names.
#
proc ::optable::favoriteReportNames {} {
  set reportNames {}
  foreach entry $::reportFavorites {
    lappend reportNames [lindex $entry 0]
  }
  return $reportNames
}

# addFavoriteDlg
#   Adds the current position to the opening report favorites list.
#
proc ::optable::addFavoriteDlg {} {
  set w .addFavoriteDlg
  win::createDialog $w
  wm title $w "scidCommunity: Add Opening Report Favorite"
  ttk::label $w.name -text "Enter a name for the opening report of this position:"
  pack $w.name -side top
  ttk::entry $w.e -width 40
  pack $w.e -side top -fill x -padx 2
  addHorizontalRule $w
  ttk::label $w.old -text "Existing favorite report names:"
  pack $w.old -side top
  autoscrollText y $w.existing $w.existing.list Treeview
  $w.existing.list configure -width 30 -height 10 -state normal
  pack $w.existing -side top -fill both -expand yes
  foreach entry $::reportFavorites {
    $w.existing.list insert end "[lindex $entry 0]\n"
  }
  $w.existing.list configure -state disabled
  addHorizontalRule $w
  ttk::frame $w.b
  pack $w.b -side bottom -fill x
  ttk::button $w.b.ok -text OK -command ::optable::addFavoriteOK
  ttk::button $w.b.cancel -text $::tr(Cancel) -command "grab release $w; destroy $w"
  packdlgbuttons $w.b.cancel $w.b.ok
  focus $w.e
  grab $w
}

proc ::optable::addFavoriteOK {} {
  global reportFavorites
  set w .addFavoriteDlg
  set reportName [$w.e get]
  set err ""
  if {$reportName == ""} {
    set err "The report name must not be empty."
  } elseif {[lsearch -exact [::optable::favoriteReportNames] $reportName] >= 0} {
    set err "That name is already used for another favorite report position."
  } else {
    lappend reportFavorites [list $reportName [sc_game moves]]
    ::optable::saveFavorites
    ::optable::updateFavoritesMenu
    grab release $w
    destroy $w
    return
  }
  tk_messageBox -title scidCommunity -icon info -type ok -message $err
}

set reportFavoritesName ""

# editFavoritesDlg
#   Open the dialog box for editing the list of opening report
#   favorite positions.
#
proc ::optable::editFavoritesDlg {} {
  global reportFavorites reportFavoritesTemp reportFavoritesName
  set w .editFavoritesDlg
  if {[winfo exists $w]} { return }

  set ::reportFavoritesTemp $::reportFavorites
  win::createDialog $w
  wm title $w "scidCommunity: [tr OprepFavoritesEdit]"
  # wm transient $w .
  bind $w <F1> {helpWindow Reports Opening}
  ttk::entry $w.e -width 60 \
      -textvariable reportFavoritesName -exportselection 0
  $w.e configure -validate key -validatecommand "after 200 ::optable::editFavoritesRefresh; return true"
  pack $w.e -side top -fill x
  pack [ttk::frame $w.b] -side bottom -fill x
  ttk::frame $w.f
  ttk::treeview $w.f.list -columns {0} -show {} -selectmode browse \
             -yscrollcommand "$w.f.ybar set"
  $w.f.list configure -height 10
  $w.f.list column 0 -width 50
  ttk::scrollbar $w.f.ybar -takefocus 0 -command "$w.f.list yview"
  pack $w.f.ybar -side right -fill y
  pack $w.f.list -side left -fill both -expand 1
  pack $w.f -side top -fill both -expand yes
  bind $w.f.list <<TreeviewSelect>>  ::optable::editFavoritesSelect
  set i 0
  foreach entry $::reportFavoritesTemp {
    set name [lindex $entry 0]
    set moves [lindex $entry 1]
    $w.f.list insert {} end -id $i -values [list "$name \[$moves\]"]
    incr i
  }
  ttk::button $w.b.delete -text $::tr(Delete)  -command ::optable::editFavoritesDelete
  ttk::button $w.b.up -image tb_up -command {::optable::editFavoritesMove up}
  ttk::button $w.b.down -image tb_down -command {::optable::editFavoritesMove down}
  ttk::button $w.b.ok -text "OK" -command ::optable::editFavoritesOK
  ttk::button $w.b.cancel -text $::tr(Cancel) -command {
    catch {grab release .editFavoritesDlg}
    destroy .editFavoritesDlg
  }
  pack $w.b.delete $w.b.up $w.b.down -side left -padx 2 -pady 2
  packdlgbuttons $w.b.cancel $w.b.ok
  set editFavoritesName ""

  wm protocol $w WM_DELETE_WINDOW [list $w.b.cancel invoke]
  update
  catch {grab $w}
}

proc ::optable::editFavoritesRefresh {args} {
  global reportFavoritesTemp reportFavoritesName
  set list .editFavoritesDlg.f.list
  set sel [lindex [$list selection] 0]
  if {$sel == ""} { return }
  set name $reportFavoritesName
  set e [lindex $reportFavoritesTemp $sel]
  set moves [lindex $e 1]
  set e [lreplace $e 0 0 $name]
  set reportFavoritesTemp [lreplace $reportFavoritesTemp $sel $sel $e]
  $list item $sel -values [list "$name \[$moves\]"]
  $list selection set $sel
}

proc ::optable::editFavoritesSelect {} {
  set list .editFavoritesDlg.f.list
  set sel [lindex [$list selection] 0]
  if {$sel == ""} {
    set ::reportFavoritesName ""
    return
  }
  if {$sel >= [llength $::reportFavoritesTemp]} {
    set ::reportFavoritesName ""
    return
  }
  set e [lindex $::reportFavoritesTemp $sel]
  set ::reportFavoritesName [lindex $e 0]
}

proc ::optable::editFavoritesDelete {} {
  global reportFavoritesTemp
  set w .editFavoritesDlg
  set list $w.f.list
  set sel [lindex [$list selection] 0]
  if {$sel == ""} { return }
  set reportFavoritesTemp [lreplace $reportFavoritesTemp $sel $sel]
  $list delete $sel
  set ::reportFavoritesName ""

}

proc ::optable::editFavoritesMove {dir} {
  global reportFavoritesTemp
  set w .editFavoritesDlg
  set list $w.f.list
  set sel [lindex [$list selection] 0]
  if {$sel == ""} { return }
  set e [lindex $reportFavoritesTemp $sel]
  set name [lindex $e 0]
  set moves [lindex $e 1]
  set text "$name \[$moves\]"

  set newsel $sel
  if {$dir == "up"} {
    incr newsel -1
    if {$newsel < 0} { return }
  } else {
    incr newsel
    if {[$list next $sel] == {} } { return }
  }
  set reportFavoritesTemp [lreplace $reportFavoritesTemp $sel $sel]
  set reportFavoritesTemp [linsert $reportFavoritesTemp $newsel $e]
  set i 0
  foreach entry $::reportFavoritesTemp {
    set name [lindex $entry 0]
    set moves [lindex $entry 1]
    $w.f.list item $i -values [list "$name \[$moves\]"]
    incr i
  }
  $list selection set $newsel
}

proc ::optable::editFavoritesOK {} {
  set w .editFavoritesDlg
  catch {grab release $w}
  destroy $w
  set ::reportFavorites $::reportFavoritesTemp
  ::optable::saveFavorites
  ::optable::updateFavoritesMenu
}

proc ::optable::favoritesFilename {} {
  return [scidConfigFile reports]
}

proc ::optable::saveFavorites {} {
  set fname [::optable::favoritesFilename]
  if {[catch {open $fname w} f]} {
    # tk_messageBox ...
    return
  }
  puts $f "# Scid opening report favorites file"
  puts $f ""
  puts $f "set reportFavorites [list $::reportFavorites]"
  close $f
}

proc ::optable::loadFavorites {} {
  global reportFavorites
  set fname [::optable::favoritesFilename]
  catch {source $fname}
}

::optable::loadFavorites

set reportFormat html
set reportType full

proc ::optable::generateFavoriteReports {} {
  global reportFavorites
  if {[llength $reportFavorites] == 0} {
    tk_messageBox -title "scidCommunity" -type ok -icon info \
        -message "You have no favorite report positions."
    return
  }
  set ::reportDir $::initialDir(report)

  set w .reportFavoritesDlg
  if {[winfo exists $w]} { return }
  win::createDialog $w
  wm title $w "scidCommunity: Generate Reports..."
  pack [ttk::label $w.typelabel -text "Select the report type:" -font font_Bold] -side top -anchor w
  pack [ttk::frame $w.type] -side top -anchor w
  ttk::radiobutton $w.type.full -text "Full" -variable reportType -value full
  ttk::radiobutton $w.type.compact -text "Compact (no theory table)" -variable reportType -value compact
  ttk::radiobutton $w.type.theory -text "Theory table only" -variable reportType -value theory
  pack $w.type.full $w.type.compact $w.type.theory -side left -padx 5
  addHorizontalRule $w
  pack [ttk::label $w.fmtlabel -text "Select the report file format:" -font font_Bold] -side top -anchor w
  pack [ttk::frame $w.fmt] -side top -anchor w
  ttk::radiobutton $w.fmt.text -text "Plain text (.txt)" -variable reportFormat -value text
  ttk::radiobutton $w.fmt.html -text "HTML" -variable reportFormat -value html
  pack $w.fmt.text $w.fmt.html $w.fmt.latex -side left -padx 5
  addHorizontalRule $w
  pack [ttk::frame $w.dir] -side top
  ttk::label $w.dir.label -text "Save reports in the folder: " -font font_Bold
  ttk::entry $w.dir.entry -textvariable ::reportDir
  ttk::button $w.dir.choose -text $::tr(Browse...) -command {
    set tmpdir [tk_chooseDirectory -parent .reportFavoritesDlg \
        -title "Scid: Choose Report Folder"]
    if {$tmpdir != ""} {
      set ::reportDir [file nativename $tmpdir]
    }
  }
  pack $w.dir.label -side left
  pack $w.dir.choose -side right -pady 3
  pack $w.dir.entry -side left -fill x -padx 5
  addHorizontalRule $w
  pack [ttk::frame $w.b] -side bottom -fill x
  ttk::button $w.b.ok -text "OK"\
      -command "::optable::reportFavoritesOK; grab release $w; destroy $w; ::optable::makeReportWin"
  ttk::button $w.b.cancel -text $::tr(Cancel) -command "grab release $w; destroy $w"
  packdlgbuttons $w.b.cancel $w.b.ok
  grab $w
}

proc ::optable::reportFavoritesOK {} {
  global reportDir reportFormat reportType
  set ::initialDir(report) $reportDir
  set fmt $reportFormat
  switch $reportFormat {
    "html" { set suffix ".html" }
    "text" { set suffix ".txt" }
    "latex" { set suffix "tex" }
  }

  set w .reportsProgress
  toplevel $w
  wm withdraw $w
  wm title $w "scidCommunity: Generating Reports"
  bind $w <Visibility> "raiseWin $w"
  pack [ttk::label $w.t -width 40 -text "Generating reports. Please wait..." -font font_Bold] -side top -pady 5
  pack [ttk::label $w.report] -side top -pady 5
  wm deiconify $w
  grab $w
  update

  set count 0
  set total [llength $::reportFavorites]
  foreach entry $::reportFavorites {
    set name [lindex $entry 0]
    set moves [lindex $entry 1]
    set fname [file join $reportDir "$name$suffix"]
    if {[catch {open $fname w} f]} {
      tk_messageBox -title "scidCommunity" -icon warning -type ok \
          -message "Unable to write file: $fname\n$f"
      grab release $w
      destroy $w
      return
    }
    incr count
    $w.report configure -text "$count / $total: $name$suffix"
    update
    sc_game push
    sc_move addSan $moves
    ::optable::makeReportWin -nodisplay -noprogress
    if {$reportType == "theory"} {
      set report [::optable::table $fmt]
    } elseif {$reportType == "compact"} {
      set report [::optable::report $fmt 0 $::optable::_flip]
    } else {
      set report [::optable::report $fmt 1 $::optable::_flip]
    }
    if {$::hasEncoding  &&  $::langEncoding($::language) != ""} {
      catch {set report [encoding convertto $::langEncoding($::language) $report]}
    }
    sc_game pop
    puts $f $report
    close $f
  }
  grab release $w
  destroy $w
}

# end of optable.tcl
