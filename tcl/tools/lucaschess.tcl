###
### lucaschess.tcl: part of scidCommunity.
### Download and install chess engines from Lucas Chess R.
###

namespace eval lucaschess {}

# Engine data from Lucas Chess R OSEngines.py
# Each entry: {key name elo exe folder nodes_compatible lucas_elo_min lucas_elo_max lucas_config}
set ::lucaschess::engines {
    {stockfish       {Stockfish 18}            3700 {stockfish-18-64}      stockfish   0 1340 1559 {depth 1-4, UCI_Elo=1400-3100}}
    {komodo          {Dragon-1}                3529 {dragon-linux}         komodo      1 1355 1944 {depth 1-4}}
    {patricia        {Patricia 4 v2}           3500 {patricia_4_v2}        patricia    0 {}   {}   {}}
    {igel            {Igel 3.0.0}              3402 {Igel-3.0.10}         igel        1 {}   {}   {}}
    {ethereal        {Ethereal 12.75}          3392 {Ethereal-12.75}      ethereal    0 {}   {}   {}}
    {lc0             {Lc0 0.32.0}              3332 {Lc0-0.32.0}          lc0         1 {}   {}   {}}
    {arasan          {Arasan 22.2}             3259 {Arasan-22.2}         arasan      0 1000 2600 {UCI_Elo=1000-2600}}
    {andscacs        {Andscacs 0.95}           3240 {Andscacs-0.95}       andscacs    0 {}   {}   {}}
    {laser           {Laser 1.7}               3227 {Laser-1.17}          laser       0 {}   {}   {}}
    {marvin          {Marvin 5.0.0}            3112 {Marvin-5.0.0}        marvin      1 {}   {}   {}}
    {texel           {Texel 1.08}              3100 {texel64}             texel       0 1282 2500 {depth 1-4, UCI_Elo=700-2500}}
    {beef            {Beef 0.36}               3097 {Beef-0.36}           beef        0 {}   {}   {}}
    {critter         {Critter 1.6a}            3091 {Critter-1.6a}        critter     0 1383 1979 {depth 1-4}}
    {stash           {Stash 29.0}              3065 {Stash-29.0}          stash       0 {}   {}   {}}
    {monolith        {Monolith 2.01}           3003 {Monolith-2.01}       monolith    1 {}   {}   {}}
    {weiss           {Weiss 1.2}               2982 {Weiss-1.2}           weiss       0 {}   {}   {}}
    {godel           {Godel 7.0}               2979 {Godel-7.0}           godel       1 {}   {}   {}}
    {counter         {Counter 3.7}             2963 {Counter-3.7}         counter     1 {}   {}   {}}
    {tucano          {Tucano 9.00}             2940 {Tucano-9.00}         tucano      1 {}   {}   {}}
    {rodentii        {Rodent II 0.9.64}        2912 {RodentII-0.9.64}     rodentii    1 888  2647 {NPS=1-3830}}
    {amoeba          {Amoeba 2.6}              2911 {Amoeba-2.6}          amoeba      1 {}   {}   {}}
    {asymptote       {Asymptote 0.8}           2909 {Asymptote-0.8}       asymptote   1 {}   {}   {}}
    {toga            {DeepToga 1.9.6nps}       2843 {DeepToga1.9.6nps}   toga        0 1304 2850 {depth 1-4, NPS=3.4K-300K}}
    {zurichess       {Zurichess 1.7.4}         2830 {Zurichess-1.7.4}    zurichess   0 {}   {}   {}}
    {fruit           {Fruit 2.1}               2784 {Fruit-2.1}           fruit       0 1478 1876 {depth 1-4}}
    {octochess       {Octochess r5190}         2771 {Octochess-r5190}     octochess   0 {}   {}   {}}
    {glaurung        {Glaurung 2.2}            2765 {Glaurung-2.2}        glaurung    1 1500 1914 {depth 2-4}}
    {gambitfruit     {Gambit-Fruit 1.0}        2750 {gfruit}              gambitfruit 0 2500 2850 {NPS=30K-300K}}
    {cheng           {Cheng 4.40}              2750 {Cheng-4.40}          cheng       0 1245 2950 {depth 1-4, UCI_Elo=1550-1880}}
    {k2              {K2 0.99}                 2704 {K2-0.99}             k2          1 {}   {}   {}}
    {discocheck      {Discocheck 5.2.1}        2700 {Discocheck-5.2.1}   discocheck  1 1298 1731 {depth 1-4}}
    {velvet          {Velvet 1.2.0}            2686 {Velvet-1.2.0}        velvet      0 {}   {}   {}}
    {wyldchess       {WyldChess 1.51}          2682 {WyldChess-1.51}      wyldchess   0 {}   {}   {}}
    {daydreamer      {Daydreamer 1.75}         2670 {Daydreamer-1.75}     daydreamer  1 1413 1662 {depth 2-4}}
    {supernova       {Supernova 2.3}           2646 {Supernova-2.3}       supernova   1 {}   {}   {}}
    {drofa           {Drofa 3.3.0}             2642 {Drofa-3.3.0}         drofa       0 {}   {}   {}}
    {gaviota         {Gaviota 0.84}            2638 {Gaviota-0.84}        gaviota     1 1331 1911 {depth 1-4}}
    {delocto         {Delocto 0.61n}           2625 {Delocto-0.61n}       delocto     0 {}   {}   {}}
    {zappa           {Zappa 1.1}               2614 {Zappa-1.1}           zappa       1 {}   {}   {}}
    {ct800           {CT800 1.46}              2600 {CT800_V1.46}         ct800       1 459  2500 {UCI_Elo=1000-2100}}
    {greko           {GreKo 2020.03}           2580 {GreKo-2020.03}       greko       1 1225 2794 {depth 1-4, NPS=1K-140K}}
    {pawny           {Pawny 1.2}               2550 {Pawny-1.2}           pawny       0 1288 1573 {depth 2-4}}
    {greko98         {GreKo 9.8}               2500 {GreKo98a}            greko98     1 745  2795 {NPS=1K-4K}}
    {teki            {Teki 2}                  2439 {Teki-2}              teki        0 {}   {}   {}}
    {tunguska        {Tunguska 1.1}            2439 {Tunguska-1.1}        tunguska    0 {}   {}   {}}
    {simplex         {Simplex 0.9.8}           2396 {Simplex-0.9.8}       simplex     0 1147 1705 {depth 1-4}}
    {ceechess        {CeeChess 1.3.2}          2268 {CeeChess-1.3.2}      ceechess    0 {}   {}   {}}
    {spacedog        {SpaceDog 0.97.7}         2231 {SpaceDog-0.97.7}     spacedog    0 {}   {}   {}}
    {maia-2200       {Maia-2200}               2200 {Lc0-0.27.0}          maia        1 {}   {}   {nodes=800}}
    {gunborg         {Gunborg 1.35}            2086 {Gunborg-1.35}        gunborg     0 {}   {}   {}}
    {jabba           {Jabba 1.0}               2078 {Jabba-1.0}           jabba       0 {}   {}   {}}
    {clarabit        {Clarabit 1.00}           2058 {Clarabit-1.00}       clarabit    0 1182 1536 {depth 1-4}}
    {goldfish        {Goldfish 1.13.0}         2050 {Goldfish-1.13.0}     goldfish    1 {}   {}   {}}
    {fractal         {FracTal 1.0}             2010 {FracTal-1.0}         fractal     0 {}   {}   {}}
    {sissa           {Sissa 2.0}               1957 {Sissa-2.0}           sissa       0 {}   {}   {}}
    {cinnamon        {Cinnamon 1.2b}           1930 {Cinnamon-1.2b}       cinnamon    0 {}   {}   {}}
    {wowl            {Wowl 1.3.7}              1925 {Wowl-1.3.7}          wowl        1 {}   {}   {}}
    {maia-1900       {Maia-1900}               1900 {Lc0-0.27.0}          maia        1 2402 3054 {nodes=450}}
    {pigeon          {Pigeon 1.5.1}            1836 {Pigeon-1.5.1}        pigeon      0 {}   {}   {}}
    {maia-1800       {Maia-1800}               1800 {Lc0-0.27.0}          maia        1 2190 2334 {nodes=300}}
    {rocinante       {Rocinante 2.0}           1800 {Rocinante-2.0}       rocinante   0 1860 1921 {}}
    {shallow-blue    {Shallow-Blue 2.0.0}      1712 {Shallow-blue-2.0.0}  shallow-blue 0 {}  {}   {}}
    {maia-1700       {Maia-1700}               1700 {Lc0-0.27.0}          maia        1 1740 2040 {nodes=130}}
    {pulse           {Pulse 1.6.1}             1615 {Pulse-1.6.1}         pulse       1 {}   {}   {}}
    {monochrome      {Monochrome}              1601 {Monochrome}          monochrome  0 {}   {}   {}}
    {maia-1600       {Maia-1600}               1600 {Lc0-0.27.0}          maia        1 1500 1627 {nodes=60}}
    {irina           {Irina 0.23}              1600 {irina}               irina       0 100  1743 {NPS=20-30000}}
    {maia-1500       {Maia-1500}               1500 {Lc0-0.27.0}          maia        1 1410 1410 {nodes=30}}
    {eguzki          {Eguzki 1.0}              1500 {eguzki}              eguzki      0 1000 2700 {UCI_Elo=1000-2700}}
    {quokka          {Quokka 2.1}              1448 {Quokka-2.1}          quokka      0 {}   {}   {}}
    {chessika        {Chessika 2.21}           1441 {Chessika-2.21}       chessika    0 {}   {}   {}}
    {hactar          {Hactar 0.9.0}            1421 {Hactar-0.9.0}        hactar      0 {}   {}   {}}
    {maia-1400       {Maia-1400}               1400 {Lc0-0.27.0}          maia        1 1326 1326 {nodes=12}}
    {maia-1300       {Maia-1300}               1300 {Lc0-0.27.0}          maia        1 {}   {}   {nodes=5}}
    {dragontooth     {Dragontooth 0.2}         1225 {Dragontooth-0.2}     dragontooth 0 {}   {}   {}}
    {maia-1200       {Maia-1200}               1200 {Lc0-0.27.0}          maia        1 {}   {}   {nodes=2}}
    {cassandre       {Cassandre 0.24}          1140 {Cassandre-0.24}      cassandre   0 {}   {}   {}}
    {maia-1100       {Maia-1100}               1100 {Lc0-0.27.0}          maia        1 1090 1090 {nodes=1}}
    {eguzkilore      {Eguzkilore 1.0}          1000 {eguzkilore}          eguzkilore  0 {}   {}   {}}
}

