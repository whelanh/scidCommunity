############################################################
### file/rtf.tcl — RTF export/import for scidCommunity
### Copyright (C) 2026 scidCommunity contributors
###
### Exports the current game (or all filtered games) to an RTF file,
### preserving rich-text comment formatting stored as HTML-like markup.
### Provides a matching importer for RTF files produced by this module.
###
### All public entry points are in the  ::rtf  namespace.
############################################################

namespace eval ::rtf {

    # -----------------------------------------------------------------------
    # NAG number <-> display symbol table
    # -----------------------------------------------------------------------
    variable nagSymbol
    array set nagSymbol {
        1   "!"
        2   "?"
        3   "!!"
        4   "??"
        5   "!?"
        6   "?!"
        10  "="
        13  "\u221e"
        14  "\u2a72"
        15  "\u2a71"
        16  "\u00b1"
        17  "\u2213"
        18  "+-"
        19  "-+"
        20  "+--"
        21  "--+"
        32  "\u27f3"
        36  "\u2192"
        40  "\u2191"
        132 "\u21c6"
        138 "(D)"
        140 "\u25b3"
        142 "\u2313"
        145 "RR"
        146 "N"
    }

    variable symbolToNag
    array set symbolToNag {
        "!"      "$1"
        "?"      "$2"
        "!!"     "$3"
        "??"     "$4"
        "!?"     "$5"
        "?!"     "$6"
        "="      "$10"
        "\u221e" "$13"
        "\u2a72" "$14"
        "+/="    "$14"
        "+="     "$14"
        "\u2a71" "$15"
        "=/+"    "$15"
        "=+"     "$15"
        "\u00b1" "$16"
        "+/-"    "$16"
        "\u2213" "$17"
        "-/+"    "$17"
        "+-"     "$18"
        "-+"     "$19"
        "+--"    "$20"
        "--+"    "$21"
        "\u27f3" "$32"
        "\u2192" "$36"
        "\u2191" "$40"
        "\u21c6" "$132"
        "(D)"    "$138"
        "\u25b3" "$140"
        "\u2313" "$142"
        "RR"     "$145"
        "N"      "$146"
    }

    # Map a "$N" or plain number string -> symbol (falls back to raw text)
    proc nagToSymbol {nagStr} {
        variable nagSymbol
        set result {}
        foreach tok [split [string trim $nagStr]] {
            if {$tok eq "" || $tok eq "0"} { continue }
            if {![string match {$*} $tok] && ![string is integer -strict $tok]} {
                lappend result $tok
                continue
            }
            set n $tok
            regsub {^\$} $n {} n
            if {[info exists nagSymbol($n)]} {
                lappend result $nagSymbol($n)
            } else {
                lappend result "\$$n"
            }
        }
        return [join $result " "]
    }

    # Convert symbols back to standard PGN NAG codes ($N)
    proc symbolToNag {text} {
        variable symbolToNag
        set result {}
        foreach word [split $text] {
            if {$word eq ""} { continue }
            if {[info exists symbolToNag($word)]} {
                lappend result $symbolToNag($word)
            } else {
                lappend result $word
            }
        }
        return [join $result " "]
    }

    # -----------------------------------------------------------------------
    # RTF character escaping
    # -----------------------------------------------------------------------
    proc rtfEscape {text} {
        set text [string map [list "\\" "\\\\" "\x7b" "\\\x7b" "\x7d" "\\\x7d"] $text]
        set out ""
        foreach ch [split $text ""] {
            set cp [scan $ch %c]
            if {$cp > 127} {
                append out "\\u${cp}?"
            } else {
                append out $ch
            }
        }
        return $out
    }

    proc rtfUnescape {text} {
        set result ""
        set i 0
        set len [string length $text]
        while {$i < $len} {
            if {[regexp {^\\u(-?[0-9]+)\??} [string range $text $i end] m numStr]} {
                set cp $numStr
                if {$cp < 0} { set cp [expr {$cp + 65536}] }
                append result [format %c $cp]
                incr i [string length $m]
            } elseif {[string range $text $i [expr {$i+1}]] eq "\\\\"} {
                append result "\\"
                incr i 2
            } elseif {[string range $text $i [expr {$i+1}]] eq "\\\x7b"} {
                append result "\x7b"
                incr i 2
            } elseif {[string range $text $i [expr {$i+1}]] eq "\\\x7d"} {
                append result "\x7d"
                incr i 2
            } else {
                append result [string index $text $i]
                incr i
            }
        }
        return $result
    }

    # -----------------------------------------------------------------------
    # Font/colour table builders
    # -----------------------------------------------------------------------
    proc commentDefaultColor_ {} {
        if {[info exists ::pgnColor(Comment)] && $::pgnColor(Comment) ne ""} {
            return $::pgnColor(Comment)
        }
        return "#008b00"
    }

