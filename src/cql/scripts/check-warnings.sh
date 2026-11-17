#!/bin/sh
# Compile every CQL translation unit that the application builds and fail if
# any of them produces a warning.
#
# The CQL engine used to be compiled with -Wno-write-strings, -Wno-sign-compare
# and friends (see the import notes in README.md). It is now C++20-clean, and
# this guard keeps it that way: a future import that reintroduces an old
# idiom shows up here instead of being silenced in the build files.
#
#   src/cql/scripts/check-warnings.sh
#
# cql.cpp (the standalone main()) and origChanges.cpp (scidvspc's Game patches,
# which replace code scidCommunity does not have) are not part of the
# application build, so they are not compiled here either.
set -u

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cql=$(CDPATH= cd -- "$here/.." && pwd)
src=$(CDPATH= cd -- "$cql/.." && pwd)

CXX=${CXX:-g++}
CXXFLAGS=${CXXFLAGS:--std=c++20 -Wall -Wextra -Wno-deprecated-declarations}
# -frtti: the engine dispatches on dynamic_cast<>() throughout.
CQLFLAGS="-DINTEGRATED -frtti -I$src -I$src/external -I$cql"

warnings=$(mktemp)
trap 'rm -f "$warnings"' EXIT

for file in "$cql"/*.cpp; do
    case $(basename "$file") in
    cql.cpp | origChanges.cpp) continue ;;
    esac
    # shellcheck disable=SC2086
    $CXX $CXXFLAGS -fsyntax-only $CQLFLAGS "$file" 2>&1 |
        grep -E "^$cql/.*(warning|error):" >>"$warnings"
done

if [ -s "$warnings" ]; then
    sort -u "$warnings" >&2
    echo "CQL: warnings above; the engine must compile warning-free." >&2
    exit 1
fi
echo "CQL: all translation units compile without warnings."
