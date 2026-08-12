#
# tcl/tools/iccf.tcl
# Play on ICCF feature for scidCommunity
# Uses xfcc/SOAP protocol to interact with the ICCF chess server
#

namespace eval iccf {

# ICCF state variables (credentials loaded from options.dat, others initialized here)
variable username
variable password
variable server
variable playing 0
variable games {}
variable yourTurnGames {}
variable waitingGames {}
variable selectedGame -1
variable savedGameNum 0
variable gameData
variable gameToDbMap
variable treeview ""
variable treeviewWaiting ""
variable yourMsgWidget ""
variable statusText ""
variable sortCol
variable sortDir
variable sentGames
variable pendingMessages
variable drawOffers
variable resigns
variable acceptDraws

# SOAP settings
variable soapNS "http://www.bennedik.com/webservices/XfccBasic"

}
# Initialize server if not already set by options
if {![info exists ::iccf::server] || $::iccf::server eq ""} {
  set ::iccf::server "https://www.iccf.com/xfccbasic.asmx"
}

#
# ::iccf::config - Entry point from Play menu
# Checks for stored credentials, shows login dialog if needed
#
proc ::iccf::config {} {
  if {[winfo exists .iccf]} {
    raise .iccf
    return
  }
  if {[winfo exists .lssConfig]} {
    raise .lssConfig
    return
  }

  set ::iccf::savedGameNum 0
  set ::iccf::games {}
  set ::iccf::yourTurnGames {}
  set ::iccf::waitingGames {}
  catch {array unset ::iccf::gameData}
  catch {array unset ::iccf::gameToDbMap}
  catch {array unset ::iccf::sentGames}
  catch {array unset ::iccf::pendingMessages}
  catch {array unset ::iccf::drawOffers}
  catch {array unset ::iccf::resigns}
  catch {array unset ::iccf::acceptDraws}

  if {$::iccf::username ne "" && $::iccf::password ne ""} {
    ::iccf::connect
  } else {
    ::iccf::loginDialog
  }
}

#
# ::iccf::loginDialog - Show dialog for ICCF username/password
#
proc ::iccf::loginDialog {} {
  set w .lssConfig
  ::win::createDialog $w
  wm title $w $::tr(ICCFTitle)

  ttk::frame $w.f -padding 10

  ttk::label $w.f.llogin -text "$::tr(ICCFLogin):"
  ttk::entry $w.f.elogin -textvariable ::iccf::username -width 30

  ttk::label $w.f.lpass -text "$::tr(ICCFPassword):"
  ttk::entry $w.f.epass -textvariable ::iccf::password -width 30 -show "*"

  ttk::frame $w.f.buttons
  ttk::button $w.f.buttons.connect -text $::tr(ICCFConnect) -command {
    if {$::iccf::username eq "" || $::iccf::password eq ""} {
      tk_messageBox -message $::tr(ICCFCredentialsNeeded) -icon warning -parent .lssConfig
      return
    }
    options.write
    destroy .lssConfig
    ::iccf::connect
  }
  ttk::button $w.f.buttons.cancel -text $::tr(Cancel) -command { destroy .lssConfig }

  grid $w.f.llogin -row 0 -column 0 -sticky e -padx 5 -pady 3
  grid $w.f.elogin -row 0 -column 1 -sticky we -padx 5 -pady 3
  grid $w.f.lpass  -row 1 -column 0 -sticky e -padx 5 -pady 3
  grid $w.f.epass  -row 1 -column 1 -sticky we -padx 5 -pady 3

  grid $w.f.buttons.connect -row 0 -column 0 -padx 5 -pady 10
  grid $w.f.buttons.cancel  -row 0 -column 1 -padx 5 -pady 10

  grid $w.f.buttons -row 2 -column 0 -columnspan 2 -pady 10

  ttk::label $w.f.website -text "Website: https://www.iccf.com" \
    -foreground blue -cursor hand2 -font font_Small
  bind $w.f.website <ButtonRelease-1> {openURL "https://www.iccf.com"}
  grid $w.f.website -row 3 -column 0 -columnspan 2

  pack $w.f -fill both -expand yes

  bind $w <Escape> "destroy $w"
  bind $w <Return> "$w.f.buttons.connect invoke"
  focus $w.f.elogin
}

