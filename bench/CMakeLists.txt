# Copyright (C) 2026 Hugh Whelan
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

cmake_minimum_required(VERSION 3.15)
set(CMAKE_CXX_STANDARD 20 CACHE STRING "")

# The same core sources the unit tests link; no Tcl/Tk needed.
set(SCID_CORE
  ../src/cb2_annotations.cpp
  ../src/cb2_format.cpp
  ../src/cb2_moves.cpp
  ../src/codec_cb2.cpp
  ../src/codec_scid4.cpp
  ../src/epdbook.cpp
  ../src/scidbase.cpp
  ../src/sortcache.cpp
  ../src/stored.cpp
  ../src/game.cpp
  ../src/position.cpp
  ../src/textbuf.cpp
  ../src/misc.cpp
  ../src/matsig.cpp
  ../src/filter.cpp
)

find_package(Threads REQUIRED)
add_executable(tree_bench tree_bench.cpp ${SCID_CORE})
target_include_directories(tree_bench PRIVATE ../src)
target_link_libraries(tree_bench PRIVATE ${CMAKE_THREAD_LIBS_INIT})
set_property(TARGET tree_bench PROPERTY INTERPROCEDURAL_OPTIMIZATION_RELEASE True)
