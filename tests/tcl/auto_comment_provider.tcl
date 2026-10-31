# Copyright (C) 2025-2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# auto_comment_provider.tcl -- Tk-free tests for the provider layer of
# tcl/tools/auto_comment.tcl.
#
#   tclsh tests/tcl/auto_comment_provider.tcl
#
# The transport, the URL joins, the auth decision and the reply/error parsing
# are pure functions once Tk is stubbed, so they can be checked without a
# display, a network or a model. Everything the dialogs add on top of them
# (packing, section switching, persistence) still needs one manual run.

set fails 0
set checks 0

proc check {label cond {detail ""}} {
    incr ::checks
    if {$cond} {
        puts "  ok   $label"
    } else {
        incr ::fails
        if {$detail eq ""} {
            puts "  FAIL $label"
        } else {
            puts "  FAIL $label -- $detail"
        }
    }
}

proc checkEq {label got want} {
    check $label [expr {$got eq $want}] "got '$got' want '$want'"
}

# --------------------------------------------------------------- environment --
# Stubs for the parts of scid that auto_comment.tcl touches at load time.
proc options.store {varname {default ""}} {
    if {![info exists $varname]} { set $varname $default }
}
namespace eval ttk {}
namespace eval ::auto_comment {}
proc winfo {args} { return 0 }
set ::boxes {}
proc tk_messageBox {args} { lappend ::boxes $args ; return ok }
proc raise {w} { set ::raisedWindow $w }
proc focus {args} { set ::focusedWindow $args }
proc ttk::label {args} {}
proc ttk::labelframe {args} {}
proc ttk::entry {args} {}
proc ttk::button {args} {}
proc ttk::combobox {args} {}
proc ttk::frame {args} {}
proc ttk::checkbutton {args} {}
proc pack {args} {}
proc bind {args} {}
proc font {{args ""}} { return "" }
proc openURL {args} {}
set ::language E
set ::translatePieces 0

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl tools auto_comment.tcl]

# A temp directory of our own, so the request-file test never writes into the
# shared one. It lives in the OS temp directory, not in the source tree, so an
# aborted run cannot leave junk behind in the repository.
set sysTmp [expr {[info exists ::env(TMPDIR)] ? $::env(TMPDIR) \
              : [info exists ::env(TEMP)] ? $::env(TEMP) : "/tmp"}]
set tmproot [file join $sysTmp "auto_comment_test_[pid]"]
catch {file delete -force $tmproot}
file mkdir $tmproot
set ::env(TMPDIR) $tmproot

# ------------------------------------------------------------- provider list --
puts "\n== provider list =="
checkEq "all seven providers" [::auto_comment::providerList] {none local ollama openai opencode gemini deepseek}
check "none first so a fresh install sends nothing" \
    [expr {[lindex [::auto_comment::providerList] 0] eq "none"}]

# ---------------------------------------------------------- provider labels --
# The combo shows a label and the options file keeps the id. The two Ollama
# channels are why: "local" and "ollama" are the same product name to anyone
# who does not already know that one is a server on this machine and the other
# is a hosted service.
puts "\n== provider labels =="
checkEq "one label per provider" [llength [::auto_comment::providerLabels]] 7
checkEq "the labels are all different" \
    [llength [lsort -unique [::auto_comment::providerLabels]]] 7
checkEq "the local channel says so" [::auto_comment::providerLabel local] {Ollama - local server}
checkEq "the hosted channel says so" [::auto_comment::providerLabel ollama] {Ollama Cloud (hosted)}
foreach id [::auto_comment::providerList] {
    checkEq "$id round-trips through its label" \
        [::auto_comment::providerFromLabel [::auto_comment::providerLabel $id]] $id
}
checkEq "a bare product name is not a provider" [::auto_comment::providerFromLabel Ollama] {}
checkEq "an empty label is not a provider" [::auto_comment::providerFromLabel ""] {}
# Picking a label stores the id, and only a label we wrote is accepted.
set ::auto_comment::provider none
checkEq "picking the local label stores local" \
    [::auto_comment::pickProvider {Ollama - local server}] local
checkEq "... and the variable holds the id" $::auto_comment::provider local
checkEq "picking the cloud label stores ollama" \
    [::auto_comment::pickProvider {Ollama Cloud (hosted)}] ollama
checkEq "... and the variable holds that id" $::auto_comment::provider ollama
set ::auto_comment::provider none
checkEq "an unknown label picks nothing" [::auto_comment::pickProvider {Some other model}] {}
checkEq "... and leaves the provider alone" $::auto_comment::provider none

# ----------------------------------------------------------------- readiness --
puts "\n== readiness =="
set ::auto_comment::provider none
checkEq "none is a refusal, not a failure" [::auto_comment::providerReady] {no model selected}

set ::auto_comment::provider ollama
set ::auto_comment::ollamaKey ""
set ::auto_comment::ollamaModel "deepseek-v4.1-flash:1017"
checkEq "ollama cloud needs its key" [::auto_comment::providerReady] {no Ollama Cloud key set}
set ::auto_comment::ollamaKey "k"
set ::auto_comment::ollamaModel ""
checkEq "ollama cloud needs its model" [::auto_comment::providerReady] {no Ollama model selected}
set ::auto_comment::ollamaModel "deepseek-v4.1-flash:1017"
checkEq "ollama cloud ready" [::auto_comment::providerReady] {}

set ::auto_comment::ollamaKey ""
checkEq "a keyless ollama request is refused before anything is sent" \
    [::auto_comment::query "hi" 50] "ERROR: no Ollama Cloud key set"
set ::auto_comment::ollamaKey "k"

set ::auto_comment::provider opencode
set ::auto_comment::opencodeKey ""
set ::auto_comment::opencodeModel "glm-5.3-flash"
checkEq "opencode needs its key" [::auto_comment::providerReady] {no OpenCode key set}
set ::auto_comment::opencodeKey "k"
set ::auto_comment::opencodeModel ""
checkEq "opencode needs its model" [::auto_comment::providerReady] {no OpenCode model selected}
set ::auto_comment::opencodeModel "glm-5.3-flash"
checkEq "opencode ready" [::auto_comment::providerReady] {}

set ::auto_comment::provider local
set ::auto_comment::localUrl "http://localhost:11434"
set ::auto_comment::localModel ""
checkEq "local needs a model" [::auto_comment::providerReady] {no local model selected}
set ::auto_comment::localModel "qwen3:8b"
checkEq "local ready and needs no key" [::auto_comment::providerReady] {}

