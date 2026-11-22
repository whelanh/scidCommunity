# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later
#
# lang_registry.tcl -- the interface languages this tree ships.
#
#   source [file join $root tests tcl lang_registry.tcl]
#
# tcl/language.tcl is the one list of languages: every addLanguage line names
# the letter the catalogue uses and the file it lives in. Harnesses that have
# to cover every catalogue read that list instead of keeping a copy, so adding
# a language changes the program and its translation file, not the tests.

# Returns {letter file} pairs in the order the Language menu shows them.
proc languageCatalogues {root} {
    set fh [open [file join $root tcl language.tcl] r]
    fconfigure $fh -encoding utf-8
    set text [read $fh]
    close $fh
    set catalogues {}
    foreach {_ letter file} [regexp -all -inline \
            {addLanguage\s+(\S+)\s+\S+\s+\d+\s+\S+\s+(\S+\.tcl)} $text] {
        lappend catalogues [list $letter $file]
    }
    if {[llength $catalogues] == 0} {
        error "no addLanguage entries found in tcl/language.tcl"
    }
    return $catalogues
}

# The catalogue filenames alone, sorted, for comparing against a directory.
proc languageFiles {root} {
    set files {}
    foreach pair [languageCatalogues $root] {
        lappend files [lindex $pair 1]
    }
    return [lsort $files]
}
