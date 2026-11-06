# updatecheck.tcl: in-app update notifier for scidCommunity.
# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Checks the GitHub Releases for whelanh/scidCommunity for a newer version and,
# on Windows only, offers to download and run the NSIS installer.
#
# Design notes:
#   * The version check fetches the "latest" release JSON once per day (automatic
#     check) and parses tag_name / html_url / browser_download_url with plain
#     regexps, so no extra Tcl package (tls/json) is required.
#   * Packaged channels that update themselves (Snap, Flatpak) are never nagged.
#     AUR/COPR have no environment marker, so those users still see the notifier;
#     it is harmless because it only points at the release page.
#   * The download reuses the same curl/wget/PowerShell fallback chain the rest
#     of the app already relies on (see tools/chesscom.tcl).

namespace eval ::appupdate {
    variable repo    "whelanh/scidCommunity"
    variable apiUrl  "https://api.github.com/repos/whelanh/scidCommunity/releases/latest"
    variable checkInterval 86400   ;# seconds between automatic checks
    variable dlToken 0
}

################################################################################
# Version helpers
################################################################################

# Normalize a version to a plain dotted number ("v5.2.0" -> "5.2.0"). Returns ""
# when the string does not look like a version.
proc ::appupdate::normalize {v} {
    set v [string trim $v]
    regsub {^v} $v "" v
    if {![regexp {^[0-9]+(\.[0-9]+)*} $v m]} { return "" }
    return $m
}

# True when $current is older than $latest.
proc ::appupdate::newerAvailable {current latest} {
    set c [::appupdate::normalize $current]
    set l [::appupdate::normalize $latest]
    if {$c eq "" || $l eq "" || $c eq $l} { return 0 }
    if {[catch {package vsatisfies $c $l} ok]} { return 0 }
    return [expr {!$ok}]
}

################################################################################
# Persisted check state (a tiny file in the config dir, kept apart from the
# options file so the notifier does not depend on its format)
################################################################################

proc ::appupdate::configFile {} {
    return [file nativename [file join $::scidConfigDir "update.dat"]]
}

proc ::appupdate::stateRead {} {
    set state [dict create lastCheck 0 lastNotified ""]
    if {[catch {
        set f [::appupdate::configFile]
        if {![file exists $f]} { return $state }
        set fd [open $f r]
        set txt [read $fd]
        close $fd
        if {[regexp {lastCheck\s+(\d+)} $txt -> v] && [string is integer -strict $v]} {
            dict set state lastCheck $v
        }
        if {[regexp {lastNotified\s+(\S+)} $txt -> v]} {
            dict set state lastNotified $v
        }
    } err]} {
        # Ignore: treat as never checked.
    }
    return $state
}

proc ::appupdate::stateWrite {state} {
    if {[catch {
        set fd [open [::appupdate::configFile] w]
        puts $fd "lastCheck [dict get $state lastCheck]"
        puts $fd "lastNotified [dict get $state lastNotified]"
        close $fd
    } err]} {
        # Ignore: caching is best-effort.
    }
}

################################################################################
# Fetching
################################################################################

# Resolve a command-line tool to a full path, preferring PATH and falling back
# to the directory of the executable (the Windows build bundles curl.exe there).
proc ::appupdate::resolve {name} {
    set p [auto_execok $name]
    if {$p ne ""} { return $p }
    if {$::windowsOS} {
        set cand [file join $::scidExeDir "$name.exe"]
        if {[file exists $cand]} { return $cand }
    }
    return ""
}

