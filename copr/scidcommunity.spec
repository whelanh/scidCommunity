Name:           scidcommunity
Version:        5.1.1
Release:        3.git%(c=%{commit}; echo ${c:0:7})%{?dist}
Summary:        Chess database application with play and training functionality

# Commit hash from github branch
%global commit cee3cc8b96b1476e44547c130e9316de47e9810b
%global shortcommit %(c=%{commit}; echo ${c:0:7})

License:        GPL-2.0-or-later
URL:            https://github.com/whelanh/scidCommunity
# For COPR SCM method: point to specific commit instead of tag
# Source0: https://github.com/whelanh/scidCommunity/archive/%{commit}/scidcommunity-%{shortcommit}.tar.gz
Source0:        scidcommunity-%{version}.tar.gz

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
    -DCPACK_PACKAGE_VERSION=%{version}
%cmake_build

%install
%cmake_install

%check
desktop-file-validate %{buildroot}%{_datadir}/applications/io.github.whelanh.scidCommunity.desktop
appstream-util validate-relax --nonet %{buildroot}%{_metainfodir}/io.github.whelanh.scidCommunity.appdata.xml

%files
%license COPYING
%doc README.md ChangeLog
%{_bindir}/scidCommunity
%{_bindir}/phalanx-scid
%{_datadir}/scid/
%{_datadir}/applications/io.github.whelanh.scidCommunity.desktop
%{_datadir}/icons/hicolor/scalable/apps/io.github.whelanh.scidCommunity.svg
%{_metainfodir}/io.github.whelanh.scidCommunity.appdata.xml

%changelog

* Mon Dec 09 2025 Hugh Whelan <hugh@example.com> - 5.1.1-1
- Initial COPR package
- Chess database application with enhanced features
- Includes Header Search layouts, engine controls, TWIC downloads
- Integration with Chess.com and Lichess platforms
