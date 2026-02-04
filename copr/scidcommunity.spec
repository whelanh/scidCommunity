Name:           scidcommunity
Version:        5.1.2.17
Release:        3.git%{shortcommit}%{?dist}
Summary:        Chess database application with play and training functionality

# Commit hash from github branch
%global commit 9bc0353648d09ee2682b3d097c22007f2877fd02
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
