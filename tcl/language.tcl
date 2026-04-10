### lang.tcl: Support for multiple-language menus, buttons, etc.
### Part of Scid, which is Copyright 2001-2003 Shane Hudson.

array set langEncoding {}
set languages {}
set ::isRTL 0
set ::rtlLanguages {Q V}

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
## TODO Put in the right letters for greek
set transPieces(G)   { P B K K Q D R T B L N S }
set untransPieces(G) { B P K K D Q T R L B S N }
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
set transPieces(Q)   { P ب K م Q و R ر B ف N ح }
set transPieces(V)   { P פ K מ Q מ R צ B ר N ס }
set untransPieces(V) { פ P מ K מ Q צ R ר B ס N }

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
################################################################################
# isLTRChar:
#    Returns 1 if the given Unicode code point is a Latin letter, digit, or
#    period (common in embedded LTR tokens like "Rel.", "HTML", "chess.com").
################################################################################
proc isLTRChar {code} {
  if {($code >= 0x41 && $code <= 0x5A) || ($code >= 0x61 && $code <= 0x7A)} { return 1 }
  if {$code >= 0x30 && $code <= 0x39} { return 1 }
  if {$code == 0x2E} { return 1 }
  return 0
}
################################################################################
# reverseForRTL:
#    Converts logical-order RTL text to visual order for display in Tk menu
#    widgets that do not implement the Unicode BiDi algorithm.
#    Reverses the entire string, then reverses embedded LTR runs (Latin text,
#    digits, abbreviations) back to their correct left-to-right order.
################################################################################
proc reverseForRTL {text} {
  set reversed [string reverse $text]
  set result ""
  set i 0
  set len [string length $reversed]
  while {$i < $len} {
    set code [scan [string index $reversed $i] %c]
    if {[isLTRChar $code]} {
      # Collect the LTR run, including spaces between LTR characters
      set ltr_run [string index $reversed $i]
      incr i
      while {$i < $len} {
        set code [scan [string index $reversed $i] %c]
        if {[isLTRChar $code]} {
          append ltr_run [string index $reversed $i]
          incr i
        } elseif {[string index $reversed $i] eq " " && ($i + 1) < $len
                  && [isLTRChar [scan [string index $reversed [expr {$i + 1}]] %c]]} {
          # Space between two LTR chars belongs to the LTR run
          append ltr_run " "
          incr i
        } else {
          break
        }
      }
      append result [string reverse $ltr_run]
    } else {
      append result [string index $reversed $i]
      incr i
    }
  }
  return $result
}
################################################################################
# menuText:
#    Assigns the menu name and help message for a menu entry and language.
################################################################################
proc menuText {lang tag label underline {helpMsg ""}} {
  if {$lang in $::rtlLanguages} {
    # Convert to visual order for Tk menus that lack BiDi support
    set ::menuLabel($lang,$tag) [reverseForRTL $label]
    set ::menuUnder($lang,$tag) -1
  } else {
    set ::menuLabel($lang,$tag) $label
    set ::menuUnder($lang,$tag) $underline
  }
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
  if {$lang == "X"} {return $tag}
  # First, look for a menu label
  if {[info exists menuLabel($lang,$tag)]} {
    set result $menuLabel($lang,$tag)
  } elseif {[info exists menuLabel(E,$tag)]} {
    set result $menuLabel(E,$tag)
  # Now look for a regular button/message translation
  } elseif {[info exists tr($tag)]} {
    set result $tr($tag)
  } else {
    # Finally, just give up and return the original tag
    return $tag
  }
  return $result
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
      Q {sc_info language ar}
      V {sc_info language he}
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

  # Apply RTL configuration for Arabic
  if {$lang == "Q" || $lang == "V"} {
    applyRTLConfiguration
  } else {
    applyLTRConfiguration
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

proc applyRTLConfiguration {} {
  set ::isRTL 1
  option add *Text.direction rtl
  option add *Entry.justify right
  option add *Label.justify right
  option add *Button.justify right
}

proc applyLTRConfiguration {} {
  set ::isRTL 0
  option add *Text.direction ltr
  option add *Entry.justify left
  option add *Label.justify left
  option add *Button.justify left
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
    Q {sc_info language ar}
    V {sc_info language he}
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
addLanguage B Português 0 iso8859-1 portbr.tcl
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
addLanguage Q العربية 0 utf-8 arabic.tcl
addLanguage V עברית 0 utf-8 hebrew.tcl

setLanguage

### End of file: lang.tcl