# Depth-to-ELO calibration from Lucas Chess ManagerElo (engine depth=ELO)
# Format: {key depth elo}
set ::lucaschess::depthCalib {
    {stockfish 1 1340}  {stockfish 2 1365}  {stockfish 3 1441}  {stockfish 4 1559}
    {komodo    1 1355}  {komodo    2 1591}  {komodo    3 1709}  {komodo    4 1944}
    {cheng     1 1245}  {cheng     2 1463}  {cheng     3 1689}  {cheng     4 1847}
    {critter   1 1383}  {critter   2 1662}  {critter   3 1892}  {critter   4 1979}
    {gaviota   1 1331}  {gaviota   2 1516}  {gaviota   3 1657}  {gaviota   4 1911}
    {glaurung  2 1500}  {glaurung  3 1731}  {glaurung  4 1914}
    {greko     1 1225}  {greko     2 1339}  {greko     3 1622}  {greko     4 1818}
    {texel     1 1282}  {texel     2 1503}  {texel     3 1579}  {texel     4 1848}
    {toga      1 1304}  {toga      2 1546}  {toga      3 1881}  {toga      4 1948}
    {discocheck 1 1298} {discocheck 2 1447} {discocheck 3 1613} {discocheck 4 1731}
    {daydreamer 2 1413} {daydreamer 3 1488} {daydreamer 4 1662}
    {pawny     2 1288}  {pawny     3 1460}  {pawny     4 1573}
    {simplex   1 1147}  {simplex   2 1284}  {simplex   3 1452}  {simplex   4 1705}
    {clarabit  1 1182}  {clarabit  2 1281}  {clarabit  3 1411}  {clarabit  4 1536}
    {fruit     1 1478}  {fruit     2 1549}  {fruit     3 1737}  {fruit     4 1876}
}

