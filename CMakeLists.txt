# Copyright (C) 2016-2017  Fulvio Benini
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid. If not, see <http://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.15)
project(scid)
if(NOT CPACK_PACKAGE_VERSION)
  if(DEFINED ENV{SCIDCOMMUNITY_VERSION} AND NOT "$ENV{SCIDCOMMUNITY_VERSION}" STREQUAL "")
    set(CPACK_PACKAGE_VERSION $ENV{SCIDCOMMUNITY_VERSION})
  else()
    # Try to get the version from git
    find_package(Git QUIET)
    if(GIT_FOUND)
      execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE GIT_RESULT
        OUTPUT_VARIABLE GIT_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )
      if(GIT_RESULT EQUAL 0)
        # Remove 'v' prefix if present
        if(GIT_VERSION MATCHES "^v")
          string(SUBSTRING ${GIT_VERSION} 1 -1 GIT_VERSION)
        endif()
        set(CPACK_PACKAGE_VERSION ${GIT_VERSION})
      endif()
    endif()

    if(NOT CPACK_PACKAGE_VERSION)
      set(CPACK_PACKAGE_VERSION 5.1.0)
    endif()
  endif()
endif()
set(
  CPACK_PACKAGE_DESCRIPTION_SUMMARY
  "chess database application with play and training functionality"
)
set(CPACK_DEBIAN_PACKAGE_DEPENDS "tk8.6 (>= 8.6.0), libtcl8.6 (>= 8.6.0), libtk8.6 (>= 8.6.0)")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
include(CPack)

# Pass version and build date to C++ code as compile-time definitions
# This allows the Help/About dialog to show dynamic version and date information
# Get build date from git commit date (works better with reproducible builds like Flatpak)
if(GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --format=%cd --date=format:%b\ %d\ %Y
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE GIT_DATE_RESULT
    OUTPUT_VARIABLE SCID_BUILD_DATE
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT GIT_DATE_RESULT EQUAL 0)
    string(TIMESTAMP SCID_BUILD_DATE "%b %d %Y")
  endif()
else()
  string(TIMESTAMP SCID_BUILD_DATE "%b %d %Y")
endif()
add_compile_definitions(
  SCID_VERSION_STRING="${CPACK_PACKAGE_VERSION}"
  SCID_BUILD_DATE="${SCID_BUILD_DATE}"
)


set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CXX_FLAGS)
  set(CMAKE_BUILD_TYPE "Release")
endif()

if(MSVC)
  add_definitions(/D_CRT_SECURE_NO_WARNINGS /D_SCL_SECURE_NO_WARNINGS)
  # To run/debug using Visual Studio set "scid" as startup project and add:
  # Command Arguments: ../tcl/start.tcl
  # Environment:       PATH=C:\tcl\bin
endif()

find_package(Threads)
find_package(TCL)

# polyglot
file(GLOB POLYGLOT_SRC src/polyglot/*.cpp)
add_library(polyglot ${POLYGLOT_SRC})

# scidCommunity
file(GLOB SCID_SRC src/*.h src/*.cpp)
if(MSVC)
  add_executable(scidCommunity WIN32 ${SCID_SRC} resources/win/scid.rc resources/win/scid.manifest)
  target_link_options(scidCommunity PRIVATE /ENTRY:mainCRTStartup)
else()
  add_executable(scidCommunity ${SCID_SRC})
endif()
set_property(TARGET scidCommunity PROPERTY INTERPROCEDURAL_OPTIMIZATION_RELEASE True)
target_include_directories(scidCommunity PRIVATE ${TCL_INCLUDE_PATH} ${TK_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/src/external)
target_link_libraries(scidCommunity PRIVATE polyglot ${CMAKE_THREAD_LIBS_INIT} ${TCL_LIBRARY} ${TK_LIBRARY})

option(SPELLCHKVALIDATE "Verify the integrity of spelling files" OFF)
if(SPELLCHKVALIDATE)
  target_compile_definitions(scidCommunity PRIVATE -DSPELLCHKVALIDATE)
endif()

option(INCLUDE_ICCF "Include ICCF archive downloader (login required, not for release builds)" OFF)
if(INCLUDE_ICCF)
  set(ICCF_TCL_FLAG "set ::iccfEnabled 1")
else()
  set(ICCF_TCL_FLAG "")
endif()
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/tcl/build_flags.tcl.in"
  "${CMAKE_CURRENT_SOURCE_DIR}/tcl/build_flags.tcl"
  @ONLY
)

install(TARGETS scidCommunity DESTINATION bin)

# Create symlink for system-wide access (for RPM/DEB packages installed in /opt)
if(CMAKE_INSTALL_PREFIX MATCHES "^/opt/")
  # Create a symlink from /usr/local/bin to the installed binary
  install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory \
    \$ENV{DESTDIR}/usr/local/bin)")
  install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink \
    ${CMAKE_INSTALL_PREFIX}/bin/scidCommunity \
    \$ENV{DESTDIR}/usr/local/bin/scidcommunity)")
endif()

file(GLOB ECO_FILES *.eco)
install(FILES ${ECO_FILES} DESTINATION share/scid)
install(DIRECTORY bitmaps DESTINATION share/scid)
install(DIRECTORY bitmaps2 DESTINATION share/scid)
install(DIRECTORY books DESTINATION share/scid)
install(DIRECTORY html DESTINATION share/scid)
install(DIRECTORY img DESTINATION share/scid)
install(DIRECTORY scripts DESTINATION share/scid)
install(DIRECTORY sounds DESTINATION share/scid)
install(DIRECTORY tcl DESTINATION share/scid)

# Install desktop file, appdata, and icon
install(FILES data/io.github.whelanh.scidCommunity.desktop DESTINATION share/applications)
install(FILES data/io.github.whelanh.scidCommunity.appdata.xml DESTINATION share/metainfo)
install(FILES data/io.github.whelanh.scidCommunity.svg DESTINATION share/icons/hicolor/scalable/apps)

# engine phalanx
file(GLOB PHALANX_SRC engines/phalanx-scid/*.c)
add_executable(phalanx-scid ${PHALANX_SRC})
set_target_properties(phalanx-scid PROPERTIES COMPILE_FLAGS "-w")
install(TARGETS phalanx-scid DESTINATION bin)


option(GTEST "Build unit tests" OFF)
if(GTEST)
  add_subdirectory(gtest)
endif()