    proc buildColorTable {commentList} {
        set colors [list "#000000" [commentDefaultColor_]]
        foreach markup $commentList {
            foreach run [::windows::commenteditor::parseMarkup_ $markup] {
                set color [::windows::commenteditor::styleGet_ [lindex $run 1] color]
                if {$color ne "" && $color ni $colors} {
                    lappend colors $color
                }
            }
        }
        return $colors
    }

    proc buildFontTable {commentList} {
        set defaultFamily "Helvetica"
        catch { set defaultFamily [font actual font_Regular -family] }
        set fonts [list $defaultFamily]
        foreach markup $commentList {
            foreach run [::windows::commenteditor::parseMarkup_ $markup] {
                set fam [::windows::commenteditor::styleGet_ [lindex $run 1] family]
                if {$fam ne "" && $fam ni $fonts} {
                    lappend fonts $fam
                }
            }
        }
        return $fonts
    }

    # -----------------------------------------------------------------------
    # RTF document header
    # -----------------------------------------------------------------------
    proc rtfHeader {fontTable colorTable} {
        set h "\x7b\\rtf1\\ansi\\deff0\n"

        append h "\x7b\\fonttbl\n"
        set fi 0
        foreach fam $fontTable {
            append h "\x7b\\f$fi\\fnil\\fcharset0 [rtfEscape $fam];\x7d\n"
            incr fi
        }
        append h "\x7d\n"

        append h "\x7b\\colortbl ;"
        foreach color $colorTable {
            if {[regexp {^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$} \
                    $color -> rh gh bh]} {
                set r [expr {[scan $rh %x]}]
                set g [expr {[scan $gh %x]}]
                set b [expr {[scan $bh %x]}]
                append h "\\red${r}\\green${g}\\blue${b};"
            } else {
                append h "\\red0\\green0\\blue0;"
            }
        }
        append h "\x7d\n"
        return $h
    }

    # -----------------------------------------------------------------------
    # Convert one markup string -> RTF inline runs
    # -----------------------------------------------------------------------
    proc markupToRtf {markup fontTable colorTable defaultSizePt} {
        set out ""
        set runs [::windows::commenteditor::parseMarkup_ $markup]
        if {[llength $runs] == 0} { return "" }

        foreach run $runs {
            lassign $run text style
            lassign $style bold italic under color family size

            set ctrl ""
            if {$bold}   { append ctrl "\\b " }   else { append ctrl "\\b0 " }
            if {$italic} { append ctrl "\\i " }   else { append ctrl "\\i0 " }
            if {$under}  { append ctrl "\\ul " }  else { append ctrl "\\ulnone " }

            if {$family ne ""} {
                set fi [lsearch -exact $fontTable $family]
                if {$fi < 0} { set fi 0 }
                append ctrl "\\f$fi "
            } else {
                append ctrl "\\f0 "
            }

            if {$size ne "" && [string is integer -strict $size] && $size > 0} {
                append ctrl "\\fs[expr {$size * 2}] "
            }

            if {$color ne ""} {
                set ci [lsearch -exact $colorTable $color]
                if {$ci < 0} { set ci 0 }
                append ctrl "\\cf[expr {$ci + 1}] "
            } else {
                set ci [lsearch -exact $colorTable [commentDefaultColor_]]
                if {$ci < 0} { set ci 0 }
                append ctrl "\\cf[expr {$ci + 1}] "
            }

            set escaped [rtfEscape $text]
            set escaped [string map {"\n" "\\par\n"} $escaped]
            append out "\x7b$ctrl$escaped\x7d"
        }
        return $out
    }