# Expand depth entries: for each base engine with depth calibration,
# add separate entries per depth level.
proc ::lucaschess::expandDepthEngines {} {
    foreach calib $::lucaschess::depthCalib {
        lassign $calib key depth elo
        set base [::lucaschess::findEngine $key]
        if {$base eq ""} { continue }
        lassign $base _ baseName _ exe folder nodes_comp _ _ _
        set dName "$baseName (depth $depth)"
        lappend ::lucaschess::engines [list $key-d$depth $dName \
            $elo $exe $folder $nodes_comp $elo $elo "depth=$depth"]
    }
}

# Find an engine in the main list by key
proc ::lucaschess::findEngine {key} {
    foreach e $::lucaschess::engines {
        if {[lindex $e 0] eq $key} { return $e }
    }
    return ""
}

::lucaschess::expandDepthEngines

# GitHub repository base URL
set ::lucaschess::githubBase "https://raw.githubusercontent.com/lukasmonk/lucaschessR6/main/bin/OS"
set ::lucaschess::githubApi "https://api.github.com/repos/lukasmonk/lucaschessR6/contents"

set ::lucaschess::skipExtensions {.7z .zip .tar.gz .tar .tgz}

# ::lucaschess::downloadFile
proc ::lucaschess::downloadFile {url destFile} {
    set destDir [file dirname $destFile]
    file mkdir $destDir
    set tempFile [file join $destDir "_download_tmp"]

    if {[auto_execok curl] ne ""} {
        if {[catch {exec curl -L -s --max-time 120 -o "$tempFile" "$url" 2>@1} err]} {
            error "curl download failed: $err"
        }
    } elseif {[auto_execok wget] ne ""} {
        if {[catch {exec wget -q --timeout=120 -O "$tempFile" "$url" 2>@1} err]} {
            error "wget download failed: $err"
        }
    } elseif {[info exists ::windowsOS] && $::windowsOS && [auto_execok powershell] ne ""} {
        set ::env(SCID_LC_DL_URL) $url
        set ::env(SCID_LC_DL_FILE) $tempFile
        if {[catch {exec powershell -NoLogo -NoProfile -Command \
            {$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri $env:SCID_LC_DL_URL -OutFile $env:SCID_LC_DL_FILE -TimeoutSec 120}} err]} {
            error "PowerShell download failed: $err"
        }
    } else {
        ::lucaschess::downloadWithHTTP $url $tempFile
    }

    file rename -force $tempFile $destFile
    return $destFile
}

