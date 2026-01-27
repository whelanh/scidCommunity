#!/usr/bin/tclsh
###
### propagatelang.tcl
###

# (C) Pascal Georges 2007
#
# This is an utility script that helps adding keywords to each language file
# 1. It is supposed that language files are synchronized before running this script
# 2. The english file is compared to others and if tokens are in the english file and not in others
# it will added at the right place. The result is output to args.new
# Usage : "propagatelang.tcl francais" : will synchronize francais.tcl to english.tcl and send the output to francais.new
#              or "propagatelang.tcl" for all files
# a "TODO translate me" is appended at each line needing it

array set encodings {
  czech iso8859-2
  deutsch iso8859-1
  francais utf-8
  hungary iso8859-2
  italian utf-8
  chinese utf-8
  nederlan iso8859-1
  norsk iso8859-1
  polish iso8859-2
  portbr iso8859-1
  russian utf-8
  serbian iso8859-2
  spanish iso8859-1
  swedish iso8859-1
  catalan iso8859-1
  suomi iso8859-1
  greek utf-8
  turkish utf-8
  SerbCyr utf-8
  japanese utf-8
  romanian utf-8
}

array set codes {
  czech C
  deutsch D
  francais F
  hungary H
  italian I
  chinese M
  nederlan N
  norsk O
  polish P
  portbr B
  russian R
  serbian Y
  spanish S
  swedish W
  catalan K
  suomi U
  greek G
  turkish T
  SerbCyr J
  japanese A
  romanian L
}

set languages {czech deutsch francais hungary italian chinese nederlan norsk polish
  portbr spanish swedish serbian russian catalan suomi greek turkish SerbCyr japanese romanian
}

################################################################################
proc checkfile {code langfile enc} {
  # Read this language file and the english file:

  set f [open english.tcl r]
  set data [read $f]
  close $f
  set englishData [split $data "\n"]
  set englishNames {}

  set f [open $langfile.tcl r]
  fconfigure $f -encoding $enc
  set data [read $f]
  close $f
  set langData [split $data "\n"]
  set langNames {}

  foreach line $langData {
    set fields [split $line]
    set command [lindex $fields 0]
    set lang [lindex $fields 1]
    set name [lindex $fields 2]
    if {$lang == $code  &&  ($command == "menuText" || $command == "translate" || $command == "helpMsg")} {
      lappend langNames $command:$name
    } else  {
      lappend langNames $line
    }
  }

  set fnew [open $langfile.tcl w]
  fconfigure $fnew -encoding $enc

  set lastLine -1
  set i 0
  while {$i < [llength $englishData]} {
    set line [lindex $englishData $i]
    set fields [split $line]
    set command [lindex $fields 0]
    set lang [lindex $fields 1]
    set name [lindex $fields 2]

    if {$lang == "E"  &&  ($command == "menuText" || $command == "translate" || $command == "helpMsg")} {
      set lineCount [lsearch -exact $langNames $command:$name]
      if { $lineCount < 0} {
        # Missing translation - need to copy all lines of the English entry
        puts $fnew  "# ====== TODO To be translated ======"
        puts $fnew [regsub " E " $line " $code "]
        
        # Check if this is a multi-line entry by counting braces
        set braceCount 0
        foreach char [split $line ""] {
          if {$char eq "\{"} { incr braceCount }
          if {$char eq "\}"} { incr braceCount -1 }
        }
        
        # Also check for continuation with backslash
        set hasBackslash [string match "*\\\\" [string trimright $line]]
        
        # Continue reading lines until braces are balanced and no trailing backslash
        while {($braceCount > 0 || $hasBackslash) && $i + 1 < [llength $englishData]} {
          incr i
          set line [lindex $englishData $i]
          puts $fnew [regsub " E " $line " $code "]
          
          foreach char [split $line ""] {
            if {$char eq "\{"} { incr braceCount }
            if {$char eq "\}"} { incr braceCount -1 }
          }
          set hasBackslash [string match "*\\\\" [string trimright $line]]
        }
      } elseif {$lastLine >= $lineCount} {
          puts "WARNING: $name found in a wrong position"
      } else {
        foreach l [lrange $langData [ expr $lastLine + 1 ] $lineCount] {
          puts $fnew $l
        }

        # in case of a \\ at the end of the last line
        if {[string index $l end] == "\\"} {
          incr lineCount
          puts $fnew [lindex $langData $lineCount]
        }
        set lastLine $lineCount
      }
    }
    incr i
  }

  foreach l [lrange $langData [ expr $lastLine + 1 ] end-1] {
    puts $fnew $l
  }
  close $fnew
}
################################################################################

if {[llength $argv] == 0} { set argv $languages }

foreach language $argv {
  if {[info exists codes($language)]} {
    checkfile $codes($language) $language $encodings($language)
  } else {
    puts "No such language file: $language"
  }
}

# end of file