# Fetch a URL to stdout asynchronously; calls $callback with the response body
# (or "" on failure). Non-blocking: the callback fires from the event loop.
proc ::appupdate::fetchAsync {url callback} {
    variable pending
    set cmd ""
    set curl [::appupdate::resolve curl]
    set wget [::appupdate::resolve wget]
    if {$curl ne ""} {
        set args [list -s --max-time 20]
        # Schannel (the native Windows TLS backend) can hang on a certificate
        # revocation check; disable it on Windows.
        if {$::windowsOS} { lappend args --ssl-no-revoke }
        lappend args $url
        set cmd [list | $curl {*}$args]
    } elseif {$wget ne ""} {
        set cmd [list | $wget -q -O - --timeout=20 $url]
    } else {
        # No command-line client: fall back to a synchronous fetch on the next
        # event-loop turn so the callback is still asynchronous from the caller.
        after 0 [list ::appupdate::_syncFallback $url $callback]
        return
    }
    set token [incr ::appupdate::dlToken]
    set fd [open $cmd r]
    fconfigure $fd -blocking 0 -buffering full
    set pending($token) [list $fd "" $callback]
    fileevent $fd readable [list ::appupdate::_fetchRead $token]
}

proc ::appupdate::_fetchRead {token} {
    variable pending
    if {![info exists pending($token)]} { return }
    lassign $pending($token) fd buf callback
    if {[catch { append buf [read $fd] } err]} {
        catch { close $fd }
        unset -nocomplain pending($token)
        {*}$callback ""
        return
    }
    if {[eof $fd]} {
        catch { close $fd }
        unset -nocomplain pending($token)
        {*}$callback $buf
    } else {
        set pending($token) [list $fd $buf $callback]
    }
}

proc ::appupdate::_syncFallback {url callback} {
    set body ""
    if {$::windowsOS && [auto_execok powershell] ne ""} {
        if {![catch {exec powershell -NoLogo -NoProfile -Command \
            "(Invoke-WebRequest -UseBasicParsing -Uri '$url' -TimeoutSec 20).Content" 2>@1} body]} {
        } else {
            set body ""
        }
    }
    {*}$callback $body
}