    # -----------------------------------------------------------------------
    # Convert RTF runs back to HTML markup string
    # -----------------------------------------------------------------------
    proc rtfRunsToMarkup {rtfText fontTable colorTable {defaultSizePt 11}} {
        set markup ""
        set tokens [tokenizeRtf_ $rtfText]
        foreach tok $tokens {
            if {![string match "\x7b*" $tok]} { continue }
            set inner [string range $tok 1 end-1]

            set bold 0; set italic 0; set under 0
            set color ""; set family ""; set size ""
            set plainText ""

            set len [string length $inner]
            set pos 0
            while {$pos < $len} {
                set ch [string index $inner $pos]
                if {$ch ne "\\"} {
                    if {$ch ne "\n" && $ch ne "\r"} { append plainText $ch }
                    incr pos
                    continue
                }

                set tail [string range $inner $pos end]

                # \uNNNN unicode character (with optional '?' fallback)
                if {[regexp {^\\u(-?[0-9]+)(\?)?} $tail -> cpStr qm]} {
                    set cp $cpStr
                    if {$cp < 0} { set cp [expr {$cp + 65536}] }
                    append plainText [format %c $cp]
                    incr pos [expr {2 + [string length $cpStr] + [string length $qm]}]
                    continue
                }

                # Escaped literals \\ \{ \}
                if {[regexp {^\\(\\|\x7b|\x7d)} $tail -> lit]} {
                    append plainText $lit
                    incr pos 2
                    continue
                }

                # Control word: \wordNNN with optional trailing space
                if {[regexp {^\\([a-zA-Z]+)(-?[0-9]*)[ ]?} $tail -> word numStr]} {
                    set consumed [expr {1 + [string length $word] + [string length $numStr]}]
                    if {[string index $tail $consumed] eq " "} { incr consumed }
                    incr pos $consumed
                    switch -- $word {
                        b      { if {$numStr eq "0"} { set bold 0 } else { set bold 1 } }
                        i      { if {$numStr eq "0"} { set italic 0 } else { set italic 1 } }
                        ul     { set under 1 }
                        ulnone { set under 0 }
                        f      {
                            if {[string is integer -strict $numStr]} {
                                set fi [expr {int($numStr)}]
                                if {$fi > 0 && $fi < [llength $fontTable]} {
                                    set family [lindex $fontTable $fi]
                                }
                            }
                        }
                        fs     {
                            if {[string is integer -strict $numStr]} {
                                set s [expr {int($numStr) / 2}]
                                if {$s != $defaultSizePt} { set size $s }
                            }
                        }
                        cf     {
                            if {[string is integer -strict $numStr]} {
                                set ci [expr {int($numStr) - 1}]
                                if {$ci >= 0 && $ci < [llength $colorTable]} {
                                    set color [lindex $colorTable $ci]
                                }
                            }
                        }
                        par    { append plainText "\n" }
                        default {}
                    }
                    continue
                }

                # Unknown backslash sequence: skip the backslash.
                incr pos
            }

            if {$color eq "#000000" || $color eq [commentDefaultColor_]} { set color "" }

            set openTag ""
            set closeTag ""
            if {$bold}   { append openTag "<b>";  set closeTag "</b>$closeTag" }
            if {$italic} { append openTag "<i>";  set closeTag "</i>$closeTag" }
            if {$under}  { append openTag "<u>";  set closeTag "</u>$closeTag" }
            if {$color ne "" || $family ne "" || $size ne ""} {
                set attrs ""
                if {$color  ne ""} { append attrs "color:$color;" }
                if {$family ne ""} { append attrs "font-family:$family;" }
                if {$size   ne ""} { append attrs "font-size:${size}pt;" }
                append openTag "<span style=\"[string trimright $attrs]\">"
                set closeTag "</span>$closeTag"
            }
            append markup $openTag [::windows::commenteditor::escapeText_ $plainText] $closeTag
        }
        return $markup
    }

    # -----------------------------------------------------------------------
    # Game tree walker
    # -----------------------------------------------------------------------
    proc collectGame {} {
        sc_move start
        return [collectLine_]
    }

    proc collectLine_ {} {
        set elements {}
        set needMoveNum 1

        set preComment [sc_pos getComment]
        set preNags    [sc_pos getNags]
        if {$preNags eq "0"} { set preNags "" }
        if {$preComment ne "" || $preNags ne ""} {
            set preDiagramFen ""
            if {[hasDiagramNag_ $preNags]} {
                set preDiagramFen [lindex [split [sc_pos fen]] 0]
            }
            lappend elements [list "" [nagToSymbol $preNags] $preComment {} $preDiagramFen]
            set needMoveNum 1
        }

        while {![sc_pos isAt vend]} {
            set vars {}
            set nv [sc_var count]
            if {$nv > 0} {
                for {set v 0} {$v < $nv} {incr v} {
                    sc_var enter $v
                    sc_move back
                    set varElems [collectLine_]
                    sc_var exit
                    lappend vars $varElems
                }
            }

            sc_move forward

            set moveText [sc_game info previousMove]
            set moveNum  [sc_pos moveNumber]
            set side     [sc_pos side]
            if {$side eq "black"} {
                set moveLabel "$moveNum.$moveText"
                set needMoveNum 0
            } else {
                if {$needMoveNum} {
                    set moveLabel "[expr {$moveNum - 1}]...$moveText"
                } else {
                    set moveLabel "$moveText"
                }
                set needMoveNum 0
            }

            set nags [sc_pos getNags]
            if {$nags eq "0"} { set nags "" }
            set nagSym [nagToSymbol $nags]
            set diagramFen ""
            if {[hasDiagramNag_ $nags]} {
                set diagramFen [lindex [split [sc_pos fen]] 0]
            }

            set comment [sc_pos getComment]
            if {$comment ne "" || [llength $vars] > 0} {
                set needMoveNum 1
            }

            lappend elements [list $moveLabel $nagSym $comment $vars $diagramFen]
        }
        return $elements
    }

