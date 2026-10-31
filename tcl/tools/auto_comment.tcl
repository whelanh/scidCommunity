# Copyright (C) 2025-2026 Hugh Whelan
# Copyright (C) 2026 David Crandall
# SPDX-License-Identifier: GPL-2.0-or-later

############################################################
### Auto Comment - AI-generated chess commentary
### Queries engine evaluation APIs and uses an LLM (Gemini,
### DeepSeek, Ollama Cloud, an OpenAI-compatible endpoint, a
### local model, or OpenCode Console) to generate natural
### language commentary.

namespace eval ::auto_comment {
    # LLM provider, one value for every path:
    #   none    no model at all - no request is ever made
    #   local   any Ollama-style server (ollama, LM Studio's Ollama endpoint)
    #   ollama  Ollama's hosted service. Its own channel, not a typed URL: the
    #           native API lives at https://ollama.com/api (chat, tags) and the
    #           OpenAI-compatible one at https://ollama.com/v1, so "https://
    #           ollama.com/api" typed into the generic channel answers 404 on
    #           every /v1 path
    #   openai  any OpenAI-compatible endpoint: DeepSeek, Gemini's compatibility
    #           endpoint, vLLM, LM Studio, a gateway...
    #   opencode OpenCode Console's model gateway, which is OpenAI-compatible
    #   gemini  Google's native API   (kept until Game Comment is retired)
    #   deepseek DeepSeek's native API (kept until Game Comment is retired)
    # The default is "none": a review is complete without prose, and a machine
    # with no model should behave exactly like one whose owner has not chosen a
    # model yet. Nothing is sent anywhere until someone picks a provider, and an
    # existing install keeps whatever it already stored.
    options.store ::auto_comment::provider "none"

    # Local (Ollama-style) settings
    options.store ::auto_comment::localUrl "http://localhost:11434"
    options.store ::auto_comment::localModel ""

    # OpenAI-compatible settings
    options.store ::auto_comment::openaiUrl "https://api.deepseek.com"
    options.store ::auto_comment::openaiKey ""
    options.store ::auto_comment::openaiModel ""

    # Ollama Cloud settings. The base is fixed here rather than typed: the
    # hosted service is the one endpoint whose URL a user gets wrong, because
    # the native API and the OpenAI-compatible API sit under different roots.
    #
    # The channel speaks the native API (api/chat, api/tags). That is the whole
    # of it: the OpenAI and Anthropic compatibility layers are documented as
    # subsets of it, and the native one carries what this feature needs - the
    # answer in message.content with thinking kept in its own field, and a model
    # list that says which models can chat at all.
    options.store ::auto_comment::ollamaKey ""
    options.store ::auto_comment::ollamaModel ""
    variable ollamaBase "https://ollama.com/api"
    variable ollamaKeyUrl "https://ollama.com/settings/keys"

    # OpenCode Console settings. The gateway itself is a commercial service, so
    # both roots live here where a rename or a path change is one line.
    # Its model list is a sibling of the chat root, not a child of it:
    # .../inference/v1/models answers, .../inference/openai/v1/models does not.
    options.store ::auto_comment::opencodeKey ""
    options.store ::auto_comment::opencodeModel ""
    variable opencodeBase      "https://opencode.ai/inference/openai"
    variable opencodeModelsUrl "https://opencode.ai/inference/v1/models"

    # Scratch model for "none": the dialogs bind their model field to one
    # variable per provider, and without this the empty provider kept showing
    # Gemini's model name next to "LLM Provider: none". Never persisted.
    variable noModel ""

    # Gemini settings
    options.store ::auto_comment::apiKey ""
    options.store ::auto_comment::model "gemini-3.6-flash"

    # DeepSeek settings
    options.store ::auto_comment::deepseekApiKey ""
    options.store ::auto_comment::deepseekModel "deepseek-v4-pro"

    variable geminiApiBase "https://generativelanguage.googleapis.com/v1beta/models"
    variable deepseekApiBase "https://api.deepseek.com"
    variable lichessApiUrl "https://lichess.org/api/cloud-eval"
    variable chessdbApiUrl "http://www.chessdb.cn/cdb.php"
    
    # Log file for Windows GUI (fallback when stderr unavailable)
    variable logFile ""

    # Debug logging is opt-in: release builds must not write to stderr/stdout
    # (a stray console can break the Windows GUI build). Set the
    # SCID_AUTOCOMMENT_DEBUG environment variable to enable it when developing.
    variable debugEnabled [expr {[info exists ::env(SCID_AUTOCOMMENT_DEBUG)] ? 1 : 0}]
}

# ::auto_comment::logDebug
#   Writes debug messages to stderr (Linux/macOS) or a log file (Windows GUI).
#   Does nothing unless debug logging has been enabled (see debugEnabled).
#
proc ::auto_comment::logDebug {message} {
    variable debugEnabled
    variable logFile

    if {![info exists debugEnabled] || !$debugEnabled} { return }

    # Try stderr first (works on Linux/macOS terminal)
    if {[catch {puts stderr $message}]} {
        # Fallback: write to a log file (for Windows GUI)
        if {$logFile eq ""} {
            set logDir [file join [pwd] "logs"]
            catch {file mkdir $logDir}
            set logFile [file join $logDir "auto_comment_debug.log"]
        }
        set fd [open $logFile "a"]
        puts $fd $message
        close $fd
    } else {
        flush stderr
    }
}

# ::auto_comment::fitWindow
#   Sizes a toplevel window to fit its content and centers it on screen.
#   Wayland/Hyprland (via XWayland) does not reliably honor the requested
#   size of a Tk toplevel, which leaves popups clipped. Explicitly setting
#   the geometry ensures the whole popup is visible. Optional minimum
#   width/height can be supplied for windows with a preferred floor size.
#
proc ::auto_comment::fitWindow {w {minW 0} {minH 0}} {
    if {![winfo exists $w]} { return }
    update idletasks
    set reqW [winfo reqwidth $w]
    set reqH [winfo reqheight $w]
    if {$reqW < $minW} { set reqW $minW }
    if {$reqH < $minH} { set reqH $minH }

    # Keep the window on screen (leave a small margin).
    set screenW [winfo screenwidth $w]
    set screenH [winfo screenheight $w]
    set maxW [expr {$screenW - 40}]
    set maxH [expr {$screenH - 80}]
    if {$maxW < 200} { set maxW 200 }
    if {$maxH < 100} { set maxH 100 }
    if {$reqW > $maxW} { set reqW $maxW }
    if {$reqH > $maxH} { set reqH $maxH }

    set x [expr {($screenW - $reqW) / 2}]
    set y [expr {($screenH - $reqH) / 2}]
    if {$x < 0} { set x 0 }
    if {$y < 0} { set y 0 }

    wm geometry $w "${reqW}x${reqH}+${x}+${y}"
}

# ::auto_comment::providerList
#   The values the settings combo offers, in the order it shows them.
proc ::auto_comment::providerList {} {
    return {none local ollama openai opencode gemini deepseek}
}

# ::auto_comment::providerLabel
#   What the provider combo shows for a stored id. The options file stores the
#   id, so the two must be different strings for the two channels a user cannot
#   tell apart from an id: "local" and "ollama" are both Ollama to anyone who
#   does not already know that one is a server on this machine and the other is
#   a paid hosted service. The label says which is which; the id never changes.
proc ::auto_comment::providerLabel {provider} {
    switch -- $provider {
        none     { return "No model" }
        local    { return "Ollama - local server" }
        ollama   { return "Ollama Cloud (hosted)" }
        openai   { return "OpenAI-compatible endpoint" }
        opencode { return "OpenCode Console" }
        gemini   { return "Google Gemini" }
        deepseek { return "DeepSeek" }
    }
    return $provider
}

# ::auto_comment::providerLabels
#   The combobox values: one label per stored id, in providerList order.
proc ::auto_comment::providerLabels {} {
    set out {}
    foreach id [::auto_comment::providerList] {
        lappend out [::auto_comment::providerLabel $id]
    }
    return $out
}

# ::auto_comment::providerFromLabel
#   The stored id behind a label, or "" when the label belongs to no provider.
#   Matching is exact: a hand-edited options file or a stale dialog is not a
#   reason to guess which channel the user meant.
proc ::auto_comment::providerFromLabel {label} {
    set want [string trim $label]
    foreach id [::auto_comment::providerList] {
        if {[::auto_comment::providerLabel $id] eq $want} { return $id }
    }
    return ""
}

# ::auto_comment::providerReady
#   Empty when the selected provider has what it needs, otherwise the reason it
#   cannot run - shown to the user instead of a request that silently fails.
proc ::auto_comment::providerReady {} {
    switch -- $::auto_comment::provider {
        none     { return "no model selected" }
        local {
            if {$::auto_comment::localUrl eq ""} { return "no local endpoint set" }
            if {$::auto_comment::localModel eq ""} { return "no local model selected" }
            return ""
        }
        openai {
            if {$::auto_comment::openaiUrl eq ""} { return "no endpoint set" }
            if {$::auto_comment::openaiModel eq ""} { return "no model selected" }
            return ""
        }
        ollama {
            # The hosted service refuses an unauthenticated chat request, and its
            # model list answers without one, so a missing key is caught here
            # instead of arriving as a 401 after the game has been scanned.
            if {$::auto_comment::ollamaKey eq ""} { return "no Ollama Cloud key set" }
            if {$::auto_comment::ollamaModel eq ""} { return "no Ollama model selected" }
            return ""
        }
        opencode {
            # the gateway requires the header for every paid model, so a missing
            # key is a refusal here rather than a 401 from the endpoint
            if {$::auto_comment::opencodeKey eq ""} { return "no OpenCode key set" }
            if {$::auto_comment::opencodeModel eq ""} { return "no OpenCode model selected" }
            return ""
        }
        gemini {
            if {$::auto_comment::apiKey eq ""} { return "no Gemini key set" }
            if {$::auto_comment::model eq ""} { return "no Gemini model selected" }
            return ""
        }
        deepseek {
            if {$::auto_comment::deepseekApiKey eq ""} { return "no DeepSeek key set" }
            if {$::auto_comment::deepseekModel eq ""} { return "no DeepSeek model selected" }
            return ""
        }
    }
    return "unknown provider: $::auto_comment::provider"
}

# ::auto_comment::baseUrl
#   Normalise an API base the user typed. Both forms of the same endpoint are
#   accepted - "https://api.openai.com" and "https://api.openai.com/v1" - so a
#   caller can always append its own "/v1/..." path without doubling the version
#   segment. Trailing slashes are dropped too.
proc ::auto_comment::baseUrl {url} {
    set base [string trim [string trimright $url /]]
    regsub -nocase {/v1$} $base "" base
    return [string trimright $base /]
}

