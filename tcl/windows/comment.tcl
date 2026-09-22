############################################################
### Comment Editor window
# Copyright (C) 2016 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

namespace eval ::windows::commenteditor {
	variable isOpen 0
	variable w_ .commentWin
	variable needNotify_ 0
	variable undoComment_ 1
	variable undoNAGs_ 1
	variable timeH 0
	variable timeM 10
	variable timeS 0
	variable timeTotal 10
	array set prevSecs {white 360001 black 360001}
	array set lastTime {white {0 10 0 10} black {0 10 0 10}}

	variable pendingStyle_ {0 0 0 "" "" ""}
	variable styleIds_ 0
	variable typingStart_ ""
	variable typingPending_ 0
	variable renderInProgress_ 0
	variable fontFamilyDlg_ ""
	variable fontSizeDlg_ ""
	variable presetColors_ {Green #008000 Blue #0000CD Red #FF0000 Brown #A0522D}
	array set styleById_ {}
	array set idByStyle_ {}
	array set fontCache_ {}

	proc clearComment_ {} {
		if {[sc_pos getComment] != ""} {
			undoFeature save
			sc_pos setComment ""
			set ::windows::commenteditor::needNotify_ 1
		}
		notify_ idle
	}

	proc clearNAGs_ {} {
		if {[sc_pos getNags] != 0} {
			undoFeature save
			sc_pos clearNags
			set ::windows::commenteditor::needNotify_ 1
		}
		notify_ idle
	}

	proc notify_ {wait} {
		if {$::windows::commenteditor::needNotify_} {
			after cancel "::notify::PosChanged pgnonly"
			after $wait "::notify::PosChanged pgnonly"
		}
	}

	proc notifyCancel_ {} {
		after cancel "::notify::PosChanged pgnonly"
	}

	proc storeComment_ {} {
		variable w_
		variable renderInProgress_
		variable typingStart_
		variable typingPending_
		variable pendingStyle_
		if {$renderInProgress_} { return }
		if {![$w_.cf.txtframe.text edit modified]} { return }

		if {$typingPending_} {
			set typingPending_ 0
			if {$pendingStyle_ ne [defaultStyle_]} {
				set start $typingStart_
				set end [$w_.cf.txtframe.text index insert]
				if {[$w_.cf.txtframe.text compare $start < $end]} {
					$w_.cf.txtframe.text tag add [ensureTag_ $w_.cf.txtframe.text $pendingStyle_] $start $end
				}
			}
		}

		# The "end-1c" below is because Tk adds a newline to text contents:
		set oldComment [sc_pos getComment]
		set newComment [serializeComment_ $w_.cf.txtframe.text]
		if {"$oldComment" ne "$newComment"} {
			variable undoComment_
			if { $undoComment_ } {
				set undoComment_ 0
				undoFeature save
			}
			sc_pos setComment $newComment
			set ::windows::commenteditor::needNotify_ 1
		}
		notify_ 1500
		$w_.cf.txtframe.text edit modified false
	}

	proc storeNAGs_ {} {
		variable w_
		set nag_stored [sc_pos getNags]
		set nag_text [$w_.nf.text get]
		#sc_pos getNags returns 0 when empty
		if {$nag_text == ""} { set nag_text 0 }
		if {"$nag_text" ne "$nag_stored"} {
			variable undoNAGs_
			if { $undoNAGs_ } {
				set undoNAGs_ 0
				undoFeature save
			}
			sc_pos clearNags
			foreach {nag} [split "$nag_text" " "] {
				sc_pos addNag $nag
			}
			set ::windows::commenteditor::needNotify_ 1
		}
		notify_ 1500
	}

	proc updateFromTotal_ {} {
		variable timeTotal
		variable timeH
		variable timeM
		variable timeS
		if {![string is double -strict $timeTotal]} { return }
		set totalSeconds [expr {int($timeTotal * 60)}]
		set timeH [expr {$totalSeconds / 3600}]
		set timeM [expr {($totalSeconds % 3600) / 60}]
		set timeS [expr {$totalSeconds % 60}]
	}

	proc updateFromHHMMSS_ {} {
		variable timeTotal
		variable timeH
		variable timeM
		variable timeS
		if {![string is integer -strict $timeH]} { set timeH 0 }
		if {![string is integer -strict $timeM]} { set timeM 0 }
		if {![string is integer -strict $timeS]} { set timeS 0 }
		set timeTotal [expr {($timeH * 3600 + $timeM * 60 + $timeS) / 60.0}]
	}

	proc focusTimeEntry_ {} {
		variable w_
		if {![winfo exists $w_.nf.time.em]} { return }
		focus $w_.nf.time.em
		$w_.nf.time.em selection range 0 end
		$w_.nf.time.em icursor end
	}

	proc submitTime_ {} {
		variable w_
		variable timeH
		variable timeM
		variable timeS
		variable lastTime
		
		# Determine which player just moved
		set side [sc_pos side]
		if {$side eq "black"} { set p "white" } else { set p "black" }

		# Ensure integer values
		if {![string is integer -strict $timeH]} { set timeH 0 }
		if {![string is integer -strict $timeM]} { set timeM 0 }
		if {![string is integer -strict $timeS]} { set timeS 0 }

		set lastTime($p) [list $timeH $timeM $timeS [expr {($timeH * 3600 + $timeM * 60 + $timeS) / 60.0}]]
		
		set clk [format "\[%%clk %02d:%02d:%02d\]" $timeH $timeM $timeS]
		set txt $w_.cf.txtframe.text
		set current [$txt get 1.0 end-1c]
		if {[string length $current] > 0} {
			$txt insert 1.0 "$clk "
		} else {
			$txt insert 1.0 "$clk"
		}
		$txt edit modified true
		storeComment_

		# Cancel pending delayed notifications; we'll trigger a full update
		notifyCancel_

		# Advance to the next ply and refresh everything
		if {![sc_pos isAt end] && ![sc_pos isAt vend]} {
			sc_move forward
			::notify::PosChanged -pgn -animate
		} else {
			# At end of game/variation: still refresh PGN to show the new comment
			::notify::PosChanged pgnonly
		}

		# Focus the minutes entry for rapid keyboard-driven time entry
		after idle [list ::windows::commenteditor::focusTimeEntry_]
	}

	proc defaultStyle_ {} {
		return [list 0 0 0 "" "" ""]
	}

	proc styleGet_ {style dim} {
		lassign $style b i u color family size
		switch -- $dim {
			b      { return $b }
			i      { return $i }
			u      { return $u }
			color  { return $color }
			family { return $family }
			size   { return $size }
		}
		return ""
	}

	proc styleSetAttr_ {style dim value} {
		lassign $style b i u color family size
		switch -- $dim {
			b      { set b $value }
			i      { set i $value }
			u      { set u $value }
			color  { set color $value }
			family { set family $value }
			size   { set size $value }
		}
		return [list $b $i $u $color $family $size]
	}

	proc styleMerge_ {base add} {
		lassign $base b i u color family size
		lassign $add ab ai au acolor afamily asize
		if {$ab} { set b 1 }
		if {$ai} { set i 1 }
		if {$au} { set u 1 }
		if {$acolor ne ""} { set color $acolor }
		if {$afamily ne ""} { set family $afamily }
		if {$asize ne ""} { set size $asize }
		return [list $b $i $u $color $family $size]
	}

	proc escapeText_ {text} {
		return [string map {& &amp; < &lt; > &gt; "\"" &quot;} $text]
	}

	proc unescapeText_ {text} {
		return [string map {&lt; < &gt; > &quot; "\"" &amp; &} $text]
	}

	proc openTags_ {style} {
		lassign $style b i u color family size
		set s ""
		if {$b} { append s "<b>" }
		if {$i} { append s "<i>" }
		if {$u} { append s "<u>" }
		if {$color ne "" || $family ne "" || $size ne ""} {
			set attrs ""
			if {$color ne ""} { append attrs "color:$color;" }
			if {$family ne ""} { append attrs "font-family:$family;" }
			if {$size ne ""} { append attrs "font-size:${size}pt;" }
			append s "<span style=\"[string trimright $attrs]\">"
		}
		return $s
	}

	proc closeTags_ {style} {
		lassign $style b i u color family size
		set s ""
		if {$color ne "" || $family ne "" || $size ne ""} { append s "</span>" }
		if {$u} { append s "</u>" }
		if {$i} { append s "</i>" }
		if {$b} { append s "</b>" }
		return $s
	}

	proc tagToStyle_ {tag} {
		set color ""; set family ""; set size ""
		if {[regexp {^span\s+style="(.*)"$} $tag -> attrs]} {
			foreach pair [split $attrs ";"] {
				set pair [string trim $pair]
				if {$pair eq ""} { continue }
				set c [string first ":" $pair]
				if {$c < 0} { continue }
				set k [string trim [string range $pair 0 [expr {$c - 1}]]]
				set v [string trim [string range $pair [expr {$c + 1}] end]]
				switch -exact -- $k {
					color       { set color $v }
					font-family { set family $v }
					font-size   {
						if {[regexp {^([0-9.]+)(pt)?$} $v -> sz]} { set size $sz }
					}
				}
			}
		}
		return [list 0 0 0 $color $family $size]
	}

	proc parseMarkup_ {text} {
		set runs {}
		set style [defaultStyle_]
		set stack {}
		set buf ""
		set pos 0
		set len [string length $text]
		while {1} {
			set lt [string first "<" $text $pos]
			if {$lt < 0} {
				append buf [string range $text $pos end]
				break
			}
			append buf [string range $text $pos [expr {$lt - 1}]]
			set gt [string first ">" $text [expr {$lt + 1}]]
			if {$gt < 0} {
				append buf [string range $text $lt end]
				break
			}
			set tag [string range $text [expr {$lt + 1}] [expr {$gt - 1}]]
			set pos [expr {$gt + 1}]
			set isOpen -1
			set isClose -1
			switch -regexp -- $tag {
				{^b$}      { set isOpen b }
				{^/b$}     { set isClose b }
				{^i$}      { set isOpen i }
				{^/i$}     { set isClose i }
				{^u$}      { set isOpen u }
				{^/u$}     { set isClose u }
				{^span\s}  { set isOpen span }
				{^/span$}  { set isClose span }
			}
			if {$isOpen ne -1} {
				if {$buf ne ""} { lappend runs [list [unescapeText_ $buf] $style]; set buf "" }
				lappend stack $style
				set add [list 0 0 0 "" "" ""]
				switch -- $isOpen {
					b    { set add [list 1 0 0 "" "" ""] }
					i    { set add [list 0 1 0 "" "" ""] }
					u    { set add [list 0 0 1 "" "" ""] }
					span { set add [tagToStyle_ $tag] }
				}
				set style [styleMerge_ $style $add]
			} elseif {$isClose ne -1} {
				if {$buf ne ""} { lappend runs [list [unescapeText_ $buf] $style]; set buf "" }
				if {[llength $stack] > 0} {
					set style [lindex $stack end]
					set stack [lrange $stack 0 end-1]
				}
			} else {
				append buf "<$tag>"
			}
		}
		if {$buf ne ""} { lappend runs [list [unescapeText_ $buf] $style] }
		return $runs
	}

	proc styleFont_ {style} {
		variable fontCache_
		variable styleIds_
		lassign $style b i u color family size
		if {$family eq ""} { set family [font actual font_Regular -family] }
		if {$size eq ""} { set size [font actual font_Regular -size] }
		set weight normal
		if {$b} { set weight bold }
		set slant roman
		if {$i} { set slant italic }
		set fkey [join [list $family $size $weight $slant] \x1F]
		if {![info exists fontCache_($fkey)]} {
			set fname "commenteditorfont_[incr styleIds_]"
			font create $fname -family $family -size $size -weight $weight -slant $slant
			set fontCache_($fkey) $fname
		}
		return $fontCache_($fkey)
	}

	proc tagForStyle_ {style} {
		variable idByStyle_
		variable styleById_
		variable styleIds_
		set key [join $style \x1F]
		if {![info exists idByStyle_($key)]} {
			set id [incr styleIds_]
			set idByStyle_($key) $id
			set styleById_($id) $style
		}
		return "st$idByStyle_($key)"
	}

	proc ensureTag_ {t style} {
		set tag [tagForStyle_ $style]
		lassign $style b i u color family size
		$t tag configure $tag -font [styleFont_ $style]
		if {$color ne ""} { $t tag configure $tag -foreground $color }
		if {$u} { $t tag configure $tag -underline 1 }
		return $tag
	}

	proc styleAt_ {t index} {
		variable styleById_
		foreach tag [$t tag names $index] {
			if {[string match "st*" $tag]} {
				set id [string range $tag 2 end]
				if {[info exists styleById_($id)]} { return $styleById_($id) }
			}
		}
		return [defaultStyle_]
	}

	proc serializeComment_ {t} {
		set out ""
		set cur [defaultStyle_]
		set started 0
		foreach {k v index} [$t dump -text 1.0 end-1c] {
			if {$k ne "text"} { continue }
			set st [styleAt_ $t $index]
			if {!$started} {
				append out [openTags_ $st]
				set cur $st
				set started 1
			} elseif {$st ne $cur} {
				append out [closeTags_ $cur]
				append out [openTags_ $st]
				set cur $st
			}
			append out [escapeText_ $v]
		}
		if {$started} { append out [closeTags_ $cur] }
		return $out
	}

	proc renderComment_ {t markup} {
		variable renderInProgress_
		set renderInProgress_ 1
		$t configure -state normal
		$t delete 1.0 end
		foreach run [parseMarkup_ $markup] {
			lassign $run text style
			$t insert end $text [list [ensureTag_ $t $style]]
		}
		$t edit modified false
		set renderInProgress_ 0
	}

	proc getSelection_ {t} {
		if {[catch {set s [$t tag ranges sel]}]} { return "" }
		if {[llength $s] != 2} { return "" }
		set start [lindex $s 0]
		set end [lindex $s 1]
		if {[$t compare $start == $end]} { return "" }
		return [list $start $end]
	}

	proc selectionHasAttr_ {t start end dim} {
		foreach {k v index} [$t dump -text $start $end] {
			if {$k ne "text"} { continue }
			if {![styleGet_ [styleAt_ $t $index] $dim]} { return 0 }
		}
		return 1
	}

	proc applyStyleAttr_ {t start end dim value} {
		foreach {k v index} [$t dump -text $start $end] {
			if {$k ne "text"} { continue }
			set newst [styleSetAttr_ [styleAt_ $t $index] $dim $value]
			set e [$t index "$index + [string length $v] chars"]
			foreach tag [$t tag names $index] {
				if {[string match "st*" $tag]} { $t tag remove $tag $index $e }
			}
			$t tag add [ensureTag_ $t $newst] $index $e
		}
		$t edit modified true
		storeComment_
	}

	proc toggleStyle_ {dim} {
		variable w_
		variable pendingStyle_
		set t $w_.cf.txtframe.text
		set sel [getSelection_ $t]
		if {$sel eq ""} {
			set pendingStyle_ [styleSetAttr_ $pendingStyle_ $dim [expr {! [styleGet_ $pendingStyle_ $dim]}]]
			return
		}
		lassign $sel start end
		set val [expr {! [selectionHasAttr_ $t $start $end $dim]}]
		applyStyleAttr_ $t $start $end $dim $val
		set pendingStyle_ [styleAt_ $t $start]
	}

	proc setStyleDim_ {dim value} {
		variable w_
		variable pendingStyle_
		set t $w_.cf.txtframe.text
		set sel [getSelection_ $t]
		if {$sel eq ""} {
			set pendingStyle_ [styleSetAttr_ $pendingStyle_ $dim $value]
			return
		}
		lassign $sel start end
		applyStyleAttr_ $t $start $end $dim $value
		set pendingStyle_ [styleAt_ $t $start]
	}

	proc removeFormatting_ {} {
		variable w_
		variable pendingStyle_
		set t $w_.cf.txtframe.text
		set def [defaultStyle_]
		set sel [getSelection_ $t]
		if {$sel eq ""} {
			set pendingStyle_ $def
			return
		}
		lassign $sel start end
		foreach {k v index} [$t dump -text $start $end] {
			if {$k ne "text"} { continue }
			set e [$t index "$index + [string length $v] chars"]
			foreach tag [$t tag names $index] {
				if {[string match "st*" $tag]} { $t tag remove $tag $index $e }
			}
		}
		$t edit modified true
		storeComment_
		set pendingStyle_ $def
	}

	proc colorSwatchImage_ {color} {
		set name "cswatch[regsub -all {#} $color {}]"
		if {![catch {image type $name}]} { return $name }
		image create photo $name -width 12 -height 12
		$name put $color -to 0 0 12 12
		return $name
	}

	proc chooseColor_ {} {
		variable w_
		variable presetColors_
		set t $w_.cf.txtframe.text
		set m $t.colormenu
		if {![winfo exists $m]} {
			menu $m -tearoff 0
			foreach {label color} $presetColors_ {
				$m add command -label "[tr $label]" -image [colorSwatchImage_ $color] -compound left \
					-command "::windows::commenteditor::setStyleDim_ color $color"
			}
			$m add separator
			$m add command -label "[tr CustomColor]" -command "::windows::commenteditor::chooseCustomColor_"
		}
		tk_popup $m [winfo pointerx $t] [winfo pointery $t]
	}

	proc chooseCustomColor_ {} {
		variable w_
		variable pendingStyle_
		set t $w_.cf.txtframe.text
		set sel [getSelection_ $t]
		if {$sel eq ""} { set init [styleGet_ $pendingStyle_ color] } else { set init [styleGet_ [styleAt_ $t [lindex $sel 0]] color] }
		if {$init eq ""} { set init "#000000" }
		set color [tk_chooseColor -title "scidCommunity" -initialcolor $init -parent $w_]
		if {$color eq ""} { return }
		setStyleDim_ color $color
	}

	proc chooseFont_ {} {
		variable w_
		variable pendingStyle_
		variable fontFamilyDlg_
		variable fontSizeDlg_
		set t $w_.cf.txtframe.text
		set sel [getSelection_ $t]
		if {$sel eq ""} { set st $pendingStyle_ } else { set st [styleAt_ $t [lindex $sel 0]] }
		set fontFamilyDlg_ [styleGet_ $st family]
		set fontSizeDlg_ [styleGet_ $st size]
		if {$fontFamilyDlg_ eq ""} { set fontFamilyDlg_ [font actual font_Regular -family] }
		if {$fontSizeDlg_ eq ""} { set fontSizeDlg_ [font actual font_Regular -size] }
		set dlg .commentFontDlg
		if {[winfo exists $dlg]} { destroy $dlg }
		toplevel $dlg
		wm title $dlg "[tr CommentFont]"
		wm transient $dlg $w_
		ttk::frame $dlg.f -padding 8
		ttk::label $dlg.f.lf -text "[tr Family]"
		ttk::combobox $dlg.f.ef -width 24 -textvariable ::windows::commenteditor::fontFamilyDlg_ \
			-values [lsort [font families]]
		ttk::label $dlg.f.ls -text "[tr Size]"
		ttk::entry $dlg.f.es -width 6 -textvariable ::windows::commenteditor::fontSizeDlg_
		ttk::frame $dlg.b
		ttk::button $dlg.b.ok -text [tr OK] -command "::windows::commenteditor::applyFont_ $dlg"
		ttk::button $dlg.b.cancel -text [tr Cancel] -command "destroy $dlg"
		grid $dlg.f.lf -row 0 -column 0 -sticky w
		grid $dlg.f.ef -row 0 -column 1 -sticky w
		grid $dlg.f.ls -row 1 -column 0 -sticky w -pady {5 0}
		grid $dlg.f.es -row 1 -column 1 -sticky w -pady {5 0}
		grid $dlg.f -sticky nsew
		grid $dlg.b.ok $dlg.b.cancel -padx 4
		grid $dlg.b -pady {8 0}
		setWinLocation $dlg
		after idle [list focus $dlg.f.ef]
	}

	proc applyFont_ {dlg} {
		variable fontFamilyDlg_
		variable fontSizeDlg_
		if {![string is integer -strict $fontSizeDlg_] || $fontSizeDlg_ <= 0} {
			tk_messageBox -parent $dlg -icon warning -type ok -title "scidCommunity" -message "[tr FontSizeWarning]"
			return
		}
		destroy $dlg
		setStyleDim_ family $fontFamilyDlg_
		setStyleDim_ size $fontSizeDlg_
	}

	proc showFormatMenu_ {t} {
		set m $t.formatmenu
		if {![winfo exists $m]} {
			menu $m -tearoff 0
			$m add command -label "[tr Bold]" -accelerator "Ctrl+B" -command "::windows::commenteditor::toggleStyle_ b"
			$m add command -label "[tr Italic]" -accelerator "Ctrl+I" -command "::windows::commenteditor::toggleStyle_ i"
			$m add command -label "[tr Underline]" -accelerator "Ctrl+U" -command "::windows::commenteditor::toggleStyle_ u"
			$m add separator
			$m add command -label "[tr TextColor]" -accelerator "Ctrl+R" -command "::windows::commenteditor::chooseColor_"
			$m add command -label "[tr CommentFont]" -accelerator "Ctrl+F" -command "::windows::commenteditor::chooseFont_"
			$m add separator
			$m add command -label "[tr RemoveFormatting]" -command "::windows::commenteditor::removeFormatting_"
		}
		tk_popup $m [winfo pointerx $t] [winfo pointery $t]
	}

	proc onTypeStart_ {t char} {
		variable typingStart_
		variable typingPending_
		set typingPending_ 0
		if {$char ne ""} {
			set typingStart_ [$t index insert]
			set typingPending_ 1
		}
	}

	proc markupToHtml {comment} {
		set out ""
		foreach run [parseMarkup_ $comment] {
			lassign $run text style
			append out [openTags_ $style]
			append out [string map {"\n" "<br />"} [::html::html_entities $text]]
			append out [closeTags_ $style]
		}
		return $out
	}
}

proc ::windows::commenteditor::createWin { {focus_if_exists 1} } {
	variable w_

	if {! [::win::createWindow $w_ [tr {WindowsComment}] 530x220]} {
		if { $focus_if_exists } {
			::win::makeVisible $w_
			focus $w_.cf.txtframe.text
		} else {
			::win::closeWindow $w_
		}
		return
	}

	# NAGs frame:
	ttk::frame $w_.nf
	ttk::label $w_.nf.label -font font_Bold -text [tr AnnotationSymbols]
	ttk::button $w_.nf.clear -text [tr Clear] -command "::windows::commenteditor::clearNAGs_"
	ttk::entry $w_.nf.text
	ttk::frame $w_.nf.b
	set i 0
	foreach {nag description} {
		!! ExcellentMove
		! GoodMove
		!? InterestingMove
		?! DubiousMove
		? PoorMove
		?? Blunder
		N Novelty
		+-- WhiteCrushing
		+- WhiteDecisiveAdvantage
		+/- WhiteClearAdvantage
		+= WhiteSlightAdvantage
		= Equality
		D Diagram
		--+ BlackCrushing
		-+ BlackDecisiveAdvantage
		-/+ BlackClearAdvantage
		=+ BlackSlightAdvantage
		~ Unclear
	} {
		ttk::button $w_.nf.b.b$i -text "$nag" -width 3 -command "::addNag $nag"
		::utils::tooltip::Set $w_.nf.b.b$i [tr $description]
		grid $w_.nf.b.b$i -column [expr {$i % 6}] -row [expr {int($i / 6)}] -padx 1 -pady 1
		incr i
	}
	grid columnconfig $w_.nf 0 -weight 1
	grid columnconfig $w_.nf 2 -weight 1
	grid $w_.nf.label $w_.nf.clear x -sticky nsew
	grid $w_.nf.text -sticky nsew -columnspan 3
	grid $w_.nf.b -sticky nsew -columnspan 2 -row 2 -column 0

	# Time Entry frame:
	ttk::labelframe $w_.nf.time -text "Time Entry" -padding 5
	ttk::label $w_.nf.time.lh -text "H"
	ttk::entry $w_.nf.time.eh -width 3 -textvariable ::windows::commenteditor::timeH
	ttk::label $w_.nf.time.lm -text "M"
	ttk::entry $w_.nf.time.em -width 3 -textvariable ::windows::commenteditor::timeM
	ttk::label $w_.nf.time.ls -text "S"
	ttk::entry $w_.nf.time.es -width 3 -textvariable ::windows::commenteditor::timeS
	
	ttk::label $w_.nf.time.lt -text "Total minutes"
	ttk::entry $w_.nf.time.et -width 6 -textvariable ::windows::commenteditor::timeTotal

	ttk::button $w_.nf.time.sub -text "Submit" -command "::windows::commenteditor::submitTime_"

	grid $w_.nf.time.lh $w_.nf.time.eh $w_.nf.time.lm $w_.nf.time.em $w_.nf.time.ls $w_.nf.time.es -padx 1 -sticky w
	grid $w_.nf.time.lt -column 0 -row 1 -columnspan 3 -sticky w -pady {5 0}
	grid $w_.nf.time.et -column 3 -row 1 -columnspan 3 -sticky w -pady {5 0}
	grid $w_.nf.time.sub -column 0 -row 2 -columnspan 6 -sticky ew -pady {5 0}

	grid $w_.nf.time -row 2 -column 2 -sticky nsew -padx {5 0}

	bind $w_.nf.time.eh <KeyRelease> "::windows::commenteditor::updateFromHHMMSS_"
	bind $w_.nf.time.em <KeyRelease> "::windows::commenteditor::updateFromHHMMSS_"
	bind $w_.nf.time.es <KeyRelease> "::windows::commenteditor::updateFromHHMMSS_"
	bind $w_.nf.time.et <KeyRelease> "::windows::commenteditor::updateFromTotal_"
	bind $w_.nf.time.eh <Return> "::windows::commenteditor::submitTime_"
	bind $w_.nf.time.em <Return> "::windows::commenteditor::submitTime_"
	bind $w_.nf.time.es <Return> "::windows::commenteditor::submitTime_"
	bind $w_.nf.time.et <Return> "::windows::commenteditor::submitTime_"

	# Comment frame:
	ttk::frame $w_.cf
	ttk::label $w_.cf.label -font font_Bold -text [tr Comment]
	ttk::button $w_.cf.clear -text [tr Clear] -command "::windows::commenteditor::clearComment_"
	ttk::button $w_.cf.format -text [tr Format] -command "::windows::commenteditor::showFormatMenu_ $w_.cf.txtframe.text"
	autoscrollText y $w_.cf.txtframe $w_.cf.txtframe.text Treeview
	$w_.cf.txtframe.text configure -wrap word -state normal
	grid rowconfig $w_.cf 1 -weight 1
	grid columnconfig $w_.cf 0 -weight 1
	grid $w_.cf.label -row 0 -column 0 -sticky w
	grid $w_.cf.clear -row 0 -column 1 -sticky e -padx 2
	grid $w_.cf.format -row 0 -column 2 -sticky e -padx 2
	grid $w_.cf.txtframe -sticky nsew -columnspan 3


	# Arrange frames:
	grid $w_.cf -row 0 -column 0 -columnspan 2 -sticky nsew
	grid $w_.nf -row 1 -column 0 -columnspan 2 -sticky nsew
	grid rowconfig $w_ 0 -weight 1
	grid columnconfig $w_ 0 -weight 1

	# Load current NAGs and comment
	Refresh

	# Add bindings at the end
	bind $w_ <Destroy> "if {\[string equal $w_ %W\]} { set ::windows::commenteditor::isOpen 0; ::windows::commenteditor::notify_ 1 }"
	bind $w_.nf.text <KeyPress>   "::windows::commenteditor::notifyCancel_"
	bind $w_.nf.text <KeyRelease> "::windows::commenteditor::storeNAGs_"
	bind $w_.cf.txtframe.text <KeyPress>   "::windows::commenteditor::notifyCancel_; ::windows::commenteditor::onTypeStart_ %W %A"
	bind $w_.cf.txtframe.text <KeyRelease> "::windows::commenteditor::notify_ 1000"
	bind $w_.cf.txtframe.text <<Modified>> "::windows::commenteditor::storeComment_"

	bind $w_.cf.txtframe.text <Control-b> "::windows::commenteditor::toggleStyle_ b; break"
	bind $w_.cf.txtframe.text <Control-i> "::windows::commenteditor::toggleStyle_ i; break"
	bind $w_.cf.txtframe.text <Control-u> "::windows::commenteditor::toggleStyle_ u; break"
	bind $w_.cf.txtframe.text <Control-r> "::windows::commenteditor::chooseColor_; break"
	bind $w_.cf.txtframe.text <Control-f> "::windows::commenteditor::chooseFont_; break"

	set ::windows::commenteditor::isOpen 1
	$w_.cf.txtframe.text edit modified false
	after idle focus $w_.cf.txtframe.text
}

# Gets the comment and NAGs for the current position and updates the
# corresponding widgets.
# Disables NAGs widgets if at vstart (NAGs cannot be inserted before moves).
proc ::windows::commenteditor::Refresh {} {
	variable w_
	if {![winfo exists $w_]} { return }

	::windows::commenteditor::notifyCancel_
	variable needNotify_ 0
	variable undoNAGs_ 1
	variable undoComment_ 1
	variable pendingStyle_

	set pendingStyle_ [::windows::commenteditor::defaultStyle_]

	set comment [sc_pos getComment]
	if {$comment != [::windows::commenteditor::serializeComment_ $w_.cf.txtframe.text]} {
		::windows::commenteditor::renderComment_ $w_.cf.txtframe.text $comment
	}
	$w_.cf.txtframe.text edit modified false

	set nag [sc_pos getNags]
	$w_.nf.text configure -state normal
	$w_.nf.text delete 0 end
	if {$nag != "0"} {
		$w_.nf.text insert end $nag
	}
	# if at vstart, disable NAG codes and reset clock
	if {[sc_pos isAt vstart]} {
		set state "disabled"
		set ::windows::commenteditor::prevSecs(white) 360001
		set ::windows::commenteditor::prevSecs(black) 360001
		set ::windows::commenteditor::lastTime(white) {0 10 0 10}
		set ::windows::commenteditor::lastTime(black) {0 10 0 10}
		set ::windows::commenteditor::timeH 0
		set ::windows::commenteditor::timeM 10
		set ::windows::commenteditor::timeS 0
		set ::windows::commenteditor::timeTotal 10
	} else	{
		set state "normal"
		# Determine which player just moved
		set side [sc_pos side]
		if {$side eq "black"} { set p "white" } else { set p "black" }
		lassign $::windows::commenteditor::lastTime($p) ::windows::commenteditor::timeH ::windows::commenteditor::timeM ::windows::commenteditor::timeS ::windows::commenteditor::timeTotal
	}
	$w_.nf.clear configure -state $state
	$w_.nf.text configure -state $state
	foreach c [winfo children $w_.nf.b] {
		$c configure -state $state
	}
}

proc makeCommentWin {{toggle ""}} {
	::windows::commenteditor::createWin [string compare "$toggle" "toggle"]
}