    # -----------------------------------------------------------------------
    # Board diagrams (rendered for the "D" / "#" annotation NAG)
    # -----------------------------------------------------------------------
    array set pieceImgCache_ {}
    proc hasDiagramNag_ {nags} {
        foreach tok [split [string trim $nags]] {
            if {$tok eq "D" || $tok eq "#"} { return 1 }
        }
        return 0
    }

    proc piece2gifName_ {piece} {
        switch -- $piece {
            K { return wk } k { return bk }
            Q { return wq } q { return bq }
            R { return wr } r { return br }
            B { return wb } b { return bb }
            N { return wn } n { return bn }
            P { return wp } p { return bp }
        }
        return sq
    }

    proc pieceImage_ {piece} {
        variable pieceImgCache_
        if {![info exists pieceImgCache_($piece)]} {
            set dir [file join [::html::htmlSourceDir] bitmaps mini]
            set fname [file join $dir "[piece2gifName_ $piece].gif"]
            if {[file exists $fname]} {
                set pieceImgCache_($piece) [image create photo -file $fname]
            } else {
                set pieceImgCache_($piece) ""
            }
        }
        return $pieceImgCache_($piece)
    }

    proc fenToBoardPng_ {fen} {
        set sq 40
        set size [expr {$sq * 8}]

        set boardPart [lindex [split $fen] 0]
        set grid {}
        foreach rank [split $boardPart "/"] {
            set row {}
            foreach ch [split $rank ""] {
                if {[string is integer -strict $ch]} {
                    for {set j 0} {$j < $ch} {incr j} { lappend row "" }
                } else {
                    lappend row $ch
                }
            }
            lappend grid $row
        }
        if {[llength $grid] != 8} { error "invalid FEN" }

        set img [image create photo -width $size -height $size]
        for {set r 0} {$r < 8} {incr r} {
            for {set c 0} {$c < 8} {incr c} {
                set isDark [expr {($r + $c) % 2 == 1}]
                set color [expr {$isDark ? "#b58863" : "#f0d9b5"}]
                $img put $color -to [expr {$c*$sq}] [expr {$r*$sq}] \
                    [expr {$c*$sq+$sq}] [expr {$r*$sq+$sq}]
            }
        }
        for {set r 0} {$r < 8} {incr r} {
            for {set c 0} {$c < 8} {incr c} {
                set piece [lindex [lindex $grid $r] $c]
                if {$piece eq ""} { continue }
                set pimg [pieceImage_ $piece]
                if {$pimg eq ""} { continue }
                $img copy $pimg -zoom 2 -to [expr {$c*$sq}] [expr {$r*$sq}]
            }
        }

        set png [$img data -format png]
        image delete $img
        return $png
    }

    proc diagramToRtf_ {fen} {
        if {[catch {set png [fenToBoardPng_ $fen]}]} { return "" }
        if {$png eq ""} { return "" }
        set px 320
        binary scan $png H* hex
        return "\x7b\\pict\\pngblip\\picw${px}\\pich${px}\\picwgoal2880\\pichgoal2880 $hex\x7d"
    }

    # -----------------------------------------------------------------------
    # Render a game element list to RTF body text
    # -----------------------------------------------------------------------
    proc renderLine_ {elements fontTable colorTable defaultSizePt depth} {
        set out ""
        set indent [string repeat "    " $depth]
        set defCtrl "\\f0\\fs[expr {$defaultSizePt*2}]\\cf1\\b0\\i0\\ulnone "

        foreach elt $elements {
            lassign $elt moveLabel nagSym comment vars diagramFen

            if {$moveLabel ne ""} {
                if {$depth == 0} {
                    append out "\x7b\\b [rtfEscape $moveLabel]\x7d"
                } else {
                    append out "\x7b[rtfEscape $moveLabel]\x7d"
                }
                if {$nagSym ne ""} {
                    append out " \x7b${defCtrl}[rtfEscape $nagSym]\x7d"
                }
                append out " "
            }

            if {$comment ne ""} {
                append out "\x7b\\v SCID_COMMENT_BEGIN\\v0\x7d"
                append out [markupToRtf $comment $fontTable $colorTable $defaultSizePt]
                append out "\x7b\\v SCID_COMMENT_END\\v0\x7d "
            }

            if {$diagramFen ne ""} {
                set diagram [diagramToRtf_ $diagramFen]
                if {$diagram ne ""} {
                    append out "\\par\n${indent}${diagram}\\par\n"
                }
            }

            foreach var $vars {
                set varSizePt [expr {$defaultSizePt > 9 ? $defaultSizePt - 1 : $defaultSizePt}]
                append out "\\par\n${indent}    \x7b${defCtrl}\\fs[expr {$varSizePt*2}] (\x7d "
                append out [renderLine_ $var $fontTable $colorTable $varSizePt [expr {$depth+1}]]
                append out "\x7b${defCtrl}\\fs[expr {$varSizePt*2}] )\x7d \\par\n${indent}"
            }
        }
        return $out
    }

