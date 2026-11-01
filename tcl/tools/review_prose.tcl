# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# review_prose.tcl -- run the coach prompts without blocking the board.
#
# The prompts themselves come from review_coach.tcl; this is the queue. One
# request at a time, through ::auto_comment's provider, with progress, cancel
# and an in-session cache. A request that fails is dropped: prose is an extra,
# and a missing model must not cost the review.
#
# No PGN writing here; the caller decides where the text lands (step 5).

namespace eval ::reviewprose {
    variable job {}
    variable cache [dict create]
}

# Clean what a model wrote before it is stored. auto_comment already normalises
# markdown and SAN in finishReply/cleanupText; this adds the review's own rules:
# one paragraph, no surrounding quotes, no runaway length.
proc ::reviewprose::clean {text} {
    if {[llength [info commands ::auto_comment::cleanupText]]} {
        catch { set text [::auto_comment::cleanupText $text] }
    }
    # Typographic punctuation is mapped to ASCII before it reaches the PGN:
    # scid reads comments in the host codepage, so a UTF-8 em dash arrives as
    # mojibake. Accented letters are real text and are left alone.
    set q [format %c 34]
    set map [list [format %c 8212] - [format %c 8211] - [format %c 8216] ' \
        [format %c 8217] ' [format %c 8220] $q [format %c 8221] $q \
        [format %c 8230] ... [format %c 160] { }]
    set text [string map $map $text]
    set text [string trim $text]
    regsub {^["'“”]+} $text "" text
    regsub {["'“”]+$} $text "" text
    # Line structure is kept: the summary answers in three labelled lines, and
    # flattening them would fold LEVEL and OPENING into the summary. Runs of
    # blank lines collapse to one line break, and each line is trimmed.
    regsub -all {[ \t]+} $text " " text
    regsub -all {\s*\n\s*} $text "\n" text
    set text [join [lmap l [split $text "\n"] {string trim $l}] "\n"]
    set text [string trim $text]
    # A comment's brackets are structural: a model must not close our block or
    # open a token of its own.
    regsub -all {[\[\]]} $text "" text
    set text [string trim $text]
    if {[string length $text] > 600} { set text [string range $text 0 599] }
    return $text
}

proc ::reviewprose::cacheKey {item} {
    return [list [dict get $item kind] [dict get $item key] [dict get $item prompt]]
}

proc ::reviewprose::run {prompts onProgress onDone} {
    variable job
    if {[dict size $job] && [dict get $job active]} { return 0 }
    set job [dict create prompts $prompts index 0 results {} errors {} \
        active 1 cancelled 0 token "" onProgress $onProgress onDone $onDone]
    # "0 of N" before the first answer, not after it: the model may take a while
    # and a caller that is counting has nothing else to say in the meantime.
    if {$onProgress ne ""} {
        catch { {*}$onProgress 0 [llength $prompts] {} {} {} {} }
    }
    ::reviewprose::next
    return 1
}

proc ::reviewprose::next {} {
    variable job
    variable cache
    if {![dict size $job] || ![dict get $job active]} { return }
    set i [dict get $job index]
    set prompts [dict get $job prompts]
    if {$i >= [llength $prompts]} {
        ::reviewprose::finish
        return
    }
    set item [lindex $prompts $i]
    set key [cacheKey $item]
    if {[dict exists $cache $key]} {
        ::reviewprose::record $item [dict get $cache $key] ""
        return
    }
    set cb [list apply {{item args} {
        ::reviewprose::reply $item {*}$args
    }} $item]
    set token [::auto_comment::queryAsync [dict get $item prompt] \
        [expr {[dict exists $item max] ? [dict get $item max] : 500}] $cb]
    dict set job token $token
    return
}

proc ::reviewprose::reply {item args} {
    variable job
    if {![dict size $job] || ![dict get $job active]} { return }
    set text [join $args " "]
    if {[string match "ERROR:*" $text]} {
        ::reviewprose::record $item "" [string range $text 7 end]
        return
    }
    ::reviewprose::record $item [clean $text] ""
    return
}

proc ::reviewprose::record {item text err} {
    variable job
    variable cache
    if {![dict size $job] || ![dict get $job active]} { return }
    set key [cacheKey $item]
    set results [dict get $job results]
    set errors [dict get $job errors]
    if {$text ne ""} {
        dict set results $key $text
        dict set cache $key $text
    }
    if {$err ne ""} { dict set errors $key $err }
    set done [expr {[dict get $job index] + 1}]
    set total [llength [dict get $job prompts]]
    dict set job index $done
    dict set job results $results
    dict set job errors $errors
    set cb [dict get $job onProgress]
    if {$cb ne ""} {
        catch { {*}$cb $done $total [dict get $item kind] [dict get $item key] $text $err }
    }
    after 0 ::reviewprose::next
    return
}

proc ::reviewprose::finish {} {
    variable job
    if {![dict size $job]} { return }
    set results [dict get $job results]
    set errors [dict get $job errors]
    set cb [dict get $job onDone]
    set cancelled [dict get $job cancelled]
    set job {}
    if {$cb ne ""} { catch { {*}$cb $results $errors $cancelled } }
    return
}

proc ::reviewprose::cancel {} {
    variable job
    if {![dict size $job]} { return }
    dict set job cancelled 1
    dict set job active 0
    set token ""
    catch { set token [dict get $job token] }
    if {$token ne ""} { catch { ::auto_comment::cancelAsync $token } }
    ::reviewprose::finish
    return
}

proc ::reviewprose::status {} {
    variable job
    if {![dict size $job]} { return [dict create active 0 done 0 total 0] }
    return [dict create active [dict get $job active] \
        done [dict get $job index] total [llength [dict get $job prompts]] \
        cancelled [dict get $job cancelled]]
}

proc ::reviewprose::clearCache {} {
    variable cache
    set cache [dict create]
    return
}
