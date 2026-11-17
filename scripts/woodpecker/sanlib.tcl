# Shared SAN -> UCI helpers for the Woodpecker probe scripts (needs ::chessboard).
# ---- SAN -> UCI against ::chessboard's legal moves ---------------------------
proc sanToUci {pos san} {
    set s [string map {+ "" # "" ! "" ? ""} $san]
    set side [dict get $pos side]
    set legal [::chessboard::legalMoves $pos]
    if {$s eq "O-O" || $s eq "O-O-O"} {
        set r [expr {$side eq "w" ? 1 : 8}]
        set to [expr {$s eq "O-O" ? "g$r" : "c$r"}]
        foreach m $legal { if {$m eq "e$r$to"} { return $m } }
        error "no castle $san"
    }
    set promo ""
    if {[regexp {^(.*)=([QRBN])$} $s -> s p]} { set promo [string tolower $p] }
    set piece P
    if {[string match {[KQRBN]*} $s]} { set piece [string index $s 0]; set s [string range $s 1 end] }
    set s [string map {x ""} $s]
    set dest [string range $s end-1 end]
    set dis [string range $s 0 end-2]
    set board [dict get $pos board]
    set hits {}
    foreach m $legal {
        if {[string range $m 2 3] ne $dest} continue
        if {[string length $m] > 4 && [string index $m 4] ne $promo} continue
        if {[string length $m] == 4 && $promo ne ""} continue
        set from [string range $m 0 1]
        set pc [string toupper [lindex $board [::chessboard::sqIndex $from]]]
        if {$pc ne $piece} continue
        if {$dis ne "" && [string first $dis $from] < 0} {
            # disambiguation: file, rank or both must appear in the from-square
            set ok 1
            foreach ch [split $dis ""] { if {[string first $ch $from] < 0} { set ok 0 } }
            if {!$ok} continue
        }
        lappend hits $m
    }
    if {[llength $hits] != 1} { error "SAN $san ambiguous/unknown: $hits" }
    return [lindex $hits 0]
}

proc fenAfterPgn {pgn plies} {
    set pos [::chessboard::fromFen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"]
    set i 0
    foreach san $pgn {
        if {$i >= $plies} break
        set pos [::chessboard::makeMove $pos [sanToUci $pos $san]]
        incr i
    }
    return [::chessboard::toFen $pos]
}