    # -----------------------------------------------------------------------
    # Game header tags -> RTF paragraphs & hidden destination
    # -----------------------------------------------------------------------
    proc tagsToRtf {defaultSizePt} {
        set out ""
        set headerSz [expr {$defaultSizePt + 3}]

        # 1. Embed full raw PGN tags inside an RTF hidden comment destination {\*\scidtags ...}
        set rawTags ""
        catch {
            set rawPgn [sc_game pgn -comments 0 -variations 0]
            foreach line [split $rawPgn "\n"] {
                set line [string trim $line]
                if {[string match {\[*\]} $line]} {
                    append rawTags "$line\n"
                } elseif {$line ne "" && ![string match {\[*\]} $line]} {
                    break
                }
            }
        }
        if {$rawTags ne ""} {
            append out "\x7b\\*\\scidtags\n[rtfEscape $rawTags]\x7d\n"
        }

        # 2. Parse tags into array for clean visual rendering
        array set tagMap {}
        foreach line [split $rawTags "\n"] {
            if {[regexp {^\[([a-zA-Z0-9]+)\s+"(.*)"\]$} $line -> k v]} {
                set tagMap($k) $v
            }
        }

        set white  "?"
        if {[info exists tagMap(White)] && $tagMap(White) ne ""} { set white $tagMap(White) }
        set black  "?"
        if {[info exists tagMap(Black)] && $tagMap(Black) ne ""} { set black $tagMap(Black) }
        set result "*"
        if {[info exists tagMap(Result)] && $tagMap(Result) ne ""} { set result $tagMap(Result) }
        set welo ""
        if {[info exists tagMap(WhiteElo)] && $tagMap(WhiteElo) ne ""} { set welo " ($tagMap(WhiteElo))" }
        set belo ""
        if {[info exists tagMap(BlackElo)] && $tagMap(BlackElo) ne ""} { set belo " ($tagMap(BlackElo))" }

        # Render styled title line
        append out "\x7b\\b\\fs[expr {$headerSz*2}] [rtfEscape "$white$welo \u2013 $black$belo  $result"]\x7d\\par\n"

        # Render the remaining header tags, one per line
        array set shown {}
        foreach tag {Event Site Date Round ECO Opening Variation Annotator} {
            if {[info exists tagMap($tag)] && $tagMap($tag) ne "" && $tagMap($tag) ne "?" && $tagMap($tag) ne "????"} {
                append out "[rtfEscape "$tag: $tagMap($tag)"]\\par\n"
                set shown($tag) 1
            }
        }
        foreach tag [lsort [array names tagMap]] {
            if {[info exists shown($tag)]} { continue }
            if {$tag in {White Black Result WhiteElo BlackElo Event Site Date Round ECO Opening Variation Annotator}} { continue }
            set v $tagMap($tag)
            if {$v eq "" || $v eq "?"} { continue }
            append out "[rtfEscape "$tag: $v"]\\par\n"
        }

        append out "\\par\n"
        return $out
    }

    # -----------------------------------------------------------------------
    # Collect all comments from the current game tree
    # -----------------------------------------------------------------------
    proc collectComments_ {listVar} {
        upvar $listVar comments
        set comments {}
        sc_move start
        collectCommentsLine_ comments
    }

    proc collectCommentsLine_ {listVar} {
        upvar $listVar comments
        set c [sc_pos getComment]
        if {$c ne ""} { lappend comments $c }
        while {![sc_pos isAt vend]} {
            set nv [sc_var count]
            for {set v 0} {$v < $nv} {incr v} {
                sc_var enter $v
                sc_move back
                collectCommentsLine_ comments
                sc_var exit
            }
            sc_move forward
            set c [sc_pos getComment]
            if {$c ne ""} { lappend comments $c }
        }
    }

    # -----------------------------------------------------------------------
    # PUBLIC: Export current game to RTF file
    # -----------------------------------------------------------------------
    proc exportCurrentGame {} {
        set ftype {
            { "Rich Text Format files" {".rtf"} }
            { "All files" {"*"} }
        }
        set fName [tk_getSaveFile \
            -initialdir $::initialDir(base) \
            -filetypes $ftype \
            -defaultextension ".rtf" \
            -title [tr RtfExportTitle]]
        if {$fName eq ""} { return }

        if {[catch {exportCurrentGameToFile_ $fName} err]} {
            tk_messageBox -icon error -type ok -title "scidCommunity" \
                -message "[tr RtfExportError]:\n$err"
            return
        }
        set ::initialDir(base) [file dirname $fName]
    }

