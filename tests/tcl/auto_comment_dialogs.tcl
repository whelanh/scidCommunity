# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# auto_comment_dialogs.tcl -- build the Auto Comment dialogs under real Tk.
#
#   wish tests/tcl/auto_comment_dialogs.tcl
#   xvfb-run -a wish tests/tcl/auto_comment_dialogs.tcl   (no display)
#
# The provider harness cannot see layout: it stubs Tk. This one creates the
# widgets and switches through every provider, which is what caught "none"
# matching no section at all and leaving the dialog with no body.
#
# The scid environment is stubbed; nothing here touches a database, an engine
# or the network. Window geometry is not asserted: the size a top-level ends up
# with is the window manager's business, and Wayland compositors ignore wm
# geometry entirely.

set fails 0
set checks 0
proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} { puts "  FAIL $label" } else { puts "  FAIL $label -- $detail" }
    }
}
proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}

# --------------------------------------------------------------- environment --
proc options.store {varname {default ""}} {
    if {![info exists $varname]} { set $varname $default }
}
set ::savedCount 0
set ::saveResult 1
set ::messages {}
# The real options.write returns 1 when it wrote, 0 when it reported a failed
# open itself, and throws only if the write breaks part-way.
proc options.write {} {
    incr ::savedCount
    if {$::saveResult eq "error"} { error "disk full" }
    return $::saveResult
}
proc openURL {url} { set ::openedUrl $url }
set ::boxes {}
proc tk_messageBox {args} {
    lappend ::messages [dict get $args -message]
    lappend ::boxes $args
    return ok
}
set ::language E
set ::translatePieces 0

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools auto_comment.tcl]

proc visibleSections {w} {
    set out {}
    foreach n {note local ollama openai opencode gemini deepseek} {
        set f $w.content.$n
        if {[winfo exists $f] && [winfo ismapped $f]} { lappend out $n }
    }
    return $out
}

# ------------------------------------------------------------ settings dialog --
puts "\n== settings dialog =="
::auto_comment::configureApiKey
update
set w .autoCommentConfig
check "dialog is built" [winfo exists $w]

foreach p {none local ollama openai opencode gemini deepseek} {
    set ::auto_comment::provider $p
    if {[catch {::auto_comment::syncProviderSections $w} err]} {
        check "$p switches without a Tk error" 0 $err
        continue
    }
    update
    set expect [expr {$p eq "none" ? "note" : $p}]
    checkEq "$p shows its section" [visibleSections $w] [list $expect]
}

# the heading and the provider selector are always present
check "provider combo is always shown" [expr {[winfo ismapped $w.content.provider]}]
check "the dialog has a body below the selector" \
    [expr {[llength [visibleSections $w]] == 1}]

# switching through the combobox binding, not just by calling the proc: the
# widget carries the label, and selecting it stores the id
set ::auto_comment::provider none
::auto_comment::syncProviderCombo $w.content.provider
::auto_comment::syncProviderSections $w
update
checkEq "the combo shows the stored provider's label" \
    [$w.content.provider get] [::auto_comment::providerLabel none]
check "the labels are what the combo offers" \
    [expr {[$w.content.provider cget -values] eq [::auto_comment::providerLabels]}] \
    [$w.content.provider cget -values]
$w.content.provider set [::auto_comment::providerLabel opencode]
event generate $w.content.provider <<ComboboxSelected>>
update
checkEq "combobox event switches sections" [visibleSections $w] {opencode}
checkEq "and stores the id, not the label" $::auto_comment::provider opencode
check "opencode section has a key field" [expr {[winfo exists $w.content.opencode.key]}]
check "opencode section has a model field" [expr {[winfo exists $w.content.opencode.model]}]
check "opencode section offers models" \
    [expr {[llength [$w.content.opencode.model cget -values]] > 0}] \
    [$w.content.opencode.model cget -values]

# Ollama Cloud is a named channel, so the base URL is not something the user
# types: the section has a key and a model, and no endpoint field at all.
set ::auto_comment::provider ollama
::auto_comment::syncProviderSections $w
update
checkEq "ollama cloud shows its section" [visibleSections $w] {ollama}
check "ollama cloud has a key field" [expr {[winfo exists $w.content.ollama.key]}]
check "ollama cloud has no endpoint field to get wrong" \
    [expr {![winfo exists $w.content.ollama.url]}]