# Parse the GitHub "latest release" JSON. Returns a dict:
#   version   - tag name without the leading "v"
#   htmlUrl   - the release page URL
#   installer - the Windows NSIS installer download URL ("" when absent)
# Returns "" when the payload is not a usable release.
proc ::appupdate::parseRelease {data} {
    if {![regexp {"tag_name"\s*:\s*"v?([^"]+)"} $data -> version]} { return "" }
    if {![regexp {"html_url"\s*:\s*"([^"]+)"} $data -> htmlUrl]} { set htmlUrl "" }
    set installer ""
    if {[regexp {"browser_download_url"\s*:\s*"([^"]*-windows-x64-setup\.exe)"} $data -> u]} {
        set installer $u
    }
    return [list version $version htmlUrl $htmlUrl installer $installer]
}

################################################################################
# Public entry points
################################################################################

# "Check for Updates" menu command.
proc ::appupdate::check {} {
    if {[::appupdate::checking]} { return }
    ::appupdate::showChecking
    ::appupdate::fetchAsync $::appupdate::apiUrl [list ::appupdate::_checkDone manual]
}

# Automatic check at startup (silent unless a newer version is found).
proc ::appupdate::autoCheck {} {
    # Packaged channels update themselves: never nag them.
    if {[info exists ::env(SNAP)] || [info exists ::env(FLATPAK_ID)]} { return }
    set state [::appupdate::stateRead]
    set now [clock seconds]
    set last [dict get $state lastCheck]
    if {$last > 0 && [expr {$now - $last}] < $::appupdate::checkInterval} { return }
    dict set state lastCheck $now
    ::appupdate::stateWrite $state
    ::appupdate::fetchAsync $::appupdate::apiUrl [list ::appupdate::_checkDone auto]
}

proc ::appupdate::_checkDone {mode data} {
    ::appupdate::hideChecking
    set info [::appupdate::parseRelease $data]
    if {$info eq ""} {
        if {$mode eq "manual"} {
            tk_messageBox -title "scidCommunity" -type ok -icon warning \
                -message [tr UpdateCheckFailed]
        }
        return
    }
    set version [dict get $info version]
    if {![::appupdate::newerAvailable $::scidVersion $version]} {
        if {$mode eq "manual"} {
            tk_messageBox -title "scidCommunity" -type ok -icon info \
                -message [format [tr UpdateUpToDate] $::scidVersion]
        }
        return
    }
    if {$mode eq "auto"} {
        # Do not re-notify for a version the user has already seen.
        set state [::appupdate::stateRead]
        if {[dict get $state lastNotified] eq $version} { return }
        dict set state lastNotified $version
        ::appupdate::stateWrite $state
    }
    ::appupdate::showUpdateDialog $version [dict get $info htmlUrl] [dict get $info installer]
}

################################################################################
# UI
################################################################################

proc ::appupdate::checking {} {
    return [expr {[winfo exists .updateCheckWin]}]
}

# A transient "Checking for updates..." window shown during a manual check.
proc ::appupdate::showChecking {} {
    set w .updateCheckWin
    if {[winfo exists $w]} { return }
    ::win::createDialog $w
    wm title $w "scidCommunity"
    wm resizable $w 0 0
    ttk::label $w.l -text [tr UpdateChecking]
    ttk::progressbar $w.pb -mode indeterminate
    pack $w.l -padx 24 -pady {16 4}
    pack $w.pb -fill x -padx 24 -pady {0 16}
    ::win::makeVisible $w
    update idletasks
}

proc ::appupdate::hideChecking {} {
    if {[winfo exists .updateCheckWin]} { destroy .updateCheckWin }
}

# The "a new version is available" dialog. On Windows it offers a
# "Download & Install" button; that button never appears on other platforms.
proc ::appupdate::showUpdateDialog {version htmlUrl installer} {
    set w .updateDlg
    if {[winfo exists $w]} { destroy $w }
    ::win::createDialog $w
    wm title $w "scidCommunity"
    wm resizable $w 0 0

    set msg [format [tr UpdateAvailable] $version $::scidVersion]
    ttk::label $w.msg -text $msg -justify left -wraplength 400
    pack $w.msg -padx 16 -pady 16 -fill x

    ttk::frame $w.buttons
    pack $w.buttons -fill x -padx 8 -pady {0 8}

    # Windows only: offer the one-click installer.
    if {$::windowsOS && $installer ne ""} {
        dialogbutton $w.buttons.install -text [tr UpdateDownloadInstall] \
            -command [list ::appupdate::downloadAndInstall $installer $version]
        pack $w.buttons.install -side right -padx 4
    }

    if {$htmlUrl ne ""} {
        dialogbutton $w.buttons.release -text [tr UpdateViewRelease] \
            -command [list openURL $htmlUrl]
        pack $w.buttons.release -side right -padx 4
    }

    dialogbutton $w.buttons.later -text [tr UpdateNotNow] -command "destroy $w"
    pack $w.buttons.later -side right -padx 4

    bind $w <Escape> "destroy $w"
    ::win::makeVisible $w
}

################################################################################
# Download & Install (Windows only)
################################################################################

proc ::appupdate::downloading {} {
    return [expr {[winfo exists .updateDl]}]
}

proc ::appupdate::downloadAndInstall {url version} {
    if {[::appupdate::downloading]} { return }
    set answer [tk_messageBox -title "scidCommunity" -type okcancel -icon info \
        -message [format [tr UpdateInstallConfirm] $version]]
    if {$answer ne "ok"} { return }

    set dest [file join [::appupdate::tempDir] \
        "scidCommunity-$version-windows-x64-setup.exe"]
    # A previous partial download may be present; start fresh.
    catch { file delete -force $dest }

    ::appupdate::showDownloading $version
    ::appupdate::downloadAsync $url $dest [list ::appupdate::_downloadDone $dest] .updateDl.progress
}

proc ::appupdate::showDownloading {version} {
    set w .updateDl
    if {[winfo exists $w]} { destroy $w }
    ::win::createDialog $w
    wm title $w "scidCommunity"
    wm resizable $w 0 0
    ttk::label $w.l -text [format [tr UpdateDownloading] $version]
    ttk::progressbar $w.pb -mode indeterminate
    ttk::label $w.progress -text ""
    ttk::frame $w.buttons
    dialogbutton $w.buttons.cancel -text [tr Cancel] \
        -command "::appupdate::cancelDownload"
    pack $w.l -padx 24 -pady {16 4}
    pack $w.pb -fill x -padx 24 -pady {0 4}
    pack $w.progress -padx 24 -pady {0 8}
    pack $w.buttons -pady {0 12}
    pack $w.buttons.cancel -padx 5
    ::win::makeVisible $w
    update idletasks
}

# Download $url to $dest asynchronously. curl/wget write the file directly (-o)
# rather than streaming bytes through a Tcl pipe: that is both simpler and more
# robust on Windows, and it leaves the pipe free to signal completion (their
# stdout is empty, so the channel's EOF means the client has exited).
# $label, when given, is a widget updated with a running byte count.
proc ::appupdate::downloadAsync {url dest callback {label ""}} {
    variable dl_
    set curl [::appupdate::resolve curl]
    set wget [::appupdate::resolve wget]
    set cmd ""
    if {$curl ne ""} {
        set args [list -sS -f -L --max-time 900 -A "scidCommunity/$::scidVersion"]
        # Schannel can hang for a long time on a certificate revocation check
        # during the TLS handshake (notably to the S3 host the release URL
        # redirects to); disable it on Windows.
        if {$::windowsOS} { lappend args --ssl-no-revoke }
        lappend args -o $dest $url
        set cmd [list | $curl {*}$args]
    } elseif {$wget ne ""} {
        set cmd [list | $wget -q -O $dest --timeout=900 $url]
    } else {
        # No command-line client: do a blocking download on the next loop turn.
        after 0 [list ::appupdate::_downloadSync $url $dest $callback]
        return
    }
    set token [incr ::appupdate::dlToken]
    set fd [open $cmd r]
    fconfigure $fd -blocking 0
    set dl_($token) [list $fd $callback $dest $label]
    fileevent $fd readable [list ::appupdate::_downloadPoll $token]
    set ::appupdate::dlPoll_($token) [after 400 [list ::appupdate::_downloadProgress $token]]
}

# The download client writes the file itself, so this only has to notice when
# it exits (EOF), check its exit status, and hand off to the callback.
proc ::appupdate::_downloadPoll {token} {
    variable dl_
    if {![info exists dl_($token)]} { return }
    lassign $dl_($token) fd callback dest label
    catch { read $fd }
    if {[eof $fd]} {
        # Closing a non-blocking pipe discards the child's exit status, so switch
        # back to blocking first: close then errors when curl/wget exited
        # non-zero (partial download, HTTP error, timeout). A truncated installer
        # must never reach the callback.
        catch { fconfigure $fd -blocking 1 }
        set ok 0
        if {![catch { close $fd }]} { set ok 1 }
        catch { after cancel $::appupdate::dlPoll_($token) }
        unset -nocomplain ::appupdate::dlPoll_($token)
        unset -nocomplain dl_($token)
        if {$ok} {
            {*}$callback $dest
        } else {
            catch { file delete -force $dest }
            ::appupdate::downloadFailed
        }
    }
}

# Update the running byte count while the download is in flight.
proc ::appupdate::_downloadProgress {token} {
    variable dl_
    if {![info exists dl_($token)]} { return }
    lassign $dl_($token) fd callback dest label
    if {$label ne "" && [winfo exists $label]} {
        if {[file exists $dest]} {
            $label configure -text [format [tr UpdateDownloaded] [::appupdate::humanBytes [file size $dest]]]
        }
    }
    set ::appupdate::dlPoll_($token) [after 400 [list ::appupdate::_downloadProgress $token]]
}

# "n" bytes as a short human-readable string (e.g. "12.3 MB").
proc ::appupdate::humanBytes {n} {
    set units {B KB MB GB}
    set u 0
    set v [expr {double($n)}]
    while {$v >= 1024.0 && $u < 3} {
        set v [expr {$v / 1024.0}]
        incr u
    }
    if {$u == 0} { return "$n B" }
    return [format "%.1f %s" $v [lindex $units $u]]
}

proc ::appupdate::cancelDownload {} {
    variable dl_
    foreach token [array names dl_] {
        lassign $dl_($token) fd callback dest label
        # Kill the client before closing: curl writes to -o, not the pipe, so
        # closing the read end does not stop it and close() would block the UI
        # until --max-time. kill/taskkill ends it first, then close() returns.
        set pid ""
        catch { set pid [pid $fd] }
        if {$pid ne ""} {
            if {[catch { exec kill $pid }]} {
                catch { exec taskkill.exe /PID $pid /T /F }
            }
        }
        catch { close $fd }
        catch { after cancel $::appupdate::dlPoll_($token) }
        catch { unset ::appupdate::dlPoll_($token) }
        catch { file delete -force $dest }
        unset dl_($token)
    }
    if {[winfo exists .updateDl]} { destroy .updateDl }
}

proc ::appupdate::_downloadSync {url dest callback} {
    set ok 0
    if {[catch {
        if {$::windowsOS && [auto_execok powershell] ne ""} {
            exec powershell -NoLogo -NoProfile -Command \
                "Invoke-WebRequest -UseBasicParsing -Uri '$url' -OutFile '$dest' -UserAgent 'scidCommunity/$::scidVersion'" 2>@1
        } else {
            ::chesscom::downloadWithHTTP $url $dest "scidCommunity/$::scidVersion"
        }
        set ok 1
    } err]} {}
    if {!$ok || ![file exists $dest] || [file size $dest] == 0} {
        ::appupdate::downloadFailed
        return
    }
    {*}$callback $dest
}

proc ::appupdate::downloadFailed {} {
    if {[winfo exists .updateDl]} { destroy .updateDl }
    tk_messageBox -title "scidCommunity" -type ok -icon error \
        -message [tr UpdateDownloadFailed]
}

proc ::appupdate::_downloadDone {dest} {
    if {[winfo exists .updateDl]} { destroy .updateDl }
    if {![file exists $dest] || [file size $dest] == 0} {
        ::appupdate::downloadFailed
        return
    }
    ::appupdate::launchAndExit $dest
}

# Launch the downloaded installer and close the app. The installer must not run
# while scidCommunity.exe is still alive (Windows locks a running .exe), so a
# helper script waits for this process to exit before starting it.
proc ::appupdate::launchAndExit {installer} {
    set helper [file join [::appupdate::tempDir] "scidCommunity-update-[pid].cmd"]
    set pid [pid]
    if {[catch {
        set fh [open $helper w]
        puts $fh "@echo off"
        puts $fh ":wait"
        puts $fh "ping -n 2 127.0.0.1 >nul"
        puts $fh "tasklist /fi \"PID eq $pid\" /nh 2>nul | findstr /b \"scidCommunity.exe\" >nul"
        puts $fh "if not errorlevel 1 goto wait"
        puts $fh "start \"scidCommunity\" \"[string map {\" \"} $installer]\""
        puts $fh "del \"%~f0\""
        close $fh
        exec cmd.exe /c start "scidCommunity" [list $helper]
    } err]} {
        # Helper could not be launched; fall back to launching the installer
        # directly (may fail if the running exe is still locked).
        catch { exec cmd.exe /c start "scidCommunity" [list $installer] }
    }
    # Exit cleanly: prompts about unsaved games, saves options, then quits.
    ::file::Exit
}

proc ::appupdate::tempDir {} {
    foreach var {TMPDIR TEMP TMP} {
        if {[info exists ::env($var)] && $::env($var) ne "" \
            && [file isdirectory $::env($var)]} {
            return $::env($var)
        }
    }
    if {!$::windowsOS && [file isdirectory /tmp]} { return /tmp }
    return [pwd]
}

################################################################################
# Schedule the automatic startup check shortly after the main window is ready.
################################################################################
after 3000 ::appupdate::autoCheck