    proc exportCurrentGameToFile_ {fName} {
        set defaultSizePt 11
        catch {
            set sz [font actual font_Regular -size]
            if {$sz > 0} { set defaultSizePt $sz }
        }

        sc_game push copy
        try {
            set comments {}
            collectComments_ comments
            set fontTable  [buildFontTable  $comments]
            set colorTable [buildColorTable $comments]
            set gameElems  [collectGame]
        } finally {
            sc_game pop
        }

        set ch [open $fName w]
        try {
            fconfigure $ch -encoding utf-8
            puts -nonewline $ch [rtfHeader $fontTable $colorTable]
            puts -nonewline $ch [tagsToRtf $defaultSizePt]
            puts -nonewline $ch "\\f0\\fs[expr {$defaultSizePt*2}]\\cf1 "
            puts -nonewline $ch "\x7b\\v \\fs[expr {$defaultSizePt*2}] SCID_MOVES_BEGIN \\v0\x7d\n"
            puts -nonewline $ch [renderLine_ $gameElems $fontTable $colorTable $defaultSizePt 0]
            puts            $ch "\\par\n\x7d"
        } finally {
            close $ch
        }
    }

    # -----------------------------------------------------------------------
    # PUBLIC: Export all filtered games to RTF file
    # -----------------------------------------------------------------------
    proc exportFilterGames {} {
        if {[sc_filter count] == 0} {
            tk_messageBox -icon info -type ok -title "scidCommunity" \
                -message [tr FilterEmpty]
            return
        }
        set ftype {
            { "Rich Text Format files" {".rtf"} }
            { "All files" {"*"} }
        }
        set fName [tk_getSaveFile \
            -initialdir $::initialDir(base) \
            -filetypes $ftype \
            -defaultextension ".rtf" \
            -title [tr RtfExportTitle]]
        if {$fName eq ""} { return }

        if {[catch {exportFilterGamesToFile_ $fName} err]} {
            tk_messageBox -icon error -type ok -title "scidCommunity" \
                -message "[tr RtfExportError]:\n$err"
            return
        }
        set ::initialDir(base) [file dirname $fName]
    }

    proc exportFilterGamesToFile_ {fName} {
        set defaultSizePt 11
        catch {
            set sz [font actual font_Regular -size]
            if {$sz > 0} { set defaultSizePt $sz }
        }

        set savedGameNum [sc_game number]

        # Pass 1: collect all comments to build unified font/colour table
        set allComments {}
        set gn [sc_filter first]
        while {$gn != 0} {
            if {![catch {sc_game load $gn}]} {
                collectCommentsLine_ allComments
            }
            set gn [sc_filter next]
        }

        set fontTable  [buildFontTable  $allComments]
        set colorTable [buildColorTable $allComments]

        try {
            set ch [open $fName w]
            try {
                fconfigure $ch -encoding utf-8
                puts -nonewline $ch [rtfHeader $fontTable $colorTable]

                set first 1
                set gn [sc_filter first]
                while {$gn != 0} {
                    if {[catch {sc_game load $gn}]} {
                        set gn [sc_filter next]
                        continue
                    }
                    if {!$first} { puts $ch "\\page" }
                    set first 0

                    set gameElems [collectGame]
                    puts -nonewline $ch [tagsToRtf $defaultSizePt]
                    puts -nonewline $ch "\\f0\\fs[expr {$defaultSizePt*2}]\\cf1 "
                    puts -nonewline $ch "\x7b\\v \\fs[expr {$defaultSizePt*2}] SCID_MOVES_BEGIN \\v0\x7d\n"
                    puts -nonewline $ch [renderLine_ $gameElems $fontTable $colorTable $defaultSizePt 0]
                    puts $ch "\\par"
                    set gn [sc_filter next]
                }
                puts $ch "\x7d"
            } finally {
                close $ch
            }
        } finally {
            if {$savedGameNum > 0} {
                catch {sc_game load $savedGameNum}
            }
        }
    }

    # -----------------------------------------------------------------------
    # PUBLIC: Import a game from an RTF file produced by this module
    # -----------------------------------------------------------------------
    proc importFromFile {} {
        set ftype {
            { "Rich Text Format files" {".rtf"} }
            { "All files" {"*"} }
        }
        set fName [tk_getOpenFile \
            -initialdir $::initialDir(base) \
            -filetypes $ftype \
            -title [tr RtfImportTitle]]
        if {$fName eq ""} { return }

        if {[catch {importFile_ $fName} err]} {
            tk_messageBox -icon error -type ok -title "scidCommunity" \
                -message "[tr RtfImportError]:\n$err"
            return
        }
        set ::initialDir(base) [file dirname $fName]
    }

