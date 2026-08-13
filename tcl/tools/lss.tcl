#
# tcl/tools/lss.tcl
# Play on Lechenicher SchachServer (LSS) feature for scidCommunity
# Uses xfcc/SOAP protocol to interact with the LSS chess server
#

namespace eval lss {

# LSS state variables (credentials loaded from options.dat, others initialized here)
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
variable oppMsgWidget ""
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
if {![info exists ::lss::server] || $::lss::server eq ""} {
  set ::lss::server "https://www.chess-server.net/de/api/server/xfcc/soap"
}

#
# ::lss::config - Entry point from Play menu
# Checks for stored credentials, shows login dialog if needed
#
proc ::lss::config {} {
  if {[winfo exists .lss]} {
    raise .lss
    return
  }
  if {[winfo exists .lssConfig]} {
    raise .lssConfig
    return
  }

  set ::lss::savedGameNum 0
  set ::lss::games {}
  set ::lss::yourTurnGames {}
  set ::lss::waitingGames {}
  catch {array unset ::lss::gameData}
  catch {array unset ::lss::gameToDbMap}
  catch {array unset ::lss::sentGames}
  catch {array unset ::lss::pendingMessages}
  catch {array unset ::lss::drawOffers}
  catch {array unset ::lss::resigns}
  catch {array unset ::lss::acceptDraws}

  if {$::lss::username ne "" && $::lss::password ne ""} {
    ::lss::connect
  } else {
    ::lss::loginDialog
  }
}

#
# ::lss::loginDialog - Show dialog for LSS username/password
#
proc ::lss::loginDialog {} {
  set w .lssConfig
  ::win::createDialog $w
  wm title $w $::tr(LSSTitle)

  ttk::frame $w.f -padding 10

  ttk::label $w.f.llogin -text "$::tr(LSSLogin):"
  ttk::entry $w.f.elogin -textvariable ::lss::username -width 30

  ttk::label $w.f.lpass -text "$::tr(LSSPassword):"
  ttk::entry $w.f.epass -textvariable ::lss::password -width 30 -show "*"

  ttk::frame $w.f.buttons
  ttk::button $w.f.buttons.connect -text $::tr(LSSConnect) -command {
    if {$::lss::username eq "" || $::lss::password eq ""} {
      tk_messageBox -message $::tr(LSSCredentialsNeeded) -icon warning -parent .lssConfig
      return
    }
    options.write
    destroy .lssConfig
    ::lss::connect
  }
  ttk::button $w.f.buttons.cancel -text $::tr(Cancel) -command { destroy .lssConfig }

  grid $w.f.llogin -row 0 -column 0 -sticky e -padx 5 -pady 3
  grid $w.f.elogin -row 0 -column 1 -sticky we -padx 5 -pady 3
  grid $w.f.lpass  -row 1 -column 0 -sticky e -padx 5 -pady 3
  grid $w.f.epass  -row 1 -column 1 -sticky we -padx 5 -pady 3

  grid $w.f.buttons.connect -row 0 -column 0 -padx 5 -pady 10
  grid $w.f.buttons.cancel  -row 0 -column 1 -padx 5 -pady 10

  grid $w.f.buttons -row 2 -column 0 -columnspan 2 -pady 10

  ttk::label $w.f.website -text "Website: https://www.chess-server.net" \
    -foreground blue -cursor hand2 -font font_Small
  bind $w.f.website <ButtonRelease-1> {openURL "https://www.chess-server.net"}
  grid $w.f.website -row 3 -column 0 -columnspan 2

  pack $w.f -fill both -expand yes

  bind $w <Escape> "destroy $w"
  bind $w <Return> "$w.f.buttons.connect invoke"
  focus $w.f.elogin
}

#
# ::lss::escapeXml - Escape special characters for XML
#
proc ::lss::escapeXml {text} {
  set text [string map {& &amp; < &lt; > &gt; \" &quot; \' &apos;} $text]
  return $text
}

#
# ::lss::unescapeXml - Unescape XML special characters
#
proc ::lss::unescapeXml {text} {
  set text [string map {&amp; & &lt; < &gt; > &quot; \" &apos; \' &#39; \' &#13; \n} $text]
  return $text
}

#
# ::lss::soapRequest - Make a SOAP HTTP request
# Returns the response body text, or empty on error
#
proc ::lss::soapRequest {action soapBody {timeout 30000}} {
  set soapEnvelope "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"$::lss::soapNS\">
    <soap:Header/>
    <soap:Body>
        $soapBody
    </soap:Body>
</soap:Envelope>"

  set soapAction "$::lss::soapNS/$action"
  set timeoutSec [expr {$timeout / 1000}]

  if {[catch {
    exec curl -s -S -m $timeoutSec \
      -H "Content-Type: text/xml; charset=utf-8" \
      -H "SOAPAction: $soapAction" \
      -H "User-Agent: scidCommunity-LSS/1.0" \
      -d @- << $soapEnvelope \
      $::lss::server
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
# ::lss::fetchGames - Call GetMyGames SOAP and parse response
# Returns a list of dicts, each representing one game
#
proc ::lss::fetchGames {} {
  set soapBody "
        <ns:GetMyGames>
            <ns:username>[::lss::escapeXml $::lss::username]</ns:username>
            <ns:password>[::lss::escapeXml $::lss::password]</ns:password>
        </ns:GetMyGames>"

  set response [::lss::soapRequest "GetMyGames" $soapBody]
  if {$response eq ""} {
    return -code error [::tr LSSConnectionFailed]
  }

  if {[regexp {AuthenticationFailed|InvalidUsernameOrPassword} $response]} {
    return -code error [::tr LSSAuthFailed]
  }

  return [::lss::parseGetMyGamesResponse $response]
}

#
# ::lss::parseGetMyGamesResponse - Parse the SOAP XML response from GetMyGames
# Extracts XfccGame elements into a list of dicts
#
proc ::lss::parseGetMyGamesResponse {xml} {
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
      set val [::lss::unescapeXml $value]

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
# ::lss::getTagValue - Extract a single tag value from XML text
#
proc ::lss::getTagValue {xml tag} {
  if {[regexp "<${tag}>(.*?)</${tag}>" $xml -> val]} {
    return [::lss::unescapeXml $val]
  }
  return ""
}

#
# ::lss::connect - Create the main "Play on LSS" window
#
proc ::lss::connect {} {
  if {[winfo exists .lss]} {
    raise .lss
    return
  }

  if {![sc_base inUse]} {
    tk_messageBox -message $::tr(LSSNoDatabase) -icon warning
    return
  }

  set ::lss::games {}
  set ::lss::yourTurnGames {}
  set ::lss::waitingGames {}
  set ::lss::selectedGame -1
  catch {array unset ::lss::gameData}
  catch {array unset ::lss::gameToDbMap}
  catch {array unset ::lss::sentGames}
  catch {array unset ::lss::pendingMessages}
  catch {array unset ::lss::drawOffers}
  catch {array unset ::lss::resigns}
  catch {array unset ::lss::acceptDraws}

  set w .lss
  ::createToplevel $w "" 1
  ::setTitle $w $::tr(LSSTitle)
  wm protocol $w WM_DELETE_WINDOW "::lss::closeWindow"

  ::lss::createWindow $w
}

#
# ::lss::createWindow - Build the LSS window UI
#
proc ::lss::createWindow {w} {
  bind $w <Escape> "::lss::closeWindow"
  bind $w <FocusIn> "if {\[winfo exists $w\]} { ::lss::populateGameList }"

  # Branding with logo
  set logoPath [file join $::scidImgDir LSS LSS_Logo_3-qKwWTcQ.png]
  ttk::frame $w.brandframe -style fieldbg.TFrame
  if {![catch {image create photo ::lss::logo -file $logoPath}]} {
    ttk::label $w.brandframe.lbl -image ::lss::logo -text " Lechenicher SchachServer (LSS)" \
      -compound left -font font_Bold -style fieldbg.TLabel
  } else {
    ttk::label $w.brandframe.lbl -text "Lechenicher SchachServer (LSS)" \
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
  $nb add $tab1 -text $::tr(LSSYourTurn)

  # Update Games and Send Moves buttons
  ttk::frame $tab1.top
  ttk::button $tab1.top.update -text $::tr(LSSUpdateGames) -command ::lss::updateGames
  ttk::button $tab1.top.send -text $::tr(LSSSendMoves) -command ::lss::sendMoves
  ttk::label $tab1.top.status -textvariable ::lss::statusText -width 50
  pack $tab1.top.update -side left -padx 5 -pady 5
  pack $tab1.top.status -side left -padx 5 -pady 5
  pack $tab1.top.send -side right -padx 5 -pady 5

  # Your Turn game list treeview
  set f1 $tab1.glist
  ttk::frame $f1
  set t1 $f1.tree
  set cols {LSSGameID LSSOpponent LSSEvent LSSYourTime LSSOppTime LSSLastMove LSSDrawOffered LSSYourMove LSSOfferDraw LSSResign LSSSent}
  ttk::treeview $t1 -columns $cols -show headings -selectmode browse
  foreach {col text} {LSSGameID LSSGameID LSSOpponent LSSOpponent LSSEvent LSSEvent
    LSSYourTime LSSMyTime LSSOppTime LSSOppTime LSSLastMove LSSLastMove
    LSSDrawOffered LSSDrawOffered LSSYourMove LSSYourMove LSSOfferDraw LSSOfferDraw LSSResign LSSResign LSSSent LSSSent} {
    $t1 heading $col -text $::tr($text) -command [list ::lss::onSortClick $t1 $col]
  }
  set arrowWidth [font measure font_Regular " \u25B2"]
  set extraWidth {LSSGameID 5 LSSOpponent 30 LSSEvent 35 LSSYourTime 15 LSSOppTime 15}
  foreach col $cols {
    set text [$t1 heading $col -text]
    set extra [expr {[dict exists $extraWidth $col] ? [dict get $extraWidth $col] : 0}]
    $t1 column $col -width [expr {[font measure font_Regular $text] + 14 + $arrowWidth + $extra}] -stretch no
  }
  # Center move text and status columns
  $t1 column LSSLastMove -width [expr {[$t1 column LSSLastMove -width] + 10}] -anchor center
  $t1 column LSSYourMove -anchor center
  $t1 column LSSDrawOffered -anchor center
  $t1 column LSSOfferDraw -anchor center
  $t1 column LSSResign -anchor center
  $t1 column LSSSent -anchor center
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
  bind $t1 <Double-ButtonRelease-1> "::lss::loadSelectedGame %W %x %y"
  bind $t1 <<TreeviewSelect>> "::lss::onGameSelect %W"
  bind $t1 <ButtonRelease-1> "::lss::onDrawClick %W %x %y"

  pack $tab1.top -fill x
  pack $f1 -fill both -expand yes -padx 5 -pady {5 0}

  # Message area for Your Turn tab
  ttk::frame $tab1.messages
  ttk::frame $tab1.messages.opp
  ttk::label $tab1.messages.opp.lbl -text "$::tr(LSSOpponentMessage):"
  text $tab1.messages.opp.txt -width 35 -height 4 -wrap word -state disabled
  ttk::scrollbar $tab1.messages.opp.sb -orient vertical -command "$tab1.messages.opp.txt yview"
  $tab1.messages.opp.txt configure -yscrollcommand "$tab1.messages.opp.sb set"
  grid $tab1.messages.opp.lbl -row 0 -column 0 -columnspan 2 -sticky w
  grid $tab1.messages.opp.txt -row 1 -column 0 -sticky news
  grid $tab1.messages.opp.sb  -row 1 -column 1 -sticky ns
  grid columnconfigure $tab1.messages.opp 0 -weight 1
  grid rowconfigure $tab1.messages.opp 1 -weight 1
  ttk::frame $tab1.messages.your
  ttk::label $tab1.messages.your.lbl -text "$::tr(LSSYourMessage):"
  text $tab1.messages.your.txt -width 35 -height 4 -wrap word
  grid $tab1.messages.your.lbl  -row 0 -column 0 -sticky w
  grid $tab1.messages.your.txt  -row 1 -column 0 -sticky news
  grid rowconfigure $tab1.messages.your 1 -weight 1
  grid columnconfigure $tab1.messages.your 0 -weight 1
  grid $tab1.messages.opp $tab1.messages.your -padx 5 -pady 5 -sticky news
  grid columnconfigure $tab1.messages 0 -weight 1
  grid columnconfigure $tab1.messages 1 -weight 1
  grid rowconfigure $tab1.messages 0 -weight 1
  pack $tab1.messages -fill both -expand yes -padx 5 -pady 5

  # Tab 2: Waiting
  set tab2 $nb.waiting
  ttk::frame $tab2
  $nb add $tab2 -text $::tr(LSSWaiting)
  ttk::frame $tab2.glist
  set t2 $tab2.glist.tree
  set cols2 {LSSGameID LSSOpponent LSSEvent LSSYourTime LSSOppTime LSSLastMove}
  ttk::treeview $t2 -columns $cols2 -show headings -selectmode browse
  foreach {col text} {LSSGameID LSSGameID LSSOpponent LSSOpponent LSSEvent LSSEvent
    LSSYourTime LSSMyTime LSSOppTime LSSOppTime LSSLastMove LSSLastMove} {
    $t2 heading $col -text $::tr($text) -command [list ::lss::onSortClick $t2 $col]
  }
  foreach col $cols2 {
    set text [$t2 heading $col -text]
    set extra [expr {[dict exists $extraWidth $col] ? [dict get $extraWidth $col] : 0}]
    $t2 column $col -width [expr {[font measure font_Regular $text] + 14 + $arrowWidth + $extra}] -stretch no
  }
  $t2 column LSSLastMove -width [expr {[$t2 column LSSLastMove -width] + 20}] -stretch yes -anchor center
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
  bind $t2 <Double-ButtonRelease-1> "::lss::loadSelectedGame %W %x %y"
  pack $tab2.glist -fill both -expand yes -padx 5 -pady 5

  # Store widget references
  set ::lss::treeview $t1
  set ::lss::treeviewWaiting $t2
  set ::lss::oppMsgWidget $tab1.messages.opp.txt
  set ::lss::yourMsgWidget $tab1.messages.your.txt

  # Default sort: My Clock ascending (least time first)
  ::lss::setSort $t1 LSSYourTime 1
  ::lss::setSort $t2 LSSYourTime 1

  # Bottom buttons
  ttk::frame $w.buttons
  ttk::button $w.buttons.close -text $::tr(LSSClose) -command ::lss::closeWindow
  pack $w.buttons.close -side right -padx 5 -pady 5

  pack $nb -fill both -expand yes
  pack $w.buttons -fill x -padx 5
}

#
# ::lss::updateGames - Fetch games from LSS and update database/gamelist
#
proc ::lss::updateGames {} {
  if {![sc_base inUse]} {
    tk_messageBox -message $::tr(LSSNoDatabase) -icon warning
    return
  }

  set ::lss::statusText $::tr(LSSUpdating)
  update idletasks

  # Clear any previous "Sent" checkmarks when updating games
  catch {array unset ::lss::sentGames}

  set savedGame 0
  catch {set savedGame [sc_game number]}

  if {[catch {
    set ::lss::games [::lss::fetchGames]
  } err]} {
    set ::lss::statusText ""
    if {$savedGame > 0} { catch {sc_game load $savedGame} }
    tk_messageBox -message $err -icon error -parent .lss
    return
  }

  if {[llength $::lss::games] == 0} {
    set ::lss::statusText [::tr LSSNoGamesFound]
    return
  }

  set newCount 0
  set updatedCount 0
  set unchangedCount 0
  set yourTurnList {}
  set waitingList {}

  catch {array unset ::lss::gameData}
  catch {array unset ::lss::gameToDbMap}

  set curDb [sc_base current]

  # Single fast filter pass to find all existing LSS games
  if {[catch {sc_filter new $curDb} tmpFilter]} {
    set ::lss::statusText [::tr LSSFilterError]
    if {$savedGame > 0} { catch {sc_game load $savedGame} }
    return
  }
  catch {sc_filter reset $curDb $tmpFilter full}
  catch {sc_filter search $curDb $tmpFilter tags LSS *}
  set nExisting [expr {[catch {sc_filter count $curDb $tmpFilter} c] ? 0 : $c}]

  # Build in-memory map: LSS ID -> DB game number
  set idToGnum {}
  if {$nExisting > 0 && $nExisting < 50000} {
    foreach {idx line deleted} [sc_base gameslist $curDb 0 $nExisting $tmpFilter N+] {
      if {![regexp {^(\d+)_} $idx -> gnum]} { continue }
      if {[catch {sc_game load $gnum}]} { continue }
      set extra [sc_game tags get Extra]
      foreach eline [split $extra "\n"] {
        if {[regexp {^LSS "([^"]+)"} $eline -> tagVal]} {
          dict set idToGnum $tagVal $gnum
          break
        }
      }
    }
  }
  catch {sc_filter reset $curDb $tmpFilter empty}

  foreach game $::lss::games {
    set id [dict get $game id]
    set ::lss::gameData($id) $game

    set dbGameNum -1
    if {[dict exists $idToGnum $id]} {
      set dbGameNum [dict get $idToGnum $id]
    }

    if {$dbGameNum > 0} {
      set ::lss::gameToDbMap($id) $dbGameNum
      if {[::lss::needsMoveUpdate $game $dbGameNum]} {
        ::lss::updateGameMoves $game $dbGameNum
        incr updatedCount
      } else {
        incr unchangedCount
      }
    } else {
      set dbGameNum [::lss::addNewGame $game $id "LSS"]
      if {$dbGameNum > 0} {
        set ::lss::gameToDbMap($id) $dbGameNum
        incr newCount
      }
    }

    if {[dictGetDefault $game myTurn "false"] && [string is true -strict [dictGetDefault $game myTurn "false"]]} {
      lappend yourTurnList $id
    } else {
      lappend waitingList $id
    }
  }

  set ::lss::yourTurnGames $yourTurnList
  set ::lss::waitingGames $waitingList
  catch {sc_filter reset $curDb $tmpFilter empty}

  set msg [format $::tr(LSSGamesUpdated) $newCount $updatedCount $unchangedCount]
  set ::lss::statusText $msg

  if {$savedGame > 0} { catch {sc_game load $savedGame} }

  ::lss::populateGameList
}

#
# ::lss::parseEventDate - Try to extract a PGN date (YYYY.MM.DD) from an event name
#   Looks for patterns like "2026-Aug" or "2026-Sep" etc.
#   Returns "????.??.??" if no date found
#
proc ::lss::parseEventDate {event} {
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
# ::lss::addNewGame - Create a new game in the database from LSS data
#   Returns the new game number (1-based) or -1 on failure
#
proc ::lss::addNewGame {game lssId tagName} {
  if {[catch {sc_game new}]} { return -1 }

  set white [dictGetDefault $game white "?"]
  set black [dictGetDefault $game black "?"]
  set event [dictGetDefault $game event ""]
  set whiteElo [dictGetDefault $game whiteElo 0]
  set blackElo [dictGetDefault $game blackElo 0]
  set eventDate [dictGetDefault $game eventDate ""]
  set site [dictGetDefault $game site [dictGetDefault $game serverInfo "LSS"]]
  set result [dictGetDefault $game result "Ongoing"]
  set variant [dictGetDefault $game variant ""]
  set setup [dictGetDefault $game setup "false"]
  set startFen [dictGetDefault $game fen ""]

  # Map LSS result to PGN result
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
    set date [::lss::parseEventDate $event]
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
    set t [::lss::makeExtraTag $game $key $tag]
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
    # Strip LSS non-standard "ep" suffix from en passant captures
    regsub -all {ep(\s|\.|$)} $moves {\1} moves
    regsub -all {ep$} $moves {} moves
    if {[catch {sc_game import $moves}]} {
      catch {sc_move start}
      set moveTokens [::lss::parseSanTokens $moves]
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
# ::lss::needsMoveUpdate - Check if the database game needs new moves
#   Compares DB moves with LSS moves
#
proc ::lss::needsMoveUpdate {game dbGameNum} {
  set lssMoves [dictGetDefault $game moves ""]
  if {$lssMoves eq ""} { return 0 }

  if {[catch {sc_game load $dbGameNum}]} { return 0 }

  catch {sc_move end}
  set dbMovesStr [sc_game moves nomoves]
  set dbMoveTokens [::lss::parseSanTokens $dbMovesStr]
  set dbMoveCount [llength $dbMoveTokens]

  set lssMoveTokens [::lss::parseSanTokens $lssMoves]
  set lssMoveCount [llength $lssMoveTokens]

  if {$lssMoveCount > $dbMoveCount} {
    return 1
  }

  return 0
}

#
# ::lss::updateGameMoves - Add new moves from LSS to the database game
#
proc ::lss::updateGameMoves {game dbGameNum} {
  set lssMoves [dictGetDefault $game moves ""]
  if {$lssMoves eq ""} { return }

  if {[catch {sc_game load $dbGameNum}]} { return }

  catch {sc_move end}
  set dbMovesStr [sc_game moves nomoves]
  set dbMoveTokens [::lss::parseSanTokens $dbMovesStr]
  set dbMoveCount [llength $dbMoveTokens]

  set lssMoveTokens [::lss::parseSanTokens $lssMoves]
  set lssMoveCount [llength $lssMoveTokens]

  if {$dbMoveCount >= $lssMoveCount} { return }

  # Verify DB moves are a prefix of server moves
  for {set i 0} {$i < $dbMoveCount} {incr i} {
    set dbM [regsub {[\+#]} [lindex $dbMoveTokens $i] ""]
    set lsM [regsub {[\+#]} [lindex $lssMoveTokens $i] ""]
    if {[::lss::normalizeMove $dbM] ne [::lss::normalizeMove $lsM]} { return }
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
# ::lss::parseSanTokens - Parse a SAN move string into individual move tokens
#
proc ::lss::parseSanTokens {sanString} {
  if {$sanString eq ""} { return {} }

  # Remove result marker
  regsub {\s*(1-0|0-1|1/2-1/2|\*)\s*$} $sanString "" sanString

  # Remove move numbers and periods
  set cleaned [regsub -all {\d+\.+} $sanString " "]

  set tokens {}
  foreach token [split [string trim $cleaned]] {
    if {$token ne "" && $token ne "..."} {
      # Strip LSS non-standard "ep" suffix from en passant captures
      set token [regsub {ep$} $token ""]
      lappend tokens $token
    }
  }
  return $tokens
}

#
# ::lss::dictGetDefault - Get value from dict with default
#
proc ::lss::dictGetDefault {d key default} {
  if {[dict exists $d $key]} {
    return [dict get $d $key]
  }
  return $default
}

#
# ::lss::makeExtraTag - Format a game dict field as an extra PGN tag
#   Returns 'TagName "value"' or "" if the field is absent/zero
#
proc ::lss::makeExtraTag {game key tagName} {
  set val [dictGetDefault $game $key ""]
  if {$val eq "" || $val eq 0} { return "" }
  return "$tagName \"$val\""
}

#
# ::lss::normalizeMove - Strip disambiguation from SAN for comparison
#
proc ::lss::normalizeMove {move} {
  # Keep SAN disambiguation intact; different disambiguations can represent different legal moves.
  return $move
}

#
# ::lss::toInt - Convert value to integer, defaulting to 0
#
proc ::lss::toInt {val} {
  if {[string is integer -strict $val]} { return [expr {$val}] }
  return 0
}

#
# ::lss::rowTags - Return treeview tags flagging low reflection time
#   timeUrgent: less than 2 days remaining, timeLow: less than 10 days
#
proc ::lss::rowTags {id} {
  if {![info exists ::lss::gameData($id)]} { return {} }
  set game $::lss::gameData($id)
  set moves [dictGetDefault $game moves ""]
  if {$moves eq ""} { return {} }
  set mins [expr {[::lss::toInt [dictGetDefault $game daysPlayer 0]] * 1440 \
                + [::lss::toInt [dictGetDefault $game hoursPlayer 0]] * 60 \
                + [::lss::toInt [dictGetDefault $game minutesPlayer 0]]}]
  if {$mins < [expr {2 * 1440}]} { return timeUrgent }
  if {$mins < [expr {10 * 1440}]} { return timeLow }
  return {}
}

#
# ::lss::setSort - Set the sort column/direction for a treeview and update
#   the heading indicators (arrows)
#
proc ::lss::setSort {tree col dir} {
  set ::lss::sortCol($tree) $col
  set ::lss::sortDir($tree) $dir
  foreach c [$tree cget -columns] {
    set text [regsub { (\u25B2|\u25BC)$} [$tree heading $c -text] ""]
    if {$c eq $col} {
      append text [expr {$dir ? " \u25B2" : " \u25BC"}]
    }
    $tree heading $c -text $text
  }
}

#
# ::lss::onSortClick - Sort a gamelist treeview when a column heading is clicked
#   Clicking the current sort column toggles the direction; a new column sorts ascending
#
proc ::lss::onSortClick {tree col} {
  set dir 1
  if {[info exists ::lss::sortCol($tree)] && $::lss::sortCol($tree) eq $col} {
    set dir [expr {!$::lss::sortDir($tree)}]
  }
  ::lss::setSort $tree $col $dir
  ::lss::populateGameList
}

#
# ::lss::sortRows - Sort {id rowVals} pairs according to the treeview sort state
#   Game id and clock columns are compared numerically (total minutes), all
#   other columns alphabetically (case-insensitive)
#
proc ::lss::sortRows {tree rows} {
  if {![info exists ::lss::sortCol($tree)]} { set ::lss::sortCol($tree) LSSYourTime }
  if {![info exists ::lss::sortDir($tree)]} { set ::lss::sortDir($tree) 1 }
  set col $::lss::sortCol($tree)
  set dir $::lss::sortDir($tree)
  set colIdx [lsearch -exact [$tree cget -columns] $col]

  set numeric 0
  set data {}
  foreach r $rows {
    lassign $r id vals
    switch -- $col {
      LSSGameID {
        set numeric 1
        set key [expr {[string is integer -strict $id] ? $id : 0}]
      }
      LSSYourTime - LSSOppTime {
        set numeric 1
        set game $::lss::gameData($id)
        if {$col eq "LSSYourTime"} {
          set d [::lss::toInt [dictGetDefault $game daysPlayer 0]]
          set h [::lss::toInt [dictGetDefault $game hoursPlayer 0]]
          set m [::lss::toInt [dictGetDefault $game minutesPlayer 0]]
        } else {
          set d [::lss::toInt [dictGetDefault $game daysOpponent 0]]
          set h [::lss::toInt [dictGetDefault $game hoursOpponent 0]]
          set m [::lss::toInt [dictGetDefault $game minutesOpponent 0]]
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
# ::lss::populateGameList - Fill both treeviews
#
proc ::lss::populateGameList {} {
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
  set sel1 [lindex [$::lss::treeview selection] 0]
  set sel2 [lindex [$::lss::treeviewWaiting selection] 0]

  # Your Turn tab
  set t1 $::lss::treeview
  set children [$t1 children {}]
  foreach child $children { $t1 delete $child }
  set rows {}
  foreach id $::lss::yourTurnGames {
    lappend rows [list $id [::lss::buildGameRow $id 1 $activeMovesStr]]
  }
  foreach r [::lss::sortRows $t1 $rows] {
    lassign $r id rowVals
    $t1 insert {} end -id "lss_${id}" -values $rowVals -tags [::lss::rowTags $id]
  }

  # Waiting tab
  set t2 $::lss::treeviewWaiting
  set children [$t2 children {}]
  foreach child $children { $t2 delete $child }
  set rows {}
  foreach id $::lss::waitingGames {
    lappend rows [list $id [::lss::buildGameRow $id 0 $activeMovesStr]]
  }
  foreach r [::lss::sortRows $t2 $rows] {
    lassign $r id rowVals
    $t2 insert {} end -id "lss_${id}" -values $rowVals -tags [::lss::rowTags $id]
  }

  if {$saved > 0} {
    catch {sc_game load $saved}
    catch {::move::PGNOffset $ply}
  }

  # Restore selections
  if {$sel1 ne "" && [$::lss::treeview exists $sel1]} {
    $::lss::treeview selection set $sel1
  }
  if {$sel2 ne "" && [$::lss::treeviewWaiting exists $sel2]} {
    $::lss::treeviewWaiting selection set $sel2
  }
}

#
# ::lss::buildGameRow
#
# ::lss::buildGameRow - Build treeview row values for a game
#
proc ::lss::buildGameRow {id extended {activeMovesStr ""}} {
  if {![info exists ::lss::gameData($id)]} { return {} }
  set game $::lss::gameData($id)
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

  set daysP [::lss::toInt [dictGetDefault $game daysPlayer 0]]
  set hoursP [::lss::toInt [dictGetDefault $game hoursPlayer 0]]
  set minsP [::lss::toInt [dictGetDefault $game minutesPlayer 0]]
  set daysO [::lss::toInt [dictGetDefault $game daysOpponent 0]]
  set hoursO [::lss::toInt [dictGetDefault $game hoursOpponent 0]]
  set minsO [::lss::toInt [dictGetDefault $game minutesOpponent 0]]
  set yourTime [format "%dd %dh %dm" $daysP $hoursP $minsP]
  set oppTime [format "%dd %dh %dm" $daysO $hoursO $minsO]

  set moves [dictGetDefault $game moves ""]
  set lastMove "?"
  if {$moves ne ""} {
    set tokens [::lss::parseSanTokens $moves]
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
    if {[info exists ::lss::gameToDbMap($id)]} {
      set dbGameNum $::lss::gameToDbMap($id)
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
        set dbMoves [llength [::lss::parseSanTokens $dbMovesStr]]
        set lssMoves [llength [::lss::parseSanTokens $moves]]
        if {$dbMoves > $lssMoves} {
          set newTokens [::lss::parseSanTokens $dbMovesStr]
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
      [expr {[info exists ::lss::acceptDraws($id)] ? "A" : [info exists ::lss::drawOffers($id)] ? "\u2713" : ""}] \
      [expr {[info exists ::lss::resigns($id)] ? "\u2713" : ""}] \
      [expr {[info exists ::lss::sentGames($id)] ? "\u2713" : ""}]]
  } else {
    return [list $id $opponent $event $yourTime $oppTime $lastMove]
  }
}

#
# ::lss::onGameSelect - Handle game selection in treeview
#   Update opponent message display
#
proc ::lss::onGameSelect {w} {
  set sel [$w selection]

  # Save pending message for previously selected game
  if {$::lss::selectedGame > 0} {
    set msg [$::lss::yourMsgWidget get 1.0 end-1c]
    if {[string trim $msg] ne ""} {
      set ::lss::pendingMessages($::lss::selectedGame) $msg
    } else {
      catch {unset ::lss::pendingMessages($::lss::selectedGame)}
    }
  }

  if {[llength $sel] == 0} {
    $::lss::yourMsgWidget delete 1.0 end
    $::lss::oppMsgWidget configure -state normal
    $::lss::oppMsgWidget delete 1.0 end
    $::lss::oppMsgWidget configure -state disabled
    set ::lss::selectedGame -1
    return
  }

  set itemId [lindex $sel 0]
  if {![regexp {^lss_(.+)$} $itemId -> id]} { return }

  set ::lss::selectedGame $id

  set msg ""
  if {[info exists ::lss::gameData($id)]} {
    set game $::lss::gameData($id)
    set msg [dictGetDefault $game message ""]
  }

  $::lss::oppMsgWidget configure -state normal
  $::lss::oppMsgWidget delete 1.0 end
  if {$msg ne ""} {
    $::lss::oppMsgWidget insert end $msg
  }
  $::lss::oppMsgWidget configure -state disabled

  # Restore any pending message for this game
  $::lss::yourMsgWidget delete 1.0 end
  if {[info exists ::lss::pendingMessages($id)]} {
    $::lss::yourMsgWidget insert end $::lss::pendingMessages($id)
  }
}

#
# ::lss::loadSelectedGame - Load a game from the treeview into the main board
#
proc ::lss::loadSelectedGame {w x y} {
  if {[$w identify region $x $y] eq "heading"} { return }
  set sel [$w selection]
  if {[llength $sel] == 0} { return }
  set itemId [lindex $sel 0]
  if {![regexp {^lss_(.+)$} $itemId -> id]} { return }
  if {[info exists ::lss::gameToDbMap($id)]} {
    set dbGameNum $::lss::gameToDbMap($id)
    if {$::lss::savedGameNum == 0 && [sc_base inUse]} { set ::lss::savedGameNum [sc_game number] }
    ::game::Load $dbGameNum
    catch {sc_move end}
    ::move::PGNOffset [sc_move pgn]
  }
}

#
# ::lss::onDrawClick - Toggle draw offer for a game when clicking the Offer Draw column
#
proc ::lss::onDrawClick {w x y} {
  if {[$w identify region $x $y] eq "heading"} { return }
  set colIdx [$w identify column $x $y]
  set cols {LSSGameID LSSOpponent LSSEvent LSSYourTime LSSOppTime LSSLastMove LSSDrawOffered LSSYourMove LSSOfferDraw LSSResign LSSSent}
  set idx [string range $colIdx 1 end]
  if {![string is integer -strict $idx] || $idx < 1 || $idx > [llength $cols]} { return }
  set col [lindex $cols [expr {$idx - 1}]]

  if {$col ni {LSSOfferDraw LSSResign}} { return }
  set sel [$w selection]
  if {[llength $sel] == 0} { return }
  set itemId [lindex $sel 0]
  if {![regexp {^lss_(.+)$} $itemId -> id]} { return }

  if {$col eq "LSSOfferDraw"} {
    if {[info exists ::lss::drawOffers($id)]} {
      unset ::lss::drawOffers($id)
      catch {unset ::lss::acceptDraws($id)}
    } else {
      # If opponent already offered a draw, this means "accept draw"
      if {[info exists ::lss::gameData($id)]} {
        set game $::lss::gameData($id)
        set oppOffered [dictGetDefault $game drawOffered "false"]
      } else {
        set oppOffered "false"
      }
      if {[string is true -strict $oppOffered]} {
        set ::lss::acceptDraws($id) 1
      } else {
        set ::lss::drawOffers($id) 1
      }
      catch {unset ::lss::resigns($id)}
    }
  }

  if {$col eq "LSSResign"} {
    if {[info exists ::lss::resigns($id)]} {
      unset ::lss::resigns($id)
    } else {
      set ::lss::resigns($id) 1
      catch {unset ::lss::drawOffers($id)}
    }
  }

  ::lss::populateGameList
}

#
# ::lss::sendMoves - Scan for new moves and send them to LSS
#   Goes through "Your turn" games, finds moves in DB not yet sent,
#   sends them via MakeAMove SOAP call with user messages
#
proc ::lss::sendMoves {} {
  if {![sc_base inUse]} {
    tk_messageBox -message $::tr(LSSNoDatabase) -icon warning -parent .lss
    return
  }

  if {[llength $::lss::games] == 0} {
    tk_messageBox -message [::tr LSSNeedUpdate] -icon info -parent .lss
    return
  }

  set successful 0
  set failed 0
  set ::lss::statusText $::tr(LSSSendingMoves)
  update idletasks

  set savedGame [sc_game number]

  # Save message for currently selected game if any
  if {$::lss::selectedGame > 0} {
    set currentMsg [$::lss::yourMsgWidget get 1.0 end-1c]
    if {[string trim $currentMsg] ne ""} {
      set ::lss::pendingMessages($::lss::selectedGame) $currentMsg
    } else {
      catch {unset ::lss::pendingMessages($::lss::selectedGame)}
    }
    $::lss::yourMsgWidget delete 1.0 end
  }

  foreach id $::lss::yourTurnGames {
    if {![info exists ::lss::gameData($id)]} { continue }
    set game $::lss::gameData($id)

    if {![info exists ::lss::gameToDbMap($id)]} { continue }
    set dbGameNum $::lss::gameToDbMap($id)
    if {$dbGameNum <= 0} { continue }

    if {[catch {sc_game load $dbGameNum}]} { continue }

    catch {sc_move end}
    set dbMovesStr [sc_game moves nomoves]
    set dbMoveTokens [::lss::parseSanTokens $dbMovesStr]
    set dbMoveCount [llength $dbMoveTokens]

    set lssMoves [dictGetDefault $game moves ""]
    set lssMoveTokens [::lss::parseSanTokens $lssMoves]
    set lssMoveCount [llength $lssMoveTokens]

    if {$dbMoveCount <= $lssMoveCount && ![info exists ::lss::resigns($id)] && ![info exists ::lss::drawOffers($id)] && ![info exists ::lss::acceptDraws($id)] && ![info exists ::lss::pendingMessages($id)]} { continue }

    # Verify DB moves are a prefix of server moves (only if we have moves to compare)
    if {$dbMoveCount >= $lssMoveCount} {
      set prefixOk 1
      for {set i 0} {$i < $lssMoveCount} {incr i} {
        set dbM [regsub {[\+#]} [lindex $dbMoveTokens $i] ""]
        set lsM [regsub {[\+#]} [lindex $lssMoveTokens $i] ""]
        if {[::lss::normalizeMove $dbM] ne [::lss::normalizeMove $lsM]} {
          set prefixOk 0
          break
        }
      }
      if {!$prefixOk} { continue }
    }

    set newMoves [lrange $dbMoveTokens $lssMoveCount end]
    set hasNewMoves [expr {[llength $newMoves] > 0}]

    # Read per-game message and flags
    if {[info exists ::lss::pendingMessages($id)]} {
      set msg $::lss::pendingMessages($id)
    } else {
      set msg ""
    }

    set offerDraw [expr {[info exists ::lss::drawOffers($id)] ? "true" : "false"}]
    set resign [expr {[info exists ::lss::resigns($id)] ? "true" : "false"}]
    set acceptDraw [expr {[info exists ::lss::acceptDraws($id)] ? "true" : "false"}]

    # Send the first unsent move, or an empty move for resign/draw/message-only
    if {$hasNewMoves} {
      set move [lindex $newMoves 0]
      set moveCount [expr {$lssMoveCount + 1}]
    } else {
      set move ""
      set moveCount $lssMoveCount
    }
    set fullMoveNum [expr {($moveCount + 1) / 2}]
    set result [::lss::sendMoveSoap $id $fullMoveNum $move $msg $offerDraw $resign $acceptDraw]
    if {$result eq "Success"} {
      incr successful
      set ::lss::sentGames($id) 1
      catch {unset ::lss::pendingMessages($id)}
      catch {unset ::lss::drawOffers($id)}
      catch {unset ::lss::resigns($id)}
      catch {unset ::lss::acceptDraws($id)}
    } else {
      incr failed
    }
  }

  # Restore the saved game
  if {[catch {sc_game load $savedGame}]} {}

  set msg [format $::tr(LSSMovesSent) $successful $failed]
  set ::lss::statusText $msg
  ::lss::populateGameList
}

#
# ::lss::sendMoveSoap - Send a single move via MakeAMove SOAP call
#
proc ::lss::sendMoveSoap {gameId moveCount move message offerDraw resign acceptDraw} {
  set soapBody "
        <ns:MakeAMove>
            <ns:username>[::lss::escapeXml $::lss::username]</ns:username>
            <ns:password>[::lss::escapeXml $::lss::password]</ns:password>
            <ns:gameId>$gameId</ns:gameId>
            <ns:resign>$resign</ns:resign>
            <ns:acceptDraw>$acceptDraw</ns:acceptDraw>
            <ns:movecount>$moveCount</ns:movecount>
            <ns:myMove>[::lss::escapeXml $move]</ns:myMove>
            <ns:offerDraw>$offerDraw</ns:offerDraw>
            <ns:claimDraw>false</ns:claimDraw>
            <ns:myMessage>[::lss::escapeXml $message]</ns:myMessage>
        </ns:MakeAMove>"

  set response [::lss::soapRequest "MakeAMove" $soapBody]

  if {$response eq ""} {
    return "ConnectionFailed"
  }

  if {[regexp {<[^>]*:?MakeAMoveResult>(.*?)</[^>]*:?MakeAMoveResult>} $response -> result]} {
    return $result
  }

  return ""
}

#
# ::lss::closeWindow - Close the LSS window and clean up
#
proc ::lss::closeWindow {} {
  set ::lss::playing 0
  if {[winfo exists .lss]} {
    destroy .lss
  }
  if {[info exists ::lss::savedGameNum] && $::lss::savedGameNum > 0 && [sc_base inUse]} {
    catch {sc_game load $::lss::savedGameNum}
    ::notify::GameChanged
  }
}

# End of ::lss namespace