check "ollama cloud offers models" \
    [expr {[llength [$w.content.ollama.model cget -values]] > 0}] \
    [$w.content.ollama.model cget -values]

# ------------------------------------------- the two Ollama channels -----------------
# The stored ids are "local" and "ollama", which is the same product name twice.
# What tells a user which is the server on this machine and which is the hosted
# service is the combo label and the section: one asks for an endpoint and no
# key, the other asks for a key and has no endpoint to get wrong.
puts "\n== the two Ollama channels are told apart =="
set labels [$w.content.provider cget -values]
checkEq "seven labels, one per provider" [llength $labels] 7
check "the local channel is labelled local" \
    [expr {[lsearch -exact $labels {Ollama - local server}] >= 0}] $labels
check "the hosted channel is labelled Ollama Cloud" \
    [expr {[lsearch -exact $labels {Ollama Cloud (hosted)}] >= 0}] $labels
check "the two labels are different" \
    [expr {[lsearch -exact $labels {Ollama - local server}] \
        ne [lsearch -exact $labels {Ollama Cloud (hosted)}]}]

$w.content.provider set {Ollama Cloud (hosted)}
event generate $w.content.provider <<ComboboxSelected>>
update
checkEq "picking the cloud label stores ollama" $::auto_comment::provider ollama
checkEq "and shows the Ollama Cloud section" [visibleSections $w] {ollama}
check "the cloud section asks for a key" [expr {[winfo exists $w.content.ollama.key]}]
check "the cloud section has no endpoint field" \
    [expr {![winfo exists $w.content.ollama.url]}]

$w.content.provider set {Ollama - local server}
event generate $w.content.provider <<ComboboxSelected>>
update
checkEq "picking the local label stores local" $::auto_comment::provider local
checkEq "and shows the local section" [visibleSections $w] {local}
check "the local section asks for an endpoint" [expr {[winfo exists $w.content.local.url]}]
check "the local section asks for no key" [expr {![winfo exists $w.content.local.key]}]

# ------------------------------------------------- a failed Load Models ------
# The warning used to be parented to the main window. On Windows that activates
# it, and the Game Comment dialog is transient to it, so the settings dialog the
# user was typing in dropped behind the dialog it was opened from: "Load Models"
# looked like it threw the settings away. The box belongs to the dialog now.
puts "\n== a failed Load Models keeps the settings dialog in front =="
# The Ollama section asks ::auto_comment::fetchOllamaModels, not the generic
# fetcher: stubbing only the latter left this test talking to ollama.com, which
# has a live model list and therefore no warning to check. On a runner with
# network the assertion failed; the harness must decide the answer itself.
rename ::auto_comment::fetchUrlModels ::real_fetchUrlModels
proc ::auto_comment::fetchUrlModels {args} { return {} }
rename ::auto_comment::fetchOllamaModels ::real_fetchOllamaModels
proc ::auto_comment::fetchOllamaModels {} { return {} }
set ::boxes {}
set ::messages {}
::auto_comment::loadModels $w.content.ollama.model ollama
update
check "the settings dialog is still open" [winfo exists $w]
check "the warning was shown" [expr {[llength $::boxes] == 1}] $::boxes
checkEq "and it belongs to the settings dialog" \
    [dict get [lindex $::boxes 0] -parent] $w

# ------------------------------------------------------- staying on the screen --
# The switch resizes the dialog in place, so the position it already has is the
# one it grows from. A user who left the dialog near the bottom edge would lose
# the OK row below the screen, and on a small display the tallest section is
# already close to the usable height. Both are capped the way fitWindow caps a
# new dialog.
puts "\n== a switch near the bottom edge keeps the OK row on the screen =="
set scrH [winfo screenheight $w]
set scrW [winfo screenwidth $w]
wm geometry $w "[winfo width $w]x[winfo height $w]+40+[expr {$scrH - [winfo height $w] - 60}]"
update
check "the dialog starts out above the bottom edge" \
    [expr {[winfo rooty $w] + [winfo height $w] <= $scrH}] \
    "top [winfo rooty $w] height [winfo height $w] screen $scrH"

