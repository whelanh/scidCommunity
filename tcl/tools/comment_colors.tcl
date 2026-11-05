# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# comment_colors.tcl -- where a generated comment's provenance is written.
#
# The comment editor stores formatting inside the comment itself as
# <span style="..."> markup, so a colour written here is read by the comment
# window, the PGN window and the RTF export, and plain PGN export strips it
# (src/game.cpp). Game Review's verdicts are green and the coach's prose is
# blue; text the reader writes carries no span and shows in ::pgnColor(Comment).
#
# The colours are per writer, not per text shape. A coach phase line, a coach
# moment and the coach's Summary/Level/Opening block are all blue because
# ::reviewcoach wrote them, not because of a marker they happen to carry; the
# report block and the move verdicts are green because the review wrote them.
#
# Stripping has to know about the wrapper: a generated line is one span around
# the whole line, so removing the line removes the span too.
# ::commentcolors::stripEmpty clears a wrapper left behind when only the text
# inside it was removed (a re-review of a verdict, say).

namespace eval ::commentcolors {
    # The review's verdicts: the same green the comment editor offers as its
    # Green preset, so a reader can recolour one and stay in the palette.
    variable reviewColor "#008000"
    # The coach's prose. This blue is chosen to read on the dark themes (#1e1e2e)
    # as well as the light ones; no single blue reaches 4.5:1 on both, and this
    # one is 4.46:1 on the darkest bundled background.
    variable coachColor "#3B82F6"

    # The comment editor's markup escapes these four characters; a span has to
    # carry the same escaping or its text is parsed as tags.
    proc escape {text} {
        return [string map {& &amp; < &lt; > &gt; "\"" &quot;} $text]
    }

    proc wrap {color text} {
        if {$text eq ""} { return "" }
        return "<span style=\"color:$color\">[escape $text]</span>"
    }

    proc wrapReview {text} {
        variable reviewColor
        return [wrap $reviewColor $text]
    }

    proc wrapCoach {text} {
        variable coachColor
        return [wrap $coachColor $text]
    }

    # Wrap each line separately. Leading whitespace stays outside the span so
    # the report's indented continuation lines still begin with their indent,
    # which is what ::reviewreport::stripHeader anchors on.
    proc wrapLines {color text} {
        set out {}
        foreach line [split $text "\n"] {
            if {[regexp {^([ \t]*)(.*)$} $line -> lead rest] && $rest ne ""} {
                lappend out "$lead[wrap $color $rest]"
            } else {
                lappend out $line
            }
        }
        return [join $out "\n"]
    }

    proc wrapReviewLines {text} {
        variable reviewColor
        return [wrapLines $reviewColor $text]
    }

    proc wrapCoachLines {text} {
        variable coachColor
        return [wrapLines $coachColor $text]
    }

    # A wrapper whose text was removed by a token strip is not content. Remove
    # it so a second review does not grow the comment with empty spans.
    proc stripEmpty {text} {
        return [regsub -all {<span[^>]*>\s*</span>} $text ""]
    }

    # Remove one generated line, wrapped (this writer's output) or plain (a
    # comment written before the colours existed). The plain pass is what keeps
    # an old game reviewable.
    proc stripLine {text pattern} {
        set out [regsub -all "<span\[^>\]*>$pattern</span>" $text ""]
        set out [regsub -all $pattern $out ""]
        return [stripEmpty $out]
    }
}