#
# ::iccf::escapeXml - Escape special characters for XML
#
proc ::iccf::escapeXml {text} {
  set text [string map {& &amp; < &lt; > &gt; \" &quot; \' &apos;} $text]
  return $text
}

#
# ::iccf::unescapeXml - Unescape XML special characters
#
proc ::iccf::unescapeXml {text} {
  set text [string map {&amp; & &lt; < &gt; > &quot; \" &apos; \' &#39; \' &#13; \n} $text]
  return $text
}

#
# ::iccf::soapRequest - Make a SOAP HTTP request
# Returns the response body text, or empty on error
#
proc ::iccf::soapRequest {action soapBody {timeout 30000}} {
  set soapEnvelope "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"$::iccf::soapNS\">
    <soap:Header/>
    <soap:Body>
        $soapBody
    </soap:Body>
</soap:Envelope>"

  set soapAction "$::iccf::soapNS/$action"
  set timeoutSec [expr {$timeout / 1000}]

  if {[catch {
    exec curl -s -S -m $timeoutSec \
      -H "Content-Type: text/xml; charset=utf-8" \
      -H "SOAPAction: $soapAction" \
      -H "User-Agent: scidCommunity-ICCF/1.0" \
      -d @- << $soapEnvelope \
      $::iccf::server
  } result]} {
    return ""
  }

  # exec decodes stdout with the system encoding, which mangles UTF-8 when
  # the system encoding is not UTF-8 (e.g. latin-1). Round-trip through
  # system-encoding bytes and re-decode as UTF-8; a no-op when the system
  # encoding is already UTF-8.
  set result [encoding convertfrom utf-8 [encoding convertto [encoding system] $result]]

  return $result
}

#
# ::iccf::fetchGames - Call GetMyGames SOAP and parse response
# Returns a list of dicts, each representing one game
#
proc ::iccf::fetchGames {} {
  set soapBody "
        <ns:GetMyGames>
            <ns:username>[::iccf::escapeXml $::iccf::username]</ns:username>
            <ns:password>[::iccf::escapeXml $::iccf::password]</ns:password>
        </ns:GetMyGames>"

  set response [::iccf::soapRequest "GetMyGames" $soapBody]
  if {$response eq ""} {
    return -code error [::tr ICCFConnectionFailed]
  }

  if {[regexp {AuthenticationFailed|InvalidUsernameOrPassword} $response]} {
    return -code error [::tr ICCFAuthFailed]
  }

  return [::iccf::parseGetMyGamesResponse $response]
}

#
# ::iccf::parseGetMyGamesResponse - Parse the SOAP XML response from GetMyGames
# Extracts XfccGame elements into a list of dicts
#
proc ::iccf::parseGetMyGamesResponse {xml} {
  set games {}

  # Remove newlines between tags
  regsub -all {\n} $xml "" xml
  regsub -all {>[\t ]+<} $xml {><} xml

  # Strip namespace prefixes only within tags: <ns1:tag> -> <tag>, </ns1:tag> -> </tag>
  regsub -all {<(/?)\w+:} $xml {<\1} xml

  set pattern {<XfccGame>(.*?)</XfccGame>}
  set matches [regexp -all -inline $pattern $xml]

  foreach {full inner} $matches {
    set gameDict {}

    set fieldPattern {<(id|white|black|event|myTurn|hasWhite|whiteElo|blackElo|setup|fen|moves|drawOffered|message|daysOpponent|hoursOpponent|minutesOpponent|daysPlayer|hoursPlayer|minutesPlayer|serverInfo|eventDate|site|whiteTitle|blackTitle|whiteNA|blackNA|eventSponsor|section|stage|board|timeControl|result|variant|noEngines|whiteCountry|blackCountry|whiteIccfID|blackIccfID|whiteFideID|blackFideID)>([^<]*)</\1>}

    set fields [regexp -all -inline $fieldPattern $inner]

    foreach {f1 tag value} $fields {
      set val [::iccf::unescapeXml $value]

      if {$tag in {id whiteElo blackElo daysOpponent hoursOpponent minutesOpponent daysPlayer hoursPlayer minutesPlayer whiteIccfID blackIccfID whiteFideID blackFideID}} {
        if {[string is integer -strict $val]} {
          set val [expr {$val}]
        }
      }

      dict set gameDict $tag $val
    }

    if {[dict exists $gameDict id]} {
      lappend games $gameDict
    }
  }

  return $games
}

#
# ::iccf::getTagValue - Extract a single tag value from XML text
#
proc ::iccf::getTagValue {xml tag} {
  if {[regexp "<${tag}>(.*?)</${tag}>" $xml -> val]} {
    return [::iccf::unescapeXml $val]
  }
  return ""
}

#
# ::iccf::connect - Create the main "Play on ICCF" window
#
proc ::iccf::connect {} {
  if {[winfo exists .iccf]} {
    raise .iccf
    return
  }

  if {![sc_base inUse]} {
    tk_messageBox -message $::tr(ICCFNoDatabase) -icon warning
    return
  }

  set ::iccf::games {}
  set ::iccf::yourTurnGames {}
  set ::iccf::waitingGames {}
  set ::iccf::selectedGame -1
  catch {array unset ::iccf::gameData}
  catch {array unset ::iccf::gameToDbMap}
  catch {array unset ::iccf::sentGames}
  catch {array unset ::iccf::pendingMessages}
  catch {array unset ::iccf::drawOffers}
  catch {array unset ::iccf::resigns}
  catch {array unset ::iccf::acceptDraws}

  set w .iccf
  ::createToplevel $w "" 1
  ::setTitle $w $::tr(ICCFTitle)
  wm protocol $w WM_DELETE_WINDOW "::iccf::closeWindow"

  ::iccf::createWindow $w
}

#
# ::iccf::createWindow - Build the ICCF window UI
#
proc ::iccf::createWindow {w} {
  bind $w <Escape> "::iccf::closeWindow"
  bind $w <FocusIn> "if {\[winfo exists $w\]} { ::iccf::populateGameList }"

  # Branding with logo
  set logoPath [file join $::scidImgDir LSS iccf.png]
  ttk::frame $w.brandframe -style fieldbg.TFrame
  if {![catch {image create photo ::iccf::logo -file $logoPath}]} {
    ttk::label $w.brandframe.lbl -image ::iccf::logo \
      -compound left -font font_Bold -style fieldbg.TLabel
  } else {
    ttk::label $w.brandframe.lbl -text "ICCF" \
      -font font_Bold -style fieldbg.TLabel
  }
  pack $w.brandframe.lbl -anchor w -padx 5
  pack $w.brandframe -fill x -pady {5 0}

  # Main notebook for tabs
  set nb $w.nb
  ttk::notebook $nb

  # Tab 1: Your Turn
  set tab1 $nb.yourturn
  ttk::frame $tab1
  $nb add $tab1 -text $::tr(ICCFYourTurn)

  # Update Games and Send Moves buttons
  ttk::frame $tab1.top
  ttk::button $tab1.top.update -text $::tr(ICCFUpdateGames) -command ::iccf::updateGames
  ttk::button $tab1.top.send -text $::tr(ICCFSendMoves) -command ::iccf::sendMoves
  ttk::label $tab1.top.status -textvariable ::iccf::statusText -width 50
  pack $tab1.top.update -side left -padx 5 -pady 5
  pack $tab1.top.status -side left -padx 5 -pady 5
  pack $tab1.top.send -side right -padx 5 -pady 5

  # Your Turn game list treeview
  set f1 $tab1.glist
  ttk::frame $f1
  set t1 $f1.tree
  set cols {ICCFGameID ICCFOpponent ICCFEvent ICCFYourTime ICCFOppTime ICCFLastMove ICCFDrawOffered ICCFYourMove ICCFOfferDraw ICCFResign ICCFSent}
  ttk::treeview $t1 -columns $cols -show headings -selectmode browse
  foreach {col text} {ICCFGameID ICCFGameID ICCFOpponent ICCFOpponent ICCFEvent ICCFEvent
    ICCFYourTime ICCFMyTime ICCFOppTime ICCFOppTime ICCFLastMove ICCFLastMove
    ICCFDrawOffered ICCFDrawOffered ICCFYourMove ICCFYourMove ICCFOfferDraw ICCFOfferDraw ICCFResign ICCFResign ICCFSent ICCFSent} {
    $t1 heading $col -text $::tr($text) -command [list ::iccf::onSortClick $t1 $col]
  }
  set arrowWidth [font measure font_Regular " \u25B2"]
  set extraWidth {ICCFGameID 5 ICCFOpponent 30 ICCFEvent 35 ICCFYourTime 15 ICCFOppTime 15}
  foreach col $cols {
    set text [$t1 heading $col -text]
    set extra [expr {[dict exists $extraWidth $col] ? [dict get $extraWidth $col] : 0}]
    $t1 column $col -width [expr {[font measure font_Regular $text] + 14 + $arrowWidth + $extra}] -stretch no
  }
  # Center move text and status columns
  $t1 column ICCFLastMove -width [expr {[$t1 column ICCFLastMove -width] + 10}] -anchor center
  $t1 column ICCFYourMove -anchor center
  $t1 column ICCFDrawOffered -anchor center
  $t1 column ICCFOfferDraw -anchor center
  $t1 column ICCFResign -anchor center
  $t1 column ICCFSent -anchor center
  $t1 tag configure timeLow -foreground #cc6600
  $t1 tag configure timeUrgent -foreground red
  set vsb1 [ttk::scrollbar $f1.vsb -orient vertical -command "$t1 yview"]
  set hsb1 [ttk::scrollbar $f1.hsb -orient horizontal -command "$t1 xview"]
  $t1 configure -yscrollcommand "$vsb1 set" -xscrollcommand "$hsb1 set"
  grid $t1  $vsb1 -sticky news
  grid $hsb1       -sticky we
  grid rowconfigure $f1 0 -weight 1
  grid rowconfigure $f1 1 -weight 0
  grid columnconfigure $f1 0 -weight 1
  bind $t1 <Double-ButtonRelease-1> "::iccf::loadSelectedGame %W %x %y"
  bind $t1 <<TreeviewSelect>> "::iccf::onGameSelect %W"
  bind $t1 <ButtonRelease-1> "::iccf::onDrawClick %W %x %y"

  pack $tab1.top -fill x
  pack $f1 -fill both -expand yes -padx 5 -pady {5 0}

  # Message area for Your Turn tab (ICCF: no opponent messages)
  ttk::frame $tab1.messages
  ttk::label $tab1.messages.lbl -text "$::tr(ICCFYourMessage):"
  text $tab1.messages.txt -width 35 -height 4 -wrap word
  grid $tab1.messages.lbl -row 0 -column 0 -sticky w
  grid $tab1.messages.txt -row 1 -column 0 -sticky news
  grid rowconfigure $tab1.messages 1 -weight 1
  grid columnconfigure $tab1.messages 0 -weight 1
  pack $tab1.messages -fill both -expand yes -padx 5 -pady 5

  # Tab 2: Waiting
  set tab2 $nb.waiting
  ttk::frame $tab2
  $nb add $tab2 -text $::tr(ICCFWaiting)
  ttk::frame $tab2.glist
  set t2 $tab2.glist.tree
  set cols2 {ICCFGameID ICCFOpponent ICCFEvent ICCFYourTime ICCFOppTime ICCFLastMove}
  ttk::treeview $t2 -columns $cols2 -show headings -selectmode browse
  foreach {col text} {ICCFGameID ICCFGameID ICCFOpponent ICCFOpponent ICCFEvent ICCFEvent
    ICCFYourTime ICCFMyTime ICCFOppTime ICCFOppTime ICCFLastMove ICCFLastMove} {
    $t2 heading $col -text $::tr($text) -command [list ::iccf::onSortClick $t2 $col]
  }
  foreach col $cols2 {
    set text [$t2 heading $col -text]
    set extra [expr {[dict exists $extraWidth $col] ? [dict get $extraWidth $col] : 0}]
    $t2 column $col -width [expr {[font measure font_Regular $text] + 14 + $arrowWidth + $extra}] -stretch no
  }
  $t2 column ICCFLastMove -width [expr {[$t2 column ICCFLastMove -width] + 20}] -stretch yes -anchor center
  $t2 tag configure timeLow -foreground #cc6600
  $t2 tag configure timeUrgent -foreground red
  set vsb2 [ttk::scrollbar $tab2.glist.vsb -orient vertical -command "$t2 yview"]
  set hsb2 [ttk::scrollbar $tab2.glist.hsb -orient horizontal -command "$t2 xview"]
  $t2 configure -yscrollcommand "$vsb2 set" -xscrollcommand "$hsb2 set"
  grid $t2  $vsb2 -sticky news
  grid $hsb2       -sticky we
  grid rowconfigure $tab2.glist 0 -weight 1
  grid rowconfigure $tab2.glist 1 -weight 0
  grid columnconfigure $tab2.glist 0 -weight 1
  bind $t2 <Double-ButtonRelease-1> "::iccf::loadSelectedGame %W %x %y"
  pack $tab2.glist -fill both -expand yes -padx 5 -pady 5

  # Store widget references
  set ::iccf::treeview $t1
  set ::iccf::treeviewWaiting $t2
  set ::iccf::yourMsgWidget $tab1.messages.txt

  # Default sort: My Clock ascending (least time first)
  ::iccf::setSort $t1 ICCFYourTime 1
  ::iccf::setSort $t2 ICCFYourTime 1

  # Bottom buttons
  ttk::frame $w.buttons
  ttk::button $w.buttons.close -text $::tr(ICCFClose) -command ::iccf::closeWindow
  pack $w.buttons.close -side right -padx 5 -pady 5

  pack $nb -fill both -expand yes
  pack $w.buttons -fill x -padx 5
}

#
# ::iccf::updateGames - Fetch games from ICCF and update database/gamelist
#
proc ::iccf::updateGames {} {
  if {![sc_base inUse]} {
    tk_messageBox -message $::tr(ICCFNoDatabase) -icon warning
    return
  }

  set ::iccf::statusText $::tr(ICCFUpdating)
  update idletasks

  set savedGame 0
  catch {set savedGame [sc_game number]}

  if {[catch {
    set ::iccf::games [::iccf::fetchGames]
  } err]} {
    set ::iccf::statusText ""
    if {$savedGame > 0} { catch {sc_game load $savedGame} }
    tk_messageBox -message $err -icon error -parent .iccf
    return
  }

  if {[llength $::iccf::games] == 0} {
    set ::iccf::statusText [::tr ICCFNoGamesFound]
    return
  }

  set newCount 0
  set updatedCount 0
  set unchangedCount 0
  set yourTurnList {}
  set waitingList {}

  catch {array unset ::iccf::gameData}
  catch {array unset ::iccf::gameToDbMap}

  set curDb [sc_base current]

  # Single fast filter pass to find all existing ICCF games
  if {[catch {sc_filter new $curDb} tmpFilter]} {
    set ::iccf::statusText [::tr ICCFFilterError]
    if {$savedGame > 0} { catch {sc_game load $savedGame} }
    return
  }
  catch {sc_filter reset $curDb $tmpFilter full}
  catch {sc_filter search $curDb $tmpFilter tags ICCF *}
  set nExisting [expr {[catch {sc_filter count $curDb $tmpFilter} c] ? 0 : $c}]

  # Build in-memory map: ICCF ID -> DB game number
  set idToGnum {}
  if {$nExisting > 0 && $nExisting < 50000} {
    foreach {idx line deleted} [sc_base gameslist $curDb 0 $nExisting $tmpFilter N+] {
      if {![regexp {^(\d+)_} $idx -> gnum]} { continue }
      if {[catch {sc_game load $gnum}]} { continue }
      set extra [sc_game tags get Extra]
      foreach eline [split $extra "\n"] {
        if {[regexp {^ICCF "([^"]+)"} $eline -> tagVal]} {
          dict set idToGnum $tagVal $gnum
          break
        }
      }
    }
  }
  catch {sc_filter reset $curDb $tmpFilter empty}

  foreach game $::iccf::games {
    set id [dict get $game id]
    set ::iccf::gameData($id) $game

    set dbGameNum -1
    if {[dict exists $idToGnum $id]} {
      set dbGameNum [dict get $idToGnum $id]
    }

    if {$dbGameNum > 0} {
      set ::iccf::gameToDbMap($id) $dbGameNum
      if {[::iccf::needsMoveUpdate $game $dbGameNum]} {
        ::iccf::updateGameMoves $game $dbGameNum
        incr updatedCount
      } else {
        incr unchangedCount
      }
    } else {
      set dbGameNum [::iccf::addNewGame $game $id "ICCF"]
      if {$dbGameNum > 0} {
        set ::iccf::gameToDbMap($id) $dbGameNum
        incr newCount
      }
    }

    if {![::iccf::gameStarted $game]} {
      # Game has not started yet: keep it out of the Your Turn tab
      lappend waitingList $id
    } elseif {[dictGetDefault $game myTurn "false"] && [string is true -strict [dictGetDefault $game myTurn "false"]]} {
      lappend yourTurnList $id
    } else {
      lappend waitingList $id
    }
  }

  set ::iccf::yourTurnGames $yourTurnList
  set ::iccf::waitingGames $waitingList
  catch {sc_filter reset $curDb $tmpFilter empty}

  set msg [format $::tr(ICCFGamesUpdated) $newCount $updatedCount $unchangedCount]
  set ::iccf::statusText $msg

  if {$savedGame > 0} { catch {sc_game load $savedGame} }

  ::iccf::populateGameList
}

#
# ::iccf::parseEventDate - Try to extract a PGN date (YYYY.MM.DD) from an event name
#   Looks for patterns like "2026-Aug" or "2026-Sep" etc.
#   Returns "????.??.??" if no date found
#
proc ::iccf::parseEventDate {event} {
  set months {Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06 Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12}
  if {[regexp {(\d{4})-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)} $event -> year mon]} {
    foreach {mAbbr mNum} $months {
      if {$mon eq $mAbbr} {
        return "$year.$mNum.??"
      }
    }
  }
  return "????.??.??"
}

#
# ::iccf::addNewGame - Create a new game in the database from ICCF data
#   Returns the new game number (1-based) or -1 on failure
#
proc ::iccf::addNewGame {game lssId tagName} {
  if {[catch {sc_game new}]} { return -1 }

  set white [dictGetDefault $game white "?"]
  set black [dictGetDefault $game black "?"]
  set event [dictGetDefault $game event ""]
  set whiteElo [dictGetDefault $game whiteElo 0]
  set blackElo [dictGetDefault $game blackElo 0]
  set eventDate [dictGetDefault $game eventDate ""]
  set site [dictGetDefault $game site [dictGetDefault $game serverInfo "ICCF"]]
  set result [dictGetDefault $game result "Ongoing"]
  set variant [dictGetDefault $game variant ""]
  set setup [dictGetDefault $game setup "false"]
  set startFen [dictGetDefault $game fen ""]

  # Map ICCF result to PGN result
  set pgnResult "*"
  switch $result {
    WhiteWins            { set pgnResult "1-0" }
    BlackWins            { set pgnResult "0-1" }
    Draw                 { set pgnResult "1/2-1/2" }
    WhiteWinAdjudicated  { set pgnResult "1-0" }
    BlackWinAdjudicated  { set pgnResult "0-1" }
    DrawAdjudicated      { set pgnResult "1/2-1/2" }
    WhiteDefaulted       { set pgnResult "1-0" }
    BlackDefaulted       { set pgnResult "0-1" }
    BothDefaulted        { set pgnResult "0-0" }
    Cancelled            { set pgnResult "*" }
    AdjudicationPending  { set pgnResult "*" }
    default              { set pgnResult "*" }
  }

  # Format date: use eventDate if provided, otherwise try to extract from event name
  set date ""
  set eventDate [dictGetDefault $game eventDate ""]
  if {$eventDate ne ""} {
    set date $eventDate
  } else {
    set date [::iccf::parseEventDate $event]
  }

  # Set tags
  set extraTags [list "$tagName \"$lssId\""]
  foreach {key tag} {
    timeControl TimeControl
    whiteTitle WhiteTitle
    blackTitle BlackTitle
    whiteNA WhiteNA
    blackNA BlackNA
    whiteCountry WhiteCountry
    blackCountry BlackCountry
    whiteIccfID WhiteIccfId
    blackIccfID BlackIccfId
    whiteFideID WhiteFideId
    blackFideID BlackFideId
    eventSponsor EventSponsor
    section Section
    stage Stage
    board Board
  } {
    set t [::iccf::makeExtraTag $game $key $tag]
    if {$t ne ""} { lappend extraTags $t }
  }
  if {[string is true -strict [dictGetDefault $game noEngines ""]]} {
    lappend extraTags "NoEngines \"1\""
  }
  set hasWhite [dictGetDefault $game hasWhite ""]
  if {$hasWhite ne "" && ![string is true -strict $hasWhite]} {
    lappend extraTags "FlipB \"1\""
  }
  if {$variant eq "Chess960"} {
    lappend extraTags "Variant \"Chess960\""
  }
  if {[string is true -strict $setup] && $startFen ne ""} {
    lappend extraTags "SetUp \"1\"" "FEN \"$startFen\""
  }
  sc_game tags set -white $white -black $black -event $event \
    -site $site -date $date -round "?" -result $pgnResult \
    -whiteElo $whiteElo -blackElo $blackElo \
    -eventdate $date \
    -extra $extraTags

  # For Chess960, set the starting position before adding moves
  if {[string is true -strict $setup] && $startFen ne ""} {
    catch {sc_game startBoard $startFen}
  }

  # Add moves if available
  set moves [dictGetDefault $game moves ""]
  if {$moves ne ""} {
    # Strip ICCF non-standard "ep" suffix from en passant captures
    regsub -all {ep(\s|\.|$)} $moves {\1} moves
    regsub -all {ep$} $moves {} moves
    if {[catch {sc_game import $moves}]} {
      catch {sc_move start}
      set moveTokens [::iccf::parseSanTokens $moves]
      foreach m $moveTokens {
        catch {sc_move addSan $m}
      }
    }
  }

  # Save as new game
  set curDb [sc_base current]
  if {[catch {sc_game save 0 $curDb}]} {
    return -1
  }

  set newNum [sc_base numGames $curDb]
  return $newNum
}

#
# ::iccf::needsMoveUpdate - Check if the database game needs new moves
#   Compares DB moves with ICCF moves
#
proc ::iccf::needsMoveUpdate {game dbGameNum} {
  set lssMoves [dictGetDefault $game moves ""]
  if {$lssMoves eq ""} { return 0 }

  if {[catch {sc_game load $dbGameNum}]} { return 0 }

  catch {sc_move end}
  set dbMovesStr [sc_game moves nomoves]
  set dbMoveTokens [::iccf::parseSanTokens $dbMovesStr]
  set dbMoveCount [llength $dbMoveTokens]

  set lssMoveTokens [::iccf::parseSanTokens $lssMoves]
  set lssMoveCount [llength $lssMoveTokens]

  if {$lssMoveCount > $dbMoveCount} {
    return 1
  }

  return 0
}

#
# ::iccf::updateGameMoves - Add new moves from ICCF to the database game
#
proc ::iccf::updateGameMoves {game dbGameNum} {
  set lssMoves [dictGetDefault $game moves ""]
  if {$lssMoves eq ""} { return }

  if {[catch {sc_game load $dbGameNum}]} { return }

  catch {sc_move end}
  set dbMovesStr [sc_game moves nomoves]
  set dbMoveTokens [::iccf::parseSanTokens $dbMovesStr]
  set dbMoveCount [llength $dbMoveTokens]

  set lssMoveTokens [::iccf::parseSanTokens $lssMoves]
  set lssMoveCount [llength $lssMoveTokens]

  if {$dbMoveCount >= $lssMoveCount} { return }

  # Verify DB moves are a prefix of server moves
  for {set i 0} {$i < $dbMoveCount} {incr i} {
    set dbM [regsub {[\+#]} [lindex $dbMoveTokens $i] ""]
    set lsM [regsub {[\+#]} [lindex $lssMoveTokens $i] ""]
    if {[::iccf::normalizeMove $dbM] ne [::iccf::normalizeMove $lsM]} { return }
  }

  set newMoves [lrange $lssMoveTokens $dbMoveCount end]
  catch {sc_move end}

  foreach m $newMoves {
    if {[catch {sc_move addSan $m}]} { return }
  }

  set curDb [sc_base current]
  catch {sc_game save $dbGameNum $curDb}
}

#
# ::iccf::parseSanTokens - Parse a SAN move string into individual move tokens
#
proc ::iccf::parseSanTokens {sanString} {
  if {$sanString eq ""} { return {} }

  # Remove result marker
  regsub {\s*(1-0|0-1|1/2-1/2|\*)\s*$} $sanString "" sanString

  # Remove move numbers and periods
  set cleaned [regsub -all {\d+\.+} $sanString " "]

  set tokens {}
  foreach token [split [string trim $cleaned]] {
    if {$token ne "" && $token ne "..."} {
      # Strip ICCF non-standard "ep" suffix from en passant captures
      set token [regsub {ep$} $token ""]
      lappend tokens $token
    }
  }
  return $tokens
}

#
# ::iccf::dictGetDefault - Get value from dict with default
#
proc ::iccf::dictGetDefault {d key default} {
  if {[dict exists $d $key]} {
    return [dict get $d $key]
  }
  return $default
}

#
# ::iccf::makeExtraTag - Format a game dict field as an extra PGN tag
#   Returns 'TagName "value"' or "" if the field is absent/zero
#
proc ::iccf::makeExtraTag {game key tagName} {
  set val [dictGetDefault $game $key ""]
  if {$val eq "" || $val eq 0} { return "" }
  return "$tagName \"$val\""
}

#
# ::iccf::normalizeMove - Strip disambiguation from SAN for comparison
#
proc ::iccf::normalizeMove {move} {
  # Keep SAN disambiguation intact; different disambiguations can represent different legal moves.
  return $move
}

#
# ::iccf::toInt - Convert value to integer, defaulting to 0
#
proc ::iccf::toInt {val} {
  if {[string is integer -strict $val]} { return [expr {$val}] }
  return 0
}

#
# ::iccf::gameStarted - Return 1 if the game has any moves, 0 if not started
#
proc ::iccf::gameStarted {game} {
  set moves [dictGetDefault $game moves ""]
  if {$moves eq ""} { return 0 }
  if {[llength [::iccf::parseSanTokens $moves]] == 0} { return 0 }
  return 1
}

#
# ::iccf::rowTags - Return treeview tags flagging low reflection time
#   timeUrgent: less than 2 days remaining, timeLow: less than 10 days
#
proc ::iccf::rowTags {id} {
  if {![info exists ::iccf::gameData($id)]} { return {} }
  set game $::iccf::gameData($id)
  if {![::iccf::gameStarted $game]} { return {} }
  set mins [expr {[::iccf::toInt [dictGetDefault $game daysPlayer 0]] * 1440 \
                + [::iccf::toInt [dictGetDefault $game hoursPlayer 0]] * 60 \
                + [::iccf::toInt [dictGetDefault $game minutesPlayer 0]]}]
  if {$mins < [expr {2 * 1440}]} { return timeUrgent }
  if {$mins < [expr {10 * 1440}]} { return timeLow }
  return {}
}

#
# ::iccf::setSort - Set the sort column/direction for a treeview and update
#   the heading indicators (arrows)
#
proc ::iccf::setSort {tree col dir} {
  set ::iccf::sortCol($tree) $col
  set ::iccf::sortDir($tree) $dir
  foreach c [$tree cget -columns] {
    set text [regsub { (\u25B2|\u25BC)$} [$tree heading $c -text] ""]
    if {$c eq $col} {
      append text [expr {$dir ? " \u25B2" : " \u25BC"}]
    }
    $tree heading $c -text $text
  }
}

#
# ::iccf::onSortClick - Sort a gamelist treeview when a column heading is clicked
#   Clicking the current sort column toggles the direction; a new column sorts ascending
#
proc ::iccf::onSortClick {tree col} {
  set dir 1
  if {[info exists ::iccf::sortCol($tree)] && $::iccf::sortCol($tree) eq $col} {
    set dir [expr {!$::iccf::sortDir($tree)}]
  }
  ::iccf::setSort $tree $col $dir
  ::iccf::populateGameList
}

#
# ::iccf::sortRows - Sort {id rowVals} pairs according to the treeview sort state
#   Game id and clock columns are compared numerically (total minutes), all
#   other columns alphabetically (case-insensitive)
#
proc ::iccf::sortRows {tree rows} {
  if {![info exists ::iccf::sortCol($tree)]} { set ::iccf::sortCol($tree) ICCFYourTime }
  if {![info exists ::iccf::sortDir($tree)]} { set ::iccf::sortDir($tree) 1 }
  set col $::iccf::sortCol($tree)
  set dir $::iccf::sortDir($tree)
  set colIdx [lsearch -exact [$tree cget -columns] $col]

  set numeric 0
  set data {}
  foreach r $rows {
    lassign $r id vals
    switch -- $col {
      ICCFGameID {
        set numeric 1
        set key [expr {[string is integer -strict $id] ? $id : 0}]
      }
      ICCFYourTime - ICCFOppTime {
        set numeric 1
        set game $::iccf::gameData($id)
        if {$col eq "ICCFYourTime"} {
          set d [::iccf::toInt [dictGetDefault $game daysPlayer 0]]
          set h [::iccf::toInt [dictGetDefault $game hoursPlayer 0]]
          set m [::iccf::toInt [dictGetDefault $game minutesPlayer 0]]
        } else {
          set d [::iccf::toInt [dictGetDefault $game daysOpponent 0]]
          set h [::iccf::toInt [dictGetDefault $game hoursOpponent 0]]
          set m [::iccf::toInt [dictGetDefault $game minutesOpponent 0]]
        }
        set key [expr {$d * 1440 + $h * 60 + $m}]
      }
      default {
        set key [string tolower [lindex $vals $colIdx]]
      }
    }
    lappend data [list $key $r]
  }

  if {$numeric} {
    set data [lsort -index 0 -integer [expr {$dir ? "-increasing" : "-decreasing"}] $data]
  } else {
    set data [lsort -index 0 -dictionary [expr {$dir ? "-increasing" : "-decreasing"}] $data]
  }

  set sorted {}
  foreach e $data { lappend sorted [lindex $e 1] }
  return $sorted
}

#
# ::iccf::populateGameList - Fill both treeviews
#
proc ::iccf::populateGameList {} {
  set saved [sc_game number]
  set ply [sc_pos pgnOffset]

  # Get moves string for active game if loaded
  set activeMovesStr ""
  if {$saved > 0} {
    catch {
      sc_move end
      set activeMovesStr [sc_game moves nomoves]
      sc_move ply $ply
    }
  }

  # Preserve selections across rebuild (FocusIn triggers this while user is typing)
  set sel1 [lindex [$::iccf::treeview selection] 0]
  set sel2 [lindex [$::iccf::treeviewWaiting selection] 0]

  # Your Turn tab
  set t1 $::iccf::treeview
  set children [$t1 children {}]
  foreach child $children { $t1 delete $child }
  set rows {}
  foreach id $::iccf::yourTurnGames {
    lappend rows [list $id [::iccf::buildGameRow $id 1 $activeMovesStr]]
  }
  foreach r [::iccf::sortRows $t1 $rows] {
    lassign $r id rowVals
    $t1 insert {} end -id "iccf_${id}" -values $rowVals -tags [::iccf::rowTags $id]
  }

  # Waiting tab
  set t2 $::iccf::treeviewWaiting
  set children [$t2 children {}]
  foreach child $children { $t2 delete $child }
  set rows {}
  foreach id $::iccf::waitingGames {
    lappend rows [list $id [::iccf::buildGameRow $id 0 $activeMovesStr]]
  }
  foreach r [::iccf::sortRows $t2 $rows] {
    lassign $r id rowVals
    $t2 insert {} end -id "iccf_${id}" -values $rowVals -tags [::iccf::rowTags $id]
  }

  if {$saved > 0} {
    catch {sc_game load $saved}
    catch {::move::PGNOffset $ply}
  }

  # Restore selections
  if {$sel1 ne "" && [$::iccf::treeview exists $sel1]} {
    $::iccf::treeview selection set $sel1
  }
  if {$sel2 ne "" && [$::iccf::treeviewWaiting exists $sel2]} {
    $::iccf::treeviewWaiting selection set $sel2
  }
}

#
# ::iccf::buildGameRow

#
# ::iccf::buildGameRow - Build treeview row values for a game
#
proc ::iccf::buildGameRow {id extended {activeMovesStr ""}} {
  if {![info exists ::iccf::gameData($id)]} { return {} }
  set game $::iccf::gameData($id)
  set white [dictGetDefault $game white "?"]
  set black [dictGetDefault $game black "?"]
  set event [dictGetDefault $game event ""]

  set hasWhite [dictGetDefault $game hasWhite ""]
  set yourColor ""
  if {$hasWhite ne ""} {
    if {[string is true -strict $hasWhite]} { set yourColor white } else { set yourColor black }
  }
  set opponent "?"
  if {$yourColor eq "white"} { set opponent $black } elseif {$yourColor eq "black"} { set opponent $white } else { set opponent "$white / $black" }

  set daysP [::iccf::toInt [dictGetDefault $game daysPlayer 0]]
  set hoursP [::iccf::toInt [dictGetDefault $game hoursPlayer 0]]
  set minsP [::iccf::toInt [dictGetDefault $game minutesPlayer 0]]
  set daysO [::iccf::toInt [dictGetDefault $game daysOpponent 0]]
  set hoursO [::iccf::toInt [dictGetDefault $game hoursOpponent 0]]
  set minsO [::iccf::toInt [dictGetDefault $game minutesOpponent 0]]
  set yourTime [format "%dd %dh %dm" $daysP $hoursP $minsP]
  set oppTime [format "%dd %dh %dm" $daysO $hoursO $minsO]

  set moves [dictGetDefault $game moves ""]
  set lastMove "?"
  if {$moves ne ""} {
    set tokens [::iccf::parseSanTokens $moves]
    set n [llength $tokens]
    if {$n > 0} {
      set idx [expr {$n - 1}]
      set moveNum [expr {$idx / 2 + 1}]
      set lastToken [lindex $tokens $idx]
      if {$idx % 2 == 0} { set lastMove "$moveNum. $lastToken" } else { set lastMove "$moveNum...$lastToken" }
    }
  }

  if {$extended} {
    # Compute "Your Move" - first new SAN move not yet on the server
    set yourMove ""
    if {[info exists ::iccf::gameToDbMap($id)]} {
      set dbGameNum $::iccf::gameToDbMap($id)
      set dbMovesStr ""
      if {$activeMovesStr ne "" && $dbGameNum == [sc_game number]} {
        set dbMovesStr $activeMovesStr
      } else {
        if {![catch {sc_game load $dbGameNum}]} {
          catch {sc_move end}
          set dbMovesStr [sc_game moves nomoves]
        }
      }
      if {$dbMovesStr ne ""} {
        set dbMoves [llength [::iccf::parseSanTokens $dbMovesStr]]
        set lssMoves [llength [::iccf::parseSanTokens $moves]]
        if {$dbMoves > $lssMoves} {
          set newTokens [::iccf::parseSanTokens $dbMovesStr]
          set firstNew [lindex $newTokens $lssMoves]
          set moveIdx [expr {$lssMoves + 1}]
          set fullMoveNum [expr {($moveIdx + 1) / 2}]
          if {$lssMoves % 2 == 0} {
            set yourMove "$fullMoveNum. $firstNew"
          } else {
            set yourMove "$fullMoveNum...$firstNew"
          }
        }
      }
    }
    set drawOffered [dictGetDefault $game drawOffered "false"]
    return [list $id $opponent $event $yourTime $oppTime $lastMove \
      [expr {[string is true -strict $drawOffered] ? "\u2713" : ""}] \
      $yourMove \
      [expr {[info exists ::iccf::acceptDraws($id)] ? "A" : [info exists ::iccf::drawOffers($id)] ? "\u2713" : ""}] \
      [expr {[info exists ::iccf::resigns($id)] ? "\u2713" : ""}] \
      [expr {[info exists ::iccf::sentGames($id)] ? "\u2713" : ""}]]
  } else {
    return [list $id $opponent $event $yourTime $oppTime $lastMove]
  }
}

#
# ::iccf::onGameSelect - Handle game selection in treeview
#   Update opponent message display
#
proc ::iccf::onGameSelect {w} {
  set sel [$w selection]

  # Save pending message for previously selected game
  if {$::iccf::selectedGame > 0} {
    set msg [$::iccf::yourMsgWidget get 1.0 end-1c]
    if {[string trim $msg] ne ""} {
      set ::iccf::pendingMessages($::iccf::selectedGame) $msg
    } else {
      catch {unset ::iccf::pendingMessages($::iccf::selectedGame)}
    }
  }

  if {[llength $sel] == 0} {
    $::iccf::yourMsgWidget delete 1.0 end
    set ::iccf::selectedGame -1
    return
  }

  set itemId [lindex $sel 0]
  if {![regexp {^iccf_(.+)$} $itemId -> id]} { return }

  set ::iccf::selectedGame $id

  # Restore any pending message for this game
  $::iccf::yourMsgWidget delete 1.0 end
  if {[info exists ::iccf::pendingMessages($id)]} {
    $::iccf::yourMsgWidget insert end $::iccf::pendingMessages($id)
  }
}

#
# ::iccf::loadSelectedGame - Load a game from the treeview into the main board
#
proc ::iccf::loadSelectedGame {w x y} {
  if {[$w identify region $x $y] eq "heading"} { return }
  set sel [$w selection]
  if {[llength $sel] == 0} { return }
  set itemId [lindex $sel 0]
  if {![regexp {^iccf_(.+)$} $itemId -> id]} { return }
  if {[info exists ::iccf::gameToDbMap($id)]} {
    set dbGameNum $::iccf::gameToDbMap($id)
    if {$::iccf::savedGameNum == 0 && [sc_base inUse]} { set ::iccf::savedGameNum [sc_game number] }
    ::game::Load $dbGameNum
    catch {sc_move end}
    ::move::PGNOffset [sc_move pgn]
  }
}

#
# ::iccf::onDrawClick - Toggle draw offer for a game when clicking the Offer Draw column
#
proc ::iccf::onDrawClick {w x y} {
  if {[$w identify region $x $y] ni {cell tree}} { return }
  set colIdx [$w identify column $x $y]
  set cols {ICCFGameID ICCFOpponent ICCFEvent ICCFYourTime ICCFOppTime ICCFLastMove ICCFDrawOffered ICCFYourMove ICCFOfferDraw ICCFResign ICCFSent}
  set idx [string range $colIdx 1 end]
  if {![string is integer -strict $idx] || $idx < 1 || $idx > [llength $cols]} { return }
  set col [lindex $cols [expr {$idx - 1}]]

  if {$col ni {ICCFOfferDraw ICCFResign}} { return }
  set itemId [$w identify item $x $y]
  if {$itemId eq ""} { return }
  if {![regexp {^iccf_(.+)$} $itemId -> id]} { return }

  if {$col eq "ICCFOfferDraw"} {
    if {[info exists ::iccf::drawOffers($id)]} {
      unset ::iccf::drawOffers($id)
      catch {unset ::iccf::acceptDraws($id)}
    } else {
      # If opponent already offered a draw, this means "accept draw"
      if {[info exists ::iccf::gameData($id)]} {
        set game $::iccf::gameData($id)
        set oppOffered [dictGetDefault $game drawOffered "false"]
      } else {
        set oppOffered "false"
      }
      if {[string is true -strict $oppOffered]} {
        set ::iccf::acceptDraws($id) 1
      } else {
        set ::iccf::drawOffers($id) 1
      }
      catch {unset ::iccf::resigns($id)}
    }
  }

  if {$col eq "ICCFResign"} {
    if {[info exists ::iccf::resigns($id)]} {
      unset ::iccf::resigns($id)
    } else {
      set ::iccf::resigns($id) 1
      catch {unset ::iccf::drawOffers($id)}
    }
  }

  ::iccf::populateGameList
}

#
# ::iccf::sendMoves - Scan for new moves and send them to ICCF
#   Goes through "Your turn" games, finds moves in DB not yet sent,
#   sends them via MakeAMove SOAP call with user messages
#
proc ::iccf::sendMoves {} {
  if {![sc_base inUse]} {
    tk_messageBox -message $::tr(ICCFNoDatabase) -icon warning -parent .iccf
    return
  }

  if {[llength $::iccf::games] == 0} {
    tk_messageBox -message [::tr ICCFNeedUpdate] -icon info -parent .iccf
    return
  }

  set successful 0
  set failed 0
  set ::iccf::statusText $::tr(ICCFSendingMoves)
  update idletasks

  set savedGame [sc_game number]

  # Save message for currently selected game if any
  if {$::iccf::selectedGame > 0} {
    set currentMsg [$::iccf::yourMsgWidget get 1.0 end-1c]
    if {[string trim $currentMsg] ne ""} {
      set ::iccf::pendingMessages($::iccf::selectedGame) $currentMsg
    } else {
      catch {unset ::iccf::pendingMessages($::iccf::selectedGame)}
    }
    $::iccf::yourMsgWidget delete 1.0 end
  }

  foreach id $::iccf::yourTurnGames {
    if {![info exists ::iccf::gameData($id)]} { continue }
    set game $::iccf::gameData($id)

    # Never try to send moves for games that have not started yet
    if {![::iccf::gameStarted $game]} { continue }

    if {![info exists ::iccf::gameToDbMap($id)]} { continue }
    set dbGameNum $::iccf::gameToDbMap($id)
    if {$dbGameNum <= 0} { continue }

    if {[catch {sc_game load $dbGameNum}]} { continue }

    catch {sc_move end}
    set dbMovesStr [sc_game moves nomoves]
    set dbMoveTokens [::iccf::parseSanTokens $dbMovesStr]
    set dbMoveCount [llength $dbMoveTokens]

    set lssMoves [dictGetDefault $game moves ""]
    set lssMoveTokens [::iccf::parseSanTokens $lssMoves]
    set lssMoveCount [llength $lssMoveTokens]

    if {$dbMoveCount <= $lssMoveCount && ![info exists ::iccf::resigns($id)] && ![info exists ::iccf::drawOffers($id)] && ![info exists ::iccf::acceptDraws($id)] && ![info exists ::iccf::pendingMessages($id)]} { continue }

    # Verify DB moves are a prefix of server moves (only if we have moves to compare)
    if {$dbMoveCount >= $lssMoveCount} {
      set prefixOk 1
      for {set i 0} {$i < $lssMoveCount} {incr i} {
        set dbM [regsub {[\+#]} [lindex $dbMoveTokens $i] ""]
        set lsM [regsub {[\+#]} [lindex $lssMoveTokens $i] ""]
        if {[::iccf::normalizeMove $dbM] ne [::iccf::normalizeMove $lsM]} {
          set prefixOk 0
          break
        }
      }
      if {!$prefixOk} { continue }
    }

    set newMoves [lrange $dbMoveTokens $lssMoveCount end]
    set hasNewMoves [expr {[llength $newMoves] > 0}]

    # Read per-game message and flags
    if {[info exists ::iccf::pendingMessages($id)]} {
      set msg $::iccf::pendingMessages($id)
    } else {
      set msg ""
    }

    set offerDraw [expr {[info exists ::iccf::drawOffers($id)] ? "true" : "false"}]
    set resign [expr {[info exists ::iccf::resigns($id)] ? "true" : "false"}]
    set acceptDraw [expr {[info exists ::iccf::acceptDraws($id)] ? "true" : "false"}]

    # Send the first unsent move, or an empty move for resign/draw/message-only
    if {$hasNewMoves} {
      set move [lindex $newMoves 0]
      set moveCount [expr {$lssMoveCount + 1}]
    } else {
      set move ""
      set moveCount $lssMoveCount
    }
    set fullMoveNum [expr {($moveCount + 1) / 2}]
    set result [::iccf::sendMoveSoap $id $fullMoveNum $move $msg $offerDraw $resign $acceptDraw]
    if {$result eq "Success"} {
      incr successful
      set ::iccf::sentGames($id) 1
      catch {unset ::iccf::pendingMessages($id)}
      catch {unset ::iccf::drawOffers($id)}
      catch {unset ::iccf::resigns($id)}
      catch {unset ::iccf::acceptDraws($id)}
    } else {
      incr failed
    }
  }

  # Restore the saved game
  if {[catch {sc_game load $savedGame}]} {}

  set msg [format $::tr(ICCFMovesSent) $successful $failed]
  set ::iccf::statusText $msg
  ::iccf::populateGameList
}

#
# ::iccf::sendMoveSoap - Send a single move via MakeAMove SOAP call
#
proc ::iccf::sendMoveSoap {gameId moveCount move message offerDraw resign acceptDraw} {
  set soapBody "
        <ns:MakeAMove>
            <ns:username>[::iccf::escapeXml $::iccf::username]</ns:username>
            <ns:password>[::iccf::escapeXml $::iccf::password]</ns:password>
            <ns:gameId>$gameId</ns:gameId>
            <ns:resign>$resign</ns:resign>
            <ns:acceptDraw>$acceptDraw</ns:acceptDraw>
            <ns:movecount>$moveCount</ns:movecount>
            <ns:myMove>[::iccf::escapeXml $move]</ns:myMove>
            <ns:offerDraw>$offerDraw</ns:offerDraw>
            <ns:claimDraw>false</ns:claimDraw>
            <ns:myMessage>[::iccf::escapeXml $message]</ns:myMessage>
        </ns:MakeAMove>"

  set response [::iccf::soapRequest "MakeAMove" $soapBody]

  if {$response eq ""} {
    return "ConnectionFailed"
  }

  if {[regexp {<[^>]*:?MakeAMoveResult>(.*?)</[^>]*:?MakeAMoveResult>} $response -> result]} {
    return $result
  }

  return ""
}

#
# ::iccf::closeWindow - Close the ICCF window and clean up
#
proc ::iccf::closeWindow {} {
  set ::iccf::playing 0
  if {[winfo exists .iccf]} {
    destroy .iccf
  }
  if {[info exists ::iccf::savedGameNum] && $::iccf::savedGameNum > 0 && [sc_base inUse]} {
    catch {sc_game load $::iccf::savedGameNum}
    ::notify::GameChanged
  }
}

# End of ::iccf namespace