# ::lucaschess::downloadWithHTTP
proc ::lucaschess::downloadWithHTTP {url destFile} {
    package require http
    if {[catch {package require tls} tlsErr]} {
        error "Tcl TLS support is unavailable: $tlsErr."
    }
    http::register https 443 [list ::tls::socket -autoservername true]
    if {[catch {
        set fd [open $destFile wb]
        set token [http::geturl $url -channel $fd -timeout 120000]
        close $fd
        set ncode [http::ncode $token]
        http::cleanup $token
        if {$ncode != 200} { error "HTTP $ncode" }
    } err]} {
        catch {close $fd}
        error "HTTP download error: $err"
    }
}

# ::lucaschess::fetchGitHubApi
proc ::lucaschess::fetchGitHubApi {apiUrl} {
    if {[auto_execok curl] ne ""} {
        if {[catch {exec curl -L -s -H "Accept: application/vnd.github+json" \
            -H "User-Agent: scidCommunity" "$apiUrl" 2>@1} result]} {
            error "GitHub API call failed: $result"
        }
        return $result
    } elseif {[auto_execok wget] ne ""} {
        if {[catch {exec wget -q -O - --header="Accept: application/vnd.github+json" \
            --header="User-Agent: scidCommunity" "$apiUrl" 2>@1} result]} {
            error "GitHub API call failed: $result"
        }
        return $result
    }
    error "GitHub API requires curl or wget for directory listing."
}