foreach p {opencode openai gemini none} {
    set ::auto_comment::provider $p
    ::auto_comment::syncProviderSections $w
    update
    set bottom [expr {[winfo rooty $w] + [winfo height $w]}]
    check "the $p switch keeps the dialog above the bottom edge" \
        [expr {$bottom <= $scrH - 40}] "bottom $bottom screen $scrH"
    check "the $p switch keeps the dialog inside the screen height" \
        [expr {[winfo height $w] <= $scrH - 80}] \
        "height [winfo height $w] screen $scrH"
    check "the $p switch keeps the dialog inside the screen width" \
        [expr {[winfo width $w] <= $scrW - 40}] \
        "width [winfo width $w] screen $scrW"
}
# and back to a middle position: the ordinary case must not be moved around
set ::auto_comment::provider none
::auto_comment::syncProviderSections $w
update
wm geometry $w "[winfo width $w]x[winfo height $w]+40+[expr {int(($scrH - [winfo height $w]) / 2)}]"
update
set before [winfo rooty $w]
set ::auto_comment::provider opencode
::auto_comment::syncProviderSections $w
update
checkEq "a switch that fits does not move the dialog" [winfo rooty $w] $before

# ------------------------------------ moving an existing setup to a channel --
# A user who has a Gemini key stored must be able to pick another provider
# without losing it: the provider list is the path, and the keys are per
# provider.
puts "\n== an existing Gemini setup can move to another channel =="
set ::auto_comment::provider gemini
set ::auto_comment::apiKey "stored-gemini-key"
set ::auto_comment::openaiKey ""
set ::auto_comment::openaiModel ""
::auto_comment::syncProviderSections $w
update
checkEq "it starts on the stored provider" [visibleSections $w] {gemini}

set ::auto_comment::provider openai
$w.content.provider set [::auto_comment::providerLabel openai]
event generate $w.content.provider <<ComboboxSelected>>
update
checkEq "picking openai shows the openai section" [visibleSections $w] {openai}

set ::auto_comment::openaiUrl "https://api.deepseek.com"
set ::auto_comment::openaiKey "new-key"
set ::auto_comment::openaiModel "glm-5.3-flash"
set ::savedCount 0
set ::saveResult 1
::auto_comment::saveSettings $w
update
check "the dialog closed" [expr {![winfo exists $w]}]
checkEq "the provider that was saved is the new one" $::auto_comment::provider openai
checkEq "the Gemini key is still there" $::auto_comment::apiKey {stored-gemini-key}
checkEq "the new channel kept its own key" $::auto_comment::openaiKey {new-key}

# ---------------------------------------------------------------- saving ------
puts "\n== OK saves and closes =="
::auto_comment::configureApiKey
update
set ::auto_comment::provider opencode
set ::auto_comment::opencodeKey "secret"
set ::savedCount 0
set ::saveResult 1
::auto_comment::saveSettings $w
update
check "options.write ran" [expr {$::savedCount == 1}] "count $::savedCount"
check "the dialog closed" [expr {![winfo exists $w]}]

# A refused write must not take the typed key with it. options.write has
# already told the user, so the dialog adds nothing and stays open.
puts "\n== a failed save keeps the dialog and its values =="
::auto_comment::configureApiKey
update
set ::auto_comment::provider opencode
set ::auto_comment::opencodeKey "typed-but-unsaved"
set ::saveResult 0
set ::savedCount 0
set ::messages {}
::auto_comment::saveSettings $w
update
check "options.write was asked once" [expr {$::savedCount == 1}] "count $::savedCount"
check "the dialog stayed open" [winfo exists $w]
check "the key is still there" \
    [expr {$::auto_comment::opencodeKey eq "typed-but-unsaved"}] $::auto_comment::opencodeKey
check "no second complaint" [expr {[llength $::messages] == 0}] $::messages

# An unexpected error keeps it open too, and says why.
set ::saveResult "error"
set ::messages {}
::auto_comment::saveSettings $w
update
check "the dialog stayed open after an error" [winfo exists $w]
check "the user was told once" [expr {[llength $::messages] == 1}] $::messages
destroy $w

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