# ::auto_comment::urlHost
#   The host of an http(s) URL, without userinfo, port or brackets. "" when the
#   string is not an absolute URL.
proc ::auto_comment::urlHost {url} {
    if {![regexp -nocase {^[a-z][a-z0-9+.-]*://([^/?#]*)} [string trim $url] -> auth]} {
        return ""
    }
    set auth [string range $auth [expr {[string last "@" $auth] + 1}] end]
    if {[string match {\[*} $auth]} {
        return [string range $auth 0 [string first "\]" $auth]]
    }
    return [lindex [split $auth ":"] 0]
}

# ::auto_comment::isLoopbackHost
#   True for a host that never leaves this machine. vLLM and LM Studio answer on
#   http://localhost:8000, so loopback is the one place a cleartext request is
#   not a leak.
proc ::auto_comment::isLoopbackHost {host} {
    set h [string tolower [string trim $host]]
    if {[string match {\[*} $h]} { set h [string range $h 1 end-1] }
    if {$h in {localhost 127.0.0.1 ::1}} { return 1 }
    return [regexp {^127\.[0-9]+\.[0-9]+\.[0-9]+$} $h]
}

# ::auto_comment::cleartextKeyError
#   "" when it is safe to send an API key to $url, otherwise the reason to
#   refuse. A key over http to a remote host would go out in clear text; the
#   endpoint may still be used without a key (the dialog says to leave it empty
#   when the endpoint needs none).
proc ::auto_comment::cleartextKeyError {url key} {
    if {$key eq ""} { return "" }
    if {[regexp -nocase {^https://} [string trim $url]]} { return "" }
    if {[::auto_comment::isLoopbackHost [::auto_comment::urlHost $url]]} { return "" }
    return "refusing to send the API key in clear text to \"$url\": use https, or clear the key when the endpoint needs none"
}

# ::auto_comment::writeRequestFile
#   Write a request body to a fresh file and return its path. The name is
#   unpredictable and the file is created exclusively and owner-only, so neither
#   a pre-created file or symlink nor another local account can reach the body:
#   it carries the prompt, and the prompt carries game data.
proc ::auto_comment::writeRequestFile {body {tag chat}} {
    set dir [::auto_comment::getTempDir]
    for {set attempt 0} {$attempt < 10} {incr attempt} {
        set name "auto_comment_${tag}_[pid]_[clock seconds]_[clock clicks]_[expr {int(rand() * 1000000)}].json"
        set path [file join $dir $name]
        # EXCL prevents substitution, 0600 prevents reading: a shared /tmp uses
        # 0644 by default, which is world-readable while curl runs.
        if {[catch {set fd [open $path {WRONLY CREAT EXCL} 0600]}]} { continue }
        if {[catch {
            puts -nonewline $fd $body
            close $fd
        } err]} {
            catch {close $fd}
            catch {file delete -force $path}
            return -code error $err
        }
        return $path
    }
    return -code error "cannot create a request file in $dir"
}

# ::auto_comment::writeCurlConfig
#   Write the auth header to a curl config file and return its path.
#
#   The key must not go in curl's arguments: any local user can read another
#   process's argv with ps or /proc, which would undo the 0600 options file.
#   "header = ..." in a config file is the documented way to pass it without
#   an argument, and the file is created owner-only by writeRequestFile.
proc ::auto_comment::writeCurlConfig {header {tag auth}} {
    set value [string map [list "\\" "\\\\" "\"" "\\\""] $header]
    return [::auto_comment::writeRequestFile "header = \"$value\"\n" $tag]
}

# ::auto_comment::chatEndpoint
#   The URL a chat request goes to for the selected provider.
proc ::auto_comment::chatEndpoint {} {
    switch -- $::auto_comment::provider {
        local  { return "[::auto_comment::baseUrl $::auto_comment::localUrl]/api/chat" }
        ollama { return "$::auto_comment::ollamaBase/chat" }
        openai {
            set base [::auto_comment::baseUrl $::auto_comment::openaiUrl]
            # A full endpoint pasted from a provider's documentation is used as
            # it stands. Appending the path to it again is the classic 404, and
            # copying the endpoint is what people do.
            if {[string match -nocase */chat/completions $base]} { return $base }
            # Gemini's compatibility root carries its own version segment, so it
            # takes the path without the leading /v1.
            if {[string match -nocase */v1beta/openai $base]} { return "$base/chat/completions" }
            return "$base/v1/chat/completions"
        }
        opencode { return "$::auto_comment::opencodeBase/v1/chat/completions" }
    }
    return ""
}

# ::auto_comment::modelsUrl
#   The model-list URL that belongs to a chat base. Accepts the same forms as
#   chatEndpoint - a base with or without /v1, or the full endpoint, which is
#   what gets pasted - and keeps Gemini's compatibility root on its own version
#   segment, because /v1/models does not exist below it.
proc ::auto_comment::modelsUrl {url} {
    set base [string trim $url]
    regsub -nocase {/chat/completions$} $base "" base
    set base [::auto_comment::baseUrl $base]
    if {[string match -nocase */v1beta/openai $base]} { return "$base/models" }
    return "$base/v1/models"
}

# ::auto_comment::providerModel
#   The model id for the selected chat provider. Each generic provider keeps its
#   own model, so switching channels does not overwrite the other one's choice.
proc ::auto_comment::providerModel {} {
    switch -- $::auto_comment::provider {
        local    { return $::auto_comment::localModel }
        ollama   { return $::auto_comment::ollamaModel }
        openai   { return $::auto_comment::openaiModel }
        opencode { return $::auto_comment::opencodeModel }
    }
    return ""
}

# ::auto_comment::chatBody
#   The request body for the selected provider. Ollama's native API takes
#   "options num_predict"; OpenAI-compatible ones take "max_tokens". Both take a
#   single user message.
proc ::auto_comment::chatBody {prompt {maxTokens 300}} {
    set esc [::auto_comment::escapeJson $prompt]
    switch -- $::auto_comment::provider {
        local -
        ollama {
            # the native shape: Ollama's own /api/chat, which both the local
            # server and the hosted service answer
            set model [::auto_comment::escapeJson [::auto_comment::providerModel]]
            return "{\"model\":\"$model\",\"messages\":\[{\"role\":\"user\",\"content\":\"$esc\"}\],\"stream\":false,\"options\":{\"num_predict\":$maxTokens}}"
        }
        openai -
        opencode {
            set model [::auto_comment::escapeJson [::auto_comment::providerModel]]
            return "{\"model\":\"$model\",\"messages\":\[{\"role\":\"user\",\"content\":\"$esc\"}\],\"stream\":false,\"max_tokens\":$maxTokens}"
        }
    }
    return ""
}

# ::auto_comment::chatAuth
#   The Authorization header value, or "" when the endpoint needs no key. A local
#   server must never be sent someone's cloud key.
proc ::auto_comment::chatAuth {} {
    switch -- $::auto_comment::provider {
        ollama {
            if {$::auto_comment::ollamaKey eq ""} { return "" }
            # the hosted service is https by construction: no cleartext case
            return "Authorization: Bearer $::auto_comment::ollamaKey"
        }
        opencode {
            if {$::auto_comment::opencodeKey eq ""} { return "" }
            # the OpenCode endpoint is always https, so no cleartext case exists
            return "Authorization: Bearer $::auto_comment::opencodeKey"
        }
        openai {
            if {$::auto_comment::openaiKey eq ""} { return "" }
            # queryChat refuses this case before it gets here; keeping the check
            # means a future caller cannot send the key over cleartext either.
            if {[::auto_comment::cleartextKeyError $::auto_comment::openaiUrl $::auto_comment::openaiKey] ne ""} {
                return ""
            }
            return "Authorization: Bearer $::auto_comment::openaiKey"
        }
    }
    return ""
}

# ::auto_comment::replyText
#   Pull the assistant text out of a chat response. OpenAI-compatible endpoints
#   answer in choices[0].message.content; Ollama in message.content. Both are
#   read here so the caller does not care which provider produced the reply.
proc ::auto_comment::replyText {raw} {
    set text [::auto_comment::extractOpenAIChoice $raw]
    if {$text eq ""} { set text [::auto_comment::extractOllamaMessage $raw] }
    return $text
}

proc ::auto_comment::extractOpenAIChoice {raw} {
    if {![regexp {"choices"\s*:\s*\[} $raw]} { return "" }
    if {[regexp {"content"\s*:\s*"((?:[^"\\]|\\.)*)"} $raw -> text]} {
        return [::auto_comment::unescapeJson $text]
    }
    return ""
}

proc ::auto_comment::extractOllamaMessage {raw} {
    if {![regexp {"message"\s*:\s*\{.*?"content"\s*:\s*"((?:[^"\\]|\\.)*)"} $raw -> text]} {
        return ""
    }
    return [::auto_comment::unescapeJson $text]
}

# ::auto_comment::unescapeJson
#   Minimal JSON string decoder: the escapes a chat reply actually contains.
#   subst does the work in one pass. A string map in front of it would have to
#   key on the already-decoded forms, and did: a content of C:\new matched a
#   "backslash backslash n" key and became a newline, and two literal
#   backslashes collapsed into one. Decode each escape exactly once.
proc ::auto_comment::unescapeJson {text} {
    return [subst -nocommands -novariables $text]
}

# ::auto_comment::replyError
#   The message inside an API error response, or "" when the body is not one.
#   OpenAI-compatible endpoints put the text in error.message; the OpenCode
#   gateway wraps the same object one level deeper, and a few endpoints answer
#   with a bare string. The text is what the user needs: a missing key, a model
#   that is on another API, an unpaid plan.
proc ::auto_comment::replyError {raw} {
    if {[regexp {"error"\s*:\s*\{} $raw]} {
        if {[regexp {"message"\s*:\s*"((?:[^"\\]|\\.)*)"} $raw -> msg]} {
            return [::auto_comment::unescapeJson $msg]
        }
        return "API error: [string range [string trim $raw] 0 300]"
    }
    if {[regexp {"error"\s*:\s*"((?:[^"\\]|\\.)*)"} $raw -> msg]} {
        return [::auto_comment::unescapeJson $msg]
    }
    return ""
}

# ::auto_comment::readAndDelete
#   The contents of a scratch file, removed as it is read. "" when it is gone.
proc ::auto_comment::readAndDelete {path} {
    if {![file exists $path]} { return "" }
    set text ""
    if {![catch {set fd [open $path r]}]} {
        catch { set text [read $fd] }
        catch { close $fd }
    }
    catch { file delete -force $path }
    return $text
}

# ::auto_comment::replyFailure
#   The "ERROR:" line for a response that cannot be read as a chat reply, or
#   "" when the body should be parsed for text. The status is what separates a
#   wrong URL from a wrong model, so it is reported instead of guessed at.
proc ::auto_comment::replyFailure {status body authSent} {
    if {[regexp {^3[0-9][0-9]$} $status]} {
        # curl was told to follow redirects, so this is a redirect it would not
        # take (a method change it could not make, or a loop).
        return "ERROR: the endpoint redirected (HTTP $status) instead of answering: use the URL it points at, usually the https form"
    }
    set err [::auto_comment::replyError $body]
    if {$err ne ""} {
        # A 401/403 on a request that carried no key is not a bad key: the key
        # was never sent. Saying so saves a round trip through the settings.
        if {!$authSent && $status in {401 403}} { append err " (no API key was sent)" }
        return "ERROR: $err"
    }
    if {[regexp {^[45][0-9][0-9]$} $status]} {
        return "ERROR: the endpoint answered HTTP $status: [string range [string trim $body] 0 200]"
    }
    return ""
}

# ::auto_comment::emptyReplyError
#   Why a response held no text. An empty 301 body used to be reported as "the
#   endpoint returned no text (check the model name)", which sent the user to
#   the model name for a URL mistake: a base typed as "http://host/v1" answers
#   301 with no body at all.
proc ::auto_comment::emptyReplyError {status body} {
    set body [string trim $body]
    if {[regexp {^3[0-9][0-9]$} $status]} {
        return "the endpoint redirected (HTTP $status) instead of answering: use the URL it points at, usually the https form"
    }
    if {$body eq ""} {
        if {$status eq "" || $status eq "000"} {
            return "the endpoint answered nothing (no HTTP status): check the endpoint URL"
        }
        return "the endpoint answered HTTP $status with an empty body"
    }
    # A reply cut off at the token limit is not a model-name problem, and the
    # native channel can produce exactly that: a reasoning model that spends its
    # options.num_predict on thinking answers with message.content empty and
    # done_reason "length". Saying "check the model name" there would repeat the
    # misdirection this transport exists to remove.
    if {[regexp {"(?:done_reason|finish_reason)"\s*:\s*"length"} $body]} {
        return "the model used its whole output budget before writing an answer (the reply was cut off): raise the token limit or pick a model that does not think first"
    }
    if {![regexp {"choices"\s*:} $body] && ![regexp {"message"\s*:} $body]} {
        return "the endpoint answered HTTP $status with something that is not a chat reply: [string range $body 0 200]"
    }
    return "the endpoint returned no text (check the model name)"
}

# ::auto_comment::query
#   One entry point for every caller. Returns the assistant text, or a string
#   starting with "ERROR:" that the caller shows to the user. "none" is a
#   refusal, not a failure: nothing is sent, and the caller is expected to have
#   offered the user a way to turn the coach on.
proc ::auto_comment::query {prompt {maxTokens 300}} {
    switch -- $::auto_comment::provider {
        none     { return "ERROR: no model selected (open Game Comment and press Settings...)" }
        gemini   { return [::auto_comment::queryGemini $prompt] }
        deepseek { return [::auto_comment::queryDeepSeek $prompt] }
        local -
        ollama -
        openai -
        opencode { return [::auto_comment::queryChat $prompt $maxTokens] }
    }
    return "ERROR: unknown provider: $::auto_comment::provider"
}

# ::auto_comment::post303Flag
#   --post303 exists only since curl 7.70, and an unknown option makes curl
#   refuse the whole command line before it sends anything: a 7.55 system curl
#   would fail every request, redirect or not. Probe once and offer the flag
#   only where it exists; on an older curl a 303 is followed as a GET, which is
#   what the status means.
proc ::auto_comment::post303Flag {} {
    if {![info exists ::auto_comment::post303]} {
        set ::auto_comment::post303 ""
        if {![catch {exec curl --version} out]} {
            if {[regexp {curl (\d+)\.(\d+)} $out -> major minor] \
                    && [package vcompare "$major.$minor" "7.70"] >= 0} {
                set ::auto_comment::post303 --post303
            }
        }
    }
    return $::auto_comment::post303
}

# ::auto_comment::queryChat
#   The transport for both generic providers: one request shape per provider,
#   written to a temp file and handed to curl, exactly like the native DeepSeek
#   path so Windows (curl.exe) and Unix behave the same.
# The request one generic chat call needs: the curl argv, the three files and
# the auth file. Shared by the blocking and the asynchronous transports so the
# two cannot drift in their endpoints, headers or redirect rules.
proc ::auto_comment::chatSpec {prompt {maxTokens 300}} {
    set reason [::auto_comment::providerReady]
    if {$reason ne ""} { return [dict create error "ERROR: $reason"] }
    if {$::auto_comment::provider eq "openai"} {
        set refuse [::auto_comment::cleartextKeyError $::auto_comment::openaiUrl $::auto_comment::openaiKey]
        if {$refuse ne ""} { return [dict create error "ERROR: $refuse"] }
    }
    set url [::auto_comment::chatEndpoint]
    set body [::auto_comment::chatBody $prompt $maxTokens]
    if {[catch {set tmpfile [::auto_comment::writeRequestFile $body chat]} err]} {
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    if {[catch {set replyfile [::auto_comment::writeRequestFile "" reply]} err]} {
        catch {file delete -force $tmpfile}
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    set args [list curl -sS -L --post301 --post302 {*}[::auto_comment::post303Flag] \
        --connect-timeout 15 --max-time 180 \
        -H {Content-Type: application/json} -X POST \
        -o $replyfile -w {%{http_code}} --data-binary @$tmpfile]
    if {[regexp -nocase {^https://} $url]} { lappend args --proto-redir =https }
    set authfile ""
    set auth [::auto_comment::chatAuth]
    if {$auth ne ""} {
        if {[catch {set authfile [::auto_comment::writeCurlConfig $auth]} err]} {
            catch {file delete -force $tmpfile}
            catch {file delete -force $replyfile}
            return [dict create error "ERROR: cannot write the request: $err"]
        }
        lappend args --config $authfile
    }
    lappend args $url
    if {[catch {set errfile [::auto_comment::writeRequestFile "" err]} err]} {
        catch {file delete -force $tmpfile}
        catch {file delete -force $replyfile}
        if {$authfile ne ""} { catch {file delete -force $authfile} }
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    return [dict create args $args tmpfile $tmpfile replyfile $replyfile \
        errfile $errfile authfile $authfile]
}

proc ::auto_comment::chatCleanup {spec} {
    catch { file delete -force [dict get $spec tmpfile] }
    catch { file delete -force [dict get $spec authfile] }
    return
}

proc ::auto_comment::queryChat {prompt {maxTokens 300}} {
    set spec [::auto_comment::chatSpec $prompt $maxTokens]
    if {[dict exists $spec error]} { return [dict get $spec error] }
    set args [dict get $spec args]
    set replyfile [dict get $spec replyfile]
    set errfile [dict get $spec errfile]

    set result ""
    set ok 0
    if {![catch {exec {*}$args 2> $errfile} result]} { set ok 1 }
    ::auto_comment::chatCleanup $spec

    set raw [::auto_comment::readAndDelete $replyfile]
    set reason [string trim [::auto_comment::readAndDelete $errfile]]
    set status ""
    regexp {^([0-9]{3})} [string trim $result] -> status

    if {!$ok} {
        set failure [::auto_comment::replyFailure $status $raw [expr {[dict get $spec authfile] ne ""}]]
        if {$failure ne ""} { return $failure }
        if {$reason eq ""} { set reason "curl exited without a message" }
        return "ERROR: request failed: $reason"
    }
    set failure [::auto_comment::replyFailure $status $raw [expr {[dict get $spec authfile] ne ""}]]
    if {$failure ne ""} { return $failure }
    set text [::auto_comment::finishReply $raw]
    if {$text eq ""} {
        return "ERROR: [::auto_comment::emptyReplyError $status $raw]"
    }
    return $text
}

# ::auto_comment::finishReply
#   Turn a raw response into the text a caller writes: extract it, then apply the
#   same normalisation the native providers use. The prompt asks for plain text;
#   a model that ignores that must not be able to put "nf3" or "**bold**" into
#   the PGN.
proc ::auto_comment::finishReply {raw} {
    return [string trim [::auto_comment::cleanupText [::auto_comment::replyText $raw]]]
}

# ::auto_comment::queryAsync
#   The same request as queryChat, without blocking the Tk event loop. The
#   reply is read from the curl pipe by fileevent and handed to callback as
#   `text` (or an "ERROR: ..." string). Native Gemini/DeepSeek requests still
#   block: their transports are separate and are not on the review path.
proc ::auto_comment::queryAsync {prompt {maxTokens 300} callback} {
    set why ""
    catch { set why [::auto_comment::providerReady] }
    if {$why ne ""} {
        after 0 [list {*}$callback "ERROR: $why"]
        return ""
    }
    set parser ""
    switch -- $::auto_comment::provider {
        gemini {
            set spec [::auto_comment::geminiSpec $prompt]
            set parser ::auto_comment::geminiText
        }
        deepseek {
            set spec [::auto_comment::deepseekSpec $prompt]
            set parser ::auto_comment::deepseekText
        }
        default {
            set spec [::auto_comment::chatSpec $prompt $maxTokens]
        }
    }
    if {[dict exists $spec error]} {
        after 0 [list {*}$callback [dict get $spec error]]
        return ""
    }
    set args [dict get $spec args]
    if {[catch {set chan [open [list | {*}$args] r]} err]} {
        ::auto_comment::chatCleanup $spec
        after 0 [list {*}$callback "ERROR: $err"]
        return ""
    }
    fconfigure $chan -blocking 0 -buffering none
    if {![info exists ::auto_comment::asyncSeq]} { set ::auto_comment::asyncSeq 0 }
    incr ::auto_comment::asyncSeq
    set token "async$::auto_comment::asyncSeq"
    set ::auto_comment::async($token) [dict create chan $chan spec $spec out "" \
        callback $callback parser $parser]
    fileevent $chan readable [list ::auto_comment::asyncRead $token]
    return $token
}

proc ::auto_comment::asyncRead {token} {
    if {![info exists ::auto_comment::async($token)]} { return }
    set st $::auto_comment::async($token)
    set chan [dict get $st chan]
    if {![eof $chan]} {
        dict append st out [read $chan]
        set ::auto_comment::async($token) $st
        return
    }
    dict append st out [read $chan]
    fileevent $chan readable {}
    catch { close $chan }
    set spec [dict get $st spec]
    ::auto_comment::chatCleanup $spec
    set cb [dict get $st callback]
    set parser [dict get $st parser]
    set raw [expr {[dict exists $spec replyfile] ? [::auto_comment::readAndDelete [dict get $spec replyfile]] : [dict get $st out]}]
    set reason ""
    catch { set reason [string trim [::auto_comment::readAndDelete [dict get $spec errfile]]] }
    set status ""
    if {[dict exists $spec replyfile]} {
        regexp {^([0-9]{3})} [string trim [dict get $st out]] -> status
    }
    set auth [expr {[dict get $spec authfile] ne ""}]
    unset ::auto_comment::async($token)

    if {$parser ne ""} {
        {*}$cb [{*}$parser $raw]
        return
    }
    set failure [::auto_comment::replyFailure $status $raw $auth]
    if {$failure ne ""} {
        {*}$cb $failure
        return
    }
    if {$reason ne "" && $status eq "000"} {
        {*}$cb "ERROR: request failed: $reason"
        return
    }
    set text [::auto_comment::finishReply $raw]
    if {$text eq ""} {
        set text "ERROR: [::auto_comment::emptyReplyError $status $raw]"
    }
    {*}$cb $text
    return
}

proc ::auto_comment::cancelAsync {token} {
    if {$token eq "" || ![info exists ::auto_comment::async($token)]} { return }
    set st $::auto_comment::async($token)
    set chan [dict get $st chan]
    set pid ""
    catch { set pid [pid $chan] }
    if {$pid ne ""} { catch { exec kill $pid } }
    fileevent $chan readable {}
    catch { close $chan }
    ::auto_comment::chatCleanup [dict get $st spec]
    unset ::auto_comment::async($token)
    return
}

# ::auto_comment::modelChoices
#   Returns the fallback list of model ids for the given provider.  These are
#   only defaults; the "Load Models" button replaces them with the live list
#   retrieved from the provider.
#
proc ::auto_comment::modelChoices {provider} {
    switch -- $provider {
        ollama {
            # what the hosted service serves to a chat-completions client; "Load
            # Models" replaces this with the live list
            return {deepseek-v4.1-flash glm-5.3-flash kimi-k2.6 minimax-m3 gpt-oss:120b}
        }
        deepseek { return {deepseek-v4-pro deepseek-flash} }
        gemini {
            return {gemini-3.6-flash gemini-3.5-flash-lite gemini-2.5-flash gemini-2.5-flash-lite}
        }
        opencode {
            # Chat-completions models the gateway serves to other clients. GPT
            # and Grok are Responses, Claude and most Qwen are Messages, Jev is
            # SystemOne, and the free tier answers OpenCode itself (403 here):
            # listing any of those would only produce a failed request. "Load
            # Models" asks the gateway and filters the same way.
            return {glm-5.3-flash deepseek-v4.1-flash minimax-m3 kimi-k2.6 mistral-large-4}
        }
    }
    # local and openai list what the endpoint reports; nothing is guessed
    return {}
}

# ::auto_comment::syncModelCombo
#   Points a model combobox at the model variable of the currently selected
#   provider and refreshes its choices, so the user can pick the model every
#   time the Game Comment dialog is opened.
#
proc ::auto_comment::syncModelCombo {combo} {
    if {![winfo exists $combo]} { return }
    # "none" - and any value a hand-edited options file might hold - binds to a
    # scratch variable, so the model field stays empty instead of showing
    # Gemini's model beside "LLM Provider: none".
    switch -- $::auto_comment::provider {
        local    { set var ::auto_comment::localModel }
        ollama   { set var ::auto_comment::ollamaModel }
        openai   { set var ::auto_comment::openaiModel }
        opencode { set var ::auto_comment::opencodeModel }
        gemini   { set var ::auto_comment::model }
        deepseek { set var ::auto_comment::deepseekModel }
        default  { set var ::auto_comment::noModel }
    }
    $combo configure -textvariable $var \
        -values [::auto_comment::modelChoices $::auto_comment::provider]
}

# ::auto_comment::syncProviderCombo
#   Show the stored provider in a provider combobox, and offer the labels. The
#   widget holds the label while ::auto_comment::provider holds the id, so a
#   caller that changes the provider (a test, a restored session) has one place
#   to bring the display back in step.
proc ::auto_comment::syncProviderCombo {combo} {
    if {![winfo exists $combo]} { return "" }
    $combo configure -values [::auto_comment::providerLabels]
    $combo set [::auto_comment::providerLabel $::auto_comment::provider]
    return [$combo get]
}

# ::auto_comment::pickProvider
#   Take the provider the user picked out of a label. Returns the stored id, or
#   "" when the label is not one of ours (nothing is changed then, so an
#   unreadable value cannot silently move the user to another channel).
proc ::auto_comment::pickProvider {label} {
    set id [::auto_comment::providerFromLabel $label]
    if {$id ne ""} { set ::auto_comment::provider $id }
    return $id
}

# ::auto_comment::chooseProvider
#   The settings dialog's <<ComboboxSelected>> handler: store the id the label
#   names, put the display back if the label was stale, and show that channel's
#   section.
proc ::auto_comment::chooseProvider {w} {
    ::auto_comment::pickProvider [$w.content.provider get]
    ::auto_comment::syncProviderCombo $w.content.provider
    ::auto_comment::syncProviderSections $w
}

# ::auto_comment::chooseProviderForModel
#   The Game Comment dialog's handler: the same label-to-id step, then the model
#   field follows the provider it now names.
proc ::auto_comment::chooseProviderForModel {combo modelCombo} {
    ::auto_comment::pickProvider [$combo get]
    ::auto_comment::syncProviderCombo $combo
    ::auto_comment::syncModelCombo $modelCombo
}

# ::auto_comment::refreshAfterSettings
#   Bring the calling dialog's provider and model comboboxes back in step after
#   the settings dialog closes: both may have been changed there.
proc ::auto_comment::refreshAfterSettings {modelCombo providerCombo} {
    ::auto_comment::syncProviderCombo $providerCombo
    ::auto_comment::syncModelCombo $modelCombo
}

# ::auto_comment::openSettings
#   Opens the settings dialog and, once it is closed, refreshes the supplied
#   comboboxes in case the provider or model was changed there.
#
proc ::auto_comment::openSettings {combo {providerCombo ""}} {
    ::auto_comment::configureApiKey
    if {[winfo exists .autoCommentConfig]} {
        # The script runs when the dialog is destroyed, so `winfo exists` has to
        # be evaluated then: in the old double-quoted bind it was substituted
        # here, the test became a constant, and the refresh never ran.
        bind .autoCommentConfig <Destroy> \
            "+if {!\[winfo exists .autoCommentConfig\]} { ::auto_comment::refreshAfterSettings {$combo} {$providerCombo} }"
    }
}

# ::auto_comment::syncProviderSections
#   Show only the section that belongs to the selected provider. Five sets of
#   fields packed at once is unreadable, and the dialog is the only place a user
#   finds out that a local model needs no key.
proc ::auto_comment::syncProviderSections {w} {
    if {![winfo exists $w.content]} { return }
    set want $::auto_comment::provider
    if {$want ni {none local ollama openai opencode gemini deepseek}} { set want none }
    # The "no model yet" note lives in a frame called "note", not "none"; without
    # this the default provider matched no section and the dialog opened with no
    # body at all - which is the one state a fresh install is in.
    set show [expr {$want eq "none" ? "note" : $want}]
    foreach name {note local ollama openai opencode gemini deepseek} {
        set frame $w.content.$name
        if {![winfo exists $frame]} { continue }
        if {$name eq $show} {
            # Plain pack, no -before: every section is a child of $w.content, which
            # is itself packed above $w.buttons, so the order inside the content
            # frame is all that matters - and Tk refuses -before across masters.
            pack $frame -fill x -pady {0 10}
        } else {
            pack forget $frame
        }
    }
    # The sections are very different heights, so a switch from "none" to a
    # five-widget section would otherwise leave the dialog sized for two lines.
    # Size only: re-centring here would make the window jump on every change.
    if {[winfo exists $w] && [winfo ismapped $w]} {
        update idletasks
        # Size only: Tk keeps the window where it is. Passing a position read
        # back from winfo would hand the window manager its own coordinates and
        # let the dialog drift on every provider change.
        set wd [winfo reqwidth $w]
        set ht [winfo reqheight $w]
        # fitWindow caps a new dialog on the screen; this path grows one that is
        # already up, so it has to cap the same way. Without it a switch made
        # near the bottom edge grows the window downward and takes the OK row
        # off the screen - measured at 1633 on a 1440-tall desktop, 193px below
        # the edge - and the tallest section is already 654px against the 688px
        # a 1366x768 display leaves after fitWindow's margins.
        set maxW [expr {[winfo screenwidth $w] - 40}]
        set maxH [expr {[winfo screenheight $w] - 80}]
        if {$wd > $maxW} { set wd $maxW }
        if {$ht > $maxH} { set ht $maxH }
        # Capping the height is not enough on its own: the window keeps its top,
        # so a capped dialog can still hang past the bottom edge. Lift it by the
        # overlap it would have, which leaves a dialog that fits exactly where
        # the user put it and needs no assumption about the window decoration.
        set limit [expr {[winfo screenheight $w] - 40}]
        set over [expr {[winfo rooty $w] + $ht - $limit}]
        if {$over > 0} {
            set y [expr {max(0, [winfo y $w] - $over)}]
            wm geometry $w "${wd}x${ht}+[winfo x $w]+${y}"
        } else {
            wm geometry $w "${wd}x${ht}"
        }
    }
}

# ::auto_comment::configureApiKey
#   Dialog to configure LLM provider and API keys.
#
proc ::auto_comment::configureApiKey {} {
    set w .autoCommentConfig
    if {[winfo exists $w]} {
        raise $w
        return
    }

    toplevel $w
    wm title $w "Auto Comment - Settings"
    wm resizable $w 1 1
    wm minsize $w 320 200

    ttk::frame $w.content -padding 15
    pack $w.content -fill both -expand 1

    ttk::label $w.content.info -text \
        "Configure your LLM provider and API key(s).\nEach provider keeps its own key and model, so you can pick a different one above at any time without losing the settings you already have.\nKeys are stored locally on your machine only.\nOK saves these settings to your options file." \
        -wraplength 420 -justify left
    pack $w.content.info -anchor w -pady {0 10}

    # Provider selector
    ttk::label $w.content.provlbl -text "LLM Provider:"
    pack $w.content.provlbl -anchor w
    # The combo shows a label and the options file keeps the id: see
    # providerLabel. Without the label the two Ollama channels read as
    # "local" and "ollama", which is the same product twice.
    ttk::combobox $w.content.provider \
        -values [::auto_comment::providerLabels] -state readonly -width 28
    pack $w.content.provider -anchor w -pady {0 10}
    bind $w.content.provider <<ComboboxSelected>> \
        [list ::auto_comment::chooseProvider $w]

    # --- none ---
    ttk::label $w.content.note -justify left -wraplength 420 -text \
        "No model selected.\nGame comments are written without AI prose; the review itself still runs."

    # --- Local (Ollama-style) ---
    ttk::labelframe $w.content.local -text "Local model" -padding 10
    ttk::label $w.content.local.urllbl -text "Endpoint:"
    pack $w.content.local.urllbl -anchor w
    ttk::entry $w.content.local.url -width 50 -textvariable ::auto_comment::localUrl
    pack $w.content.local.url -fill x -pady {0 5}
    ttk::label $w.content.local.modellbl -text "Model:"
    pack $w.content.local.modellbl -anchor w
    ttk::combobox $w.content.local.model -width 30 -textvariable ::auto_comment::localModel \
        -values [::auto_comment::modelChoices local]
    pack $w.content.local.model -anchor w -pady {0 5}
    ttk::button $w.content.local.load -text "Load Models" \
        -command [list ::auto_comment::loadModels $w.content.local.model local]
    pack $w.content.local.load -anchor w -pady {0 5}
    ttk::label $w.content.local.hint -justify left -wraplength 420 -text \
        "Works with Ollama, LM Studio and any server that answers /api/chat. No key and no GPU required: a small model is enough."
    pack $w.content.local.hint -anchor w

    # --- Ollama Cloud ---
    # Its own section, not a preset of the OpenAI-compatible one: the base URL is
    # the thing users get wrong (the native API lives under /api, the
    # OpenAI-compatible one under /v1), so it is not a field at all here.
    ttk::labelframe $w.content.ollama -text "Ollama Cloud" -padding 10
    ttk::label $w.content.ollama.keylbl -text "API key:"
    pack $w.content.ollama.keylbl -anchor w
    ttk::entry $w.content.ollama.key -width 50 -textvariable ::auto_comment::ollamaKey -show "*"
    pack $w.content.ollama.key -fill x -pady {0 5}
    ttk::label $w.content.ollama.modellbl -text "Model:"
    pack $w.content.ollama.modellbl -anchor w
    ttk::combobox $w.content.ollama.model -width 30 -textvariable ::auto_comment::ollamaModel \
        -values [::auto_comment::modelChoices ollama]
    pack $w.content.ollama.model -anchor w -pady {0 5}
    ttk::button $w.content.ollama.load -text "Load Models" \
        -command [list ::auto_comment::loadModels $w.content.ollama.model ollama]
    pack $w.content.ollama.load -anchor w -pady {0 5}
    ttk::button $w.content.ollama.open -text "Get an Ollama Key" -command [list openURL $::auto_comment::ollamaKeyUrl]
    pack $w.content.ollama.open -anchor w -pady {0 5}
    ttk::label $w.content.ollama.hint -justify left -wraplength 420 -text \
        "Ollama's hosted models, including the ones too large to run locally. Requests go to https://ollama.com/api/chat; the key comes from your Ollama account."
    pack $w.content.ollama.hint -anchor w

    # --- OpenAI-compatible ---
    ttk::labelframe $w.content.openai -text "Cloud / OpenAI-compatible" -padding 10
    ttk::label $w.content.openai.urllbl -text "Endpoint:"
    pack $w.content.openai.urllbl -anchor w
    ttk::entry $w.content.openai.url -width 50 -textvariable ::auto_comment::openaiUrl
    pack $w.content.openai.url -fill x -pady {0 5}
    ttk::label $w.content.openai.keylbl -text "API key (leave empty if the endpoint needs none):"
    pack $w.content.openai.keylbl -anchor w
    ttk::entry $w.content.openai.key -width 50 -textvariable ::auto_comment::openaiKey -show "*"
    pack $w.content.openai.key -fill x -pady {0 5}
    ttk::label $w.content.openai.modellbl -text "Model:"
    pack $w.content.openai.modellbl -anchor w
    ttk::combobox $w.content.openai.model -width 30 -textvariable ::auto_comment::openaiModel \
        -values [::auto_comment::modelChoices openai]
    pack $w.content.openai.model -anchor w -pady {0 5}
    ttk::button $w.content.openai.load -text "Load Models" \
        -command [list ::auto_comment::loadModels $w.content.openai.model openai]
    pack $w.content.openai.load -anchor w -pady {0 5}
    ttk::label $w.content.openai.hint -justify left -wraplength 420 -text \
        "DeepSeek, Gemini's compatibility endpoint, vLLM, a gateway: anything that speaks /v1/chat/completions. Either the base URL or the full endpoint can be pasted."
    pack $w.content.openai.hint -anchor w

    # --- OpenCode Console ---
    ttk::labelframe $w.content.opencode -text "OpenCode Console" -padding 10
    ttk::label $w.content.opencode.keylbl -text "API key:"
    pack $w.content.opencode.keylbl -anchor w
    ttk::entry $w.content.opencode.key -width 50 -textvariable ::auto_comment::opencodeKey -show "*"
    pack $w.content.opencode.key -fill x -pady {0 5}
    ttk::label $w.content.opencode.modellbl -text "Model:"
    pack $w.content.opencode.modellbl -anchor w
    ttk::combobox $w.content.opencode.model -width 30 -textvariable ::auto_comment::opencodeModel \
        -values [::auto_comment::modelChoices opencode]
    pack $w.content.opencode.model -anchor w -pady {0 5}
    ttk::button $w.content.opencode.load -text "Load Models" \
        -command [list ::auto_comment::loadModels $w.content.opencode.model opencode]
    pack $w.content.opencode.load -anchor w -pady {0 5}
    ttk::button $w.content.opencode.open -text "Get an API Key" -command {
        openURL "https://opencode.ai/console"
    }
    pack $w.content.opencode.open -anchor w -pady {0 5}
    ttk::label $w.content.opencode.hint -justify left -wraplength 420 -text \
        "OpenCode's model gateway: paid models or a Go plan. Free models only answer OpenCode itself, so they are not listed. Only chat-completions models work here; copy any other model id from the console."
    pack $w.content.opencode.hint -anchor w

    # --- Gemini section ---
    ttk::labelframe $w.content.gemini -text "Google Gemini" -padding 10
    pack $w.content.gemini -fill x -pady {0 10}

    ttk::label $w.content.gemini.keylbl -text "API Key:"
    pack $w.content.gemini.keylbl -anchor w
    ttk::entry $w.content.gemini.key -width 50 -textvariable ::auto_comment::apiKey
    pack $w.content.gemini.key -fill x -pady {0 5}

    ttk::label $w.content.gemini.modellbl -text "Model:"
    pack $w.content.gemini.modellbl -anchor w
    ttk::combobox $w.content.gemini.model -width 30 -textvariable ::auto_comment::model \
        -values [::auto_comment::modelChoices gemini]
    pack $w.content.gemini.model -anchor w -pady {0 5}

    ttk::button $w.content.gemini.load -text "Load Models" \
        -command [list ::auto_comment::loadModels $w.content.gemini.model gemini]
    pack $w.content.gemini.load -anchor w -pady {0 5}

    ttk::button $w.content.gemini.open -text "Get Gemini Key" -command {
        openURL "https://aistudio.google.com/apikey"
    }
    pack $w.content.gemini.open -anchor w

    # --- DeepSeek section ---
    ttk::labelframe $w.content.deepseek -text "DeepSeek" -padding 10
    pack $w.content.deepseek -fill x -pady {0 10}

    ttk::label $w.content.deepseek.keylbl -text "API Key:"
    pack $w.content.deepseek.keylbl -anchor w
    ttk::entry $w.content.deepseek.key -width 50 -textvariable ::auto_comment::deepseekApiKey
    pack $w.content.deepseek.key -fill x -pady {0 5}

    ttk::label $w.content.deepseek.modellbl -text "Model:"
    pack $w.content.deepseek.modellbl -anchor w
    ttk::combobox $w.content.deepseek.model -width 30 -textvariable ::auto_comment::deepseekModel \
        -values [::auto_comment::modelChoices deepseek]
    pack $w.content.deepseek.model -anchor w -pady {0 5}

    ttk::button $w.content.deepseek.load -text "Load Models" \
        -command [list ::auto_comment::loadModels $w.content.deepseek.model deepseek]
    pack $w.content.deepseek.load -anchor w -pady {0 5}

    ttk::button $w.content.deepseek.open -text "Get DeepSeek Key" -command {
        openURL "https://platform.deepseek.com/api_keys"
    }
    pack $w.content.deepseek.open -anchor w

    # --- Buttons ---
    ttk::frame $w.buttons -padding {15 5}
    pack $w.buttons -fill x

    ttk::button $w.buttons.ok -text "OK" -command [list ::auto_comment::saveSettings $w]
    pack $w.buttons.ok -side right -padx 5

    bind $w <Return> [list ::auto_comment::saveSettings $w]
    bind $w <Escape> "destroy $w"

    ::auto_comment::syncProviderCombo $w.content.provider
    ::auto_comment::syncProviderSections $w
    ::auto_comment::fitWindow $w
}

# ::auto_comment::saveSettings
#   Persist the provider settings and close the dialog.
#
#   These variables live in this namespace, and options.dat is loaded before
#   tcl/tools/auto_comment.tcl exists, so a file holding only
#   "set ::auto_comment::provider ..." would fail to load ("parent namespace
#   doesn't exist") at the next start. options.write is the whole-file saver
#   behind Options > Save Options: it writes "namespace eval" for every
#   registered namespace first, so the namespace exists by the time the value
#   is set. Using it here is also why the dialog no longer asks the user to
#   remember a separate menu action: a key typed and then lost on exit is the
#   one failure that looks like the feature is broken.
proc ::auto_comment::saveSettings {w} {
    set saved 0
    if {[catch {set saved [options.write]} err]} {
        tk_messageBox -icon warning -type ok -title "Auto Comment" \
            -message "Could not save the settings to the options file:\n\n$err" \
            -parent $w
        return
    }
    if {!$saved} {
        # options.write reports a failed open itself and returns 0. Keep the
        # dialog: a provider and a key typed and then thrown away with the
        # window is the silent loss this persistence exists to prevent.
        return
    }
    destroy $w
}

# ::auto_comment::fetchLichessEval
#   Fetches cloud evaluation from the Lichess API.
#   Returns the raw JSON string, or "" on failure.
#
proc ::auto_comment::fetchLichessEval {fen {variant "standard"}} {
    set urlFen [string map {" " "%20"} $fen]
    set url "$::auto_comment::lichessApiUrl?fen=$urlFen&multiPv=5&variant=$variant"

    set result ""
    if {![catch {exec curl -s --max-time 10 -H "Accept: */*" $url} result]} {
        # Check that it contains PV data (not an error response)
        if {[regexp {"pvs"} $result]} {
            return $result
        }
    }
    return ""
}

# ::auto_comment::fetchChessDBEval
#   Fallback: fetches evaluation from chessdb.cn.
#   Returns the raw JSON/text string, or "" on failure.
#
proc ::auto_comment::fetchChessDBEval {fen} {
    set urlFen [string map {" " "%20" "/" "%2F"} $fen]
    set url "$::auto_comment::chessdbApiUrl?action=queryall&board=$urlFen&showall=0&json=1"

    set result ""
    if {![catch {exec curl -s --max-time 10 $url} result]} {
        if {[string length $result] > 5} {
            return $result
        }
    }
    return ""
}
# ::auto_comment::formatLichessEval
#   Converts raw Lichess cloud eval JSON into human-readable text
#   with SAN notation and formatted scores.
#
proc ::auto_comment::formatLichessEval {jsonData fen} {
    # Determine side to move
    set color [lindex [split $fen] 1]
    set sideToMove [expr {$color eq "w" ? "White" : "Black"}]

    # Extract depth
    set depth ""
    regexp {"depth":(\d+)} $jsonData -> depth

    set isBlack [expr {$color eq "b"}]
    set result "Position evaluation (depth $depth). $sideToMove to move.\n"
    append result "Lines are ranked from best to worst for $sideToMove. Line 1 is the engine's top recommendation.\n"
    append result "Each line has a quality label showing how it compares to the best move.\n"

    # Move-label mapping: first SAN move -> quality label
    set moveLabels [dict create]

    # First pass: collect all PVs with their scores
    set pvList {}
    if {[regexp -indices {"pvs"\s*:\s*\[} $jsonData match]} {
        set arrayStart [lindex $match 1]
        set remaining [string range $jsonData $arrayStart end]

        while {[regexp -indices {\{[^\}]+\}} $remaining objMatch]} {
            set objStart [lindex $objMatch 0]
            set objEnd [lindex $objMatch 1]
            set obj [string range $remaining $objStart $objEnd]

            set moves ""
            set cp ""
            set mate ""

            regexp {"moves"\s*:\s*"([^"]*)"} $obj -> moves
            regexp {"cp"\s*:\s*(-?\d+)} $obj -> cp
            regexp {"mate"\s*:\s*(-?\d+)} $obj -> mate

            if {$moves ne ""} {
                lappend pvList [list $moves $cp $mate]
            }

            set remaining [string range $remaining [expr {$objEnd + 1}] end]
        }
    }

    # Get the best score (first line) for comparison
    set bestCp 0
    if {[llength $pvList] > 0} {
        set firstCp [lindex [lindex $pvList 0] 1]
        if {$firstCp ne ""} {
            # Normalize to side-to-move perspective for comparison
            set bestCp [expr {$isBlack ? -1 * $firstCp : $firstCp}]
        }
    }

    # No PVs found — return empty
    if {[llength $pvList] == 0} {
        return [list "" [dict create]]
    }

    # Second pass: format with quality labels
    set lineNum 1
    foreach pv $pvList {
        lassign $pv moves cp mate

        # Compute quality label based on centipawn loss from best
        set label "best"
        if {$lineNum > 1 && $cp ne ""} {
            set thisCp [expr {$isBlack ? -1 * $cp : $cp}]
            set cpLoss [expr {$bestCp - $thisCp}]
            if {$cpLoss < 10} {
                set label "equal"
            } elseif {$cpLoss < 50} {
                set label "slightly worse"
            } elseif {$cpLoss < 100} {
                set label "inaccuracy"
            } elseif {$cpLoss < 200} {
                set label "mistake"
            } else {
                set label "blunder"
            }
        } elseif {$lineNum == 1 && $mate ne ""} {
            set label "best (mate)"
        }

        # Convert UCI to SAN
        set sanMoves [::lichess_eval::uciToSan $moves $fen]
        set numberedMoves [::lichess_eval::formatLine $fen $sanMoves]

        # Extract the first SAN move for move-label mapping
        set firstMove [lindex [split $sanMoves] 0]
        if {$firstMove ne ""} {
            dict set moveLabels $firstMove $label
        }

        append result "Line $lineNum ($label): $numberedMoves\n"
        incr lineNum
    }

    return [list $result $moveLabels]
}

# ::auto_comment::formatChessDBEval
#   Converts raw ChessDB JSON into human-readable text.
#   ChessDB already provides SAN notation, scores, and winrates.
#
proc ::auto_comment::formatChessDBEval {jsonData fen} {
    set color [lindex [split $fen] 1]
    set sideToMove [expr {$color eq "w" ? "White" : "Black"}]

    set result "Position evaluation (chessdb.cn). $sideToMove to move.\n"
    append result "Moves are ranked from best to worst for $sideToMove. Move 1 is the engine's top recommendation.\n"
    append result "Each move has a quality label showing how it compares to the best move.\n"
    append result "Top moves:\n"

    # Move-label mapping: SAN move -> quality label
    set moveLabels [dict create]

    # Parse individual move objects from the JSON "moves" array
    # to avoid cross-object mismatches when some scores are "??"
    set moveList {}
    if {[regexp -indices {"moves"\s*:\s*\[} $jsonData arrayMatch]} {
        set arrayStart [lindex $arrayMatch 1]
        set remaining [string range $jsonData $arrayStart end]

        while {[llength $moveList] < 5 && \
               [regexp -indices {\{[^\}]+\}} $remaining objMatch]} {
            set objStart [lindex $objMatch 0]
            set objEnd [lindex $objMatch 1]
            set obj [string range $remaining $objStart $objEnd]

            set san ""
            set score ""
            set winrate ""
            regexp {"san"\s*:\s*"([^"]*)"} $obj -> san
            regexp {"score"\s*:\s*(-?\d+)} $obj -> score
            regexp {"winrate"\s*:\s*"([^"]*)"} $obj -> winrate

            # Only include moves with a known numeric score
            if {$san ne "" && $score ne ""} {
                lappend moveList [list $san $score $winrate]
            }

            set remaining [string range $remaining [expr {$objEnd + 1}] end]
        }
    }

    # No moves found — return empty
    if {[llength $moveList] == 0} {
        return [list "" [dict create]]
    }

    # Get best score for comparison (chessdb scores are from side-to-move perspective)
    set bestScore [lindex [lindex $moveList 0] 1]

    set count 0
    foreach mv $moveList {
        lassign $mv san score winrate
        incr count

        set label "best"
        if {$count > 1} {
            set cpLoss [expr {$bestScore - $score}]
            if {$cpLoss < 10} {
                set label "equal"
            } elseif {$cpLoss < 50} {
                set label "slightly worse"
            } elseif {$cpLoss < 100} {
                set label "inaccuracy"
            } elseif {$cpLoss < 200} {
                set label "mistake"
            } else {
                set label "blunder"
            }
        }

        dict set moveLabels $san $label
        append result "$count. $san ($label)\n"
    }

    return [list $result $moveLabels]
}

proc ::auto_comment::buildPrompt {fen evalText movePlayed variant {opening ""} {nagSymbol ""} {includeSymbols 1} {whitePerspective 0} {whoMoved ""} {isSingleMove 0} {pgn ""} {treeInfo ""}} {
    if {$whoMoved eq ""} { set whoMoved "the player who just moved" }

    set prompt "You are a chess commentator writing a short, plain-language annotation for club-level players. You are given objective engine analysis. TRUST it completely: use the quality labels and the VERDICT exactly as provided, and add only a clear explanation of WHY.

Write your commentary about the move just played by $whoMoved.

===== HOW TO READ THE ENGINE ANALYSIS =====
- \"Line N\" is a candidate continuation (PV). Line 1 is ALWAYS the engine's best move; later lines are progressively worse alternatives. Each line already carries a quality label (best, equal, slightly worse, inaccuracy, mistake, blunder).
- Move notation tells you WHO moved: \"13.\" is a White move, \"13...\" is a Black move. A candidate line beginning \"13...Re8\" is therefore a Black alternative. A move is good for Black when it LOWERS White's score, and good for White when it RAISES White's score.
- The played move's quality is stated in the VERDICT line. Repeat that label; do not recompute or second-guess it. The VERDICT already accounts for which side played the move.
- Numeric scores beside a line are from the SIDE TO MOVE's perspective (the evaluation block states who is to move): a positive score favors the side to move, a negative score favors the opponent. Scores labeled \"White's perspective\" (including all PGN/GROUND TRUTH and \"Engine score\" values) are from White's side regardless of who is to move: a positive value favors White and a negative value favors Black. A large value (e.g. -80.00 or +50.00) means a decisive or forced win, never equality.
- Scale reference: +/- 1.00 is roughly one pawn; +/- 10.00 is winning; mate is given as \"Mate in N\".

===== STRICT RULES =====
1. Ground every claim in the provided lines. Do NOT invent plans, motifs, tactics, or ideas that are not present in the PV sequences.
2. Never propose a move unless it appears in one of the provided lines, and never propose a move that was already played earlier in the game (check the PGN).
3. Castling: read castling rights from the FEN field (e.g. \"KQkq\", \"kq\", or \"-\"). Do not mention castling for a side whose right is absent.
4. For a blunder, mistake, or inaccuracy, name the better alternative from Line 1 and the concrete tactical or structural reason it is better.

===== OUTPUT FORMAT =====
- First line (exact form): \"VERDICT: $movePlayed is a {adjective} move according to the engine analysis.\" where {adjective} is the label in the VERDICT line. If the move delivers checkmate or forces a win, use \"best\". If the VERDICT line states that the move is absent from the engine's lines, use \"questionable\".
- Then write ONE concise paragraph:
  * blunder/mistake/inaccuracy: name the Line 1 alternative and why it is better. Under 70 words.
  * best/equal: explain the point of the move (threat, prevention, stabilization) using only the PV. Under 40 words.
  * checkmate: simply note that the move delivers checkmate and wins the game. Under 30 words.
- Use the tree statistics only to note whether the move is a common theoretical choice or a sideline.
- Plain text only: no markdown, no headings, no bold or italics."

    append prompt "\n\n===== GAME INFORMATION =====\n"
    if {$pgn ne ""} { append prompt "\nFull PGN:\n$pgn\n" }
    if {$opening ne ""} { append prompt "\nOpening: $opening" }
    append prompt "\n\nCurrent move: $movePlayed (by $whoMoved)"
    append prompt "\nFEN: $fen"
    if {$nagSymbol ne ""} { append prompt "\nAnnotation: $nagSymbol" }

    if {$treeInfo ne ""} {
        append prompt "\n\n===== TREE STATISTICS =====\n"
        append prompt $treeInfo
    }

    append prompt "\n\n===== ENGINE ANALYSIS =====\n"
    append prompt $evalText

    # For non-English UI languages, ask the LLM to answer in the user's language.
    # Keep engine analysis in standard SAN so move identities remain exact.
    if {$::language ne "E"} {
        if {[info exists ::langName($::language)]} {
            set langFullName $::langName($::language)
        } else {
            set langFullName $::language
        }

        append prompt "\n\n===== LANGUAGE =====\n"
        append prompt "\nCRITICAL: Write your ENTIRE response in $langFullName."

        if {$::translatePieces && [info exists ::transPieces($::language)]} {
            set pieceGuide {}
            set examplesFrom {}
            set examplesTo {}
            foreach {eng loc} $::transPieces($::language) {
                switch -- $eng {
                    K { lappend pieceGuide "King: $loc"; lappend examplesFrom "Ke2"; lappend examplesTo "${loc}e2" }
                    Q { lappend pieceGuide "Queen: $loc"; lappend examplesFrom "Qd1"; lappend examplesTo "${loc}d1" }
                    R { lappend pieceGuide "Rook: $loc"; lappend examplesFrom "Re1"; lappend examplesTo "${loc}e1" }
                    B { lappend pieceGuide "Bishop: $loc"; lappend examplesFrom "Bf4"; lappend examplesTo "${loc}f4" }
                    N { lappend pieceGuide "Knight: $loc"; lappend examplesFrom "Nc3"; lappend examplesTo "${loc}c3" }
                }
            }
            if {[llength $pieceGuide] > 0} {
                append prompt "\nYou MUST convert all chess piece letters to $langFullName notation in your response:"
                append prompt "\n  [join $pieceGuide {, }]"
                append prompt "\nExamples: [lindex $examplesFrom 0] becomes [lindex $examplesTo 0], [lindex $examplesFrom 4] becomes [lindex $examplesTo 4], [lindex $examplesFrom 3] becomes [lindex $examplesTo 3]."
                append prompt "\nPawn moves (e.g. e4, d5, c5) do NOT get a piece letter — leave them unchanged."
                append prompt "\nThe engine analysis above uses English letters (K, Q, R, B, N) — you MUST translate every piece letter when you mention a move in your commentary."
            }
        } else {
            append prompt "\nKeep standard English SAN piece letters (K, Q, R, B, N)."
        }
    }
    return $prompt
}

# ::auto_comment::cleanupText
#   Post-processes LLM output: strips markdown, fixes move notation.
#
proc ::auto_comment::cleanupText {text} {
    # Strip any markdown bold/italic markers the LLM might include
    set text [regsub -all {\*\*([^*]+)\*\*} $text {\1}]
    set text [regsub -all {\*([^*]+)\*} $text {\1}]
    # Fix capitalized pawn moves: A6->a6, C5->c5, etc.
    # One pass per file letter avoids unsafe subst with command substitution.
    foreach cap {A B C D E F G H} {
        set low [string tolower $cap]
        set text [regsub -all "(\[^a-zA-Z\])${cap}(\[1-8\])" $text "\\1${low}\\2"]
    }
    # Determine piece-letter set for case normalization.
    # English defaults to bknqr. For translated-piece languages, derive from transPieces.
    set pieceLetters "bknqr"
    if {$::language ne "E" && $::translatePieces && [info exists ::transPieces($::language)]} {
        set pieceLetters ""
        foreach {eng loc} $::transPieces($::language) {
            if {$eng in {K Q R B N}} {
                set lower [string tolower $loc]
                if {[string length $lower] == 1 && [string is ascii -strict $lower] && [string is alpha -strict $lower]} {
                    append pieceLetters $lower
                }
            }
        }
        if {$pieceLetters eq ""} {
            set pieceLetters "bknqr"
        }
    }

    # Fix lowercase piece moves (nf3->Nf3) and captures (nxf3->Nxf3).
    # One pass per piece letter avoids unsafe subst with command substitution.
    foreach letter [split $pieceLetters ""] {
        set upper [string toupper $letter]
        # Non-letter context before the piece letter
        set text [regsub -all "(\[^a-zA-Z\])${letter}(\[a-h\]\[1-8\])" $text "\\1${upper}\\2"]
        set text [regsub -all "(\[^a-zA-Z\])${letter}(x\[a-h\]\[1-8\])" $text "\\1${upper}\\2"]
        # Start-of-string context
        set text [regsub "^${letter}(\[a-h\]\[1-8\])" $text "${upper}\\1"]
        set text [regsub "^${letter}(x\[a-h\]\[1-8\])" $text "${upper}\\1"]
    }

    # Safety net: convert any remaining English piece letters in move patterns
    # to local notation. This catches cases where the LLM echoes English SAN
    # despite being told to use local notation.
    if {$::language ne "E" && $::translatePieces && [info exists ::transPieces($::language)]} {
        foreach {eng loc} $::transPieces($::language) {
            if {$eng in {K Q R B N} && $eng ne $loc} {
                # Match: PieceLetter + optional disambiguation (file or rank)
                #        + optional 'x' + file + rank
                # E.g.: Nc3, Nxc3, Nbc3, N1c3, Nbxc3
                set pat "(^|\[^a-zA-Z\])${eng}(\[a-h1-8\]?x?\[a-h\]\[1-8\])"
                set text [regsub -all $pat $text "\\1${loc}\\2"]
            }
        }
    }

    return [string trim $text]
}

# ::auto_comment::escapeJson
#   Escapes a string for embedding inside a JSON string value.
#
proc ::auto_comment::escapeJson {str} {
    return [string map {
        "\\" "\\\\"
        "\"" "\\\""
        "\n" "\\n"
        "\r" "\\r"
        "\t" "\\t"
    } $str]
}

# ::auto_comment::fetchGeminiModels
#   Queries the Gemini API for the current list of available models.
#   Returns a list of model names (without the "models/" prefix), or {} on failure.
#
# ::auto_comment::geminiModelsUrl
#   The model-list request, page size included: the warning shows this URL, and
#   the base alone would name a request that was never made.
proc ::auto_comment::geminiModelsUrl {} {
    return "$::auto_comment::geminiApiBase?pageSize=200"
}

proc ::auto_comment::fetchGeminiModels {} {
    set url [::auto_comment::geminiModelsUrl]
    set result ""
    if {[catch {exec curl -s --max-time 15 \
            -H "x-goog-api-key: $::auto_comment::apiKey" \
            $url 2>@1} result]} {
        ::auto_comment::logDebug "Auto Comment: fetchGeminiModels curl error: $result"
        return {}
    }

    set models {}
    foreach {- name} [regexp -all -inline {"name"\s*:\s*"models/([^"]+)"} $result] {
        # Only the text-generation models are relevant for generateContent.
        if {[string match "*gemini*" $name]} {
            lappend models $name
        }
    }
    return [lsort -dictionary $models]
}

# ::auto_comment::fetchDeepSeekModels
#   Queries the DeepSeek API for the current list of available models.
#   Returns a list of model ids, or {} on failure.
#
proc ::auto_comment::fetchDeepSeekModels {} {
    set url "$::auto_comment::deepseekApiBase/models"
    set result ""
    set headers {}
    if {[::auto_comment::cleartextKeyError $url $::auto_comment::deepseekApiKey] eq ""} {
        lappend headers -H "Authorization: Bearer $::auto_comment::deepseekApiKey"
    } else {
        ::auto_comment::logDebug "Auto Comment: not sending the API key to $url: not https"
    }
    if {[catch {exec curl -s --max-time 15 {*}$headers \
            $url 2>@1} result]} {
        ::auto_comment::logDebug "Auto Comment: fetchDeepSeekModels curl error: $result"
        return {}
    }

    set models {}
    foreach {- id} [regexp -all -inline {"id"\s*:\s*"([^"]+)"} $result] {
        lappend models $id
    }
    return [lsort -dictionary $models]
}

# ::auto_comment::loadModels
#   Populates a model combobox with the current models from the given provider.
#   Warns the user if the fetch fails (e.g. missing API key or no network).
#
# ::auto_comment::modelListTargets
#   Where to look for a model list, as a flat list of alternating url and regex
#   pairs. Split out of fetchUrlModels so the shape can be checked without a
#   network: "foreach {target re}" flattens, so each field is its own element.
proc ::auto_comment::modelListTargets {base {modelsUrl ""}} {
    # A flat list of alternating url and regex: "foreach {target re}" reads it,
    # so lappend each field separately. A list of two-element lists would make
    # the whole pair one target and the request would go to a nonsense URL.
    if {$modelsUrl ne ""} {
        # An explicit URL wins: a gateway's model list is not always a child of
        # its chat root (OpenCode serves .../inference/v1/models while chat lives
        # under .../inference/openai/v1/...).
        return [list $modelsUrl {"id"\s*:\s*"([^"]+)"}]
    }
    set base [::auto_comment::baseUrl $base]
    if {$base eq ""} { return {} }
    return [list [::auto_comment::modelsUrl $base] {"id"\s*:\s*"([^"]+)"} \
                 "$base/api/tags"              {"name"\s*:\s*"([^"]+)"}]
}

# ::auto_comment::targetUrls
#   The URLs modelListTargets would ask, as a plain list. loadModels reports
#   these on failure, and taking them from the same function means the reported
#   list cannot drift from the attempted one.
proc ::auto_comment::targetUrls {base} {
    set urls {}
    foreach {target re} [::auto_comment::modelListTargets $base] { lappend urls $target }
    return $urls
}

# ::auto_comment::fetchUrlModels
#   Ask an endpoint what models it has. /v1/models first (OpenAI-compatible),
#   then Ollama's /api/tags for a server that only speaks the native API. Model
#   lists include embedding models, so the caller must let the user choose.
#   A redirect is followed: a base typed as "http://host/v1" answers on its
#   https form, and the model list is how the user finds that out.
proc ::auto_comment::fetchUrlModels {base key {modelsUrl ""}} {
    set ids {}
    foreach {target re} [::auto_comment::modelListTargets $base $modelsUrl] {
        set cmd [list curl -s -L --max-time 10 -H {Accept: application/json}]
        # A keyed request must not be redirected down to cleartext; the key is
        # only attached to https or loopback targets above.
        if {[regexp -nocase {^https://} $target]} { lappend cmd --proto-redir =https }
        set authfile ""
        if {$key ne ""} {
            # the key only rides an https (or loopback) connection, and never
            # rides in argv
            if {[::auto_comment::cleartextKeyError $target $key] eq ""} {
                if {![catch {set authfile [::auto_comment::writeCurlConfig \
                        "Authorization: Bearer $key"]} err]} {
                    lappend cmd --config $authfile
                } else {
                    ::auto_comment::logDebug "Auto Comment: cannot write the auth file: $err"
                }
            } else {
                ::auto_comment::logDebug "Auto Comment: not sending the API key to $target: not https"
            }
        }
        lappend cmd $target
        set raw ""
        set failed [catch {exec {*}$cmd 2>@1} raw]
        if {$authfile ne ""} { catch {file delete -force $authfile} }
        if {$failed} { continue }
        foreach {all id} [regexp -all -inline $re $raw] { lappend ids $id }
        if {[llength $ids]} { break }
    }
    return [lsort -unique $ids]
}

# ::auto_comment::chatCompletionsOnly
#   Drop the models an OpenAI-compatible gateway serves through another API
#   family, because /chat/completions cannot reach them: GPT and Grok are
#   Responses, Claude and most Qwen are Messages, Jev is SystemOne. The live
#   model list does not say which family a model is on, so this keys on the
#   documented table (opencode.ai/v2/docs/console/models). It fails open: an
#   unknown new model stays in the list.
#
#   The free tier is dropped as well: those models answer OpenCode itself and
#   return 403 to any other client, key or no key.
proc ::auto_comment::chatCompletionsOnly {ids} {
    set out {}
    foreach id $ids {
        if {$id in {test big-pickle}} { continue }
        if {[string match "*-free" $id]} { continue }
        if {[regexp {^(gpt-|claude-|gemini-|grok-|muse-|jev-)} $id]} { continue }
        if {[string match "qwen*" $id] && $id ne "qwen3.8-max"} { continue }
        lappend out $id
    }
    return $out
}

# ::auto_comment::parseOllamaTags
#   Model ids out of an /api/tags response, keeping only the ones that can
#   answer a chat request. Every entry carries a capabilities list, and a model
#   without "completion" (clef:27b is decision/vision only) would only produce a
#   failed request - /v1/models listed it anyway, with nothing to filter on.
#
#   The array is split into entries by the key every entry starts with, and the
#   name and the capabilities are read from each entry on its own. One regexp
#   spanning from a name to its capabilities does not work here: Tcl's regexp
#   prefers the longest overall match, so the first name was paired with the
#   last capabilities and every model in between was lost.
proc ::auto_comment::parseOllamaTags {raw} {
    set starts {}
    set pos 0
    # Split at the name key rather than at the object's opening brace: the
    # document's whitespace and its key order are not significant, and relying
    # on "name" being the first property sent a valid response to the all-names
    # fallback, where the capabilities filter does not run.
    while {[regexp -indices -start $pos {"name"\s*:\s*"} $raw m]} {
        lappend starts [lindex $m 0]
        set pos [expr {[lindex $m 1] + 1}]
    }
    set chat {}
    set recognised 0
    set n 0
    foreach start $starts {
        incr n
        if {$n < [llength $starts]} {
            set end [expr {[lindex $starts $n] - 1}]
        } else {
            set end [string length $raw]
        }
        set entry [string range $raw $start $end]
        if {![regexp {"name"\s*:\s*"([^"]+)"} $entry -> name]} { continue }
        incr recognised
        # an entry with no capabilities (an older server) is kept: the list is
        # the only way to find a model, and a wrong entry fails loudly
        if {[regexp {"capabilities"\s*:\s*\[([^\]]*)\]} $entry -> caps] \
                && [string first "completion" $caps] < 0} {
            continue
        }
        lappend chat $name
    }
    if {$recognised == 0} {
        # No entry could be read at all (a shape this parser does not split, for
        # example JSON with a space after the colon): keep every name rather
        # than showing an empty list. A model that was read and then filtered
        # out must not come back here - the filter exists so it is not offered.
        foreach {_ name} [regexp -all -inline {"name"\s*:\s*"([^"]+)"} $raw] {
            lappend chat $name
        }
    }
    return [lsort -dictionary [lsort -unique $chat]]
}

# ::auto_comment::fetchTagModels
#   Ask an Ollama-style server for its native model list, keeping the models that
#   can chat. `apiRoot` is the native API root ("https://ollama.com/api",
#   "http://localhost:11434/api"), and the request goes to its /tags.
#   Returns {answered models}: `answered` is 0 when the request failed, so a
#   caller can tell a server that does not serve that path (LM Studio, vLLM, a
#   gateway) from an Ollama with nothing able to answer.
#
#   Both Ollama channels use this: the local one speaks the same native API as
#   the hosted one, and the native list is the only one that says which models
#   can chat. /v1/models lists an embedding model (nomic-embed-text) exactly
#   like a chat model, and offering it only produces a failed request.
proc ::auto_comment::fetchTagModels {apiRoot {key ""}} {
    # --fail: a server that answers /api/tags with a 404 (LM Studio, vLLM) must
    # count as "no native list", or its empty body would suppress the generic
    # fallback that exists for exactly those servers.
    set cmd [list curl -s -L --fail --max-time 15 -H {Accept: application/json}]
    # A keyed request must not be redirected down to cleartext; the hosted base
    # is https by construction, a local one usually is not.
    if {[regexp -nocase {^https://} $apiRoot]} { lappend cmd --proto-redir =https }
    set authfile ""
    if {$key ne ""} {
        if {![catch {set authfile [::auto_comment::writeCurlConfig \
                "Authorization: Bearer $key"]} err]} {
            lappend cmd --config $authfile
        } else {
            ::auto_comment::logDebug "Auto Comment: cannot write the auth file: $err"
        }
    }
    lappend cmd [string trimright $apiRoot /]/tags
    set raw ""
    set failed [catch {exec {*}$cmd 2>@1} raw]
    if {$authfile ne ""} { catch {file delete -force $authfile} }
    if {$failed} { return [list 0 {}] }
    # A 200 is not enough: a server that answers unknown paths with its web UI
    # returns HTML, which parses to no models - and a valid empty models array
    # must not be treated the same way, or an Ollama with no chat model would
    # get the unfiltered generic list. Only a body with a models array is the
    # native list.
    if {![regexp {"models"\s*:} $raw]} { return [list 0 {}] }
    return [list 1 [::auto_comment::parseOllamaTags $raw]]
}

# ::auto_comment::fetchOllamaModels
#   The hosted model list from ollama.com's /api/tags. It answers without a key,
#   so the list is usable before one is entered, and the key rides the https
#   connection when there is one.
proc ::auto_comment::fetchOllamaModels {} {
    lassign [::auto_comment::fetchTagModels $::auto_comment::ollamaBase \
        $::auto_comment::ollamaKey] answered models
    if {!$answered} { return {} }
    return $models
}

# ::auto_comment::localModelList
#   The local channel's models and the URLs they were asked for, as a two-element
#   list. The local server is asked for /api/tags first and the same
#   capability filter is applied as on the hosted channel; a server that does not
#   answer that path falls back to the generic /v1/models list, which is
#   reported unfiltered because nothing is known about those models.
#
#   The targets are returned with the models, not recomputed by the caller: the
#   failure warning must name what was actually tried, and a second computation
#   can drift from the first.
proc ::auto_comment::localModelList {} {
    set base [::auto_comment::baseUrl $::auto_comment::localUrl]
    if {$base eq ""} { return [list {} {}] }
    set tagUrl "$base/api/tags"
    lassign [::auto_comment::fetchTagModels "$base/api"] answered models
    if {$answered} { return [list $models [list $tagUrl]] }
    return [list [::auto_comment::fetchUrlModels $base ""] \
                 [::auto_comment::targetUrls $base]]
}

proc ::auto_comment::loadModels {combo provider} {
    # The URLs the list was asked for, so a failure can show them: a base the
    # user typed wrong ("https://ollama.com/api") is invisible in the dialog, and
    # the model list is the first place the mistake shows up. A generic base has
    # two targets (see modelListTargets), and both are reported: a local server
    # that only speaks the native API failed on the /v1 one too.
    set targets {}
    switch -- $provider {
        deepseek {
            set label "DeepSeek"
            set targets [list "$::auto_comment::deepseekApiBase/models"]
            set models [::auto_comment::fetchDeepSeekModels]
        }
        local {
            # The local channel speaks Ollama's native API too, so its list is
            # the native one when the server has it: /v1/models answers with the
            # embedding models as well, and the chat endpoint cannot use them.
            set label "the local server"
            lassign [::auto_comment::localModelList] models targets
        }
        openai {
            set label "the endpoint"
            set targets [::auto_comment::targetUrls $::auto_comment::openaiUrl]
            set models [::auto_comment::fetchUrlModels $::auto_comment::openaiUrl $::auto_comment::openaiKey]
        }
        ollama {
            set label "Ollama Cloud"
            set targets [list "$::auto_comment::ollamaBase/tags"]
            # /api/tags is the documented list, and it answers without a key
            set models [::auto_comment::fetchOllamaModels]
        }
        opencode {
            set label "OpenCode Console"
            set targets [list $::auto_comment::opencodeModelsUrl]
            set models [::auto_comment::chatCompletionsOnly \
                [::auto_comment::fetchUrlModels "" $::auto_comment::opencodeKey \
                    $::auto_comment::opencodeModelsUrl]]
        }
        default {
            set label "Gemini"
            set targets [list [::auto_comment::geminiModelsUrl]]
            set models [::auto_comment::fetchGeminiModels]
        }
    }
    if {[llength $models] > 0} {
        $combo configure -values $models
        # an empty model field is why a review would say "no model selected":
        # take the first one the endpoint offers so that cannot happen silently
        if {[$combo cget -textvariable] ne ""} {
            set var [$combo cget -textvariable]
            if {![info exists $var] || [set $var] eq ""} {
                set $var [lindex $models 0]
            }
        }
    } else {
        # The box belongs to the dialog the button is in, not to the main
        # window. Parented to ".", a modal box activates the main window, and
        # the Game Comment dialog is transient to it, so on Windows the settings
        # dialog the user was typing in dropped behind the dialog it was opened
        # from - "Load Models" looked like it threw the settings away and went
        # back to the previous dialog, with the correction still unsaved.
        if {[winfo exists $combo]} {
            set owner [winfo toplevel $combo]
        } else {
            set owner .
        }
        set message "Could not retrieve a model list from $label.\n\n"
        if {[llength $targets] > 0} {
            append message "Tried:\n"
            foreach t $targets { append message "  $t\n" }
            append message "\n"
        }
        append message "Check the endpoint, the API key and the internet connection."
        tk_messageBox -icon warning -type ok -title "Auto Comment" \
            -message $message \
            -parent $owner
        # Whatever the window manager did with the z-order while the box was
        # up, the user's next click belongs in this dialog.
        raise $owner
        focus -force $owner
    }
}

# Native Gemini and DeepSeek request specs, shared by the blocking and async
# transports. The reply is the body on stdout, so no reply file is needed.
proc ::auto_comment::geminiSpec {prompt} {
    set model $::auto_comment::model
    set url "$::auto_comment::geminiApiBase/$model:generateContent"
    set body "{\"contents\":\[{\"parts\":\[{\"text\":\"[::auto_comment::escapeJson $prompt]\"}\]}\]}"
    if {[catch {set tmpfile [::auto_comment::writeRequestFile $body req]} err]} {
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    if {[catch {set replyfile [::auto_comment::writeRequestFile "" reply]} err]} {
        catch {file delete -force $tmpfile}
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    set args [list curl -s --connect-timeout 15 --max-time 60 \
        -H {Content-Type: application/json} \
        -H "x-goog-api-key: $::auto_comment::apiKey" \
        -o $replyfile -w {%{http_code}} -X POST -d @$tmpfile $url]
    return [dict create args $args tmpfile $tmpfile replyfile $replyfile authfile ""]
}

proc ::auto_comment::deepseekSpec {prompt} {
    set model $::auto_comment::deepseekModel
    set url "$::auto_comment::deepseekApiBase/chat/completions"
    set body "{\"model\":\"$model\",\"messages\":\[{\"role\":\"user\",\"content\":\"[::auto_comment::escapeJson $prompt]\"}\],\"stream\":false,\"temperature\":1.0}"
    if {[catch {set tmpfile [::auto_comment::writeRequestFile $body req]} err]} {
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    set authfile ""
    if {[catch {set authfile [::auto_comment::writeCurlConfig \
            "Authorization: Bearer $::auto_comment::deepseekApiKey"]} err]} {
        catch {file delete -force $tmpfile}
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    if {[catch {set replyfile [::auto_comment::writeRequestFile "" reply]} err]} {
        catch {file delete -force $tmpfile}
        catch {file delete -force $authfile}
        return [dict create error "ERROR: cannot write the request: $err"]
    }
    set args [list curl -s --connect-timeout 15 --max-time 180 \
        -H {Content-Type: application/json} --config $authfile \
        -o $replyfile -w {%{http_code}} -X POST --data-binary @$tmpfile $url]
    return [dict create args $args tmpfile $tmpfile replyfile $replyfile authfile $authfile]
}

proc ::auto_comment::geminiText {raw} {
    if {[regexp {"error"\s*:\s*\{} $raw]} {
        set errMsg ""
        regexp {"message"\s*:\s*"([^"]*)"} $raw -> errMsg
        return "ERROR: $errMsg"
    }
    if {![regexp {"text"\s*:\s*"((?:[^"\\]|\\.)*)"} $raw -> rawText]} {
        return "ERROR: Could not parse the Gemini response (it may have been blocked by safety filters)."
    }
    set text [string map {"\\n" "\n" "\\r" "" "\\t" " " "\\\"" "\"" "\\\\" "\\"} $rawText]
    set text [::auto_comment::cleanupText $text]
    if {$text eq ""} {
        return "ERROR: Gemini returned an empty response (it may have been blocked by safety filters)."
    }
    return $text
}

proc ::auto_comment::deepseekText {raw} {
    if {[regexp {"error"\s*:\s*\{} $raw]} {
        set errMsg ""
        regexp {"message"\s*:\s*"([^"]*)"} $raw -> errMsg
        return "ERROR: $errMsg"
    }
    if {![regexp {"content"\s*:\s*"((?:[^"\\]|\\.)*)"} $raw -> rawText]} {
        return "ERROR: Could not parse the DeepSeek response."
    }
    set text [string map {"\\n" "\n" "\\r" "" "\\t" " " "\\\"" "\"" "\\\\" "\\"} $rawText]
    set text [::auto_comment::cleanupText $text]
    if {$text eq ""} {
        return "ERROR: DeepSeek returned an empty response."
    }
    return $text
}

# ::auto_comment::queryGemini
#   Sends the prompt to the Gemini API.
#   Returns the generated commentary text, or "" on failure.
#
proc ::auto_comment::queryGemini {prompt} {
    set model $::auto_comment::model
    set url "$::auto_comment::geminiApiBase/$model:generateContent"

    # DEBUG: Log the prompt being sent
    ::auto_comment::logDebug "\n===== GEMINI API REQUEST ====="
    ::auto_comment::logDebug "Model: $model"
    ::auto_comment::logDebug "Prompt:"
    ::auto_comment::logDebug $prompt
    ::auto_comment::logDebug "===============================\n"

    set escaped [::auto_comment::escapeJson $prompt]
    set jsonBody "{\"contents\":\[{\"parts\":\[{\"text\":\"$escaped\"}\]}\]}"

    set tmpfile [::auto_comment::writeRequestFile $jsonBody req]

    set result ""
    set ok 0

    if {![catch {exec curl -s --connect-timeout 15 --max-time 60 \
            -H "Content-Type: application/json" \
            -H "x-goog-api-key: $::auto_comment::apiKey" \
            -X POST \
            -d @$tmpfile \
            $url 2>@1} result]} {
        set ok 1
    } else {
        ::auto_comment::logDebug "Auto Comment: curl error: $result"
    }

    catch {file delete -force $tmpfile}

    if {!$ok} {
        return "ERROR: Gemini request failed (network error or timeout): [string range [string trim $result] 0 300]"
    }

    # DEBUG: Log the raw response
    ::auto_comment::logDebug "\n===== GEMINI API RESPONSE ====="
    ::auto_comment::logDebug $result
    ::auto_comment::logDebug "===============================\n"

    # Check for API error responses
    if {[regexp {"error"\s*:\s*\{} $result]} {
        set errMsg ""
        regexp {"message"\s*:\s*"([^"]*)"} $result -> errMsg
        ::auto_comment::logDebug "Auto Comment: Gemini API error: $errMsg"
        ::auto_comment::logDebug "Auto Comment: Full response: $result"
        return "ERROR: $errMsg"
    }

    # Extract text from Gemini response
    set text ""
    if {[regexp {"text"\s*:\s*"((?:[^"\\]|\\.)*)"} $result -> rawText]} {
        set text [string map {
            "\\n" "\n"
            "\\r" ""
            "\\t" " "
            "\\\"" "\""
            "\\\\" "\\"
        } $rawText]
    } else {
        ::auto_comment::logDebug "Auto Comment: Could not parse Gemini response: $result"
        return "ERROR: Could not parse the Gemini response (it may have been blocked by safety filters)."
    }

    # DEBUG: Log the extracted commentary before cleanup
    ::auto_comment::logDebug "\n===== GEMINI EXTRACTED COMMENTARY (before cleanup) ====="
    ::auto_comment::logDebug $text
    ::auto_comment::logDebug "========================================================\n"

    set text [::auto_comment::cleanupText $text]
    if {$text eq ""} {
        return "ERROR: Gemini returned an empty response (it may have been blocked by safety filters)."
    }
    return $text
}

# ::auto_comment::queryDeepSeek
#   Sends the prompt to the DeepSeek API (OpenAI-compatible).
#   Returns the generated commentary text, or "" on failure.
#
proc ::auto_comment::queryDeepSeek {prompt} {
    set model $::auto_comment::deepseekModel
    set url "$::auto_comment::deepseekApiBase/chat/completions"

    # DEBUG: Log the prompt being sent
    ::auto_comment::logDebug "\n===== DEEPSEEK API REQUEST ====="
    ::auto_comment::logDebug "Model: $model"
    ::auto_comment::logDebug "Prompt:"
    ::auto_comment::logDebug $prompt
    ::auto_comment::logDebug "================================\n"

    set escapedPrompt [::auto_comment::escapeJson $prompt]
    set jsonBody "{\"model\":\"$model\",\"messages\":\[{\"role\":\"user\",\"content\":\"$escapedPrompt\"}\],\"stream\":false,\"temperature\":1.0}"

    set tmpfile [::auto_comment::writeRequestFile $jsonBody req]
    set authfile ""
    if {[catch {set authfile [::auto_comment::writeCurlConfig \
            "Authorization: Bearer $::auto_comment::deepseekApiKey"]} err]} {
        catch {file delete -force $tmpfile}
        return "ERROR: cannot write the request: $err"
    }

    set result ""
    set ok 0

    if {![catch {exec curl -s --connect-timeout 15 --max-time 180 \
            -H "Content-Type: application/json" \
            --config $authfile \
            -X POST \
            --data-binary @$tmpfile \
            $url 2>@1} result]} {
        set ok 1
    } else {
        ::auto_comment::logDebug "Auto Comment: curl error: $result"
    }

    catch {file delete -force $tmpfile}
    catch {file delete -force $authfile}

    if {!$ok} {
        return "ERROR: DeepSeek request failed (network error or timeout): [string range [string trim $result] 0 300]"
    }

    # DEBUG: Log the raw response
    ::auto_comment::logDebug "\n===== DEEPSEEK API RESPONSE ====="
    ::auto_comment::logDebug $result
    ::auto_comment::logDebug "=================================\n"

    # Check for API error responses
    if {[regexp {"error"\s*:\s*\{} $result]} {
        set errMsg ""
        regexp {"message"\s*:\s*"([^"]*)"} $result -> errMsg
        ::auto_comment::logDebug "Auto Comment: DeepSeek API error: $errMsg"
        ::auto_comment::logDebug "Auto Comment: Full response: $result"
        return "ERROR: $errMsg"
    }

    # Extract text from DeepSeek response (OpenAI format)
    # {"choices":[{"message":{"content":"..."},...}],...}
    set text ""
    if {[regexp {"content"\s*:\s*"((?:[^"\\]|\\.)*)"} $result -> rawText]} {
        set text [string map {
            "\\n" "\n"
            "\\r" ""
            "\\t" " "
            "\\\"" "\""
            "\\\\" "\\"
        } $rawText]
    } else {
        ::auto_comment::logDebug "Auto Comment: Could not parse DeepSeek response: $result"
        return "ERROR: Could not parse the DeepSeek response."
    }

    # DEBUG: Log the extracted commentary before cleanup
    ::auto_comment::logDebug "\n===== DEEPSEEK EXTRACTED COMMENTARY (before cleanup) ====="
    ::auto_comment::logDebug $text
    ::auto_comment::logDebug "==========================================================\n"

    set text [::auto_comment::cleanupText $text]
    if {$text eq ""} {
        return "ERROR: DeepSeek returned an empty response (the model may have hit its output limit before writing any commentary)."
    }
    return $text
}

# ::auto_comment::getOpeningName
#   Retrieves the full opening name for a given ECO code.
#
proc ::auto_comment::getOpeningName {eco} {
    if {$eco eq ""} { return "" }
    
    # sc_eco summary $eco 0 returns lines from scid.eco:
    # "A00 [Barnes Opening]  1. f3"
    # Note: the second argument 0 disables translation for consistent parsing.
    set summary [sc_eco summary $eco 0]
    if {$summary ne ""} {
        set lines [split $summary "\n"]
        foreach line $lines {
            if {[regexp {^([A-E]\d\d[a-z]?\d?)\s+\[([^\]]+)\]} $line -> code description]} {
                # Return the matched code and description
                # return "$code $description"
                return "$description"
            }
        }
    }
    return $eco
}

# ::auto_comment::getTreeInfo
#   Fetches tree statistics for the current position and returns a formatted block.
proc ::auto_comment::getTreeInfo {baseId} {
    set treeBlock ""
    set currBase [sc_base current]

    # 1. Search the database for the current board position.
    # sc_filter search uses the current game position, which the caller has
    # already stepped back to before invoking getTreeInfo.
    if {$baseId != $currBase} {
        sc_base switch $baseId
    }
    
    catch {sc_filter search $baseId "tree" board}

    # 2. Fetch tree statistics using the combined filter '+dbfilter+tree'.
    set err [catch {sc_tree stats $baseId "+dbfilter+tree" 0 frequency 4} stats]
    
    # Restore original base if we switched
    if {$baseId != $currBase} {
        sc_base switch $currBase
    }
    
    if {$err} { return "" }
    
    set lines [split $stats "\n"]
    set count 0
    foreach line $lines {
        if {$count >= 3} break
        # Skip header, total lines and empty lines
        if {[string match "*Move(s)*" $line] || [string match "*TOTAL:*" $line] || [string trim $line] eq ""} continue

        # Parse the fixed-width output of sc_tree stats (tkscid.cpp)
        # Format emitted by tkscid.cpp (lines 8315-8286):
        # Base (0-49), Score (50-57), AvElo (58-63), Perf (64-69), AvLen (70-75),
        # AvYear (76-81), %Draws (82-87), %Win (88-99)
        # Example: " 1: e4 e5 Nf3 Nc6             A00      1234: 45.6%   52.3%  2100  2200    45  1995   32%      48.25%"
        # MoveSeq: 4-28, Games: 36-42, Success%: 51-57, %Draws: 82-87, %Win: 88-99
        catch {
            set moveSeq [string trim [string range $line 4 28]]
            if {$moveSeq eq "" || $moveSeq eq "---"} continue

            set games   [string trim [string range $line 36 42]]
            set success [string trim [string range $line 51 57]]
            set draws   [string trim [string range $line 82 87]]
            set win     [string trim [string range $line 88 99]]
            
            if {$treeBlock eq ""} {
                append treeBlock "Top 3 most frequent database lines for the current position (depth 4 plies):"
            }
            append treeBlock "\n- $moveSeq ($games games): Score $success, Draws $draws, Win $win"
            incr count
        }
    }
    return $treeBlock
}

# ::auto_comment::getTempDir
#   Returns a suitable temporary directory.
#
proc ::auto_comment::getTempDir {} {
    if {[info exists ::env(TMPDIR)]} {
        return $::env(TMPDIR)
    } elseif {[info exists ::env(TEMP)]} {
        return $::env(TEMP)
    } elseif {[info exists ::env(TMP)]} {
        return $::env(TMP)
    } elseif {[file isdirectory "/tmp"]} {
        return "/tmp"
    } else {
        return [pwd]
    }
}