# ::lucaschess::parseGitHubDir
proc ::lucaschess::parseGitHubDir {json} {
    set files {}
    # Match JSON objects and extract name/download_url pairs together
    set objPat {\{[^\}]*"name"\s*:\s*"([^"]+)"[^\}]*"download_url"\s*:\s*("null"|"([^"]+)")[^\}]*\}}
    foreach {_ name nullOrUrl actualUrl} [regexp -all -inline $objPat $json] {
        # Skip if download_url is null or missing
        if {$nullOrUrl eq "null" || $actualUrl eq ""} { continue }
        if {$name eq ""} { continue }

        set skip 0
        foreach ext $::lucaschess::skipExtensions {
            if {[string match "*$ext" $name]} { set skip 1; break }
        }
        if {!$skip} { lappend files [list $name $actualUrl] }
    }
    return $files
}

# ::lucaschess::downloadEngineDir
proc ::lucaschess::downloadEngineDir {enginedata os} {
    lassign $enginedata key name elo exe folder nodes_comp lelo_min lelo_max config
    set destDir [file join $::scidEnginesDir "lucaschess" $folder]

    if {$::windowsOS} { set exe "$exe.exe" }

    if {[file exists [file join $destDir $exe]]} {
        set answer [tk_messageBox -title "scidCommunity" -icon question -type yesno \
            -message "Engine $name already exists at:\n[file join $destDir $exe]\n\nDownload again?"]
        if {$answer ne "yes"} { return [file join $destDir $exe] }
    }

    set apiUrl "$::lucaschess::githubApi/bin/OS/$os/Engines/$folder"
    set filesToDl {}

    if {[catch {
        set json [::lucaschess::fetchGitHubApi $apiUrl]
        set filesToDl [::lucaschess::parseGitHubDir $json]
    }]} {
        # API failed - fall back to direct download
    }

    if {[llength $filesToDl] == 0} {
        set filesToDl [list [list $exe "$::lucaschess::githubBase/$os/Engines/$folder/$exe"]]
    }

    file mkdir $destDir
    set exePath ""
    set errors {}
    foreach fileInfo $filesToDl {
        lassign $fileInfo fileName downloadUrl
        set destFile [file join $destDir $fileName]
        if {[catch {
            ::lucaschess::downloadFile $downloadUrl $destFile
        } err]} {
            lappend errors "$fileName: $err"
            continue
        }
        if {$fileName eq $exe} {
            set exePath $destFile
        }
        if {!$::windowsOS && $fileName eq $exe} {
            if {[catch {file attributes $destFile -permissions 0755}]} {}
        }
    }

    if {$exePath eq ""} {
        error "Could not find engine binary: $exe\nErrors: [join $errors "\n"]"
    }

    if {[llength $errors] > 0} {
        tk_messageBox -title "scidCommunity" -icon warning \
            -message "Some files could not be downloaded:\n[join $errors "\n"]"
    }

    if {!$::windowsOS} { catch {file attributes $exePath -permissions 0755} }
    return $exePath
}

# ::lucaschess::installEngine
proc ::lucaschess::installEngine {enginedata} {
    lassign $enginedata key name elo exe folder nodes_comp lelo_min lelo_max config
    set dlg .lucaschessdlg
    if {[winfo exists $dlg]} { destroy $dlg }

    if {$::windowsOS} {
        set os "win32"
    } elseif {$::macOS} {
        tk_messageBox -title "scidCommunity" -icon error \
            -message "Lucas Chess engine installation is not supported on macOS.\n\nThe Lucas Chess R repository does not provide macOS binaries."
        return
    } else {
        set os "linux"
    }

    win::createDialog $dlg
    ::setTitle $dlg "scidCommunity: Installing $name"
    pack [ttk::label $dlg.msg -text "Downloading $name from Lucas Chess R..."] -padx 20 -pady 10
    pack [ttk::progressbar $dlg.bar -mode indeterminate] -fill x -padx 20 -pady 5
    $dlg.bar start
    update

    if {[catch {
        set exePath [::lucaschess::downloadEngineDir $enginedata $os]
    } err]} {
        destroy $dlg
        tk_messageBox -title "scidCommunity" -icon error \
            -message "Download failed:\n$err"
        return
    }

    destroy $dlg

    set engineDir [file dirname $exePath]
    set engineName [::enginecfg::uniquename "Lucas Chess $name"]

    set newEngine [list $engineName $exePath {} $engineDir $elo [clock seconds] \
        {} 1 {}]
    lappend ::engines(list) $newEngine
    ::enginecfg::write
    ::enginelist::sort

    set msg "Engine \"$engineName\" (ELO $elo) installed.\n\nLocation: $exePath"
    if {$config ne ""} {
        append msg "\n\nLucas ELO config: $config\nUse these UCI options to adjust playing strength."
    }
    tk_messageBox -title "scidCommunity" -icon info -message $msg
}

