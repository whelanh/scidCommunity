### lang.tcl: Support for multiple-language menus, buttons, etc.
### Part of Scid, which is Copyright 2001-2003 Shane Hudson.

array set langEncoding {}
set languages {}

if {[catch {encoding names}]} {
  set hasEncoding 0
} else {
  set hasEncoding 1
}
################################################################################
#  Translation of pieces
#  Note to adopt also tkscid.cpp to allow for a new langauge as well
#  as add transPieces to langPieces[] in game.cpp
################################################################################
array set transPieces {}

set transPieces(F)   { P P K R Q D R T B F N C }
set untransPieces(F) { P P R K D Q T R F B C N }
set transPieces(S)   { P P K R Q D R T B A N C }
set untransPieces(S) { P P R K D Q T R A B C N }
set transPieces(D)   { P B K K Q D R T B L N S }
set untransPieces(D) { B P K K D Q T R L B S N }
set transPieces(I)   { P P K R Q D R T B A N C }
set untransPieces(I) { P P R K D Q T R A B C N }
set transPieces(N)   { P p K K Q D R T B L N P }
set untransPieces(N) { p P K K D Q T R L B P N }
set transPieces(C)   { P P K K Q D R V B S N J }
set untransPieces(C) { P P K K D Q V R S B J N }
set transPieces(G)   { P P K Ρ Q Β R Π B Α N Ι }
set untransPieces(G) { P P Ρ K Β Q Π R Α B Ι N }
set transPieces(H)   { P G K K Q V R B B F N H }
set untransPieces(H) { G P K K V Q B R F B H N }
set transPieces(O)   { P B K K Q D R T B L N S }
set untransPieces(O) { B P K K D Q T R L B S N }
set transPieces(W)   { P B K K Q D R T B L N S }
set untransPieces(W) { B P K K D Q T R L B S N }
set transPieces(K)   { P P K R Q D R T B A N C }
set untransPieces(K) { P P R K D Q T R A B C N }
set transPieces(U)   { P S K K Q D R T B L N R }
set untransPieces(U) { S P K K D Q T R L B R N }
set transPieces(M)   { P 兵 K 王 Q 后 R 车 B 象 N 馬 }
set untransPieces(M) { 兵 P 王 K 后 Q 车 R 象 B 馬 N }
set transPieces(B)   { P P K R Q D R T B B N C }
set untransPieces(B) { P P R K D Q T R B B C N }
set transPieces(V)   { P ח K מ Q ם R צ B ר N פ }
set untransPieces(V) { ח P מ K ם Q צ R ר B פ N }
set transPieces(h)   { P प K र Q व R ह B ऊ N घ }
set untransPieces(h) { प P र K व Q ह R ऊ B घ N }
set transPieces(Q)   { P п K Кр Q Ф R Т B С N К }
set untransPieces(Q) { п P Кр K Ф Q Т R С B К N }
set transPieces(b)   { P প K র Q ম R ন B হ N ঘ }
set untransPieces(b) { প P র K ম Q ন R হ B ঘ N }

################################################################################
proc trans { msg } {
  if { $::language == "E" || ! $::translatePieces || $msg == "\[end\]"} {
    return $msg
  }
  if { [ catch { set t [string map $::transPieces($::language) $msg ]} ] } {
    return $msg
  }
  return $t
}
################################################################################
proc untrans { msg } {
  if { $::language == "E"  || ! $::translatePieces || $msg == "\[end\]"} {
    return $msg
  }
  if { [ catch { set t [string map $::untransPieces($::language) $msg ]} ] } {
    return $msg
  }
  return $t
}
################################################################################
#
################################################################################
proc addLanguage {letter name underline encodingSystem filename} {
  lappend ::languages $letter
  set ::langName($letter) $name
  set ::langUnderline($letter) $underline
  set ::langEncoding($letter) $encodingSystem
  set ::langSourceFile($letter) $filename
}
# Languages that use right-to-left (RTL) scripts.
# Tk 9 on Linux does not apply the Unicode BiDi algorithm to menu/label
# widgets, so Hebrew text must be converted to visual order at runtime.
set ::rtlLanguages {V}

################################################################################
# graphemeClusters:
#    Splits a string into grapheme clusters. Each cluster is a base character
#    followed by any combining marks (Hebrew niqqud/cantillation). This ensures
#    vowel marks stay attached to their correct base letter during reversal.
################################################################################
proc graphemeClusters {text} {
  set clusters {}
  set current ""
  foreach ch [split $text {}] {
    set cp [scan $ch %c]
    # Hebrew combining marks:
    #   Cantillation: U+0591-U+05AF, Niqqud: U+05B0-U+05BD,
    #   Rafe: U+05BF, Shin/Sin dots: U+05C1-U+05C2,
    #   Upper/Lower marks: U+05C4-U+05C5, Qamats Qatan: U+05C7
    set isCombining [expr {
      ($cp >= 0x0591 && $cp <= 0x05BD) ||
      $cp == 0x05BF ||
      ($cp >= 0x05C1 && $cp <= 0x05C2) ||
      ($cp >= 0x05C4 && $cp <= 0x05C5) ||
      $cp == 0x05C7
    }]
    if {$isCombining && $current ne ""} {
      append current $ch
    } else {
      if {$current ne ""} {
        lappend clusters $current
      }
      set current $ch
    }
  }
  if {$current ne ""} {
    lappend clusters $current
  }
  return $clusters
}