    proc importFile_ {fName} {
        set ch [open $fName r]
        fconfigure $ch -encoding utf-8
        set raw [read $ch]
        close $ch

        if {![string match "*SCID_COMMENT_BEGIN*" $raw] && \
            ![string match "*SCID_MOVES_BEGIN*" $raw] && \
            ![string match "*scidtags*" $raw]} {
            error [tr RtfNotScidFile]
        }

        set fontTable  [extractFontTable_  $raw]
        set colorTable [extractColorTable_ $raw]

        # Switch to clipboard database
        if {[sc_base current] != $::clipbase_db} {
            ::file::SwitchToBase $::clipbase_db
        }

        # Handle single-game or multi-game RTF separated by \page
        set sections [split [string map {"\\page" "\x1f"} $raw] "\x1f"]
        set importedCount 0
        set lastGameNum 0

        foreach section $sections {
            # Find body start: after colortbl if present
            set bodyStart 0
            if {[regexp -indices {\x7b\\colortbl [^\x7d]*\x7d} $section m]} {
                set bodyStart [expr {[lindex $m 1] + 1}]
            }
            set body [string range $section $bodyStart end]
            set body [string trimright $body]
            if {[string index $body end] eq "\x7d"} {
                set body [string range $body 0 end-1]
            }

            set pgn  [extractPgnTags_  $body]
            set moves [extractMoves_   $body $fontTable $colorTable]
            if {[string trim $moves] eq ""} { continue }
            set fullPgn "$pgn\n$moves\n"

            if {[::game::Clear] eq "cancel"} { return }
            if {[catch {sc_game import $fullPgn} result]} {
                error "PGN import failed: $result"
            }

            # Save imported game to clipbase
            sc_game save 0 $::clipbase_db
            set lastGameNum [sc_base numGames $::clipbase_db]
            incr importedCount
        }

        if {$importedCount == 0} {
            error [tr RtfNotScidFile]
        }

        # Load the last imported game and update UI
        sc_game load $lastGameNum
        flipBoardForPlayerNames
        ::notify::DatabaseModified $::clipbase_db
        ::notify::GameChanged

        # Refresh gamelist window if open for clipbase
        foreach glwin $::windows::gamelist::wins {
            if {[info exists ::gamelistBase($glwin)] && $::gamelistBase($glwin) == $::clipbase_db} {
                ::windows::gamelist::Refresh 1 [list $glwin]
                ::win::makeVisible $glwin
                break
            }
        }

        if {$importedCount > 1} {
            tk_messageBox -icon info -type ok -title "scidCommunity" \
                -message [format [tr RtfImportSuccessMulti] $importedCount]
        } else {
            tk_messageBox -icon info -type ok -title "scidCommunity" \
                -message [tr RtfImportSuccess]
        }
    }

    # -----------------------------------------------------------------------
    # RTF header parsers
    # -----------------------------------------------------------------------
    proc extractFontTable_ {rtf} {
        set fonts {}
        if {[regexp {\x7b\\fonttbl((?:[^\x7b\x7d]|\x7b[^\x7b\x7d]*\x7d)*)\x7d} $rtf -> ftbl]} {
            set rest $ftbl
            while {[regexp {\x7b\\f([0-9]+)([^;]*);\x7d(.*)} $rest -> fi content rest]} {
                set fam [string trim $content]
                regsub -all {\\[a-zA-Z0-9]+[ ]?} $fam {} fam
                set fam [string trim $fam " \t\n\r;\\"]
                while {[llength $fonts] <= [expr {int($fi)}]} { lappend fonts "" }
                lset fonts [expr {int($fi)}] $fam
            }
        }
        if {[llength $fonts] == 0} {
            set defaultFamily "Helvetica"
            catch { set defaultFamily [font actual font_Regular -family] }
            set fonts [list $defaultFamily]
        }
        return $fonts
    }

    proc extractColorTable_ {rtf} {
        set colors {}
        if {[regexp {\x7b\\colortbl ([^\x7d]*)\x7d} $rtf -> ctbl]} {
            set entries [split $ctbl ";"]
            foreach entry $entries {
                set entry [string trim $entry]
                if {$entry eq ""} { continue }
                set r 0; set g 0; set b 0
                regexp {\\red([0-9]+)}   $entry -> r
                regexp {\\green([0-9]+)} $entry -> g
                regexp {\\blue([0-9]+)}  $entry -> b
                lappend colors [format "#%02x%02x%02x" $r $g $b]
            }
        }
        if {[llength $colors] == 0} { set colors {"#000000"} }
        return $colors
    }