set ::auto_comment::provider openai
set ::auto_comment::openaiUrl "https://api.deepseek.com"
set ::auto_comment::openaiModel ""
checkEq "openai needs a model" [::auto_comment::providerReady] {no model selected}
set ::auto_comment::openaiModel "deepseek-v4-pro"
checkEq "openai ready without a key" [::auto_comment::providerReady] {}

set ::auto_comment::provider bogus
checkEq "unknown provider is named" [::auto_comment::providerReady] "unknown provider: bogus"

# ------------------------------------------------------------------ endpoints --
puts "\n== endpoint joins =="
set ::auto_comment::provider openai
foreach {label url want} {
    "bare host"        "https://api.deepseek.com"                       "https://api.deepseek.com/v1/chat/completions"
    "trailing slash"   "https://api.deepseek.com/"                      "https://api.deepseek.com/v1/chat/completions"
    "with /v1"         "https://api.openai.com/v1"                      "https://api.openai.com/v1/chat/completions"
    "with /v1/"        "https://api.openai.com/v1/"                     "https://api.openai.com/v1/chat/completions"
    "pasted full URL"  "https://api.deepseek.com/v1/chat/completions"   "https://api.deepseek.com/v1/chat/completions"
    "pasted full URL/" "https://api.deepseek.com/v1/chat/completions/"  "https://api.deepseek.com/v1/chat/completions"
    "gemini root"      "https://generativelanguage.googleapis.com/v1beta/openai" \
                       "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
    "gemini full"      "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" \
                       "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
} {
    set ::auto_comment::openaiUrl $url
    checkEq "openai $label" [::auto_comment::chatEndpoint] $want
}