# ::lucaschess::choose
proc ::lucaschess::choose {} {
    set w .lucaschess
    if {[winfo exists $w]} { raise $w; return }
    win::createDialog $w
    ::setTitle $w "scidCommunity: Lucas Chess Engines"

    ttk::frame $w.list
    ttk::treeview $w.list.tree -columns {Name IntELO LucasELO} -height 20 \
        -show headings -selectmode browse -yscrollcommand "$w.list.ybar set"
    $w.list.tree column Name -width 200
    $w.list.tree heading Name -text "Engine"
    $w.list.tree column IntELO -anchor center -width 60
    $w.list.tree heading IntELO -text "ELO"
    $w.list.tree column LucasELO -anchor w -width 380
    $w.list.tree heading LucasELO -text "Lucas ELO settings"

    ttk::scrollbar $w.list.ybar -command "$w.list.tree yview"
    pack $w.list.tree $w.list.ybar -side left -fill both -expand 1

    set sorted [lsort -integer -decreasing -index 2 $::lucaschess::engines]
    foreach e $sorted {
        lassign $e key name elo exe folder nodes_comp lelo_min lelo_max config
        set lucasELO ""
        if {$lelo_min ne "" && $lelo_max ne ""} {
            set lucasELO "$lelo_min - $lelo_max"
            if {$config ne ""} {
                append lucasELO "   $config"
            }
        }
        $w.list.tree insert {} end -id $key -values [list $name $elo $lucasELO]
    }

    bind $w.list.tree <ButtonRelease-1> "
        lassign \[$w.list.tree identify %x %y\] what
        if {\$what eq {heading}} {
            set col \[$w.list.tree column \[$w.list.tree identify column %x %y\] -id\]
            ::lucaschess::sort $w \$col
        }
    "
    pack $w.list -side top -fill both -expand 1 -padx 5 -pady 5

    ttk::frame $w.buttons
    dialogbutton $w.buttons.install -text "Install" -command "
        set sel \[$w.list.tree selection\]
        if {\$sel ne {}} {
            foreach e \$::lucaschess::engines {
                if {\[lindex \$e 0\] eq \$sel} {
                    ::lucaschess::installEngine \$e
                    break
                }
            }
        }
    "
    dialogbutton $w.buttons.close -text "Close" -command "destroy $w"
    packbuttons right $w.buttons.close $w.buttons.install
    pack $w.buttons -side top -fill x -padx 5 -pady {0 5}

    bind $w.list.tree <Double-1> "$w.buttons.install invoke"
    bind $w <Escape> "destroy $w"
    wm protocol $w WM_DELETE_WINDOW "destroy $w"
}

# ::lucaschess::sort
proc ::lucaschess::sort {w col} {
    set tree $w.list.tree
    set children [$tree children {}]
    if {[llength $children] == 0} { return }

    set items {}
    foreach child $children {
        set vals [$tree item $child -values]
        lassign $vals name intElo lucasElo
        if {$intElo eq ""} { set intElo 0 }
        set lucasSort 0
        if {$lucasElo ne ""} {
            set lucasSort [lindex [split $lucasElo " "] 0]
        }
        lappend items [list $child $name $intElo $lucasSort]
    }

    switch $col {
        Name     { set items [lsort -dictionary -index 1 $items] }
        IntELO   { set items [lsort -integer -decreasing -index 2 $items] }
        LucasELO { set items [lsort -integer -decreasing -index 3 $items] }
    }

    foreach item $items { $tree move [lindex $item 0] {} end }
}
