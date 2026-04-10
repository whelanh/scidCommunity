Name:           scidcommunity
Version:        5.1.2.98
Release:        3.git%{shortcommit}%{?dist}
Summary:        Chess database application with play and training functionality

# Commit hash from github branch
%global commit 4b170c3843e1b20166e301284d9b2350385efebe
%global shortcommit %(c=%{commit}; echo ${c:0:7})

License:        GPL-2.0-or-later
URL:            https://github.com/whelanh/scidCommunity
Source0:        https://github.com/whelanh/scidCommunity/archive/%{commit}/scidCommunity-%{commit}.tar.gz

BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  tcl-devel >= 8.6
BuildRequires:  tk-devel >= 8.6
BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib

Requires:       tcl >= 8.6
Requires:       tk >= 8.6

%description
ScidCommunity is a chess database application based on Scid (Shane's Chess
Information Database). With ScidCommunity you can maintain a database of chess
games, search games by many criteria, view graphical trends, and produce
printable reports on players and openings. 

ScidCommunity offers enhancements including improved header search with saved
layouts, engine depth and move time controls, TWIC game downloads, and
integration with online chess platforms like Chess.com and Lichess.

%prep
# GitHub archive creates directory named: scidCommunity-<commit>
%autosetup -n scidCommunity-%{commit}

%build
%cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="%{optflags}" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCPACK_PACKAGE_VERSION=%{version} \
    -DCMAKE_INSTALL_PREFIX=/usr
%cmake_build

%install
%cmake_install

%check
desktop-file-validate %{buildroot}%{_datadir}/applications/io.github.whelanh.scidCommunity.desktop
appstream-util validate-relax --nonet %{buildroot}%{_metainfodir}/io.github.whelanh.scidCommunity.appdata.xml

%files
%license COPYING
%doc README.md
%{_bindir}/scidCommunity
%{_bindir}/phalanx-scid
%{_datadir}/scid/
%{_datadir}/applications/io.github.whelanh.scidCommunity.desktop
%{_datadir}/icons/hicolor/scalable/apps/io.github.whelanh.scidCommunity.svg
%{_metainfodir}/io.github.whelanh.scidCommunity.appdata.xml