set ::auto_comment::provider opencode
checkEq "opencode endpoint" [::auto_comment::chatEndpoint] \
    {https://opencode.ai/inference/openai/v1/chat/completions}

set ::auto_comment::provider ollama
checkEq "ollama cloud speaks the native chat endpoint" [::auto_comment::chatEndpoint] \
    {https://ollama.com/api/chat}
checkEq "and its model list is api/tags" \
    "$::auto_comment::ollamaBase/tags" {https://ollama.com/api/tags}
check "ollama cloud offers default models" \
    [expr {[llength [::auto_comment::modelChoices ollama]] > 0}] \
    [::auto_comment::modelChoices ollama]

set ::auto_comment::provider local
set ::auto_comment::localUrl "http://localhost:11434/"
checkEq "local endpoint" [::auto_comment::chatEndpoint] {http://localhost:11434/api/chat}

puts "\n== model-list URLs =="
foreach {label url want} {
    "bare host"       "https://api.deepseek.com"                     "https://api.deepseek.com/v1/models"
    "with /v1"        "https://api.openai.com/v1"                    "https://api.openai.com/v1/models"
    "pasted endpoint" "https://api.deepseek.com/v1/chat/completions" "https://api.deepseek.com/v1/models"
    "local style"     "http://localhost:8000/v1"                     "http://localhost:8000/v1/models"
    "gemini root"     "https://generativelanguage.googleapis.com/v1beta/openai" \
                      "https://generativelanguage.googleapis.com/v1beta/openai/models"
} {
    checkEq "models for $label" [::auto_comment::modelsUrl $url] $want
}

puts "\n== model-list lookup targets =="
set t1 [::auto_comment::modelListTargets "https://api.deepseek.com" ]
checkEq "two targets, url and regex each" [llength $t1] 4
checkEq "first target is /v1/models" [lindex $t1 0] {https://api.deepseek.com/v1/models}
checkEq "its regex asks for ids" [lindex $t1 1] {"id"\s*:\s*"([^"]+)"}
checkEq "second target is the ollama path" [lindex $t1 2] {https://api.deepseek.com/api/tags}
checkEq "single target when a URL is given" \
    [llength [::auto_comment::modelListTargets "" "https://opencode.ai/inference/v1/models"]] 2
checkEq "the explicit URL is used verbatim" \
    [lindex [::auto_comment::modelListTargets "" "https://opencode.ai/inference/v1/models"] 0] \
    {https://opencode.ai/inference/v1/models}
checkEq "no base and no URL means nothing to try" [::auto_comment::modelListTargets ""] {}

# api/tags carries a capabilities list per model, which /v1/models does not.
# clef:27b is decision/vision only: offering it would only produce a failed chat
# request.
puts "\n== ollama cloud model list =="
set tags {{"models":[{"name":"glm-5.3","model":"glm-5.3","modified_at":"2026-10-06T06:00:00-07:00","size":0,"digest":"abc","details":{"parent_model":"","format":"","family":"","families":null,"parameter_size":"","quantization_level":""},"capabilities":["completion","thinking","tools"]},{"name":"clef:27b","model":"clef:27b","modified_at":"2026-10-06T06:00:00-07:00","size":0,"digest":"def","details":{"parent_model":"","format":"","family":"","families":null,"parameter_size":"","quantization_level":""},"capabilities":["decision","vision"]},{"name":"deepseek-v4.1-flash:1017","model":"deepseek-v4.1-flash:1017","modified_at":"2026-10-06T06:00:00-07:00","size":0,"digest":"ghi","details":{"parent_model":"","format":"","family":"","families":null,"parameter_size":"","quantization_level":""},"capabilities":["completion","thinking","tools","vision"]}]}}
checkEq "only models that can chat are offered" \
    [::auto_comment::parseOllamaTags $tags] {deepseek-v4.1-flash:1017 glm-5.3}
checkEq "a server without capabilities keeps every model" \
    [::auto_comment::parseOllamaTags {{"models":[{"name":"qwen3:8b","model":"qwen3:8b"}]}}] {qwen3:8b}
# ... but a list where every entry *was* parsed and every one filtered out stays
# empty: the fallback is for a shape the parser could not read, not for models
# that cannot answer a chat request. Offering clef:27b only produces a failure.
checkEq "a list with nothing that can chat stays empty" \
    [::auto_comment::parseOllamaTags {{"models":[{"name":"clef:27b","capabilities":["decision","vision"]}]}}] {}
checkEq "an unreadable shape still falls back to every name" \
    [::auto_comment::parseOllamaTags {{"models": [{"name": "qwen3:8b"}, {"name": "glm-5.3"}]}}] \
    {glm-5.3 qwen3:8b}
# The same document, pretty-printed, must go through the same filter: whitespace
# is not a different shape, and the all-names fallback does not look at
# capabilities.
set prettyTags {{"models": [
  {"name": "clef:27b", "capabilities": ["decision", "vision"]},
  {"name": "glm-5.3", "capabilities": ["completion", "thinking"]}
]}}
checkEq "whitespace does not bypass the capability filter" \
    [::auto_comment::parseOllamaTags $prettyTags] {glm-5.3}
checkEq "and a pretty list with nothing that can chat stays empty" \
    [::auto_comment::parseOllamaTags {{"models": [
  {"name": "clef:27b", "capabilities": ["decision", "vision"]}
]}}] {}
# Key order is not significant either: `model` often comes before `name`, and
# splitting on the object's first property sent that shape to the fallback.
checkEq "key order does not bypass the capability filter" \
    [::auto_comment::parseOllamaTags {{"models":[{"model":"clef:27b","name":"clef:27b","capabilities":["decision","vision"]},{"model":"glm-5.3","name":"glm-5.3","capabilities":["completion"]}]}}] \
    {glm-5.3}

# -------------------------------------------------------------------- request --
puts "\n== request bodies =="
set ::auto_comment::provider opencode
set ::auto_comment::opencodeModel "glm-5.3-flash"
set body [::auto_comment::chatBody {Say "hi"} 600]
check "opencode sends its own model" [string match {*"model":"glm-5.3-flash"*} $body] $body
check "opencode uses max_tokens" [string match {*"max_tokens":600*} $body] $body
check "prompt quotes escaped" [expr {[string first {Say \"hi\"} $body] >= 0}] $body

set ::auto_comment::provider openai
set ::auto_comment::openaiModel "deepseek-v4-pro"
set body [::auto_comment::chatBody "x" 300]
check "openai sends its own model" [string match {*"model":"deepseek-v4-pro"*} $body] $body

set ::auto_comment::provider local
set ::auto_comment::localModel "qwen3:8b"
set body [::auto_comment::chatBody "x" 300]
check "local uses num_predict" [string match {*"num_predict":300*} $body] $body
check "local body has no max_tokens" [expr {![string match {*max_tokens*} $body]}] $body

# A hosted Ollama model id carries a tag ("deepseek-v4.1-flash:1017"); the colon
# is part of the id and must reach the request untouched. The channel speaks the
# native API, so the budget is Ollama's num_predict, not max_tokens.
set ::auto_comment::provider ollama
set ::auto_comment::ollamaModel "deepseek-v4.1-flash:1017"
set body [::auto_comment::chatBody "x" 300]
check "ollama cloud sends its own model, tag included" \
    [string match {*"model":"deepseek-v4.1-flash:1017"*} $body] $body
check "ollama cloud uses the native body shape" \
    [string match {*"num_predict":300*} $body] $body
check "ollama cloud body has no max_tokens" \
    [expr {![string match {*max_tokens*} $body]}] $body
check "ollama cloud sends a bearer header" \
    [string match {*Bearer*} [::auto_comment::chatAuth]]

set ::auto_comment::provider opencode
checkEq "providerModel follows the provider" [::auto_comment::providerModel] "glm-5.3-flash"

# ----------------------------------------------------------------------- auth --
puts "\n== auth =="
set ::auto_comment::provider opencode
set ::auto_comment::opencodeKey "oc-key"
checkEq "opencode sends its key" [::auto_comment::chatAuth] {Authorization: Bearer oc-key}

set ::auto_comment::provider openai
set ::auto_comment::openaiKey "sk-key"
set ::auto_comment::openaiUrl "https://api.openai.com/v1"
checkEq "openai over https" [::auto_comment::chatAuth] {Authorization: Bearer sk-key}
set ::auto_comment::openaiUrl "http://10.0.0.5:8000"
checkEq "openai key never over cleartext" [::auto_comment::chatAuth] {}
set ::auto_comment::openaiUrl "http://127.0.0.1:8000"
checkEq "openai key allowed to loopback" [::auto_comment::chatAuth] {Authorization: Bearer sk-key}

set ::auto_comment::provider local
set ::auto_comment::localUrl "http://localhost:11434"
set ::auto_comment::localModel "m"
checkEq "local is never sent the cloud key" [::auto_comment::chatAuth] {}

# the guard that queryChat applies only to the openai provider, exercised here
# in isolation so the test never shells out to curl
set ::auto_comment::openaiUrl "http://10.0.0.5:8000"
set ::auto_comment::openaiKey "sk-key"
check "cleartext refused for a remote http endpoint" \
    [expr {[::auto_comment::cleartextKeyError $::auto_comment::openaiUrl $::auto_comment::openaiKey] ne ""}]

# --------------------------------------------------------------------- replies --
puts "\n== replies and errors =="
set openaiReply {{"id":"x","choices":[{"index":0,"message":{"role":"assistant","content":"Rook takes e5."},"finish_reason":"stop"}]}}
checkEq "openai reply" [::auto_comment::replyText $openaiReply] {Rook takes e5.}

set ollamaReply {{"model":"m","message":{"role":"assistant","content":"Castle early."},"done":true}}
checkEq "ollama reply" [::auto_comment::replyText $ollamaReply] {Castle early.}

set reasoner {{"choices":[{"message":{"role":"assistant","reasoning_content":"thinking about the pawn structure","content":"The knight goes to f3."}}]}}
checkEq "reasoning is not the answer" [::auto_comment::replyText $reasoner] {The knight goes to f3.}

# The hosted service answers in the native shape, with thinking in its own
# field: the answer is what gets written, never the reasoning.
set cloudReply {{"model":"deepseek-v4.1-flash:1017","created_at":"2026-10-06T06:00:00Z","message":{"role":"assistant","content":"The knight goes to f3.","thinking":"the pawn structure suggests"},"done":true,"done_reason":"stop","eval_count":42}}
checkEq "a native cloud reply keeps the answer, not the thinking" \
    [::auto_comment::replyText $cloudReply] {The knight goes to f3.}
checkEq "a native cloud error body is read" \
    [::auto_comment::replyError {{"error":"Unauthorized"}}] {Unauthorized}

checkEq "escapes decoded" \
    [::auto_comment::replyText {{"choices":[{"message":{"content":"line1\nline2 \"q\" and \\ slash"}}]}}] \
    "line1\nline2 \"q\" and \\ slash"

# A backslash escaped for JSON must survive as a backslash, not be re-read as
# an escape: this is what the string map in front of subst used to break.
checkEq "escaped backslash before n stays literal" \
    [::auto_comment::replyText {{"choices":[{"message":{"content":"path C:\\new here"}}]}}] \
    {path C:\new here}
checkEq "two escaped backslashes stay two" \
    [::auto_comment::replyText {{"choices":[{"message":{"content":"two \\\\ slashes"}}]}}] \
    {two \\ slashes}

checkEq "no error in a good reply" [::auto_comment::replyError $openaiReply] {}
checkEq "opencode auth error" \
    [::auto_comment::replyError {{"type":"error","error":{"type":"AuthError","message":"Missing API key."}}}] \
    {Missing API key.}
checkEq "deepseek error object" \
    [::auto_comment::replyError {{"error":{"message":"Insufficient Balance","type":"unknown_error"}}}] \
    {Insufficient Balance}
checkEq "bare string error" \
    [::auto_comment::replyError {{"error":"model not found"}}] {model not found}
check "unshaped error still explains itself" \
    [string match {API error:*} [::auto_comment::replyError {{"error":{"weird":true}}}]] \
    [::auto_comment::replyError {{"error":{"weird":true}}}]

checkEq "markdown stripped" \
    [::auto_comment::finishReply {{"choices":[{"message":{"content":"**Nf3** is best."}}]}}] \
    {Nf3 is best.}
checkEq "lowercase SAN repaired" \
    [::auto_comment::finishReply {{"choices":[{"message":{"content":"the knight goes nf3"}}]}}] \
    {the knight goes Nf3}

# --------------------------------------------- the key never rides in argv ----
puts "\n== auth goes to curl in a file, never in its arguments =="

# Replace exec so nothing leaves the machine, and record what curl would have
# been given. A key in argv is readable by any local user via ps or /proc.
#
# The transport asks curl for the body in a file (-o) and the status code on
# stdout (-w), so the stub does the same: $::fakeBody lands in the file and
# $::fakeStatus is what the command returns.
rename exec ::real_exec
set ::lastArgv {}
set ::lastCfg ""
set ::lastCfgText ""
set ::lastCfgMode 0
set ::fakeBody "{}"
set ::fakeStatus "200"
set ::fakeCurlVersion "curl 8.23.0 (x86_64-pc-linux-gnu)"
set ::fakeStderr ""
set ::fakeExecError ""
set ::lastOutFile ""
proc exec {args} {
    set ::lastArgv $args
    # post303Flag probes `curl --version`; answer with the fake version.
    if {[lsearch -exact $args --version] >= 0} { return $::fakeCurlVersion }
    # A per-target answer, for the runs where two targets must answer
    # differently: a local server that serves /api/tags and one that does not
    # are the same channel. The URL is the last http(s) word: a redirection
    # ("2>@1") can follow it, and it is not the target.
    set target ""
    foreach a $args {
        if {[regexp {^https?://} $a]} { set target $a }
    }
    set body $::fakeBody
    set fail $::fakeExecError
    set status $::fakeStatus
    if {[info exists ::fakeBodyFor($target)]} { set body $::fakeBodyFor($target) }
    if {[info exists ::fakeFailFor($target)]} { set fail $::fakeFailFor($target) }
    if {[info exists ::fakeStatusFor($target)]} { set status $::fakeStatusFor($target) }
    # --fail makes curl exit non-zero on a 4xx/5xx; the stub has to model it or
    # a test cannot tell a 404 body from an answer.
    if {[lsearch -exact $args --fail] >= 0 \
        && [string is integer -strict $status] && $status >= 400} {
        set fail "curl: (22) The requested URL returned error: $status"
    }
    set idx [lsearch -exact $args --config]
    if {$idx >= 0} {
        set ::lastCfg [lindex $args [expr {$idx + 1}]]
        if {![catch {
            set fh [open $::lastCfg r]
            set ::lastCfgText [read $fh]
            close $fh
            file stat $::lastCfg st
            set ::lastCfgMode [expr {$st(mode) & 0o777}]
        }]} {}
    }
    set eidx [lsearch -exact $args 2>]
    if {$eidx >= 0} {
        set fh [open [lindex $args [expr {$eidx + 1}]] w]
        puts -nonewline $fh $::fakeStderr
        close $fh
    }
    set oidx [lsearch -exact $args -o]
    if {$oidx >= 0} {
        set ::lastOutFile [lindex $args [expr {$oidx + 1}]]
        set fh [open $::lastOutFile w]
        puts -nonewline $fh $body
        close $fh
        # a non-zero curl exit is what Tcl turns into an error; the stub can
        # reproduce one, including the message Tcl appends to stdout
        if {$fail ne ""} { error $fail }
        return $::fakeStatus
    }
    # without -o curl writes the body to stdout, which is how the model-list
    # fetch reads it
    if {$fail ne ""} { error $fail }
    return $body
}

set ::auto_comment::provider openai
set ::auto_comment::openaiUrl "https://api.example.com"
set ::auto_comment::openaiKey "sk-secret-value"
set ::auto_comment::openaiModel "m"
set ::fakeBody {{"choices":[{"message":{"content":"Fine."}}]}}
set ::fakeStatus "200"
set ::lastArgv {}
set ::lastCfg ""
set ::reply [::auto_comment::queryChat "hi" 50]
checkEq "the request still returns its text" $reply {Fine.}
check "a config file carried the header" [expr {[lsearch -exact $::lastArgv --config] >= 0}] $::lastArgv
check "the key is not in argv" \
    [expr {[string first "sk-secret-value" [join $::lastArgv " "]] < 0}] $::lastArgv
checkEq "the config holds the bearer header" $::lastCfgText \
    "header = \"Authorization: Bearer sk-secret-value\"\n"
if {$::tcl_platform(platform) eq "windows"} {
    puts "  skip auth-file permissions are not a POSIX mode on this platform"
} else {
    checkEq "the auth file is owner-only" [format %04o $::lastCfgMode] 0600
}
check "the auth file is deleted after the request" \
    [expr {$::lastCfg ne "" && ![file exists $::lastCfg]}] $::lastCfg

# the OpenCode channel uses the same transport and must behave the same way
set ::auto_comment::provider opencode
set ::auto_comment::opencodeKey "oc-secret-value"
set ::auto_comment::opencodeModel "glm-5.3-flash"
set ::lastArgv {}
::auto_comment::queryChat "hi" 50
check "opencode key is not in argv" \
    [expr {[string first "oc-secret-value" [join $::lastArgv " "]] < 0}] $::lastArgv

# and so does the native DeepSeek path
set ::auto_comment::provider deepseek
set ::auto_comment::deepseekApiKey "ds-secret-value"
set ::auto_comment::deepseekModel "deepseek-v4-pro"
set ::lastArgv {}
::auto_comment::queryDeepSeek "hi"
check "deepseek key is not in argv" \
    [expr {[string first "ds-secret-value" [join $::lastArgv " "]] < 0}] $::lastArgv

# loading a model list sends the key too
set ::fakeBody {{"object":"list","data":[{"id":"model-a"},{"id":"model-b"}]}}
set ::lastArgv {}
set models [::auto_comment::fetchUrlModels "https://api.example.com" "sk-secret-value"]
checkEq "the model list came back" $models {model-a model-b}
check "the model-list key is not in argv" \
    [expr {[string first "sk-secret-value" [join $::lastArgv " "]] < 0}] $::lastArgv
check "the model-list auth file is deleted" \
    [expr {![file exists $::lastCfg]}] $::lastCfg

# the hosted channel asks api/tags, and its key stays out of argv like every other
set ::fakeBody $tags
set ::lastArgv {}
set ::auto_comment::ollamaKey "ollama-secret-value"
set models [::auto_comment::fetchOllamaModels]
checkEq "the hosted list is the chat-capable subset" $models {deepseek-v4.1-flash:1017 glm-5.3}
check "it asks api/tags" \
    [string match {*ollama.com/api/tags*} [join $::lastArgv { }]] $::lastArgv
check "the hosted key is not in argv" \
    [expr {[string first "ollama-secret-value" [join $::lastArgv { }]] < 0}] $::lastArgv
set ::auto_comment::ollamaKey ""

# ------------------------------------------ the local channel's own model list --
# The local channel speaks the same native API as the hosted one, so it asks
# /api/tags and keeps the same chat-capable subset. /v1/models is the list that
# would offer an embedding model the chat endpoint cannot use.
puts "\n== local channel model list =="
set ::auto_comment::localUrl "http://localhost:11434"
set ::fakeBody {{"models":[{"name":"qwen3:8b","capabilities":["completion","tools"]},{"name":"nomic-embed-text:latest","capabilities":["embedding"]},{"name":"glm-5.3","capabilities":["completion"]}]}}
set ::fakeStatus "200"
set ::lastArgv {}
lassign [::auto_comment::localModelList] localModels localTargets
checkEq "the local list drops what cannot chat" $localModels {glm-5.3 qwen3:8b}
checkEq "and only the native list was asked" $localTargets {http://localhost:11434/api/tags}
check "the request went to the local server" \
    [string match {*localhost:11434/api/tags*} [join $::lastArgv { }]] $::lastArgv
check "the local list never asks ollama.com" \
    [expr {[string first "ollama.com" [join $::lastArgv { }]] < 0}] $::lastArgv

# A local Ollama whose only models cannot chat has nothing to offer. The empty
# answer is the honest one: falling back to the unfiltered list would offer the
# embedding model again.
set ::fakeBody {{"models":[{"name":"nomic-embed-text:latest","capabilities":["embedding"]}]}}
lassign [::auto_comment::localModelList] localModels localTargets
checkEq "an Ollama with nothing that can chat stays empty" $localModels {}
checkEq "... and no fallback list was tried" $localTargets {http://localhost:11434/api/tags}

# LM Studio, vLLM and the like do not serve /api/tags at all: the generic list
# is used instead, and the failure warning can then name both paths.
unset -nocomplain ::fakeBodyFor ::fakeFailFor
set ::fakeFailFor(http://localhost:11434/api/tags) \
    "curl: (22) The requested URL returned error: 404"
set ::fakeBodyFor(http://localhost:11434/v1/models) \
    {{"object":"list","data":[{"id":"qwen3:8b"},{"id":"nomic-embed-text:latest"}]}}
lassign [::auto_comment::localModelList] localModels localTargets
checkEq "a server without api/tags falls back to /v1/models" \
    $localModels {nomic-embed-text:latest qwen3:8b}
checkEq "and the targets name both paths it tried" $localTargets \
    {http://localhost:11434/v1/models http://localhost:11434/api/tags}
unset -nocomplain ::fakeBodyFor ::fakeFailFor

# The same server answering /api/tags with a 404 body (not a curl error): with
# --fail that is a failed request, so the generic list is still tried. Without
# it curl exits 0 and the empty filtered list looked like an answer.
set ::fakeStatusFor(http://localhost:11434/api/tags) 404
set ::fakeBodyFor(http://localhost:11434/api/tags) {{"error":"not found"}}
set ::fakeBodyFor(http://localhost:11434/v1/models) \
    {{"object":"list","data":[{"id":"qwen3:8b"}]}}
lassign [::auto_comment::localModelList] localModels localTargets
checkEq "a 404 from api/tags still falls back" $localModels {qwen3:8b}
checkEq "and names both paths it tried" $localTargets \
    {http://localhost:11434/v1/models http://localhost:11434/api/tags}
unset -nocomplain ::fakeStatusFor ::fakeBodyFor

# A 200 that is not a tags list (a gateway's web UI answers unknown paths with
# HTML): the native list did not answer, so the generic one is still tried. A
# valid empty {"models":[]} is different and must not fall back.
set ::fakeStatusFor(http://localhost:11434/api/tags) 200
set ::fakeBodyFor(http://localhost:11434/api/tags) \
    {<!doctype html><html><body>not found</body></html>}
set ::fakeBodyFor(http://localhost:11434/v1/models) \
    {{"object":"list","data":[{"id":"qwen3:8b"}]}}
lassign [::auto_comment::localModelList] localModels localTargets
checkEq "a 200 that is not a tags list falls back" $localModels {qwen3:8b}
checkEq "and names both paths" $localTargets \
    {http://localhost:11434/v1/models http://localhost:11434/api/tags}
set ::fakeBodyFor(http://localhost:11434/api/tags) {{"models":[]}}
lassign [::auto_comment::localModelList] localModels localTargets
checkEq "a valid empty tags list does not fall back" $localModels {}
checkEq "and only the native list is named" $localTargets {http://localhost:11434/api/tags}
unset -nocomplain ::fakeStatusFor ::fakeBodyFor ::fakeFailFor

# The hosted channel must not read the local server's list, and the local one
# must not read ollama.com's: the two channels are separate settings.
set ::auto_comment::localUrl "http://127.0.0.1:11434"
set ::fakeBody {{"models":[{"name":"glm-5.3","capabilities":["completion"]}]}}
set ::lastArgv {}
::auto_comment::fetchOllamaModels
check "the hosted list asks ollama.com" \
    [string match {*ollama.com/api/tags*} [join $::lastArgv { }]] $::lastArgv
check "the hosted list never asks the local server" \
    [expr {[string first "127.0.0.1" [join $::lastArgv { }]] < 0}] $::lastArgv
set ::lastArgv {}
::auto_comment::localModelList
check "the local list asks the local server" \
    [string match {*127.0.0.1:11434/api/tags*} [join $::lastArgv { }]] $::lastArgv
check "the local list never asks ollama.com" \
    [expr {[string first "ollama.com" [join $::lastArgv { }]] < 0}] $::lastArgv

# ------------------------------------------- a failure says what happened ----
puts "\n== a failed request says what happened =="

# A base typed without the scheme answers 301 with no body at all. That used to
# be reported as "the endpoint returned no text (check the model name)", which
# sent the user looking at the model name for a URL mistake.
checkEq "a redirect is named as a redirect" \
    [::auto_comment::emptyReplyError 301 ""] \
    "the endpoint redirected (HTTP 301) instead of answering: use the URL it points at, usually the https form"
checkEq "an empty body names the status" \
    [::auto_comment::emptyReplyError 200 ""] \
    "the endpoint answered HTTP 200 with an empty body"
checkEq "a body that is not a chat reply is quoted" \
    [::auto_comment::emptyReplyError 200 "<html>nope</html>"] \
    "the endpoint answered HTTP 200 with something that is not a chat reply: <html>nope</html>"
checkEq "an empty message still blames the model" \
    [::auto_comment::emptyReplyError 200 {{"choices":[{"message":{"content":""}}]}}] \
    "the endpoint returned no text (check the model name)"
# A reasoning model that spends its budget thinking answers with empty content:
# that is a budget problem, not a wrong model name.
checkEq "a truncated native reply is a budget problem" \
    [::auto_comment::emptyReplyError 200 {{"message":{"role":"assistant","content":"","thinking":"long reasoning"},"done":true,"done_reason":"length"}}] \
    "the model used its whole output budget before writing an answer (the reply was cut off): raise the token limit or pick a model that does not think first"
checkEq "the openai shape says the same" \
    [::auto_comment::emptyReplyError 200 {{"choices":[{"message":{"content":""},"finish_reason":"length"}]}}] \
    "the model used its whole output budget before writing an answer (the reply was cut off): raise the token limit or pick a model that does not think first"
checkEq "no status at all is its own case" \
    [::auto_comment::emptyReplyError "" ""] \
    "the endpoint answered nothing (no HTTP status): check the endpoint URL"

checkEq "an unauthorised reply with no key says so" \
    [::auto_comment::replyFailure 401 {{"error":{"message":"Unauthorized"}}} 0] \
    "ERROR: Unauthorized (no API key was sent)"
checkEq "an unauthorised reply with a key stays plain" \
    [::auto_comment::replyFailure 401 {{"error":{"message":"Unauthorized"}}} 1] \
    "ERROR: Unauthorized"
checkEq "a 404 body is quoted" \
    [::auto_comment::replyFailure 404 "Not Found" 0] \
    "ERROR: the endpoint answered HTTP 404: Not Found"
checkEq "a good reply is not a failure" \
    [::auto_comment::replyFailure 200 $openaiReply 1] {}

# end to end through the transport: the status decides, not the body
set ::auto_comment::provider openai
set ::auto_comment::openaiUrl "https://api.example.com"
set ::auto_comment::openaiModel "m"
set ::fakeBody ""
set ::fakeStatus "301"
checkEq "the transport reports the redirect" [::auto_comment::queryChat "hi" 50] \
    "ERROR: the endpoint redirected (HTTP 301) instead of answering: use the URL it points at, usually the https form"
check "a redirect is followed" [expr {[lsearch -exact $::lastArgv -L] >= 0}] $::lastArgv
check "the POST and its body survive the redirect" \
    [expr {[lsearch -exact $::lastArgv --post301] >= 0 \
        && [lsearch -exact $::lastArgv --post302] >= 0 \
        && [lsearch -exact $::lastArgv --post303] >= 0}] $::lastArgv
check "the body is written to a file, the status read from stdout" \
    [expr {[lsearch -exact $::lastArgv -o] >= 0 && [lsearch -exact $::lastArgv -w] >= 0}] $::lastArgv
# -L resends the prompt body, so an encrypted request must not be allowed to
# redirect into clear text.
check "an https request refuses a cleartext redirect" \
    [expr {[lsearch -exact $::lastArgv --proto-redir] >= 0}] $::lastArgv
set ::auto_comment::openaiUrl "http://127.0.0.1:8000"
::auto_comment::queryChat "hi" 50
check "an http base keeps the default redirect policy" \
    [expr {[lsearch -exact $::lastArgv --proto-redir] < 0}] $::lastArgv
# curl before 7.70 does not know --post303 and refuses the whole command line
# for it, so the flag is offered only when the probe finds a version that has it.
set ::fakeCurlVersion "curl 7.55.1 (Windows) libcurl/7.55.1"
unset -nocomplain ::auto_comment::post303
set ::lastArgv {}
::auto_comment::queryChat "hi" 50
check "an old curl is not offered --post303" \
    [expr {[lsearch -exact $::lastArgv --post303] < 0}] $::lastArgv
check "but still keeps the POST across 301 and 302" \
    [expr {[lsearch -exact $::lastArgv --post301] >= 0 \
        && [lsearch -exact $::lastArgv --post302] >= 0}] $::lastArgv
set ::fakeCurlVersion "curl 8.23.0 (x86_64-pc-linux-gnu)"
unset -nocomplain ::auto_comment::post303

set ::auto_comment::openaiUrl "https://api.example.com"
check "the reply file is deleted after the request" \
    [expr {$::lastOutFile ne "" && ![file exists $::lastOutFile]}] $::lastOutFile

set ::fakeStatus "200"
set ::fakeBody {{"choices":[{"message":{"content":""}}]}}
checkEq "an empty message keeps its own wording" [::auto_comment::queryChat "hi" 50] \
    "ERROR: the endpoint returned no text (check the model name)"

set ::auto_comment::openaiKey ""
set ::fakeStatus "401"
set ::fakeBody {{"error":{"message":"Unauthorized"}}}
checkEq "a keyless 401 says the key was never sent" [::auto_comment::queryChat "hi" 50] \
    "ERROR: Unauthorized (no API key was sent)"

# curl's own reason is kept: -s used to swallow it, so every transport failure
# read "network error or timeout" and nothing else.
set ::fakeStatus "000"
set ::fakeBody ""
set ::fakeStderr "curl: (7) Failed to connect to 127.0.0.1 port 1: Connection refused"
set ::fakeExecError "000child process exited abnormally"
checkEq "a transport failure quotes curl" [::auto_comment::queryChat "hi" 50] \
    "ERROR: request failed: curl: (7) Failed to connect to 127.0.0.1 port 1: Connection refused"

# a redirect that never resolves is a redirect, not a network error
set ::fakeStatus "301"
set ::fakeStderr "curl: (47) Maximum (50) redirects followed"
set ::fakeExecError "301child process exited abnormally"
check "a redirect loop is named as a redirect" \
    [string match {ERROR: the endpoint redirected (HTTP 301)*} [::auto_comment::queryChat "hi" 50]] \
    [::auto_comment::queryChat "hi" 50]
set ::fakeExecError ""
set ::fakeStderr ""
set ::fakeStatus "200"

# ------------------------------- a failed model list keeps the dialog in front --
puts "\n== a failed model list keeps the settings dialog in front =="
# Load Models is the button whose warning used to be parented to ".": on Windows
# a box parented to the main window activates it, and the Game Comment dialog is
# transient to it, so the settings dialog the user was typing in dropped behind
# the dialog it had been opened from.
proc winfo {args} {
    switch -- [lindex $args 0] {
        toplevel { return .autoCommentConfig }
        exists   { return 1 }
    }
    return 0
}
set ::auto_comment::provider openai
set ::auto_comment::openaiUrl "http://ollama.com/v1"
set ::auto_comment::openaiKey ""
set ::auto_comment::openaiModel "deepseek-v4.1-flash:1017"
set ::fakeBody ""
set ::fakeStatus "301"
set ::boxes {}
set ::raisedWindow ""
set ::focusedWindow ""
::auto_comment::loadModels .autoCommentConfig.content.openai.model openai
check "the warning was shown once" [expr {[llength $::boxes] == 1}] $::boxes
checkEq "it is parented to the settings dialog, not the main window" \
    [dict get [lindex $::boxes 0] -parent] .autoCommentConfig
checkEq "the settings dialog is put back in front" $::raisedWindow .autoCommentConfig
checkEq "and takes the focus back" [lindex $::focusedWindow 0] -force
check "the warning names the URL it tried" \
    [string match {*Tried:*} [dict get [lindex $::boxes 0] -message]] \
    [dict get [lindex $::boxes 0] -message]
# A generic base has two targets, and a local server that only speaks the native
# API failed on both: report both, or the message hides half the attempt.
check "both attempted URLs are named" \
    [expr {([string first {http://ollama.com/v1/models} [dict get [lindex $::boxes 0] -message]] >= 0) \
        && ([string first {http://ollama.com/api/tags} [dict get [lindex $::boxes 0] -message]] >= 0)}] \
    [dict get [lindex $::boxes 0] -message]

# The other channels have one target each. Their branches set a singular
# `target`, which the message never read, so the warning named the provider but
# not the URL - the one line that exposes a wrong base.
foreach prov {opencode gemini} {
    set ::auto_comment::provider $prov
    set ::fakeBody ""
    set ::fakeStatus "500"
    set ::boxes {}
    ::auto_comment::loadModels .autoCommentConfig.content.$prov.model $prov
    set want [expr {$prov eq "opencode" \
        ? $::auto_comment::opencodeModelsUrl \
        : "https://generativelanguage.googleapis.com/v1beta/models?pageSize=200"}]
    check "$prov names the URL it tried" \
        [expr {[string first $want [dict get [lindex $::boxes 0] -message]] >= 0}] \
        [dict get [lindex $::boxes 0] -message]
}

# The Gemini warning used to name the API root, not the request: the list is
# asked with a page size, and anyone reproducing the failure with the bare root
# would get a different answer.
check "gemini names the page size it asked for" \
    [string match {*?pageSize=200*} [dict get [lindex $::boxes 0] -message]] \
    [dict get [lindex $::boxes 0] -message]

# Load Models on each Ollama channel names that channel's own endpoint: the
# local one reports the local server, the hosted one reports ollama.com, and
# neither reports the other. A user who picked one channel and got the other's
# URL in the warning is looking at the wrong machine.
puts "\n== each Ollama channel reports its own endpoint =="
set ::auto_comment::localUrl "http://localhost:11434"
set ::fakeBody ""
set ::fakeStatus "500"
set ::auto_comment::provider local
set ::boxes {}
::auto_comment::loadModels .autoCommentConfig.content.local.model local
set localMsg [dict get [lindex $::boxes 0] -message]
check "the local warning names the local server" \
    [expr {[string first {http://localhost:11434/api/tags} $localMsg] >= 0}] $localMsg
check "the local warning never names ollama.com" \
    [expr {[string first "ollama.com" $localMsg] < 0}] $localMsg
set ::boxes {}
set ::auto_comment::provider ollama
::auto_comment::loadModels .autoCommentConfig.content.ollama.model ollama
set cloudMsg [dict get [lindex $::boxes 0] -message]
check "the hosted warning names ollama.com" \
    [expr {[string first {https://ollama.com/api/tags} $cloudMsg] >= 0}] $cloudMsg
check "the hosted warning never names the local server" \
    [expr {[string first "localhost" $cloudMsg] < 0}] $cloudMsg

# ---------------------------------------- the dialog handlers store ids, not labels --
# The combo holds the label and ::auto_comment::provider holds the id the options
# file keeps. The handler is the only place the two meet, and Tk itself needs a
# display, so this stands in for the widget: same three subcommands the dialog
# uses (configure -values, set, get).
puts "\n== the dialog handlers store ids, not labels =="
proc .autoCommentConfig.content.provider {sub args} {
    switch -- $sub {
        configure { set ::comboValues [lindex $args 1]; return }
        set       { set ::comboValue [lindex $args 0]; return }
        get       { return $::comboValue }
        default   { return }
    }
}
proc ::fakeModelCombo {sub args} {
    switch -- $sub {
        configure {
            foreach {key value} $args {
                if {$key eq "-textvariable"} { set ::modelVar $value }
            }
            return
        }
        default { return }
    }
}
proc ::fakeProviderCombo {sub args} {
    switch -- $sub {
        configure { set ::comboValues [lindex $args 1]; return }
        set       { set ::comboValue [lindex $args 0]; return }
        get       { return $::comboValue }
        default   { return }
    }
}
set ::comboValue ""
set ::comboValues {}
set ::auto_comment::provider none
::auto_comment::syncProviderCombo .autoCommentConfig.content.provider
checkEq "the combo shows the stored provider's label" $::comboValue {No model}
checkEq "and offers every label" $::comboValues [::auto_comment::providerLabels]

.autoCommentConfig.content.provider set {Ollama Cloud (hosted)}
::auto_comment::chooseProvider .autoCommentConfig
checkEq "picking the cloud label stores ollama" $::auto_comment::provider ollama
checkEq "and the combo keeps showing it" $::comboValue {Ollama Cloud (hosted)}
.autoCommentConfig.content.provider set {Ollama - local server}
::auto_comment::chooseProvider .autoCommentConfig
checkEq "picking the local label stores local" $::auto_comment::provider local

# A value that is not one of our labels (a stale dialog, a hand-edited file) is
# not a pick: the provider stays put and the display is put back.
.autoCommentConfig.content.provider set Ollama
::auto_comment::chooseProvider .autoCommentConfig
checkEq "an unknown label changes nothing" $::auto_comment::provider local
checkEq "and the combo is put back in step" $::comboValue {Ollama - local server}

# The Game Comment dialog's handler does the same, then rebinds the model field.
set ::comboValue {Ollama Cloud (hosted)}
set ::modelVar ""
::auto_comment::chooseProviderForModel ::fakeProviderCombo ::fakeModelCombo
checkEq "the batch dialog stores the hosted id" $::auto_comment::provider ollama
checkEq "and its model field follows that channel" $::modelVar ::auto_comment::ollamaModel
set ::comboValue {Ollama - local server}
::auto_comment::chooseProviderForModel ::fakeProviderCombo ::fakeModelCombo
checkEq "the batch dialog stores the local id" $::auto_comment::provider local
checkEq "and its model field follows it" $::modelVar ::auto_comment::localModel

# Closing Settings refreshes both combos: a provider changed there must show in
# the dialog that opened it, and the model field must follow it.
set ::auto_comment::provider ollama
set ::comboValue ""
set ::modelVar ""
::auto_comment::refreshAfterSettings ::fakeModelCombo ::fakeProviderCombo
checkEq "the provider label follows Settings" $::comboValue {Ollama Cloud (hosted)}
checkEq "and the model field follows that channel" $::modelVar ::auto_comment::ollamaModel

# ------------------------------------------------------- gateway model filter --
puts "\n== gateway model filter =="
set gatewayIds {glm-5.3 kimi-k3 minimax-m3 deepseek-v4-pro mistral-large-4 qwen3.8-max \
                gpt-6.1-sol claude-sonnet-5 gemini-3.6-flash grok-4.7 muse-spark-1.3 \
                jev-1.13 qwen3.6-plus glm-5.3-flash-free deepseek-v4.1-flash-free \
                big-pickle test}
checkEq "only chat-completions paid models survive" \
    [::auto_comment::chatCompletionsOnly $gatewayIds] \
    {glm-5.3 kimi-k3 minimax-m3 deepseek-v4-pro mistral-large-4 qwen3.8-max}
checkEq "an unknown new model is kept" \
    [::auto_comment::chatCompletionsOnly {brand-new-model}] {brand-new-model}

# ------------------------------------------------------------ request files --
puts "\n== request files =="
set f1 [::auto_comment::writeRequestFile {body one} chat]
set f2 [::auto_comment::writeRequestFile {body two} chat]
check "two calls never share a path" [expr {$f1 ne $f2}] "$f1 / $f2"
check "the body round-trips" [expr {[read [set fh [open $f1 r]]] eq "body one"}] "content"
close $fh
check "name is not predictable" [expr {[file tail $f1] ne "auto_comment_chat.json"}] [file tail $f1]
if {$::tcl_platform(platform) eq "windows"} {
    puts "  skip permissions are not a POSIX mode on this platform"
} else {
    file stat $f1 st
    checkEq "owner-only permissions" [format %04o [expr {$st(mode) & 0o777}]] 0600
}
file delete -force $f1 $f2

# A keyed model-list request must not follow a redirect down to cleartext.
puts "\n== model-list redirects stay encrypted =="
set savedOllamaKey $::auto_comment::ollamaKey
set ::auto_comment::ollamaKey "secret-key"
set ::fakeBody {{"models":[{"name":"glm-5.3","capabilities":["completion"]}]}}
set ::fakeStatus "200"
set ::lastArgv {}
catch {::auto_comment::fetchOllamaModels}
check "the Ollama model list refuses an https downgrade" \
    [expr {[lsearch -exact $::lastArgv --proto-redir] >= 0 \
        && [lindex $::lastArgv [expr {[lsearch -exact $::lastArgv --proto-redir] + 1}]] eq "=https"}] \
    $::lastArgv
set ::auto_comment::ollamaKey $savedOllamaKey
set ::lastArgv {}
catch {::auto_comment::fetchUrlModels "https://api.deepseek.com" "secret-key"}
check "the generic model list refuses it too" \
    [expr {[lsearch -exact $::lastArgv --proto-redir] >= 0}] $::lastArgv


# The native API replies, parsed without a network.
set geminiReply {{"candidates":[{"content":{"parts":[{"text":"A good move."}]}}]}}
checkEq "Gemini text is extracted" [::auto_comment::geminiText $geminiReply] {A good move.}
set geminiError {{"error":{"code":400,"message":"bad key"}}}
checkEq "Gemini errors are named" [::auto_comment::geminiText $geminiError] "ERROR: bad key"
set deepseekReply {{"choices":[{"message":{"content":"The threat is Qh5."}}]}}
checkEq "DeepSeek text is extracted" \
    [::auto_comment::deepseekText $deepseekReply] {The threat is Qh5.}
checkEq "DeepSeek errors are named" \
    [::auto_comment::deepseekText {{"error":{"message":"bad key"}}}] "ERROR: bad key"

# ------------------------------------------------------------------- cleanup --
file delete -force $tmproot

puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