    proc extractPgnTags_ {body} {
        # 1. Check for exact embedded PGN tags from {\*\scidtags ...}
        if {[regexp {\x7b\\\*\\scidtags[ \n\r]+([^\x7d]+)\x7d} $body -> rawTags]} {
            set tags [string trim [rtfUnescape $rawTags]]
            if {$tags ne ""} { return $tags }
        }

        # 2. Fall back to parsing Tag: Value lines from the header
        set knownTags {Event Site Date Round White Black Result WhiteElo BlackElo ECO}
        set pgn ""
        set header [string range $body 0 3000]
        set plain  [rtfToPlain_ $header]
        foreach line [split $plain "\n"] {
            set line [string trim $line]
            foreach tag $knownTags {
                set prefix "$tag: "
                if {[string match "${prefix}*" $line]} {
                    set val [string range $line [string length $prefix] end]
                    append pgn "\[$tag \"[string trim $val]\"\]\n"
                    break
                }
            }
        }
        if {$pgn eq ""} {
            append pgn "\[Event \"?\"\]\n\[Site \"?\"\]\n\[Date \"????.??.??\"\]\n"
            append pgn "\[Round \"?\"\]\n\[White \"?\"\]\n\[Black \"?\"\]\n\[Result \"*\"\]\n"
        }
        return $pgn
    }

    proc rtfToPlain_ {rtf} {
        regsub -all {\x7b\\[*][^\x7b\x7d]*\x7d} $rtf {} rtf
        set rtf [rtfUnescape $rtf]
        regsub -all {\\[a-zA-Z]+(-?[0-9]*)[ ]?} $rtf {} rtf
        regsub -all {[\x7b\x7d\\]} $rtf {} rtf
        return [string trim $rtf]
    }

    proc extractMoves_ {body fontTable colorTable} {
        set pgn ""
        set tokens [tokenizeRtf_ $body]
        set nTokens [llength $tokens]
        set i 0
        set inMoves 0
        set defaultSizePt 11

        while {$i < $nTokens} {
            set tok [lindex $tokens $i]
            incr i

            # Skip embedded pictures (board diagrams).
            if {[string first "\\pict" $tok] == 1} { continue }

            set plain [string trim [rtfToPlain_ $tok]]

            if {[string match "*SCID_MOVES_BEGIN*" $plain]} {
                set inMoves 1
                if {[regexp {\\fs([0-9]+)} $tok -> fsVal]} {
                    set defaultSizePt [expr {int($fsVal) / 2}]
                }
                continue
            }
            if {!$inMoves} { continue }

            if {[string match "*SCID_COMMENT_BEGIN*" $plain]} {
                set commentRtf ""
                while {$i < $nTokens} {
                    set ctok [lindex $tokens $i]
                    incr i
                    set cplain [string trim [rtfToPlain_ $ctok]]
                    if {[string match "*SCID_COMMENT_END*" $cplain]} { break }
                    append commentRtf $ctok
                }
                set markup [rtfRunsToMarkup $commentRtf $fontTable $colorTable $defaultSizePt]
                # Replace right braces so they do not terminate the PGN comment
                # (the PGN lexer treats the first literal right brace as the
                # comment end and does not honour backslash escapes).
                set markup [string map [list "\x7b" "\uff5b" "\x7d" "\uff5d"] $markup]
                append pgn " {$markup}"
            } elseif {$plain ne "" && ![string match "*SCID_*" $plain]} {
                set convertedTok [symbolToNag $plain]
                append pgn " $convertedTok"
            }
        }
        return [string trim $pgn]
    }

    # Simple RTF tokenizer: splits into {group} tokens and bare text lines
    proc tokenizeRtf_ {rtf} {
        set tokens {}
        set pos 0
        set len [string length $rtf]
        set buf ""

        while {$pos < $len} {
            set ch [string index $rtf $pos]
            if {$ch eq "\x7b"} {
                if {$buf ne ""} { lappend tokens $buf; set buf "" }
                set depth 1
                set start $pos
                incr pos
                while {$pos < $len && $depth > 0} {
                    set c [string index $rtf $pos]
                    if {$c eq "\\"} {
                        incr pos 2
                        continue
                    }
                    if {$c eq "\x7b"} { incr depth }
                    if {$c eq "\x7d"} { incr depth -1 }
                    incr pos
                }
                lappend tokens [string range $rtf $start [expr {$pos-1}]]
            } elseif {$ch eq "\n" || $ch eq "\r"} {
                if {$buf ne ""} { lappend tokens $buf; set buf "" }
                incr pos
            } else {
                append buf $ch
                if {$ch eq "\\"} {
                    set next [string index $rtf [expr {$pos + 1}]]
                    if {$next eq "\x7b" || $next eq "\x7d" || $next eq "\\"} {
                        append buf $next
                        incr pos 2
                    } else {
                        incr pos
                    }
                } else {
                    incr pos
                }
            }
        }
        if {$buf ne ""} { lappend tokens $buf }
        return $tokens
    }

}
### End of file/rtf.tcl