################################################################################
# bidiVisualLine:
#    Converts a single line of logical-order Hebrew text to visual order.
#    1. Reverse all grapheme clusters in the string.
#    2. Find any Latin/digit sequences that were reversed and un-reverse them.
################################################################################
proc bidiVisualLine {text} {
  # Step 1: Reverse grapheme clusters
  set clusters [graphemeClusters $text]
  set reversed {}
  for {set i [expr {[llength $clusters] - 1}]} {$i >= 0} {incr i -1} {
    lappend reversed [lindex $clusters $i]
  }
  set reversedText [join $reversed ""]

  # Step 2: Find Latin/digit-containing runs and un-reverse them.
  # Pattern matches non-space non-Hebrew sequences containing at least one
  # Latin letter or digit (e.g. reversed "chess.com" → "moc.ssehc").
  set result ""
  set pos 0
  set len [string length $reversedText]
  while {$pos < $len} {
    if {[regexp -start $pos -indices \
         {[^\s\u0590-\u05FF]*[A-Za-z0-9][^\s\u0590-\u05FF]*} \
         $reversedText match]} {
      set matchStart [lindex $match 0]
      set matchEnd [lindex $match 1]
      # Append any text before the match unchanged
      if {$matchStart > $pos} {
        append result [string range $reversedText $pos [expr {$matchStart - 1}]]
      }
      # Un-reverse this LTR segment
      set ltrRun [string range $reversedText $matchStart $matchEnd]
      set ltrClusters [graphemeClusters $ltrRun]
      set unreversed {}
      for {set i [expr {[llength $ltrClusters] - 1}]} {$i >= 0} {incr i -1} {
        lappend unreversed [lindex $ltrClusters $i]
      }
      append result [join $unreversed ""]
      set pos [expr {$matchEnd + 1}]
    } else {
      append result [string range $reversedText $pos end]
      break
    }
  }
  return $result
}

################################################################################
# bidiVisual:
#    Converts logical-order text containing Hebrew to visual order for display
#    in Tk widgets that don't support BiDi. Handles multiline strings by
#    processing each line independently. Skips strings with HTML tags.
################################################################################
proc bidiVisual {text} {
  # Skip strings containing HTML tags (used by text widgets that may
  # handle their own rendering)
  if {[string match "*<*>*" $text]} {
    return $text
  }
  # Process each line independently
  set lines [split $text \n]
  set result {}
  foreach line $lines {
    lappend result [bidiVisualLine $line]
  }
  return [join $result \n]
}

################################################################################
# menuText:
#    Assigns the menu name and help message for a menu entry and language.
################################################################################
proc menuText {lang tag label underline {helpMsg ""}} {
  # For RTL languages, convert Hebrew text to visual order
  if {$lang in $::rtlLanguages && [regexp {[\u0590-\u05FF]} $label]} {
    set label [bidiVisual $label]
    set underline -1  ;# underline meaningless after visual reordering
    if {$helpMsg ne "" && [regexp {[\u0590-\u05FF]} $helpMsg]} {
      set helpMsg [bidiVisual $helpMsg]
    }
  }
  set ::menuLabel($lang,$tag) $label
  set ::menuUnder($lang,$tag) $underline
  if {$helpMsg != ""} {
    set ::helpMessage($lang,$tag) $helpMsg
  }
}
################################################################################
# helpMsg:
#    Assigns the help message for a particular language for a button.
# ################################################################################
proc helpMsg {lang button message} {
  set ::helpMessage($lang,$button) $message
}

