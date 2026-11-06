# Copyright (C) 2026 Hugh Whelan
# SPDX-License-Identifier: GPL-2.0-or-later
#
# updatecheck_download.tcl -- the downloader's failure and cancel paths.
#
#   tclsh tests/tcl/updatecheck_download.tcl
#
# The real downloader shells out to curl/wget; here a sh child stands in so the
# exit-status and cancel paths are exercised without a network or a real
# installer. A failed child must never reach the install callback, and cancel
# must kill the child instead of waiting for it.

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

set root [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $root tcl updatecheck.tcl]

# tclsh has no Tk; stub the widgets the downloader touches on its error path.
# The harness runs on Linux, where the Windows-only installer path is inert.
set ::windowsOS 0
proc winfo {args} { return 0 }
proc tr {args} { return [lindex $args 0] }

set ::downFailed 0
set ::callbackRan 0
set ::pollDone 0
proc ::appupdate::downloadFailed {} { set ::downFailed 1; set ::pollDone 1 }
proc ::testcb {dest} { set ::callbackRan 1; set ::pollDone 1 }

proc makePipe {shcmd} {
    set fd [open "|sh -c [list $shcmd]" r]
    fconfigure $fd -blocking 0
    return $fd
}

set dest "/tmp/updatecheck-download-test-[pid].bin"

puts "\na failed download must not install"
catch { file delete -force $dest }
set fh [open $dest w]; close $fh
set ::downFailed 0; set ::callbackRan 0; set ::pollDone 0
set fd [makePipe {exit 1}]
set ::appupdate::dl_(1) [list $fd ::testcb $dest ""]
fileevent $fd readable [list ::appupdate::_downloadPoll 1]
after 5000 { set ::pollDone 1 }
vwait ::pollDone
check "it reports failure" $::downFailed
check "it never runs the install callback" [expr {!$::callbackRan}]
check "it deletes the partial file" [expr {![file exists $dest]}]

puts "\na clean download installs"
catch { file delete -force $dest }
set fh [open $dest w]; close $fh
set ::downFailed 0; set ::callbackRan 0; set ::pollDone 0
set fd [makePipe {exit 0}]
set ::appupdate::dl_(2) [list $fd ::testcb $dest ""]
fileevent $fd readable [list ::appupdate::_downloadPoll 2]
after 5000 { set ::pollDone 1 }
vwait ::pollDone
check "it runs the install callback" $::callbackRan
check "it does not report failure" [expr {!$::downFailed}]

puts "\ncancel kills the child instead of waiting"
set fd [makePipe {sleep 30}]
set ::appupdate::dl_(3) [list $fd ::testcb $dest ""]
set t0 [clock milliseconds]
::appupdate::cancelDownload
set elapsed [expr {[clock milliseconds] - $t0}]
check "cancel returns promptly" [expr {$elapsed < 5000}] "$elapsed ms"
check "cancel forgets the download" [expr {![info exists ::appupdate::dl_(3)]}]

puts "\nthe install callback receives the destination once"
# Run downloadAndInstall end-to-end with a stub downloadAsync that behaves like
# curl + _downloadPoll: it writes the file, then appends $dest when invoking the
# callback. If downloadAndInstall also baked $dest in, _downloadDone would get
# two arguments and never launch.
proc tk_messageBox {args} { return "ok" }
proc ::appupdate::showDownloading {version} {}
set ::dlSeen {}
proc ::appupdate::downloadAsync {url dest callback args} {
    set ::dlSeen [list $url $dest $callback]
    set fh [open $dest w]; puts $fh x; close $fh
    {*}$callback $dest
}
set ::launched ""
proc ::appupdate::launchAndExit {installer} { set ::launched $installer }

set setup [file join [::appupdate::tempDir] "scidCommunity-5.2.0-windows-x64-setup.exe"]
catch { file delete -force $setup }
set ::launched ""
::appupdate::downloadAndInstall "http://example.invalid/setup.exe" "5.2.0"
check "the installer is launched" [expr {$::launched eq $setup}] "launched='$::launched'"
check "the callback prefix has no baked-in destination" \
    [expr {[lindex $::dlSeen 2] eq "::appupdate::_downloadDone"}] \
    "callback='[lindex $::dlSeen 2]'"
catch { file delete -force $setup }

catch { file delete -force $dest }
puts "\n$checks checks, $fails failures"
exit [expr {$fails ? 1 : 0}]
