#!/bin/sh
# Compile every CQL translation unit that the application builds and fail if
# any of them produces a warning or fails to compile.
#
# Every .cpp in this directory is part of the application build and is compiled
# below. A future import that reintroduces an old idiom shows up here instead of
# being silenced in the build files.
#
#   src/cql/scripts/check-warnings.sh
#
set -u

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cql=$(CDPATH= cd -- "$here/.." && pwd)
src=$(CDPATH= cd -- "$cql/.." && pwd)

CXX=${CXX:-g++}
# Matches the application build (Makefile's WARNINGS): the whole tree compiles
# with -Wno-deprecated-declarations, so the check must not fail on something the
# real build accepts. This is not a CQL-specific suppression.
CXXFLAGS=${CXXFLAGS:--std=c++20 -Wall -Wextra -Wno-deprecated-declarations}
# -frtti: the engine dispatches on dynamic_cast<>() throughout.
CQLFLAGS="-DINTEGRATED -frtti -I$src -I$src/external -I$cql"

warnings=$(mktemp)
trap 'rm -f "$warnings"' EXIT

for file in "$cql"/*.cpp; do
    # shellcheck disable=SC2086
    output=$($CXX $CXXFLAGS -fsyntax-only $CQLFLAGS "$file" 2>&1)
    status=$?
    printf '%s\n' "$output" |
        grep -E "^$cql/.*(warning|error):" >>"$warnings"
    if [ "$status" -ne 0 ]; then
        # A failure caused by a shared header (src/game.h, src/common.h, ...) is
        # outside the directory filter above. Report the compiler's own output
        # rather than finishing with an empty warning list and exit status 0.
        printf '%s\n' "$output" >&2
        echo "CQL: $file failed to compile." >&2
        exit 1
    fi
done

if [ -s "$warnings" ]; then
    sort -u "$warnings" >&2
    echo "CQL: warnings above; the engine must compile warning-free." >&2
    exit 1
fi
echo "CQL: all translation units compile without warnings."