array set tr {}
array set translations {}
################################################################################
# translate:
#    Assigns a translation for future reference.
################################################################################
proc translate {lang tag label} {
  regsub {\\n} $label "\n" label
  # For RTL languages, convert Hebrew text to visual order
  if {$lang in $::rtlLanguages && [regexp {[\u0590-\u05FF]} $label]} {
    set label [bidiVisual $label]
  }
  set ::translations($lang,$tag) $label
  set ::tr($tag) $label
  foreach extra {":" "..."} {
    set newtag "${tag}${extra}"
    set newlabel "${label}${extra}"
    set ::translations($lang,$newtag) $newlabel
    set ::tr($newtag) $newlabel
  }
}
################################################################################
# translateECO:
#    Given a pair list of ECO opening name phrase translations,
#    assigns the translations for future reference.
################################################################################
proc translateECO {lang pairList} {
  foreach {from to} $pairList {
    sc_eco translate $lang $from $to
  }
}
################################################################################
# tr:
#    Given a tag and language, returns the stored text for that tag.
################################################################################
proc tr {tag {lang ""}} {
  global menuLabel tr
  if {$lang == ""} {set lang $::language}
  # First, look for a menu label
  if {[info exists menuLabel($lang,$tag)]} {
    return $menuLabel($lang,$tag)
  }
  if {[info exists menuLabel(E,$tag)]} {
    return $menuLabel(E,$tag)
  }
  # Now look for a regular button/message translation
  if {[info exists tr($tag)]} {
    return $tr($tag)
  }
  # Finally, just give up and return the original tag
  return $tag
}
################################################################################
#
################################################################################
proc setLanguage {} {
  global menuLabel menuUnder helpTitle helpText tips
  set lang $::language
  
  if { $::translatePieces } {
    switch $lang {
      C {sc_info language cz}
      D {sc_info language de}
      F {sc_info language fr}
      G {sc_info language gr}
      H {sc_info language hu}
      I {sc_info language it}
      K {sc_info language ca}
      N {sc_info language ne}
      O {sc_info language no}
      S {sc_info language es}
      U {sc_info language fi}
      W {sc_info language sw}
      M {sc_info language zh}
      T {sc_info language tr}
      J {sc_info language sr}
      A {sc_info language ja}
      L {sc_info language ro}
      B {sc_info language pt}
      V {sc_info language he}
      Z {sc_info language swa}
      h {sc_info language hi}
      Q {sc_info language uk}
      b {sc_info language bn}
      default {sc_info language en}
    }
  } else {
    sc_info language en
  }
  
  if {[catch {
    if {[info exists ::langSourceFile($lang)]} {
      source -encoding $::langEncoding($lang) [file nativename [file join "$::scidTclDir" "lang/$::langSourceFile($lang)"]]
      unset ::langSourceFile($lang)
    }
    setLanguage_$lang
  } err ]} {
    tk_messageBox -message "Error loading $lang language: $err"
  }

  # If using Tk, translate all menus:
  if {[winfo exists .menu]} { setLanguageMenus }
  
  foreach i [array names ::tr] {
    if {[info exists ::translations($lang,$i)]} {
      set ::tr($i) $::translations($lang,$i)
    } elseif {[info exists ::translations(E,$i)]} {
      set ::tr($i) $::translations(E,$i)
    }
  }
}
################################################################################
# Will switch language only for Scid backoffice, no UI
# Used to make callbacks use english by default
################################################################################
proc setLanguageTemp { lang } {
  switch $lang {
    C {sc_info language cz}
    D {sc_info language de}
    F {sc_info language fr}
    G {sc_info language gr}
    H {sc_info language hu}
    I {sc_info language it}
    K {sc_info language ca}
    N {sc_info language ne}
    O {sc_info language no}
    S {sc_info language es}
    U {sc_info language fi}
    W {sc_info language sw}
    M {sc_info language zh}
    T {sc_info language tr}
    J {sc_info language sr}
    A {sc_info language ja}
    L {sc_info language ro}
    B {sc_info language pt}
    V {sc_info language he}
    Z {sc_info language swa}
    h {sc_info language hi}
    Q {sc_info language uk}
    b {sc_info language bn}
    default {sc_info language en}
  }
}

addLanguage E English 0 utf-8 english.tcl
addLanguage K Català 2 iso8859-1 catalan.tcl
addLanguage C Čeština 0 iso8859-2 czech.tcl
addLanguage D Deutsch 0 iso8859-1 deutsch.tcl
addLanguage F Francais 0 utf-8 francais.tcl
addLanguage G Ελληνικά 0 utf-8 greek.tcl
addLanguage H Magyar 0 iso8859-2 hungary.tcl
addLanguage I Italiano 0 utf-8 italian.tcl
addLanguage N Nederlands 0 iso8859-1 nederlan.tcl
addLanguage O Norsk 1 iso8859-1 norsk.tcl
addLanguage P Polski 0 iso8859-2 polish.tcl
addLanguage B Português 0 utf-8 portbr.tcl
addLanguage R Русский 1 utf-8 russian.tcl
addLanguage Y Srpski 2 iso8859-2 serbian.tcl
addLanguage S Español 1 utf-8 spanish.tcl
addLanguage U Suomi 1 iso8859-1 suomi.tcl
addLanguage W Svenska 1 iso8859-1 swedish.tcl
addLanguage M 中文 0 utf-8 chinese.tcl
addLanguage T Türkçe 1 utf-8 turkish.tcl
addLanguage J Српски 0 utf-8 SerbCyr.tcl
addLanguage A 日本語 0 utf-8 japanese.tcl
addLanguage L Română 0 utf-8 romanian.tcl
addLanguage V עברית 0 utf-8 hebrew.tcl
addLanguage Z Kiswahili 0 utf-8 swahili.tcl
addLanguage h हिन्दी 0 utf-8 hindi.tcl
addLanguage Q Українська 0 utf-8 ukrainian.tcl
addLanguage b বাংলা 0 utf-8 bengali.tcl

setLanguage

### End of file: lang.tcl
