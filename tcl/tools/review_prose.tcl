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
# No PGN writing here; the caller decides where the text lands
# (::reviewcoach::place).

namespace eval ::reviewprose {
    variable job {}
    variable cache [dict create]
    # A run's identity. A reply carries the id it was asked under, so an answer
    # that arrives after its run was cancelled - or after the next run started -
    # cannot be recorded against a question it never answered.
    variable seq 0
}

# Clean what a model wrote before it is stored. auto_comment already normalises
# markdown and SAN in finishReply/cleanupText; this adds the review's own rules:
# one paragraph's worth of text, no surrounding quotes, no runaway length.
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

# ::reviewprose::run
#   Ask the provider every prompt in `prompts`, in order, one at a time. Answers
#   are keyed by {kind key prompt}, so a second review of the same game in the
#   same session is served from the cache. Returns 1 when the queue started, 0
#   when one was already running.
#
#   onProgress is called as {*}$cmd <done> <total> <kind> <key> <text> <error>
#   - "0 of N" before the first request, so a caller that is counting has
#   something to say while the model thinks.
#   onDone is called as {*}$cmd <results> <errors> <cancelled>.
proc ::reviewprose::run {prompts onProgress onDone} {
    variable job
    variable seq
    if {[dict size $job] && [dict get $job active]} { return 0 }
    incr seq
    set job [dict create id $seq prompts $prompts index 0 results {} errors {} \
        active 1 cancelled 0 token "" onProgress $onProgress onDone $onDone]
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
    set id [dict get $job id]
    set i [dict get $job index]
    set prompts [dict get $job prompts]
    if {$i >= [llength $prompts]} {
        ::reviewprose::finish
        return
    }
    set item [lindex $prompts $i]
    set key [cacheKey $item]
    if {[dict exists $cache $key]} {
        ::reviewprose::record $id $item [dict get $cache $key] ""
        return
    }
    # The callback is bound to the run and to the item it was asked for: a reply
    # for the wrong question, or for a run that is over, is not recorded.
    set cb [list apply {{id item args} {
        ::reviewprose::reply $id $item {*}$args
    }} $id $item]
    set token [::auto_comment::queryAsync [dict get $item prompt] \
        [expr {[dict exists $item max] ? [dict get $item max] : 300}] $cb]
    dict set job token $token
    return
}

proc ::reviewprose::reply {id item args} {
    variable job
    if {![dict size $job] || ![dict get $job active]} { return }
    if {[dict get $job id] ne $id} { return }
    # A cancelled run discards what the model says next, whatever the channel
    # does: killing the child is best-effort on both platforms, and on Windows a
    # curl the fallback cannot reach still answers. The reply is refused here, at
    # the point where it would become prose, not merely ignored one layer down.
    if {[dict get $job cancelled]} { return }
    set text [join $args " "]
    if {[string match "ERROR:*" $text]} {
        ::reviewprose::record $id $item "" [string range $text 6 end]
        return
    }
    ::reviewprose::record $id $item [clean $text] ""
    return
}

proc ::reviewprose::record {id item text err} {
    variable job
    variable cache
    if {![dict size $job] || ![dict get $job active]} { return }
    if {[dict get $job id] ne $id} { return }
    if {[dict get $job cancelled]} { return }
    # Only the question that is outstanding can be answered. An out-of-order or
    # repeated reply must not advance the queue: one question, one answer.
    set i [dict get $job index]
    set prompts [dict get $job prompts]
    if {$i >= [llength $prompts] || [lindex $prompts $i] ne $item} { return }
    set key [cacheKey $item]
    set results [dict get $job results]
    set errors [dict get $job errors]
    if {$text ne ""} {
        dict set results $key $text
        dict set cache $key $text
    }
    if {$err ne ""} { dict set errors $key $err }
    set done [expr {$i + 1}]
    set total [llength $prompts]
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

# Drop the queue. What has already been answered stays in `results` and onDone
# sees it: prose that arrived is part of a game that was written, and throwing it
# away would lose work the model was paid for.
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
    if {![dict size $job]} {
        return [dict create active 0 done 0 total 0 cancelled 0]
    }
    return [dict create active [dict get $job active] \
        done [dict get $job index] total [llength [dict get $job prompts]] \
        cancelled [dict get $job cancelled]]
}

proc ::reviewprose::clearCache {} {
    variable cache
    set cache [dict create]
    return
}