%changelog
* Fri Apr 10 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-98
- "Add Arabic and Hebrew language options"
* Thu Apr 9, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-97
- "Fix gamelist ordering on auto-load"
* Wed Apr 8, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-96
- "Simplify manual time entry; improve German translation"
* Tue Apr 7, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-95
- "Fix mouse wheel bindings in Board display"
* Tue Apr 7, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-93
- "Security enhancements (no functional change)"
* Mon Apr 6, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-92
- "Remove auto-scroll on double-click in the Gamelist window"
* Mon Apr 6, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-90
- "Speed enhancements + game selection fix"
* Sun Apr 5, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-89
- "Fix issue with multi-game select in Gamelist Window"
* Sat Apr 4, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-88
- "Persist multiple game choices in Gamelist Window; revert no compaction while Engine Window open"
* Sat Apr 4, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-87
- "Allow Ctrl + mouse click and Shift + mouse click to select multiple games in Gamelist Window"
* Fri Apr 3, 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-86
- "Minor fixes to time recording in Serious games and Time Analysis graph labels"
* Tue Mar 31 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-85
- "Fix loading of informant values"
* Mon Mar 30 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-84
- "Add rotate board button; add default informant labels to Preferences menu"
* Sat Mar 28 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-83
- "Add ability to use wildcards in custom photo names"
* Sat Mar 28 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-81
- "Simplify custom photo usage (png and gif)"
* Thu Mar 26 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-80
- "Complete overhaul and update of Opening Report"
* Thu Mar 26 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-79
- "Add ability to show evaluation symbols; update Help files"
* Thu Mar 26 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-78
- "Add Invert Search button to the Header Search window"
* Wed Mar 25 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-77
- "Fix mask feature in the Tree Window"
* Tue Mar 24 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-73
- "Enable THP support for Linux users"
* Mon Mar 23 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-72
- "Security hardening"
* Mon Mar 23 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-69
- "Link Load Game features to the Game List Window"
* Sat Mar 21 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-68
- "Expand .lock message + translate"
* Fri Mar 20 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-67
- "Various fixes, local language translations"
* Thu Mar 19 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-65
- "Add new themes and modularize theme handling"
* Wed Mar 18 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-63
- "Add time analysis graphs and time input; add base corruption safeguard"
* Tue Mar 17 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-62
- "Added options for Tactical Game play"
* Sat Mar 14 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-61
- "Improved Portuguese translation and improved AI comment prompts"
* Fri Mar 13 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-52
- "Fix navigation issue with the board arrow keys at variations"
* Thu Mar 12 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-51
- "Move AI comment buttons to Engine Window and add Portuguese piece encoding"
* Thu Mar 12 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-50
- "Restore in-memory caching of engine results in the Engine Window"
* Wed Mar 11 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-49
- "Engine score regraph redrawn when user selects a new game"
* Wed Mar 11 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-48
- "Added Game Accuracy labels in the Engine Score chart in the Engine Window"
* Mon Mar 09 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-44
- "Add move navigation from the score graph in the Engine Window"
* Mon Mar 09 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-41
- "Add Scid score graph to the Engine Window"
* Sun Mar 08 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-40
- "Honor user preference for no arrows in analysis/engine windows; add move sounds"
* Sat Mar 07 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-39
- "Added tree information to Auto Comment prompts and incorporated upstream changes"
* Thu Mar 05 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-38
- "Added local language support for Auto Comment buttons"
* Thu Mar 05 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-37
- "Final improvements for prompts used for the Auto Comment buttons"
* Wed Mar 04 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-36
- "Refinements to prompts used in Auto Comment buttons"
* Tue Mar 03 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-35
- "Add Auto Comment buttons to the PGN and Analysis Engine windows"
* Fri Feb 27 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-33
- "Added stored evaluations panel to top of the Engine Window"
* Thu Feb 26 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-32
- "Added new Lichess Eval button in PGN window to look up stored evals"
* Tue Feb 24 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-31
- "Changes made for Flatpak version"
* Sun Feb 22 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-25
- "Add more audio packages to Snap build, translation additions"
* Sat Feb 21 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-24
- "Fix audio set up for move announcements/move sounds"
* Tue Feb 17 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-23
- "Update Tip Of The Day"
* Wed Feb 11 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-22
- "Continue to correct outdated and inaccurate help files"
* Wed Feb 11 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-21
- "Update help files for new features"
* Mon Feb 9 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-20
- "Add headless API: no impact to GUI users"
* Sun Feb 8 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-19
- "Refine Lichess Table Base button reporting of partial 8-man tablebase results"
* Thu Feb 5 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-18
- "Add column to Tree View window showing gross percentage of wins for side to move"
* Wed Feb 4 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-17
- "fix translations for new features"
* Wed Feb 4 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-16
- "Update language files for new functions"
* Mon Feb 3 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-14
- "Allow multiple move sequences in the Tree Window"
* Mon Feb 3 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-13
- "Improved HTML and HTML+JavaScript Exports"
* Mon Feb 2 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-10
- "Removed out of date LaTex code, modernized cpp code and updated help files"
* Sun Feb 1 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-09
- "Cleanup Export game to HTML options and remove Latex option"
* Mon Jan 27 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-08
- "Change Options/Language list to local words for language"
* Mon Jan 26 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-07
- "Add Japanese and Romanian language .tcl files"
* Sun Jan 25 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-06
- "Add Turkish and Serbian Cyrillic and update other language .tcl files"
* Sat Jan 24 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-05
- "Additional translation additions"
* Fri Jan 23 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-04
- "Add machine-translated chinese.tcl file"
* Thu Jan 22 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-03
- "Add missing translations to german, spanish, italian and french language files"
* Thu Jan 22 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-02
- "Fix highlighting in sand and cobalt2 themes"
* Tue Jan 20 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-01
- "Better handling of user moves in a live Lichess Tournament game if the Pause button has been pressed"
* Sat Jan 17 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.2-0
- "User moves in a live Lichess tournament game get moved to a comment when new actually played moves are updated"
* Fri Jan 16 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-99
- "Various additional fixes to Flatpak About, translation and arrow navigation"
* Fri Jan 16 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-98
- "Various fixes to About, translation and arrow navigation"
* Thu Jan 15 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-97
- "Add option to toggle engine variation arrows off"
* Thu Jan 15 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-96
- "Correct deutsch.tcl language file"
* Wed Jan 14 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-95
- "Further refinements of down arrow when more than one variation for a move"
* Wed Jan 14 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-94
- "Allow down arrow in PGN Window to enter a variation (right arrow continues in variation), up arrow returns to main line"
* Wed Jan 14 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-83
- "Add Lichess/ChessBase format for arrows and symbols as default"
* Wed Jan 14 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-82
- "Add multi-colored arrows for engine analysis: green (Best), yellow (2nd), red (3rd+)"
* Mon Jan 12 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-81
- "Extend automatic repetition detection to new moves"
* Mon Jan 12 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-80
- "Update COPYING file"
* Mon Jan 12 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-79
- "Implement automatic 2-fold and 3-fold repetition detection in PGN Window"
* Sat Jan 10 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-78
- "Allow the Play/Tactical Game function to use any engine the user has configured, eliminating dependency on Phalanx/Toga"
* Sun Jan 4 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-77
- "Have the Best Games button honor the state of the all_games checkbox"
* Fri Jan 2 2026 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-76
- "Incorporate upstream patches and update copyright years"
* Tue Dec 30 2025 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-75
- "Add pause button to PGN Window only for Lichess Tournament games"
* Fri Dec 26 2025 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-74
- Align Engine Window variation hover pop up with Board perspective
* Thu Dec 25 2025 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-73
- Simplify Lichess live tournament monitoring and auto jump to last move
* Wed Dec 24 2025 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-72
- Lichess live tournament monitoring
- Button in PGN Window for chessdb.cn engine based tree web page
* Mon Dec 09 2025 Hugh Whelan <brickhousedevelopers@gmail.com> - 5.1.1-1
- Initial COPR package
- Chess database application with enhanced features
- Includes Header Search layouts, engine controls, TWIC downloads
- Integration with Chess.com and Lichess platforms
